import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/widgets/app_input.dart';
import 'package:soloforte/features/clientes/application/providers/cliente_provider.dart';
import 'package:soloforte/features/clientes/presentation/widgets/cliente_card_widget.dart';

class ClientesListScreen extends ConsumerStatefulWidget {
  const ClientesListScreen({super.key});

  @override
  ConsumerState<ClientesListScreen> createState() => _ClientesListScreenState();
}

class _ClientesListScreenState extends ConsumerState<ClientesListScreen> {
  final TextEditingController _buscaController = TextEditingController();
  String _busca = '';

  @override
  void initState() {
    super.initState();
    _buscaController.addListener(() {
      setState(() => _busca = _buscaController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ClienteState>(clienteProvider, (previous, next) {
      final erro = next.erro;
      if (erro != null && erro.isNotEmpty && erro != previous?.erro) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              backgroundColor: AppColors.error,
              content: Text(erro),
            ),
          );
        ref.read(clienteProvider.notifier).limparErro();
      }
    });

    final state = ref.watch(clienteProvider);
    final clientes = state.clientes.where((cliente) {
      if (_busca.isEmpty) return true;
      final nome = cliente.nome.toLowerCase();
      final token = cliente.token.toLowerCase();
      return nome.contains(_busca) || token.contains(_busca);
    }).toList(growable: false);

    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      appBar: AppBar(
        title: const Text('Clientes'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => context.push(AppRoutes.clienteNovo),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          children: [
            AppInput(
              controller: _buscaController,
              label: 'Busca',
              hint: 'Buscar por nome ou token',
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.textSecond,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (state.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (clientes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.person_outline,
                            size: 72,
                            color: AppColors.textSecond,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Nenhum cliente cadastrado',
                            style: AppTextStyles.label,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Toque em + para adicionar',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () =>
                        ref.read(clienteProvider.notifier).carregarClientes(),
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 96),
                      itemCount: clientes.length,
                      itemBuilder: (context, index) {
                        final cliente = clientes[index];
                        return ClienteCardWidget(
                          cliente: cliente,
                          onTap: () {
                            ref
                                .read(clienteProvider.notifier)
                                .selecionarCliente(cliente);
                            context.push(
                              AppRoutes.clienteDetalhePath(cliente.id),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
