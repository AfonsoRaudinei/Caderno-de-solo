# 04 — Potássio (K): Motor de Cálculo
**SoloForte · Referências Técnicas**
Fontes: Fancelli (2020), IAC (2016), EMBRAPA, UFLA, Raij et al.

---

## 1. Conceito e Comportamento no Solo

O potássio move-se no solo principalmente por **fluxo de massa** e difusão. É cátion monovalente (K⁺) e compete com Ca²⁺, Mg²⁺ e NH₄⁺ pelos sítios de troca da CTC.

**Funções principais:**
- Ativação enzimática (>60 enzimas)
- Regulação osmótica e abertura de estômatos
- Transporte de açúcares (enchimento de grãos)
- Resistência a doenças e estresses hídricos

> Alta relação K:Mg ou K:Ca → antagonismo — reduz absorção de Ca e Mg mesmo com teores adequados no solo.

---

## 2. Extrator e Conversão

| Parâmetro | Detalhe |
|---|---|
| Extrator padrão | Resina (IAC/SP) ou Mehlich-1 (MG, PR, Sul) |
| Unidade laudo | mg/dm³ (ppm) ou mmolc/dm³ |
| Conversão | K (cmolc/dm³) = K (mg/dm³) ÷ 391 |

**Conversão de óxido:**
```
K₂O → K:  × 0,830
K → K₂O:  × 1,205
```

---

## 3. Variáveis de Entrada

| Variável | Símbolo | Unidade | Descrição |
|---|---|---|---|
| Potássio no solo | K | cmolc/dm³ | Da análise (converter se mg/dm³) |
| CTC total | CTC | cmolc/dm³ | SB + H+Al |
| Saturação por K na CTC | %K | % | K / CTC × 100 |
| Argila | Arg | % | Para ajuste do NC |
| Cultura | — | — | Soja / Milho / Feijão / Algodão |
| Produtividade esperada | Prod | sc/ha ou t/ha | Para manutenção |

---

## 4. Níveis Críticos e Interpretação

### 4.1 Por Saturação na CTC (método preferencial — Fancelli)

| %K na CTC | Interpretação |
|---|---|
| < 2% | Muito baixo — correção urgente |
| 2 a 3% | Baixo — corrigir |
| 3 a 5% | Adequado — manutenção |
| 5 a 7% | Alto — monitorar antagonismos Ca/Mg |
| > 7% | Muito alto — risco de desequilíbrio |

**Faixa ideal:** 3 a 5% da CTC

### 4.2 Por Teor Absoluto (mg/dm³) — Referência IAC

| Classe Textural | Argila (%) | NC K (mg/dm³) |
|---|---|---|
| Arenoso | < 15 | 40 |
| Textura média | 15 a 35 | 60 |
| Argiloso | 36 a 60 | 80 |
| Muito argiloso | > 60 | 100 |

### 4.3 Por Teor em cmolc/dm³ — Referência UFLA/EMBRAPA

| Classe | K (cmolc/dm³) |
|---|---|
| Muito baixo | < 0,08 |
| Baixo | 0,08 a 0,15 |
| Médio | 0,15 a 0,30 |
| Bom | 0,30 a 0,50 |
| Muito alto | > 0,50 |

---

## 5. Lógica de Recomendação

### 5.1 Adubação de Correção (%K abaixo do ideal)

Objetivo: elevar a saturação de K na CTC para a faixa de 3–5%.

```
K_necessario (cmolc/dm³) = (%K_desejado / 100 × CTC) − K_atual

Dose_K₂O (kg/ha) = K_necessario × 391 × 1,205 × Prof_fator
```

Onde:
- 391 = peso equivalente do K em mg/mmol
- 1,205 = conversão K → K₂O
- Prof_fator = fator de profundidade (igual ao da calagem)

### 5.2 Adubação de Manutenção

Objetivo: repor o K exportado pela colheita.

```
Dose_manutenção (kg K₂O/ha) = Exportação_cultura
```

Exportação de K₂O por cultura (referência):

| Cultura | Produtividade | Exportação K₂O |
|---|---|---|
| Soja | 60 sc/ha (3,6 t) | ~90 kg K₂O/ha |
| Milho | 150 sc/ha (9,0 t) | ~50 kg K₂O/ha |
| Feijão | 40 sc/ha (2,4 t) | ~45 kg K₂O/ha |
| Algodão caroço | 4 t/ha | ~80 kg K₂O/ha |

> O algodão é a cultura com maior dependência de K — deficiência de K é a principal causa de "murchamento" e queda de produtividade.

---

## 6. Equilíbrio de Bases com K

```
%K na CTC = (K / CTC) × 100

Relações de equilíbrio:
  Ca : Mg  > 1,5
  Ca : K   > 10 (evitar dominância excessiva de K)
  Mg : K   > 2  (Mg não pode ser suprimido por K)
```

Se %K > 7% → risco de antagonismo → pode ser necessário aumentar Ca e Mg antes de mais K.

---

## 7. Fatores que Afetam Disponibilidade de K

| Fator | Efeito |
|---|---|
| Alto Ca ou Mg | Antagonismo — reduz absorção de K |
| Déficit hídrico | Reduz fluxo de massa — menos K chega à raiz |
| Solo compactado | Reduz volume de solo explorado |
| CTC baixa (solos arenosos) | Maior lixiviação de K |
| Plantio direto antigo | Estratificação de K na superfície |

---

## 8. Conversões de Unidade — Potássio

| De | Para | Fator |
|---|---|---|
| mg/dm³ | cmolc/dm³ | ÷ 391 |
| cmolc/dm³ | mg/dm³ | × 391 |
| K | K₂O | × 1,205 |
| K₂O | K | × 0,830 |
| mg/dm³ | kg/ha (0–20 cm) | × 2,0 (aprox.) |

---

## 9. Fontes e Referências

| Referência | Uso no Motor |
|---|---|
| Fancelli (2020) | Saturação %K na CTC, equilíbrio de bases, algodão |
| IAC (2016) / Raij et al. | NC por textura em mg/dm³ |
| EMBRAPA / Sousa & Lobato | Exportação por cultura, manutenção |
| UFLA / 5ª Aproximação MG | Classes em cmolc/dm³ |

---

*Documento: 04_potassio.md · SoloForte v1 · Março 2026*
