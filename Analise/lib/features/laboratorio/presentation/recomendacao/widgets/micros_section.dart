import 'package:flutter/material.dart';
import 'package:soloforte/core/widgets/app_card.dart';
import 'package:soloforte/domain/usecases/recomendacao_engine.dart';

class RecomendacaoMicrosSection extends StatelessWidget {
  const RecomendacaoMicrosSection({super.key, required this.resultado});

  final ResultadoRecomendacao resultado;

  @override
  Widget build(BuildContext context) {
    if (resultado.micros.isEmpty && resultado.grupos.isEmpty) {
      return const AppCardSection(
        title: 'MICRONUTRIENTES',
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Nenhuma dose de micronutriente configurada.',
            style: TextStyle(fontSize: 13, color: Color(0xFF86868B)),
          ),
        ),
      );
    }

    return AppCardSection(
      title: 'MICRONUTRIENTES',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...resultado.micros.asMap().entries.map((entry) {
            final i = entry.key;
            final m = entry.value;
            return Column(children: [
              if (i > 0)
                const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5E7)),
              _buildMicroRow(m),
            ]);
          }),
          if (resultado.grupos.isNotEmpty) ...[
            const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5E7)),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                'GRUPOS DE PRODUTO',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF86868B),
                    letterSpacing: 0.5),
              ),
            ),
            ...resultado.grupos.map((g) => _buildGrupoRow(g)),
          ],
        ],
      ),
    );
  }

  Widget _buildMicroRow(MicroResultado m) {
    final cor = _corMicro(m.elemento);
    final icone = _iconeMicro(m.elemento);
    final temDose = m.dose > 0;
    final barPct = m.nc > 0 ? (m.valorAtual / m.nc * 100).clamp(0.0, 100.0) : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icone, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                m.elemento,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: cor),
              ),
              const SizedBox(width: 6),
              Text(
                '(${m.via})',
                style: const TextStyle(fontSize: 10, color: Color(0xFF86868B)),
              ),
              const Spacer(),
              Text(
                '${m.valorAtual.toStringAsFixed(2)} mg/dm³',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D1D1F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _barraSimples(barPct, m.deficiente ? const Color(0xFFFF3B30) : cor),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                'NC: ${m.nc.toStringAsFixed(2)} mg/dm³',
                style: const TextStyle(fontSize: 10, color: Color(0xFF86868B)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: m.deficiente
                      ? const Color(0xFFFF3B30).withValues(alpha: 0.10)
                      : const Color(0xFF34C759).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  m.deficiente ? 'Deficiente' : 'Adequado',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: m.deficiente ? const Color(0xFFFF3B30) : const Color(0xFF34C759),
                  ),
                ),
              ),
            ],
          ),
          if (temDose) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  '${m.dose.toStringAsFixed(1)} ${m.unidade}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: cor),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '· ${m.doseProdutoLabel}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF86868B)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (m.referencia != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  m.referencia!,
                  style: const TextStyle(fontSize: 10, color: Color(0xFFC7C7CC)),
                ),
              ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildGrupoRow(GrupoResultado grupo) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E5E7), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '📦 ${grupo.nomeGrupo}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D1D1F),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    grupo.via,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF007AFF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              grupo.micros.map((e) => '${_iconeMicro(e.elemento)} ${e.elemento}').join('  '),
              style: const TextStyle(fontSize: 12, color: Color(0xFF86868B)),
            ),
            const SizedBox(height: 6),
            const Divider(height: 1, color: Color(0xFFE5E5E7)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    grupo.produto,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF1D1D1F)),
                  ),
                ),
                Text(
                  grupo.doseProdutoKgLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF007AFF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Fornece: ${grupo.fornecimento}',
              style: const TextStyle(fontSize: 11, color: Color(0xFF86868B)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _barraSimples(double pct, Color cor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LinearProgressIndicator(
        value: pct / 100.0,
        backgroundColor: const Color(0xFFE5E5E7),
        valueColor: AlwaysStoppedAnimation<Color>(cor),
        minHeight: 8,
      ),
    );
  }

  String _iconeMicro(String el) {
    switch (el) {
      case 'Zn':
        return '🔵';
      case 'B':
        return '🟡';
      case 'Cu':
        return '🟠';
      case 'Fe':
        return '🔴';
      case 'Mn':
        return '🟣';
      case 'Ni':
        return '⚫';
      case 'Mo':
        return '🔘';
      case 'Se':
        return '🟢';
      default:
        return '⚪';
    }
  }

  Color _corMicro(String el) {
    switch (el) {
      case 'Zn':
        return const Color(0xFF007AFF);
      case 'B':
        return const Color(0xFFFFCC00);
      case 'Cu':
        return const Color(0xFFFF9500);
      case 'Fe':
        return const Color(0xFFFF3B30);
      case 'Mn':
        return const Color(0xFF9B59B6);
      case 'Ni':
        return const Color(0xFF636366);
      case 'Mo':
        return const Color(0xFF5AC8FA);
      case 'Se':
        return const Color(0xFF34C759);
      default:
        return const Color(0xFF86868B);
    }
  }
}

class RecomendacaoMicrosSoloSection extends StatelessWidget {
  const RecomendacaoMicrosSoloSection({super.key, required this.resultado});

  final ResultadoRecomendacao resultado;

  @override
  Widget build(BuildContext context) {
    return _RecomendacaoMicrosAgrupadosSection(
      resultado: resultado,
      titulo: 'MICRONUTRIENTES — APLICAÇÃO NO SOLO',
      filtroVia: const ['Solo', 'Ambas'],
      campoExtra: (m) => 'Produto: ${m?.doseProdutoLabel ?? '-'}',
    );
  }
}

class RecomendacaoMicrosFoliarSection extends StatelessWidget {
  const RecomendacaoMicrosFoliarSection({super.key, required this.resultado});

  final ResultadoRecomendacao resultado;

  @override
  Widget build(BuildContext context) {
    return _RecomendacaoMicrosAgrupadosSection(
      resultado: resultado,
      titulo: 'MICRONUTRIENTES — APLICAÇÃO FOLIAR',
      filtroVia: const ['Foliar', 'Ambas'],
      campoExtra: (m) => 'Produto: ${m?.doseProdutoLabel ?? '-'}',
    );
  }
}

class _RecomendacaoMicrosAgrupadosSection extends StatelessWidget {
  const _RecomendacaoMicrosAgrupadosSection({
    required this.resultado,
    required this.titulo,
    required this.filtroVia,
    required this.campoExtra,
  });

  final ResultadoRecomendacao resultado;
  final String titulo;
  final List<String> filtroVia;
  final String? Function(MicroResultado? m) campoExtra;

  @override
  Widget build(BuildContext context) {
    final micros = resultado.micros.where((m) {
      final via = m.via;
      return filtroVia.any((f) => via.contains(f));
    }).toList();

    if (micros.isEmpty) return const SizedBox.shrink();

    return AppCardSection(
      title: titulo,
      child: Column(
        children: micros.asMap().entries.map((entry) {
          final i = entry.key;
          final m = entry.value;
          final nome = m.elemento;
          final teor = m.valorAtual;
          final extra = campoExtra(m);

          return Column(
            children: [
              if (i > 0)
                const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5E7)),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(nome, style: const TextStyle(fontSize: 13, color: Color(0xFF1D1D1F))),
                        const Spacer(),
                        Text(
                          '${teor.toStringAsFixed(2)} mg/dm³',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF86868B)),
                        ),
                      ],
                    ),
                    if (extra != null) ...[
                      const SizedBox(height: 4),
                      Text(extra, style: const TextStyle(fontSize: 11, color: Color(0xFF86868B))),
                    ],
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
