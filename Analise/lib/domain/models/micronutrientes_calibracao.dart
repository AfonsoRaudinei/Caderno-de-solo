/// Modelo, migração e validação do card de Micronutrientes na calibração.
///
/// Persistência continua em `Map<String, dynamic>` (Hive/Firestore), com
/// `schemaVersion` e fallbacks seguros para calibrações antigas.
library;

const int kMicrosSchemaVersion = 2;

const List<String> kElementosMicros = [
  'B',
  'Cu',
  'Fe',
  'Mn',
  'Zn',
  'Mo',
  'Co',
  'Ni',
  'Se',
];

const List<String> kViasGrupoMicros = ['Foliar', 'Solo', 'TS'];

const List<String> kUnidadesConcentracaoMicro = ['%', 'g/L', 'g/kg'];

const List<String> kReferenciasNcMicros = [
  '06 — Micronutrientes: Motor de Cálculo',
  'EMBRAPA Soja',
  'Personalizada',
];

const Map<String, String> kNomesMicros = {
  'B': 'Boro',
  'Cu': 'Cobre',
  'Fe': 'Ferro',
  'Mn': 'Manganês',
  'Zn': 'Zinco',
  'Mo': 'Molibdênio',
  'Co': 'Cobalto',
  'Ni': 'Níquel',
  'Se': 'Selênio',
};

/// Resultado de validação inline do card de micronutrientes.
class MicrosValidationResult {
  const MicrosValidationResult({
    required this.isValid,
    this.errors = const [],
    this.fieldErrors = const {},
  });

  final bool isValid;
  final List<String> errors;

  /// Erros por chave (`grupo:<id>:nome`, `elemento:B:ncSolo`, ...).
  final Map<String, String> fieldErrors;

  factory MicrosValidationResult.ok() =>
      const MicrosValidationResult(isValid: true);
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return Map<String, dynamic>.from(value);
  if (value is Map) {
    return value.map((key, val) => MapEntry(key.toString(), val));
  }
  return <String, dynamic>{};
}

double _asDouble(dynamic value, [double fallback = 0]) {
  if (value is num) return value.toDouble();
  if (value is String) {
    final normalized = value.trim().replaceAll(',', '.');
    return double.tryParse(normalized) ?? fallback;
  }
  return fallback;
}

String _asString(dynamic value, [String fallback = '']) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) return fallback;
  return text;
}

List<String> _asStringList(dynamic value) {
  if (value is! List) return <String>[];
  final out = <String>[];
  for (final item in value) {
    final text = item?.toString().trim() ?? '';
    if (text.isEmpty) continue;
    if (!out.contains(text)) out.add(text);
  }
  return out;
}

String _normalizeViaGrupo(String? raw) {
  final via = (raw ?? '').trim();
  if (kViasGrupoMicros.contains(via)) return via;
  final lower = via.toLowerCase();
  if (lower.contains('foliar')) return 'Foliar';
  if (lower.contains('ts') || lower.contains('semente')) return 'TS';
  if (lower.contains('solo')) return 'Solo';
  return 'Foliar';
}

/// Defaults técnicos por elemento (compatíveis com `defaultMicros`).
Map<String, dynamic> defaultElementoMicro(String simbolo) {
  switch (simbolo) {
    case 'B':
      return _elementoBase(
        simbolo: 'B',
        extrator: 'Água quente',
        ncSolo: 0.36,
        fonteSolo: 'Ulexita',
        teorSolo: 10.0,
        eficienciaSolo: 60.0,
        fonteFoliar: 'Ácido bórico',
        teorFoliar: 17.0,
        eficienciaFoliar: 80.0,
        doseFoliar: 150.0,
        extracaoGt: 70.0,
        exportacaoGt: 30.0,
      );
    case 'Cu':
      return _elementoBase(
        simbolo: 'Cu',
        extrator: 'DTPA-TEA',
        ncSolo: 0.71,
        fonteSolo: 'Sulfato de cobre',
        teorSolo: 25.0,
        eficienciaSolo: 40.0,
        fonteFoliar: 'Sulfato de cobre',
        teorFoliar: 25.0,
        eficienciaFoliar: 65.0,
        doseFoliar: 150.0,
        extracaoGt: 25.0,
        exportacaoGt: 10.0,
      );
    case 'Fe':
      return _elementoBase(
        simbolo: 'Fe',
        extrator: 'DTPA-TEA',
        ncSolo: 19.0,
        fonteSolo: 'Sulfato ferroso',
        teorSolo: 20.0,
        eficienciaSolo: 30.0,
        fonteFoliar: 'EDTA-Fe',
        teorFoliar: 13.0,
        eficienciaFoliar: 85.0,
        doseFoliar: 80.0,
        extracaoGt: 180.0,
        exportacaoGt: 40.0,
      );
    case 'Mn':
      return _elementoBase(
        simbolo: 'Mn',
        extrator: 'DTPA-TEA',
        ncSolo: 6.0,
        fonteSolo: 'Sulfato de manganês',
        teorSolo: 27.0,
        eficienciaSolo: 25.0,
        fonteFoliar: 'Sulfato de manganês',
        teorFoliar: 27.0,
        eficienciaFoliar: 70.0,
        doseFoliar: 250.0,
        extracaoGt: 100.0,
        exportacaoGt: 20.0,
      );
    case 'Zn':
      return _elementoBase(
        simbolo: 'Zn',
        extrator: 'DTPA-TEA',
        ncSolo: 0.91,
        fonteSolo: 'Sulfato de zinco',
        teorSolo: 23.0,
        eficienciaSolo: 50.0,
        fonteFoliar: 'Sulfato de zinco',
        teorFoliar: 23.0,
        eficienciaFoliar: 70.0,
        doseFoliar: 200.0,
        extracaoGt: 60.0,
        exportacaoGt: 25.0,
      );
    case 'Mo':
      return _elementoBase(
        simbolo: 'Mo',
        extrator: 'Oxalato de amônio',
        ncSolo: 0.1,
        fonteSolo: 'Molibdato de sódio',
        teorSolo: 39.0,
        eficienciaSolo: 70.0,
        fonteFoliar: 'Molibdato de sódio',
        teorFoliar: 39.0,
        eficienciaFoliar: 90.0,
        doseFoliar: 40.0,
        extracaoGt: 5.0,
        exportacaoGt: 2.0,
      );
    case 'Co':
      return _elementoBase(
        simbolo: 'Co',
        extrator: 'DTPA-TEA',
        ncSolo: 0.05,
        fonteSolo: 'Sulfato de cobalto',
        teorSolo: 21.0,
        eficienciaSolo: 50.0,
        fonteFoliar: 'Sulfato de cobalto',
        teorFoliar: 21.0,
        eficienciaFoliar: 70.0,
        doseFoliar: 3.0,
        extracaoGt: 1.0,
        exportacaoGt: 0.5,
      );
    case 'Ni':
      return _elementoBase(
        simbolo: 'Ni',
        extrator: 'DTPA-TEA',
        ncSolo: 0.1,
        fonteSolo: 'Sulfato de níquel',
        teorSolo: 22.0,
        eficienciaSolo: 50.0,
        fonteFoliar: 'Sulfato de níquel',
        teorFoliar: 22.0,
        eficienciaFoliar: 70.0,
        doseFoliar: 5.0,
        extracaoGt: 2.0,
        exportacaoGt: 1.0,
      );
    case 'Se':
      return _elementoBase(
        simbolo: 'Se',
        extrator: 'DTPA-TEA',
        ncSolo: 0.05,
        fonteSolo: 'Selenato de sódio',
        teorSolo: 45.0,
        eficienciaSolo: 50.0,
        fonteFoliar: 'Selenato de sódio',
        teorFoliar: 45.0,
        eficienciaFoliar: 70.0,
        doseFoliar: 5.0,
        extracaoGt: 1.0,
        exportacaoGt: 0.5,
      );
    default:
      return _elementoBase(
        simbolo: simbolo,
        extrator: 'DTPA-TEA',
        ncSolo: 0.0,
        fonteSolo: '',
        teorSolo: 0.0,
        eficienciaSolo: 50.0,
        fonteFoliar: '',
        teorFoliar: 0.0,
        eficienciaFoliar: 70.0,
        doseFoliar: 0.0,
        extracaoGt: 0.0,
        exportacaoGt: 0.0,
      );
  }
}

Map<String, dynamic> _elementoBase({
  required String simbolo,
  required String extrator,
  required double ncSolo,
  required String fonteSolo,
  required double teorSolo,
  required double eficienciaSolo,
  required String fonteFoliar,
  required double teorFoliar,
  required double eficienciaFoliar,
  required double doseFoliar,
  required double extracaoGt,
  required double exportacaoGt,
}) {
  return {
    'simbolo': simbolo,
    'extrator': extrator,
    'referencia': '06 — Micronutrientes: Motor de Cálculo',
    'referenciaNc': '06 — Micronutrientes: Motor de Cálculo',
    'ncSolo': ncSolo,
    'ncUnidade': 'mg/dm³',
    'extracaoGt': extracaoGt,
    'exportacaoGt': exportacaoGt,
    'referenciaExtracaoExportacao': '',
    'viaAplicacao': 'Solo (correção)',
    'viasPermitidas': List<String>.from(kViasGrupoMicros),
    'percentualCorrecaoSolo': 100.0,
    'fonteSolo': fonteSolo,
    'teorFonteSolo': teorSolo,
    'eficienciaSolo': eficienciaSolo,
    'doseElementoFoliar': doseFoliar,
    'fonteFoliar': fonteFoliar,
    'teorFonteFoliar': teorFoliar,
    'eficienciaFoliar': eficienciaFoliar,
    'concentracao': teorSolo > 0 ? teorSolo : teorFoliar,
    'unidadeConcentracao': '%',
    'doseMin': 0.0,
    'doseMax': doseFoliar > 0 ? doseFoliar * 2 : 0.0,
    'unidadeDose': 'g/ha',
    'limiteToxicidade': null,
    'temAnaliseFoliar': false,
    'teorFoliar': 0.0,
    'adicionarGrupo': false,
    'grupoId': '',
    'propagadoDoGrupo': false,
  };
}

Map<String, dynamic> novoGrupoAplicacao({
  required String id,
  required int indice,
  String? via,
}) {
  final viaNorm = _normalizeViaGrupo(via);
  return {
    'id': id,
    'nome': 'Grupo $indice',
    'extrator': 'DTPA-TEA',
    'via': viaNorm,
    'elementos': <String>[],
    'produto': 'Mistura manual',
    'eficiencia': 70.0,
    'fonteFoliar': 'Mistura manual',
    'fonteSolo': 'Mistura manual',
    'fonteTs': 'Mistura manual',
    'eficienciaFoliar': 70.0,
    'eficienciaSolo': 70.0,
    'eficienciaTs': 70.0,
    'referenciaNcNome': '',
    'referenciaNome': '',
    'microGrupoTipoFonte': 'Autores',
    'microGrupoFonteNome': '',
  };
}

/// Migra/normaliza o mapa `micros` para o schema atual sem perder dados.
Map<String, dynamic> migrateMicrosParametros(Map<String, dynamic>? raw) {
  final source = _asMap(raw);
  final elementosRaw = _asMap(source['elementos']);
  final elementos = <String, dynamic>{};

  for (final simbolo in kElementosMicros) {
    final base = defaultElementoMicro(simbolo);
    final atual = _asMap(elementosRaw[simbolo]);
    final merged = {...base, ...atual};

    // Separar referência de NC da referência legada genérica.
    // Preferir valores do registro original (atual), não do default base.
    final refNc = _asString(
      atual['referenciaNc'],
      _asString(atual['referencia'], base['referenciaNc'] as String),
    );
    merged['referenciaNc'] = refNc;
    merged['referencia'] = refNc;

    if (_asString(merged['ncUnidade']).isEmpty) {
      merged['ncUnidade'] = 'mg/dm³';
    }

    merged['extracaoGt'] =
        _asDouble(merged['extracaoGt'], base['extracaoGt'] as double);
    merged['exportacaoGt'] =
        _asDouble(merged['exportacaoGt'], base['exportacaoGt'] as double);
    merged['referenciaExtracaoExportacao'] =
        _asString(merged['referenciaExtracaoExportacao']);

    final vias = _asStringList(merged['viasPermitidas']);
    merged['viasPermitidas'] =
        vias.isEmpty ? List<String>.from(kViasGrupoMicros) : vias;

    final concentracao = merged['concentracao'];
    if (concentracao == null) {
      final via = _asString(merged['viaAplicacao'], 'Solo (correção)');
      merged['concentracao'] = via.toLowerCase().contains('foliar') ||
              via.toLowerCase().contains('ts')
          ? _asDouble(
              merged['teorFonteFoliar'], base['teorFonteFoliar'] as double)
          : _asDouble(merged['teorFonteSolo'], base['teorFonteSolo'] as double);
    } else {
      merged['concentracao'] = _asDouble(concentracao);
    }

    final unidadeConc = _asString(merged['unidadeConcentracao'], '%');
    merged['unidadeConcentracao'] =
        kUnidadesConcentracaoMicro.contains(unidadeConc) ? unidadeConc : '%';

    merged['doseMin'] = _asDouble(merged['doseMin']);
    merged['doseMax'] = _asDouble(
      merged['doseMax'],
      _asDouble(merged['doseElementoFoliar']) * 2,
    );
    merged['unidadeDose'] = _asString(merged['unidadeDose'], 'g/ha');
    merged['ncSolo'] = _asDouble(merged['ncSolo'], base['ncSolo'] as double);
    merged['simbolo'] = simbolo;

    elementos[simbolo] = merged;
  }

  // Preserva elementos customizados fora da lista padrão, se existirem.
  for (final entry in elementosRaw.entries) {
    if (elementos.containsKey(entry.key)) continue;
    elementos[entry.key] = {
      ...defaultElementoMicro(entry.key),
      ..._asMap(entry.value)
    };
  }

  final gruposRaw = source['grupos'];
  final grupos = <Map<String, dynamic>>[];
  if (gruposRaw is List) {
    for (var i = 0; i < gruposRaw.length; i++) {
      grupos.add(migrateGrupoAplicacao(_asMap(gruposRaw[i]), indice: i + 1));
    }
  }

  return {
    ...source,
    'schemaVersion': kMicrosSchemaVersion,
    'elementos': elementos,
    'grupos': grupos,
    'pH': _asDouble(source['pH'], 5.8),
    'plantioDiretoAntigo': source['plantioDiretoAntigo'] == true,
    'gessoDoseKgHa': _asDouble(source['gessoDoseKgHa']),
  };
}

Map<String, dynamic> migrateGrupoAplicacao(
  Map<String, dynamic> raw, {
  required int indice,
}) {
  final via = _normalizeViaGrupo(_asString(raw['via'], 'Foliar'));
  final produtoLegacy = _asString(raw['produto'], 'Mistura manual');
  final eficienciaLegacy = _asDouble(raw['eficiencia'], 70);

  String fontePara(String key, String fallback) {
    final atual = _asString(raw[key]);
    if (atual.isNotEmpty) return atual;
    return fallback;
  }

  double eficienciaPara(String key) {
    if (raw.containsKey(key) && raw[key] != null) {
      return _asDouble(raw[key], eficienciaLegacy);
    }
    return eficienciaLegacy;
  }

  final fonteFoliar =
      fontePara('fonteFoliar', via == 'Foliar' ? produtoLegacy : produtoLegacy);
  final fonteSolo =
      fontePara('fonteSolo', via == 'Solo' ? produtoLegacy : produtoLegacy);
  final fonteTs =
      fontePara('fonteTs', via == 'TS' ? produtoLegacy : produtoLegacy);

  final referenciaNc = _asString(
    raw['referenciaNcNome'],
    _asString(raw['referenciaNome']),
  );

  final elementos = _asStringList(raw['elementos'])
      .where((e) => kElementosMicros.contains(e))
      .toList(growable: false);

  final nomeRaw = raw['nome'];
  final nome = nomeRaw == null ? 'Grupo $indice' : nomeRaw.toString().trim();

  return {
    ...raw,
    'id': _asString(raw['id'], 'grupo-$indice'),
    'nome': nome,
    'extrator': _asString(raw['extrator'], 'DTPA-TEA'),
    'via': via,
    'elementos': elementos,
    'produto': produtoLegacy,
    'eficiencia': eficienciaLegacy,
    'fonteFoliar': fonteFoliar,
    'fonteSolo': fonteSolo,
    'fonteTs': fonteTs,
    'eficienciaFoliar': eficienciaPara('eficienciaFoliar'),
    'eficienciaSolo': eficienciaPara('eficienciaSolo'),
    'eficienciaTs': eficienciaPara('eficienciaTs'),
    'referenciaNcNome': referenciaNc,
    'referenciaNome': referenciaNc,
    'microGrupoTipoFonte': _asString(raw['microGrupoTipoFonte'], 'Autores'),
    'microGrupoFonteNome': _asString(raw['microGrupoFonteNome']),
  };
}

/// Fonte efetiva do grupo conforme a via selecionada.
String fonteDoGrupo(Map<String, dynamic> grupo) {
  final via = _normalizeViaGrupo(_asString(grupo['via'], 'Foliar'));
  switch (via) {
    case 'Solo':
      return _asString(
          grupo['fonteSolo'], _asString(grupo['produto'], 'Mistura manual'));
    case 'TS':
      return _asString(
          grupo['fonteTs'], _asString(grupo['produto'], 'Mistura manual'));
    case 'Foliar':
    default:
      return _asString(
          grupo['fonteFoliar'], _asString(grupo['produto'], 'Mistura manual'));
  }
}

/// Eficiência efetiva do grupo conforme a via selecionada (1–100).
double eficienciaDoGrupo(Map<String, dynamic> grupo) {
  final via = _normalizeViaGrupo(_asString(grupo['via'], 'Foliar'));
  final legacy = _asDouble(grupo['eficiencia'], 70);
  switch (via) {
    case 'Solo':
      return _asDouble(grupo['eficienciaSolo'], legacy)
          .clamp(1, 100)
          .toDouble();
    case 'TS':
      return _asDouble(grupo['eficienciaTs'], legacy).clamp(1, 100).toDouble();
    case 'Foliar':
    default:
      return _asDouble(grupo['eficienciaFoliar'], legacy)
          .clamp(1, 100)
          .toDouble();
  }
}

/// Símbolos já associados a algum grupo.
Set<String> elementosEmGrupos(List<Map<String, dynamic>> grupos) {
  final set = <String>{};
  for (final grupo in grupos) {
    set.addAll(_asStringList(grupo['elementos']));
  }
  return set;
}

/// Lista de grupos tipada a partir do mapa micros.
List<Map<String, dynamic>> gruposFromMicros(Map<String, dynamic> micros) {
  final raw = micros['grupos'];
  if (raw is! List) return const [];
  return raw.map((e) => _asMap(e)).toList(growable: false);
}

/// Duplica um grupo com novo id e sufixo no nome.
Map<String, dynamic> duplicarGrupoAplicacao(
  Map<String, dynamic> grupo, {
  required String novoId,
}) {
  final migrado = migrateGrupoAplicacao(grupo, indice: 1);
  return {
    ...migrado,
    'id': novoId,
    'nome': '${_asString(migrado['nome'], 'Grupo')} (cópia)',
  };
}

/// Valida grupos e elementos do card de micronutrientes.
MicrosValidationResult validateMicrosParametros(
    Map<String, dynamic> microsRaw) {
  final micros = migrateMicrosParametros(microsRaw);
  final grupos = gruposFromMicros(micros);
  final elementos = _asMap(micros['elementos']);
  final errors = <String>[];
  final fieldErrors = <String, String>{};

  for (final grupo in grupos) {
    final id = _asString(grupo['id'], 'grupo');
    final nome = _asString(grupo['nome']);
    if (nome.isEmpty) {
      const msg = 'Nome do grupo é obrigatório.';
      errors.add(msg);
      fieldErrors['grupo:$id:nome'] = msg;
    }

    final via = _asString(grupo['via']);
    if (!kViasGrupoMicros.contains(via)) {
      const msg = 'Selecione uma via de aplicação.';
      errors.add(msg);
      fieldErrors['grupo:$id:via'] = msg;
    }

    final membros = _asStringList(grupo['elementos']);
    if (membros.isEmpty) {
      const msg = 'Selecione ao menos um elemento no grupo.';
      errors.add(msg);
      fieldErrors['grupo:$id:elementos'] = msg;
    }

    final uniqueCheck = <String>{};
    for (final simbolo in membros) {
      if (!uniqueCheck.add(simbolo)) {
        final msg = 'Elemento $simbolo duplicado no mesmo grupo.';
        errors.add(msg);
        fieldErrors['grupo:$id:elementos'] = msg;
      }
    }

    void validarEficiencia(String campo, double valor) {
      if (valor < 1 || valor > 100) {
        const msg = 'Eficiência deve estar entre 1 e 100%.';
        errors.add(msg);
        fieldErrors['grupo:$id:$campo'] = msg;
      }
    }

    switch (via) {
      case 'Solo':
        validarEficiencia(
          'eficienciaSolo',
          _asDouble(
              grupo['eficienciaSolo'], _asDouble(grupo['eficiencia'], 70)),
        );
        break;
      case 'TS':
        validarEficiencia(
          'eficienciaTs',
          _asDouble(grupo['eficienciaTs'], _asDouble(grupo['eficiencia'], 70)),
        );
        break;
      case 'Foliar':
      default:
        validarEficiencia(
          'eficienciaFoliar',
          _asDouble(
              grupo['eficienciaFoliar'], _asDouble(grupo['eficiencia'], 70)),
        );
        break;
    }

    for (final simbolo in membros) {
      final el = _asMap(elementos[simbolo]);
      final nc = _asDouble(el['ncSolo']);
      if (nc < 0) {
        final msg = 'Nível crítico de $simbolo deve ser ≥ 0.';
        errors.add(msg);
        fieldErrors['elemento:$simbolo:ncSolo'] = msg;
      }

      final extracao = _asDouble(el['extracaoGt']);
      if (extracao < 0) {
        final msg = 'Extração de $simbolo deve ser ≥ 0.';
        errors.add(msg);
        fieldErrors['elemento:$simbolo:extracaoGt'] = msg;
      }

      final exportacao = _asDouble(el['exportacaoGt']);
      if (exportacao < 0) {
        final msg = 'Exportação de $simbolo deve ser ≥ 0.';
        errors.add(msg);
        fieldErrors['elemento:$simbolo:exportacaoGt'] = msg;
      }

      final doseMin = _asDouble(el['doseMin']);
      final doseMax = _asDouble(el['doseMax']);
      if (doseMin > doseMax) {
        final msg = 'Dose mínima de $simbolo não pode ser maior que a máxima.';
        errors.add(msg);
        fieldErrors['elemento:$simbolo:doseMin'] = msg;
      }
    }
  }

  return MicrosValidationResult(
    isValid: errors.isEmpty,
    errors: errors,
    fieldErrors: fieldErrors,
  );
}

/// Texto resumido do NC para UI (sempre visível no subcard).
String formatNivelCriticoVisivel(Map<String, dynamic> elemento) {
  final nc = _asDouble(elemento['ncSolo']);
  final unidade = _asString(elemento['ncUnidade'], 'mg/dm³');
  final ncText = nc.toStringAsFixed(2).replaceAll('.', ',');
  return '$ncText $unidade';
}

String nomeElementoMicro(String simbolo) => kNomesMicros[simbolo] ?? simbolo;
