# 00 — Conversões de Unidades e Constantes
**SoloForte · Referências Técnicas**
Fontes: Fancelli (2020) Aula 8, EMBRAPA, IAC, química analítica padrão

---

## 1. Propósito deste Documento

Este arquivo centraliza **todas as conversões de unidade, fatores e constantes** usados pelo motor do SoloForte. É a referência que o desenvolvedor Dart consulta para garantir que os cálculos usam as unidades corretas antes de aplicar qualquer fórmula.

> Regra de ouro: **converter sempre para a unidade padrão do motor antes de calcular.**
> Unidade padrão do motor: **cmolc/dm³** para cátions, **mg/dm³** para micronutrientes e P, **%** para saturações.

---

## 2. Unidades de Análise de Solo — Padrão de Laudos no Brasil

| Nutriente / Parâmetro | Extrator | Unidade comum no laudo | Unidade padrão motor |
|---|---|---|---|
| pH (CaCl₂) | CaCl₂ 0,01 mol/L | adimensional | adimensional |
| pH (água) | H₂O | adimensional | adimensional |
| Matéria Orgânica | Walkley-Black / Colorimetria | g/dm³ ou % | g/dm³ |
| P | Resina / Mehlich-1 / Mehlich-3 | mg/dm³ | mg/dm³ |
| K | Resina / Mehlich-1 | mg/dm³ ou mmolc/dm³ | cmolc/dm³ |
| Ca | Resina / KCl | mmolc/dm³ ou cmolc/dm³ | cmolc/dm³ |
| Mg | Resina / KCl | mmolc/dm³ ou cmolc/dm³ | cmolc/dm³ |
| Al | KCl 1 mol/L | mmolc/dm³ ou cmolc/dm³ | cmolc/dm³ |
| H+Al | Tampão SMP | mmolc/dm³ ou cmolc/dm³ | cmolc/dm³ |
| S | Fosfato de cálcio | mg/dm³ | mg/dm³ |
| B | Água quente | mg/dm³ | mg/dm³ |
| Cu | DTPA-TEA / Mehlich-1 | mg/dm³ | mg/dm³ |
| Fe | DTPA-TEA / Mehlich-1 | mg/dm³ | mg/dm³ |
| Mn | DTPA-TEA / Mehlich-1 | mg/dm³ | mg/dm³ |
| Zn | DTPA-TEA / Mehlich-1 | mg/dm³ | mg/dm³ |
| Mo | Oxalato de amônio | mg/dm³ | mg/dm³ |

---

## 3. Conversões de Unidades Gerais

**Fonte: Fancelli, Aula 8 (2020)**

| Unidade de origem (A) | Unidade destino (B) | Fator (B = A × F) |
|---|---|---|
| % | g/kg | × 10 |
| % | g/dm³ | × 10 |
| % | g/L | × 10 |
| ppm | mg/kg | × 1 |
| ppm | mg/dm³ | × 1 |
| ppm | mg/L | × 1 |
| meq/100 cm³ | mmolc/dm³ | × 10 |
| meq/100 g | cmolc/dm³ | × 1 |
| cmolc/dm³ | mmolc/dm³ | × 10 |
| mmolc/dm³ | cmolc/dm³ | ÷ 10 |

---

## 4. Conversões por Elemento — Óxidos e Formas Comerciais

**Origem dos fatores:** massas moleculares dos elementos e compostos.

### 4.1 Fósforo

```
P → P₂O₅:   × 2,291
P₂O₅ → P:   × 0,437
```

| Cálculo | Massa molecular usada |
|---|---|
| P = 31 g/mol, P₂O₅ = 142 g/mol | P₂O₅/2P = 142/62 = 2,291 |

### 4.2 Potássio

```
K → K₂O:   × 1,205
K₂O → K:   × 0,830
```

| Cálculo | Massa molecular usada |
|---|---|
| K = 39 g/mol, K₂O = 94 g/mol | K₂O/2K = 94/78 = 1,205 |

### 4.3 Cálcio

```
Ca → CaO:   × 1,399
CaO → Ca:   × 0,715
```

| Cálculo | Massa molecular usada |
|---|---|
| Ca = 40 g/mol, CaO = 56 g/mol | CaO/Ca = 56/40 = 1,399 |

### 4.4 Magnésio

```
Mg → MgO:   × 1,658
MgO → Mg:   × 0,602
```

| Cálculo | Massa molecular usada |
|---|---|
| Mg = 24 g/mol, MgO = 40,3 g/mol | MgO/Mg = 40,3/24 = 1,679 ≈ 0,602 inverso |

### 4.5 Enxofre

```
S → SO₃:    × 2,500
SO₃ → S:    × 0,400
S → SO₄:    × 2,996
SO₄ → S:    × 0,334
```

### 4.6 Nitrogênio

```
N → NH₃:        × 1,216
N → NO₃⁻:       × 4,429
Ureia → N:       × 0,467  (ureia = CO(NH₂)₂, 46% N)
Ureia → N:       teor declarado no produto
```

---

## 5. Conversão de K: mg/dm³ → cmolc/dm³

Esta é a conversão mais frequente no motor — laudos brasileiros frequentemente expressam K em mg/dm³.

```
K (cmolc/dm³) = K (mg/dm³) ÷ 391
K (mg/dm³)    = K (cmolc/dm³) × 391
```

**Origem do fator 391:**
```
Massa atômica K = 39,1 g/mol
Valência K⁺ = 1
Peso equivalente = 39,1 / 1 = 39,1 g/eq
1 cmolc/dm³ = 1 meq/100mL = 10 mmolc/dm³
Fator = 39,1 × 10 = 391 mg/dm³ por cmolc/dm³
```

---

## 6. Conversão de Ca e Mg: mmolc/dm³ → cmolc/dm³

Laudos de laboratórios do Estado de São Paulo (IAC/Resina) frequentemente usam mmolc/dm³.

```
X (cmolc/dm³) = X (mmolc/dm³) ÷ 10
X (mmolc/dm³) = X (cmolc/dm³) × 10
```

**Exemplos práticos:**
- Ca = 20 mmolc/dm³ → 2,0 cmolc/dm³
- Mg = 8 mmolc/dm³ → 0,8 cmolc/dm³
- H+Al = 45 mmolc/dm³ → 4,5 cmolc/dm³

---

## 7. Conversão de Dose: mg/dm³ → kg/ha

Para converter teor no solo em quantidade por área (camada 0–20 cm, densidade padrão 1,3 g/cm³):

```
Dose (kg/ha) = Teor (mg/dm³) × 2,0   [aproximação para 0–20 cm]
```

**Cálculo exato:**
```
Dose (kg/ha) = Teor (mg/dm³) × Profundidade (dm) × Densidade (kg/dm³)
             = Teor × 2 × 1,3
             = Teor × 2,6   [exato para ds = 1,3 g/cm³]
```

> O fator 2,0 é a aproximação padrão usada em recomendações brasileiras (considera ds ≈ 1,0 t/dm³ como simplificação). Para cálculos precisos, usar ds real do solo.

---

## 8. Fator de Profundidade — Calagem e Gessagem

| Profundidade corrigida | Fator multiplicador |
|---|---|
| 0–20 cm | 1,0 |
| 0–40 cm | 2,03 |
| 0–60 cm | 3,0 |

**Origem do fator 2,03 (0–40 cm):**
```
Camada 0–20 cm: densidade ≈ 1,0 t/dm³ → fator 1,0
Camada 20–40 cm: densidade ≈ 1,03 t/dm³ (subsolo mais compactado)
Fator total 0–40 cm = 1,0 + 1,03 = 2,03
```

---

## 9. Fatores do Calcário — PN (Poder de Neutralização)

```
PN = CaO (%) × 1,79 + MgO (%) × 2,48
```

**Origem dos fatores:**
```
1,79 = 100 / 56   (MM CaCO₃ / MM CaO)
2,48 = 100 / 40,3 (MM CaCO₃ / MM MgO)
```

---

## 10. Equivalente-Grama do Gesso

```
Equivalente-grama do gesso = 86 g/eq
```

Usado nas fórmulas de correção de solo sódico e excesso de K (02_gesso.md).

**Origem:**
```
Gesso = CaSO₄ · 2H₂O
Massa molecular = 172 g/mol
Valência Ca²⁺ = 2
Peso equivalente = 172 / 2 = 86 g/eq
```

---

## 11. Matéria Orgânica — Conversão MO ↔ Carbono Orgânico

```
MO (g/dm³) = CO (g/dm³) × 1,724
CO (g/dm³) = MO (g/dm³) × 0,580
```

**Origem do fator 1,724:**
```
Van Bemmelen: MO contém ~58% de C
Fator = 100 / 58 = 1,724
```

---

## 12. Conversões de Área e Volume

| De | Para | Fator |
|---|---|---|
| ha | m² | × 10.000 |
| m² | ha | ÷ 10.000 |
| dm³ | L | × 1 |
| dm³ | cm³ | × 1.000 |
| t/ha | kg/ha | × 1.000 |
| kg/ha | g/ha | × 1.000 |
| kg/ha | t/ha | ÷ 1.000 |

---

## 13. Tabela de Pesos Atômicos dos Elementos do Motor

| Elemento | Símbolo | Peso Atômico (g/mol) | Valência usual no solo |
|---|---|---|---|
| Hidrogênio | H | 1,0 | +1 |
| Carbono | C | 12,0 | — |
| Nitrogênio | N | 14,0 | — |
| Oxigênio | O | 16,0 | — |
| Fósforo | P | 31,0 | — |
| Enxofre | S | 32,1 | — |
| Potássio | K | 39,1 | +1 |
| Cálcio | Ca | 40,1 | +2 |
| Magnésio | Mg | 24,3 | +2 |
| Alumínio | Al | 27,0 | +3 |
| Ferro | Fe | 55,8 | +2 / +3 |
| Manganês | Mn | 54,9 | +2 |
| Zinco | Zn | 65,4 | +2 |
| Cobre | Cu | 63,5 | +2 |
| Boro | B | 10,8 | — |
| Molibdênio | Mo | 96,0 | +6 |

---

## 14. Resumo Rápido — Conversões Mais Usadas no Motor

| Situação | Conversão |
|---|---|
| Laudo K em mg/dm³ | ÷ 391 → cmolc/dm³ |
| Laudo Ca/Mg em mmolc/dm³ | ÷ 10 → cmolc/dm³ |
| Resultado em P → fertilizante | × 2,291 → P₂O₅ |
| Resultado em K → fertilizante | × 1,205 → K₂O |
| Dose em mg/dm³ → kg/ha | × 2,0 (aprox.) |
| MO% → g/dm³ | × 10 |
| Dose t/ha → kg/ha | × 1.000 |

---

## 15. Fontes e Referências

| Referência | Uso |
|---|---|
| Fancelli (2020), Aula 8 | Extratores, tabela de conversão geral |
| Química analítica padrão | Pesos atômicos, equivalentes-grama |
| EMBRAPA / Sousa & Lobato | Fator profundidade, densidade padrão |
| IAC (2016) / Raij et al. | Unidades de laudo São Paulo |

---

*Documento: 00_conversoes.md · SoloForte v1 · Março 2026*
