import 'dart:developer';

import 'package:soloforte/core/utils/safra_utils.dart';
import 'package:soloforte/data/lab_templates/mb_template.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';

class MbImportService {
  const MbImportService();

  List<AnaliseSolo> fromJson(Map<String, dynamic> json) {
    final amostras = json['amostras'];
    if (amostras is! List) {
      log('Campo "amostras" ausente ou inválido no JSON MB Agronegócios.');
      return const [];
    }

    final result = <AnaliseSolo>[];
    for (final a in amostras.whereType<Map<String, dynamic>>()) {
      try {
        result.add(_mapAmostra(a, json));
      } catch (e, st) {
        log('Erro ao mapear amostra no MB Agronegócios: $e',
            error: e, stackTrace: st);
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
        log('Campo esperado ausente no JSON MB: $key');
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

    // ─── Conversões obrigatórias ─────────────────────────────────────
    // K: mg/dm³ → cmolc/dm³ (÷ 391)
    final kCmolc = (toDouble(raw('k_mgdm3')) ?? 0.0) / 391.0;

    // Carbono: g/dm³ → dag/kg (÷ 10)
    final carbonoDagKg = toDouble(raw('carbono_gdm3')) != null
        ? toDouble(raw('carbono_gdm3'))! / 10.0
        : null;

    // M.O.: % = dag/kg → sem conversão
    final moDagKg = toDouble(raw('mo_pct'));

    // Composição Física: % → g/kg (× 10)
    final argilaGkg = toDouble(raw('argila_pct')) != null
        ? toDouble(raw('argila_pct'))! * 10.0
        : null;
    final silteGkg = toDouble(raw('silte_pct')) != null
        ? toDouble(raw('silte_pct'))! * 10.0
        : null;
    final areiaGkg = toDouble(raw('areiaTotal_pct')) != null
        ? toDouble(raw('areiaTotal_pct'))! * 10.0
        : null;

    final metadata = <String, dynamic>{
      'fonte': laudo['fonte'],
      'analise': laudo['analise'],
      'dataEmissao': laudo['dataEmissao'],
      'propriedade': laudo['propriedade'],
      'municipio': laudo['municipio'],
      'groupId': laudo['groupId'],
      'groupTitle': laudo['groupTitle'],
      'importedAt': laudo['importedAt'],
      'sourceFileName': laudo['sourceFileName'],
    };

    final id =
        '${laudo['analise'] ?? 'mb'}-${raw('numeroAmostra') ?? DateTime.now().millisecondsSinceEpoch}';

    final dataCadastro =
        DateTime.tryParse((laudo['dataEmissao'] ?? '').toString()) ??
            DateTime.now();

    return AnaliseSolo(
      id: id,
      fazenda: (laudo['propriedade'] ?? '') as String,
      produtor: (laudo['proprietario'] ?? '') as String,
      talhao: (raw('talhao') ?? '') as String,
      numeroAmostra: (raw('numeroAmostra') ?? '') as String,
      cultura: Cultura.soja,
      safra: calcularSafra(dataCadastro),
      laboratorio: mbLabInfo.nome,
      dataCadastro: dataCadastro,
      profundidade: _normalizarProfundidade(raw('profundidade')),
      descricaoLocal: laudo['propriedade'] as String?,
      argila: argilaGkg,
      silte: silteGkg,
      areiaTotal: areiaGkg,
      phAgua: null,
      phSmp: null,
      phCaCl2: toDouble(raw('phCaCl2')),
      materiaOrganica: moDagKg,
      carbonoOrganico: carbonoDagKg,
      pMehlich: toDouble(raw('pMehlich')),
      pResina: toDouble(raw('pResina')),
      pRem: toDouble(raw('pRem')),
      s020: toDouble(raw('s020')),
      s2040: null,
      k: kCmolc,
      ca: toDouble(raw('ca')),
      mg: toDouble(raw('mg')),
      al: toDouble(raw('al')),
      hMaisAl: toDouble(raw('hMaisAl')),
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
