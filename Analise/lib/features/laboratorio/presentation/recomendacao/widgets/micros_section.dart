import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';
import 'package:soloforte/domain/usecases/recomendacao_engine.dart';

class RecomendacaoMicrosUnificadosSection extends StatelessWidget {
  const RecomendacaoMicrosUnificadosSection({
    super.key,
    required this.resultado,
  });

  final ResultadoRecomendacao resultado;

  @override
  Widget build(BuildContext context) {
    if (resultado.micros.isEmpty) return const SizedBox.shrink();
    final palette = context.appPalette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'MICRONUTRIENTES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: palette.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...resultado.grupos.map(
          (grupo) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _GrupoMicroCard(grupo: grupo),
          ),
        ),
        if (resultado.grupos.isEmpty)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                for (var i = 0; i < resultado.micros.length; i++)
                  _MicroNutrienteItem(
                    micro: resultado.micros[i],
                    showDivider: i < resultado.micros.length - 1,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _GrupoMicroCard extends StatelessWidget {
  const _GrupoMicroCard({required this.grupo});

  final GrupoResultado grupo;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  grupo.nomeGrupo,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D1D1F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${grupo.via} · ${grupo.produto}',
                  style: TextStyle(
                    fontSize: 12,
                    color: palette.textSecondary,
                  ),
                ),
                Text(
                  grupo.doseProdutoKgLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          for (var i = 0; i < grupo.micros.length; i++)
            _MicroNutrienteItem(
              micro: grupo.micros[i],
              showDivider: i < grupo.micros.length - 1,
            ),
        ],
      ),
    );
  }
}

class _MicroNutrienteItem extends StatelessWidget {
  const _MicroNutrienteItem({
    required this.micro,
    required this.showDivider,
  });

  final MicroResultado micro;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            leading: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _corDoNutriente(micro.elemento),
                shape: BoxShape.circle,
              ),
            ),
            title: Text(
              micro.elemento,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '${micro.valorAtual.toStringAsFixed(2)} mg/dm³ · NC ${micro.nc.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 12),
            ),
            children: [
              _DetalheLinha('Déficit', '${_fmt(micro.deficit)} mg/dm³'),
              _DetalheLinha(
                  'Correção solo', '${_fmt(micro.correcaoSolo)} g/ha'),
              _DetalheLinha('Produção', '${_fmt(micro.producaoTha)} t/ha'),
              _DetalheLinha('Extração', '${_fmt(micro.extracao)} g/ha'),
              _DetalheLinha('Exportação', '${_fmt(micro.exportacao)} g/ha'),
              _DetalheLinha('Regra', micro.regraUtilizada),
              _DetalheLinha(
                'Eficiência',
                '${_fmt(micro.eficienciaAplicada)}% (${micro.via})',
              ),
              _DetalheLinha(
                'Necessidade',
                '${_fmt(micro.necessidadeNutriente)} g/ha',
              ),
              _DetalheLinha('Fonte', micro.fonte),
              _DetalheLinha('Dose comercial', micro.doseProdutoLabel),
              if (micro.memoriaCalculo.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Memória de cálculo',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                ...micro.memoriaCalculo.map(
                  (linha) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      '· $linha',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ),
              ],
              if (micro.avisosNutriente.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...micro.avisosNutriente.map(
                  (aviso) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('⚠️ ', style: TextStyle(fontSize: 12)),
                        Expanded(
                          child: Text(
                            aviso,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFFF9500),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: context.appPalette.border,
          ),
      ],
    );
  }

  String _fmt(double v) => v.toStringAsFixed(2).replaceAll('.', ',');

  Color _corDoNutriente(String elemento) {
    const cores = {
      'Se': Color(0xFF34C759),
      'Ni': Color(0xFF1D1D1F),
      'Co': Color(0xFF8E8E93),
      'Mn': Color(0xFFAF52DE),
      'B': Color(0xFFFFCC00),
      'Cu': Color(0xFFFF9500),
      'Zn': Color(0xFF007AFF),
      'Mo': Color(0xFF5856D6),
      'Fe': Color(0xFF5AC8FA),
    };
    return cores[elemento] ?? const Color(0xFF8E8E93);
  }
}

class _DetalheLinha extends StatelessWidget {
  const _DetalheLinha(this.label, this.valor);

  final String label;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: context.appPalette.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
