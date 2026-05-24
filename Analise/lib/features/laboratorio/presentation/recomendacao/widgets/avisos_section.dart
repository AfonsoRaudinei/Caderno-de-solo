import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/widgets/app_card.dart';
import 'package:soloforte/domain/usecases/recomendacao_engine.dart';

class RecomendacaoIdentificacaoSection extends StatelessWidget {
  const RecomendacaoIdentificacaoSection({super.key, required this.resultado});

  final ResultadoRecomendacao resultado;

  @override
  Widget build(BuildContext context) {
    final analise = resultado.analise;
    return AppCardSection(
      title: 'Identificação',
      child: Column(
        children: [
          _buildInfoRow('Identificação', analise.id),
          _buildInfoRow('Nome do produtor', analise.nome),
          _buildInfoRow('Fazenda', analise.fazenda),
          _buildInfoRow('Cidade', analise.localizacao),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text('$label: ', style: AppTextStyles.label),
          Text(value, style: AppTextStyles.body),
        ],
      ),
    );
  }
}

class RecomendacaoAvisosSection extends StatelessWidget {
  const RecomendacaoAvisosSection({super.key, required this.resultado});

  final ResultadoRecomendacao resultado;

  @override
  Widget build(BuildContext context) {
    return AppCardSection(
      title: 'Avisos',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (resultado.avisos.isEmpty)
            const Text('Sem avisos críticos para os parâmetros atuais.')
          else
            ...resultado.avisos.map(
              (aviso) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _Badge(
                  icon: Icons.warning_amber_rounded,
                  color: AppColors.warning,
                  label: aviso,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class RecomendacaoArgumentosSection extends StatelessWidget {
  const RecomendacaoArgumentosSection({super.key, required this.resultado});

  final ResultadoRecomendacao resultado;

  @override
  Widget build(BuildContext context) {
    final citacoes = resultado.citacoes;
    return AppCardSection(
      title: 'Argumentos Técnicos',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(resultado.argumentos, style: AppTextStyles.body),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          _buildCitacao('Calcário', citacoes?['calagem']),
          _buildCitacao('Gesso', citacoes?['gesso']),
          _buildCitacao('Fósforo', citacoes?['fosforo']),
          _buildCitacao('Potássio', citacoes?['potassio']),
          _buildCitacao('Micronutrientes', citacoes?['micros']),
        ],
      ),
    );
  }

  Widget _buildCitacao(String nutriente, String? citacao) {
    if (citacao == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        '• $nutriente: $citacao',
        style: AppTextStyles.label.copyWith(color: AppColors.textSecond),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
