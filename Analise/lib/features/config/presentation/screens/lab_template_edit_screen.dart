import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/widgets/app_button.dart';
import 'package:soloforte/core/widgets/app_card.dart';
import 'package:soloforte/core/widgets/app_input.dart';
import 'package:soloforte/domain/entities/lab_template.dart';
import 'package:soloforte/features/config/presentation/controllers/lab_template_controller.dart';
import 'package:uuid/uuid.dart';

class LabTemplateEditScreen extends ConsumerStatefulWidget {
  final LabTemplate? template;

  const LabTemplateEditScreen({super.key, this.template});

  @override
  ConsumerState<LabTemplateEditScreen> createState() =>
      _LabTemplateEditScreenState();
}

class _LabTemplateEditScreenState
    extends ConsumerState<LabTemplateEditScreen> {
  late TextEditingController _nomeCtrl;
  late TextEditingController _keywordsCtrl;

  // Opção A — dropdown único para todos os nutrientes
  late UnidadeNutriente _unidadeNutrientes;
  late UnidadeMO _unidadeMO;
  late UnidadeTextura _unidadeTextura;

  // Opção C — toggles individuais
  late bool _entregaCTC;
  late bool _entregaSB;
  late bool _entregaVPercent;
  late bool _entregaMPercent;
  late bool _entregaPhAgua;
  late bool _entregaPhSMP;
  late bool _entregaH;
  late bool _entregaHidrogenioPuro;
  late bool _entregaCtcEfetiva;
  late bool _entregaMicroDtpa;
  late bool _entregaMicroMehlich;
  late bool _entregaTextura;
  late bool _entregaKNH4Cl;
  late bool _entregaCaMaisMg;
  late bool _entregaMo;
  late bool _entregaCo;
  late bool _entregaPTotal;
  late bool _entregaClassificacaoTextura;
  late bool _entregaTipoSoloMapa;
  late bool _separaSolicitanteProprietario;
  late bool _entregaAreiasDetalhadas;
  late bool _entregaCascalho;
  late bool _micronutrientesPorAmostra;
  late bool _identificacaoComposta;
  late bool _umAmostraPorLaudo;
  late bool _ativo;

  bool _salvando = false;
  final _formKey = GlobalKey<FormState>();

  bool get _isEditing => widget.template != null;
  bool get _isDefault => widget.template?.isDefault ?? false;

  @override
  void initState() {
    super.initState();
    final t = widget.template;

    _nomeCtrl = TextEditingController(text: t?.nome ?? '');
    _keywordsCtrl = TextEditingController(
      text: t?.keywords.join(', ') ?? '',
    );

    _unidadeNutrientes = t?.unidadeK ?? UnidadeNutriente.cmolcDm3;
    _unidadeMO = t?.unidadeMO ?? UnidadeMO.gDm3;
    _unidadeTextura = t?.unidadeTextura ?? UnidadeTextura.gKg;

    _entregaCTC = t?.entregaCTC ?? true;
    _entregaSB = t?.entregaSB ?? true;
    _entregaVPercent = t?.entregaVPercent ?? true;
    _entregaMPercent = t?.entregaMPercent ?? true;
    _entregaPhAgua = t?.entregaPhAgua ?? false;
    _entregaPhSMP = t?.entregaPhSMP ?? true;
    _entregaH = t?.entregaH ?? false;
    _entregaHidrogenioPuro = t?.entregaHidrogenioPuro ?? false;
    _entregaCtcEfetiva = t?.entregaCtcEfetiva ?? false;
    _entregaMicroDtpa = t?.entregaMicroDtpa ?? true;
    _entregaMicroMehlich = t?.entregaMicroMehlich ?? false;
    _entregaTextura = t?.entregaTextura ?? true;
    _entregaKNH4Cl = t?.entregaKNH4Cl ?? false;
    _entregaCaMaisMg = t?.entregaCaMaisMg ?? false;
    _entregaMo = t?.entregaMo ?? false;
    _entregaCo = t?.entregaCo ?? false;
    _entregaPTotal = t?.entregaPTotal ?? false;
    _entregaClassificacaoTextura = t?.entregaClassificacaoTextura ?? false;
    _entregaTipoSoloMapa = t?.entregaTipoSoloMapa ?? false;
    _separaSolicitanteProprietario =
        t?.separaSolicitanteProprietario ?? false;
    _entregaAreiasDetalhadas = t?.entregaAreiasDetalhadas ?? false;
    _entregaCascalho = t?.entregaCascalho ?? false;
    _micronutrientesPorAmostra = t?.micronutrientesPorAmostra ?? false;
    _identificacaoComposta = t?.identificacaoComposta ?? false;
    _umAmostraPorLaudo = t?.umAmostraPorLaudo ?? false;
    _ativo = t?.ativo ?? true;
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _keywordsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titulo = _isEditing
        ? (_isDefault ? widget.template!.nome : 'Editar Template')
        : 'Novo Template';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: Text(
          titulo,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1D1D1F),
          ),
        ),
        backgroundColor: const Color(0xFFF5F5F7),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.primary,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Aviso para templates padrão
              if (_isDefault) _AvisoReadOnly(),

              // Seção 1 — Identificação
              const _SectionHeader(titulo: 'IDENTIFICAÇÃO'),
              const SizedBox(height: 8),
              AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      AppInput(
                        controller: _nomeCtrl,
                        label: 'Nome do Laboratório',
                        hint: 'Ex: AgroLab Tocantins',
                        enabled: !_isDefault,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Campo obrigatório'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      AppInput(
                        controller: _keywordsCtrl,
                        label: 'Palavras-chave para detecção',
                        hint: 'Ex: agrolab, agrolab.com.br, João Silva',
                        enabled: !_isDefault,
                        maxLines: 3,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Adicione ao menos uma palavra-chave';
                          }
                          return null;
                        },
                      ),
                      if (!_isDefault)
                        const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Text(
                            'Separe por vírgula. O parser busca essas '
                            'palavras no PDF.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecond,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Seção 2 — Unidades (Opção A — dropdown único)
              const _SectionHeader(titulo: 'UNIDADES PADRÃO'),
              const SizedBox(height: 8),
              AppCard(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      _DropdownRow<UnidadeNutriente>(
                        label: 'K, Ca, Mg, Al, H+Al, CTC, SB',
                        value: _unidadeNutrientes,
                        items: UnidadeNutriente.values
                            .map((u) => DropdownMenuItem(
                                  value: u,
                                  child: Text(u.label),
                                ))
                            .toList(),
                        onChanged: _isDefault
                            ? null
                            : (v) =>
                                setState(() => _unidadeNutrientes = v!),
                      ),
                      const Divider(height: 1),
                      _DropdownRow<UnidadeMO>(
                        label: 'Matéria Orgânica (M.O.)',
                        value: _unidadeMO,
                        items: UnidadeMO.values
                            .map((u) => DropdownMenuItem(
                                  value: u,
                                  child: Text(u.label),
                                ))
                            .toList(),
                        onChanged: _isDefault
                            ? null
                            : (v) => setState(() => _unidadeMO = v!),
                      ),
                      const Divider(height: 1),
                      _DropdownRow<UnidadeTextura>(
                        label: 'Textura (Argila, Silte, Areia)',
                        value: _unidadeTextura,
                        items: UnidadeTextura.values
                            .map((u) => DropdownMenuItem(
                                  value: u,
                                  child: Text(u.label),
                                ))
                            .toList(),
                        onChanged: _isDefault
                            ? null
                            : (v) =>
                                setState(() => _unidadeTextura = v!),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Seção 3 — Derivados calculados
              const _SectionHeader(titulo: 'DERIVADOS CALCULADOS'),
              const SizedBox(height: 4),
              const Text(
                'Ative os campos que o lab já entrega calculados no laudo.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecond,
                ),
              ),
              const SizedBox(height: 10),
              AppCard(
                child: Column(
                  children: [
                    _ToggleRow(
                      label: 'CTC (Capacidade de Troca Catiônica)',
                      subtitle: 'Lab calcula e entrega no laudo',
                      value: _entregaCTC,
                      enabled: !_isDefault,
                      onChanged: (v) => setState(() => _entregaCTC = v),
                    ),
                    _Divider(),
                    _ToggleRow(
                      label: 'SB (Soma de Bases)',
                      value: _entregaSB,
                      enabled: !_isDefault,
                      onChanged: (v) => setState(() => _entregaSB = v),
                    ),
                    _Divider(),
                    _ToggleRow(
                      label: 'V% (Saturação por Bases)',
                      value: _entregaVPercent,
                      enabled: !_isDefault,
                      onChanged: (v) =>
                          setState(() => _entregaVPercent = v),
                    ),
                    _Divider(),
                    _ToggleRow(
                      label: 'm% (Saturação por Alumínio)',
                      value: _entregaMPercent,
                      enabled: !_isDefault,
                      onChanged: (v) =>
                          setState(() => _entregaMPercent = v),
                    ),
                    _Divider(),
                    _ToggleRow(
                      label: 'CTC Efetiva (t = SB + Al)',
                      value: _entregaCtcEfetiva,
                      enabled: !_isDefault,
                      onChanged: (v) =>
                          setState(() => _entregaCtcEfetiva = v),
                    ),
                    _Divider(),
                    _ToggleRow(
                      label: 'H° (Hidrogênio puro separado)',
                      subtitle: 'H separado de H+Al',
                      value: _entregaHidrogenioPuro,
                      enabled: !_isDefault,
                      onChanged: (v) =>
                          setState(() => _entregaHidrogenioPuro = v),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // pH
              const _SectionHeader(titulo: 'pH'),
              const SizedBox(height: 8),
              AppCard(
                child: Column(
                  children: [
                    _ToggleRow(
                      label: 'pH em Água',
                      value: _entregaPhAgua,
                      enabled: !_isDefault,
                      onChanged: (v) =>
                          setState(() => _entregaPhAgua = v),
                    ),
                    _Divider(),
                    _ToggleRow(
                      label: 'pH SMP',
                      value: _entregaPhSMP,
                      enabled: !_isDefault,
                      onChanged: (v) =>
                          setState(() => _entregaPhSMP = v),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Micronutrientes
              const _SectionHeader(titulo: 'MICRONUTRIENTES'),
              const SizedBox(height: 8),
              AppCard(
                child: Column(
                  children: [
                    _ToggleRow(
                      label: 'Cu, Fe, Mn, Zn por DTPA',
                      value: _entregaMicroDtpa,
                      enabled: !_isDefault,
                      onChanged: (v) =>
                          setState(() => _entregaMicroDtpa = v),
                    ),
                    _Divider(),
                    _ToggleRow(
                      label: 'Cu, Fe, Mn, Zn por Mehlich',
                      value: _entregaMicroMehlich,
                      enabled: !_isDefault,
                      onChanged: (v) =>
                          setState(() => _entregaMicroMehlich = v),
                    ),
                    _Divider(),
                    _ToggleRow(
                      label: 'Mo (Molibdênio)',
                      value: _entregaMo,
                      enabled: !_isDefault,
                      onChanged: (v) => setState(() => _entregaMo = v),
                    ),
                    _Divider(),
                    _ToggleRow(
                      label: 'Co (Cobalto)',
                      value: _entregaCo,
                      enabled: !_isDefault,
                      onChanged: (v) => setState(() => _entregaCo = v),
                    ),
                    _Divider(),
                    _ToggleRow(
                      label: 'Micros por amostra (não agrupados)',
                      subtitle: 'Solum lista micros individualmente',
                      value: _micronutrientesPorAmostra,
                      enabled: !_isDefault,
                      onChanged: (v) =>
                          setState(() => _micronutrientesPorAmostra = v),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Campos especiais
              const _SectionHeader(titulo: 'CAMPOS ESPECIAIS'),
              const SizedBox(height: 8),
              AppCard(
                child: Column(
                  children: [
                    _ToggleRow(
                      label: 'Textura granulométrica',
                      subtitle: 'Argila, Silte, Areia',
                      value: _entregaTextura,
                      enabled: !_isDefault,
                      onChanged: (v) =>
                          setState(() => _entregaTextura = v),
                    ),
                    _Divider(),
                    _ToggleRow(
                      label: 'Areias detalhadas (grossa + fina)',
                      value: _entregaAreiasDetalhadas,
                      enabled: !_isDefault,
                      onChanged: (v) =>
                          setState(() => _entregaAreiasDetalhadas = v),
                    ),
                    _Divider(),
                    _ToggleRow(
                      label: 'Cascalho',
                      value: _entregaCascalho,
                      enabled: !_isDefault,
                      onChanged: (v) =>
                          setState(() => _entregaCascalho = v),
                    ),
                    _Divider(),
                    _ToggleRow(
                      label: 'P Total (%)',
                      subtitle: 'Sellar entrega P Total em porcentagem',
                      value: _entregaPTotal,
                      enabled: !_isDefault,
                      onChanged: (v) =>
                          setState(() => _entregaPTotal = v),
                    ),
                    _Divider(),
                    _ToggleRow(
                      label: 'Classificação textural',
                      subtitle: 'Argilosa, Média, Arenosa',
                      value: _entregaClassificacaoTextura,
                      enabled: !_isDefault,
                      onChanged: (v) =>
                          setState(() => _entregaClassificacaoTextura = v),
                    ),
                    _Divider(),
                    _ToggleRow(
                      label: 'Tipo de solo MAPA (IN02/2008)',
                      value: _entregaTipoSoloMapa,
                      enabled: !_isDefault,
                      onChanged: (v) =>
                          setState(() => _entregaTipoSoloMapa = v),
                    ),
                    _Divider(),
                    _ToggleRow(
                      label: 'K em mg/dm³ (extrato NH₄Cl)',
                      subtitle: 'Além do K em cmolc/mmolc',
                      value: _entregaKNH4Cl,
                      enabled: !_isDefault,
                      onChanged: (v) =>
                          setState(() => _entregaKNH4Cl = v),
                    ),
                    _Divider(),
                    _ToggleRow(
                      label: 'Ca+Mg somado (campo separado)',
                      value: _entregaCaMaisMg,
                      enabled: !_isDefault,
                      onChanged: (v) =>
                          setState(() => _entregaCaMaisMg = v),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Layout do laudo
              const _SectionHeader(titulo: 'LAYOUT DO LAUDO'),
              const SizedBox(height: 8),
              AppCard(
                child: Column(
                  children: [
                    _ToggleRow(
                      label: 'Uma amostra por arquivo PDF',
                      subtitle: 'Desative se o laudo tem múltiplas amostras',
                      value: _umAmostraPorLaudo,
                      enabled: !_isDefault,
                      onChanged: (v) =>
                          setState(() => _umAmostraPorLaudo = v),
                    ),
                    _Divider(),
                    _ToggleRow(
                      label: 'Solicitante diferente do proprietário',
                      subtitle: 'Separar campos solicitante e proprietário',
                      value: _separaSolicitanteProprietario,
                      enabled: !_isDefault,
                      onChanged: (v) => setState(
                          () => _separaSolicitanteProprietario = v),
                    ),
                    _Divider(),
                    _ToggleRow(
                      label: 'Identificação composta',
                      subtitle: 'Código interno + código externo da amostra',
                      value: _identificacaoComposta,
                      enabled: !_isDefault,
                      onChanged: (v) =>
                          setState(() => _identificacaoComposta = v),
                    ),
                  ],
                ),
              ),

              // Status (só para templates custom)
              if (!_isDefault) ...[
                const SizedBox(height: 16),
                const _SectionHeader(titulo: 'STATUS'),
                const SizedBox(height: 8),
                AppCard(
                  child: _ToggleRow(
                    label: 'Template ativo',
                    subtitle:
                        'Templates inativos não são detectados no upload',
                    value: _ativo,
                    enabled: true,
                    onChanged: (v) => setState(() => _ativo = v),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),

      // Botão salvar (apenas para templates custom)
      bottomNavigationBar: _isDefault
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: AppButton(
                  label: _isEditing ? 'Salvar Alterações' : 'Criar Template',
                  onPressed: _salvando ? null : _salvar,
                  isLoading: _salvando,
                ),
              ),
            ),
    );
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    try {
      final keywords = _keywordsCtrl.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final novo = LabTemplate(
        id: widget.template?.id ?? const Uuid().v4(),
        nome: _nomeCtrl.text.trim(),
        keywords: keywords,
        unidadeK: _unidadeNutrientes,
        unidadeCa: _unidadeNutrientes,
        unidadeMg: _unidadeNutrientes,
        unidadeAl: _unidadeNutrientes,
        unidadeHAl: _unidadeNutrientes,
        unidadeNa: _unidadeNutrientes,
        unidadeCTC: _unidadeNutrientes,
        unidadeSB: _unidadeNutrientes,
        unidadeMO: _unidadeMO,
        unidadeCOT: _unidadeMO,
        unidadeTextura: _unidadeTextura,
        entregaCTC: _entregaCTC,
        entregaSB: _entregaSB,
        entregaVPercent: _entregaVPercent,
        entregaMPercent: _entregaMPercent,
        entregaPhAgua: _entregaPhAgua,
        entregaPhSMP: _entregaPhSMP,
        entregaH: _entregaH,
        entregaHidrogenioPuro: _entregaHidrogenioPuro,
        entregaCtcEfetiva: _entregaCtcEfetiva,
        entregaMicroDtpa: _entregaMicroDtpa,
        entregaMicroMehlich: _entregaMicroMehlich,
        entregaTextura: _entregaTextura,
        entregaKNH4Cl: _entregaKNH4Cl,
        entregaCaMaisMg: _entregaCaMaisMg,
        entregaMo: _entregaMo,
        entregaCo: _entregaCo,
        entregaPTotal: _entregaPTotal,
        entregaClassificacaoTextura: _entregaClassificacaoTextura,
        entregaTipoSoloMapa: _entregaTipoSoloMapa,
        separaSolicitanteProprietario: _separaSolicitanteProprietario,
        entregaAreiasDetalhadas: _entregaAreiasDetalhadas,
        entregaCascalho: _entregaCascalho,
        micronutrientesPorAmostra: _micronutrientesPorAmostra,
        identificacaoComposta: _identificacaoComposta,
        umAmostraPorLaudo: _umAmostraPorLaudo,
        ativo: _ativo,
        isDefault: false,
        createdAt: widget.template?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(labTemplatesProvider.notifier).save(novo);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }
}

// ── Widgets auxiliares ─────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String titulo;
  const _SectionHeader({required this.titulo});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 0),
        child: Text(
          titulo,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: Color(0xFF86868B),
          ),
        ),
      );
}

class _AvisoReadOnly extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3CD),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFFFE082)),
        ),
        child: const Row(
          children: [
            Icon(CupertinoIcons.lock, color: Color(0xFF856404), size: 15),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Template padrão — apenas visualização. '
                'Crie um template personalizado para customizar.',
                style: TextStyle(fontSize: 12, color: Color(0xFF856404)),
              ),
            ),
          ],
        ),
      );
}

class _DropdownRow<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  const _DropdownRow({
    required this.label,
    required this.value,
    required this.items,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1D1D1F),
                ),
              ),
            ),
            DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              underline: const SizedBox(),
              style: TextStyle(
                fontSize: 14,
                color: onChanged == null
                    ? const Color(0xFF86868B)
                    : const Color(0xFF007AFF),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    this.subtitle,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1D1D1F),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF86868B),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            CupertinoSwitch(
              value: value,
              onChanged: enabled ? onChanged : null,
              activeTrackColor: const Color(0xFF007AFF),
            ),
          ],
        ),
      );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Divider(
        height: 1,
        indent: 16,
        endIndent: 16,
        color: Color(0xFFE5E5EA),
      );
}
