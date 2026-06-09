import 'dart:developer';

import 'package:soloforte/core/utils/safra_utils.dart';
import 'package:soloforte/data/lab_templates/solum_template.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';

class SolumImportService {
  const SolumImportService();

  List<AnaliseSolo> fromJson(Map<String, dynamic> json) {
    final amostras = json['amostras'];
    if (amostras is! List) {
      log('Campo "amostras" ausente ou inválido no JSON Solum.');
      return const [];
    }

    final result = <AnaliseSolo>[];
    for (final a in amostras.whereType<Map<String, dynamic>>()) {
      try {
        result.add(_mapAmostra(a, json));
      } catch (e, st) {
        log('Erro ao mapear amostra Solum: $e', error: e, stackTrace: st);
      }
    }
    return result;
  }

  AnaliseSolo _mapAmostra(
    Map<String, dynamic> amostra,
    Map<String, dynamic> laudo,
  ) {
    dynamic raw(String key) => amostra[key];

    double? toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) {
        final s = v.trim();
        if (s == '-' || s.isEmpty) return null;
        return double.tryParse(s.replaceAll(',', '.'));
      }
      return null;
    }

    // mmolc/dm³ → cmolc/dm³ (÷ 10)
    final kMmolc = toDouble(raw('k_mmolc'));
    final caMmolc = toDouble(raw('ca_mmolc'));
    final mgMmolc = toDouble(raw('mg_mmolc'));
    final alMmolc = toDouble(raw('al_mmolc'));
    final halMmolc = toDouble(raw('hMaisAl_mmolc'));
    final ctcMmolc = toDouble(raw('ctc_mmolc'));
    final sbMmolc = toDouble(raw('sb_mmolc'));
    final kCmolc = kMmolc != null ? kMmolc / 10.0 : null;
    final caCmolc = caMmolc != null ? caMmolc / 10.0 : null;
    final mgCmolc = mgMmolc != null ? mgMmolc / 10.0 : null;
    final alCmolc = alMmolc != null ? alMmolc / 10.0 : null;
    final halCmolc = halMmolc != null ? halMmolc / 10.0 : null;
    final ctcCmolc = ctcMmolc != null ? ctcMmolc / 10.0 : null;
    final sbCmolc = sbMmolc != null ? sbMmolc / 10.0 : null;

    // MO: g/dm³ → dag/kg (÷ 10)
    final moDagKg = toDouble(raw('mo_gdm3')) != null
        ? toDouble(raw('mo_gdm3'))! / 10.0
        : null;

    final metadata = <String, dynamic>{
      'fonte': laudo['fonte'],
      'laudoNumero': laudo['laudoNumero'],
      'dataEmissao': laudo['dataEmissao'],
      'proprietario': laudo['proprietario'],
      'propriedade': laudo['propriedade'],
      'cliente': laudo['cliente'],
      'municipio': laudo['municipio'],
      'groupId': laudo['groupId'],
      'groupTitle': laudo['groupTitle'],
      'importedAt': laudo['importedAt'],
      'sourceFileName': laudo['sourceFileName'],
    };

    final dataCadastro =
        DateTime.tryParse((laudo['dataEmissao'] ?? '').toString()) ??
            DateTime.now();

    return AnaliseSolo(
      id: '${laudo['laudoNumero'] ?? 'solum'}-${raw('numeroAmostra') ?? DateTime.now().millisecondsSinceEpoch}',
      fazenda: (laudo['propriedade'] ?? '') as String,
      produtor: (laudo['proprietario'] ?? laudo['cliente'] ?? '') as String,
      talhao: (raw('talhao') ?? '') as String,
      numeroAmostra: (raw('numeroAmostra') ?? '') as String,
      cultura: Cultura.soja,
      safra: calcularSafra(dataCadastro),
      laboratorio: solumLabInfo.nome,
      dataCadastro: dataCadastro,
      profundidade: raw('profundidade')?.toString() ?? '0-20',
      descricaoLocal: laudo['propriedade'] as String?,
      argila: null, // Solum não reporta granulometria neste layout
      silte: null,
      areiaTotal: null,
      phAgua: null,
      phSmp: toDouble(raw('phSmp')),
      phCaCl2: toDouble(raw('phCaCl2')),
      materiaOrganica: moDagKg,
      carbonoOrganico: null,
      pMehlich: toDouble(raw('p_mgdm3')), // P = Resina e/ou Mehlich
      pResina: null,
      pRem: null,
      s020: toDouble(raw('s020')),
      s2040: null,
      k: kCmolc,
      ca: caCmolc,
      mg: mgCmolc,
      al: alCmolc,
      hMaisAl: halCmolc,
      na: null,
      ctc: ctcCmolc,
      sb: sbCmolc,
      vPercent: toDouble(raw('vPercent')),
      mPercent: toDouble(raw('mPercent')),
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
}
