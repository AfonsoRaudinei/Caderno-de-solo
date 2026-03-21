# SoloForte — Arquitetura do Fluxo de Dados
**Documento de referência obrigatória para o agente**
**Leia este arquivo ANTES de qualquer tarefa no projeto**
Versão 1.0 · Março 2026

---

## 1. O Fluxo Fundamental

```
SoloForte tem TRÊS pilares independentes que se combinam na Recomendação:

┌─────────────────────┐  ┌─────────────────────┐  ┌─────────────────────┐
│  REFERÊNCIAS        │  │  CALIBRAÇÃO          │  │  ANÁLISE DE SOLO    │
│  TÉCNICAS           │  │                      │  │                     │
│                     │  │                      │  │                     │
│  Config →           │  │  Lab →               │  │  Tab Análise        │
│  Base de Dados      │  │  Calibração          │  │                     │
│                     │  │                      │  │                     │
│  • NC por elemento  │  │  • Método calagem    │  │  • P, K, Ca, Mg     │
│  • Tabelas IAC      │  │  • % correção P/K    │  │  • pH, CTC, H+Al    │
│  • Fórmulas motor   │  │  • Fontes micros     │  │  • Argila, textura  │
│  • Fancelli, EMBRAPA│  │  • FEP, FEK          │  │  • Al, m%           │
│  • Constantes       │  │  • Albrecht metas    │  │  • Camadas 0-20,    │
│                     │  │  • Extrator          │  │    20-40 cm         │
│  Somente leitura    │  │  • Referências       │  │  • Dados subsolo    │
│  Técnico consulta   │  │  • Nome, cultura,    │  │  • Produtividade    │
│  não edita          │  │    safra, cliente    │  │    esperada         │
│                     │  │  • Perfil nomeado    │  │  • Cultivar         │
│                     │  │  • Reutilizável      │  │  • Data coleta      │
└─────────────────────┘  └─────────────────────┘  └─────────────────────┘
           │                        │                        │
           └────────────────────────┴────────────────────────┘
                                    │
                                    ▼
                    ┌─────────────────────────────┐
                    │      RECOMENDAÇÃO           │
                    │    Lab → Recomendação       │
                    │                             │
                    │  1. Técnico seleciona       │
                    │     qual ANÁLISE usar       │
                    │                             │
                    │  2. Técnico seleciona       │
                    │     qual CALIBRAÇÃO aplicar │
                    │                             │
                    │  3. App cruza os três       │
                    │     pilares e calcula       │
                    │                             │
                    │  Saída:                     │
                    │  • Dose calcário (t/ha)     │
                    │  • Dose gesso (kg/ha)       │
                    │  • Dose P₂O₅ (kg/ha)       │
                    │  • Dose K₂O (kg/ha)        │
                    │  • Dose por micro (g/ha)    │
                    │  • Argumentos técnicos      │
                    │  • Relações e alertas       │
                    └─────────────────────────────┘
```

---

## 2. Definição Precisa de Cada Pilar

### 2.1 Referências Técnicas
- **O que é:** a fonte de verdade científica do app
- **Onde vive:** `Config → Base de Dados` + pasta `PROMPT/`
- **Quem edita:** ninguém — são documentos técnicos (Fancelli, EMBRAPA, IAC)
- **O que contém:** NC por elemento e extrator, tabelas de classificação,
  fórmulas dos 7 métodos de calagem, constantes agronômicas
- **Como o motor usa:** carrega as tabelas e constantes nos cálculos

### 2.2 Calibração
- **O que é:** o perfil de trabalho do técnico
- **Onde vive:** `Lab → Calibração` (tab esquerda)
- **Quem edita:** o técnico agrônomo
- **O que contém:**
  - Identificação: nome, cultura, safra, cliente, fazenda, talhão
  - Card Corretivos: tipo calcário, PRNT, método (①–⑦), Albrecht metas,
    grade, profundidade, superfície contato, gesso, mês aplicação
  - Card Fósforo: extrator, referência, NC, modo (correção/extração),
    % correção, FEP, modo aplicação
  - Card Potássio: extrator, critério NC, modo, % correção, FEK,
    modo aplicação
  - Card Micros: NC por elemento, via (solo/foliar), fonte, eficiência,
    grupos de aplicação
- **Característica chave:** é **reutilizável** — uma calibração pode ser
  aplicada a múltiplas análises de solo diferentes
- **Analogia:** é a "receita" do técnico. Não tem dados do solo ainda.

### 2.3 Análise de Solo
- **O que é:** os dados reais do solo de um talhão específico
- **Onde vive:** `Tab Análise`
- **Quem edita:** técnico insere os dados do laudo do laboratório
- **O que contém:** todos os valores analíticos (P, K, Ca, Mg, pH, CTC,
  H+Al, Al, argila, matéria orgânica, camadas, subsolo, cultivar,
  produtividade esperada)
- **Característica chave:** representa um momento no tempo — um solo,
  uma data, um laboratório
- **Analogia:** é o "ingrediente" que a receita vai processar

### 2.4 Recomendação
- **O que é:** o resultado do cruzamento dos três pilares
- **Onde vive:** `Lab → Recomendação` (tab direita)
- **Como funciona:**
  ```
  Recomendação = f(Calibração, Análise, Referências)

  Calibração  define: COMO calcular (métodos, %, fontes)
  Análise     define: COM QUAIS DADOS calcular (valores do solo)
  Referências define: AS REGRAS E TABELAS (NC, fatores, fórmulas)
  ```
- **Saída:** doses calculadas com argumentos técnicos, relações
  Ca:Mg, K:Mg, alertas, score de qualidade do calcário,
  cronograma de aplicação, agrupamento de micros

---

## 3. Regras Invioláveis para o Agente

### REGRA 1 — Calibração não tem dados de solo
A Calibração define REGRAS e PERCENTUAIS.
Ela nunca armazena valores de P_solo, K_solo, Ca, etc.
Esses valores só existem na Análise de Solo.

**ERRADO:**
```dart
// Na calibração NÃO existe isso:
double pSolo;
double kAtual;
```

**CORRETO:**
```dart
// Na calibração existe:
double pctCorrecaoP;  // ex: 50% do déficit agora
double fep;           // ex: 20%
String extrator;      // ex: 'resina_iac'
```

### REGRA 2 — Recomendação combina os dois
Os cálculos finais (doses em kg/ha, t/ha) só acontecem
na Recomendação, quando Calibração + Análise se encontram.

```dart
// Recomendação:
double ncP = referencias.getNC(calibracao.extrator, analise.argila);
double deficit = max(0, ncP - analise.pSolo);
double dose = deficit * calibracao.fatorSolo * calibracao.pctCorrecao / 100;
double doseFinal = dose / (calibracao.fep / 100);
```

### REGRA 3 — Referências são somente leitura
O técnico pode consultar as Referências Técnicas (Config → Base de Dados)
mas não pode alterar os valores que o motor usa.
O que é editável fica na Calibração.

### REGRA 4 — Democracia nos valores da Calibração
Todos os valores padrão da Calibração são sugestões editáveis.
Nenhum campo bloqueia o cálculo.
Avisos informam. Bloqueios não existem.

### REGRA 5 — Uma Calibração, múltiplas Análises
O técnico cria uma calibração "Cerrado Soja 2026" e aplica
em 50 talhões diferentes. Cada talhão tem sua Análise.
A Recomendação de cada talhão usa a mesma Calibração
mas os dados de solo de cada Análise.

---

## 4. Estrutura de Dados (resumo)

```dart
// CALIBRAÇÃO — o perfil do técnico
class CalibracaoEntity {
  String nome;
  String cultura;          // soja | milho | feijao | algodao
  String safra;
  String cliente;
  String fazenda;
  String talhao;

  // Card Corretivos
  String tipocalcario;
  double cao, mgo, pn, re, prnt;
  int metodoCalagem;       // 1 a 7
  double pctCorrecaoCalcario;
  double vDesejado;        // método V%
  double fatorHAl;         // método EMBRAPA
  double pctCaAlvo, pctMgAlvo, pctKAlvo;  // Albrecht
  double ncCaAbs, ncMgAbs, ncKAbs;        // NC absolutos
  double profIncorporacao;
  double sc;               // superfície contato
  int mesAplicacao;
  bool usarGesso;
  int metodoGesso;

  // Card Fósforo
  String extratoP;         // resina_iac | mehlich1 | mehlich3
  String referenciaP;
  double ncP;              // editável
  int modoP;               // 1=correção | 2=extração
  double pctCorrecaoP;
  double fep;
  String modoAplicacaoP;

  // Card Potássio
  String extratoK;
  String criterioNCK;      // teor | pctCTC | ambos
  double ncKTeor;
  double ncKPctCTC;
  int modoK;
  double pctCorrecaoK;
  double fek;
  String modoAplicacaoK;

  // Card Micros
  List<ConfigMicro> micros;
  List<GrupoAplicacao> grupos;
}

// ANÁLISE — os dados do laudo
class AnaliseEntity {
  // Identificação
  String laboratorio;
  DateTime dataColeta;
  String cultivar;
  double produtividadeEsperada;

  // Dados do solo 0-20cm
  double ph, pSolo, kSolo, caSolo, mgSolo;
  double alSolo, hAlSolo, ctc, argila, mo;

  // Dados subsolo 20-40cm (para gesso)
  double caSub, alSub, mPctSub, vPctSub, ctcSub;
}

// RECOMENDAÇÃO — o resultado
class RecomendacaoEntity {
  CalibracaoEntity calibracao;
  AnaliseEntity analise;

  // Resultados calculados
  double doseCalcario;     // t/ha
  double doseGesso;        // kg/ha
  double doseP;            // kg P₂O₅/ha
  double doseK;            // kg K₂O/ha
  List<ResultadoMicro> micros;

  // Argumentos técnicos
  double relCaMg;
  String classRelCaMg;
  double vPctFinal;
  double pctCaFinal, pctMgFinal;
  List<String> avisos;
  List<String> argumentos;
}
```

---

## 5. Mapa das Telas

```
App SoloForte
│
├── Tab Análise
│   └── Inserir / listar laudos de solo
│       (dados brutos do laboratório)
│
├── Tab Lab
│   ├── Calibração (tab esquerda)
│   │   ├── Cabeçalho (nome, cultura, safra, cliente...)
│   │   ├── Card 1 — Corretivos (calcário + gesso)
│   │   ├── Card 2 — Fósforo
│   │   ├── Card 3 — Potássio
│   │   └── Card 4 — Micronutrientes
│   │
│   └── Recomendação (tab direita)
│       ├── Selecionar Análise de Solo
│       ├── Selecionar Calibração
│       └── Resultado calculado com argumentos
│
├── Tab Histórico
│   └── Recomendações geradas anteriormente
│
├── Tab Culturas
│   └── Dados de extração/exportação por cultivar
│       (alimenta Modo 2 de P e K)
│
└── Tab Config
    ├── Perfil do usuário (logomarca, assinatura)
    └── Base de Dados (Referências Técnicas)
        └── 00_conversoes.md a 08_fertilizantes.md
```

---

## 6. Como o Motor Usa os Três Pilares (exemplo real)

**Cenário:** técnico quer saber a dose de P para o Talhão 3.

```
1. REFERÊNCIAS fornecem:
   NC_P (Resina IAC, argiloso) = 30 mg/dm³
   fator_solo (argiloso) = 4.0
   FEP base (argiloso) = 15%

2. CALIBRAÇÃO do técnico define:
   extrator = 'resina_iac'
   modoP = 1 (correção)
   pctCorrecaoP = 50%  ← corrigir só metade agora
   modoAplicacao = 'sulco'
   fep = 15% (carregado da ref, editável)

3. ANÁLISE do Talhão 3 tem:
   P_solo = 12 mg/dm³
   argila = 45% (argiloso)

4. RECOMENDAÇÃO calcula:
   NC       = 30 mg/dm³  (das referências)
   deficit  = 30 - 12 = 18 mg/dm³
   pctCorr  = 50%  (da calibração)
   dose_base = 18 × 4.0 × 0.50 = 36 kg P₂O₅/ha
   fep_sulco = 15% × 1.5 = 22.5%  (ajuste sulco)
   dose_final = 36 / 0.225 = 160 kg P₂O₅/ha

5. Argumento gerado na Recomendação:
   "Solo argiloso com P abaixo do NC (12 vs 30 mg/dm³ — Resina IAC).
    Corrigindo 50% do déficit neste ciclo.
    Aplicação no sulco aumenta eficiência do P (FEP 22,5%).
    Dose: 160 kg P₂O₅/ha."
```

---

## 7. Referência de Arquivos

| Arquivo | Papel |
|---|---|
| `calibracao_tela_spec.md` | Especificação completa da tela Calibração |
| `card_corretivos_spec.md` | Detalhe do Card 1 (calcário + gesso) |
| `card_fosforo_spec.md` | Detalhe do Card 2 (fósforo) |
| `card_potassio_spec.md` | Detalhe do Card 3 (potássio) |
| `card_micros_spec.md` | Detalhe do Card 4 (micronutrientes) |
| `08_AGRO_FORMULAS_v2.md` | Motor de cálculo completo (Dart) |
| `PROMPT/01_calagem.md` | 7 métodos calagem + Albrecht + Y |
| `PROMPT/03_fosforo.md` | NC, modos, FEP, Legacy P |
| `PROMPT/04_potassio.md` | NC, modos, FEK, antagonismos |
| `PROMPT/06_micronutrientes.md` | NC, via solo/foliar, grupos |
| `plano_acao_auditoria.md` | 5 prompts de implementação pendentes |
| `prompt_auditoria.md` | Checklist 85 itens para re-auditoria |

---

*Documento: SOLOFORTE_FLUXO_ARQUITETURA.md*
*Leitura obrigatória antes de qualquer tarefa no projeto*
*SoloForte · Março 2026*
