import 'dart:developer';

import 'package:soloforte/core/utils/safra_utils.dart';
import 'package:soloforte/data/lab_templates/ibra_template.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';

class IbraImportService {
  const IbraImportService();

  List<AnaliseSolo> fromJson(Map<String, dynamic> json) {
    final amostras = json['amostras'];
    if (amostras is! List) {
      log('Campo "amostras" ausente ou inválido no JSON IBRA.');
      return const [];
    }

    final result = <AnaliseSolo>[];
    for (final a in amostras.whereType<Map<String, dynamic>>()) {
      try {
        result.add(_mapAmostra(a, json));
      } catch (e, st) {
        log('Erro ao mapear amostra no IBRA: $e', error: e, stackTrace: st);
      }
    }
    return result;
  }

  AnaliseSolo _mapAmostra(
    Map<String, dynamic> amostra,
    Map<String, dynamic> laudo,
  ) {
    dynamic raw(String key) {
      if (!amostra.containsKey(key)) {
        log('Campo esperado ausente no JSON IBRA: $key');
        return null;
      }
      return amostra[key];
    }

    double? toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v.replaceAll(',', '.'));
      return null;
    }

    Cultura parseCultura(String? culturaStr) {
      if (culturaStr == null) return Cultura.soja;
      final lower = culturaStr.toLowerCase();
      if (lower.contains('milho')) return Cultura.milho;
      if (lower.contains('feijão') || lower.contains('feijao')) {
        return Cultura.feijao;
      }
      if (lower.contains('algodão') || lower.contains('algodao')) {
        return Cultura.algodao;
      }
      if (lower.contains('arroz')) return Cultura.arroz;
      if (lower.contains('sorgo')) return Cultura.sorgo;
      return Cultura.soja;
    }

    // ─── Conversões obrigatórias ─────────────────────────────────────
    // K, Ca, Mg, Al, H+Al: mmolc/dm³ → cmolc/dm³ (÷ 10)
    final kCmolc = (toDouble(raw('k_mmolc')) ?? 0.0) / 10.0;
    final caCmolc = (toDouble(raw('ca_mmolc')) ?? 0.0) / 10.0;
    final mgCmolc = (toDouble(raw('mg_mmolc')) ?? 0.0) / 10.0;
    final alCmolc = (toDouble(raw('al_mmolc')) ?? 0.0) / 10.0;
    final halCmolc = (toDouble(raw('hMaisAl_mmolc')) ?? 0.0) / 10.0;

    // M.O. e COT: g/dm³ → dag/kg (÷ 10)
    final moDagKg = toDouble(raw('mo_gdm3')) != null
        ? toDouble(raw('mo_gdm3'))! / 10.0
        : null;
    final cotDagKg = toDouble(raw('cot_gdm3')) != null
        ? toDouble(raw('cot_gdm3'))! / 10.0
        : null;

    final metadata = <String, dynamic>{
      'fonte': laudo['fonte'],
      'os': laudo['os'],
      'dataEmissao': laudo['dataEmissao'],
      'propriedade': laudo['propriedade'],
      'municipio': laudo['municipio'],
      'responsavel': laudo['responsavel'],
      'groupId': laudo['groupId'],
      'groupTitle': laudo['groupTitle'],
      'importedAt': laudo['importedAt'],
      'sourceFileName': laudo['sourceFileName'],
    };

    final id =
        '${laudo['os'] ?? 'ibra'}-${raw('numeroAmostra') ?? DateTime.now().millisecondsSinceEpoch}';

    final dataCadastro =
        DateTime.tryParse((laudo['dataEmissao'] ?? '').toString()) ??
            DateTime.now();

    return AnaliseSolo(
      id: id,
      fazenda: (laudo['propriedade'] ?? '') as String,
      produtor: (laudo['proprietario'] ?? laudo['responsavel'] ?? '') as String,
      talhao: (raw('talhao') ?? '') as String,
      numeroAmostra: (raw('numeroAmostra') ?? '') as String,
      cultura: parseCultura((laudo['cultura'] ?? raw('cultura'))?.toString()),
      safra: calcularSafra(dataCadastro),
      laboratorio: ibraLabInfo.nome,
      dataCadastro: dataCadastro,
      profundidade: _normalizarProfundidade(raw('profundidade')),
      descricaoLocal: laudo['propriedade'] as String?,
      argila: toDouble(raw('argila')),
      silte: toDouble(raw('silte')),
      areiaTotal: toDouble(raw('areiaTotal')),
      phAgua: null,
      phSmp: toDouble(raw('phSmp')),
      phCaCl2: toDouble(raw('phCaCl2')),
      materiaOrganica: moDagKg,
      carbonoOrganico: cotDagKg,
      pMehlich: null, // IBRA usa Resina (IAC)
      pResina: toDouble(raw('pResina')),
      pRem: toDouble(raw('pRem')),
      s020: toDouble(raw('s020')),
      s2040: null,
      k: kCmolc,
      ca: caCmolc,
      mg: mgCmolc,
      al: alCmolc,
      hMaisAl: halCmolc,
      na: null,
      b: toDouble(raw('b')),
      cu: toDouble(raw('cu')),
      fe: toDouble(raw('fe')),
      mn: toDouble(raw('mn')),
      zn: toDouble(raw('zn')),
      ni: null,
      mo: null,
      se: null,
      laudoMetadata: metadata,
    );
  }

  String _normalizarProfundidade(dynamic raw) {
    final original = raw?.toString().trim() ?? '';
    if (original.isEmpty) return '0-20';

    var cleaned = original.toLowerCase();
    cleaned = cleaned.replaceAll('cm', '');
    cleaned = cleaned.replaceAll(RegExp(r'[–—−]'), '-');
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();

    final rangeMatch =
        RegExp(r'(\d{1,3})\s*[-/]\s*(\d{1,3})').firstMatch(cleaned);
    if (rangeMatch != null) {
      return '${rangeMatch.group(1)}-${rangeMatch.group(2)}';
    }

    final wordRangeMatch = RegExp(
      r'(\d{1,3})\s*(a|ate|até|to)\s*(\d{1,3})',
      caseSensitive: false,
    ).firstMatch(cleaned);
    if (wordRangeMatch != null) {
      return '${wordRangeMatch.group(1)}-${wordRangeMatch.group(3)}';
    }

    final single = RegExp(r'\d{1,3}').firstMatch(cleaned)?.group(0);
    if (single != null) {
      return '0-$single';
    }

    return original;
  }
}
