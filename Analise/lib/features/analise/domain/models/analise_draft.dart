import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:uuid/uuid.dart';

class AnaliseDraft {
  static const _metaIdKey = '__id';
  static const _metaDataCadastroKey = '__dataCadastro';

  final String? persistedId;
  final DateTime? persistedDataCadastro;
  final Map<String, String> fields;

  const AnaliseDraft({
    this.persistedId,
    this.persistedDataCadastro,
    this.fields = const {},
  });

  factory AnaliseDraft.empty() => const AnaliseDraft();

  factory AnaliseDraft.fromAnaliseSolo(AnaliseSolo analise) {
    return AnaliseDraft(
      persistedId: analise.id,
      persistedDataCadastro: analise.dataCadastro,
      fields: {
        'fazenda': analise.fazenda,
        'produtor': analise.produtor,
        'talhao': analise.talhao,
        'numeroAmostra': analise.numeroAmostra,
        'cultura': analise.cultura.label,
        'safra': analise.safra,
        'laboratorio': analise.laboratorio,
        'profundidade': analise.profundidade,
        'latitude': analise.latitude?.toString() ?? '',
        'longitude': analise.longitude?.toString() ?? '',
        'descricaoLocal': analise.descricaoLocal ?? '',
        'pdfUrl': analise.pdfUrl ?? '',
        'argila': analise.argila?.toString() ?? '',
        'silte': analise.silte?.toString() ?? '',
        'areiaTotal': analise.areiaTotal?.toString() ?? '',
        'phAgua': analise.phAgua?.toString() ?? '',
        'phCaCl2': analise.phCaCl2?.toString() ?? '',
        'phSmp': analise.phSmp?.toString() ?? '',
        'materiaOrganica': analise.materiaOrganica?.toString() ?? '',
        'carbonoOrganico': analise.carbonoOrganico?.toString() ?? '',
        'pMehlich': analise.pMehlich?.toString() ?? '',
        'pResina': analise.pResina?.toString() ?? '',
        'pRem': analise.pRem?.toString() ?? '',
        's020': analise.s020?.toString() ?? '',
        's2040': analise.s2040?.toString() ?? '',
        'k': analise.k?.toString() ?? '',
        'ca': analise.ca?.toString() ?? '',
        'mg': analise.mg?.toString() ?? '',
        'al': analise.al?.toString() ?? '',
        'hMaisAl': analise.hMaisAl?.toString() ?? '',
        'na': analise.na?.toString() ?? '',
        'b': analise.b?.toString() ?? '',
        'cu': analise.cu?.toString() ?? '',
        'fe': analise.fe?.toString() ?? '',
        'mn': analise.mn?.toString() ?? '',
        'zn': analise.zn?.toString() ?? '',
        'ni': analise.ni?.toString() ?? '',
        'mo': analise.mo?.toString() ?? '',
        'se': analise.se?.toString() ?? '',
      },
    );
  }

  factory AnaliseDraft.fromImportMap(Map<String, dynamic> input) {
    final out = <String, String>{};
    input.forEach((k, v) {
      out[k] = v?.toString() ?? '';
    });
    return AnaliseDraft(fields: out);
  }

  AnaliseDraft copyWith({
    String? persistedId,
    DateTime? persistedDataCadastro,
    Map<String, String>? fields,
    bool clearPersistedId = false,
    bool clearPersistedDataCadastro = false,
  }) {
    return AnaliseDraft(
      persistedId: clearPersistedId ? null : (persistedId ?? this.persistedId),
      persistedDataCadastro: clearPersistedDataCadastro
          ? null
          : (persistedDataCadastro ?? this.persistedDataCadastro),
      fields: fields ?? this.fields,
    );
  }

  AnaliseDraft withField(String key, String value) {
    return copyWith(fields: {...fields, key: value});
  }

  String stringValue(String key, [String fallback = '']) {
    return (fields[key] ?? fallback).trim();
  }

  double? doubleValue(String key) {
    final raw = fields[key];
    if (raw == null || raw.trim().isEmpty) return null;
    return double.tryParse(raw.replaceAll(',', '.'));
  }

  Map<String, dynamic> toFormMap() {
    return <String, dynamic>{
      _metaIdKey: persistedId ?? '',
      _metaDataCadastroKey: persistedDataCadastro?.toIso8601String() ?? '',
      ...fields,
    };
  }

  static Cultura parseCultura(String raw) {
    final normalized = raw.trim().toLowerCase();
    for (final c in Cultura.values) {
      if (c.name == normalized || c.label.toLowerCase() == normalized) {
        return c;
      }
    }
    return Cultura.soja;
  }

  AnaliseSolo toEntity({
    required Uuid uuid,
    String? laudoProdutor,
    String? laudoFazenda,
    String? laudoLaboratorio,
    String? laudoSafra,
    Map<String, dynamic>? validationSnapshot,
  }) {
    final produtor = (laudoProdutor != null && laudoProdutor.isNotEmpty)
        ? laudoProdutor
        : stringValue('produtor');
    final fazenda = (laudoFazenda != null && laudoFazenda.isNotEmpty)
        ? laudoFazenda
        : stringValue('fazenda');
    final laboratorio =
        (laudoLaboratorio != null && laudoLaboratorio.isNotEmpty)
            ? laudoLaboratorio
            : stringValue('laboratorio');
    final safra = (laudoSafra != null && laudoSafra.isNotEmpty)
        ? laudoSafra
        : stringValue('safra');

    return AnaliseSolo(
      id: (persistedId != null && persistedId!.isNotEmpty)
          ? persistedId!
          : uuid.v4(),
      fazenda: fazenda,
      produtor: produtor,
      talhao: stringValue('talhao'),
      numeroAmostra: stringValue('numeroAmostra'),
      cultura: parseCultura(stringValue('cultura')),
      safra: safra,
      laboratorio: laboratorio,
      dataCadastro: persistedDataCadastro ?? DateTime.now(),
      profundidade: stringValue('profundidade'),
      latitude: doubleValue('latitude'),
      longitude: doubleValue('longitude'),
      descricaoLocal: stringValue('descricaoLocal'),
      pdfUrl: stringValue('pdfUrl'),
      argila: doubleValue('argila'),
      silte: doubleValue('silte'),
      areiaTotal: doubleValue('areiaTotal'),
      phAgua: doubleValue('phAgua'),
      phCaCl2: doubleValue('phCaCl2'),
      phSmp: doubleValue('phSmp'),
      materiaOrganica: doubleValue('materiaOrganica'),
      carbonoOrganico: doubleValue('carbonoOrganico'),
      pMehlich: doubleValue('pMehlich'),
      pResina: doubleValue('pResina'),
      pRem: doubleValue('pRem'),
      s020: doubleValue('s020'),
      s2040: doubleValue('s2040'),
      k: doubleValue('k'),
      ca: doubleValue('ca'),
      mg: doubleValue('mg'),
      al: doubleValue('al'),
      hMaisAl: doubleValue('hMaisAl'),
      na: doubleValue('na'),
      b: doubleValue('b'),
      cu: doubleValue('cu'),
      fe: doubleValue('fe'),
      mn: doubleValue('mn'),
      zn: doubleValue('zn'),
      ni: doubleValue('ni'),
      mo: doubleValue('mo'),
      se: doubleValue('se'),
      laudoMetadata: validationSnapshot,
    );
  }
}
