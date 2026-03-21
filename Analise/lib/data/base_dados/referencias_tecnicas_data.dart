class ReferenciaTecnica {
  const ReferenciaTecnica({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.ano,
    required this.formulaAssociada,
    required this.resumo,
    required this.arquivoMarkdown,
    required this.autor,
    required this.anoPublicacao,
    required this.instituicao,
  });

  final String id;
  final String nome;
  final String tipo;
  final String ano;
  final String formulaAssociada;
  final String resumo;
  final String arquivoMarkdown;
  final String autor;
  final int anoPublicacao;
  final String instituicao;
}

const List<ReferenciaTecnica> referenciasTecnicasPadrao = [
  ReferenciaTecnica(
    id: 'ref-conversoes-00',
    nome: '00 — Conversões de Unidades e Constantes',
    tipo: 'Referência Técnica',
    ano: '2026',
    formulaAssociada: 'Base de cálculo',
    resumo:
        'Consolida fatores de conversão, constantes e padronização de unidades '
        'utilizadas pelos motores de cálculo.',
    arquivoMarkdown: 'PROMPT/dados referencias/00_conversoes.md',
    autor: 'Fancelli, A.L.; IAC',
    anoPublicacao: 2016,
    instituicao: 'IAC · ESALQ/USP',
  ),
  ReferenciaTecnica(
    id: 'ref-calagem-01',
    nome: '01 — Calagem: Motor de Cálculo',
    tipo: 'Referência Técnica',
    ano: '2026',
    formulaAssociada: 'Calagem',
    resumo: 'Diretrizes técnicas para recomendação de calagem com métodos de '
        'saturação por bases, SMP e interpretação de corretivos.',
    arquivoMarkdown: 'PROMPT/dados referencias/01_calagem.md',
    autor: 'Fancelli, A.L.',
    anoPublicacao: 2020,
    instituicao: 'ESALQ/USP',
  ),
  ReferenciaTecnica(
    id: 'ref-gesso-02',
    nome: '02 — Gesso Agrícola: Motor de Cálculo',
    tipo: 'Referência Técnica',
    ano: '2026',
    formulaAssociada: 'Gesso',
    resumo:
        'Define diagnóstico de gessagem no subsolo, métodos de dose, ajustes '
        'por solo sódico e impactos no manejo de cálcio e enxofre.',
    arquivoMarkdown: 'PROMPT/dados referencias/02_gesso.md',
    autor: 'Vitti, G.C.; Caires, E.F.',
    anoPublicacao: 2020,
    instituicao: 'ESALQ/USP · UEPG · EMBRAPA',
  ),
  ReferenciaTecnica(
    id: 'ref-fosforo-03',
    nome: '03 — Fósforo (P): Motor de Cálculo',
    tipo: 'Referência Técnica',
    ano: '2026',
    formulaAssociada: 'Fósforo',
    resumo:
        'Reúne critérios de interpretação de P no solo, dinâmica de difusão, '
        'fixação e regras práticas de recomendação.',
    arquivoMarkdown: 'PROMPT/dados referencias/03_fosforo.md',
    autor: 'Fancelli, A.L.',
    anoPublicacao: 2020,
    instituicao: 'ESALQ/USP · IAC 2016 · EMBRAPA',
  ),
  ReferenciaTecnica(
    id: 'ref-potassio-04',
    nome: '04 — Potássio (K): Motor de Cálculo',
    tipo: 'Referência Técnica',
    ano: '2026',
    formulaAssociada: 'Potássio',
    resumo:
        'Documenta relações de K com CTC e antagonismos, conversões e parâmetros '
        'para recomendação de adubação potássica.',
    arquivoMarkdown: 'PROMPT/dados referencias/04_potassio.md',
    autor: 'Fancelli, A.L.',
    anoPublicacao: 2020,
    instituicao: 'ESALQ/USP · IAC 2016',
  ),
  ReferenciaTecnica(
    id: 'ref-enxofre-05',
    nome: '05 — Enxofre (S): Motor de Cálculo',
    tipo: 'Referência Técnica',
    ano: '2026',
    formulaAssociada: 'Enxofre',
    resumo: 'Define diagnóstico e recomendação de S, relação com gessagem e '
        'seleção de fontes sulfuradas conforme sistema de produção.',
    arquivoMarkdown: 'PROMPT/dados referencias/05_enxofre.md',
    autor: 'Fancelli, A.L.; Vitti, G.C.',
    anoPublicacao: 2020,
    instituicao: 'ESALQ/USP · EMBRAPA',
  ),
  ReferenciaTecnica(
    id: 'ref-micros-06',
    nome: '06 — Micronutrientes: Motor de Cálculo',
    tipo: 'Referência Técnica',
    ano: '2026',
    formulaAssociada: 'Micronutrientes',
    resumo:
        'Traz interpretação por elemento (B, Cu, Fe, Mn, Zn, Mo, Ni, Se e Co), '
        'extratores, faixas e critérios de dose.',
    arquivoMarkdown: 'PROMPT/dados referencias/06_micronutrientes.md',
    autor: 'Fancelli, A.L.',
    anoPublicacao: 2020,
    instituicao: 'ESALQ/USP · EMBRAPA Soja',
  ),
  ReferenciaTecnica(
    id: 'ref-nitrogenio-07',
    nome: '07 — Nitrogênio (N): Motor de Cálculo',
    tipo: 'Referência Técnica',
    ano: '2026',
    formulaAssociada: 'Nitrogênio',
    resumo:
        'Consolida formas de N, perdas no sistema (volatilização, lixiviação e '
        'desnitrificação) e estratégias de manejo de eficiência.',
    arquivoMarkdown: 'PROMPT/dados referencias/07_nitrogenio.md',
    autor: 'Fancelli, A.L.; Otto, R.',
    anoPublicacao: 2023,
    instituicao: 'ESALQ/USP · EMBRAPA',
  ),
  ReferenciaTecnica(
    id: 'ref-especiais-08',
    nome: '08 — Fertilizantes Especiais e Eficiência',
    tipo: 'Referência Técnica',
    ano: '2026',
    formulaAssociada: 'Fontes especiais',
    resumo:
        'Organiza classes de fertilizantes especiais, inibidores, revestimentos '
        'e critérios de uso para aumento de eficiência agronômica.',
    arquivoMarkdown: 'PROMPT/dados referencias/08_fertilizantes_especiais.md',
    autor: 'Otto, R.; Vitti, G.C.',
    anoPublicacao: 2023,
    instituicao: 'ESALQ/USP',
  ),
];

ReferenciaTecnica? referenciaTecnicaPorId(String id) {
  for (final referencia in referenciasTecnicasPadrao) {
    if (referencia.id == id) return referencia;
  }
  return null;
}
