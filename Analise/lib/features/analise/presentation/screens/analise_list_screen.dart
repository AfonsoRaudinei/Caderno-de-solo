import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/presentation/providers/analise_provider.dart';
import 'package:soloforte/features/analise/presentation/widgets/analise_card_widget.dart';
import 'package:soloforte/features/analise/presentation/widgets/produtor_row_widget.dart';
import 'package:soloforte/features/analise/presentation/widgets/filter_chips_widget.dart';

class AnaliseListScreen extends ConsumerStatefulWidget {
  const AnaliseListScreen({super.key});

  @override
  ConsumerState<AnaliseListScreen> createState() => _AnaliseListScreenState();
}

class _AnaliseListScreenState extends ConsumerState<AnaliseListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCultura;
  String? _selectedSafra;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Cultura? culturaEnum;
    if (_selectedCultura != null) {
      culturaEnum = Cultura.values.firstWhere(
        (e) => e.label == _selectedCultura,
        orElse: () => Cultura.soja,
      );
    }

    final analises = ref.watch(
      analisesFiltradasProvider(
        cultura: culturaEnum,
        safra: _selectedSafra,
        busca: _searchQuery,
      ),
    );

    final produtores = ref.watch(analiseRepositoryProvider).getProdutores();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Análise de Solo'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(130),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Buscar área, produtor, cultura...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilterChipsWidget(
                labels: Cultura.values.map((e) => e.label).toList(),
                selectedLabel: _selectedCultura,
                onSelected: (label) {
                  setState(() {
                    _selectedCultura = _selectedCultura == label ? null : label;
                  });
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: FutureBuilder(
              future: produtores,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                final list = snapshot.data!;
                if (list.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        'Produtores',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        return ProdutorRowWidget(produtor: list[index]);
                      },
                    ),
                    const Divider(),
                  ],
                );
              },
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Análises',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (analises.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.science_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Nenhuma análise encontrada',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Toque em + para cadastrar uma nova análise',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final analise = analises[index];
                    return AnaliseCardWidget(
                      analise: analise,
                      onTap: () {
                        context.push('${AppRoutes.analise}/detalhe/${analise.id}');
                      },
                    );
                  },
                  childCount: analises.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(AppRoutes.analiseForm);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
