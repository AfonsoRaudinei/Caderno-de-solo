/// Representa a citação bibliográfica de um método de cálculo.
/// É preenchida a partir da calibração no momento do cálculo.
class CitacaoCalibracaoModel {
  final String autor;
  final int ano;
  final String instituicao;
  final String metodo;

  const CitacaoCalibracaoModel({
    required this.autor,
    required this.ano,
    required this.instituicao,
    required this.metodo,
  });

  static const calagem = CitacaoCalibracaoModel(
    autor: 'Fancelli, A.L.',
    ano: 2020,
    instituicao: 'ESALQ/USP',
    metodo: 'Saturação por Bases (V%)',
  );

  static const gesso = CitacaoCalibracaoModel(
    autor: 'Vitti, G.C.',
    ano: 2004,
    instituicao: 'ESALQ/USP',
    metodo: 'Elevação de V% na camada 20–40 cm',
  );

  static const fosforo = CitacaoCalibracaoModel(
    autor: 'Fancelli, A.L.',
    ano: 2020,
    instituicao: 'ESALQ/USP · IAC 2016',
    metodo: 'Resina Sintética de Troca Iônica',
  );

  static const potassio = CitacaoCalibracaoModel(
    autor: 'Fancelli, A.L.',
    ano: 2020,
    instituicao: 'ESALQ/USP · IAC 2016',
    metodo: 'Participação na CTC (%)',
  );

  static const enxofre = CitacaoCalibracaoModel(
    autor: 'Fancelli, A.L.; Vitti, G.C.',
    ano: 2020,
    instituicao: 'ESALQ/USP · EMBRAPA',
    metodo: 'Nível crítico S-SO₄ (mg/dm³)',
  );

  static const micronutrientes = CitacaoCalibracaoModel(
    autor: 'Fancelli, A.L.',
    ano: 2020,
    instituicao: 'ESALQ/USP · EMBRAPA Soja',
    metodo: 'Níveis Críticos por Extrator',
  );

  factory CitacaoCalibracaoModel.fromJson(Map<String, dynamic> json) {
    return CitacaoCalibracaoModel(
      autor: json['autor'] as String? ?? '',
      ano: (json['ano'] as num?)?.toInt() ?? 0,
      instituicao: json['instituicao'] as String? ?? '',
      metodo: json['metodo'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'autor': autor,
      'ano': ano,
      'instituicao': instituicao,
      'metodo': metodo,
    };
  }
}
