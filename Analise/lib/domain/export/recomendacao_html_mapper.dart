import 'dart:math' as math;

import 'package:soloforte/domain/export/disponibilidade_nutrientes_calculator.dart';
import 'package:soloforte/domain/export/recomendacao_export_context.dart';
import 'package:soloforte/domain/formulas/classificacao_nivel.dart';
import 'package:soloforte/domain/usecases/recomendacao_engine.dart';

/// Mapeia [ResultadoRecomendacao] para HTML no visual SoloForte v4.
class RecomendacaoHtmlMapper {
  const RecomendacaoHtmlMapper();

  Map<String, String> buildPlaceholders(RecomendacaoExportContext ctx) {
    return {'BODY': buildBody(ctx)};
  }

  String buildBody(RecomendacaoExportContext ctx) {
    final r = ctx.resultado;
    final meta = ctx.metadata;
    final cal = r.calibracao;
    final a = r.analise;
    final gerada = ctx.geradaEm ?? r.geradaEm ?? DateTime.now();

    final buffer = StringBuffer()
      ..writeln(_hero())
      ..writeln('<div class="container">')
      ..writeln(_consultCard(r, meta, cal, a, gerada))
      ..writeln(_sectionDiagnostico(r))
      ..writeln(_sectionCalcario(r))
      ..writeln(_sectionProjecao(r))
      ..writeln(_sectionFosforo(r))
      ..writeln(_sectionPotassio(r))
      ..writeln(_sectionEnxofre(r))
      ..writeln(_sectionMicros(r))
      ..writeln(_sectionAvisos(r))
      ..writeln('</div>')
      ..writeln(_footer(gerada, meta.consultorNome ?? a.consultor));

    return buffer.toString();
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  static String _esc(String? text) {
    if (text == null || text.isEmpty) return '';
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;');
  }

  static String _fmt(double value, [int decimals = 2]) {
    return value.toStringAsFixed(decimals).replaceAll('.', ',');
  }

  static String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  static String _fmtDateTime(DateTime d) =>
      '${_fmtDate(d)} <span class="sm">${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}</span>';

  static double _gradPct(String nutriente, double valor, {double? argila}) {
    final (min, max) = NivelEscala.escala(nutriente, argila: argila);
    final range = max - min;
    if (range <= 0) return 0;
    final clamped = valor < min ? min : (valor > max ? max : valor);
    return ((clamped - min) / range * 100).clamp(0.0, 100.0);
  }

  static double _microGradPct(double valor, double nc) {
    if (nc <= 0) return valor <= 0 ? 0 : 100;
    return (valor / (nc * 2) * 100).clamp(0.0, 100.0);
  }

  static double microMarkerPercent(double valor, double nc) =>
      _microGradPct(valor, nc);

  static String _pillClass(String rotulo) {
    final lower = rotulo.toLowerCase();
    if (lower.contains('muito baixo') || lower.contains('deficiente')) {
      return 'pill-red';
    }
    if (lower.contains('baixo')) return 'pill-orange';
    if (lower.contains('médio') || lower.contains('medio')) {
      return 'pill-yellow';
    }
    if (lower.contains('adequado') || lower.contains('alto')) {
      return 'pill-green';
    }
    return 'pill-yellow';
  }

  static String _pill(String rotulo) =>
      '<span class="pill ${_pillClass(rotulo)}">${_esc(rotulo)}</span>';

  static String _gradBar(double leftPct, List<String> labels) {
    final scale = labels.map((l) => '<span>${_esc(l)}</span>').join();
    return '''
<div class="grad-wrap">
  <div class="grad-bar"><div class="grad-marker" style="left:${leftPct.toStringAsFixed(1)}%;"></div></div>
  <div class="grad-scale">$scale</div>
</div>''';
  }

  static String _doseBlock(
          String label, String num, String unit, String color) =>
      '''
<div class="dose-block">
  <span class="dose-lbl">${_esc(label)}</span>
  <span class="dose-num" style="color:$color;">$num</span>
  <span class="dose-unit">${_esc(unit)}</span>
</div>''';

  static String _warn(String html) => '<div class="warn">$html</div>';

  static Map<String, dynamic> _corretivos(ResultadoRecomendacao r) {
    final raw = r.calibracao.parametrosCards['corretivos'];
    return raw is Map<String, dynamic> ? raw : <String, dynamic>{};
  }

  static double _num(dynamic v, [double fb = 0]) =>
      v is num ? v.toDouble() : fb;

  static String _referenciaFosforo(ResultadoRecomendacao r) {
    final fos = r.calibracao.parametrosCards['fosforo'];
    if (fos is Map && fos['referencia'] != null) {
      return fos['referencia'].toString();
    }
    return 'Embrapa Cerrado';
  }

  static String _parseCidadeUf(String localizacao) {
    final parts = localizacao.split('/');
    if (parts.length >= 2) {
      return '${parts[0].trim()} <span class="sm">/ ${parts.sublist(1).join('/').trim()}</span>';
    }
    return _esc(localizacao);
  }

  // ─── Sections ────────────────────────────────────────────────────────────

  static String _hero() => '''
<div class="hero">
  <div class="hero-brand">SoloForte</div>
  <div class="hero-sub">Caderno de Solo</div>
</div>''';

  static String _consultCard(
    ResultadoRecomendacao r,
    RecomendacaoExportMetadata meta,
    dynamic cal,
    dynamic a,
    DateTime gerada,
  ) {
    final logoHtml = meta.logoDataUri != null
        ? '<img src="${meta.logoDataUri}" alt="Logo">'
        : '';
    final consultor = _esc(meta.consultorNome ?? a.consultor);
    final credencial = _esc(meta.consultorCredencial ?? '');
    final dataLaudo = meta.dataLaudo != null ? _fmtDate(meta.dataLaudo!) : '—';

    return '''
<div class="consult-card">
  <div class="consult-top">
    <div class="logo-ph">$logoHtml</div>
    <div>
      <div class="c-name">$consultor</div>
      <div class="c-crea">$credencial</div>
    </div>
    <div class="c-badge">${_esc(cal.nome).replaceAll(' ', '<br>')}</div>
  </div>
  <div class="info-grid">
    <div class="info-cell"><div class="info-lbl">Produtor</div><div class="info-val">${_esc(cal.cliente)}</div></div>
    <div class="info-cell"><div class="info-lbl">Fazenda</div><div class="info-val">${_esc(cal.fazenda)}</div></div>
    <div class="info-cell"><div class="info-lbl">Cidade / UF</div><div class="info-val">${_parseCidadeUf(a.localizacao)}</div></div>
    <div class="info-cell"><div class="info-lbl">Talhao</div><div class="info-val">${_esc(cal.talhao)}</div></div>
    <div class="info-cell"><div class="info-lbl">Cultura · Safra</div><div class="info-val">${_esc(cal.cultura)} <span class="sm">· ${_esc(cal.safra)}</span></div></div>
    <div class="info-cell"><div class="info-lbl">Laboratorio</div><div class="info-val">${_esc(meta.laboratorio ?? a.nome)}</div></div>
    <div class="info-cell"><div class="info-lbl">Data do Laudo</div><div class="info-val">$dataLaudo</div></div>
    <div class="info-cell"><div class="info-lbl">Recomendacao</div><div class="info-val">${_fmtDateTime(gerada)}</div></div>
  </div>
</div>''';
  }

  static String _sectionDiagnostico(ResultadoRecomendacao r) {
    final a = r.analise;
    final ctc = a.ctc > 0 ? a.ctc : 1.0;
    double pct(double v) => (v / ctc * 100).clamp(0.0, 100.0);
    final eixos = DisponibilidadeNutrientesCalculator.calcular(a.ph);
    final alPct = pct(a.al);

    return '''
<div class="section">
  <div class="section-num">01 · Diagnostico</div>
  <div class="section-title">Qualidade do Solo</div>
  <div class="section-desc">Visao integrada da fertilidade e ocupacao da CTC.</div>
  <div class="big-card">
    <div style="font-size:11px;font-weight:600;color:var(--ink3);text-transform:uppercase;letter-spacing:.6px;margin-bottom:14px;">Disponibilidade de Nutrientes</div>
    <div style="font-size:13px;color:var(--ink3);margin-bottom:6px;">pH do solo: <strong style="color:var(--blue);font-size:16px;">${_fmt(a.ph, 1)}</strong> <span style="font-size:12px;">(CaCl2)</span></div>
    <div style="font-size:11px;color:var(--red);font-weight:500;margin-bottom:20px;">Al = Toxicidade — quanto maior, pior</div>
    <div class="radar-wrap">${_radarSvg(eixos)}</div>
  </div>
  <div class="big-card" style="margin-top:14px;">
    <div style="font-size:11px;font-weight:600;color:var(--ink3);text-transform:uppercase;letter-spacing:.6px;margin-bottom:8px;">Ocupacao da CTC</div>
    <div style="font-size:12px;color:var(--ink3);margin-bottom:18px;">Distribuicao dos cations na CTC do solo.</div>
    <div style="display:flex;gap:24px;align-items:center;flex-wrap:wrap;">
      <div style="flex-shrink:0;">${_barrelSvg(a, ctc)}</div>
      <div style="flex:1;min-width:200px;">
        ${_ctcBarRow('Calcio (Ca)', a.ca, pct(a.ca), false)}
        ${_ctcBarRow('Magnesio (Mg)', a.mg, pct(a.mg), false)}
        ${_ctcBarRow('Potassio (K)', a.k, pct(a.k), false)}
        ${_ctcBarRow('H + Al (acidez)', a.hAl, pct(a.hAl), true)}
        ${_ctcBarRow('Aluminio (Al)', a.al, alPct, true, showScale: false)}
      </div>
    </div>
    ${_ctcSummary(a, ctc, alPct)}
    ${_relacoesBases(a, ctc)}
  </div>
</div>''';
  }

  static String _radarSvg(List<DisponibilidadeEixo> eixos) {
    const maxR = 120.0;
    final points = <String>[];
    final labels = <String>[];

    for (var i = 0; i < eixos.length; i++) {
      final angle = -math.pi / 2 + i * math.pi / 3;
      final r = maxR * eixos[i].value / 100;
      final x = r * math.cos(angle);
      final y = r * math.sin(angle);
      points.add('${x.toStringAsFixed(1)},${y.toStringAsFixed(1)}');

      final lx = (maxR + 12) * math.cos(angle);
      final ly = (maxR + 12) * math.sin(angle);
      final anchor = lx.abs() < 8 ? 'middle' : (lx > 0 ? 'start' : 'end');
      final tx = lx + (lx > 0 ? 4 : (lx < 0 ? -4 : 0));
      labels.add('''
<text x="${tx.toStringAsFixed(1)}" y="${(ly - 6).toStringAsFixed(1)}" text-anchor="$anchor" font-size="11" font-weight="700" fill="${eixos[i].color}">${_esc(eixos[i].label)} ${_fmt(eixos[i].value, 0)}</text>
<text x="${tx.toStringAsFixed(1)}" y="${(ly + 6).toStringAsFixed(1)}" text-anchor="$anchor" font-size="9" fill="#86868B">${_esc(eixos[i].sublabel)}</text>''');
    }

    final dots = <String>[];
    for (var i = 0; i < eixos.length; i++) {
      final angle = -math.pi / 2 + i * math.pi / 3;
      final r = maxR * eixos[i].value / 100;
      final x = r * math.cos(angle);
      final y = r * math.sin(angle);
      dots.add(
          '<circle cx="${x.toStringAsFixed(1)}" cy="${y.toStringAsFixed(1)}" r="5" fill="${eixos[i].color}" stroke="#fff" stroke-width="2"/>');
    }

    return '''
<svg class="radar" width="300" height="300" viewBox="-150 -150 300 300">
  <polygon points="0,-120 103.9,-60 103.9,60 0,120 -103.9,60 -103.9,-60" fill="none" stroke="#E5E5E7" stroke-width="1"/>
  <polygon points="0,-90 77.9,-45 77.9,45 0,90 -77.9,45 -77.9,-45" fill="none" stroke="#E5E5E7" stroke-width="1"/>
  <polygon points="0,-60 52,-30 52,30 0,60 -52,30 -52,-30" fill="none" stroke="#E5E5E7" stroke-width="1"/>
  <polygon points="0,-30 26,-15 26,15 0,30 -26,15 -26,-15" fill="none" stroke="#E5E5E7" stroke-width="1"/>
  <line x1="0" y1="0" x2="0" y2="-120" stroke="#D1D1D6" stroke-width="1"/>
  <line x1="0" y1="0" x2="103.9" y2="-60" stroke="#D1D1D6" stroke-width="1"/>
  <line x1="0" y1="0" x2="103.9" y2="60" stroke="#D1D1D6" stroke-width="1"/>
  <line x1="0" y1="0" x2="0" y2="120" stroke="#D1D1D6" stroke-width="1"/>
  <line x1="0" y1="0" x2="-103.9" y2="60" stroke="#D1D1D6" stroke-width="1"/>
  <line x1="0" y1="0" x2="-103.9" y2="-60" stroke="#D1D1D6" stroke-width="1"/>
  <polygon points="${points.join(' ')}" fill="rgba(0,122,255,0.12)" stroke="#007AFF" stroke-width="2" stroke-linejoin="round"/>
  ${dots.join('\n  ')}
  ${labels.join('\n  ')}
</svg>''';
  }

  static String _barrelSvg(dynamic a, double ctc) {
    final pctCa = (a.ca / ctc * 100).clamp(0.0, 100.0);
    final pctMg = (a.mg / ctc * 100).clamp(0.0, 100.0);
    final pctK = (a.k / ctc * 100).clamp(0.0, 100.0);
    final pctHAl = (a.hAl / ctc * 100).clamp(0.0, 100.0);
    const h = 210.0;
    final hCa = h * pctCa / 100;
    final hMg = h * pctMg / 100;
    final hK = h * pctK / 100;
    final hRed = h * pctHAl / 100;
    var y = 235.0;
    y -= hRed;
    final yRed = y;
    y -= 2;
    final yOrange = y;
    y -= hK;
    final yK = y;
    y -= hMg;
    final yMg = y;
    y -= hCa;
    final yCa = y;

    return '''
<svg width="180" height="220" viewBox="0 0 220 260">
  <defs><clipPath id="bClip"><path d="M50,25 C20,75 20,185 50,235 L170,235 C200,185 200,75 170,25 Z"/></clipPath></defs>
  <ellipse cx="110" cy="248" rx="65" ry="10" fill="rgba(0,0,0,.06)"/>
  <path d="M50,25 C20,75 20,185 50,235 L170,235 C200,185 200,75 170,25 Z" fill="#F0F0F2" stroke="#C8C8CC" stroke-width="2"/>
  <g clip-path="url(#bClip)">
    <rect x="15" y="$yRed" width="190" height="$hRed" fill="#FF3B30" opacity=".85"/>
    <rect x="15" y="$yOrange" width="190" height="2" fill="#FF9500" opacity=".9"/>
    <rect x="15" y="$yK" width="190" height="$hK" fill="#FFD60A" opacity=".9"/>
    <rect x="15" y="$yMg" width="190" height="$hMg" fill="#34C759" opacity=".9"/>
    <rect x="15" y="$yCa" width="190" height="$hCa" fill="#007AFF" opacity=".9"/>
  </g>
  <path d="M50,25 C20,75 20,185 50,235 L170,235 C200,185 200,75 170,25 Z" fill="none" stroke="#B0B0B4" stroke-width="2"/>
  <ellipse cx="110" cy="25" rx="60" ry="16" fill="#E8E8EC" stroke="#C0C0C4" stroke-width="1.5"/>
  <ellipse cx="110" cy="235" rx="60" ry="16" fill="#D4D4D8" stroke="#B8B8BC" stroke-width="1.5"/>
  <text x="110" y="138" text-anchor="middle" font-size="28" font-weight="700" fill="#fff" style="text-shadow:0 1px 4px rgba(0,0,0,.3);">${_fmt(a.vPercent, 0)}%</text>
  <text x="110" y="155" text-anchor="middle" font-size="10" font-weight="500" fill="rgba(255,255,255,.85)">V% atual</text>
</svg>''';
  }

  static String _ctcBarRow(
    String nome,
    double mmolc,
    double pctVal,
    bool inverted, {
    bool showScale = true,
  }) {
    final grad = inverted
        ? 'linear-gradient(90deg,#34C759 0%,#FFD60A 25%,#FF9500 50%,#FF3B30 75%,#C62828 100%)'
        : 'linear-gradient(90deg,#FF3B30 0%,#FF9500 25%,#FFD60A 50%,#34C759 75%,#007AFF 100%)';
    final scale = showScale && inverted
        ? '<div style="display:flex;justify-content:space-between;font-size:9px;color:var(--ink4);margin-top:4px;font-weight:500;"><span>Baixo</span><span>Medio</span><span>Alto</span></div>'
        : '';
    return '''
<div style="margin-bottom:14px;">
  <div style="display:flex;justify-content:space-between;align-items:baseline;margin-bottom:4px;">
    <span style="font-size:13px;font-weight:600;color:var(--ink);">${_esc(nome)}</span>
    <span style="font-size:12px;color:var(--ink3);">${_fmt(mmolc, 1)} mmolc · <strong style="color:var(--ink);">${_fmt(pctVal, 1)}%</strong></span>
  </div>
  <div style="position:relative;height:10px;border-radius:5px;background:$grad;">
    <div style="position:absolute;top:50%;left:${pctVal.toStringAsFixed(1)}%;transform:translate(-50%,-50%);width:16px;height:16px;background:#1D1D1F;border:3px solid #fff;border-radius:50%;box-shadow:0 1px 4px rgba(0,0,0,.25);"></div>
  </div>
  $scale
</div>''';
  }

  static String _ctcSummary(dynamic a, double ctc, double alPct) {
    String vColor(double v) {
      if (v < 40) return '#FF3B30';
      if (v < 60) return '#FF9500';
      return '#34C759';
    }

    final vCor = vColor(a.vPercent);
    final alColor =
        alPct < 5 ? '#34C759' : (alPct < 15 ? '#FF9500' : '#FF3B30');

    return '''
<div style="display:grid;grid-template-columns:repeat(4,1fr);gap:8px;margin-top:24px;">
  <div style="background:var(--bg);border:1px solid #E0F0E0;border-radius:10px;padding:10px 8px;text-align:center;">
    <div style="font-size:10px;color:var(--ink3);font-weight:600;text-transform:uppercase;letter-spacing:.4px;margin-bottom:3px;">SB</div>
    <div style="font-size:18px;font-weight:700;color:var(--ink);">${_fmt(a.sb, 2)}</div>
    <div style="font-size:9px;color:var(--ink4);">cmolc/dm3</div>
  </div>
  <div style="background:var(--bg);border:1px solid #D4EAF8;border-radius:10px;padding:10px 8px;text-align:center;">
    <div style="font-size:10px;color:var(--blue);font-weight:600;text-transform:uppercase;letter-spacing:.4px;margin-bottom:3px;">CTC</div>
    <div style="font-size:18px;font-weight:700;color:var(--blue);">${_fmt(ctc, 2)}</div>
    <div style="font-size:9px;color:var(--ink4);">cmolc/dm3</div>
  </div>
  <div style="background:#E8F5E9;border:1px solid #C8E6C9;border-radius:10px;padding:10px 8px;text-align:center;">
    <div style="font-size:10px;color:var(--ink3);font-weight:600;text-transform:uppercase;letter-spacing:.4px;margin-bottom:3px;">V%</div>
    <div style="font-size:18px;font-weight:700;color:$vCor;">${_fmt(a.vPercent, 0)}%</div>
  </div>
  <div style="background:#E8F5E9;border:1px solid #C8E6C9;border-radius:10px;padding:10px 8px;text-align:center;">
    <div style="font-size:10px;color:var(--ink3);font-weight:600;text-transform:uppercase;letter-spacing:.4px;margin-bottom:3px;">Al%</div>
    <div style="font-size:18px;font-weight:700;color:$alColor;">${_fmt(alPct, 0)}%</div>
  </div>
</div>''';
  }

  static String _relacoesBases(dynamic a, double ctc) {
    final relCaMg = a.mg > 0 ? a.ca / a.mg : 0.0;
    final relCaK = a.k > 0 ? a.ca / a.k : 0.0;
    final relMgK = a.k > 0 ? a.mg / a.k : 0.0;

    String relCell(String label, double val, String faixa) {
      final cor = _relacaoColor(label, val);
      return '''
<div style="text-align:center;">
  <div style="font-size:10px;color:var(--ink3);margin-bottom:4px;">$label</div>
  <div style="font-size:20px;font-weight:700;color:$cor;">${_fmt(val, 1)}</div>
  <div style="font-size:9px;color:var(--ink4);border-top:2px solid $cor;display:inline-block;padding-top:3px;margin-top:3px;">$faixa</div>
</div>''';
    }

    return '''
<div style="margin-top:20px;">
  <div style="font-size:11px;font-weight:600;color:var(--ink3);text-transform:uppercase;letter-spacing:.6px;margin-bottom:12px;">Relacoes de Bases</div>
  <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:10px;">
    ${relCell('Ca/Mg', relCaMg, '3–5')}
    ${relCell('Ca/K', relCaK, '10–30')}
    ${relCell('Mg/K', relMgK, '3–10')}
  </div>
</div>''';
  }

  static String _relacaoColor(String label, double val) {
    if (label == 'Ca/Mg') {
      if (val >= 3 && val <= 5) return '#34C759';
      if (val < 3) return '#FF9500';
      return '#FF3B30';
    }
    if (label == 'Ca/K') {
      if (val >= 10 && val <= 30) return '#34C759';
      if (val < 10) return '#FF9500';
      return '#FF3B30';
    }
    if (label == 'Mg/K') {
      if (val >= 3 && val <= 10) return '#34C759';
      if (val < 3) return '#FF9500';
      return '#FF3B30';
    }
    return '#86868B';
  }

  static String _sectionCalcario(ResultadoRecomendacao r) {
    final a = r.analise;
    final corr = _corretivos(r);
    final c1 = corr['calcario1'] is Map ? corr['calcario1'] as Map : {};
    final caO = _num(c1['caO'], 30);
    final mgO = _num(c1['mgO'], 16);
    final prnt = _num(c1['prnt'], 80);
    final temDose = r.doseCalcarioTHa > 0;

    final parc = r.parcelamento.map(_parseParcelRow).join();

    return '''
<div class="section">
  <div class="section-num">02 · Correcao</div>
  <div class="section-title">Calcario</div>
  <div class="section-desc">Calagem para elevar V% e equilibrar Ca/Mg do solo.</div>
  <div class="big-card">
    <div class="metric-hero">
      <span class="metric-num" style="color:var(--blue);">${temDose ? _fmt(r.doseCalcarioTHa, 2) : '—'}</span>
      <span class="metric-unit">t/ha</span>
    </div>
    <div class="vrow">
      <div class="vrow-item"><div class="vrow-lbl">V% Atual</div><div class="vrow-num" style="color:var(--red);">${_fmt(a.vPercent, 0)}%</div></div>
      <div style="color:var(--ink4);font-size:22px;flex-shrink:0;">→</div>
      <div class="vrow-item"><div class="vrow-lbl">V% Esperado</div><div class="vrow-num" style="color:var(--green);">${_fmt(r.vEsperado, 0)}%</div></div>
    </div>
    <div class="kv-list">
      <div class="kv"><span class="kv-l">Calcio (Ca)</span><span class="kv-v">${_fmt(a.ca, 2)} <span class="kv-arrow">→</span> ${_fmt(r.caEsperado, 2)} <span style="font-weight:400;color:var(--ink3);font-size:11px;">cmolc/dm3</span></span></div>
      <div class="kv"><span class="kv-l">Magnesio (Mg)</span><span class="kv-v">${_fmt(a.mg, 2)} <span class="kv-arrow">→</span> ${_fmt(r.mgEsperado, 2)} <span style="font-weight:400;color:var(--ink3);font-size:11px;">cmolc/dm3</span></span></div>
      <div class="kv"><span class="kv-l">Relacao Ca : Mg</span><span class="kv-v">${_fmt(r.relacaoCaMg, 1)} : 1</span></div>
    </div>
    <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:10px;margin-top:18px;">
      <div style="background:var(--bg);border-radius:10px;padding:14px 10px;text-align:center;"><div style="font-size:10px;color:var(--ink3);margin-bottom:4px;">CaO</div><div style="font-size:22px;font-weight:700;color:var(--blue);">${_fmt(caO, 0)}%</div></div>
      <div style="background:var(--bg);border-radius:10px;padding:14px 10px;text-align:center;"><div style="font-size:10px;color:var(--ink3);margin-bottom:4px;">MgO</div><div style="font-size:22px;font-weight:700;color:var(--green);">${_fmt(mgO, 0)}%</div></div>
      <div style="background:var(--bg);border-radius:10px;padding:14px 10px;text-align:center;"><div style="font-size:10px;color:var(--ink3);margin-bottom:4px;">PRNT</div><div style="font-size:22px;font-weight:700;color:var(--ink2);">${_fmt(prnt, 0)}%</div></div>
    </div>
    ${r.parcelamento.isNotEmpty ? '<div class="parc"><div class="parc-head">Parcelamento</div>$parc</div>' : ''}
  </div>
</div>''';
  }

  static String _parseParcelRow(String row) {
    final mesMatch = RegExp(r'—\s*(.+)$').firstMatch(row);
    final mes = mesMatch?.group(1)?.trim() ?? '';
    final pctMatch = RegExp(r'(\d+)%').firstMatch(row);
    final pct = pctMatch?.group(1) ?? '';
    final doseMatch = RegExp(r'=\s*([\d\.]+)\s*t/ha').firstMatch(row);
    final dose = doseMatch?.group(1)?.replaceAll('.', ',') ?? '';
    final appMatch = RegExp(r'^(Aplicação \d+|Aplicacao \d+)').firstMatch(row);
    final app = appMatch?.group(1) ?? 'Aplicacao';
    return '''
<div class="parc-row"><span><strong>${_esc(app)}</strong>${mes.isNotEmpty ? ' <span style="color:var(--ink3);">· ${_esc(mes)}</span>' : ''}</span><span><span class="parc-pct">$pct%</span> = $dose t/ha</span></div>''';
  }

  static String _sectionProjecao(ResultadoRecomendacao r) {
    final a = r.analise;
    final grupos = [
      ('Ca', a.ca, r.caEsperado, 'cmolc'),
      ('Mg', a.mg, r.mgEsperado, 'cmolc'),
      ('K', a.k, a.k, 'cmolc'),
      ('V%', a.vPercent, r.vEsperado, '%'),
    ];

    final maxVal = grupos
        .expand((g) => [g.$2, g.$3])
        .fold<double>(0.001, (m, v) => v > m ? v : m);

    String barGroup((String, double, double, String) g) {
      const maxH = 110.0;
      final hAntes = (g.$2 / maxVal * maxH).clamp(4.0, maxH);
      final hDepois = (g.$3 / maxVal * maxH).clamp(4.0, maxH);
      String fmtVal(double v) {
        if (g.$4 == '%') return '${_fmt(v, 0)}%';
        if (g.$1 == 'K') return _fmt(v, 2);
        return _fmt(v, 1);
      }

      return '''
<div class="ba-group"><div class="ba-bars-pair">
  <div class="ba-bar" style="background:#FF9500;height:${hAntes.toStringAsFixed(0)}px;"><div class="ba-val">${fmtVal(g.$2)}</div></div>
  <div class="ba-bar" style="background:#34C759;height:${hDepois.toStringAsFixed(0)}px;"><div class="ba-val">${fmtVal(g.$3)}</div></div>
</div><div class="ba-name">${g.$1}</div></div>''';
    }

    return '''
<div class="section">
  <div class="section-num">03 · Projecao</div>
  <div class="section-title">Antes e Depois da Correcao</div>
  <div class="section-desc">Valores projetados apos aplicacao do calcario recomendado.</div>
  <div class="big-card">
    <div class="ba-legend">
      <span><span class="ba-dot" style="background:#FF9500;"></span> Antes</span>
      <span><span class="ba-dot" style="background:#34C759;"></span> Depois</span>
    </div>
    <div class="ba">${grupos.map(barGroup).join()}</div>
    <div class="ba-note">* K calculado separadamente — sem alteracao via calagem</div>
  </div>
</div>''';
  }

  static String _sectionFosforo(ResultadoRecomendacao r) {
    final a = r.analise;
    final p = a.p;
    final nc = r.ncFosforo;
    final rotulo = ClassificacaoNivel.classificar(
      nutriente: 'p',
      valor: p,
      argila: a.argila,
    );
    final pRelNc = nc > 0 ? (p / nc * 100).clamp(0.0, 150.0) : 0.0;
    final gradPct = _gradPct('p', p, argila: a.argila);
    final cor = _nutrientColor(p, nc);
    final pillText =
        nc > 0 && p >= nc ? '$rotulo · ${_fmt(pRelNc, 0)}% NC' : rotulo;
    final warn = r.legacyP
        ? _warn(
            'Fosforo acima do NC — aplicado <strong>piso de manutencao</strong>.')
        : '';

    return '''
<div class="section">
  <div class="section-num">04 · Macronutriente</div>
  <div class="section-title">Fosforo (P)</div>
  <div class="section-desc">Extrator Mehlich · Modo ${_esc(r.modoFosforo)} · ${_esc(_referenciaFosforo(r))}.</div>
  <div class="big-card">
    <div class="metric-hero">
      <span class="metric-num" style="color:$cor;">${_fmt(p, 2)}</span>
      <span class="metric-unit">mg/dm3</span>
      <span style="margin-left:auto;padding-bottom:8px;">${_pill(pillText)}</span>
    </div>
    ${_gradBar(gradPct, [
          'Muito Baixo',
          'Baixo',
          'Medio',
          'Alto',
          'Muito Alto'
        ])}
    <div class="kv-list" style="margin-top:18px;">
      <div class="kv"><span class="kv-l">Nivel Critico (NC)</span><span class="kv-v">${_fmt(nc, 2)} mg/dm3</span></div>
      <div class="kv"><span class="kv-l">Modo de calculo</span><span class="kv-v">${_esc(r.modoFosforo)}</span></div>
      <div class="kv"><span class="kv-l">Referencia tecnica</span><span class="kv-v">${_esc(_referenciaFosforo(r))}</span></div>
    </div>
    ${_doseBlock('Dose recomendada', _fmt(r.doseP2O5KgHa, 1), 'kg P2O5 / ha', cor)}
    ${warn.isNotEmpty ? '<div style="margin-top:14px;">$warn</div>' : ''}
  </div>
</div>''';
  }

  static String _sectionPotassio(ResultadoRecomendacao r) {
    final a = r.analise;
    final k = a.k;
    final kMg = k * 391.0;
    final nc = r.ncPotassio;
    final rotulo = ClassificacaoNivel.classificar(nutriente: 'k', valor: k);
    final gradPct = _gradPct('k', k);
    final rel = r.relacoesK;

    return '''
<div class="section">
  <div class="section-num">05 · Macronutriente</div>
  <div class="section-title">Potassio (K)</div>
  <div class="section-desc">Criterio "${_esc(r.criterioPotassio)}" · ${_esc(_referenciaFosforo(r))}.</div>
  <div class="big-card">
    <div class="metric-hero">
      <span class="metric-num" style="color:var(--orange);">${_fmt(k, 2)}</span>
      <span class="metric-unit">cmolc/dm3</span>
      <span style="margin-left:auto;padding-bottom:8px;">${_pill(rotulo)}</span>
    </div>
    <div style="font-size:13px;color:var(--ink3);margin-bottom:4px;">${_fmt(kMg, 0)} mg/dm3</div>
    ${_gradBar(gradPct, [
          'Muito Baixo',
          'Baixo',
          'Medio',
          'Alto',
          'Muito Alto'
        ])}
    <div class="kv-list" style="margin-top:18px;">
      <div class="kv"><span class="kv-l">Nivel Critico (NC)</span><span class="kv-v">${_fmt(nc, 2)} cmolc/dm3</span></div>
      <div class="kv"><span class="kv-l">Criterio</span><span class="kv-v">${_esc(r.criterioPotassio)}</span></div>
      <div class="kv"><span class="kv-l">Referencia tecnica</span><span class="kv-v">${_esc(_referenciaFosforo(r))}</span></div>
    </div>
    ${_doseBlock('Dose recomendada', _fmt(r.doseK2OKgHa, 1), 'kg K2O / ha', 'var(--orange)')}
    <div style="margin-top:18px;">
      <div style="font-size:11px;font-weight:600;color:var(--ink3);text-transform:uppercase;letter-spacing:.6px;margin-bottom:10px;">Relacoes ionicas</div>
      <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:10px;">
        <div style="background:var(--bg);border-radius:10px;padding:14px 10px;text-align:center;"><div style="font-size:10px;color:var(--ink3);margin-bottom:4px;">K % CTC</div><div style="font-size:20px;font-weight:700;color:var(--orange);">${_fmt(rel.kNaCTC, 1)}%</div></div>
        <div style="background:var(--bg);border-radius:10px;padding:14px 10px;text-align:center;"><div style="font-size:10px;color:var(--ink3);margin-bottom:4px;">K : Mg</div><div style="font-size:20px;font-weight:700;color:var(--ink2);">${_fmt(rel.relKMg, 2)}</div></div>
        <div style="background:var(--bg);border-radius:10px;padding:14px 10px;text-align:center;"><div style="font-size:10px;color:var(--ink3);margin-bottom:4px;">K : Ca</div><div style="font-size:20px;font-weight:700;color:var(--ink2);">${_fmt(rel.relKCa, 2)}</div></div>
      </div>
    </div>
  </div>
</div>''';
  }

  static String _sectionEnxofre(ResultadoRecomendacao r) {
    final a = r.analise;
    final s = a.s;
    final rotulo = ClassificacaoNivel.classificar(nutriente: 's', valor: s);
    final gradPct = _gradPct('s', s);
    final dose = _doseEnxofre(s);
    final temS2040 = a.s2040 != null;
    final desc = temS2040
        ? 'Camada 0-20 cm · analisado nesta amostra.'
        : 'Camada 0-20 cm · nao analisado nesta amostra.';
    final warnText = s < 10
        ? 'Nivel muito baixo — aplicar <strong>enxofre elementar</strong> ou sulfato.${temS2040 ? '' : ' Camada 20-40 cm nao disponivel nesta analise.'}'
        : '';

    return '''
<div class="section">
  <div class="section-num">06 · Macronutriente Secundario</div>
  <div class="section-title">Enxofre (S)</div>
  <div class="section-desc">$desc</div>
  <div class="big-card">
    <div class="metric-hero">
      <span class="metric-num" style="color:var(--red);">${_fmt(s, 1)}</span>
      <span class="metric-unit">mg/dm3</span>
      <span style="margin-left:auto;padding-bottom:8px;">${_pill(rotulo)}</span>
    </div>
    ${_gradBar(gradPct, [
          'Muito Baixo',
          'Baixo',
          'Medio',
          'Alto',
          'Muito Alto'
        ])}
    ${_doseBlock('Dose recomendada', _fmt(dose, 0), 'kg S / ha', 'var(--red)')}
    ${warnText.isNotEmpty ? '<div style="margin-top:14px;">${_warn(warnText)}</div>' : ''}
  </div>
</div>''';
  }

  static double _doseEnxofre(double s) {
    if (s < 10) return 20.0;
    if (s < 20) return 10.0;
    return 0.0;
  }

  static String _sectionMicros(ResultadoRecomendacao r) {
    if (r.micros.isEmpty) {
      return '''
<div class="section">
  <div class="section-num">07 · Micronutrientes</div>
  <div class="section-title">Micronutrientes</div>
  <div class="section-desc">Cada elemento avaliado contra seu NC · doses Solo (primeiro) e Foliar.</div>
  <div class="big-card"><p style="color:var(--ink3);">Sem micronutrientes calculados.</p></div>
</div>''';
    }

    final cards = r.micros.map(_microCard).join();

    return '''
<div class="section">
  <div class="section-num">07 · Micronutrientes</div>
  <div class="section-title">Micronutrientes</div>
  <div class="section-desc">Cada elemento avaliado contra seu NC · doses Solo (primeiro) e Foliar.</div>
  <div class="big-card">$cards</div>
</div>''';
  }

  static String _microCard(MicroResultado m) {
    final nome = _microNome(m.elemento);
    final cor = _microCor(m.elemento);
    final status = m.deficiente ? 'Deficiente' : 'Adequado';
    final pillClass = m.deficiente ? 'pill-red' : 'pill-green';
    final gradPct = _microGradPct(m.valorAtual, m.nc);
    final ncLabel = 'NC ${_fmt(m.nc, m.nc < 1 ? 2 : 1)}';
    final warns = m.avisosNutriente
        .map((w) => '<div class="micro-warn">${_esc(w)}</div>')
        .join();
    final solo = _microColuna(m, true);
    final foliar = _microColuna(m, false);

    return '''
<div class="micro-card">
  <div class="micro-head">
    <div class="micro-dot" style="background:$cor;"></div>
    <div class="micro-name">$nome</div>
    <span class="micro-status-pill"><span class="pill $pillClass">$status</span></span>
    <div class="micro-val">${_fmt(m.valorAtual, 2)} <span class="u">mg/dm3</span></div>
  </div>
  <div class="micro-nc">NC: ${_fmt(m.nc, 2)} mg/dm3</div>
  <div class="grad-bar"><div class="grad-marker" style="left:${gradPct.toStringAsFixed(1)}%;"></div></div>
  <div class="grad-scale"><span>Def.</span><span>Baixo</span><span>$ncLabel</span><span>Adequado</span><span>Alto</span></div>
  $warns
  <div class="micro-doses">
    <div class="micro-dose"><div class="micro-dose-l">Solo</div><div class="micro-dose-v${solo.$2}">${solo.$1}</div></div>
    <div class="micro-dose"><div class="micro-dose-l">Foliar</div><div class="micro-dose-v${foliar.$2}">${foliar.$1}</div></div>
  </div>
</div>''';
  }

  static (String, String) _microColuna(MicroResultado m, bool solo) {
    final via = m.via.toLowerCase();
    final naoAnalisado = m.avisosNutriente.any(
      (a) =>
          a.toLowerCase().contains('nao analisado') ||
          a.toLowerCase().contains('não analisado') ||
          a.toLowerCase().contains('sem teor'),
    );

    if (naoAnalisado || m.doseProdutoLabel == 'Não analisado') {
      return ('Nao analisado', ' na');
    }

    final viaAtiva = solo
        ? via.contains('solo') || via.contains('ambas')
        : via.contains('foliar') || via.contains('ambas');

    if (!viaAtiva) {
      return ('Via nao ativa', ' na');
    }

    if (m.dose <= 0 && !m.deficiente) {
      return ('Nivel adequado', ' na');
    }

    if (m.dose > 0 && m.doseProdutoLabel.isNotEmpty) {
      return (m.doseProdutoLabel, '');
    }

    return ('Via nao ativa', ' na');
  }

  static String _microNome(String el) {
    const names = {
      'B': 'Boro (B)',
      'Cu': 'Cobre (Cu)',
      'Mn': 'Manganes (Mn)',
      'Zn': 'Zinco (Zn)',
      'Fe': 'Ferro (Fe)',
      'Mo': 'Molibdenio (Mo)',
      'Co': 'Cobalto (Co)',
      'Ni': 'Niquel (Ni)',
      'Se': 'Selenio (Se)',
    };
    return names[el] ?? el;
  }

  static String _microCor(String el) {
    const cores = {
      'Se': '#34C759',
      'Ni': '#1D1D1F',
      'Co': '#8E8E93',
      'Mn': '#AF52DE',
      'B': '#FFD60A',
      'Cu': '#FF9500',
      'Zn': '#007AFF',
      'Fe': '#A52A2A',
      'Mo': '#5856D6',
    };
    return cores[el] ?? '#8E8E93';
  }

  static String _sectionAvisos(ResultadoRecomendacao r) {
    final warns = r.avisos.isEmpty
        ? '<div class="warn">Sem avisos tecnicos para esta recomendacao.</div>'
        : r.avisos.map((a) => _warn(_esc(a))).join();

    return '''
<div class="section">
  <div class="section-num">08 · Atencao</div>
  <div class="section-title">Avisos Tecnicos</div>
  <div class="section-desc">Pontos que afetam a precisao do calculo ou exigem manejo cuidadoso.</div>
  <div class="big-card">$warns</div>
</div>''';
  }

  static String _footer(DateTime gerada, String consultor) => '''
<div class="footer">
  <strong>SoloForte · Caderno de Solo</strong><br>
  Gerado em ${_fmtDate(gerada)} as ${gerada.hour.toString().padLeft(2, '0')}:${gerada.minute.toString().padLeft(2, '0')} · ${_esc(consultor)}<br>
  <span style="font-size:10px;">Documento tecnico de uso exclusivo. Consulte sempre um Engenheiro Agronomo habilitado.</span>
</div>''';

  static String _nutrientColor(double valor, double nc) {
    if (nc <= 0) return '#34C759';
    final rel = valor / nc * 100;
    if (rel < 40) return '#FF3B30';
    if (rel < 70) return '#FF9500';
    if (rel < 100) return '#FFCC00';
    return '#34C759';
  }
}
