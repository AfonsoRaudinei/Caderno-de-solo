import 'dart:developer';

import 'package:soloforte/domain/formulas/conversoes.dart';
import 'package:soloforte/core/utils/safra_utils.dart';
import 'package:soloforte/data/lab_templates/sellar_template.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';

class SellarImportService {
  const SellarImportService();

  List<AnaliseSolo> fromJson(Map<String, dynamic> json) {
    final amostras = json['amostras'];
    if (amostras is! List) {
      log('Campo "amostras" ausente ou inválido no JSON Sellar.');
      return const [];
    }

    final result = <AnaliseSolo>[];
    for (final a in amostras.whereType<Map<String, dynamic>>()) {
      try {
        result.add(_mapAmostra(a, json));
      } catch (e, st) {
        log('Erro ao mapear amostra no Sellar: $e', error: e, stackTrace: st);
      }
    }
    return result;
  }

  AnaliseSolo _mapAmostra(
    Map<String, dynamic> amostra,
    Map<String, dynamic> laudo,
  ) {
    dynamic value(String key) {
      if (!amostra.containsKey(key)) {
        log('Campo esperado ausente no JSON Sellar: $key');
        return null;
      }
      return amostra[key];
    }

    double? toDouble(dynamic raw) {
      if (raw == null) return null;
      if (raw is num) return raw.toDouble();
      if (raw is String) return double.tryParse(raw.replaceAll(',', '.'));
      return null;
    }

    Cultura parseCultura(dynamic raw) {
      final normalized = (raw as String?)?.trim().toLowerCase() ?? '';
      for (final cultura in Cultura.values) {
        if (cultura.name == normalized ||
            cultura.label.toLowerCase() == normalized) {
          return cultura;
        }
      }
      return Cultura.soja;
    }

    final metadata = <String, dynamic>{
      'fonte': laudo['fonte'],
      'laudoNumero': laudo['laudoNumero'],
      'dataEntrada': laudo['dataEntrada'],
      'dataGeracao': laudo['dataGeracao'],
      'proprietario': laudo['proprietario'],
      'propriedade': laudo['propriedade'],
      'municipio': laudo['municipio'],
      'convenio': laudo['convenio'],
      'extratores': laudo['extratores'],
      'groupId': laudo['groupId'],
      'groupTitle': laudo['groupTitle'],
      'importedAt': laudo['importedAt'],
      'sourceFileName': laudo['sourceFileName'],
    };

    final dataCadastro =
        DateTime.tryParse((laudo['dataGeracao'] ?? '').toString()) ??
            DateTime.now();
    // Compatibilidade:
    // - JSON novo: k_mgdm3 (mg/dm³) -> converte para cmolc/dm³
    // - JSON legado: k já em cmolc/dm³
    final kDireto = toDouble(value('k'));
    final kRawMgDm3 = toDouble(value('k_mgdm3'));
    final kCmolc = kDireto ??
        (kRawMgDm3 != null ? Conversoes.kMgDm3ToCmolc(kRawMgDm3) : null);

    return AnaliseSolo(
      id: '${laudo['laudoNumero'] ?? 'sellar'}-${value('numeroSellar') ?? value('identificacao') ?? DateTime.now().millisecondsSinceEpoch}',
      fazenda: (laudo['propriedade'] ?? '') as String,
      produtor: (laudo['solicitante'] ?? laudo['proprietario'] ?? '') as String,
      talhao: (value('identificacao') ?? '') as String,
      numeroAmostra: (value('numeroSellar') ?? '') as String,
      cultura: parseCultura(laudo['cultura']),
      safra: calcularSafra(dataCadastro),
      laboratorio: sellarLabInfo.nome,
      dataCadastro: dataCadastro,
      profundidade: _normalizarProfundidade(value('profundidade')),
      descricaoLocal: laudo['municipio'] as String?,
      argila: toDouble(value('argila')),
      silte: toDouble(value('silte')),
      areiaTotal: toDouble(value('areiaTotal')),
      phAgua: toDouble(value('phAgua')),
      phSmp: toDouble(value('phSmp')),
      phCaCl2: toDouble(value('phCaCl2')),
      materiaOrganica: toDouble(value('materiaOrganica')),
      carbonoOrganico: toDouble(value('carbonoOrganico')),
      pMehlich: toDouble(value('pMehlich')),
      pResina: toDouble(value('pResina')),
      pRem: toDouble(value('pRem')),
      s020: toDouble(value('s020')),
      s2040: toDouble(value('s2040')),
      k: kCmolc,
      ca: toDouble(value('ca')),
      mg: toDouble(value('mg')),
      al: toDouble(value('al')),
      hMaisAl: toDouble(value('hMaisAl')),
      na: toDouble(value('na')),
      b: toDouble(value('b')),
      cu: toDouble(value('cu')),
      fe: toDouble(value('fe')),
      mn: toDouble(value('mn')),
      zn: toDouble(value('zn')),
      ni: toDouble(value('ni')),
      mo: toDouble(value('mo')),
      se: toDouble(value('se')),
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
