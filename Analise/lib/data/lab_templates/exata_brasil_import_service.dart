import 'dart:developer';

import 'package:soloforte/core/utils/safra_utils.dart';
import 'package:soloforte/data/lab_templates/exata_brasil_template.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';

class ExataBrasilImportService {
  const ExataBrasilImportService();

  List<AnaliseSolo> fromJson(Map<String, dynamic> json) {
    final amostras = json['amostras'];
    if (amostras is! List) {
      log('Campo "amostras" ausente ou inválido no JSON Exata Brasil.');
      return const [];
    }

    final result = <AnaliseSolo>[];
    for (final a in amostras.whereType<Map<String, dynamic>>()) {
      try {
        result.add(_mapAmostra(a, json));
      } catch (e, st) {
        log('Erro ao mapear amostra no Exata Brasil: $e',
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
        log('Campo esperado ausente no JSON Exata Brasil: $key');
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
    // K: mg/dm³ → cmolc/dm³
    final kMgDm3 = toDouble(raw('k_mgdm3'));
    final kCmolc = kMgDm3 != null ? kMgDm3 / 391.0 : toDouble(raw('k'));

    // M.O. e C.O.: g/dm³ → dag/kg (÷ 10)
    final moRaw = toDouble(raw('materiaOrganica'));
    final coRaw = toDouble(raw('carbonoOrganico'));
    final moDagKg = moRaw != null ? moRaw / 10.0 : null;
    final coDagKg = coRaw != null ? coRaw / 10.0 : null;

    final cuPrincipal = toDouble(raw('cu_dtpa')) ?? toDouble(raw('cu_meh'));
    final fePrincipal = toDouble(raw('fe_dtpa')) ?? toDouble(raw('fe_meh'));
    final mnPrincipal = toDouble(raw('mn_dtpa')) ?? toDouble(raw('mn_meh'));
    final znPrincipal = toDouble(raw('zn_dtpa')) ?? toDouble(raw('zn_meh'));

    final metadata = <String, dynamic>{
      'fonte': laudo['fonte'],
      'relatorio': laudo['relatorio'],
      'dataEmissao': laudo['dataEmissao'],
      'dataRecebimento': laudo['dataRecebimento'],
      'proprietario': laudo['proprietario'],
      'propriedade': laudo['propriedade'],
      'laboratorio': laudo['laboratorio'],
      'contato': laudo['contato'],
      'groupId': laudo['groupId'],
      'groupTitle': laudo['groupTitle'],
      'importedAt': laudo['importedAt'],
      'sourceFileName': laudo['sourceFileName'],
      'cu_meh': toDouble(raw('cu_meh')),
      'fe_meh': toDouble(raw('fe_meh')),
      'mn_meh': toDouble(raw('mn_meh')),
      'zn_meh': toDouble(raw('zn_meh')),
      'cu_dtpa': toDouble(raw('cu_dtpa')),
      'fe_dtpa': toDouble(raw('fe_dtpa')),
      'mn_dtpa': toDouble(raw('mn_dtpa')),
      'zn_dtpa': toDouble(raw('zn_dtpa')),
    };

    final id =
        '${laudo['relatorio'] ?? 'exata_brasil'}-${raw('numeroAmostra') ?? DateTime.now().millisecondsSinceEpoch}';

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
      laboratorio: exataBrasilLabInfo.nome,
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
      carbonoOrganico: coDagKg,
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
      na: toDouble(raw('na')),
      b: toDouble(raw('b')),
      cu: cuPrincipal,
      fe: fePrincipal,
      mn: mnPrincipal,
      zn: znPrincipal,
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
