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
        final normalizedDepth = profundidade?.trim() ?? '';
        return <String, dynamic>{
          'numeroAmostra': sampleId,
          'talhao': talhao ?? '',
          'profundidade': normalizedDepth.isEmpty ? '0-20' : normalizedDepth,
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
      final normalizedHeader = _normalizeHeader(header);

      final hasPMehCol = _hasPMehColumn(normalizedHeader);
      final hasBoroCol = _hasHeaderToken(normalizedHeader, 'b') ||
          normalizedHeader.contains('boro') ||
          normalizedHeader.contains('b dtpa');
      final isTablePhK = normalizedHeader.contains('k nh4cl');
      final hasPRemCol = normalizedHeader.contains('p rem');
      final hasPResCol = normalizedHeader.contains('p res') ||
          normalizedHeader.contains('p resina') ||
          normalizedHeader.contains('resina');
      final isTablePRem = hasPRemCol || hasPResCol;
      final isTableExataBaPMeh = hasPMehCol &&
          !isTablePRem &&
          (_hasHeaderToken(normalizedHeader, 'cu') ||
              _hasHeaderToken(normalizedHeader, 'fe') ||
              _hasHeaderToken(normalizedHeader, 'mn') ||
              _hasHeaderToken(normalizedHeader, 'zn')) &&
          (_hasHeaderToken(normalizedHeader, 'na') ||
              normalizedHeader.contains('argila') ||
              _hasHeaderToken(normalizedHeader, 's'));
      final isTableMicrosA = isTableExataBaPMeh ||
          normalizedHeader.contains('fe meh') ||
          (normalizedHeader.contains('cu meh') &&
              normalizedHeader.contains('mn meh'));
      final isTableMehTexture = _hasHeaderToken(normalizedHeader, 'mn') &&
          _hasHeaderToken(normalizedHeader, 'zn') &&
          _hasHeaderToken(normalizedHeader, 'na') &&
          normalizedHeader.contains('argila') &&
          normalizedHeader.contains('silte') &&
          normalizedHeader.contains('areia');
      final isTableDtpa = normalizedHeader.contains('cu dtpa') &&
          normalizedHeader.contains('fe dtpa') &&
          normalizedHeader.contains('mn dtpa') &&
          normalizedHeader.contains('zn dtpa');
      final isTableSilteAreia = normalizedHeader.contains('silte') &&
          normalizedHeader.contains('areia');

      for (final row in section.rows) {
        final valueCount = isTableDtpa ? 4 : 8;
        final parsed = _parseRowWithTailValues(row, valueCount: valueCount);
        if (parsed == null) continue;

        if (isTablePhK) {
          mergeSample(
            parsed.sampleId,
            _exataPhKFields(parsed.values),
            talhao: parsed.talhao,
            profundidade: parsed.profundidade,
          );
          continue;
        }

        if (isTablePRem) {
          mergeSample(
            parsed.sampleId,
            hasPResCol
                ? _exataPRemFields(parsed.values)
                : _exataPRemSemResinaFields(parsed.values),
            talhao: parsed.talhao,
            profundidade: parsed.profundidade,
          );
          continue;
        }

        if (isTableMehTexture) {
          mergeSample(
            parsed.sampleId,
            _exataMehTextureFields(parsed.values),
            talhao: parsed.talhao,
            profundidade: parsed.profundidade,
          );
          continue;
        }

        if (isTableDtpa) {
          mergeSample(
            parsed.sampleId,
            _exataDtpaFields(parsed.values),
            talhao: parsed.talhao,
            profundidade: parsed.profundidade,
          );
          continue;
        }

        if (isTableMicrosA && !isTableSilteAreia) {
          Map<String, dynamic> fields;

          if (hasPMehCol && !hasBoroCol) {
            fields = _exataMicrosBaFields(parsed.values);
          } else if (hasPMehCol && hasBoroCol) {
            fields = _exataMicrosGoFields(parsed.values);
          } else {
            fields = _exataMicrosTextureFields(parsed.values);
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
          mergeSample(
            parsed.sampleId,
            _exataMicrosTextureWithGranulometryFields(parsed.values),
            talhao: parsed.talhao,
            profundidade: parsed.profundidade,
          );
          continue;
        }

        if (isTableSilteAreia) {
          mergeSample(
            parsed.sampleId,
            _exataSilteAreiaFields(parsed.values),
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
          's020': values.length > 17 ? _toDouble(values[17]) : null,
          'b': values.length > 18 ? _toDouble(values[18]) : null,
          'cu': values.length > 19 ? _toDouble(values[19]) : null,
          'fe': values.length > 20 ? _toDouble(values[20]) : null,
          'mn': values.length > 21 ? _toDouble(values[21]) : null,
          'zn': values.length > 22 ? _toDouble(values[22]) : null,
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
    final macroValues = macroBlock
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
      'b': mbMicro('B'),
      'cu': mbMicro('Cu'),
      'fe': mbMicro('Fe'),
      'mn': mbMicro('Mn'),
      'zn': mbMicro('Zn'),
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
            )?.replaceAll(RegExp(r'CNPJ.*', caseSensitive: false), '').trim() ??
            '',
        'propriedade': _firstMatch(
              text,
              RegExp(r'FAZENDA:\s*([^\n\r]+)', caseSensitive: false),
            )?.replaceAll(RegExp(r'TEL.*', caseSensitive: false), '').trim() ??
            '',
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
    final laudoNumero = _firstMatch(
        text, RegExp(r'LAUDO\s+N[ºO]\s*([0-9]+)', caseSensitive: false));
    final proprietario = _firstMatch(
            text,
            RegExp(
                r'Propriet[aá]rio:\s*([^\n\r]+?)(?:\s{2,}|\t|Propriedade:|$)',
                caseSensitive: false))
        ?.trim();
    final propriedade = _firstMatch(
            text,
            RegExp(r'Propriedade:\s*([^\n\r]+?)(?:\s{2,}|\t|Matr[ií]cula:|$)',
                caseSensitive: false))
        ?.trim();
    final cliente = _firstMatch(
            text,
            RegExp(r'Cliente:\s*([^\n\r]+?)(?:\s{2,}|\t|Cidade:|CNPJ|$)',
                caseSensitive: false))
        ?.trim();
    final municipio = _firstMatch(
            text,
            RegExp(r'Cidade:\s*([^\n\r]+?)(?:\s{2,}|\t|UF:|$)',
                caseSensitive: false))
        ?.trim();
    final dataEmissao = _dateBrToIso(_firstMatch(
        text,
        RegExp(r'Fim Ensaio:\s*([0-9]{2}/[0-9]{2}/[0-9]{4})',
            caseSensitive: false)));

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
        final prof = _normalizeDepth(m.group(3)!) ?? m.group(3)!;
        sampleMeta[id] = {'talhao': talhao, 'profundidade': prof};
      }
    }

    final tableBlocks = _solumTableBlocks(text);
    if (tableBlocks.isEmpty && sampleMeta.isEmpty) {
      throw const LabPdfParseException('IDs Solum não encontrados');
    }

    List<double?> solumRow(String block, String label, int count) {
      final pattern = RegExp(
        '(?:$label)[^\\n\\r]*?(?:IAC|Cálculo|-)\\s+([\\d.,\\s\\-]+)',
        caseSensitive: false,
      );
      final match = pattern.firstMatch(block);
      if (match != null) {
        final tokens = match
            .group(1)!
            .split(RegExp(r'\s+'))
            .map((t) => t.trim())
            .where((t) => t.isNotEmpty)
            .toList();
        while (tokens.length > count && tokens.first == '-') {
          tokens.removeAt(0);
        }
        return List.generate(count, (i) {
          if (i >= tokens.length) return null;
          final s = tokens[i];
          if (s == '-') return null;
          return double.tryParse(s.replaceAll(',', '.'));
        });
      }

      return _solumVerticalRow(block, label, count);
    }

    final amostras = <Map<String, dynamic>>[];
    for (final block in tableBlocks) {
      final orderedIds = _solumOrderedIds(block);
      if (orderedIds.isEmpty) continue;
      final n = orderedIds.length;

      final kRow = solumRow(block, r'^K$|K\s+Pot', n);
      final mgRow = solumRow(block, r'^Mg$|Mg\s+Magn', n);
      final caRow = solumRow(block, r'^Ca$|Ca\s+C[aá]lc', n);
      final pRow = solumRow(block, r'^P$|P\s+F[oó]sf', n);
      final alRow = solumRow(block, r'Al(?:³|\s+Alum)', n);
      final moRow = solumRow(block, r'^MO$|MO\s+Mat', n);
      final halRow = solumRow(block, r'H[°o]\s*\+\s*Al', n);
      final phRow = solumRow(block, r'pH\s+pH CaCl|pH\s+CaCl2', n);
      final phSmpRow = solumRow(block, r'pH\s+SMP', n);
      final vPercentRow =
          solumRow(block, r'V\s*%|Satura[çc][ãa]o\s+de\s+Bases', n);
      final ctcRow = solumRow(block, r'C\.?\s*T\.?\s*C\.?', n);
      final hRow = solumRow(block, r'^H\s*°?$|H\s*[°o]\s+Hidrog', n);
      final sbRow = solumRow(block, r'S\.?\s*B\.?|Soma\s+de\s+Bases', n);
      final mPercentRow =
          solumRow(block, r'm\s*%|Satura[çc][ãa]o\s+por\s+Al', n);
      final sRow = solumRow(block, r'^S$|S\s+Enxofre|Enxofre', n);
      final bRow = solumRow(block, r'^B$|B\s+Boro|Boro', n);
      final cuRow = solumRow(block, r'^Cu$|Cu\s+Cobre|Cobre', n);
      final feRow = solumRow(block, r'^Fe$|Fe\s+Ferro', n);
      final mnRow = solumRow(block, r'^Mn$|Mn\s+Mang', n);
      final znRow = solumRow(block, r'^Zn$|Zn\s+Zinco', n);

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
          'h_mmolc': hRow[i] ?? _subtractNullable(halRow[i], alRow[i]),
          'phCaCl2': phRow[i],
          'phSmp': phSmpRow[i],
          'vPercent': vPercentRow[i],
          'ctc_mmolc': ctcRow[i],
          'sb_mmolc': sbRow[i],
          'mPercent': mPercentRow[i],
          's020': sRow[i],
          'b': bRow[i],
          'cu': cuRow[i],
          'fe': feRow[i],
          'mn': mnRow[i],
          'zn': znRow[i],
        });
      }
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

  List<String> _solumTableBlocks(String text) {
    final matches = RegExp(
      r'(?:DETERMINA[ÇC][ÕO]ES[\s\S]*?AMOSTRAS|AMOSTRAS)[\s\S]*?(?=Notas:|C[ÓO]DIGO:|$)',
      caseSensitive: false,
    ).allMatches(text);
    return matches
        .map((match) => match.group(0) ?? '')
        .where((block) => _solumOrderedIds(block).isNotEmpty)
        .toList(growable: false);
  }

  List<String> _solumOrderedIds(String block) {
    final lines = _cleanLines(block);
    for (final line in lines) {
      final tokens = line.split(RegExp(r'\s+'));
      if (tokens.length > 1 &&
          tokens.every((token) => RegExp(r'^\d{5}$').hasMatch(token))) {
        return tokens;
      }
    }

    final amostrasIndex = lines.lastIndexWhere(
      (line) => line.toLowerCase() == 'amostras',
    );
    if (amostrasIndex >= 0) {
      final ids = <String>[];
      for (var i = amostrasIndex + 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (RegExp(r'^\d{5}$').hasMatch(line)) {
          ids.add(line);
          continue;
        }
        if (ids.isNotEmpty) break;
      }
      if (ids.isNotEmpty) return ids;
    }

    return const [];
  }

  List<double?> _solumVerticalRow(String block, String label, int count) {
    final lines = _cleanLines(block);
    final labelRegex = RegExp(label, caseSensitive: false);
    final start = lines.indexWhere((line) => labelRegex.hasMatch(line));
    if (start < 0) return List.filled(count, null);

    var valuesStarted = false;
    final tokens = <String>[];
    for (var i = start + 1; i < lines.length; i++) {
      final line = lines[i].trim();
      final normalized = line.toLowerCase();
      if (!valuesStarted) {
        if (normalized == 'iac' ||
            normalized == 'cálculo' ||
            normalized == 'calculo' ||
            line == '-') {
          valuesStarted = true;
        }
        continue;
      }

      if (_looksLikeValueToken(line)) {
        tokens.add(line);
        continue;
      }
      if (tokens.isNotEmpty) break;
    }

    while (tokens.length > count && tokens.first == '-') {
      tokens.removeAt(0);
    }
    return List.generate(count, (i) {
      if (i >= tokens.length) return null;
      return _toDouble(tokens[i]);
    });
  }

  LabPdfParseResult _parseSellar(String text) {
    final lines = _cleanLines(text);
    final warnings = <String>[];

    final ids = _extractSellarIds(lines);

    if (ids.isEmpty) {
      throw const LabPdfParseException('Número Sellar não identificado');
    }

    final n = ids.length;
    final vertical = _extractSellarVerticalValues(lines, n);

    final phAgua = _extractSellarRowValues(
        lines, RegExp(r'^pH\s+Á?gua\b', caseSensitive: false), n);
    final phCaCl2 = _extractSellarRowValues(
        lines, RegExp(r'^pH\s+CaCl\s*2\b', caseSensitive: false), n);
    final pTotal = _extractSellarRowValues(
        lines, RegExp(r'^P\s+Total\b', caseSensitive: false), n);
    final pMeh = _extractSellarRowValues(
        lines, RegExp(r'^P\s+meh\b', caseSensitive: false), n);
    final pResina = _extractSellarRowValues(
        lines, RegExp(r'^P\s+resina\b', caseSensitive: false), n);
    final sValues = _extractSellarRowValues(
        lines, RegExp(r'^S-SO\s*4', caseSensitive: false), n);
    final kRows = _extractSellarRowsValues(
        lines, RegExp(r'^K\b', caseSensitive: false), n);
    final kMgDm3 = kRows.isNotEmpty ? kRows.first : const <String>[];
    final kCmolc = kRows.length > 1 ? kRows[1] : const <String>[];
    final ca = _extractSellarRowValues(
        lines, RegExp(r'^Ca\b', caseSensitive: false), n);
    final mg = _extractSellarRowValues(
        lines, RegExp(r'^Mg\b', caseSensitive: false), n);
    final al = _extractSellarRowValues(
        lines, RegExp(r'^Al\b', caseSensitive: false), n);
    final hMaisAl = _extractSellarRowValues(
        lines, RegExp(r'^H\+Al\b', caseSensitive: false), n);
    final mo = _extractSellarRowValues(
        lines, RegExp(r'^M\.O\.', caseSensitive: false), n);
    final coValues = _extractSellarRowValues(
        lines, RegExp(r'^C\.O\.', caseSensitive: false), n);
    final bValues = _extractSellarRowValues(
        lines, RegExp(r'^B\b', caseSensitive: false), n);
    final cu = _extractSellarRowValues(
        lines, RegExp(r'^Cu\b', caseSensitive: false), n);
    final fe = _extractSellarRowValues(
        lines, RegExp(r'^Fe\b', caseSensitive: false), n);
    final mn = _extractSellarRowValues(
        lines, RegExp(r'^Mn\b', caseSensitive: false), n);
    final zn = _extractSellarRowValues(
        lines, RegExp(r'^Zn\b', caseSensitive: false), n);
    final sb = _extractSellarRowValues(
        lines, RegExp(r'^SB\b', caseSensitive: false), n);
    final ctcRows = _extractSellarRowsValues(
        lines, RegExp(r'^CTC\b', caseSensitive: false), n);
    final ctc = ctcRows.isNotEmpty ? ctcRows.first : const <String>[];
    final ctcEfetiva = ctcRows.length > 1 ? ctcRows[1] : const <String>[];
    final v = _extractSellarRowValues(
        lines, RegExp(r'^V\b', caseSensitive: false), n);
    final m =
        _extractSellarRowValues(lines, RegExp(r'^m\b', caseSensitive: true), n);
    final caMg = _extractSellarRowValues(
        lines, RegExp(r'^Ca/Mg\b', caseSensitive: false), n);
    final caK = _extractSellarRowValues(
        lines, RegExp(r'^Ca/K\b', caseSensitive: false), n);
    final mgK = _extractSellarRowValues(
        lines, RegExp(r'^Mg/K\b', caseSensitive: false), n);
    final argila = _extractSellarRowValues(
        lines, RegExp(r'^Argila\b', caseSensitive: false), n);
    final silte = _extractSellarRowValues(
        lines, RegExp(r'^Silte\b', caseSensitive: false), n);
    final areia = _extractSellarRowValues(
        lines, RegExp(r'^Areia\s+Total\b', caseSensitive: false), n);
    final classificacaoTextura = _extractSellarTextRowValues(
        lines, RegExp(r'^Classificação\b', caseSensitive: false), n);
    final tipoSoloMapa = _extractSellarTextRowValues(lines,
        RegExp(r'^Tipo\s+de\s+Solo\s+\(MAPA\)', caseSensitive: false), n);

    final talhao = _extractSellarTalhoes(lines, n);

    final amostras = <Map<String, dynamic>>[];
    for (var i = 0; i < n; i++) {
      amostras.add(<String, dynamic>{
        'numeroSellar': ids[i],
        'identificacao': talhao.length > i ? talhao[i] : 'Amostra ${i + 1}',
        'profundidade': '0-20',
        'phAgua': phAgua.length > i ? _toDouble(phAgua[i]) : null,
        'phCaCl2': phCaCl2.length > i
            ? _toDouble(phCaCl2[i])
            : _verticalAt(vertical, 'phCaCl2', i),
        'pTotal': pTotal.length > i ? _toDouble(pTotal[i]) : null,
        'pMehlich': pMeh.length > i
            ? _toDouble(pMeh[i])
            : _verticalAt(vertical, 'pMehlich', i),
        'pResina': pResina.length > i ? _toDouble(pResina[i]) : null,
        'k_mgdm3': kMgDm3.length > i
            ? _toDouble(kMgDm3[i])
            : _verticalAt(vertical, 'k_mgdm3', i),
        'k': kCmolc.length > i
            ? _toDouble(kCmolc[i])
            : _verticalAt(vertical, 'k', i),
        'ca': ca.length > i ? _toDouble(ca[i]) : _verticalAt(vertical, 'ca', i),
        'mg': mg.length > i ? _toDouble(mg[i]) : _verticalAt(vertical, 'mg', i),
        'al': al.length > i ? _toDouble(al[i]) : _verticalAt(vertical, 'al', i),
        'hMaisAl': hMaisAl.length > i
            ? _toDouble(hMaisAl[i])
            : _verticalAt(vertical, 'hMaisAl', i),
        'materiaOrganica': mo.length > i
            ? _toDouble(mo[i])
            : _verticalAt(vertical, 'materiaOrganica', i),
        's020': sValues.length > i ? _toDouble(sValues[i]) : null,
        'carbonoOrganico': coValues.length > i ? _toDouble(coValues[i]) : null,
        'b': bValues.length > i
            ? _toDouble(bValues[i])
            : _verticalAt(vertical, 'b', i),
        'cu': cu.length > i ? _toDouble(cu[i]) : _verticalAt(vertical, 'cu', i),
        'fe': fe.length > i ? _toDouble(fe[i]) : _verticalAt(vertical, 'fe', i),
        'mn': mn.length > i ? _toDouble(mn[i]) : _verticalAt(vertical, 'mn', i),
        'zn': zn.length > i ? _toDouble(zn[i]) : _verticalAt(vertical, 'zn', i),
        'sb': sb.length > i ? _toDouble(sb[i]) : _verticalAt(vertical, 'sb', i),
        'ctc': ctc.length > i
            ? _toDouble(ctc[i])
            : _verticalAt(vertical, 'ctc', i),
        'ctcEfetiva': ctcEfetiva.length > i ? _toDouble(ctcEfetiva[i]) : null,
        'vPercent': v.length > i
            ? _toDouble(v[i])
            : _verticalAt(vertical, 'vPercent', i),
        'mPercent': m.length > i
            ? _toDouble(m[i])
            : _verticalAt(vertical, 'mPercent', i),
        'caMg': caMg.length > i
            ? _toDouble(caMg[i])
            : _verticalAt(vertical, 'caMg', i),
        'caK': caK.length > i
            ? _toDouble(caK[i])
            : _verticalAt(vertical, 'caK', i),
        'mgK': mgK.length > i
            ? _toDouble(mgK[i])
            : _verticalAt(vertical, 'mgK', i),
        'argila': argila.length > i
            ? _toDouble(argila[i])
            : _verticalAt(vertical, 'argila', i),
        'silte': silte.length > i
            ? _toDouble(silte[i])
            : _verticalAt(vertical, 'silte', i),
        'areiaTotal': areia.length > i
            ? _toDouble(areia[i])
            : _verticalAt(vertical, 'areiaTotal', i),
        'classificacaoTextura':
            classificacaoTextura.length > i ? classificacaoTextura[i] : null,
        'tipoSoloMapa': tipoSoloMapa.length > i ? tipoSoloMapa[i] : null,
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

    if (kCmolc.length != n || sValues.length != n || phCaCl2.length != n) {
      warnings.add('sellar_triplet_incompleto');
    }

    return LabPdfParseResult(
      labId: 'sellar',
      laudo: laudo,
      warnings: warnings,
    );
  }

  List<String> _extractSellarIds(List<String> lines) {
    for (final line in lines) {
      if (!line.toLowerCase().startsWith('número sellar') &&
          !line.toLowerCase().startsWith('numero sellar')) {
        continue;
      }
      final sameLineIds = RegExp(r'\b\d{5}\b')
          .allMatches(line)
          .map((match) => match.group(0)!)
          .toList(growable: false);
      if (sameLineIds.isNotEmpty) return sameLineIds;

      final currentIndex = lines.indexOf(line);
      final nextIds = <String>[];
      for (var i = currentIndex + 1;
          i < lines.length && i <= currentIndex + 4;
          i++) {
        final ids = RegExp(r'\b\d{5}\b')
            .allMatches(lines[i])
            .map((match) => match.group(0)!)
            .toList(growable: false);
        nextIds.addAll(ids);
        if (nextIds.isNotEmpty) return nextIds;
      }
    }

    for (final line in lines.take(30)) {
      final ids = RegExp(r'\b\d{5}\b')
          .allMatches(line)
          .map((match) => match.group(0)!)
          .toList(growable: false);
      if (ids.length >= 2) {
        return ids;
      }
    }

    final granulometriaIndex = lines.indexWhere(
      (line) => line.toLowerCase().contains('análise granulométrica'),
    );
    if (granulometriaIndex >= 0) {
      final ids = <String>[];
      for (var i = granulometriaIndex + 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (RegExp(r'^\d{5}$').hasMatch(line)) {
          ids.add(line);
          continue;
        }
        if (ids.isNotEmpty) break;
      }
      if (ids.isNotEmpty) return ids;
    }
    return const [];
  }

  List<List<String>> _extractSellarRowsValues(
    List<String> lines,
    RegExp labelPattern,
    int count,
  ) {
    final rows = <List<String>>[];
    for (final line in lines) {
      if (!labelPattern.hasMatch(line.trim())) continue;
      final values = _numericTokens(line);
      if (values.length >= count) {
        rows.add(values.sublist(values.length - count));
      }
    }
    return rows;
  }

  List<String> _extractSellarRowValues(
    List<String> lines,
    RegExp labelPattern,
    int count,
  ) {
    final rows = _extractSellarRowsValues(lines, labelPattern, count);
    return rows.isEmpty ? const [] : rows.first;
  }

  List<String> _extractSellarTextRowValues(
    List<String> lines,
    RegExp labelPattern,
    int count,
  ) {
    for (final line in lines) {
      if (!labelPattern.hasMatch(line.trim())) continue;
      final tokens = line
          .split(RegExp(r'\s+'))
          .map((token) => token.trim())
          .where((token) => token.isNotEmpty)
          .toList(growable: false);
      if (tokens.length <= count) return const [];
      return tokens.sublist(tokens.length - count);
    }
    return const [];
  }

  List<String> _numericTokens(String line) {
    return RegExp(r'(?<![A-Za-zÀ-ÿ])\d+(?:[,.]\d+)?(?![A-Za-zÀ-ÿ])')
        .allMatches(line)
        .map((match) => match.group(0)!)
        .toList(growable: false);
  }

  Map<String, List<double?>> _extractSellarVerticalValues(
    List<String> lines,
    int count,
  ) {
    final start = lines.indexWhere(
      (line) => line.toLowerCase().contains('análise granulométrica'),
    );
    final end = lines.indexWhere(
      (line) => line.toLowerCase().trim() == 'determinação',
    );
    if (start < 0 || end <= start) return const {};

    final numbers = <double>[];
    for (final line in lines.sublist(start + 1, end)) {
      for (final token in _numericTokens(line)) {
        final value = _toDouble(token);
        if (value != null) numbers.add(value);
      }
    }

    if (numbers.length < count + (count * 20)) return const {};
    var offset = count;

    List<double?> group() {
      if (offset + count > numbers.length) {
        return List<double?>.filled(count, null);
      }
      final values = numbers.sublist(offset, offset + count);
      offset += count;
      return values;
    }

    final values = <String, List<double?>>{
      'phCaCl2': group(),
      'pMehlich': group(),
      'k_mgdm3': group(),
      'ca': group(),
      'mg': group(),
      'al': group(),
      'hMaisAl': group(),
      'materiaOrganica': group(),
      'sb': group(),
      'ctc': group(),
      'vPercent': group(),
      'mPercent': group(),
    };

    for (var i = 0; i < count; i++) {
      for (final key in const [
        'b',
        'cu',
        'fe',
        'mn',
        'zn',
        'caMg',
        'caK',
        'mgK'
      ]) {
        values.putIfAbsent(key, () => List<double?>.filled(count, null));
        values[key]![i] = offset < numbers.length ? numbers[offset] : null;
        offset++;
      }
    }

    for (var i = 0; i < count; i++) {
      for (final key in const ['areiaTotal', 'silte', 'argila']) {
        values.putIfAbsent(key, () => List<double?>.filled(count, null));
        values[key]![i] = offset < numbers.length ? numbers[offset] : null;
        offset++;
      }
    }

    return values;
  }

  double? _verticalAt(
      Map<String, List<double?>> values, String key, int index) {
    final row = values[key];
    if (row == null || index < 0 || index >= row.length) return null;
    return row[index];
  }

  List<String> _extractSellarTalhoes(List<String> lines, int n) {
    final idxNumeroSellar = lines.indexWhere((line) {
      final lower = line.toLowerCase();
      return lower.startsWith('número sellar') ||
          lower.startsWith('numero sellar');
    });
    if (idxNumeroSellar >= 0) {
      for (var i = idxNumeroSellar + 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;
        if (line.toLowerCase().contains('identificação da amostra')) break;
        if (_numericTokens(line).length >= n) continue;

        final names = _splitSellarSampleNames(line, n);
        if (names.isNotEmpty) return names;
      }
    }

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
    if (idxIdentificacao >= 0 && idxTipoDeSolo > idxIdentificacao) {
      start = idxIdentificacao;
      end = idxTipoDeSolo;
    } else if (idxTipoDeSolo >= 0 && idxIdentificacao > idxTipoDeSolo) {
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

  List<String> _splitSellarSampleNames(String line, int count) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) return const [];

    final numbered = RegExp(r'.+?\d(?:\s+|$)').allMatches(trimmed).toList();
    if (numbered.length >= count - 1) {
      final names = <String>[];
      var end = 0;
      for (final match in numbered.take(count - 1)) {
        final value = match.group(0)?.trim();
        if (value != null && value.isNotEmpty) {
          names.add(value);
          end = match.end;
        }
      }
      final tail = trimmed.substring(end).trim();
      if (tail.isNotEmpty) names.add(tail);
      if (names.length == count) return names;
    }

    final tokens = trimmed.split(RegExp(r'\s{2,}'));
    if (tokens.length == count) return tokens;
    if (count == 1) return [trimmed];
    return const [];
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
        if (_sampleIdFromLine(lines[j], sampleIdRegex) != null) {
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
        if (_sampleIdFromLine(dataTokens[j], sampleIdRegex) != null) {
          rowStarts.add(j);
        }
      }

      for (var j = 0; j < rowStarts.length; j++) {
        final rowStart = rowStarts[j];
        final rowEnd =
            j + 1 < rowStarts.length ? rowStarts[j + 1] : dataTokens.length;
        final row = dataTokens
            .sublist(rowStart, rowEnd)
            .expand(_splitTableLine)
            .toList(growable: false);
        if (row.length >= 5) {
          rows.add(row);
        }
      }

      sections.add(_TableSection(header: header, rows: rows));
      i = endData;
    }

    return sections;
  }

  String? _sampleIdFromLine(String line, RegExp sampleIdRegex) {
    for (final token in _splitTableLine(line)) {
      final normalized = token.replaceAll(RegExp(r'^[^\w]+|[^\w.]+$'), '');
      if (sampleIdRegex.hasMatch(normalized)) {
        return normalized;
      }
    }
    return null;
  }

  List<String> _splitTableLine(String line) {
    return line
        .split(RegExp(r'\s+'))
        .map((token) => token.trim())
        .where((token) => token.isNotEmpty)
        .toList(growable: false);
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
      talhao = _resolveTalhaoFallback(prefix);
    } else if (depthEnd < prefix.length - 1) {
      talhao = prefix.sublist(depthEnd + 1).join(' ').trim();
    } else {
      talhao = _resolveTalhaoFallback(prefix.sublist(0, depthStart));
    }

    return _ParsedRow(
      sampleId: sampleId,
      talhao: talhao,
      profundidade: depth.isEmpty ? '' : depth,
      values: values,
    );
  }

  Map<String, dynamic> _exataPhKFields(List<String> values) {
    return <String, dynamic>{
      'phCaCl2': _valueAt(values, 0),
      'ca': _valueAt(values, 2),
      'mg': _valueAt(values, 3),
      'al': _valueAt(values, 4),
      'hMaisAl': _valueAt(values, 5),
      'k': _valueAt(values, 6),
      'k_mgdm3': _valueAt(values, 7),
    };
  }

  Map<String, dynamic> _exataPRemFields(List<String> values) {
    return <String, dynamic>{
      'pMehlich': _valueAt(values, 0),
      'pRem': _valueAt(values, 1),
      'pResina': _valueAt(values, 2),
      's020': _valueAt(values, 3),
      'materiaOrganica': _valueAt(values, 4),
      'carbonoOrganico': _valueAt(values, 5),
      'b': _valueAt(values, 6),
      'cu_meh': _valueAt(values, 7),
    };
  }

  Map<String, dynamic> _exataPRemSemResinaFields(List<String> values) {
    return <String, dynamic>{
      'pMehlich': _valueAt(values, 0),
      'pRem': _valueAt(values, 1),
      's020': _valueAt(values, 2),
      'materiaOrganica': _valueAt(values, 3),
      'carbonoOrganico': _valueAt(values, 4),
      'b': _valueAt(values, 5),
      'cu_meh': _valueAt(values, 6),
      'fe_meh': _valueAt(values, 7),
    };
  }

  Map<String, dynamic> _exataMicrosBaFields(List<String> values) {
    return <String, dynamic>{
      'pMehlich': _valueAt(values, 0),
      's020': _valueAt(values, 1),
      'cu_meh': _valueAt(values, 2),
      'fe_meh': _valueAt(values, 3),
      'mn_meh': _valueAt(values, 4),
      'zn_meh': _valueAt(values, 5),
      'na': _valueAt(values, 6),
      'argila': _valueAt(values, 7),
    };
  }

  Map<String, dynamic> _exataMicrosGoFields(List<String> values) {
    return <String, dynamic>{
      'k_mgdm3': _valueAt(values, 0),
      'pMehlich': _valueAt(values, 1),
      'pResina': _valueAt(values, 2),
      's020': _valueAt(values, 3),
      'materiaOrganica': _valueAt(values, 4),
      'carbonoOrganico': _valueAt(values, 5),
      'b': _valueAt(values, 6),
      'cu_meh': _valueAt(values, 7),
    };
  }

  Map<String, dynamic> _exataMicrosTextureFields(List<String> values) {
    return <String, dynamic>{
      'fe_meh': _valueAt(values, 0),
      'mn_meh': _valueAt(values, 1),
      'zn_meh': _valueAt(values, 2),
      'na': _valueAt(values, 3),
      'argila': _valueAt(values, 4),
    };
  }

  Map<String, dynamic> _exataMicrosTextureWithGranulometryFields(
    List<String> values,
  ) {
    return <String, dynamic>{
      'fe_meh': _valueAt(values, 0),
      'mn_meh': _valueAt(values, 1),
      'zn_meh': _valueAt(values, 2),
      'na': _valueAt(values, 3),
      'argila': _valueAt(values, 4),
      'silte': _valueAt(values, 5),
      'areiaTotal': _valueAt(values, 6),
    };
  }

  Map<String, dynamic> _exataMehTextureFields(List<String> values) {
    return <String, dynamic>{
      'mn_meh': _valueAt(values, 0),
      'zn_meh': _valueAt(values, 1),
      'na': _valueAt(values, 2),
      'argila': _valueAt(values, 3),
      'silte': _valueAt(values, 4),
      'areiaTotal': _valueAt(values, 5),
    };
  }

  Map<String, dynamic> _exataDtpaFields(List<String> values) {
    return <String, dynamic>{
      'cu_dtpa': _valueAt(values, 0),
      'fe_dtpa': _valueAt(values, 1),
      'mn_dtpa': _valueAt(values, 2),
      'zn_dtpa': _valueAt(values, 3),
    };
  }

  Map<String, dynamic> _exataSilteAreiaFields(List<String> values) {
    return <String, dynamic>{
      'silte': _valueAt(values, 0),
      'areiaTotal': _valueAt(values, 1),
    };
  }

  String _normalizeHeader(String header) {
    return header
        .toLowerCase()
        .replaceAll(RegExp(r'[()]'), ' ')
        .replaceAll(RegExp(r'[º°]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  bool _hasPMehColumn(String normalizedHeader) {
    return RegExp(r'(^|\s)p\s*(meh|mel|mehl|mehlich)(\s|$)')
        .hasMatch(normalizedHeader);
  }

  bool _hasHeaderToken(String normalizedHeader, String token) {
    return RegExp('(^|\\s)${RegExp.escape(token)}(\\s|\$)')
        .hasMatch(normalizedHeader);
  }

  double? _valueAt(List<String> values, int index) {
    if (index < 0 || index >= values.length) return null;
    return _toDouble(values[index]);
  }

  double? _subtractNullable(double? left, double? right) {
    if (left == null || right == null) return null;
    return left - right;
  }

  String _resolveTalhaoFallback(List<String> tokens) {
    if (tokens.isEmpty) return '';
    return tokens.join(' ').trim();
  }

  _DepthInfo? _extractDepth(List<String> tokens) {
    for (var i = 0; i < tokens.length; i++) {
      if (RegExp(r'^\d{1,3}\s*-\s*\d{1,3}$').hasMatch(tokens[i])) {
        return _DepthInfo(
          depth: _normalizeDepth(tokens[i]) ?? '',
          start: i,
          end: i,
        );
      }
      if (i + 2 < tokens.length &&
          RegExp(r'^\d{1,3}$').hasMatch(tokens[i]) &&
          tokens[i + 1] == '-' &&
          RegExp(r'^\d{1,3}$').hasMatch(tokens[i + 2])) {
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
    if (raw.isEmpty ||
        raw == '-' ||
        raw == 'nr' ||
        raw == 'ns' ||
        raw == 'l.q' ||
        raw == 'n.a.') {
      return null;
    }

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
      return '${_normalizeDepthNumber(match.group(1)!)}-${_normalizeDepthNumber(match.group(2)!)}';
    }
    final matchA = RegExp(r'(\d{1,2})\s*a\s*(\d{1,2})').firstMatch(cleaned);
    if (matchA != null) {
      return '${_normalizeDepthNumber(matchA.group(1)!)}-${_normalizeDepthNumber(matchA.group(2)!)}';
    }
    return cleaned.isEmpty ? null : cleaned;
  }

  String _normalizeDepthNumber(String value) {
    return (int.tryParse(value) ?? 0).toString();
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
