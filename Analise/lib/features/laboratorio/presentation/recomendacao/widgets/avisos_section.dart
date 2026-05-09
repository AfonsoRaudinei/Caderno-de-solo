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

class RecomendacaoOQueComprarSection extends StatelessWidget {
  const RecomendacaoOQueComprarSection({super.key, required this.resultado});

  final ResultadoRecomendacao resultado;

  @override
  Widget build(BuildContext context) {
    final itens = <Map<String, String>>[];

    final calcario = resultado.doseCalcarioTHa;
    if (calcario > 0) {
      itens.add({
        'nome': 'Calcário',
        'dose': '${calcario.toStringAsFixed(2)} t/ha',
        'icone': '🪨'
      });
    }

    final gessoDose = resultado.gesso.doseKgHa;
    if (gessoDose > 0) {
      itens.add({
        'nome': 'Gesso Agrícola',
        'dose': '${gessoDose.toStringAsFixed(0)} kg/ha',
        'icone': '🔵'
      });
    }

    final fosforo = resultado.doseP2O5KgHa;
    if (fosforo > 0) {
      itens.add({
        'nome': 'Fertilizante Fosfatado',
        'dose': '${fosforo.toStringAsFixed(1)} kg P₂O₅/ha',
        'icone': '🟠'
      });
    }

    final potassio = resultado.doseK2OKgHa;
    if (potassio > 0) {
      itens.add({
        'nome': 'Fertilizante Potássico',
        'dose': '${potassio.toStringAsFixed(1)} kg K₂O/ha',
        'icone': '🟡'
      });
    }

    return AppCardSection(
      title: 'O QUE COMPRAR',
      child: itens.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Nenhuma correção necessária.',
                style: TextStyle(color: Color(0xFF86868B), fontSize: 14),
              ),
            )
          : Column(
              children: List.generate(itens.length * 2 - 1, (i) {
                if (i.isOdd) {
                  return const Divider(
                      height: 1, thickness: 0.5, color: Color(0xFFE5E5E7));
                }
                final item = itens[i ~/ 2];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Text(item['icone']!, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(item['nome']!, style: AppTextStyles.label),
                      ),
                      Text(item['dose']!, style: AppTextStyles.value),
                    ],
                  ),
                );
              }),
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
