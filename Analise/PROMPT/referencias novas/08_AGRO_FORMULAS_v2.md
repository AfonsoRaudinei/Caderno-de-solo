# 08 — Fórmulas Agronômicas — Motor Completo SoloForte

> **Status:** 🔄 Motor expandido — 7 métodos de calagem + Albrecht + Y + P + K + Micros
> **Arquivos fonte:** pasta `PROMPT/` do projeto (00 a 08 .md)

---

## 1. Calcário — 7 Métodos (`calcario_formula.dart`)

Sequência de correções aplicada em TODOS os métodos:
```
Passo 1: NC_base   = resultado do método
Passo 2: NC_prof   = NC_base × p          (fator profundidade)
Passo 3: NC_prnt   = NC_prof ÷ (PRNT/100)
Passo 4: Dose_final = NC_prnt ÷ SC        (fator superfície contato)
```

| Método | Fórmula NC_base | Arquivo detalhe |
|---|---|---|
| ① V% | `((V2 − V1) × CTC) / 100` | `PROMPT/01_calagem.md` §6.1 |
| ② EMBRAPA | `H+Al × Fator` (padrão 0,5) | `PROMPT/01_calagem.md` §6.2 |
| ③ Ca+Mg | `Ca + Mg` | `PROMPT/01_calagem.md` §6.3 |
| ④ Supercalagem | Dose fixa (t/ha) | `PROMPT/01_calagem.md` §6.4 |
| ⑤ Albrecht | Déficit por saturação Ca/Mg/K na CTC | `PROMPT/01_calagem.md` §6.5 |
| ⑥ Albrecht (Y) | `max(NC_Albrecht, Y)` | `PROMPT/01_calagem.md` §6.6 |
| ⑦ Correção Mg | `deficit_Mg / fator_Mg_calcario` | `PROMPT/01_calagem.md` §6.7 |

**Valor Y (poder tampão):**
```dart
// Equação contínua por argila (5ª Aprox. MG):
Y = 0.0302 + 0.06532 × Arg − 0.000257 × Arg²

// Por P-rem: tabela em PROMPT/01_calagem.md §3.2
// Critério: se P-rem disponível → Y por P-rem (prioridade)
//           se só argila → equação contínua
//           se ambos → média ponderada 60/40
```

**Albrecht — Metas de saturação padrão por cultura:**
```dart
// Soja:    Ca 65%, Mg 15%, K 4%  → V% 84%
// Milho:   Ca 65%, Mg 15%, K 4%  → V% 84%
// Feijão:  Ca 65%, Mg 15%, K 5%  → V% 85%
// Algodão: Ca 65%, Mg 12%, K 5%  → V% 82%
// Todos editáveis pelo técnico
```

**Fator profundidade p (interpolação linear):**
```dart
// Âncoras: 0cm→0, 20cm→1.0, 40cm→2.03, 60cm→3.0
if (prof <= 20) p = prof / 20;
else if (prof <= 40) p = 1.0 + ((prof - 20) / 20) * 1.03;
else p = 2.03 + ((prof - 40) / 20) * 0.97;

// Grade: Prof = Raio_cm − (folga_mancal / 2)
//        Raio_cm = diametro_pol × 2.54 / 2
```

**PRNT:**
```dart
PRNT = (PN × RE) / 100
fator_Ca = (CaO / 100) × 0.71428
fator_Mg = (MgO / 100) × 0.60199
```

**Saturações finais (saída para Recomendação):**
```dart
Ca_total = Ca_atual + (Dose_final × fator_Ca)
Mg_total = Mg_atual + (Dose_final × fator_Mg)
CTC_nova = CTC_atual + Ca_adicionado + Mg_adicionado
pctCa    = (Ca_total / CTC_nova) × 100
pctMg    = (Mg_total / CTC_nova) × 100
vPct     = ((Ca_total + Mg_total + K) / CTC_nova) × 100
relCaMg  = Ca_total / Mg_total
```

---

## 2. Gesso (`gesso_engine.dart`)

**Diagnóstico subsolo 20–40 cm:**
```dart
bool indicado = Ca_sub < 0.5 || Al_sub > 0.5 || mPct_sub > 25;
```

| Método | Fórmula | Fonte |
|---|---|---|
| ① EMBRAPA | `NG = 50 × argila(%)` anuais / `75 × argila(%)` perenes | Souza et al. 2004 |
| ② UFLA | Tabela textural: <15%→700, 15-35%→1200, 36-60%→2200, >60%→3200 kg/ha | Lopes et al. 2006 |
| ③ Vitti | `NG = ((50 − Va_sub) × CTC_sub) / 500` | Vitti et al. 2004 |
| ④ Caires | `NG = (0.60 × CTCe_sub − Ca_sub) × 6.4` | Caires 2016 |

```dart
S_fornecido = dose_gesso × 0.15   // 15% S no gesso
Ca_fornecido = dose_gesso × 0.20  // 20% Ca no gesso
```

Detalhes completos: `PROMPT/02_gesso.md`

---

## 3. Fósforo (`fosforo_formula.dart`)

**NC por extrator e textura:**
```dart
// Resina IAC: arenoso=12, médio=20, argiloso=30, muito argiloso=40 mg/dm³
// Mehlich-1:  arenoso=8,  médio=12, argiloso=18, muito argiloso=25 mg/dm³
// Todos editáveis pelo técnico
```

**Modo 1 — Correção:**
```dart
deficit    = max(0, NC − P_solo)
dose_base  = deficit × fator_solo × (pct_correcao / 100) × fator_camada
dose_final = dose_base / (FEP_final / 100)

// fator_solo: arenoso=2.0, médio=3.0, argiloso=4.0, muito argiloso=5.0
// FEP base:   arenoso=30%, médio=20%, argiloso=15%, muito argiloso=10%
// fator_modo: sulco=1.5, lancio_incorp=1.0, lanco_sem=0.7, fertiirrig=1.3
```

**Modo 2 — Extração:**
```dart
P_solo_usado  = P_solo × (pct_uso_solo / 100)
P_solo_kg     = P_solo_usado × 2 × (prof / 20) × 2.291
extracao_P    = dado_cultivar × produtividade
dose_base     = max(0, extracao_P − P_solo_kg)
dose_final    = dose_base / (FEP_final / 100)
```

**Legacy P (P_solo > NC):**
```dart
if (P_solo > NC) {
  dose_minima = exportacao_grao × 0.30; // piso editável
  // exibir aviso na Recomendação
}
```

Detalhes completos: `PROMPT/03_fosforo.md`

---

## 4. Potássio (`potassio_formula.dart`)

**NC — dois critérios (técnico escolhe):**
```dart
// Por teor absoluto (mg/dm³ ou cmolc/dm³):
// arenoso: 40mg/dm³, médio: 60, argiloso: 80, muito argiloso: 100

// Por % K na CTC (Albrecht):
// faixa ideal: 3–5% da CTC

// Conversão: K (cmolc/dm³) = K (mg/dm³) / 391
```

**Modo 1 — Correção:**
```dart
// Por teor:
deficit    = max(0, NC_cmolc − K_atual_cmolc)
dose_K2O   = deficit × 391 × 1.205 × 2 × (pct_correcao / 100)

// Por % CTC:
K_alvo   = (pctK_alvo / 100) × CTC
deficit  = max(0, K_alvo − K_atual)
dose_K2O = deficit × 391 × 1.205 × 2 × (pct_correcao / 100)
```

**Modo 2 — Extração:**
```dart
K_solo_usado = K_solo × (pct_uso_solo / 100)
K_solo_kg    = K_solo_usado × 2 × 1.205
extracao_K   = dado_cultivar × produtividade
dose_base    = max(0, extracao_K − K_solo_kg)
dose_final   = dose_base / (FEK_final / 100)

// FEK base: arenoso=50%, médio=60%, argiloso=65%, muito argiloso=70%
// Algodão: NC → 5% CTC, FEK → 60% (flag automática)
```

**Relações antagonismo (saída Recomendação):**
```dart
pctK_CTC = (K_total / CTC) × 100  // aviso se > 7%
rel_KMg  = K_total / Mg_atual      // aviso se > 1.0
rel_KCa  = K_total / Ca_atual      // aviso se > 0.4
```

Detalhes completos: `PROMPT/04_potassio.md`

---

## 5. Micronutrientes (`micronutrientes_engine.dart`)

**NC solo padrão por elemento (Fancelli 2020, Mehlich/DTPA, mg/dm³):**

```dart
// B:  MB<0.20, B:0.21-0.35, M:0.36-0.60, A:0.61-0.90, MA>0.90
// Cu: MB<0.30, B:0.31-0.70, M:0.71-1.20, A:1.21-1.80, MA>1.80
// Fe: MB<8,   B:9-18,      M:19-30,     A:31-45,     MA>45
// Mn: MB<2,   B:3-5,       M:6-8,       A:9-12,      MA>12
// Zn: MB<0.40, B:0.41-0.90, M:0.91-1.50, A:1.51-2.20, MA>2.20
```

**Cálculo via solo:**
```dart
deficit       = max(0, NC − micro_solo)
dose_elem_g   = deficit × 2 × 1000 × (pct_correcao / 100)
dose_produto  = dose_elem_g / (teor_fonte / 100) / (eficiencia / 100) / 1000
```

**Cálculo via foliar:**
```dart
// dose_elemento definida na Calibração (g/ha por elemento)
dose_produto = dose_elemento / (teor_fonte / 100) / (eficiencia_foliar / 100)
```

**Grupos de aplicação (produto formulado):**
```dart
// Para cada elemento E no grupo:
dose_produto_E = dose_elemento_E / (teor_E_no_produto / 100) / (eficiencia_grupo / 100)
// Dose do grupo = max(dose_produto_E) para todos os elementos
```

Detalhes completos: `PROMPT/06_micronutrientes.md`

---

## 6. Conversões (`conversoes.dart`)

```dart
// Fósforo
pToP2O5 = 2.291;      p2O5ToP = 0.437;

// Potássio
kToK2O = 1.205;       k2OToK = 0.830;
kMgDm3ToCmolc = 1/391; // K mg/dm³ → cmolc/dm³

// Cálcio e Magnésio
caToCaO = 1.399;      caOToCa = 0.715;
mgToMgO = 1.658;      mgOToMg = 0.602;

// Enxofre
sToSO3 = 2.5;         sToSO4 = 2.996;

// Área e volume
mgDm3ToKgHa = 2.0;   // camada 0–20 cm, ds = 1,0
kgHaToTHa = 0.001;   tHaToKgHa = 1000.0;

// Gesso
gessoEquivGrama = 86.0;

// Calcário
fatorCaO_Ca = 0.71428;   // CaO → Ca
fatorMgO_Mg = 0.60199;   // MgO → Mg
fatorPN_1 = 1.79;        // CaO → PN
fatorPN_2 = 2.48;        // MgO → PN
```

Detalhes completos: `PROMPT/00_conversoes.md`

---

## 7. Arquivos de Referência (pasta PROMPT/)

Estes arquivos são a fonte de verdade do motor e alimentam a tela
"Referências Técnicas" em Config:

| Arquivo | Conteúdo | Linhas |
|---|---|---|
| `00_conversoes.md` | Fatores, constantes, tabelas de conversão | 307 |
| `01_calagem.md` | 7 métodos + Y + Albrecht + sequência correções | 438 |
| `02_gesso.md` | 4 métodos gessagem + diagnóstico subsolo | 171 |
| `03_fosforo.md` | NC extratores + Modos 1 e 2 + Legacy P | 179 |
| `04_potassio.md` | NC teor/%CTC + Modos 1 e 2 + antagonismos | 173 |
| `05_enxofre.md` | NC + S via gesso + fontes | 187 |
| `06_micronutrientes.md` | B,Cu,Fe,Mn,Zn,Mo,Co,Ni,Se + NC + foliares | 243 |
| `07_nitrogenio.md` | FBN + inoculantes + NBPT + inibidores | 245 |
| `08_fertilizantes_especiais.md` | Organominerais + FEP + fator F | 252 |

> **Como usar no app:** a tela Referências Técnicas (Config) lê esses
> arquivos e exibe o conteúdo completo ao técnico.
> O motor Dart usa os valores hardcoded neste arquivo `08_AGRO_FORMULAS.md`
> como constantes de implementação.

---

*Documento: 08_AGRO_FORMULAS.md · SoloForte v2.0 · Março 2026*
*Motor expandido: 7 métodos calagem + Albrecht + Y + P + K + Micros*
