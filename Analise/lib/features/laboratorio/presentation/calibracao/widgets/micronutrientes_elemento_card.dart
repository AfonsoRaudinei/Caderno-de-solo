import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';
import 'package:soloforte/core/widgets/app_dropdown.dart';
import 'package:soloforte/core/widgets/app_input.dart';
import 'package:soloforte/domain/entities/micronutrientes_calibracao.dart';

class MicronutrientesElementoCard extends StatelessWidget {
  const MicronutrientesElementoCard({
    super.key,
    required this.draftKey,
    required this.simbolo,
    required this.elemento,
    required this.onChanged,
  });

  final String draftKey;
  final String simbolo;
  final Map<String, dynamic> elemento;
  final ValueChanged<Map<String, dynamic>> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final nc = _num(elemento[legacyNcKey]);
    final ncUnidade = _string(elemento['ncUnidade'], fallback: 'mg/dm³');
    final extracao = _num(elemento['extracaoPlanta']);
    final exportacao = _num(elemento['exportacaoGraos']);
    final tipoAbsorcao =
        _string(elemento['referenciaAbsorcaoTipo'], fallback: 'Autores');
    final vias = _normalizarViasElemento(elemento);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: palette.card,
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
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
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  rotuloElementoMicro(simbolo),
                  style: AppTextStyles.label,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _ResumoParametro(
            label: 'Nível crítico',
            valor: '${_fmt(nc)} $ncUnidade',
          ),
          const SizedBox(height: 4),
          _ResumoParametro(
            label: 'Extração',
            valor: '${_fmt(extracao)} g/t',
          ),
          const SizedBox(height: 4),
          _ResumoParametro(
            label: 'Exportação',
            valor: '${_fmt(exportacao)} g/t',
          ),
          const SizedBox(height: 12),
          _buildSecaoTitulo('NÍVEL CRÍTICO', palette),
          const SizedBox(height: 6),
          _buildNumericInput(
            keyValue: '$draftKey-$simbolo-nc',
            label: 'Nível crítico',
            value: nc,
            onChanged: (value) => _patch({
              legacyNcKey: value,
            }),
          ),
          const SizedBox(height: 8),
          AppDropdown<String>(
            label: 'Unidade',
            value: _safeValue(kUnidadesNivelCritico, ncUnidade),
            items: kUnidadesNivelCritico
                .map((item) => AppDropdownItem(value: item, label: item))
                .toList(),
            onChanged: (value) => _patch({'ncUnidade': value ?? 'mg/dm³'}),
          ),
          const SizedBox(height: 8),
          AppDropdown<String>(
            label: 'Referência do nível crítico',
            value: _safeValue(
              kReferenciasNivelCritico,
              _string(elemento['referenciaNc']),
            ),
            items: kReferenciasNivelCritico
                .map((item) => AppDropdownItem(value: item, label: item))
                .toList(),
            onChanged: (value) => _patch({
              'referenciaNc': value ?? kReferenciasNivelCritico.first,
              legacyReferenciaKey: value ?? kReferenciasNivelCritico.first,
            }),
          ),
          const SizedBox(height: 14),
          _buildSecaoTitulo('EXTRAÇÃO / EXPORTAÇÃO', palette),
          const SizedBox(height: 6),
          _buildNumericPair(
            left: _buildNumericInput(
              keyValue: '$draftKey-$simbolo-extracao',
              label: 'Extração da planta (g/t)',
              value: extracao,
              onChanged: (value) => _patch({'extracaoPlanta': value}),
            ),
            right: _buildNumericInput(
              keyValue: '$draftKey-$simbolo-exportacao',
              label: 'Exportação dos grãos (g/t)',
              value: exportacao,
              onChanged: (value) => _patch({'exportacaoGraos': value}),
            ),
          ),
          const SizedBox(height: 8),
          AppDropdown<String>(
            label: 'Tipo — referência extração/exportação',
            value: tipoAbsorcao,
            items: kTiposReferenciaAbsorcao
                .map((item) => AppDropdownItem(value: item, label: item))
                .toList(),
            onChanged: (value) => _patch({
              'referenciaAbsorcaoTipo': value ?? 'Autores',
              'tipoFonte': value ?? 'Autores',
            }),
          ),
          const SizedBox(height: 8),
          AppInput(
            key: ValueKey('$draftKey-$simbolo-ref-absorcao'),
            label: 'Referência extração/exportação',
            initialValue: _string(elemento['referenciaAbsorcaoNome']),
            onChanged: (value) => _patch({
              'referenciaAbsorcaoNome': value,
              'autor': value,
            }),
          ),
          const SizedBox(height: 14),
          _buildSecaoTitulo('FONTE E LIMITES', palette),
          const SizedBox(height: 6),
          _buildNumericPair(
            left: _buildNumericInput(
              keyValue: '$draftKey-$simbolo-concentracao',
              label: 'Concentração da fonte',
              value: _num(elemento['concentracaoFonte']),
              onChanged: (value) => _patch({
                'concentracaoFonte': value,
                'teorFonteSolo': value,
                'teorFonteFoliar': value,
              }),
            ),
            right: AppDropdown<String>(
              label: 'Unidade concentração',
              value: _safeValue(
                kUnidadesConcentracao,
                _string(elemento['concentracaoUnidade'], fallback: '%'),
              ),
              items: kUnidadesConcentracao
                  .map((item) => AppDropdownItem(value: item, label: item))
                  .toList(),
              onChanged: (value) =>
                  _patch({'concentracaoUnidade': value ?? '%'}),
            ),
          ),
          const SizedBox(height: 8),
          _buildNumericPair(
            left: _buildNumericInput(
              keyValue: '$draftKey-$simbolo-dose-min',
              label: 'Dose mínima',
              value: _num(elemento['doseMinima']),
              onChanged: (value) => _patch({'doseMinima': value}),
            ),
            right: _buildNumericInput(
              keyValue: '$draftKey-$simbolo-dose-max',
              label: 'Dose máxima',
              value: _num(elemento['doseMaxima']),
              onChanged: (value) => _patch({'doseMaxima': value}),
            ),
          ),
          const SizedBox(height: 8),
          _buildNumericInput(
            keyValue: '$draftKey-$simbolo-toxicidade',
            label: 'Limite de toxicidade',
            value: _num(elemento['limiteToxicidade']),
            onChanged: (value) => _patch({'limiteToxicidade': value}),
          ),
          const SizedBox(height: 14),
          _buildSecaoTitulo('VIAS PERMITIDAS', palette),
          const SizedBox(height: 6),
          _ViaToggleGroup(
            selecionadas: vias,
            opcoes: kViasAplicacaoMicros,
            onChanged: (value) => _patch({
              'viasAplicacao': value,
              'viaAplicacao': _viaLegada(value),
            }),
          ),
        ],
      ),
    );
  }

  void _patch(Map<String, dynamic> patch) {
    final atualizado = normalizarElementoMicros(
      simbolo,
      {...elemento, ...patch},
    );
    onChanged(atualizado);
  }

  Widget _buildSecaoTitulo(String titulo, AppThemePalette palette) {
    return Text(
      titulo,
      style: AppTextStyles.caption.copyWith(
        color: palette.textSecondary,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildNumericInput({
    required String keyValue,
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return AppInput(
      key: ValueKey(keyValue),
      label: label,
      initialValue: _fmt(value),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      maxLength: 8,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
        LengthLimitingTextInputFormatter(8),
      ],
      onChanged: (text) => onChanged(_parseDouble(text)),
    );
  }

  Widget _buildNumericPair({
    required Widget left,
    required Widget right,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 8),
        Expanded(child: right),
      ],
    );
  }

  List<String> _normalizarViasElemento(Map<String, dynamic> data) {
    final raw = data['viasAplicacao'] ?? data['viaAplicacao'];
    if (raw is String && raw == 'Ambas') return ['Solo', 'Foliar'];
    if (raw is String && raw == 'Solo (correção)') return ['Solo'];
    if (raw is List) {
      return raw
          .map((item) => item.toString())
          .where((item) => kViasAplicacaoMicros.contains(item))
          .toList();
    }
    if (raw is String && kViasAplicacaoMicros.contains(raw)) return [raw];
    return ['Solo'];
  }

  String _viaLegada(List<String> vias) {
    if (vias.contains('Solo') && vias.contains('Foliar')) return 'Ambas';
    if (vias.contains('Solo')) return 'Solo (correção)';
    if (vias.contains('Foliar')) return 'Foliar';
    if (vias.contains('TS')) return 'TS';
    return 'Solo (correção)';
  }

  T? _safeValue<T>(List<T> options, T current) {
    if (options.contains(current)) return current;
    return options.isNotEmpty ? options.first : null;
  }

  String _fmt(double value, {int decimals = 2}) {
    final fixed = value.toStringAsFixed(decimals);
    final normalized =
        fixed.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    return normalized.replaceAll('.', ',');
  }

  double _parseDouble(String value) {
    return double.tryParse(value.replaceAll(',', '.').trim()) ?? 0;
  }

  double _num(dynamic value, {double fallback = 0}) {
    if (value is num) return value.toDouble();
    if (value is String) return _parseDouble(value);
    return fallback;
  }

  String _string(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  Color _microColor(String simbolo) {
    const colors = {
      'B': Color(0xFFFF9500),
      'Cu': Color(0xFF8E6B4D),
      'Fe': Color(0xFF5AC8FA),
      'Mn': Color(0xFFAF52DE),
      'Zn': Color(0xFF007AFF),
      'Mo': Color(0xFF34C759),
      'Co': Color(0xFFFF3B30),
      'Ni': Color(0xFF5856D6),
      'Se': Color(0xFF30B0C7),
    };
    return colors[simbolo] ?? AppColors.primary;
  }
}

class _ResumoParametro extends StatelessWidget {
  const _ResumoParametro({
    required this.label,
    required this.valor,
  });

  final String label;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Row(
      children: [
        Text(
          '$label: ',
          style: AppTextStyles.caption.copyWith(color: palette.textSecondary),
        ),
        Expanded(
          child: Text(
            valor,
            style: AppTextStyles.caption.copyWith(
              color: palette.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ViaToggleGroup extends StatelessWidget {
  const _ViaToggleGroup({
    required this.selecionadas,
    required this.opcoes,
    required this.onChanged,
  });

  final List<String> selecionadas;
  final List<String> opcoes;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < opcoes.length; i++) ...[
          Expanded(child: _buildToggle(context, opcoes[i])),
          if (i < opcoes.length - 1) const SizedBox(width: 6),
        ],
      ],
    );
  }

  Widget _buildToggle(BuildContext context, String opcao) {
    final palette = context.appPalette;
    final selected = selecionadas.contains(opcao);

    return GestureDetector(
      onTap: () {
        final nova = List<String>.from(selecionadas);
        if (nova.contains(opcao)) {
          nova.remove(opcao);
        } else {
          nova.add(opcao);
        }
        if (nova.isEmpty) return;
        onChanged(nova);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 36,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFAF52DE).withValues(alpha: 0.10)
              : palette.surfaceAlt,
          border: Border.all(
            color: selected ? const Color(0xFFAF52DE) : palette.borderStrong,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          opcao,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? const Color(0xFFAF52DE) : palette.textSecondary,
          ),
        ),
      ),
    );
  }
}
