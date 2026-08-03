import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/widgets/app_dropdown.dart';
import 'package:soloforte/core/widgets/app_input.dart';
import 'package:soloforte/core/widgets/nutriente_card.dart';
import 'package:soloforte/data/culturas_data.dart';
import 'package:soloforte/domain/models/micronutrientes_calibracao.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/calibracao_controller.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/widgets/calibracao_status_badge.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/widgets/calibracao_subsection_title.dart';

/// Card Lab > Calibração > Micronutrientes.
///
/// Evolui o fluxo existente: grupos independentes com um ou mais elementos,
/// campos por via, NC visível por elemento e referências separadas.
class MicronutrientesCardWidget extends ConsumerStatefulWidget {
  const MicronutrientesCardWidget({
    super.key,
    required this.draftKey,
    required this.initialData,
    required this.isExpanded,
    required this.onToggle,
    this.onChanged,
  });

  final String draftKey;
  final Map<String, dynamic> initialData;
  final bool isExpanded;
  final VoidCallback onToggle;
  final ValueChanged<Map<String, dynamic>>? onChanged;

  @override
  ConsumerState<MicronutrientesCardWidget> createState() =>
      _MicronutrientesCardWidgetState();
}

class _MicronutrientesCardWidgetState
    extends ConsumerState<MicronutrientesCardWidget> {
  late Map<String, dynamic> _data;
  final Map<String, bool> _expandedElementos = {};
  Map<String, String> _fieldErrors = {};

  @override
  void initState() {
    super.initState();
    _data = migrateMicrosParametros(widget.initialData);
  }

  @override
  void didUpdateWidget(covariant MicronutrientesCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!mapEquals(oldWidget.initialData, widget.initialData) ||
        oldWidget.draftKey != widget.draftKey) {
      _data = migrateMicrosParametros(widget.initialData);
      _fieldErrors = {};
    }
  }

  Map<String, dynamic> get _elementos =>
      Map<String, dynamic>.from((_data['elementos'] as Map?) ?? const {});

  List<Map<String, dynamic>> get _grupos => gruposFromMicros(_data);

  void _emit(Map<String, dynamic> next) {
    final migrated = migrateMicrosParametros(next);
    final validation = validateMicrosParametros(migrated);
    setState(() {
      _data = migrated;
      _fieldErrors = validation.fieldErrors;
    });
    widget.onChanged?.call(migrated);
  }

  void _updateGrupo(int index, Map<String, dynamic> patch) {
    final grupos = [..._grupos];
    if (index < 0 || index >= grupos.length) return;
    grupos[index] = migrateGrupoAplicacao(
      {...grupos[index], ...patch},
      indice: index + 1,
    );
    _emit({..._data, 'grupos': grupos});
  }

  void _updateElemento(String simbolo, Map<String, dynamic> patch) {
    final elementos = {..._elementos};
    final atual = Map<String, dynamic>.from(
      (elementos[simbolo] as Map?) ?? defaultElementoMicro(simbolo),
    );
    elementos[simbolo] = {...atual, ...patch, 'simbolo': simbolo};
    _emit({..._data, 'elementos': elementos});
  }

  @override
  Widget build(BuildContext context) {
    return NutrienteCard(
      nutriente: 'Micronutrientes',
      icon: Icons.biotech_outlined,
      cor: AppColors.micronut,
      isExpanded: widget.isExpanded,
      onToggle: widget.onToggle,
      children: [
        _buildAbsorcaoGlobal(),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            key: const Key('btn_criar_grupo_micros'),
            onPressed: _criarGrupo,
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Criar Grupo de Aplicação'),
          ),
        ),
        const SizedBox(height: 8),
        const CalibracaoSubsectionTitle('Grupos de Aplicação'),
        const SizedBox(height: 10),
        if (_grupos.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: CalibracaoStatusBadge(
              icon: Icons.info_outline,
              color: AppColors.textSecond,
              label: 'Nenhum grupo de aplicação criado ainda.',
            ),
          ),
        ..._grupos.asMap().entries.map((entry) {
          return _buildGrupoCard(index: entry.key, grupo: entry.value);
        }),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),
        const CalibracaoSubsectionTitle('Nutrientes individuais'),
        const SizedBox(height: 6),
        Text(
          'Elementos sem grupo. Os selecionados em grupos aparecem nos subcards do grupo.',
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecond),
        ),
        const SizedBox(height: 10),
        ..._buildElementosIndividuais(),
      ],
    );
  }

  Widget _buildAbsorcaoGlobal() {
    const tipos = ['Autores', 'Guidorizzi', 'Cultivar'];
    final tipo = tipos.contains(_data['microTipoFonte']?.toString())
        ? _data['microTipoFonte'].toString()
        : 'Autores';
    final fontes = _fontesParaTipo(tipo);
    final fonteRaw = _data['microFonteNome']?.toString();
    final fonte = fontes.contains(fonteRaw)
        ? fonteRaw!
        : (fontes.isNotEmpty ? fontes.first : '');
    final labelFonte = tipo == 'Guidorizzi'
        ? 'Tecnologia'
        : tipo == 'Cultivar'
            ? 'Cultivar'
            : 'Autor';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'REFERÊNCIA DE ABSORÇÃO (GLOBAL)',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecond,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        AppDropdown<String>(
          label: 'Tipo de Fonte',
          value: tipo,
          items: tipos.map((t) => AppDropdownItem(value: t, label: t)).toList(),
          onChanged: (v) {
            if (v == null) return;
            final novas = _fontesParaTipo(v);
            _emit({
              ..._data,
              'microTipoFonte': v,
              'microFonteNome': novas.isNotEmpty ? novas.first : '',
            });
          },
        ),
        const SizedBox(height: 8),
        AppDropdown<String>(
          label: labelFonte,
          value: fonte,
          items: fontes.isNotEmpty
              ? fontes.map((t) => AppDropdownItem(value: t, label: t)).toList()
              : const [AppDropdownItem(value: '', label: '')],
          onChanged: (v) {
            if (v == null || v.isEmpty) return;
            _emit({..._data, 'microFonteNome': v});
          },
        ),
      ],
    );
  }

  Widget _buildGrupoCard({
    required int index,
    required Map<String, dynamic> grupo,
  }) {
    final id = grupo['id']?.toString() ?? 'grupo-$index';
    final nome = grupo['nome']?.toString() ?? 'Grupo ${index + 1}';
    final via = grupo['via']?.toString() ?? 'Foliar';
    final elementosGrupo = List<String>.from(
      (grupo['elementos'] as List?)?.map((e) => e.toString()) ?? const [],
    );
    final tiposFonte = ['Autores', 'Guidorizzi', 'Cultivar'];
    final tipoAbs =
        tiposFonte.contains(grupo['microGrupoTipoFonte']?.toString())
            ? grupo['microGrupoTipoFonte'].toString()
            : 'Autores';
    final fontesAbs = _fontesParaTipo(tipoAbs);
    final fonteAbsRaw = grupo['microGrupoFonteNome']?.toString();
    final fonteAbs = fontesAbs.contains(fonteAbsRaw)
        ? fonteAbsRaw
        : (fontesAbs.isNotEmpty ? fontesAbs.first : null);
    final labelAbs = tipoAbs == 'Guidorizzi'
        ? 'Tecnologia'
        : tipoAbs == 'Cultivar'
            ? 'Cultivar'
            : 'Autor';
    final referenciaNc = grupo['referenciaNcNome']?.toString() ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        key: Key('grupo_micros_$id'),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.bgSecondary,
          border: Border.all(color: AppColors.borderSoft),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: AppInput(
                    key: ValueKey('${widget.draftKey}-grupo-nome-$index'),
                    label: 'Nome do grupo',
                    initialValue: nome,
                    errorText: _fieldErrors['grupo:$id:nome'],
                    onChanged: (value) => _updateGrupo(index, {'nome': value}),
                  ),
                ),
                IconButton(
                  tooltip: 'Duplicar grupo',
                  key: Key('btn_duplicar_grupo_$id'),
                  icon: const Icon(Icons.copy_outlined),
                  onPressed: () => _duplicarGrupo(index),
                ),
                IconButton(
                  tooltip: 'Excluir grupo',
                  key: Key('btn_excluir_grupo_$id'),
                  icon:
                      const Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: () {
                    final atualizados = [..._grupos]..removeAt(index);
                    _emit({..._data, 'grupos': atualizados});
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            AppDropdown<String>(
              label: 'Extrator',
              value: _safe(
                const [
                  'DTPA-TEA',
                  'Água quente',
                  'Resina',
                  'Oxalato de amônio',
                ],
                grupo['extrator']?.toString() ?? 'DTPA-TEA',
              ),
              items: const [
                AppDropdownItem(value: 'DTPA-TEA', label: 'DTPA-TEA'),
                AppDropdownItem(value: 'Água quente', label: 'Água quente'),
                AppDropdownItem(value: 'Resina', label: 'Resina'),
                AppDropdownItem(
                    value: 'Oxalato de amônio', label: 'Oxalato de amônio'),
              ],
              onChanged: (value) =>
                  _updateGrupo(index, {'extrator': value ?? 'DTPA-TEA'}),
            ),
            const SizedBox(height: 8),
            AppDropdown<String>(
              label: 'Via de aplicação do grupo',
              value: _safe(kViasGrupoMicros, via),
              items: kViasGrupoMicros
                  .map((item) => AppDropdownItem(value: item, label: item))
                  .toList(),
              onChanged: (value) =>
                  _updateGrupo(index, {'via': value ?? 'Foliar'}),
            ),
            if (_fieldErrors['grupo:$id:via'] != null)
              _ErrorText(_fieldErrors['grupo:$id:via']!),
            const SizedBox(height: 8),
            ..._buildCamposPorVia(index: index, grupo: grupo, via: via),
            const SizedBox(height: 8),
            AppDropdown<String>(
              label: 'Referência do nível crítico (solo)',
              value: kReferenciasNcMicros.contains(referenciaNc)
                  ? referenciaNc
                  : null,
              items: kReferenciasNcMicros
                  .map((item) => AppDropdownItem(value: item, label: item))
                  .toList(),
              onChanged: (value) {
                final referencia = value ?? '';
                _updateGrupo(index, {
                  'referenciaNcNome': referencia,
                  'referenciaNome': referencia,
                });
                ref
                    .read(calibracaoControllerProvider.notifier)
                    .propagarNcParaGrupo(
                      grupoIndex: index,
                      referenciaNome: referencia,
                    );
                if (referencia.isNotEmpty && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('NC atualizado com base em $referencia'),
                      backgroundColor: const Color(0xFF1D1D1F),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      duration: const Duration(milliseconds: 2500),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 8),
            AppDropdown<String>(
              label: 'Tipo — absorção / extração / exportação',
              value: tipoAbs,
              items: tiposFonte
                  .map((item) => AppDropdownItem(value: item, label: item))
                  .toList(),
              onChanged: (value) {
                final novoTipo = value ?? tiposFonte.first;
                _updateGrupo(index, {
                  'microGrupoTipoFonte': novoTipo,
                  'microGrupoFonteNome': null,
                });
              },
            ),
            const SizedBox(height: 8),
            AppDropdown<String>(
              label: labelAbs,
              value: fonteAbs,
              items: fontesAbs
                  .map((item) => AppDropdownItem(value: item, label: item))
                  .toList(),
              onChanged: (value) =>
                  _updateGrupo(index, {'microGrupoFonteNome': value}),
            ),
            const SizedBox(height: 12),
            Text('Elementos deste grupo', style: AppTextStyles.label),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: kElementosMicros.map((simbolo) {
                final selected = elementosGrupo.contains(simbolo);
                return FilterChip(
                  key: Key('chip_grupo_${id}_$simbolo'),
                  label: Text(simbolo),
                  selected: selected,
                  selectedColor: AppColors.micronut.withValues(alpha: 0.15),
                  checkmarkColor: AppColors.micronut,
                  backgroundColor: const Color(0xFFF2F2F7),
                  labelStyle: TextStyle(
                    color:
                        selected ? AppColors.micronut : const Color(0xFF1D1D1F),
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  side: BorderSide(
                    color:
                        selected ? AppColors.micronut : const Color(0xFFD1D1D6),
                  ),
                  onSelected: (value) {
                    final atual = [...elementosGrupo];
                    if (value) {
                      if (!atual.contains(simbolo)) atual.add(simbolo);
                    } else {
                      atual.remove(simbolo);
                    }
                    _updateGrupo(index, {'elementos': atual});
                  },
                );
              }).toList(),
            ),
            if (_fieldErrors['grupo:$id:elementos'] != null)
              _ErrorText(_fieldErrors['grupo:$id:elementos']!),
            const SizedBox(height: 12),
            if (elementosGrupo.isEmpty)
              const CalibracaoStatusBadge(
                icon: Icons.info_outline,
                color: AppColors.textSecond,
                label: 'Selecione elementos para exibir os subcards.',
              )
            else
              ...elementosGrupo.map((simbolo) {
                return _buildElementoSubcard(
                  simbolo: simbolo,
                  grupoId: id,
                  showInsideGroup: true,
                );
              }),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCamposPorVia({
    required int index,
    required Map<String, dynamic> grupo,
    required String via,
  }) {
    switch (via) {
      case 'Solo':
        return [
          AppInput(
            key: ValueKey('${widget.draftKey}-grupo-fonte-solo-$index'),
            label: 'Fonte utilizada (solo)',
            initialValue: fonteDoGrupo(grupo),
            onChanged: (value) => _updateGrupo(index, {
              'fonteSolo': value,
              'produto': value,
            }),
          ),
          const SizedBox(height: 8),
          _numeric(
            keyValue: '${widget.draftKey}-grupo-ef-solo-$index',
            label: 'Eficiência da aplicação no solo (%)',
            value: eficienciaDoGrupo(grupo),
            errorText: _fieldErrors['grupo:${grupo['id']}:eficienciaSolo'],
            onChanged: (value) => _updateGrupo(index, {
              'eficienciaSolo': value,
              'eficiencia': value,
            }),
          ),
        ];
      case 'TS':
        return [
          AppInput(
            key: ValueKey('${widget.draftKey}-grupo-fonte-ts-$index'),
            label: 'Fonte utilizada (tratamento de sementes)',
            initialValue: fonteDoGrupo(grupo),
            onChanged: (value) => _updateGrupo(index, {
              'fonteTs': value,
              'produto': value,
            }),
          ),
          const SizedBox(height: 8),
          _numeric(
            keyValue: '${widget.draftKey}-grupo-ef-ts-$index',
            label: 'Eficiência do tratamento de sementes (%)',
            value: eficienciaDoGrupo(grupo),
            errorText: _fieldErrors['grupo:${grupo['id']}:eficienciaTs'],
            onChanged: (value) => _updateGrupo(index, {
              'eficienciaTs': value,
              'eficiencia': value,
            }),
          ),
        ];
      case 'Foliar':
      default:
        return [
          AppInput(
            key: ValueKey('${widget.draftKey}-grupo-fonte-foliar-$index'),
            label: 'Fonte utilizada (foliar)',
            initialValue: fonteDoGrupo(grupo),
            onChanged: (value) => _updateGrupo(index, {
              'fonteFoliar': value,
              'produto': value,
            }),
          ),
          const SizedBox(height: 8),
          _numeric(
            keyValue: '${widget.draftKey}-grupo-ef-foliar-$index',
            label: 'Eficiência da aplicação foliar (%)',
            value: eficienciaDoGrupo(grupo),
            errorText: _fieldErrors['grupo:${grupo['id']}:eficienciaFoliar'],
            onChanged: (value) => _updateGrupo(index, {
              'eficienciaFoliar': value,
              'eficiencia': value,
            }),
          ),
        ];
    }
  }

  List<Widget> _buildElementosIndividuais() {
    final emGrupos = elementosEmGrupos(_grupos);
    final livres = kElementosMicros
        .where((simbolo) => !emGrupos.contains(simbolo))
        .toList(growable: false);
    if (livres.isEmpty) {
      return [
        const CalibracaoStatusBadge(
          icon: Icons.check_circle_outline,
          color: AppColors.micronut,
          label: 'Todos os elementos estão em grupos.',
        ),
      ];
    }
    return livres
        .map((simbolo) => _buildElementoSubcard(
              simbolo: simbolo,
              grupoId: null,
              showInsideGroup: false,
            ))
        .toList();
  }

  Widget _buildElementoSubcard({
    required String simbolo,
    required String? grupoId,
    required bool showInsideGroup,
  }) {
    final elemento = Map<String, dynamic>.from(
      (_elementos[simbolo] as Map?) ?? defaultElementoMicro(simbolo),
    );
    final expandKey = grupoId == null ? simbolo : '$grupoId-$simbolo';
    final aberto = _expandedElementos[expandKey] ?? showInsideGroup;
    final ncVisivel = formatNivelCriticoVisivel(elemento);
    final nome = nomeElementoMicro(simbolo);
    final refNc =
        (elemento['referenciaNc'] ?? elemento['referencia'] ?? '').toString();
    final extracao = _num(elemento['extracaoGt']);
    final exportacao = _num(elemento['exportacaoGt']);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        key: Key('subcard_micro_$expandKey'),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          border: Border.all(color: AppColors.borderSoft),
        ),
        child: Column(
          children: [
            ListTile(
              dense: true,
              leading: CircleAvatar(
                radius: 14,
                backgroundColor: _microColor(simbolo).withValues(alpha: 0.12),
                child: Text(
                  simbolo,
                  style: TextStyle(
                    color: _microColor(simbolo),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              title: Text('$nome — $simbolo', style: AppTextStyles.label),
              subtitle: Text(
                'Nível crítico: $ncVisivel',
                key: Key('nc_visivel_$expandKey'),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.micronut,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: Icon(aberto ? Icons.expand_less : Icons.expand_more),
              onTap: () => setState(
                () => _expandedElementos[expandKey] = !aberto,
              ),
            ),
            // NC sempre visível (mesmo colapsado) — reforço visual
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Extração: ${_fmt(extracao)} g/t · Exportação: ${_fmt(exportacao)} g/t'
                  '${refNc.isEmpty ? '' : '\nReferência do NC: $refNc'}',
                  style: AppTextStyles.caption,
                ),
              ),
            ),
            if (aberto)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  children: [
                    AppDropdown<String>(
                      label: 'Referência do nível crítico',
                      value:
                          kReferenciasNcMicros.contains(refNc) ? refNc : null,
                      items: kReferenciasNcMicros
                          .map((item) =>
                              AppDropdownItem(value: item, label: item))
                          .toList(),
                      onChanged: (value) {
                        final ref = value ?? '';
                        _updateElemento(simbolo, {
                          'referenciaNc': ref,
                          'referencia': ref,
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    _numeric(
                      keyValue: '${widget.draftKey}-$expandKey-nc',
                      label: 'Nível crítico (mg/dm³)',
                      value: _num(elemento['ncSolo']),
                      errorText: _fieldErrors['elemento:$simbolo:ncSolo'],
                      onChanged: (value) =>
                          _updateElemento(simbolo, {'ncSolo': value}),
                    ),
                    const SizedBox(height: 8),
                    _numeric(
                      keyValue: '${widget.draftKey}-$expandKey-extracao',
                      label: 'Extração planta inteira (g/t)',
                      value: extracao,
                      errorText: _fieldErrors['elemento:$simbolo:extracaoGt'],
                      onChanged: (value) =>
                          _updateElemento(simbolo, {'extracaoGt': value}),
                    ),
                    const SizedBox(height: 8),
                    _numeric(
                      keyValue: '${widget.draftKey}-$expandKey-exportacao',
                      label: 'Exportação pelos grãos (g/t)',
                      value: exportacao,
                      errorText: _fieldErrors['elemento:$simbolo:exportacaoGt'],
                      onChanged: (value) =>
                          _updateElemento(simbolo, {'exportacaoGt': value}),
                    ),
                    const SizedBox(height: 8),
                    AppInput(
                      key: ValueKey('${widget.draftKey}-$expandKey-ref-ee'),
                      label: 'Referência de extração/exportação',
                      initialValue:
                          (elemento['referenciaExtracaoExportacao'] ?? '')
                              .toString(),
                      onChanged: (value) => _updateElemento(
                        simbolo,
                        {'referenciaExtracaoExportacao': value},
                      ),
                    ),
                    const SizedBox(height: 8),
                    _numeric(
                      keyValue: '${widget.draftKey}-$expandKey-conc',
                      label: 'Concentração na fonte',
                      value: _num(elemento['concentracao']),
                      onChanged: (value) =>
                          _updateElemento(simbolo, {'concentracao': value}),
                    ),
                    const SizedBox(height: 8),
                    AppDropdown<String>(
                      label: 'Unidade da concentração',
                      value: _safe(
                        kUnidadesConcentracaoMicro,
                        (elemento['unidadeConcentracao'] ?? '%').toString(),
                      ),
                      items: kUnidadesConcentracaoMicro
                          .map((item) =>
                              AppDropdownItem(value: item, label: item))
                          .toList(),
                      onChanged: (value) => _updateElemento(
                        simbolo,
                        {'unidadeConcentracao': value ?? '%'},
                      ),
                    ),
                    const SizedBox(height: 8),
                    _numeric(
                      keyValue: '${widget.draftKey}-$expandKey-dose-min',
                      label: 'Dose mínima permitida',
                      value: _num(elemento['doseMin']),
                      errorText: _fieldErrors['elemento:$simbolo:doseMin'],
                      onChanged: (value) =>
                          _updateElemento(simbolo, {'doseMin': value}),
                    ),
                    const SizedBox(height: 8),
                    _numeric(
                      keyValue: '${widget.draftKey}-$expandKey-dose-max',
                      label: 'Dose máxima permitida',
                      value: _num(elemento['doseMax']),
                      onChanged: (value) =>
                          _updateElemento(simbolo, {'doseMax': value}),
                    ),
                    const SizedBox(height: 8),
                    AppInput(
                      key: ValueKey(
                          '${widget.draftKey}-$expandKey-unidade-dose'),
                      label: 'Unidade da dose',
                      initialValue:
                          (elemento['unidadeDose'] ?? 'g/ha').toString(),
                      onChanged: (value) =>
                          _updateElemento(simbolo, {'unidadeDose': value}),
                    ),
                    const SizedBox(height: 8),
                    _numeric(
                      keyValue: '${widget.draftKey}-$expandKey-tox',
                      label: 'Limite de segurança / toxicidade (opcional)',
                      value: _num(elemento['limiteToxicidade']),
                      onChanged: (value) =>
                          _updateElemento(simbolo, {'limiteToxicidade': value}),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child:
                          Text('Vias permitidas', style: AppTextStyles.label),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: kViasGrupoMicros.map((viaItem) {
                        final vias = List<String>.from(
                          (elemento['viasPermitidas'] as List?)
                                  ?.map((e) => e.toString()) ??
                              kViasGrupoMicros,
                        );
                        final selected = vias.contains(viaItem);
                        return FilterChip(
                          label: Text(viaItem),
                          selected: selected,
                          selectedColor:
                              AppColors.micronut.withValues(alpha: 0.15),
                          checkmarkColor: AppColors.micronut,
                          onSelected: (value) {
                            final next = [...vias];
                            if (value) {
                              if (!next.contains(viaItem)) next.add(viaItem);
                            } else {
                              next.remove(viaItem);
                            }
                            _updateElemento(simbolo, {'viasPermitidas': next});
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _criarGrupo() {
    final novo = novoGrupoAplicacao(
      id: 'grupo-${DateTime.now().microsecondsSinceEpoch}',
      indice: _grupos.length + 1,
    );
    _emit({
      ..._data,
      'grupos': [..._grupos, novo],
    });
  }

  void _duplicarGrupo(int index) {
    if (index < 0 || index >= _grupos.length) return;
    final copia = duplicarGrupoAplicacao(
      _grupos[index],
      novoId: 'grupo-${DateTime.now().microsecondsSinceEpoch}',
    );
    final atualizados = [..._grupos]..insert(index + 1, copia);
    _emit({..._data, 'grupos': atualizados});
  }

  Widget _numeric({
    required String keyValue,
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
    String? errorText,
  }) {
    return AppInput(
      key: ValueKey(keyValue),
      label: label,
      initialValue: _fmt(value),
      errorText: errorText,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      maxLength: 7,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
        LengthLimitingTextInputFormatter(7),
      ],
      onChanged: (text) => onChanged(_parseDouble(text)),
    );
  }

  List<String> _fontesParaTipo(String tipo) {
    if (tipo == 'Guidorizzi') return kTecnologias.keys.toList();
    if (tipo == 'Cultivar') return kCultivares.keys.toList();
    return kAutores.keys.toList();
  }

  T? _safe<T>(List<T> options, T current) {
    if (options.contains(current)) return current;
    return options.isNotEmpty ? options.first : null;
  }

  double _num(dynamic value, [double fallback = 0]) {
    if (value is num) return value.toDouble();
    if (value is String) return _parseDouble(value);
    return fallback;
  }

  double _parseDouble(String value) {
    return double.tryParse(value.replaceAll(',', '.').trim()) ?? 0;
  }

  String _fmt(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2).replaceAll('.', ',');
  }

  Color _microColor(String simbolo) {
    switch (simbolo) {
      case 'B':
        return const Color(0xFFFF9500);
      case 'Cu':
        return const Color(0xFFB45309);
      case 'Fe':
        return const Color(0xFF8E8E93);
      case 'Mn':
        return const Color(0xFFAF52DE);
      case 'Zn':
        return const Color(0xFF34C759);
      case 'Mo':
        return const Color(0xFF007AFF);
      case 'Co':
        return const Color(0xFF5856D6);
      case 'Ni':
        return const Color(0xFF5856D6);
      case 'Se':
        return const Color(0xFFFF2D55);
      default:
        return AppColors.micronut;
    }
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: AppTextStyles.caption.copyWith(color: AppColors.error),
        ),
      ),
    );
  }
}
