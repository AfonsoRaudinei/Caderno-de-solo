// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

// Reutiliza AppColors da calibracao_page.dart (coloque em app_colors.dart no projeto real)
// import '../../../core/theme/app_colors.dart';

class AppColors {
  static const primary = Color(0xFF007AFF);
  static const primaryDark = Color(0xFF0051D5);
  static const bgPrimary = Color(0xFFFFFFFF);
  static const bgSecondary = Color(0xFFF5F5F7);
  static const textPrimary = Color(0xFF1D1D1F);
  static const textSecond = Color(0xFF86868B);
  static const border = Color(0xFFD1D1D6);
  static const borderSoft = Color(0xFFE5E5E7);
  static const success = Color(0xFF34C759);
  static const warning = Color(0xFFFF9500);
  static const error = Color(0xFFFF3B30);
  static const cardBg = Color(0xFFFFFFFF);
  static const calcario = Color(0xFF5AC8FA);
  static const gesso = Color(0xFF64D2FF);
  static const fosforo = Color(0xFFFF9500);
  static const potassio = Color(0xFFFFCB00);
  static const micro = Color(0xFFAF52DE);
}

// ─── Mock de dados (substituir por providers reais) ───────────────────────────

class _MockAnalise {
  final String id;
  final String produtor;
  final String area;
  final String safra;
  final String cultura;

  // Dados da análise de solo
  final double pH;
  final double vPorcento; // Saturação de Bases %
  final double ctc; // mmolc/dm³
  final double al; // Al³⁺ mmolc/dm³
  final double argila; // %
  final double p; // P mg/dm³ (resina)
  final double k; // K mmolc/dm³
  final double ca; // Ca mmolc/dm³
  final double mg; // Mg mmolc/dm³
  final double s; // S mg/dm³
  final double b; // B mg/dm³
  final double cu; // Cu mg/dm³
  final double fe; // Fe mg/dm³
  final double mn; // Mn mg/dm³
  final double zn; // Zn mg/dm³

  const _MockAnalise({
    required this.id,
    required this.produtor,
    required this.area,
    required this.safra,
    required this.cultura,
    required this.pH,
    required this.vPorcento,
    required this.ctc,
    required this.al,
    required this.argila,
    required this.p,
    required this.k,
    required this.ca,
    required this.mg,
    required this.s,
    required this.b,
    required this.cu,
    required this.fe,
    required this.mn,
    required this.zn,
  });
}

class _MockPerfil {
  final String id;
  final String nome;
  final String metodoCalagem;
  final String metodoPosf;
  const _MockPerfil({
    required this.id,
    required this.nome,
    required this.metodoCalagem,
    required this.metodoPosf,
  });
}

final _analises = [
  const _MockAnalise(
    id: '1',
    produtor: 'João Almeida',
    area: 'Talhão 04 — Norte',
    safra: '2024/2025',
    cultura: 'Soja',
    pH: 5.0,
    vPorcento: 47.3,
    ctc: 60.4,
    al: 0.1,
    argila: 22.0,
    p: 16.0,
    k: 2.4,
    ca: 17.0,
    mg: 7.0,
    s: 6.0,
    b: 0.23,
    cu: 0.4,
    fe: 25.0,
    mn: 4.0,
    zn: 1.4,
  ),
  const _MockAnalise(
    id: '2',
    produtor: 'Maria Costa',
    area: 'Gleba Sul',
    safra: '2024/2025',
    cultura: 'Milho',
    pH: 5.8,
    vPorcento: 62.0,
    ctc: 55.0,
    al: 0.0,
    argila: 35.0,
    p: 12.0,
    k: 1.8,
    ca: 20.0,
    mg: 9.0,
    s: 4.0,
    b: 0.5,
    cu: 0.3,
    fe: 18.0,
    mn: 2.5,
    zn: 0.9,
  ),
];

final _perfis = [
  const _MockPerfil(
    id: 'p1',
    nome: 'Soja SP — ESALQ 2024',
    metodoCalagem: 'Saturação de Bases (V%)',
    metodoPosf: 'Resina (IAC)',
  ),
  const _MockPerfil(
    id: 'p2',
    nome: 'Milho MT — EMBRAPA',
    metodoCalagem: 'Neutralização do Alumínio (Al³⁺)',
    metodoPosf: 'Mehlich-1',
  ),
];

// ─── Resultado por nutriente ──────────────────────────────────────────────────

enum _StatusNC { adequado, corrigir, critico }

class _ResultadoNutriente {
  final String nutriente;
  final Color accentColor;
  final IconData icone;
  final double valorAnalisado;
  final String unidade;
  final String nivelCritico; // texto da referência real
  final double progresso; // 0.0–1.0 para barra
  final _StatusNC status;
  final String? recomendacao; // dose ou ação sugerida
  final String referencia; // fonte usada

  const _ResultadoNutriente({
    required this.nutriente,
    required this.accentColor,
    required this.icone,
    required this.valorAnalisado,
    required this.unidade,
    required this.nivelCritico,
    required this.progresso,
    required this.status,
    this.recomendacao,
    required this.referencia,
  });
}

List<_ResultadoNutriente> _calcularResultados(_MockAnalise a, _MockPerfil p) {
  final resultados = <_ResultadoNutriente>[];

  // ── Calagem ─────────────────────────────────────────────────────────────────
  const vAlvo = 70.0;
  final ncCalagem = (vAlvo - a.vPorcento) * a.ctc / 100;
  final statusCalagem = a.vPorcento >= vAlvo
      ? _StatusNC.adequado
      : a.vPorcento >= 55
          ? _StatusNC.corrigir
          : _StatusNC.critico;
  resultados.add(_ResultadoNutriente(
    nutriente: 'Calagem',
    accentColor: AppColors.calcario,
    icone: Icons.terrain_rounded,
    valorAnalisado: a.vPorcento,
    unidade: '% V',
    nivelCritico: 'V% ≥ 70%  |  pH 6,0–6,5',
    progresso: (a.vPorcento / vAlvo).clamp(0.0, 1.0),
    status: statusCalagem,
    recomendacao: statusCalagem == _StatusNC.adequado
        ? null
        : 'NC ≈ ${ncCalagem.toStringAsFixed(1)} t/ha (PRNT 100%)',
    referencia: 'ESALQ/USP — Fancelli (2020)',
  ));

  // ── Gessagem ─────────────────────────────────────────────────────────────────
  // Critério: argila < 18% ou Al subsoil (simplificado: argila-based)
  final gesso = a.argila * 0.05; // NG = 50 × argila% ÷ 1000 em t/ha
  final statusGesso = a.argila < 15 ? _StatusNC.adequado : _StatusNC.corrigir;
  resultados.add(_ResultadoNutriente(
    nutriente: 'Gessagem',
    accentColor: AppColors.gesso,
    icone: Icons.layers_rounded,
    valorAnalisado: a.argila,
    unidade: '% Argila',
    nivelCritico: 'NG = 50 × argila (%) kg/ha',
    progresso: (a.argila / 60).clamp(0.0, 1.0),
    status: statusGesso,
    recomendacao:
        '${gesso.toStringAsFixed(1)} t/ha  (${a.argila.toStringAsFixed(0)}% argila)',
    referencia: 'EMBRAPA Soja — Souza et al. (2004)',
  ));

  // ── Fósforo ─────────────────────────────────────────────────────────────────
  // NC por argila (Resina IAC)
  double ncP;
  if (a.argila < 15) {
    ncP = 30;
  } else if (a.argila <= 35) {
    ncP = 20;
  } else {
    ncP = 12;
  }
  final statusP = a.p >= ncP
      ? _StatusNC.adequado
      : a.p >= ncP * 0.7
          ? _StatusNC.corrigir
          : _StatusNC.critico;
  resultados.add(_ResultadoNutriente(
    nutriente: 'Fósforo (P)',
    accentColor: AppColors.fosforo,
    icone: Icons.science_rounded,
    valorAnalisado: a.p,
    unidade: 'mg/dm³',
    nivelCritico:
        '≥ ${ncP.toStringAsFixed(0)} mg/dm³ (argila ${a.argila.toStringAsFixed(0)}%)',
    progresso: (a.p / (ncP * 1.5)).clamp(0.0, 1.0),
    status: statusP,
    recomendacao: statusP == _StatusNC.adequado
        ? null
        : 'Verificar adubação fosfatada (consultar boletim IAC)',
    referencia: 'IAC/SP — Boletim 100 (Raij et al.)',
  ));

  // ── Potássio ─────────────────────────────────────────────────────────────────
  final kCtcPct = (a.k / a.ctc) * 100;
  const ncKPct = 2.5;
  final statusK = kCtcPct >= 3.5
      ? _StatusNC.adequado
      : kCtcPct >= ncKPct
          ? _StatusNC.corrigir
          : _StatusNC.critico;
  resultados.add(_ResultadoNutriente(
    nutriente: 'Potássio (K)',
    accentColor: AppColors.potassio,
    icone: Icons.bolt_rounded,
    valorAnalisado: kCtcPct,
    unidade: '% K/CTC',
    nivelCritico: '≥ 2,5%  |  ótimo 3,5–5,0%',
    progresso: (kCtcPct / 5.0).clamp(0.0, 1.0),
    status: statusK,
    recomendacao: statusK == _StatusNC.adequado
        ? null
        : 'Repor K — calcular dose por exportação da cultura',
    referencia: 'ESALQ/USP — Fancelli (2020)',
  ));

  // ── Micronutrientes ──────────────────────────────────────────────────────────
  final micros = <String, double>{
    'B': a.b,
    'Cu': a.cu,
    'Fe': a.fe,
    'Mn': a.mn,
    'Zn': a.zn,
  };
  final ncsM = {'B': 0.6, 'Cu': 0.4, 'Fe': 5.0, 'Mn': 1.2, 'Zn': 1.0};
  final algumCritico = micros.entries.any((e) => e.value < (ncsM[e.key] ?? 0));
  final statusMicro = algumCritico ? _StatusNC.corrigir : _StatusNC.adequado;
  resultados.add(_ResultadoNutriente(
    nutriente: 'Micronutrientes',
    accentColor: AppColors.micro,
    icone: Icons.biotech_rounded,
    valorAnalisado: a.zn, // exibe Zn como referência visual
    unidade: 'Zn mg/dm³',
    nivelCritico: 'B≥0,6 · Cu≥0,4 · Fe≥5,0 · Mn≥1,2 · Zn≥1,0 mg/dm³',
    progresso: (a.zn / 2.0).clamp(0.0, 1.0),
    status: statusMicro,
    recomendacao: algumCritico ? _microDeficiencias(micros, ncsM) : null,
    referencia: 'ESALQ/USP — DTPA-TEA',
  ));

  return resultados;
}

String _microDeficiencias(Map<String, double> vals, Map<String, double> ncs) {
  final def = vals.entries
      .where((e) => e.value < (ncs[e.key] ?? 0))
      .map((e) => '${e.key}: ${e.value.toStringAsFixed(2)} mg/dm³')
      .join(' · ');
  return 'Deficiência: $def';
}

// ─── PAGE ─────────────────────────────────────────────────────────────────────

class RecomendacaoPage extends StatefulWidget {
  const RecomendacaoPage({super.key});

  @override
  State<RecomendacaoPage> createState() => _RecomendacaoPageState();
}

class _RecomendacaoPageState extends State<RecomendacaoPage> {
  _MockAnalise? _analiseSelecionada;
  _MockPerfil? _perfilSelecionado;
  bool _calculado = false;
  List<_ResultadoNutriente> _resultados = [];

  void _calcular() {
    if (_analiseSelecionada == null || _perfilSelecionado == null) return;
    setState(() {
      _resultados =
          _calcularResultados(_analiseSelecionada!, _perfilSelecionado!);
      _calculado = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          // ── Seleção ──────────────────────────────────────────────────────
          const _SectionLabel('Análise de Solo'),
          _SelectCard<_MockAnalise>(
            placeholder: 'Selecione uma análise',
            selectedLabel: _analiseSelecionada == null
                ? null
                : '${_analiseSelecionada!.produtor} — ${_analiseSelecionada!.area} (${_analiseSelecionada!.safra})',
            items: _analises,
            labelOf: (a) =>
                '${a.produtor} · ${a.area} · ${a.safra} · ${a.cultura}',
            onSelect: (a) => setState(() {
              _analiseSelecionada = a;
              _calculado = false;
            }),
          ),

          const SizedBox(height: 8),

          const _SectionLabel('Perfil de Calibração'),
          _SelectCard<_MockPerfil>(
            placeholder: 'Selecione um perfil',
            selectedLabel: _perfilSelecionado?.nome,
            items: _perfis,
            labelOf: (p) => '${p.nome}  (${p.metodoCalagem})',
            onSelect: (p) => setState(() {
              _perfilSelecionado = p;
              _calculado = false;
            }),
          ),

          const SizedBox(height: 16),

          // ── Botão Calcular ────────────────────────────────────────────────
          _BotaoCalcular(
            ativo: _analiseSelecionada != null && _perfilSelecionado != null,
            onPressed: _calcular,
          ),

          // ── Resultados ────────────────────────────────────────────────────
          if (_calculado) ...[
            const SizedBox(height: 24),
            const _SectionLabel('Resultados da Recomendação'),
            const SizedBox(height: 4),

            // Info strip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.07),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_rounded,
                      color: AppColors.primary, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Calculado com dados reais da análise · Perfil: ${_perfilSelecionado!.nome}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            ..._resultados.map((r) => _ResultadoCard(resultado: r)),
          ],
        ],
      ),
    );
  }
}

// ─── Widgets da Recomendação ──────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6, top: 4),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecond,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _SelectCard<T> extends StatelessWidget {
  final String placeholder;
  final String? selectedLabel;
  final List<T> items;
  final String Function(T) labelOf;
  final ValueChanged<T> onSelect;

  const _SelectCard({
    required this.placeholder,
    required this.selectedLabel,
    required this.items,
    required this.labelOf,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await showModalBottomSheet<T>(
          context: context,
          backgroundColor: AppColors.bgPrimary,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (_) => ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              ...items.map(
                (item) => ListTile(
                  title: Text(labelOf(item),
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.textPrimary)),
                  onTap: () => Navigator.pop(context, item),
                ),
              ),
            ],
          ),
        );
        if (result != null) onSelect(result);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectedLabel != null
                ? AppColors.primary.withOpacity(0.4)
                : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedLabel ?? placeholder,
                style: TextStyle(
                  fontSize: 14,
                  color: selectedLabel != null
                      ? AppColors.textPrimary
                      : AppColors.textSecond,
                  fontWeight:
                      selectedLabel != null ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down,
                color: AppColors.textSecond, size: 20),
          ],
        ),
      ),
    );
  }
}

class _BotaoCalcular extends StatelessWidget {
  final bool ativo;
  final VoidCallback onPressed;
  const _BotaoCalcular({required this.ativo, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: ativo ? 1.0 : 0.4,
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: ativo ? onPressed : null,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            gradient: ativo
                ? const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [Colors.grey.shade400, Colors.grey.shade500],
                  ),
            borderRadius: BorderRadius.circular(13),
            boxShadow: ativo
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    )
                  ]
                : [],
          ),
          child: const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calculate_rounded, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text(
                  'Calcular Recomendação',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultadoCard extends StatelessWidget {
  final _ResultadoNutriente resultado;
  const _ResultadoCard({required this.resultado});

  Color get _statusColor {
    switch (resultado.status) {
      case _StatusNC.adequado:
        return AppColors.success;
      case _StatusNC.corrigir:
        return AppColors.warning;
      case _StatusNC.critico:
        return AppColors.error;
    }
  }

  String get _statusLabel {
    switch (resultado.status) {
      case _StatusNC.adequado:
        return 'Adequado';
      case _StatusNC.corrigir:
        return 'Corrigir';
      case _StatusNC.critico:
        return 'Crítico';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: resultado.accentColor, width: 3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(resultado.icone, color: resultado.accentColor, size: 18),
              const SizedBox(width: 8),
              Text(
                resultado.nutriente,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _statusColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Valor analisado + NC
          Row(
            children: [
              _InfoPill(
                label: 'Analisado',
                value:
                    '${resultado.valorAnalisado.toStringAsFixed(1)} ${resultado.unidade}',
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _InfoPill(
                  label: 'Nível crítico',
                  value: resultado.nivelCritico,
                  color: AppColors.textSecond,
                  small: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Barra de progresso
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: resultado.progresso,
              minHeight: 6,
              backgroundColor: AppColors.borderSoft,
              valueColor: AlwaysStoppedAnimation<Color>(_statusColor),
            ),
          ),

          // Recomendação de dose / ação
          if (resultado.recomendacao != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.recommend_rounded, size: 15, color: _statusColor),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      resultado.recomendacao!,
                      style: TextStyle(
                        fontSize: 13,
                        color: _statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 8),

          // Referência
          Row(
            children: [
              const Icon(Icons.menu_book_rounded,
                  size: 12, color: AppColors.textSecond),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  resultado.referencia,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecond,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool small;

  const _InfoPill({
    required this.label,
    required this.value,
    required this.color,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecond,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                fontSize: small ? 11 : 13,
                color: color,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }
}
