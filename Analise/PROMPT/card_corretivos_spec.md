# Card: Corretivos — Especificação Definitiva
**SoloForte · Lab → Calibração**
Versão 2.0 · Março 2026

---

## 1. Filosofia do Card

Este card é **democrático por princípio**. Todos os valores de referência são
sugestões de partida baseadas em Fancelli (2020), Albrecht, Vitti e EMBRAPA —
mas 100% editáveis. Técnicos de diferentes escolas, regiões e culturas devem
conseguir usar sem restrição.

**Nenhum campo trava o cálculo. Avisos informam, nunca bloqueiam.**

---

## 2. Tipo de Calagem

Primeiro campo do card — define o contexto de toda a recomendação.

**Componente:** Segmented control (2 opções)

| Opção | Descrição | Métodos disponíveis |
|---|---|---|
| Corretiva | Solo degradado, V% muito baixo, primeira correção | Todos os 7 métodos |
| Manutenção (PD) | Plantio Direto estabelecido, reposição periódica | ① V%, ⑤ Albrecht, ⑥ Albrecht (Y) |

**Critério de gatilho para Manutenção em PD (Fancelli, 2020):**
```
Profundidade 0–10 cm:  V% < 60% → calagem de manutenção indicada
Profundidade 0–20 cm:  V% < 50% → calagem de manutenção indicada

Profundidade lida automaticamente da Análise de Solo.
Se não informada → padrão 0–20 cm.
```

Badge contextual (informativo):
- V% dentro do limite → ✅ "Solo não necessita calagem de manutenção"
- V% abaixo do limite → 🟡 "Calagem de manutenção indicada"

---

## 3. Seção Calcário

---

### 3.1 Tipo de Calcário

**Componente:** Dropdown
Ao selecionar, pré-carrega os campos 3.2 com valores padrão editáveis.

| Tipo | CaO (%) | MgO (%) | PN (%) | RE (%) | PRNT (%) |
|---|---|---|---|---|---|
| Dolomítico | 30 | 16 | 90 | 90 | 81 |
| Calcítico | 42 | 3 | 88 | 85 | 75 |
| Magnesiano | 36 | 10 | 85 | 88 | 75 |
| Calcinado | 50 | 5 | 120 | 95 | 114 |
| Filler (micromoído) | 38 | 12 | 92 | 100 | 92 |
| Personalizado | — | — | — | — | — |

> Valores são sugestão. Usuário sempre confere com o laudo do calcário.

---

### 3.2 Qualidade do Calcário (1º Calcário)

Todos: `AppInput numérico, max 7 dígitos`

| Campo | Símbolo | Unidade | Observação |
|---|---|---|---|
| Óxido de Cálcio | CaO | % | Do laudo |
| Óxido de Magnésio | MgO | % | Do laudo |
| Poder de Neutralização | PN | % | Do laudo |
| Reatividade | RE | % | Do laudo |
| PRNT | PRNT | % | Auto: (PN × RE) / 100 — editável |

**Cálculos automáticos derivados (usados no motor):**
```
PRNT     = (PN × RE) / 100

fator_Ca = (CaO / 100) × 0,71428   → Ca real por t de calcário
fator_Mg = (MgO / 100) × 0,60199   → Mg real por t de calcário
```

---

### 3.3 Score de Qualidade do Calcário

Exibido automaticamente. Baseado em Fancelli (2020):
> "O PN é o parâmetro fundamental. O pior calcário é o de RE alto com PN baixo —
> não adianta moer mais fino um calcário de má qualidade."

**Fórmula:**
```
Residual (%) = PN − PRNT

Quanto maior → maior fração de ação lenta → maior efeito residual no solo
```

**Classificação:**

| Residual (PN − PRNT) | Classificação | Significado |
|---|---|---|
| 0 a 5% | Ação imediata | RE alto, age rápido, baixo residual |
| 6 a 15% | Intermediário | Equilíbrio ação rápida + residual |
| > 15% | Alto residual | PN alto, RE menor, efeito prolongado |

**Exibição no card:**
```
Score: ■■■□□  Intermediário
PN: 98,5% · RE: 90,9% · Residual: 7,6%
💡 Boa opção quando há 60–90 dias antes do plantio
```

**Cruzamento com mês de aplicação:**

| Combinação | Aviso |
|---|---|
| Residual alto + < 30 dias | ⚠️ "Calcário de ação lenta — antecipe a aplicação" |
| Residual baixo + < 30 dias | ✅ "Calcário de ação rápida — adequado para esta época" |
| Residual alto + > 90 dias | ✅✅ "Combinação ideal — ação imediata + residual garantido" |

---

### 3.4 Segundo Calcário (opcional)

**Toggle:** "Usar segundo calcário?" — padrão: Não

Se Sim → expande bloco idêntico ao 3.2 com label "2º Calcário" + campo de proporção:

| Campo | Tipo | Padrão |
|---|---|---|
| % do 1º calcário | AppInput numérico | 50% |
| % do 2º calcário | Auto: 100 − % do 1º | 50% |

**PRNT ponderado:**
```
PRNT_final = (prop1/100 × PRNT1) + (prop2/100 × PRNT2)

fator_Ca_final = (prop1/100 × fator_Ca1) + (prop2/100 × fator_Ca2)
fator_Mg_final = (prop1/100 × fator_Mg1) + (prop2/100 × fator_Mg2)
```

Exibir: `"PRNT ponderado: XX%"` em destaque.

---

### 3.5 Método de Calagem

**Componente:** Dropdown
Opções filtradas pelo Tipo de Calagem (seção 2):

**Corretiva — todos os 7:**
```
① Saturação por Bases (V%)
② Tradicional EMBRAPA (H+Al × Fator)
③ NC = Ca + Mg
④ Supercalagem (dose fixa)
⑤ Albrecht (Equilíbrio de Bases)
⑥ Albrecht (Y) — com proteção tampão
⑦ Correção Direcionada (Mg)
```

**Manutenção (PD) — apenas 3:**
```
① Saturação por Bases (V%)
⑤ Albrecht (Equilíbrio de Bases)
⑥ Albrecht (Y) — com proteção tampão
```

**Parâmetros extras por método** (expandem ao selecionar):

| Método | Campos extras |
|---|---|
| ① V% | V₂ desejado (%) — sugestão por cultura (ver 3.6.2) |
| ② EMBRAPA | Fator H+Al — padrão 0,5, editável |
| ③ Ca+Mg | Nenhum |
| ④ Supercalagem | Dose fixa (t/ha) |
| ⑤ Albrecht | Bloco Metas Albrecht (seção 3.6) |
| ⑥ Albrecht (Y) | Bloco Metas Albrecht + Painel Y (seção 3.6) |
| ⑦ Correção Mg | Mg desejado (cmolc/dm³) |

---

### 3.6 Bloco Metas Albrecht

**Visibilidade:** aparece somente quando método ⑤ ou ⑥ selecionado.

---

#### 3.6.1 Cultura de Referência

Lida automaticamente da Análise de Solo.
Exibida como label read-only: `"Cultura: Soja"`

---

#### 3.6.2 Metas de Saturação (%) — editáveis por cultura

Valores padrão sugeridos, todos editáveis:

| Cultura | %Ca alvo | %Mg alvo | %K alvo | V% implícito |
|---|---|---|---|---|
| Soja | 65% | 15% | 4% | 84% |
| Milho | 65% | 15% | 4% | 84% |
| Feijão | 65% | 15% | 5% | 85% |
| Algodão | 65% | 12% | 5% | 82% |

Campos: `AppInput numérico, max 7 dígitos`
Hints abaixo de cada campo: "%Ca: ref. 50–70%", "%Mg: ref. 10–20%", "%K: ref. 3–5%"

**V% implícito — calculado em tempo real, read-only:**
```
V%_Albrecht = %Ca_alvo + %Mg_alvo + %K_alvo + %Na_alvo (se ativo)
```

**Validação visual (aviso, sem bloqueio):**
- V% < 50% → ⚠️ "V% resultante abaixo do recomendado para culturas anuais"
- 50–80% → ✅ "Equilíbrio adequado"
- > 80% → ⚠️ "V% resultante elevado — verifique necessidade"

---

#### 3.6.3 Níveis Críticos Absolutos (cmolc/dm³) — editáveis

Piso mínimo independente da saturação calculada.
Se a dose pelo déficit de saturação não atingir o NC → dose sobe automaticamente.

| Campo | Símbolo | Padrão | Fonte do padrão |
|---|---|---|---|
| Ca mínimo | NC_Ca | 2,0 | Fancelli (2020): ideal ≥ 2,4; mín. 0,8 |
| Mg mínimo | NC_Mg | 0,8 | Fancelli (2020): mín. 0,8 cmolc/dm³ |
| K mínimo | NC_K | 0,15 | EMBRAPA: classe médio 0,15–0,30 |

**Fórmula de decisão (por base):**
```
teor_alvo     = (%_alvo / 100) × CTC
deficit       = max(0, teor_alvo − teor_atual)
teor_result   = teor_atual + (dose_calc × fator_base)

Se teor_result < NC_abs:
  → aumentar dose até teor_result = NC_abs
  → exibir: ℹ️ "Dose ajustada para atingir NC mínimo de [base]"
```

---

#### 3.6.4 Sódio Na — opcional

**Toggle:** "Incluir Na?" — padrão: Não (oculto)

Quando ativado:

| Campo | Padrão | Observação |
|---|---|---|
| %Na alvo (%) | 0 | Entra no V% implícito |
| Na máximo (cmolc/dm³) | 0,1 | PST > 15% → solo sódico |

**Diagnóstico de sodicidade:**
```
PST (%) = (Na_atual / CTC) × 100

PST > 15% → ⛔ "Solo sódico — considerar gessagem corretiva"
PST 5–15% → ⚠️ "Tendência sódica"
PST < 5%  → sem alerta
```

---

#### 3.6.5 Painel de Déficits — tempo real

```
┌──────────────────────────────────────────────┐
│  Base    Atual    Alvo     Déficit            │
│  Ca      2,0  →  3,9      1,9 cmolc/dm³      │
│  Mg      0,5  →  0,9      0,4 cmolc/dm³      │
│  K       0,16 →  0,24     0,08 cmolc/dm³     │
│  ─────────────────────────────────────────── │
│  V% atual: 57,1%   →   V% alvo: 84%          │
└──────────────────────────────────────────────┘
```

---

#### 3.6.6 Painel Y — somente método ⑥

**Quando Y prevalece (NC_Albrecht < Y):**
```
┌──────────────────────────────────────────────┐
│  🛡️ Proteção Tampão (Y)                       │
│  NC pelo Albrecht:  1,78 t/ha                │
│  Y do solo:         2,41 t/ha                │
│  → Dose base: 2,41 t/ha  (Y prevalece)       │
│  ⚠️ Solo resistente — Y supera Albrecht       │
└──────────────────────────────────────────────┘
```

**Quando Albrecht prevalece (NC_Albrecht ≥ Y):**
```
┌──────────────────────────────────────────────┐
│  🛡️ Proteção Tampão (Y)                       │
│  NC pelo Albrecht:  2,15 t/ha                │
│  Y do solo:         1,20 t/ha                │
│  → Dose base: 2,15 t/ha  (Albrecht adequado) │
│  ✅ Albrecht supera tampão                    │
└──────────────────────────────────────────────┘
```

---

### 3.7 Método de Incorporação

**Componente:** Dropdown

| Opção | Prof. padrão sugerida |
|---|---|
| Sem incorporação (superfície) | 0 cm |
| Grade aradora leve | Calculada (seção 3.8) |
| Grade aradora pesada | Calculada (seção 3.8) |
| Arado de disco / aiveca | 25 cm (editável) |
| Escarificador / subsolador | 35 cm (editável) |

---

### 3.8 Profundidade de Incorporação

Interpolação linear aplicada para todos os implementos.

---

#### 3.8.1 Grade Aradora — cálculo automático

Subcampos expandem ao selecionar grade:

| Tipo | Diâmetro (pol) | Diâmetro (cm) | Raio (cm) |
|---|---|---|---|
| 22" | 22 | 55,88 | 27,94 |
| 24" | 24 | 60,96 | 30,48 |
| 26" | 26 | 66,04 | 33,02 |
| 28" | 28 | 71,12 | 35,56 |
| 32" | 32 | 81,28 | 40,64 |

**Folga de mancal:** AppInput numérico (cm) — padrão 25 cm

**Fórmula:**
```
Raio_cm         = Diâmetro_pol × 2,54 / 2
Prof_grade (cm) = Raio_cm − (Folga_mancal / 2)
```

**Exemplos:**
```
Grade 32" + folga 25 cm → Prof = 40,64 − 12,5 = 28,14 cm
Grade 22" + folga 25 cm → Prof = 27,94 − 12,5 = 15,44 cm
```

Exibir: `"Profundidade estimada: XX,X cm"`

---

#### 3.8.2 Outros Implementos

Campo AppInput numérico (cm) com valor padrão da tabela 3.7. Editável.

---

#### 3.8.3 Fator p — interpolação linear

Âncoras (Fancelli, 2020):

| Prof (cm) | Fator p |
|---|---|
| 0 | 0 |
| 20 | 1,00 |
| 40 | 2,03 |
| 60 | 3,00 |

**Fórmula:**
```
0 ≤ Prof ≤ 20:    p = Prof / 20
20 < Prof ≤ 40:   p = 1,00 + ((Prof − 20) / 20) × 1,03
40 < Prof ≤ 60:   p = 2,03 + ((Prof − 40) / 20) × 0,97
```

Exibir: `"Fator p: X,XX"`

---

### 3.9 Superfície de Contato

**Componente:** Dropdown

| Método de Aplicação | SC (%) | Fator SC |
|---|---|---|
| Incorporado total (2 gradagens cruzadas) | 100% | 1,00 |
| Incorporado parcial (1 gradagem) | 90% | 0,90 |
| Superfície com chuva > 30 mm prevista | 85% | 0,85 |
| Superfície sem incorporação (PD) | 80% | 0,80 |

---

### 3.10 Sequência Completa de Cálculo

```
Passo 1 — NC_base    = resultado do método (01_calagem.md)
Passo 2 — NC_prof    = NC_base × p
Passo 3 — NC_prnt    = NC_prof ÷ (PRNT_final / 100)
Passo 4 — Dose_final = NC_prnt ÷ SC

Saída: Dose_final em t/ha
```

Exibir em destaque azul: `"Dose Final: X,XX t/ha"`

---

### 3.11 Parcelamento

**Gatilho automático** (sem bloqueio):
```
H+Al > 3,0 cmolc/dm³   ou   Dose_final > 3,0 t/ha
```

Quando gatilho ativo → exibir bloco sugestão expansível:

```
┌──────────────────────────────────────────────────┐
│  📋 Sugestão de Parcelamento                      │
│                                                   │
│  Dose total: 4,2 t/ha                            │
│  Nº de aplicações: [Dropdown: 2 / 3 / 4]         │
│                                                   │
│  Aplicação 1:  60%  = 2,52 t/ha                  │
│  Mês sugerido: [Data_plantio − 90 dias]           │
│                                                   │
│  Aplicação 2:  40%  = 1,68 t/ha                  │
│  Mês sugerido: [Data_plantio − 30 dias]           │
│                                                   │
│  Proporções editáveis. Total sempre = 100%.       │
└──────────────────────────────────────────────────┘
```

**Cálculo das datas sugeridas:**
```
Data_plantio    = da Análise de Solo (cultura + época)
Aplic1_sugerida = Data_plantio − 90 dias
Aplic2_sugerida = Data_plantio − 30 dias
```

Sugestão apenas — técnico ajusta livremente.

---

### 3.12 Mês de Aplicação

**Componente:** Dropdown (Jan–Dez)

```
Dias_disponíveis = Data_plantio − Data_aplicacao
```

| Dias disponíveis | Badge |
|---|---|
| < 30 | ⚠️ Muito curto |
| 30–60 | ⚡ Mínimo aceitável |
| 60–90 | ✅ Adequado |
| > 90 | ✅✅ Ideal |

**Dica contextual por textura (argila da Análise):**
```
Argila < 20%:  "Solo arenoso — preferir calcário com RE alto
                (ação rápida). Requer reaplicação mais frequente."

Argila ≥ 40%:  "Solo argiloso — preferir PN alto com RE moderado.
                Efeito residual compensado pelo alto poder tampão."
```

---

### 3.13 Avisos Contextuais (todos sem bloqueio)

| Condição | Aviso |
|---|---|
| Dose > 4 t/ha + sem incorporação | ⚠️ "Dose elevada sem incorporação — risco de pH alto na superfície, imobilização de P e redução de micronutrientes (Fancelli, 2020)" |
| m% > 25% | ⚠️ "Saturação de Al elevada — verifique possível contaminação na análise antes de prosseguir" |
| Dias disponíveis < 30 | ⚠️ "Menos de 30 dias até o plantio — preferir calcário filler ou calcinado (RE = 100%)" |
| Dias disponíveis 30–60 | ℹ️ "30–60 dias — mínimo aceitável (Fancelli recomenda ≥ 60 dias)" |
| Residual alto + poucos dias | ⚠️ "Calcário com ação lenta — calcário de alta RE seria mais adequado nesta época" |
| CaO + MgO > 100% | ⚠️ "Soma CaO + MgO inválida — verifique laudo" |
| V%_Albrecht > 100% | ⚠️ "Soma das saturações-alvo ultrapassa 100% — revise as metas" |

---

## 4. Seção Gesso

**Toggle:** "Vai usar gesso?" — padrão: Não

---

### 4.1 Diagnóstico Automático

Dados de subsolo lidos da Análise de Solo (camada 20–40 cm):

```
Gessagem indicada se qualquer condição for verdadeira:
  Ca_sub  < 0,5 cmolc/dm³
  Al_sub  > 0,5 cmolc/dm³
  m%_sub  > 25%
```

Badge (informativo):
- 🟡 "Diagnóstico: gessagem indicada — Ca: X,X / Al: X,X / m%: XX%"
- ✅ "Subsolo adequado — gessagem não indicada pelos critérios"

Se dados de subsolo não estiverem na Análise → campos aparecem para entrada manual.

---

### 4.2 Qualidade do Gesso

| Campo | Padrão | Editável |
|---|---|---|
| Teor de Ca (%) | 20% | Sim |
| Teor de S (%) | 15% | Sim |

```
S_fornecido (kg/ha) = Dose_gesso × (Teor_S / 100)
```

Exibir: `"S fornecido: XXX kg/ha"` — alimenta o card Enxofre automaticamente.

---

### 4.3 Método de Gessagem

**Componente:** Dropdown
```
① EMBRAPA / Souza et al. (2004) — argila %
② UFLA / Lopes et al. (2006) — tabela textural
③ ESALQ / Vitti et al. (2004) — V% e CTC subsolo
④ UEPG / Caires (2016) — CTCe e Ca subsolo
```

Fórmulas completas em 02_gesso.md.

---

## 5. Relação Ca:Mg — Saída para Recomendação

Calculada após a dose final. Exibida na tela Recomendação como argumento técnico
para justificar a escolha do método e tipo de calcário.

```
Ca_total     = Ca_atual + (Dose_final × fator_Ca_final)
Mg_total     = Mg_atual + (Dose_final × fator_Mg_final)
Relacao_CaMg = Ca_total / Mg_total
```

**Classificação:**

| Relação Ca:Mg | Classificação | Risco / Observação |
|---|---|---|
| < 1,5 | Estreita | Excesso de Mg → risco de compactação (Garcia, 2021) |
| 1,5 a 3,0 | Adequada | Equilíbrio ideal (Fancelli, Vitti) |
| 3,0 a 5,0 | Larga | Aceitável — atentar disponibilidade de Mg |
| > 5,0 | Muito larga | Risco de deficiência de Mg |

Texto gerado automaticamente na Recomendação:
> "A relação Ca:Mg resultante de X:1 indica [classificação]. [Justificativa técnica]."

---

## 6. Resumo — Dados que Alimentam a Recomendação

| Dado | Destino |
|---|---|
| Dose_final (t/ha) | Resultado principal |
| PRNT_final | Motor — todos os métodos |
| fator_Ca_final, fator_Mg_final | Cálculo Ca/Mg adicionados e saturações |
| p | Passo 2 da sequência |
| SC | Passo 4 da sequência |
| Método selecionado | Qual fórmula executar |
| Tipo calagem | Corretiva ou Manutenção |
| %Ca_alvo, %Mg_alvo, %K_alvo | Métodos ⑤ e ⑥ |
| NC_Ca, NC_Mg, NC_K | Piso mínimo — Albrecht |
| V%_Albrecht | Validação e exibição |
| Y do solo | Método ⑥ — decisão NC vs Y |
| Relação Ca:Mg | Recomendação — argumento técnico |
| Sugestão parcelamento | Cronograma da Recomendação |
| Score qualidade calcário | Recomendação — argumento técnico |
| Dose_gesso | Card Enxofre — S fornecido automático |
| Mês aplicação | Cronograma |

---

## 7. Validações — Todas como Aviso, Nenhuma como Bloqueio

| Campo | Condição de aviso |
|---|---|
| PRNT | > 145% |
| PN | > 145% |
| RE | > 100% |
| CaO + MgO | > 100% |
| prop1 + prop2 | ≠ 100% |
| %Ca + %Mg + %K + %Na | > 100% |
| V%_Albrecht | < 50% ou > 80% |
| Folga mancal | ≥ Diâmetro da grade |
| Dose_final | > 4 t/ha sem incorporação |
| m% atual | > 25% |
| Dias disponíveis | < 30 |

---

## 8. UX — Comportamentos

- Card fechado por padrão — abre ao toque no header
- Tipo de calagem: primeiro campo, filtra os métodos disponíveis
- Tipo de calcário: pré-carrega campos 3.2 com padrão editável
- PRNT: recalcula em tempo real ao editar PN ou RE
- Score qualidade: exibido automaticamente, atualiza em tempo real
- Bloco Albrecht: oculto — aparece só quando método ⑤ ou ⑥
- V% implícito Albrecht: recalcula em tempo real
- Painel déficits: atualiza em tempo real com dados da Análise
- Painel Y: só no método ⑥, compara NC vs Y em tempo real
- Fator p: atualiza ao selecionar implemento ou digitar profundidade
- Parcelamento: sugestão aparece quando gatilho ativo, sem bloquear
- Avisos: banners informativos abaixo da dose, todos descartáveis
- Toggle Na: oculto por padrão
- Gesso: seção oculta até toggle ativado
- S gesso: alimenta card Enxofre automaticamente
- Relação Ca:Mg: calculada silenciosamente, exibida na Recomendação
- Todos os inputs: max 7 dígitos

---

## 9. Fontes

| Referência | Uso no Card |
|---|---|
| Fancelli (2020) — Aulas 9, 10 | PRNT, PN, RE, profundidade, época, parcelamento, avisos |
| Fancelli (2020) — Aula 12 | Gesso, diagnóstico subsolo |
| Albrecht, W.A. (1930–1940s) | Saturações-alvo Ca/Mg/K, BCSR |
| Gismonti / Braga, G.N.M. (2021) | Adaptação brasileira Ca 50–65% |
| Garcia, J.L.M. (CODEAGRO/SP) | Ca:Mg estreita → compactação |
| Vitti, G.C. / ESALQ | Ca:Mg larga → deficiência Mg |
| EMBRAPA / Souza et al. (2004) | Método gesso ①, NC K |
| UFLA / Lopes et al. (2006) | Método gesso ② |
| ESALQ / Vitti et al. (2004) | Método gesso ③ |
| UEPG / Caires (2016) | Método gesso ④, NC absolutos |
| 01_calagem.md | Todos os 7 métodos de calagem |
| 02_gesso.md | Todos os 4 métodos de gessagem |
| 00_conversoes.md | Fatores CaO→Ca, MgO→Mg, polegadas→cm |

---

*Documento: card_corretivos_spec.md · SoloForte v2.0 · Março 2026*
*Decisões validadas com Bom — Março 2026*
