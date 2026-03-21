# 02 — Gesso Agrícola: Motor de Cálculo
**SoloForte · Referências Técnicas**
Fontes: Fancelli (2020), EMBRAPA/Souza et al. (2004), UFLA/Lopes et al. (2006), ESALQ/Vitti et al. (2004), UEPG/Caires & Guimarães (2016)

---

## 1. Conceito e Função

O gesso agrícola (CaSO₄·2H₂O) é um **condicionador de subsuperfície** — não substitui o calcário.

Função principal: favorecer o aprofundamento do sistema radicular pela:
- Neutralização do Al³⁺ tóxico nas camadas profundas (20–40 cm)
- Disponibilização de Ca²⁺ no subsolo
- Fornecimento de S (Enxofre) para toda a planta

> ⚠️ Calcário corrige a camada 0–20 cm. Gesso atua no subsolo 20–40 cm. São complementares, nunca substitutos.

---

## 2. Composição do Gesso Agrícola

| Componente | Teor aproximado |
|---|---|
| Enxofre (S) | 15% |
| Cálcio (Ca) | 20% |
| Fórmula química | CaSO₄·2H₂O (dihidratado) |

**Equivalência prática:**
```
1 t/ha de Gesso Agrícola (~17% umidade)
= 5,0 mmolc Ca/dm³
= 0,5 cmolc Ca/dm³ fornecido ao perfil
```

---

## 3. Variáveis de Entrada (camada 20–40 cm)

| Variável | Símbolo | Unidade | Descrição |
|---|---|---|---|
| Cálcio subsolo | Ca_sub | cmolc/dm³ | Ca trocável na camada 20–40 cm |
| Alumínio subsolo | Al_sub | cmolc/dm³ | Al trocável na camada 20–40 cm |
| Saturação Al subsolo | m%_sub | % | m% = Al / CTC_efetiva × 100 |
| Argila superfície | Arg | % | Argila da camada 0–20 cm |
| V% subsolo | Va_sub | % | Saturação por bases 20–40 cm |
| CTC subsolo | CTC_sub | mmolc/dm³ | CTC a pH7 na camada 20–40 cm |
| CTC efetiva subsolo | CTCe_sub | cmolc/dm³ | t = SB + Al na camada 20–40 cm |

---

## 4. Diagnóstico — Quando Aplicar Gesso

Aplicar gesso quando pelo menos **uma** das condições abaixo for verdadeira na camada 20–40 cm:

```
Ca_sub  < 0,5 cmolc/dm³   (ou < 5,0 mmolc/dm³)
Al_sub  > 0,5 cmolc/dm³   (ou > 5,0 mmolc/dm³)
m%_sub  > 25%
```

Se nenhuma condição atendida → gessagem não indicada.

---

## 5. Os Quatro Métodos de Cálculo

---

### 5.1 Método ① — Teor de Argila (EMBRAPA)
**Fonte:** Souza et al. (2004) · **Camada referência:** 0–20 cm

**Culturas anuais:**
```
NG (kg/ha) = 50 × Arg (%)
          ou
NG (kg/ha) = 5,0 × Arg (g/kg)
```

**Culturas perenes:**
```
NG (kg/ha) = 75 × Arg (%)
          ou
NG (kg/ha) = 7,5 × Arg (g/kg)
```

---

### 5.2 Método ② — Tabela por Textura (UFLA)
**Fonte:** Lopes et al. (2006)

| Textura | Argila (%) | Dose (kg/ha) |
|---|---|---|
| Arenosa | < 15 | 700 |
| Média | 15 a 35 | 1.200 |
| Argilosa | 36 a 60 | 2.200 |
| Muito argilosa | > 60 | 3.200 |

---

### 5.3 Método ③ — V% e CTC subsolo (ESALQ/Vitti)
**Fonte:** Vitti et al. (2004) · **Válido quando Va_sub < 35%**

```
NG (t/ha) = ((50 − Va_sub) × CTC_sub) / 500
```

- Va_sub = V% atual na camada 20–40 cm (%)
- CTC_sub = CTC a pH 7 na camada 20–40 cm (mmolc/dm³)
- 500 = constante de calibração

---

### 5.4 Método ④ — CTC Efetiva e Ca (UEPG/Caires)
**Fonte:** Caires & Guimarães (2016)

```
NG (t/ha) = (0,60 × CTCe_sub − Ca_sub) × 6,4
```

- CTCe_sub = CTC efetiva 20–40 cm (cmolc/dm³)
- Ca_sub = Ca trocável 20–40 cm (cmolc/dm³)
- 6,4 = fator de equivalência do gesso

> Resultado negativo → sem necessidade de gessagem.

---

## 6. Fórmulas Especiais

### 6.1 Correção de Solo Sódico
```
NG (kg/ha) = ((PSTI − PSTF) × CTC × 86 × h × ds) / 100
```
- PSTI = PST inicial (%), PSTF = PST final desejado (%)
- CTC em mmolc/dm³, h = profundidade (cm), ds = densidade (g/cm³)
- 86 = equivalente-grama do gesso

### 6.2 Correção de Excesso de K (solos com vinhaça)
```
NG (kg/ha) = ((PSKa − PSKd) × CTC × 86 × h × ds) / 100
```
- PSKa = saturação K atual (%), PSKd = saturação K desejada (%)

---

## 7. Efeito do Gesso sobre Micronutrientes

| Nutriente | Efeito |
|---|---|
| S | Fornecido diretamente — 15% de S por tonelada |
| Ca | Fornecido diretamente — 20% de Ca por tonelada |
| Mo | Doses > 500 kg/ha aumentam necessidade de Mo, especialmente em solos arenosos |
| B | Pode ser lixiviado indiretamente em doses elevadas |

> ⚠️ Monitorar Mo quando usar gesso acima de 500 kg/ha.

---

## 8. Fontes e Referências

| Referência | Método |
|---|---|
| EMBRAPA / Souza et al. (2004) | Método ① — Argila % |
| UFLA / Lopes et al. (2006) | Método ② — Tabela textural |
| ESALQ / Vitti et al. (2004) | Método ③ — V% e CTC |
| UEPG / Caires & Guimarães (2016) | Método ④ — CTCe e Ca |
| Fancelli (2020) | Conceito, diagnóstico, relação com micronutrientes |

---

*Documento: 02_gesso.md · SoloForte v1 · Março 2026*
