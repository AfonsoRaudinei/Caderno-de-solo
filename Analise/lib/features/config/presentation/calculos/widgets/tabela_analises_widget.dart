import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/features/config/presentation/calculos/analise_normalizada.dart';

typedef _ExtratorValor = double? Function(AnaliseNormalizada analise);
typedef _ExtratorTexto = String? Function(AnaliseNormalizada analise);

class _LinhaTabela {
  const _LinhaTabela.numero(this.label, this.extrator) : extratorTexto = null;
  const _LinhaTabela.texto(this.label, this.extratorTexto) : extrator = null;

  final String label;
  final _ExtratorValor? extrator;
  final _ExtratorTexto? extratorTexto;

  bool get isTexto => extratorTexto != null;

  bool temValor(List<AnaliseNormalizada> colunas) {
    if (isTexto) {
      return colunas.any((analise) {
        final valor = extratorTexto!(analise)?.trim();
        return valor != null && valor.isNotEmpty;
      });
    }
    return colunas.any((analise) => extrator!(analise) != null);
  }
}

class TabelaAnalisesWidget extends StatelessWidget {
  const TabelaAnalisesWidget({
    super.key,
    required this.media,
    required this.analises,
  });

  final AnaliseNormalizada? media;
  final List<AnaliseNormalizada> analises;

  static const double _larguraLabel = 176.0;
  static const double _larguraColuna = 112.0;

  static final List<_LinhaTabela> _linhas = <_LinhaTabela>[
    _LinhaTabela.numero('pH Água', (a) => a.phAgua),
    _LinhaTabela.numero('pH SMP', (a) => a.phSmp),
    _LinhaTabela.numero('pH CaCl2', (a) => a.phCaCl2),
    _LinhaTabela.numero('Ca (cmolc/dm3)', (a) => a.ca),
    _LinhaTabela.numero('Mg (cmolc/dm3)', (a) => a.mg),
    _LinhaTabela.numero('K (cmolc/dm3)', (a) => a.k),
    _LinhaTabela.numero('K (mg/dm3)', (a) => a.kMgDm3),
    _LinhaTabela.numero('Al (cmolc/dm3)', (a) => a.al),
    _LinhaTabela.numero('H+Al (cmolc/dm3)', (a) => a.hAl),
    _LinhaTabela.numero('Na (cmolc/dm3)', (a) => a.na),
    _LinhaTabela.numero('SB (cmolc/dm3)', (a) => a.sb),
    _LinhaTabela.numero('CTC (cmolc/dm3)', (a) => a.ctc),
    _LinhaTabela.numero('CTCe (cmolc/dm3)', (a) => a.ctcEfetiva),
    _LinhaTabela.numero('V% (%)', (a) => a.vPercent),
    _LinhaTabela.numero('m% (%)', (a) => a.mPercent),
    _LinhaTabela.numero('Ca/Mg', (a) => a.caMgRel),
    _LinhaTabela.numero('Ca/K', (a) => a.caKRel),
    _LinhaTabela.numero('Mg/K', (a) => a.mgKRel),
    _LinhaTabela.numero('P Mehlich (mg/dm3)', (a) => a.pMehlich),
    _LinhaTabela.numero('P Resina (mg/dm3)', (a) => a.pResina),
    _LinhaTabela.numero('P-rem (mg/L)', (a) => a.pRem),
    _LinhaTabela.numero('M.O. (%)', (a) => a.materiaOrganica),
    _LinhaTabela.numero('C orgânico (%)', (a) => a.carbonoOrganico),
    _LinhaTabela.numero('S 0-20 (mg/dm3)', (a) => a.s020),
    _LinhaTabela.numero('S 20-40 (mg/dm3)', (a) => a.s2040),
    _LinhaTabela.numero('B (mg/dm3)', (a) => a.b),
    _LinhaTabela.numero('Cu (mg/dm3)', (a) => a.cu),
    _LinhaTabela.numero('Fe (mg/dm3)', (a) => a.fe),
    _LinhaTabela.numero('Mn (mg/dm3)', (a) => a.mn),
    _LinhaTabela.numero('Zn (mg/dm3)', (a) => a.zn),
    _LinhaTabela.numero('Cu Mehlich (mg/dm3)', (a) => a.cuMehlich),
    _LinhaTabela.numero('Fe Mehlich (mg/dm3)', (a) => a.feMehlich),
    _LinhaTabela.numero('Mn Mehlich (mg/dm3)', (a) => a.mnMehlich),
    _LinhaTabela.numero('Zn Mehlich (mg/dm3)', (a) => a.znMehlich),
    _LinhaTabela.numero('Cu DTPA (mg/dm3)', (a) => a.cuDtpa),
    _LinhaTabela.numero('Fe DTPA (mg/dm3)', (a) => a.feDtpa),
    _LinhaTabela.numero('Mn DTPA (mg/dm3)', (a) => a.mnDtpa),
    _LinhaTabela.numero('Zn DTPA (mg/dm3)', (a) => a.znDtpa),
    _LinhaTabela.numero('Ni (mg/dm3)', (a) => a.ni),
    _LinhaTabela.numero('Mo (mg/dm3)', (a) => a.molibdenio),
    _LinhaTabela.numero('Se (mg/dm3)', (a) => a.se),
    _LinhaTabela.numero('Co (mg/dm3)', (a) => a.co),
    _LinhaTabela.numero('Argila (%)', (a) => a.argila),
    _LinhaTabela.numero('Silte (%)', (a) => a.silte),
    _LinhaTabela.numero('Areia total (%)', (a) => a.areiaTotal),
    _LinhaTabela.texto('Classificação textural', (a) => a.classificacaoTextura),
  ];

  @override
  Widget build(BuildContext context) {
    final colunas = <AnaliseNormalizada>[
      if (media != null) media!,
      ...analises,
    ];
    final linhas = _linhas.where((linha) => linha.temValor(colunas)).toList();

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: _larguraLabel + (colunas.length * _larguraColuna),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(colunas),
                  ...linhas.asMap().entries.map((entry) {
                    final index = entry.key;
                    return _buildLinha(
                      linha: entry.value,
                      colunas: colunas,
                      sombreado: index.isOdd,
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(List<AnaliseNormalizada> colunas) {
    return SizedBox(
      height: 68,
      child: Row(
        children: [
          Container(
            width: _larguraLabel,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.centerLeft,
            color: const Color(0xFFF5F5F7),
            child: Text(
              'PARÂMETRO',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecond,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...colunas.asMap().entries.map((entry) {
            final index = entry.key;
            final analise = entry.value;
            final isMedia = index == 0 && media != null;
            final titulo = isMedia
                ? 'MÉDIA'
                : 'Amostra ${media != null ? index : index + 1}';
            final subtitulo = isMedia ? 'seleção ativa' : _subtitulo(analise);

            return Container(
              width: _larguraColuna,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: BoxDecoration(
                color: isMedia ? AppColors.primary : Colors.white,
                border: Border(
                  left: BorderSide(
                    color: isMedia
                        ? AppColors.primary
                        : AppColors.borderSoft.withValues(alpha: 0.9),
                  ),
                  bottom: const BorderSide(color: AppColors.borderSoft),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      color: isMedia ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(
                      color: isMedia
                          ? Colors.white.withValues(alpha: 0.86)
                          : AppColors.textSecond,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLinha({
    required _LinhaTabela linha,
    required List<AnaliseNormalizada> colunas,
    required bool sombreado,
  }) {
    final background = sombreado ? const Color(0xFFF5F5F7) : Colors.white;

    return SizedBox(
      height: 48,
      child: Row(
        children: [
          Container(
            width: _larguraLabel,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.centerLeft,
            color: background,
            child: Text(
              linha.label,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
          ...colunas.asMap().entries.map((entry) {
            final index = entry.key;
            final analise = entry.value;
            final isMedia = index == 0 && media != null;
            final valor = linha.extrator?.call(analise);

            return Container(
              width: _larguraColuna,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isMedia
                    ? AppColors.primary.withValues(alpha: 0.06)
                    : background,
                border: const Border(
                  left: BorderSide(color: AppColors.borderSoft),
                  bottom: BorderSide(color: AppColors.borderSoft),
                ),
              ),
              child: Text(
                linha.isTexto
                    ? _formatarTexto(linha.extratorTexto?.call(analise))
                    : _formatarValor(valor),
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: isMedia ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _subtitulo(AnaliseNormalizada analise) {
    final talhao = analise.talhao.trim();
    if (talhao.isNotEmpty) return talhao;
    final laboratorio = analise.laboratorio.trim();
    if (laboratorio.isNotEmpty) return laboratorio;
    return analise.label;
  }

  String _formatarValor(double? valor) {
    if (valor == null) return '—';
    return valor.toStringAsFixed(2);
  }

  String _formatarTexto(String? valor) {
    final texto = valor?.trim();
    if (texto == null || texto.isEmpty) return '—';
    return texto;
  }
}
