import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/domain/entities/produtor.dart';
import 'package:soloforte/features/analise/presentation/providers/analise_provider.dart';
import 'package:soloforte/features/analise/presentation/widgets/localizacao_captura_widget.dart';
import 'package:soloforte/features/analise/presentation/widgets/num_field_widget.dart';
import 'package:soloforte/features/analise/presentation/widgets/upload_pdf_widget.dart';
import 'package:uuid/uuid.dart';

class NovaAnaliseScreen extends ConsumerStatefulWidget {
  final AnaliseSolo? analiseParaEditar;

  const NovaAnaliseScreen({super.key, this.analiseParaEditar});

  @override
  ConsumerState<NovaAnaliseScreen> createState() => _NovaAnaliseScreenState();
}

class _NovaAnaliseScreenState extends ConsumerState<NovaAnaliseScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores Identificação
  late String _selectedProdutorId;
  late TextEditingController _nomeAreaCtrl;
  late Cultura _selectedCultura;
  late String _selectedSafra;
  late TextEditingController _laboratorioCtrl;

  // Controladores Físico
  late TexturaSolo _selectedTextura;
  late String _selectedProfundidade;

  // Controladores Localização
  late double? _latitude;
  late double? _longitude;

  // Controladores Nutrientes
  late TextEditingController _phAguaCtrl;
  late TextEditingController _phSmpCtrl;
  late TextEditingController _phCacl2Ctrl;
  late TextEditingController _fosforoCtrl;
  late TextEditingController _potassioCtrl;
  late TextEditingController _calcioCtrl;
  late TextEditingController _magnesioCtrl;
  late TextEditingController _enxofreCtrl;
  late TextEditingController _aluminioCtrl;
  late TextEditingController _hMaisAlCtrl;

  late TextEditingController _boroCtrl;
  late TextEditingController _cobreCtrl;
  late TextEditingController _ferroCtrl;
  late TextEditingController _manganesCtrl;
  late TextEditingController _zincoCtrl;

  final List<String> safrasDisponiveis = [
    '2024/25',
    '2025/26',
    'Safrinha 2025',
    'Inverno 2025'
  ];

  final List<String> profundidadesDisponiveis = [
    '0-20 cm',
    '20-40 cm',
    '40-60 cm',
  ];

  @override
  void initState() {
    super.initState();
    final a = widget.analiseParaEditar;

    _selectedProdutorId = a?.produtorId ?? '1'; // Default produtor mock
    _nomeAreaCtrl = TextEditingController(text: a?.nomeArea ?? '');
    _selectedCultura = a?.cultura ?? Cultura.soja;
    _selectedSafra = a?.safra ?? safrasDisponiveis.first;
    _laboratorioCtrl = TextEditingController(text: a?.laboratorio ?? '');

    _selectedTextura = a?.textura ?? TexturaSolo.medio;
    _selectedProfundidade = a?.profundidade ?? profundidadesDisponiveis.first;

    _latitude = a?.latitude;
    _longitude = a?.longitude;

    _phAguaCtrl = TextEditingController(text: a?.phAgua?.toString() ?? '');
    _phSmpCtrl = TextEditingController(text: a?.phSmp?.toString() ?? '');
    _phCacl2Ctrl = TextEditingController(text: a?.phCacl2?.toString() ?? '');

    _fosforoCtrl = TextEditingController(text: a?.fosforo?.toString() ?? '');
    _potassioCtrl = TextEditingController(text: a?.potassio?.toString() ?? '');
    _calcioCtrl = TextEditingController(text: a?.calcio?.toString() ?? '');
    _magnesioCtrl = TextEditingController(text: a?.magnesio?.toString() ?? '');
    _enxofreCtrl = TextEditingController(text: a?.enxofre?.toString() ?? '');

    _aluminioCtrl = TextEditingController(text: a?.aluminio?.toString() ?? '');
    _hMaisAlCtrl = TextEditingController(text: a?.hMaisAl?.toString() ?? '');

    _boroCtrl = TextEditingController(text: a?.boro?.toString() ?? '');
    _cobreCtrl = TextEditingController(text: a?.cobre?.toString() ?? '');
    _ferroCtrl = TextEditingController(text: a?.ferro?.toString() ?? '');
    _manganesCtrl = TextEditingController(text: a?.manganes?.toString() ?? '');
    _zincoCtrl = TextEditingController(text: a?.zinco?.toString() ?? '');

    // Adiciona listener para recalcular CTC e V%
    _calcioCtrl.addListener(_setStateOnCtrlChange);
    _magnesioCtrl.addListener(_setStateOnCtrlChange);
    _potassioCtrl.addListener(_setStateOnCtrlChange);
    _hMaisAlCtrl.addListener(_setStateOnCtrlChange);
  }

  void _setStateOnCtrlChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _nomeAreaCtrl.dispose();
    _laboratorioCtrl.dispose();
    _phAguaCtrl.dispose();
    _phSmpCtrl.dispose();
    _phCacl2Ctrl.dispose();
    _fosforoCtrl.dispose();
    _potassioCtrl.dispose();
    _calcioCtrl.dispose();
    _magnesioCtrl.dispose();
    _enxofreCtrl.dispose();
    _aluminioCtrl.dispose();
    _hMaisAlCtrl.dispose();
    _boroCtrl.dispose();
    _cobreCtrl.dispose();
    _ferroCtrl.dispose();
    _manganesCtrl.dispose();
    _zincoCtrl.dispose();
    super.dispose();
  }

  double? _parseDouble(String text) {
    if (text.isEmpty) return null;
    return double.tryParse(text.replaceAll(',', '.'));
  }

  AnaliseSolo _buildDraftAnaliseParaCalculo() {
    return AnaliseSolo(
      id: '',
      produtorId: '',
      nomeArea: '',
      cultura: Cultura.soja,
      safra: '',
      laboratorio: '',
      dataCadastro: DateTime.now(),
      textura: TexturaSolo.medio,
      profundidade: '',
      calcio: _parseDouble(_calcioCtrl.text),
      magnesio: _parseDouble(_magnesioCtrl.text),
      potassio: _parseDouble(_potassioCtrl.text),
      hMaisAl: _parseDouble(_hMaisAlCtrl.text),
    );
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final analise = AnaliseSolo(
      id: widget.analiseParaEditar?.id ?? const Uuid().v4(),
      produtorId: _selectedProdutorId,
      nomeArea: _nomeAreaCtrl.text,
      cultura: _selectedCultura,
      safra: _selectedSafra,
      laboratorio: _laboratorioCtrl.text,
      dataCadastro: widget.analiseParaEditar?.dataCadastro ?? DateTime.now(),
      textura: _selectedTextura,
      profundidade: _selectedProfundidade,
      latitude: _latitude,
      longitude: _longitude,
      phAgua: _parseDouble(_phAguaCtrl.text),
      phSmp: _parseDouble(_phSmpCtrl.text),
      phCacl2: _parseDouble(_phCacl2Ctrl.text),
      fosforo: _parseDouble(_fosforoCtrl.text),
      potassio: _parseDouble(_potassioCtrl.text),
      calcio: _parseDouble(_calcioCtrl.text),
      magnesio: _parseDouble(_magnesioCtrl.text),
      enxofre: _parseDouble(_enxofreCtrl.text),
      aluminio: _parseDouble(_aluminioCtrl.text),
      hMaisAl: _parseDouble(_hMaisAlCtrl.text),
      boro: _parseDouble(_boroCtrl.text),
      cobre: _parseDouble(_cobreCtrl.text),
      ferro: _parseDouble(_ferroCtrl.text),
      manganes: _parseDouble(_manganesCtrl.text),
      zinco: _parseDouble(_zincoCtrl.text),
    );

    await ref.read(analiseNotifierProvider.notifier).salvar(analise);

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final produtores = ref.watch(analiseRepositoryProvider).getProdutores();
    final draftCalculo = _buildDraftAnaliseParaCalculo();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.analiseParaEditar == null
            ? 'Nova Análise'
            : 'Editar Análise'),
      ),
      body: FutureBuilder(
          future: produtores,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final produtoresList = snapshot.data as List<Produtor>;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    UploadPdfWidget(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Demonstração: PDF Parser será chamado aqui.')),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text('1. Identificação',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                          labelText: 'Produtor', border: OutlineInputBorder()),
                      initialValue: _selectedProdutorId,
                      items: produtoresList.map((p) {
                        return DropdownMenuItem(
                            value: p.id, child: Text(p.nome));
                      }).toList()
                        ..add(const DropdownMenuItem(
                            value: 'new', child: Text('+ Novo Produtor'))),
                      onChanged: (val) {
                        if (val != null && val != 'new') {
                          setState(() => _selectedProdutorId = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nomeAreaCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Nome da Área (Talhão)',
                          border: OutlineInputBorder()),
                      validator: (val) => val == null || val.isEmpty
                          ? 'Campo obrigatório'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<Cultura>(
                            decoration: const InputDecoration(
                                labelText: 'Cultura',
                                border: OutlineInputBorder()),
                            initialValue: _selectedCultura,
                            items: Cultura.values.map((c) {
                              return DropdownMenuItem(
                                  value: c,
                                  child: Text('${c.emoji} ${c.label}'));
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _selectedCultura = val!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                                labelText: 'Safra',
                                border: OutlineInputBorder()),
                            initialValue: _selectedSafra,
                            items: safrasDisponiveis.map((s) {
                              return DropdownMenuItem(value: s, child: Text(s));
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _selectedSafra = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _laboratorioCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Laboratório',
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 24),
                    const Text('2. Localização',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    LocalizacaoCaptura(
                      onCapturada: (latitude, longitude) {
                        setState(() {
                          _latitude = latitude;
                          _longitude = longitude;
                        });
                      },
                    ),
                    if (_latitude != null) ...[
                      const SizedBox(height: 8),
                      Text('Lat: $_latitude, Lng: $_longitude',
                          style: const TextStyle(color: Colors.green)),
                    ],
                    const SizedBox(height: 24),
                    const Text('3. Dados Físicos',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<TexturaSolo>(
                            decoration: const InputDecoration(
                                labelText: 'Textura',
                                border: OutlineInputBorder()),
                            initialValue: _selectedTextura,
                            items: TexturaSolo.values.map((t) {
                              return DropdownMenuItem(
                                  value: t, child: Text(t.name.toUpperCase()));
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _selectedTextura = val!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                                labelText: 'Profundidade',
                                border: OutlineInputBorder()),
                            initialValue: _selectedProfundidade,
                            items: profundidadesDisponiveis.map((p) {
                              return DropdownMenuItem(value: p, child: Text(p));
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _selectedProfundidade = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('4. pH e Tampão',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                            child: NumFieldWidget(
                                label: 'pH Água', controller: _phAguaCtrl)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: NumFieldWidget(
                                label: 'pH SMP', controller: _phSmpCtrl)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: NumFieldWidget(
                                label: 'pH CaCl₂', controller: _phCacl2Ctrl)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('5. Macronutrientes',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                            child: NumFieldWidget(
                          label: 'Fósforo (P)',
                          controller: _fosforoCtrl,
                          suffixText: 'mg',
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: NumFieldWidget(
                          label: 'Potássio (K)',
                          controller: _potassioCtrl,
                          suffixText: 'cmolc',
                        )),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                            child: NumFieldWidget(
                          label: 'Cálcio (Ca)',
                          controller: _calcioCtrl,
                          suffixText: 'cmolc',
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: NumFieldWidget(
                          label: 'Magnésio (Mg)',
                          controller: _magnesioCtrl,
                          suffixText: 'cmolc',
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: NumFieldWidget(
                          label: 'Enxofre (S)',
                          controller: _enxofreCtrl,
                          suffixText: 'mg',
                        )),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('6. Acidez e CTC (Automáticos)',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                            child: NumFieldWidget(
                          label: 'Alumínio (Al)',
                          controller: _aluminioCtrl,
                          suffixText: 'cmolc',
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: NumFieldWidget(
                          label: 'H+Al',
                          controller: _hMaisAlCtrl,
                          suffixText: 'cmolc',
                        )),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: NumFieldWidget(
                            label: 'CTC calculada',
                            controller: TextEditingController(
                                text: draftCalculo.ctc.toStringAsFixed(2)),
                            readOnly: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: NumFieldWidget(
                            label: 'V% calculada',
                            controller: TextEditingController(
                                text:
                                    draftCalculo.vPorcento.toStringAsFixed(2)),
                            readOnly: true,
                            suffixText: '%',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ExpansionTile(
                      title: const Text('7. Micronutrientes (mg/dm³)',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      childrenPadding: const EdgeInsets.only(bottom: 16),
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: NumFieldWidget(
                                    label: 'Boro (B)', controller: _boroCtrl)),
                            const SizedBox(width: 12),
                            Expanded(
                                child: NumFieldWidget(
                                    label: 'Cobre (Cu)',
                                    controller: _cobreCtrl)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                                child: NumFieldWidget(
                                    label: 'Ferro (Fe)',
                                    controller: _ferroCtrl)),
                            const SizedBox(width: 12),
                            Expanded(
                                child: NumFieldWidget(
                                    label: 'Manganês (Mn)',
                                    controller: _manganesCtrl)),
                            const SizedBox(width: 12),
                            Expanded(
                                child: NumFieldWidget(
                                    label: 'Zinco (Zn)',
                                    controller: _zincoCtrl)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _salvar,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Salvar Análise',
                            style: TextStyle(fontSize: 18)),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
