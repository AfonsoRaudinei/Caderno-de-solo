// calibracao_padrao.dart
//
// Perfil padrão "Albrecht + Y" para Soja no Cerrado.
// Criado automaticamente na primeira abertura do app (box Hive vazio).
// Todos os valores seguem o mapeamento exato das chaves lidas pela CalibracaoPage.
//
// Chave do grupo de foliar: 'grupo-foliares' (string fixa/determinística).
// Elementos B, Cu e Se estão vinculados a esse grupo.

import 'package:soloforte/domain/models/calibracao_profile.dart';

/// Retorna o perfil padrão "Albrecht + Y" como um [CalibracaoProfile] pronto
/// para ser persistido no Hive na primeira inicialização.
///
/// O ID é passado como parâmetro para que o controller possa usar seu próprio
/// [Uuid] e garantir unicidade.
CalibracaoProfile calibracaoPadrao({required String id}) {
  final now = DateTime.now();

  // ── ID fixo do grupo foliar ──────────────────────────────────────────────
  const grupoFoliaresId = 'grupo-foliares';

  return CalibracaoProfile(
    id: id,
    nome: 'Albrecht + Y',
    cultura: 'Soja',
    safra: 'atual',
    cliente: 'pré configuração',
    fazenda: '',
    talhao: '',
    observacoes: '',
    createdAt: now,
    updatedAt: now,
    parametrosCards: {
      // ── CARD 1: Corretivos (calagem + gesso) ──────────────────────────────
      'corretivos': {
        'referencia': '01 — Calagem: Motor de Cálculo',
        'referenciaId': 'ref-calagem-01',
        'arquivoMarkdown': 'PROMPT/dados referencias/01_calagem.md',

        // Calagem
        'tipoCalagem': 'Corretiva',
        'tipoCalcario': 'Dolomítico',
        'calcario1': {
          'caO': 30.0,
          'mgO': 18.0,
          'pn': 90.0,
          're': 90.0,
          'prnt': 81.0, // PN×RE/100
        },
        'usarSegundoCalcario': false,
        'calcario2': {
          'caO': 42.0,
          'mgO': 3.0,
          'pn': 88.0,
          're': 85.0,
          'prnt': 74.8,
        },
        'proporcaoCalcario1': 50.0,

        // Método: ⑥ Albrecht + Y
        'metodoCalagem': '⑥ Albrecht + Y',
        'v2': 70.0,
        'fatorHAl': 0.5,
        'doseFixa': 1.75, // usado internamente para ncAlbrecht e yDoSolo

        // Bloco Albrecht — Soja Cerrado
        'albrecht': {
          'cultura': 'Soja',
          'caAlvo': 55.0,
          'mgAlvo': 22.0,
          'kAlvo': 3.0,
          'ncCa': 2.5,
          'ncMg': 1.1,
          'ncK': 0.22,
          'incluirNa': true,
          'naAlvo': 0.0,
        },

        // Incorporação
        'metodoIncorporacao': 'Grade pesada',
        'diametroGradePol': 32.0,
        'folgaMancal': 15.0,
        'profundidadeManual': 20.0,
        'sc': 0.8, // '80% superfície PD'
        'mesAplicacao': 'Março',

        // Gesso
        'gesso': {
          'usarGesso': true,
          'metodo': '① EMBRAPA / Souza et al. (2004) — argila %',
          'teorCa': 20.0,
          'teorS': 15.0,
          'dose': 1.0,
        },
      },

      // ── CARD 2: Fósforo ───────────────────────────────────────────────────
      'fosforo': {
        'extrator': 'Mehlich-1',
        'referencia': 'Embrapa Cerrado',
        'faixaArgila': '21–40%',
        'nc': 15.0, // bloqueado pela tabela (mg/dm³)
        'camada': '0–20 cm',
        'modoCalculo': '① Correção do solo',
        'percentualCorrecao': 100.0,
        'fatorSolo': 8.0,
        'cultivar': 'Soja',
        'tipoDadoCultivar': 'Exportação',
        'percentualUsoPSolo': 100.0,
        'doseMinimaLegacyP': 15.0,
        'modoAplicacao': 'Sulco',
        'fepBase': 15.0,
      },

      // ── CARD 3: Potássio ──────────────────────────────────────────────────
      'potassio': {
        'extrator': 'Mehlich-1',
        'referencia': 'Embrapa Cerrado',
        'criterioNc': 'Ambos — usar o maior',
        'ncTeor': 46.0, // mg/dm³ — bloqueado
        'ncPctCtc': 3.0, // % — bloqueado
        'camada': '0–20 cm',
        'modoCalculo': 'Manutenção',
        'percentualCorrecao': 100.0,
        'cultivar': 'Soja',
        'tipoDadoCultivar': 'Exportação',
        'percentualUsoKSolo': 0.0,
        'modoAplicacao': 'Lanço plantio direto',
        'fekBase': 80.0,
        'doseSulco': 0.0,
      },

      // ── CARD 4: Micronutrientes ───────────────────────────────────────────
      'micros': {
        'pH': 5.8,
        'plantioDiretoAntigo': false,
        'gessoDoseKgHa': 0.0,

        // Grupo Foliares
        'grupos': <Map<String, dynamic>>[
          {
            'id': grupoFoliaresId,
            'nome': 'foliares',
            'via': 'Foliar',
            'elementos': <String>['B', 'Cu', 'Mn', 'Zn', 'Mo', 'Co', 'Ni', 'Se'],
            'produto': 'carbonatos e fontes nobres',
            'eficiencia': 90.0,
          },
        ],

        'elementos': {
          // ── B — Boro ─────────────────────────────────────────────────────
          'B': {
            'simbolo': 'B',
            'extrator': 'DTPA-TEA',
            'referencia': 'EMBRAPA Soja',
            'ncSolo': 1.0,
            'viaAplicacao': 'Ambas',
            'percentualCorrecaoSolo': 100.0,
            'teorFonteSolo': 100.0,
            'fonteSolo': 'borato de cálcio e sódio',
            'eficienciaSolo': 90.0,
            'doseElementoFoliar': 2000.0, // g/ha de elemento puro
            'teorFonteFoliar': 0.5,
            'fonteFoliar': 'boro protegido',
            'eficienciaFoliar': 80.0,
            'temAnaliseFoliar': false,
            'teorFoliar': 0.0,
            'adicionarGrupo': true,
            'grupoId': grupoFoliaresId,
          },

          // ── Cu — Cobre ───────────────────────────────────────────────────
          'Cu': {
            'simbolo': 'Cu',
            'extrator': 'Resina',
            'referencia': 'EMBRAPA Soja',
            'ncSolo': 0.8,
            'viaAplicacao': 'Foliar',
            'percentualCorrecaoSolo': 100.0,
            'teorFonteSolo': 25.0,
            'fonteSolo': 'Sulfato de cobre',
            'eficienciaSolo': 40.0,
            'doseElementoFoliar': 50.0,
            'teorFonteFoliar': 500.0,
            'fonteFoliar': 'óxido cubroso',
            'eficienciaFoliar': 80.0,
            'temAnaliseFoliar': false,
            'teorFoliar': 0.0,
            'adicionarGrupo': true,
            'grupoId': grupoFoliaresId,
          },

          // ── Fe — Ferro ───────────────────────────────────────────────────
          'Fe': {
            'simbolo': 'Fe',
            'extrator': 'Água quente',
            'referencia': '06 — Micronutrientes: Motor de Cálculo',
            'ncSolo': 0.0, // sem NC definido
            'viaAplicacao': 'Solo (correção)',
            'percentualCorrecaoSolo': 0.0,
            'teorFonteSolo': 20.0,
            'fonteSolo': 'Sulfato ferroso',
            'eficienciaSolo': 30.0,
            'doseElementoFoliar': 80.0,
            'teorFonteFoliar': 13.0,
            'fonteFoliar': 'EDTA-Fe',
            'eficienciaFoliar': 85.0,
            'temAnaliseFoliar': false,
            'teorFoliar': 0.0,
            'adicionarGrupo': false,
            'grupoId': '',
          },

          // ── Mn — Manganês ────────────────────────────────────────────────
          'Mn': {
            'simbolo': 'Mn',
            'extrator': 'Água quente',
            'referencia': '06 — Micronutrientes: Motor de Cálculo',
            'ncSolo': 6.0,
            'viaAplicacao': 'Foliar',
            'percentualCorrecaoSolo': 100.0,
            'teorFonteSolo': 27.0,
            'fonteSolo': 'Sulfato de manganês',
            'eficienciaSolo': 25.0,
            'doseElementoFoliar': 600.0,
            'teorFonteFoliar': 30.0,
            'fonteFoliar': 'carbonato de manganes',
            'eficienciaFoliar': 80.0,
            'temAnaliseFoliar': false,
            'teorFoliar': 0.0,
            'adicionarGrupo': false,
            'grupoId': '',
          },

          // ── Zn — Zinco ───────────────────────────────────────────────────
          'Zn': {
            'simbolo': 'Zn',
            'extrator': 'Água quente',
            'referencia': '06 — Micronutrientes: Motor de Cálculo',
            'ncSolo': 0.91,
            'viaAplicacao': 'Foliar',
            'percentualCorrecaoSolo': 100.0,
            'teorFonteSolo': 23.0,
            'fonteSolo': 'Sulfato de zinco',
            'eficienciaSolo': 50.0,
            'doseElementoFoliar': 200.0,
            'teorFonteFoliar': 23.0,
            'fonteFoliar': 'carbonato de zinco',
            'eficienciaFoliar': 70.0,
            'temAnaliseFoliar': false,
            'teorFoliar': 0.0,
            'adicionarGrupo': false,
            'grupoId': '',
          },

          // ── Mo — Molibdênio ──────────────────────────────────────────────
          'Mo': {
            'simbolo': 'Mo',
            'extrator': 'Oxalato de amônio',
            'referencia': '06 — Micronutrientes: Motor de Cálculo',
            'ncSolo': 0.1,
            'viaAplicacao': 'Ambas',
            'percentualCorrecaoSolo': 100.0,
            'teorFonteSolo': 39.0,
            'fonteSolo': 'Molibdato de sódio',
            'eficienciaSolo': 70.0,
            'doseElementoFoliar': 40.0,
            'teorFonteFoliar': 39.0,
            'fonteFoliar': 'Molibdato de sódio',
            'eficienciaFoliar': 90.0,
            'temAnaliseFoliar': false,
            'teorFoliar': 0.0,
            'adicionarGrupo': false,
            'grupoId': '',
          },

          // ── Co — Cobalto ─────────────────────────────────────────────────
          'Co': {
            'simbolo': 'Co',
            'extrator': 'Água quente',
            'referencia': '06 — Micronutrientes: Motor de Cálculo',
            'ncSolo': 0.05,
            'viaAplicacao': 'Ambas',
            'percentualCorrecaoSolo': 100.0,
            'teorFonteSolo': 21.0,
            'fonteSolo': 'Sulfato de cobalto',
            'eficienciaSolo': 50.0,
            'doseElementoFoliar': 3.0,
            'teorFonteFoliar': 21.0,
            'fonteFoliar': 'Sulfato de cobalto',
            'eficienciaFoliar': 70.0,
            'temAnaliseFoliar': false,
            'teorFoliar': 0.0,
            'adicionarGrupo': false,
            'grupoId': '',
          },

          // ── Ni — Níquel ──────────────────────────────────────────────────
          'Ni': {
            'simbolo': 'Ni',
            'extrator': 'Água quente',
            'referencia': '06 — Micronutrientes: Motor de Cálculo',
            'ncSolo': 0.1,
            'viaAplicacao': 'Ambas',
            'percentualCorrecaoSolo': 100.0,
            'teorFonteSolo': 22.0,
            'fonteSolo': 'Sulfato de níquel',
            'eficienciaSolo': 50.0,
            'doseElementoFoliar': 5.0,
            'teorFonteFoliar': 22.0,
            'fonteFoliar': 'Sulfato de níquel',
            'eficienciaFoliar': 70.0,
            'temAnaliseFoliar': false,
            'teorFoliar': 0.0,
            'adicionarGrupo': false,
            'grupoId': '',
          },

          // ── Se — Selênio ─────────────────────────────────────────────────
          'Se': {
            'simbolo': 'Se',
            'extrator': 'Água quente',
            'referencia': '06 — Micronutrientes: Motor de Cálculo',
            'ncSolo': 0.05,
            'viaAplicacao': 'Ambas',
            'percentualCorrecaoSolo': 100.0,
            'teorFonteSolo': 45.0,
            'fonteSolo': 'Selenato de sódio',
            'eficienciaSolo': 50.0,
            'doseElementoFoliar': 5.0,
            'teorFonteFoliar': 45.0,
            'fonteFoliar': 'Selenato de sódio',
            'eficienciaFoliar': 70.0,
            'temAnaliseFoliar': false,
            'teorFoliar': 0.0,
            'adicionarGrupo': true,
            'grupoId': grupoFoliaresId,
          },
        },
      },
    },
  );
}
