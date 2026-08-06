/// Cadastro de parâmetros agronômicos de micronutrientes na calibração.
///
/// Mantém chaves novas e legadas para compatibilidade com perfis antigos e
/// com o motor de recomendação (que lê campos legados como [legacyNcKey]).
library;

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

const List<String> kViasAplicacaoMicros = ['Solo', 'Foliar', 'TS'];

const List<String> kReferenciasNivelCritico = [
  '06 — Micronutrientes: Motor de Cálculo',
  'EMBRAPA Soja',
  'CQFS',
  'Boletim Técnico',
  'Personalizada',
];

const List<String> kTiposReferenciaAbsorcao = [
  'Autores',
  'Artigos',
  'Livros',
  'Personalizado',
];

const List<String> kExtratoresGrupo = [
  'DTPA-TEA',
  'Mehlich-1',
  'HCl',
  'Água quente (B)',
  'Personalizado',
];

const List<String> kUnidadesNivelCritico = [
  'mg/dm³',
  'mg/kg',
];

const List<String> kUnidadesConcentracao = [
  '%',
  'g/kg',
  'g/L',
];

const String legacyNcKey = 'ncSolo';
const String legacyReferenciaKey = 'referencia';

const Map<String, String> kNomesElementosMicros = {
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

Map<String, dynamic> normalizarMicros(Map<String, dynamic> raw) {
  final micros = Map<String, dynamic>.from(raw);
  final grupos = _asListMap(micros['grupos'])
      .map(normalizarGrupoMicros)
      .toList(growable: false);
  final elementosRaw = _asMap(micros['elementos']);
  final elementos = <String, dynamic>{};

  for (final simbolo in kElementosMicros) {
    elementos[simbolo] = normalizarElementoMicros(
      simbolo,
      _asMap(elementosRaw[simbolo]),
    );
  }

  micros['grupos'] = grupos;
  micros['elementos'] = elementos;
  return micros;
}

Map<String, dynamic> normalizarGrupoMicros(Map<String, dynamic> raw) {
  final grupo = Map<String, dynamic>.from(raw);
  final vias = _normalizarVias(
    grupo['viasAplicacaoGrupo'] ?? grupo['via'],
    fallback: 'Foliar',
  );

  grupo['viasAplicacaoGrupo'] = vias;
  grupo['via'] = vias.first;
  grupo['elementos'] = List<String>.from(
    (grupo['elementos'] as List?)?.map((e) => e.toString()) ?? const [],
  );
  grupo['extrator'] ??= 'DTPA-TEA';
  grupo['nome'] ??= 'Grupo';
  grupo['fonte'] ??= grupo['produto']?.toString().trim().isNotEmpty == true
      ? grupo['produto']
      : '';
  grupo['eficienciaSoloGrupo'] ??= grupo['eficienciaSolo'] ?? 30.0;
  grupo['eficienciaFoliarGrupo'] ??=
      grupo['eficienciaFoliarGrupo'] ?? grupo['eficiencia'] ?? 70.0;
  grupo['eficienciaTsGrupo'] ??= grupo['eficienciaTsGrupo'] ?? 80.0;
  grupo['referenciaTecnica'] ??= grupo['referenciaNome'] ??
      grupo['referenciaNcNome'] ??
      kReferenciasNivelCritico.first;

  return grupo;
}

Map<String, dynamic> normalizarElementoMicros(
  String simbolo,
  Map<String, dynamic> raw,
) {
  final elemento = Map<String, dynamic>.from(raw);
  elemento['simbolo'] = simbolo;

  final referenciaNc = _string(
    elemento['referenciaNc'] ?? elemento[legacyReferenciaKey],
    fallback: kReferenciasNivelCritico.first,
  );
  elemento['referenciaNc'] = referenciaNc;
  elemento[legacyReferenciaKey] = referenciaNc;

  elemento['ncUnidade'] ??= 'mg/dm³';
  elemento[legacyNcKey] ??= _defaultNc(simbolo);

  elemento['referenciaAbsorcaoTipo'] ??=
      _normalizarTipoAbsorcao(elemento['tipoFonte']);
  elemento['referenciaAbsorcaoNome'] ??=
      elemento['autor'] ?? elemento['fonteAbsorcao'] ?? 'Malavolta (1997)';

  elemento['extracaoPlanta'] ??= _num(elemento['extracaoPlanta']);
  elemento['exportacaoGraos'] ??= _num(elemento['exportacaoGraos']);

  elemento['concentracaoFonte'] ??=
      _num(elemento['concentracaoFonte'] ?? elemento['teorFonteSolo']);
  elemento['concentracaoUnidade'] ??= '%';

  elemento['doseMinima'] ??= _num(elemento['doseMinima']);
  elemento['doseMaxima'] ??= _num(elemento['doseMaxima']);
  elemento['limiteToxicidade'] ??= _num(elemento['limiteToxicidade']);

  final vias = _normalizarVias(
    elemento['viasAplicacao'] ?? elemento['viaAplicacao'],
    fallback: 'Solo',
    permiteAmbas: true,
  );
  elemento['viasAplicacao'] = vias;
  elemento['viaAplicacao'] = _viaLegada(vias);

  _sincronizarLegadoAplicacao(elemento, vias);

  return elemento;
}

Map<String, dynamic> novoGrupoMicros({required int indice}) {
  return {
    'id': 'grupo-${DateTime.now().microsecondsSinceEpoch}',
    'nome': 'Grupo $indice',
    'extrator': 'DTPA-TEA',
    'via': 'Foliar',
    'viasAplicacaoGrupo': ['Foliar'],
    'fonte': '',
    'eficienciaSoloGrupo': 30.0,
    'eficienciaFoliarGrupo': 70.0,
    'eficienciaTsGrupo': 80.0,
    'referenciaTecnica': kReferenciasNivelCritico.first,
    'elementos': <String>[],
  };
}

Set<String> elementosSelecionadosNosGrupos(List<Map<String, dynamic>> grupos) {
  return grupos
      .expand<String>(
        (grupo) =>
            (grupo['elementos'] as List?)?.map((e) => e.toString()) ??
            const <String>[],
      )
      .toSet();
}

String rotuloElementoMicro(String simbolo) {
  final nome = kNomesElementosMicros[simbolo] ?? simbolo;
  return '$simbolo — $nome';
}

void _sincronizarLegadoAplicacao(
  Map<String, dynamic> elemento,
  List<String> vias,
) {
  if (vias.contains('Solo')) {
    elemento['eficienciaSolo'] ??= 30.0;
    elemento['teorFonteSolo'] ??= elemento['concentracaoFonte'];
    elemento['fonteSolo'] ??= '';
    elemento['percentualCorrecaoSolo'] ??= 100.0;
  }
  if (vias.contains('Foliar')) {
    elemento['eficienciaFoliar'] ??= 70.0;
    elemento['teorFonteFoliar'] ??= elemento['concentracaoFonte'];
    elemento['fonteFoliar'] ??= '';
    elemento['doseElementoFoliar'] ??= 0.0;
  }
  if (vias.contains('TS')) {
    elemento['fonteTs'] ??= '';
    elemento['doseTs'] ??= 0.0;
  }
}

String _viaLegada(List<String> vias) {
  if (vias.contains('Solo') && vias.contains('Foliar')) return 'Ambas';
  if (vias.contains('Solo')) return 'Solo (correção)';
  if (vias.contains('Foliar')) return 'Foliar';
  if (vias.contains('TS')) return 'TS';
  return 'Solo (correção)';
}

List<String> _normalizarVias(
  dynamic raw, {
  required String fallback,
  bool permiteAmbas = false,
}) {
  final valores = <String>[];
  if (raw is List) {
    valores.addAll(raw.map((item) => item.toString()));
  } else if (raw is String && raw.trim().isNotEmpty) {
    final texto = raw.trim();
    if (permiteAmbas && texto == 'Ambas') {
      valores.addAll(['Solo', 'Foliar']);
    } else if (texto == 'Solo (correção)') {
      valores.add('Solo');
    } else {
      valores.add(texto);
    }
  }

  final filtrados = valores
      .where((item) => kViasAplicacaoMicros.contains(item))
      .toSet()
      .toList(growable: false);

  return filtrados.isEmpty ? [fallback] : filtrados;
}

String _normalizarTipoAbsorcao(dynamic raw) {
  final texto = raw?.toString();
  if (texto != null && kTiposReferenciaAbsorcao.contains(texto)) {
    return texto;
  }
  if (texto == 'Guidorizzi' || texto == 'Cultivar') return 'Autores';
  return 'Autores';
}

double _defaultNc(String simbolo) {
  const defaults = {
    'B': 0.36,
    'Cu': 0.71,
    'Fe': 19.0,
    'Mn': 6.0,
    'Zn': 0.91,
    'Mo': 0.1,
    'Co': 0.05,
    'Ni': 0.1,
    'Se': 0.05,
  };
  return defaults[simbolo] ?? 0.0;
}

double _num(dynamic value, [double fallback = 0]) {
  if (value is num) return value.toDouble();
  if (value is String) {
    final parsed = double.tryParse(value.replaceAll(',', '.').trim());
    if (parsed != null) return parsed;
  }
  return fallback;
}

String _string(dynamic value, {String fallback = ''}) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, val) => MapEntry(key.toString(), val));
  }
  return <String, dynamic>{};
}

List<Map<String, dynamic>> _asListMap(dynamic value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((entry) => entry.map((key, val) => MapEntry(key.toString(), val)))
      .toList();
}
