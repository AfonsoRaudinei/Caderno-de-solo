# 01 — Calagem: Motor de Cálculo
**SoloForte · Referências Técnicas**
Fontes: Fancelli (2020), Caires/UEPG (2019), UFLA/Lopes, EMBRAPA

---

## 1. Variáveis de Entrada (Análise de Solo)

| Variável | Símbolo | Unidade | Descrição |
|---|---|---|---|
| pH em CaCl₂ | pH | — | pH do solo em solução de cloreto de cálcio |
| Matéria Orgânica | MO | g/dm³ | Teor de matéria orgânica |
| Cálcio trocável | Ca²⁺ | cmolc/dm³ | Cálcio extraível |
| Magnésio trocável | Mg²⁺ | cmolc/dm³ | Magnésio extraível |
| Potássio trocável | K⁺ | cmolc/dm³ | Converter de mg/dm³ ÷ 391 |
| Acidez potencial | H+Al | cmolc/dm³ | Tampão SMP ou direto |
| Alumínio trocável | Al³⁺ | cmolc/dm³ | Toxidez |
| Fósforo remanescente | P-rem | mg/L | Para cálculo do Y (poder tampão) |
| Argila | Arg | % | Para cálculo do Y |

---

## 2. Parâmetros Calculados da Análise

Calculados antes de qualquer método de calagem.

```
SB  = Ca + Mg + K                        (Soma de Bases, cmolc/dm³)
CTC = SB + H+Al                          (CTC total a pH 7, cmolc/dm³)
t   = SB + Al                            (CTC efetiva, cmolc/dm³)
V%  = (SB / CTC) × 100                  (Saturação por Bases atual)
m%  = (Al / t) × 100                    (Saturação por Alumínio)
```

> **Conversão K:** se laudo em mg/dm³ → K (cmolc/dm³) = K (mg/dm³) ÷ 391

---

## 3. Valor Y — Poder Tampão do Solo (CTH)

O valor Y representa a **Capacidade Tampão da Acidez (CTH)** do solo.
Quanto maior o Y, maior a resistência do solo à mudança de pH — maior a dose necessária.

Fontes: Caires (2019), UFLA, tabela UFMG 5ª Aproximação (Minas Gerais).

### 3.1 Y por Textura (Argila %)

| Classe Textural | Argila (%) | Y |
|---|---|---|
| Arenoso | 0 a 15 | 0,0 a 1,0 |
| Textura média | 15 a 35 | 1,0 a 2,0 |
| Argiloso | 35 a 60 | 2,0 a 3,0 |
| Muito argiloso | 60 a 100 | 3,0 a 4,0 |

**Equação contínua (5ª Aproximação MG):**
```
Ŷ = 0,0302 + 0,06532 × Arg − 0,000257 × Arg²     R² = 0,9996
```

### 3.2 Y por Fósforo Remanescente (P-rem)

| P-rem (mg/L) | Y |
|---|---|
| 0 a 4 | 4,0 a 3,5 |
| 4 a 10 | 3,5 a 2,9 |
| 10 a 19 | 2,9 a 2,0 |
| 19 a 30 | 2,0 a 1,2 |
| 30 a 44 | 1,2 a 0,5 |
| 44 a 60 | 0,5 a 0,0 |

### 3.3 Critério de Uso do Y no SoloForte

- Se P-rem disponível → usar Y por P-rem (mais preciso)
- Se apenas argila disponível → usar equação contínua por argila
- Se ambos disponíveis → média ponderada: Y = (Y_argila × 0,6) + (Y_prem × 0,4)

> **Regra prática (Fancelli):** H+Al > 3 cmolc/dm³ → solo de alto poder tampão → calagem deve ser parcelada.

---

## 4. Parâmetros do Corretivo

| Parâmetro | Símbolo | Unidade | Descrição |
|---|---|---|---|
| PRNT | PRNT | % | Poder Relativo de Neutralização Total |
| Profundidade incorporação | Prof | fator | Ver tabela abaixo |
| Superfície de contato | SC | fator | Redução por método de aplicação |
| Tipo de calcário | — | — | Define fatores Ca e Mg |

### 4.1 Fator de Profundidade

| Profundidade | Fator |
|---|---|
| 0–20 cm | 1,0 |
| 0–40 cm | 2,03 (= 1 + densidade 20–40 cm) |
| 0–60 cm | 3,0 |

### 4.2 Fator de Superfície de Contato

| Método de Aplicação | Fator SC |
|---|---|
| Incorporado total | 1,0 (sem redução) |
| Incorporado parcial | 0,9 (÷ 0,90) |
| Superfície sem incorporação | 0,8 (÷ 0,80) |

### 4.3 Tipos de Calcário — Fatores Ca e Mg

| Tipo | Fator Ca | Fator Mg |
|---|---|---|
| Dolomítico | 0,536 | 0,443 |
| Calcítico | 0,800 | 0,050 |
| Magnesiano | 0,600 | 0,300 |

### 4.4 Poder de Neutralização (PN)

```
PN = CaO (%) × 1,79 + MgO (%) × 2,48
```

### 4.5 Reatividade (RE)

```
RE (%) = (P10 × 0) + (P20 × 20) + (P50 × 60) + (Pfino × 100)
```

- P10 = % retido peneira 2,00 mm → eficiência 0%
- P20 = % retido peneira 0,84 mm → eficiência 20%
- P50 = % retido peneira 0,30 mm → eficiência 60%
- Pfino = % passante peneira 0,30 mm → eficiência 100%

### 4.6 PRNT

```
PRNT = (PN × RE) / 100
```

---

## 5. Sequência de Correções (Aplicada em Todos os Métodos)

Após calcular a NC base de cada método, aplicar sempre nesta ordem:

```
Passo 1 — Profundidade:
  NC_prof = NC_base × Fator_Prof

Passo 2 — PRNT:
  NC_prnt = NC_prof ÷ (PRNT / 100)

Passo 3 — Superfície de Contato:
  Dose_final = NC_prnt ÷ SC

Resultado: Dose_final em t/ha
```

---

## 6. Os Sete Métodos de Calagem

---

### 6.1 Método ① — Saturação por Bases (V%)
**Fonte:** Fancelli (2020), IAC · **Status:** Método preferencial para Cerrado

```
NC_base = ((V2 − V1) × CTC) / 100
```

- V1 = V% atual (calculado da análise)
- V2 = V% desejado (ver tabela abaixo)
- CTC = SB + H+Al (cmolc/dm³)

**Escolha do V2 por cultura e MO:**

| Cultura | MO > 4% | MO < 4% |
|---|---|---|
| Soja | 65% | 70% |
| Milho | 60% | 70% |
| Feijão | 60% | 70% |
| Algodão | 65% | 70% |
| Cerrado geral | 50–55% | 60–70% |

> Aplicar calagem com mínimo **3 meses** de antecedência ao plantio.

---

### 6.2 Método ② — Tradicional EMBRAPA (H+Al × Fator)
**Fonte:** EMBRAPA · **Status:** Usado em solos com alta acidez potencial

```
NC_base = H+Al × Fator
```

- H+Al = acidez potencial (cmolc/dm³)
- Fator padrão = 0,5 (configurável pelo usuário)
- Fator pode variar: 0,3 a 1,0 conforme textura e cultura

---

### 6.3 Método ③ — NC = Ca + Mg
**Fonte:** Clássico · **Status:** Uso limitado, não recomendado isoladamente

```
NC_base = Ca + Mg
```

- Ca e Mg = teores atuais (cmolc/dm³)
- Lógica: repõe toda a fração Ca+Mg atual
- Limitação: não considera V%, CTC nem poder tampão

> ⚠️ Fancelli: não utilizar isoladamente. Útil como referência comparativa.

---

### 6.4 Método ④ — Supercalagem
**Fonte:** Fancelli (2020) · **Status:** Dose fixa de choque para solos muito ácidos

```
NC_base = Dose fixa (definida pelo usuário, padrão 1,75 t/ha)
```

- Aplicado quando o solo tem pH < 4,5 e H+Al muito elevado
- Dose fixa independe da análise — é uma intervenção de correção estrutural
- Geralmente parcelada em 2 aplicações

---

### 6.5 Método ⑤ — Albrecht (Equilíbrio de Bases)
**Fonte:** William Albrecht (Univ. Missouri, 1930–1940s), Gismonti (2021) · **Status:** Método por saturação ideal de cátions na CTC

#### Conceito
O método Albrecht não calcula uma necessidade de calcário diretamente pela acidez — ele parte de **metas de saturação ideais para Ca, Mg e K na CTC** e calcula quanto de cada base precisa ser **adicionado** para atingir esse equilíbrio.

A ideia central: o solo fértil tem proporções ideais de cátions nos sítios de troca, não apenas pH corrigido.

#### Saturações-alvo (Albrecht / BCSR)

| Cátion | Saturação mínima | Saturação máxima | Referência |
|---|---|---|---|
| Ca | 60% | 70% | Albrecht original (EUA) |
| Ca | 50% | 65% | Adaptação brasileira (Gismonti) |
| Mg | 10% | 20% | Ambas |
| K  | 3%  | 5%  | Ambas |

> O usuário configura qual faixa usar. Padrão SoloForte: Ca 60–70%, Mg 10–20%, K 3–5%.

#### Passo 1 — Teor necessário de cada base

```
Ca_necessario = (%Ca_alvo / 100) × CTC      (cmolc/dm³)
Mg_necessario = (%Mg_alvo / 100) × CTC      (cmolc/dm³)
K_necessario  = (%K_alvo  / 100) × CTC      (cmolc/dm³)
```

Use o valor mínimo da faixa como alvo de partida.

#### Passo 2 — Déficit de cada base

```
deficit_Ca = max(0, Ca_necessario − Ca_atual)   (cmolc/dm³)
deficit_Mg = max(0, Mg_necessario − Mg_atual)   (cmolc/dm³)
deficit_K  = max(0, K_necessario  − K_atual)    (cmolc/dm³)
```

Se déficit ≤ 0 → base já está no nível adequado, sem necessidade de correção.

#### Passo 3 — Conversão déficit Ca → dose de calcário

```
Ca_kg_ha = deficit_Ca × 200     (mg/dm³ × 2 = kg/ha; 1 cmolc Ca = 200 mg/dm³)

Dose_calcario_Ca (kg/ha) = Ca_kg_ha / (CaO% × 0,71428)
```

Onde `CaO% × 0,71428` = teor real de Ca no calcário (CaO → Ca: ÷ 1,399).

#### Passo 3b — Conversão déficit Mg → dose de calcário dolomítico ou silicato

```
Mg_kg_ha = deficit_Mg × 120     (1 cmolc Mg = 120 mg/dm³)

Dose_calcario_Mg (kg/ha) = Mg_kg_ha / (MgO% × 0,602)
```

> Se o calcário dolomítico supre Ca e Mg: verificar se uma única dose de calcário atende ambos os déficits simultaneamente. Se não, considerar silicato de Mg para o déficit de Mg.

#### Passo 3c — Conversão déficit K → dose de KCl

```
K_kg_ha = deficit_K × 391       (1 cmolc K = 391 mg/dm³)
K2O_kg_ha = K_kg_ha × 1,205
KCl_kg_ha = K2O_kg_ha / 0,50   (KCl tem ~50% K₂O)
```

#### NC_base para calagem (componente Ca)

Para fins de comparação com os demais métodos, a NC do Albrecht é expressa como a dose de calcário necessária para suprir o déficit de Ca:

```
NC_base (Albrecht) = Dose_calcario_Ca (convertida para t/ha)
```

Depois, aplicar as **correções padrão** (Profundidade → PRNT → Superfície de Contato) conforme seção 5.

#### Notas práticas

- Se Ca e Mg estão ambos deficientes: usar calcário dolomítico e verificar se uma única dose atende ambos
- Se só Mg está deficiente: usar silicato de magnésio (21% Mg) ou calcário dolomítico isolado
- K é corrigido via adubação potássica — independente do calcário
- O excesso de Mg (acima de 20%) pode causar compactação do solo (Garcia, 2021 — "Teste da Bota")
- O excesso de K (acima de 5–7%) pode induzir antagonismo com Ca e Mg

> **Referências:** Albrecht (1930–1940s), Gismonti/Braga (2021), Garcia J.L.M. — "Equilíbrio de Bases e Fertilidade Agrícola", CODEAGRO/SP

---

### 6.6 Método ⑥ — Albrecht com Tampão (Y)
**Fonte:** Formulação SoloForte · **Status:** Extensão do Albrecht original com proteção pelo poder tampão

#### Conceito

Idêntico ao Método ⑤ (Albrecht puro) em sua lógica de equilíbrio de bases, com uma única diferença: a dose de calcário calculada é comparada ao valor Y (poder tampão do solo). Se a dose calculada for menor que Y, usa-se Y como dose mínima.

**Razão:** um solo com alto poder tampão (alta argila, alta MO, alto H+Al) resiste à mudança de pH. Se a dose calculada pelo equilíbrio de bases não for suficiente para vencer essa resistência, o pH não se altera e o equilíbrio desejado não é atingido.

#### Fórmula

```
NC_albrecht     = Dose calculada pelo Método ⑤ (Albrecht puro)
NC_base (Y)     = max(NC_albrecht, Y)
```

#### Regra de decisão

```
Se NC_albrecht >= Y  → usar NC_albrecht    (equilíbrio de bases é suficiente)
Se NC_albrecht  < Y  → usar Y              (tampão prevalece — dose mínima = Y)
```

#### Diferença entre os dois métodos

| Característica | Método ⑤ Albrecht | Método ⑥ Albrecht (Y) |
|---|---|---|
| Base do cálculo | Equilíbrio Ca/Mg/K na CTC | Equilíbrio Ca/Mg/K na CTC |
| Proteção tampão | ❌ Não considera | ✅ Usa Y como dose mínima |
| Risco em solos tampão | Subdosagem possível | Dose garantida ≥ Y |
| Quando usar | Solos de baixo tampão (arenosos, baixa MO) | Solos de alto tampão (argilosos, alta MO, H+Al > 3) |

> Esta extensão com Y é uma formulação própria do SoloForte.
> Nomenclatura interna: **Albrecht (Y)** para distinguir do Albrecht original (⑤).

---

### 6.7 Método ⑦ — Correção Direcionada (Mg)
**Fonte:** Fancelli (2020) · **Status:** Usado quando o déficit é especificamente de Mg

```
Deficit_Mg = Mg_desejado − Mg_atual        (se negativo → sem necessidade)
NC_base    = Deficit_Mg / Fator_Mg_calcário
```

- Fator_Mg depende do tipo de calcário (ex: dolomítico = 0,443)
- Usado quando Ca está adequado mas Mg é insuficiente
- Evita superdose de Ca por excesso de calcário calcítico

---

## 7. Cálculo de Nutrientes Adicionados e Saturações Finais

Aplicar após obter a Dose_final de cada método:

```
Ca_adicionado = Dose_final × Fator_Ca_calcário
Mg_adicionado = Dose_final × Fator_Mg_calcário

Ca_total  = Ca_atual + Ca_adicionado
Mg_total  = Mg_atual + Mg_adicionado
CTC_nova  = CTC_atual + Ca_adicionado + Mg_adicionado

%Ca  = (Ca_total / CTC_nova) × 100
%Mg  = (Mg_total / CTC_nova) × 100
%K   = (K / CTC_nova) × 100
V%_final = ((Ca_total + Mg_total + K) / CTC_nova) × 100
```

---

## 8. Equilíbrio de Bases — Referência de Qualidade

| Elemento | Participação ideal na CTC |
|---|---|
| Ca | 35 a 50% |
| Mg | 12 a 20% |
| K | 3 a 5% |
| V% geral | 50 a 75% |
| Relação Ca:Mg | > 1,5 (Ca não deve dominar excessivamente) |
| Mg mínimo | 0,8 cmolc/dm³ |

---

## 9. Reação do Calcário no Solo (Referência)

```
CaCO₃ + H₂O → Ca²⁺ + HCO₃⁻ + OH⁻

H⁺  + HCO₃⁻  → H₂CO₃ → CO₂ + H₂O
H⁺  + OH⁻    → H₂O
Al³⁺ + 3OH⁻  → Al(OH)₃  (precipitação do alumínio tóxico)
```

---

## 10. Poder Tampão — Regras Práticas (Fancelli)

- Quanto maior o teor de MO, argila e óxidos de Fe/Al → maior poder tampão → maior NC
- Solos arenosos com baixa MO → baixo poder tampão → menor NC, calagem mais frequente
- H+Al > 3 cmolc/dm³ → parcelar calagem em 2 aplicações
- Neossolo (arenoso) vs Latossolo (argiloso): mesmo pH, necessidades de calagem muito diferentes

---

## 11. Fontes e Referências

| Referência | Uso no Motor |
|---|---|
| Fancelli, A.L. (2020) | Métodos V%, Ca+Mg, Supercalagem, Correção Mg |
| Albrecht, W.A. (1930–1940s) | Método Albrecht — equilíbrio de bases Ca/Mg/K na CTC |
| Gismonti / Braga, G.N.M. (2021) | Adaptação brasileira do Albrecht, saturações Ca 50–65% |
| Garcia, J.L.M. (CODEAGRO/SP) | Excesso de Mg e compactação, publicação Equilíbrio de Bases |
| Caires, E.F. / UEPG (2019) | Valor Y por P-rem, poder tampão |
| UFLA / Lopes et al. | Tabelas Y por textura |
| 5ª Aproximação MG / UFMG | Equação contínua Y = f(argila) |
| EMBRAPA / Souza et al. | Método H+Al × fator |
| IAC (2016) | V% por cultura no Cerrado |

---

*Documento: 01_calagem.md · SoloForte v1.1 · Março 2026 · Adicionados Métodos ⑤ Albrecht e ⑥ Albrecht (Y)*
