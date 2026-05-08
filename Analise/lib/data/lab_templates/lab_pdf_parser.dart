class LabPdfParseResult {
  final String labId;
  final Map<String, dynamic> laudo;
  final List<String> warnings;

  const LabPdfParseResult({
    required this.labId,
    required this.laudo,
    required this.warnings,
  });
}

class LabPdfParserService {
  const LabPdfParserService();

  LabPdfParseResult parse({
    required String labId,
    required String text,
    required String sourceName,
  }) {
    switch (labId) {
      case 'exata_brasil':
        return _parseExata(text);
      case 'ibra':
        return _parseIbra(text);
      case 'mb':
        return _parseMb(text);
      case 'sellar':
        return _parseSellar(text);
      case 'solum':
        return _parseSolum(text);
      default:
        throw LabPdfParseException('Parser não implementado para $labId');
    }
  }

  LabPdfParseResult _parseExata(String text) {
    final lines = _cleanLines(text);
    final sections = _extractTableSections(
      lines: lines,
      sampleIdRegex: RegExp(r'^(SBA|SGO)\d{2}\.\d{5,6}$'),
    );

    final amostras = <String, Map<String, dynamic>>{};
    final warnings = <String>[];

    void mergeSample(
      String sampleId,
      Map<String, dynamic> fields, {
      String? talhao,
      String? profundidade,
    }) {
      final sample = amostras.putIfAbsent(sampleId, () {
        return <String, dynamic>{
          'numeroAmostra': sampleId,
          'talhao': talhao ?? '',
          'profundidade': profundidade ?? '0-20',
        };
      });

      if ((sample['talhao'] as String).trim().isEmpty &&
          talhao != null &&
          talhao.trim().isNotEmpty) {
        sample['talhao'] = talhao.trim();
      }
      if ((sample['profundidade'] as String).trim().isEmpty &&
          profundidade != null &&
          profundidade.trim().isNotEmpty) {
        sample['profundidade'] = profundidade.trim();
      }

      for (final entry in fields.entries) {
        if (entry.value != null) {
          sample[entry.key] = entry.value;
        }
      }
    }

    for (final section in sections) {
      if (section.rows.isEmpty) continue;
      final header = section.header.join(' ').toLowerCase();

      final isTablePhK = header.contains('k (nh4cl)');
      final isTablePRem =
          header.contains('p (rem)') || header.contains('p (res)');
      final isTableMicrosA =
          header.contains('fe (meh)') ||
          (header.contains('cu (meh)') && header.contains('mn (meh)'));
      final isTableSilteAreia =
          header.contains('silte') && header.contains('areia');

      for (final row in section.rows) {
        final parsed = _parseRowWithTailValues(row, valueCount: 8);
        if (parsed == null) continue;

        final colMap = _buildColMapFromLines(section.header);

        // Acesso seguro via mapa — retorna null se coluna não encontrada
        double? byCol(String label) {
          final idx = colMap[label.toLowerCase()];
          return (idx != null && idx < parsed.values.length) ? _toDouble(parsed.values[idx]) : null;
        }

        if (isTablePhK) {
          mergeSample(
            parsed.sampleId,
            <String, dynamic>{
              'phCaCl2': byCol('cacl2') ?? byCol('ph') ?? byCol('phcacl2'),
              'ca': byCol('ca'),
              'mg': byCol('mg'),
              'al': byCol('al'),
              'hMaisAl': byCol('h+al') ?? byCol('h + al') ?? byCol('h+al³⁺'),
              'k': byCol('k'),
              // Se K aparecer em cmolc e mg/dm3, tentar resgatar via fallback se colMap sobresscreveu  
              'k_mgdm3': colMap.containsKey('mg/dm3') ? byCol('k') : (parsed.values.length > 7 ? _toDouble(parsed.values[7]) : null),
            },
            talhao: parsed.talhao,
            profundidade: parsed.profundidade,
          );
          continue;
        }

        if (isTablePRem) {
          mergeSample(
            parsed.sampleId,
            <String, dynamic>{
              'pMehlich': byCol('mehlich') ?? byCol('p (meh)'),
              'pRem': byCol('rem') ?? byCol('p (rem)'),
              'pResina': byCol('resina') ?? byCol('p (res)'),
              's020': byCol('s'),
              'materiaOrganica': byCol('m.o.') ?? byCol('mo') ?? byCol('m.o'),
              'carbonoOrganico': byCol('c.o.') ?? byCol('co') ?? byCol('c.o'),
              'b': byCol('b'),
              'cu_meh': byCol('cu'),
            },
            talhao: parsed.talhao,
            profundidade: parsed.profundidade,
          );
          continue;
        }

        if (isTableMicrosA && !isTableSilteAreia) {
          // Detectar variante por presença de colunas no header
          final hasBoroCol = RegExp(r'\bb\b|\bboro\b|\bb\s*\(|\bb\s+mg/dm\u00B3|\bb\s+dtpa', caseSensitive: false).hasMatch(header);
          final hasPMehCol = RegExp(r'p\s*\(\s*meh|\bp\b', caseSensitive: false).hasMatch(header);

          Map<String, dynamic> fields;

          if (hasPMehCol && !hasBoroCol) {
            // Variante padrão BA:
            fields = <String, dynamic>{
              'pMehlich': byCol('p') ?? byCol('p (meh)'),
              's020':     byCol('s'),
              'cu_meh':   byCol('cu'),
              'fe_meh':   byCol('fe'),
              'mn_meh':   byCol('mn'),
              'zn_meh':   byCol('zn'),
              'na':       byCol('na'),
              'argila':   byCol('argila'),
            };
          } else if (hasPMehCol && hasBoroCol) {
            // Variante GO / completa:
            fields = <String, dynamic>{
              'k_mgdm3':         byCol('nh4cl') ?? byCol('k'),
              'pMehlich':        byCol('mehlich') ?? byCol('p (meh)'),
              'pResina':         byCol('resina') ?? byCol('p (res)'),
              's020':            byCol('s'),
              'materiaOrganica': byCol('m.o.') ?? byCol('mo'),
              'carbonoOrganico': byCol('c.o.') ?? byCol('co'),
              'b':               byCol('b'),
              'cu_meh':          byCol('cu'),
            };
          } else {
            // Variante sem P no header (Fe, Mn, Zn, Na, Argila apenas)
            fields = <String, dynamic>{
              'fe_meh':  byCol('fe'),
              'mn_meh':  byCol('mn'),
              'zn_meh':  byCol('zn'),
              'na':      byCol('na'),
              'argila':  byCol('argila'),
            };
          }

          mergeSample(
            parsed.sampleId,
            fields,
            talhao: parsed.talhao,
            profundidade: parsed.profundidade,
          );
          continue;
        }

        if (isTableMicrosA && isTableSilteAreia) {
          // Variante GO: Fe(meh) | Mn(meh) | Zn(meh) | Na | Argila | Silte | Areia
          mergeSample(
            parsed.sampleId,
            <String, dynamic>{
              'fe_meh':    byCol('fe'),
              'mn_meh':    byCol('mn'),
              'zn_meh':    byCol('zn'),
              'na':        byCol('na'),
              'argila':    byCol('argila'),
              'silte':     byCol('silte'),
              'areiaTotal':byCol('areia'),
            },
            talhao: parsed.talhao,
            profundidade: parsed.profundidade,
          );
          continue;
        }

        if (isTableSilteAreia) {
          mergeSample(
            parsed.sampleId,
            <String, dynamic>{
              'silte': byCol('silte'),
              'areiaTotal': byCol('areia'),
            },
            talhao: parsed.talhao,
            profundidade: parsed.profundidade,
          );
          continue;
        }
      }
    }

    if (amostras.isEmpty) {
      throw const LabPdfParseException(
        'Nenhuma amostra Exata Brasil reconhecida no texto',
      );
    }

    final relatorio = _firstMatch(
      text,
      RegExp(r'Relat[oó]rio de Ensaio N[ºo]\s*([0-9A-Za-z\.\-]+)',
          caseSensitive: false),
    );
    final dataEmissaoBr = _firstMatch(
      text,
      RegExp(r'Data Emiss[aã]o:?\s*([0-9]{2}/[0-9]{2}/[0-9]{4})',
          caseSensitive: false),
    );
    final dataEmissaoIso = _dateBrToIso(dataEmissaoBr);

    final proprietario = _firstMatch(
      text,
      RegExp(r'Raz[aã]o Social:\s*([^\n\r]+)', caseSensitive: false),
    );
    final propriedadeCompleta = _firstMatch(
      text,
      RegExp(r'Propriedade/Munic[ií]pio/Propriet[aá]rio:\s*([^\n\r]+)',
          caseSensitive: false),
    );
    final propriedade = propriedadeCompleta?.split(' - ').first.trim();

    final laudo = <String, dynamic>{
      'fonte': 'Exata Brasil',
      'relatorio': relatorio ?? '',
      'os': relatorio?.split('.').first,
      'dataEmissao': dataEmissaoIso ?? '',
      'proprietario': proprietario ?? '',
      'propriedade': propriedade ?? propriedadeCompleta ?? '',
      'municipio': propriedadeCompleta ?? '',
      'responsavel': _firstMatch(
            text,
            RegExp(r'Contato:\s*([^\n\r]+)', caseSensitive: false),
          ) ??
          '',
      'amostras': amostras.values.toList(growable: false),
    };

    if ((laudo['amostras'] as List).isEmpty) {
      warnings.add('parse_sem_amostras');
    }

    return LabPdfParseResult(
      labId: 'exata_brasil',
      laudo: laudo,
      warnings: warnings,
    );
  }

  LabPdfParseResult _parseIbra(String text) {
    final compact = _compact(text);
    final warnings = <String>[];

    final sampleMeta = <String, Map<String, String>>{};
    final headerBlocks = RegExp(
      r'((?:\b\d{6}\b\s+){1,30})(Talh[aã]o:.*?)(?=N[ºo]\s*LAB)',
      caseSensitive: false,
      dotAll: true,
    ).allMatches(compact);

    for (final block in headerBlocks) {
      final ids = RegExp(r'\b\d{6}\b')
          .allMatches(block.group(1) ?? '')
          .map((m) => m.group(0)!)
          .toList(growable: false);
      final talhoes = RegExp(
        r'Talh[aã]o:\s*([^;]+);\s*Prof\.\s*:\s*(\d+)\s*a\s*(\d+)\s*cm',
        caseSensitive: false,
      ).allMatches(block.group(2) ?? '');

      final talhaoList = talhoes
          .map((m) => <String, String>{
                'talhao': (m.group(1) ?? '').trim(),
                'profundidade': '${m.group(2) ?? ''}-${m.group(3) ?? ''}',
              })
          .toList(growable: false);

      for (var i = 0; i < ids.length && i < talhaoList.length; i++) {
        sampleMeta[ids[i]] = talhaoList[i];
      }
    }

    final amostras = <String, Map<String, dynamic>>{};
    final dataBlocks = RegExp(
      r'N[ºo]\s*LAB.*?(?=P[aá]gina\s+\d+\s+de\s+\d+|METODOLOGIA|INSTITUTO BRASILEIRO DE AN[ÁA]LISES|$)',
      caseSensitive: false,
      dotAll: true,
    ).allMatches(compact);

    for (final block in dataBlocks) {
      final tokens = (block.group(0) ?? '')
          .split(RegExp(r'\s+'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(growable: false);
      final samplePositions = <int>[];
      for (var i = 0; i < tokens.length; i++) {
        if (RegExp(r'^\d{6}$').hasMatch(tokens[i])) {
          samplePositions.add(i);
        }
      }

      for (var i = 0; i < samplePositions.length; i++) {
        final start = samplePositions[i];
        final end = i + 1 < samplePositions.length
            ? samplePositions[i + 1]
            : tokens.length;
        final row = tokens.sublist(start, end);
        if (row.length < 20) continue;

        final sampleId = row.first;
        final values =
            row.skip(1).where(_looksLikeValueToken).toList(growable: false);

        if (values.length < 30) continue;

        final meta = sampleMeta[sampleId] ?? const <String, String>{};
        amostras[sampleId] = <String, dynamic>{
          'numeroAmostra': sampleId,
          'talhao': meta['talhao'] ?? '',
          'profundidade': meta['profundidade'] ?? '0-20',
          'pResina': values.isNotEmpty ? _toDouble(values[0]) : null,
          'pRem': values.length > 1 ? _toDouble(values[1]) : null,
          'mo_gdm3': values.length > 2 ? _toDouble(values[2]) : null,
          'cot_gdm3': values.length > 3 ? _toDouble(values[3]) : null,
          'phCaCl2': values.length > 4 ? _toDouble(values[4]) : null,
          'phSmp': values.length > 5 ? _toDouble(values[5]) : null,
          'k_mmolc': values.length > 6 ? _toDouble(values[6]) : null,
          'ca_mmolc': values.length > 7 ? _toDouble(values[7]) : null,
          'mg_mmolc': values.length > 8 ? _toDouble(values[8]) : null,
          'na': values.length > 9 ? _toDouble(values[9]) : null,
          'hMaisAl_mmolc': values.length > 10 ? _toDouble(values[10]) : null,
          'al_mmolc': values.length > 11 ? _toDouble(values[11]) : null,
          's020': values.length > 18 ? _toDouble(values[18]) : null,
          'b': values.length > 19 ? _toDouble(values[19]) : null,
          'cu': values.length > 20 ? _toDouble(values[20]) : null,
          'fe': values.length > 21 ? _toDouble(values[21]) : null,
          'mn': values.length > 22 ? _toDouble(values[22]) : null,
          'zn': values.length > 23 ? _toDouble(values[23]) : null,
          'argila':
              values.length > 2 ? _toDouble(values[values.length - 3]) : null,
          'silte':
              values.length > 1 ? _toDouble(values[values.length - 2]) : null,
          'areiaTotal':
              values.isNotEmpty ? _toDouble(values[values.length - 1]) : null,
        };
      }
    }

    if (amostras.isEmpty) {
      throw const LabPdfParseException(
        'Nenhuma amostra IBRA reconhecida no texto',
      );
    }

    final os = _firstMatch(
      text,
      RegExp(r'O\.S\.\s*:\s*(\d+)', caseSensitive: false),
    );
    final dataEmissaoBr = _firstMatch(
      text,
      RegExp(r'Emiss[aã]o:\s*([0-9]{2}/[0-9]{2}/[0-9]{4})',
          caseSensitive: false),
    );
    final dataEmissaoIso = _dateBrToIso(dataEmissaoBr);

    final laudo = <String, dynamic>{
      'fonte': 'IBRA',
      'os': os ?? '',
      'dataEmissao': dataEmissaoIso ?? '',
      'proprietario': _firstMatch(
            text,
            RegExp(
              r'Propriet[aá]rio:\s*([^\n\r]+?)(?=\s*Propr[io]dade:|\s{3,}|\t|$)',
              caseSensitive: false,
            ),
          )?.trim() ??
          '',
      'propriedade': _firstMatch(
            text,
            RegExp(
              r'Propr[io]dade:\s*([^\n\r]+?)(?=\s*Material:|\s{3,}|\t|$)',
              caseSensitive: false,
            ),
          )?.replaceAll(RegExp(r'\s+[A-Z]{2}\s+Solo\.?\s*$'), '').trim() ??
          '',
      'municipio': _firstMatch(
            text,
            RegExp(r'([A-Za-zÀ-ÿ ]+)\s+[A-Z]{2}\s+Solo\.',
                caseSensitive: false),
          ) ??
          '',
      'responsavel': _firstMatch(
            text,
            RegExp(r'Agrofarm[^\n\r]*', caseSensitive: false),
          ) ??
          'Agrofarm',
      'amostras': amostras.values.toList(growable: false),
    };

    return LabPdfParseResult(
      labId: 'ibra',
      laudo: laudo,
      warnings: warnings,
    );
  }

  LabPdfParseResult _parseMb(String text) {
    final lines = _cleanLines(text);
    final compact = _compact(text);

    final analiseNumero = _firstMatch(
      text,
      RegExp(r'AN[ÁA]LISE DE SOLO\s*-\s*N[ºO]\s*([0-9]+)',
          caseSensitive: false),
    );
    final talhao = _firstMatch(
      text,
      RegExp(r'AMOSTRA:\s*([^\n\r]+)', caseSensitive: false),
    );
    final profundidade = _normalizeDepth(
          _firstMatch(
            text,
            RegExp(r'PROFUNDIDADE:\s*([0-9\-\s]+)cm', caseSensitive: false),
          ),
        ) ??
        '0-20';

    final textureStart = lines.indexWhere(
        (line) => line.toUpperCase().contains('COMPOSIÇÃO GRANULOMÉTRICA'));
    final textureEnd = lines.indexWhere(
      (line) => line.toUpperCase().contains('PARÂMETROS ESTRATÉGICOS'),
    );
    final textureTokens = (textureStart >= 0 && textureEnd > textureStart)
        ? lines
            .sublist(textureStart, textureEnd)
            .where((line) => !RegExp(r'^\d+(,\d+)?\s*(mm|cm)$').hasMatch(line))
            .toList(growable: false)
        : const <String>[];
    final textureValues =
        textureTokens.where(_isNumberToken).take(3).toList(growable: false);

    final macroBlock = _sliceByMarkers(
      compact,
      startMarker: 'Ca Mg K P-meh K S H+Al Al',
      endMarker: 'REFERÊNCIAS TÉCNICAS PARA MÁXIMA PRODUTIVIDADE',
    );
    // Substituir 'nr' por '0' no bloco para evitar deslocamento de índices
    final macroBlockClean = macroBlock.replaceAll(
      RegExp(r'\bnr\b', caseSensitive: false), '0');
    final macroValues = macroBlockClean
        .split(RegExp(r'\s+'))
        .where(_looksLikeValueToken)
        .take(10)
        .toList(growable: false);

    if (macroValues.length < 8) {
      throw const LabPdfParseException(
        'Tabela de macronutrientes MB não pôde ser lida',
      );
    }

    double? mbMicro(String fieldLabel) {
      final match = RegExp(
        '$fieldLabel\\s+([0-9]+[,\\.][0-9]+|nr)',
        caseSensitive: false,
      ).firstMatch(text);
      final raw = match?.group(1);
      if (raw == null || raw.toLowerCase() == 'nr') return null;
      return _toDouble(raw);
    }

    final amostra = <String, dynamic>{
      'numeroAmostra': '${analiseNumero ?? ''}-1',
      'talhao': talhao?.trim() ?? '',
      'profundidade': profundidade,
      'phCaCl2': _toDouble(_firstMatch(
        text,
        RegExp(r'pH CaCl2\s*([0-9]+,[0-9]+)', caseSensitive: false),
      )),
      'phSmp': _toDouble(_firstMatch(
        text,
        RegExp(r'pH SMP\s*([0-9]+,[0-9]+)', caseSensitive: false),
      )),
      'mo_pct': _toDouble(_firstMatch(
        text,
        RegExp(r'Mat[ée]ria org[âa]nica\s*([0-9]+,[0-9]+)',
            caseSensitive: false),
      )),
      'carbono_gdm3': _toDouble(_firstMatch(
        text,
        RegExp(r'Carbono\s*([0-9]+,[0-9]+)\s*g/dm', caseSensitive: false),
      )),
      'ca': _toDouble(macroValues[0]),
      'mg': _toDouble(macroValues[1]),
      'k': _toDouble(macroValues[2]),
      'pMehlich': _toDouble(macroValues[3]),
      'k_mgdm3': _toDouble(macroValues[4]),
      's020': _toDouble(macroValues[5]),
      'hMaisAl': _toDouble(macroValues[6]),
      'al': _toDouble(macroValues[7]),
      'b':   mbMicro('B'),
      'cu':  mbMicro('Cu'),
      'fe':  mbMicro('Fe'),
      'mn':  mbMicro('Mn'),
      'zn':  mbMicro('Zn'),
      'pRem': _toDouble(_firstMatch(
        text,
        RegExp(r'P-REMANESCENTE\s+([0-9]+[,\.][0-9]+)', caseSensitive: false),
      )),
      'pResina': _toDouble(_firstMatch(
        text,
        RegExp(r'P-RESINA\s+([0-9]+[,\.][0-9]+)', caseSensitive: false),
      )),
      'na': _toDouble(_firstMatch(
        text,
        RegExp(r'S[OÓ]DIO\s+([0-9]+[,\.][0-9]+)', caseSensitive: false),
      )),
      'areiaTotal_pct':
          textureValues.isNotEmpty ? _toDouble(textureValues[0]) : null,
      'silte_pct':
          textureValues.length > 1 ? _toDouble(textureValues[1]) : null,
      'argila_pct':
          textureValues.length > 2 ? _toDouble(textureValues[2]) : null,
    };

    return LabPdfParseResult(
      labId: 'mb',
      laudo: <String, dynamic>{
        'fonte': 'MB Agronegócios',
        'analise': analiseNumero ?? '',
        'dataEmissao': _dateBrToIso(_firstMatch(
              text,
              RegExp(r'DATA SA[ÍI]DA:\s*([0-9]{2}/[0-9]{2}/[0-9]{4})',
                  caseSensitive: false),
            )) ??
            '',
        'proprietario': _firstMatch(
              text,
              RegExp(r'CLIENTE:\s*([^\n\r]+)', caseSensitive: false),
            )?.replaceAll(RegExp(r'CNPJ.*', caseSensitive: false), '').trim() ?? '',
        'propriedade': _firstMatch(
              text,
              RegExp(r'FAZENDA:\s*([^\n\r]+)', caseSensitive: false),
            )?.replaceAll(RegExp(r'TEL.*', caseSensitive: false), '').trim() ?? '',
        'municipio': _firstMatch(
              text,
              RegExp(r'CIDADE:\s*([^\n\r]+)', caseSensitive: false),
            ) ??
            '',
        'responsavel': _firstMatch(
              text,
              RegExp(r'RESPONS[ÁA]VEL:\s*([^\n\r]+)', caseSensitive: false),
            ) ??
            '',
        'amostras': <Map<String, dynamic>>[amostra],
      },
      warnings: const [],
    );
  }

  LabPdfParseResult _parseSolum(String text) {
    final lines = _cleanLines(text);
    final warnings = <String>[];

    // ── Cabeçalho ────────────────────────────────────────────────────
    final laudoNumero = _firstMatch(text, RegExp(r'LAUDO\s+N[ºO]\s*([0-9]+)', caseSensitive: false));
    final proprietario = _firstMatch(
            text, RegExp(r'Propriet[aá]rio:\s*([^\n\r]+?)(?:\s{2,}|\t|Propriedade:|$)', caseSensitive: false))
        ?.trim();
    final propriedade = _firstMatch(
            text, RegExp(r'Propriedade:\s*([^\n\r]+?)(?:\s{2,}|\t|Matr[ií]cula:|$)', caseSensitive: false))
        ?.trim();
    final cliente = _firstMatch(
            text, RegExp(r'Cliente:\s*([^\n\r]+?)(?:\s{2,}|\t|Cidade:|CNPJ|$)', caseSensitive: false))
        ?.trim();
    final municipio = _firstMatch(
            text, RegExp(r'Cidade:\s*([^\n\r]+?)(?:\s{2,}|\t|UF:|$)', caseSensitive: false))
        ?.trim();
    final dataEmissao = _dateBrToIso(_firstMatch(
        text, RegExp(r'Fim Ensaio:\s*([0-9]{2}/[0-9]{2}/[0-9]{4})', caseSensitive: false)));

    // ── IDs e identificações das amostras ────────────────────────────
    final sampleMeta = <String, Map<String, String>>{};
    final identRegex = RegExp(
      r'(\d{5})\s+([^;\n]+?)\s*;\s*([0-9]{2}-[0-9]{2})\s*;',
      caseSensitive: false,
    );
    for (final line in lines) {
      final m = identRegex.firstMatch(line);
      if (m != null) {
        final id = m.group(1)!;
        final talhao = m.group(2)!.trim();
        final prof = m.group(3)!.replaceFirst(RegExp(r'^0+'), ''); // 00-20→0-20
        sampleMeta[id] = {'talhao': talhao, 'profundidade': prof};
      }
    }

    // ── Extração de dados por campo ──────────────────────────────────
    final tableHeaderMatch = RegExp(r'AMOSTRAS\s*((?:\d{5}\s*)+)').firstMatch(text);
    final orderedIds = tableHeaderMatch != null
        ? RegExp(r'\d{5}')
            .allMatches(tableHeaderMatch.group(1) ?? '')
            .map((m) => m.group(0)!)
            .toList()
        : sampleMeta.keys.toList();

    if (orderedIds.isEmpty) {
      throw const LabPdfParseException('IDs Solum não encontrados');
    }
    final n = orderedIds.length;

    List<double?> solumRow(String label) {
      final pattern = RegExp(
        '$label[^\\n\\r]*?(?:IAC|Cálculo|-)\\s+([\\d.,\\s\\-]+)',
        caseSensitive: false,
      );
      final match = pattern.firstMatch(text);
      if (match == null) return List.filled(n, null);
      final tokens = match.group(1)!
          .split(RegExp(r'\s+'))
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .take(n)
          .toList();
      return List.generate(n, (i) {
        if (i >= tokens.length) return null;
        final s = tokens[i];
        if (s == '-') return null;
        return double.tryParse(s.replaceAll(',', '.'));
      });
    }

    final kRow = solumRow(r'K\s+Pot');
    final mgRow = solumRow(r'Mg\s+Magn');
    final caRow = solumRow(r'Ca\s+C[aá]lc');
    final pRow = solumRow(r'P\s+F[oó]sf');
    final alRow = solumRow(r'Al');
    final moRow = solumRow(r'MO\s+Mat');
    final halRow = solumRow(r'H[°o]\s*\+\s*Al');
    final phRow = solumRow(r'pH\s+pH CaCl');
    final phSmpRow = solumRow(r'pH SMP');
    final sRow = solumRow(r'S(?:[\s]+Enxofre)?|Enxofre');
    final bRow = solumRow(r'B(?:[a-zA-Z\s/()]+)?|Boro');
    final cuRow = solumRow(r'Cu(?:[\s]+Cobre)?|Cobre');
    final feRow = solumRow(r'Fe\s+Ferro');
    final mnRow = solumRow(r'Mn\s+Mang');
    final znRow = solumRow(r'Zn\s+Zinco');

    final amostras = <Map<String, dynamic>>[];
    for (var i = 0; i < n; i++) {
      final id = orderedIds[i];
      final meta = sampleMeta[id] ?? {};
      amostras.add({
        'numeroAmostra': id,
        'talhao': meta['talhao'] ?? '',
        'profundidade': meta['profundidade'] ?? '0-20',
        'k_mmolc': kRow[i],
        'mg_mmolc': mgRow[i],
        'ca_mmolc': caRow[i],
        'p_mgdm3': pRow[i],
        'al_mmolc': alRow[i],
        'mo_gdm3': moRow[i],
        'hMaisAl_mmolc': halRow[i],
        'phCaCl2': phRow[i],
        'phSmp': phSmpRow[i],
        's020': sRow[i],
        'b': bRow[i],
        'cu': cuRow[i],
        'fe': feRow[i],
        'mn': mnRow[i],
        'zn': znRow[i],
      });
    }

    if (amostras.isEmpty) {
      throw const LabPdfParseException('Sem amostras válidas no layout Solum');
    }

    return LabPdfParseResult(
      labId: 'solum',
      laudo: {
        'fonte': 'Solum Laboratório S.A.',
        'laudoNumero': laudoNumero ?? '',
        'dataEmissao': dataEmissao ?? '',
        'proprietario': proprietario ?? '',
        'propriedade': propriedade ?? '',
        'cliente': cliente ?? '',
        'municipio': municipio ?? '',
        'amostras': amostras,
      },
      warnings: warnings,
    );
  }

  LabPdfParseResult _parseSellar(String text) {
    final lines = _cleanLines(text);
    final tokens = _cleanTokens(text);
    final warnings = <String>[];

    final start = lines.indexWhere(
      (line) => line.toLowerCase().contains('análise granulométrica'),
    );
    final end = lines.indexWhere((line) => line.toLowerCase() == 'média');
    if (start < 0 || end <= start) {
      throw const LabPdfParseException('Bloco principal Sellar não encontrado');
    }

    final blockTokens = lines
        .sublist(start + 1, end)
        .expand((line) => line.split(RegExp(r'\s+')))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);

    final ids = <String>[];
    var idx = 0;
    while (idx < blockTokens.length &&
        RegExp(r'^\d{5}$').hasMatch(blockTokens[idx])) {
      ids.add(blockTokens[idx]);
      idx++;
    }

    if (ids.isEmpty) {
      throw const LabPdfParseException('Número Sellar não identificado');
    }

    final n = ids.length;
    final numeric = blockTokens
        .sublist(idx)
        .where(_looksLikeValueToken)
        .toList(growable: false);

    if (numeric.length < (n * 20)) {
      throw const LabPdfParseException('Dados numéricos Sellar insuficientes');
    }

    final ph = _takeGroup(numeric, 0, n);
    final pMeh = _takeGroup(numeric, 1, n);
    final pResina = _extractTripletAfter(tokens, 'P resina');
    final ca = _takeGroup(numeric, 3, n);
    final mg = _takeGroup(numeric, 4, n);
    final al = _takeGroup(numeric, 5, n);
    final hMaisAl = _takeGroup(numeric, 6, n);
    final mo = _takeGroup(numeric, 7, n);

    final sampleBlockStart = n * 12;
    final microAndRatios = numeric.skip(sampleBlockStart).take(n * 8).toList();
    final textures =
        numeric.skip(sampleBlockStart + (n * 8)).take(n * 3).toList();

    final talhao = _extractSellarTalhoes(lines, n);
    final kValues = _extractTripletAfter(tokens, 'K');
    final sValues = _extractTripletAfter(tokens, 'S-SO4-2');
    final coValues = _extractTripletAfter(tokens, 'C.O.');
    final bValues = _extractTripletAfterRegex(tokens, RegExp(r'^(B|Boro|B\s+mg/dm3|B\s+dtpa)$', caseSensitive: false));

    final amostras = <Map<String, dynamic>>[];
    for (var i = 0; i < n; i++) {
      final base = i * 8;
      final textureBase = i * 3;
      amostras.add(<String, dynamic>{
        'numeroSellar': ids[i],
        'identificacao': talhao.length > i ? talhao[i] : 'Amostra ${i + 1}',
        'profundidade': '0-20',
        'phCaCl2': _toDouble(ph[i]),
        'pMehlich': _toDouble(pMeh[i]),
        'pResina': pResina.length > i ? _toDouble(pResina[i]) : null,
        'k_mgdm3': kValues.length > i ? _toDouble(kValues[i]) : null,
        'ca': _toDouble(ca[i]),
        'mg': _toDouble(mg[i]),
        'al': _toDouble(al[i]),
        'hMaisAl': _toDouble(hMaisAl[i]),
        'materiaOrganica': _toDouble(mo[i]),
        's020': sValues.length > i ? _toDouble(sValues[i]) : null,
        'carbonoOrganico': coValues.length > i ? _toDouble(coValues[i]) : null,
        'b': bValues.length > i
            ? _toDouble(bValues[i])
            : (microAndRatios.length > base ? _toDouble(microAndRatios[base]) : null),
        'cu': microAndRatios.length > base + 1
            ? _toDouble(microAndRatios[base + 1])
            : null,
        'fe': microAndRatios.length > base + 2
            ? _toDouble(microAndRatios[base + 2])
            : null,
        'mn': microAndRatios.length > base + 3
            ? _toDouble(microAndRatios[base + 3])
            : null,
        'zn': microAndRatios.length > base + 4
            ? _toDouble(microAndRatios[base + 4])
            : null,
        'argila': textures.length > textureBase
            ? _toDouble(textures[textureBase])
            : null,
        'silte': textures.length > textureBase + 1
            ? _toDouble(textures[textureBase + 1])
            : null,
        'areiaTotal': textures.length > textureBase + 2
            ? _toDouble(textures[textureBase + 2])
            : null,
      });
    }

    if (amostras.isEmpty) {
      throw const LabPdfParseException('Sem amostras válidas no layout Sellar');
    }

    final laudo = <String, dynamic>{
      'fonte': 'Sellar Análises Agrícolas',
      'laudoNumero': _valueAfterLabel(lines, 'Laudo Nº') ?? '',
      'dataEntrada': _dateBrToIso(_valueAfterLabel(lines, 'Entrada:')) ?? '',
      'dataGeracao': _dateBrToIso(_valueAfterLabel(lines, 'Gerado:')) ?? '',
      'solicitante': _valueAfterLabel(lines, 'Solicitante:') ?? '',
      'proprietario': _valueAfterLabel(lines, 'Proprietário:') ?? '',
      'propriedade': _valueAfterLabel(lines, 'Propriedade:') ?? '',
      'municipio': _valueAfterLabel(lines, 'Município:') ?? '',
      'convenio': _valueAfterLabel(lines, 'Convênio:') ?? '',
      'amostras': amostras,
    };

    if (kValues.length != n || sValues.length != n) {
      warnings.add('sellar_triplet_incompleto');
    }

    return LabPdfParseResult(
      labId: 'sellar',
      laudo: laudo,
      warnings: warnings,
    );
  }

  List<String> _extractSellarTalhoes(List<String> lines, int n) {
    // No PDF Sellar: "Identificação da Amostra" aparece ANTES de "Tipo de Solo"
    // Os talhões ficam entre essas duas marcações
    final idxIdentificacao = lines.indexWhere(
      (line) => line.toLowerCase().contains('identificação da amostra'),
    );
    final idxTipoDeSolo = lines.indexWhere(
      (line) => line.toLowerCase().contains('tipo de solo'),
    );

    // Tentar ordem correta do PDF (identificacao antes de tipo de solo)
    int start, end;
    if (idxIdentificacao >= 0 &&
        idxTipoDeSolo > idxIdentificacao) {
      start = idxIdentificacao;
      end = idxTipoDeSolo;
    } else if (idxTipoDeSolo >= 0 &&
        idxIdentificacao > idxTipoDeSolo) {
      // Fallback: ordem inversa
      start = idxTipoDeSolo;
      end = idxIdentificacao;
    } else {
      return const [];
    }

    final talhoes = lines
        .sublist(start + 1, end)
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .where((line) => !RegExp(r'^\d+([,\.]\d+)?$').hasMatch(line))
        .where((line) => !_looksLikeValueToken(line))
        .toList(growable: false);

    if (talhoes.length < n) return talhoes;
    return talhoes.take(n).toList(growable: false);
  }

  List<String> _extractTripletAfter(List<String> tokens, String label) {
    for (var i = 0; i < tokens.length; i++) {
      if (tokens[i].toLowerCase() == label.toLowerCase()) {
        final out = <String>[];
        for (var j = i + 1; j < tokens.length && out.length < 3; j++) {
          if (_looksLikeValueToken(tokens[j])) {
            out.add(tokens[j]);
          }
        }
        return out;
      }
    }
    return const [];
  }

  List<String> _extractTripletAfterRegex(List<String> tokens, RegExp pattern) {
    for (var i = 0; i < tokens.length; i++) {
      if (pattern.hasMatch(tokens[i])) {
        final out = <String>[];
        for (var j = i + 1; j < tokens.length && out.length < 3; j++) {
          if (_looksLikeValueToken(tokens[j])) {
            out.add(tokens[j]);
          }
        }
        return out;
      }
    }
    return const [];
  }

  List<String> _takeGroup(List<String> values, int group, int size) {
    final start = group * size;
    if (start + size > values.length) return List<String>.filled(size, '');
    return values.sublist(start, start + size);
  }

  Map<String, int> _buildColMapFromLines(List<String> headerLines) {
    // Juntar todas as linhas e tokenizar por espaços
    final tokens = headerLines
        .join(' ')
        .split(RegExp(r'\s+'))
        .map((t) => t.trim().toLowerCase())
        .where((t) => t.isNotEmpty)
        .toList();
    final map = <String, int>{};
    for (var i = 0; i < tokens.length; i++) {
      map[tokens[i]] = i;
    }
    return map;
  }

  List<_TableSection> _extractTableSections({
    required List<String> lines,
    required RegExp sampleIdRegex,
  }) {
    final sections = <_TableSection>[];
    var i = 0;

    while (i < lines.length) {
      if (lines[i].toLowerCase() != 'amostra') {
        i++;
        continue;
      }

      var startData = -1;
      for (var j = i + 1; j < lines.length; j++) {
        if (sampleIdRegex.hasMatch(lines[j])) {
          startData = j;
          break;
        }
        if (lines[j].toLowerCase() == 'amostra' && j > i + 1) {
          break;
        }
      }

      if (startData == -1) {
        i++;
        continue;
      }

      var endData = lines.length;
      for (var j = startData + 1; j < lines.length; j++) {
        final lower = lines[j].toLowerCase();
        if (lower == 'amostra' ||
            lower.startsWith('relatório n') ||
            lower.startsWith('software ultra lims') ||
            lower.startsWith('referência metodológica') ||
            lower.startsWith('página')) {
          endData = j;
          break;
        }
      }

      final header = lines.sublist(i, startData);
      final dataTokens = lines.sublist(startData, endData);
      final rows = <List<String>>[];

      final rowStarts = <int>[];
      for (var j = 0; j < dataTokens.length; j++) {
        if (sampleIdRegex.hasMatch(dataTokens[j])) {
          rowStarts.add(j);
        }
      }

      for (var j = 0; j < rowStarts.length; j++) {
        final rowStart = rowStarts[j];
        final rowEnd =
            j + 1 < rowStarts.length ? rowStarts[j + 1] : dataTokens.length;
        final row = dataTokens.sublist(rowStart, rowEnd);
        if (row.length >= 9) {
          rows.add(row);
        }
      }

      sections.add(_TableSection(header: header, rows: rows));
      i = endData;
    }

    return sections;
  }

  _ParsedRow? _parseRowWithTailValues(List<String> row,
      {required int valueCount}) {
    if (row.length < (1 + valueCount)) return null;
    final sampleId = row.first;
    final values = row.sublist(row.length - valueCount);
    final prefix = row.sublist(1, row.length - valueCount);

    final depthInfo = _extractDepth(prefix);
    final depth = depthInfo?.depth ?? '';
    final depthStart = depthInfo?.start ?? -1;
    final depthEnd = depthInfo?.end ?? -1;

    String talhao;
    if (depthInfo == null) {
      talhao = prefix.join(' ').trim();
    } else if (depthEnd < prefix.length - 1) {
      talhao = prefix.sublist(depthEnd + 1).join(' ').trim();
    } else {
      talhao = prefix.sublist(0, depthStart).join(' ').trim();
    }

    return _ParsedRow(
      sampleId: sampleId,
      talhao: talhao,
      profundidade: depth.isEmpty ? '' : depth,
      values: values,
    );
  }

  _DepthInfo? _extractDepth(List<String> tokens) {
    for (var i = 0; i < tokens.length; i++) {
      if (RegExp(r'^\d{1,2}-\d{1,2}$').hasMatch(tokens[i])) {
        return _DepthInfo(
          depth: _normalizeDepth(tokens[i]) ?? '',
          start: i,
          end: i,
        );
      }
      if (i + 2 < tokens.length &&
          RegExp(r'^\d{1,2}$').hasMatch(tokens[i]) &&
          tokens[i + 1] == '-' &&
          RegExp(r'^\d{1,2}$').hasMatch(tokens[i + 2])) {
        return _DepthInfo(
          depth: '${tokens[i]}-${tokens[i + 2]}',
          start: i,
          end: i + 2,
        );
      }
    }
    return null;
  }

  String? _valueAfterLabel(List<String> lines, String label) {
    final idx = lines.indexWhere(
      (line) => line.toLowerCase() == label.toLowerCase(),
    );
    if (idx < 0) return null;
    for (var i = idx + 1; i < lines.length && i <= idx + 3; i++) {
      final line = lines[i].trim();
      if (line.isNotEmpty && !line.endsWith(':')) return line;
    }
    return null;
  }

  String _sliceByMarkers(
    String text, {
    required String startMarker,
    required String endMarker,
  }) {
    final start = text.indexOf(startMarker);
    if (start < 0) return '';
    final end = text.indexOf(endMarker, start + startMarker.length);
    if (end < 0) return text.substring(start + startMarker.length);
    return text.substring(start + startMarker.length, end);
  }

  List<String> _cleanLines(String text) {
    return text
        .replaceAll('\u0000', '')
        .replaceAll('ﬁ', 'fi')
        .replaceAll('ﬂ', 'fl')
        .split(RegExp(r'[\r\n]+'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
  }

  List<String> _cleanTokens(String text) {
    return text
        .replaceAll('\u0000', '')
        .replaceAll('ﬁ', 'fi')
        .replaceAll('ﬂ', 'fl')
        .split(RegExp(r'\s+'))
        .map((token) => token.trim())
        .where((token) => token.isNotEmpty)
        .toList(growable: false);
  }

  String _compact(String text) {
    return text
        .replaceAll('\u0000', '')
        .replaceAll('ﬁ', 'fi')
        .replaceAll('ﬂ', 'fl')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  bool _isNumberToken(String input) {
    return RegExp(r'^-?\d+(?:[.,]\d+)?$').hasMatch(input);
  }

  bool _looksLikeValueToken(String token) {
    final normalized = token.trim().toLowerCase();
    if (normalized == '-' || normalized == 'nr' || normalized == 'ns') {
      return true;
    }
    return _isNumberToken(normalized);
  }

  double? _toDouble(String? value) {
    if (value == null) return null;
    final raw = value.trim().toLowerCase();
    if (raw.isEmpty || raw == '-' || raw == 'nr' || raw == 'ns' || raw == 'l.q' || raw == 'n.a.') return null;

    if (raw.contains(',')) {
      final normalized = raw.replaceAll('.', '').replaceAll(',', '.');
      return double.tryParse(normalized);
    }
    return double.tryParse(raw);
  }

  String? _dateBrToIso(String? value) {
    if (value == null) return null;
    final m = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(value.trim());
    if (m == null) return null;
    return '${m.group(3)}-${m.group(2)}-${m.group(1)}';
  }

  String? _normalizeDepth(String? raw) {
    if (raw == null) return null;
    final cleaned = raw.replaceAll('cm', '').trim();
    final match = RegExp(r'(\d{1,2})\s*-\s*(\d{1,2})').firstMatch(cleaned);
    if (match != null) {
      return '${match.group(1)}-${match.group(2)}';
    }
    final matchA = RegExp(r'(\d{1,2})\s*a\s*(\d{1,2})').firstMatch(cleaned);
    if (matchA != null) {
      return '${matchA.group(1)}-${matchA.group(2)}';
    }
    return cleaned.isEmpty ? null : cleaned;
  }

  String? _firstMatch(String text, RegExp regex) {
    final match = regex.firstMatch(text);
    if (match == null || match.groupCount < 1) return null;
    return match.group(1)?.trim();
  }
}

class LabPdfParseException implements Exception {
  final String message;

  const LabPdfParseException(this.message);

  @override
  String toString() => message;
}

class _DepthInfo {
  final String depth;
  final int start;
  final int end;

  const _DepthInfo({
    required this.depth,
    required this.start,
    required this.end,
  });
}

class _ParsedRow {
  final String sampleId;
  final String talhao;
  final String profundidade;
  final List<String> values;

  const _ParsedRow({
    required this.sampleId,
    required this.talhao,
    required this.profundidade,
    required this.values,
  });
}

class _TableSection {
  final List<String> header;
  final List<List<String>> rows;

  const _TableSection({
    required this.header,
    required this.rows,
  });
}
