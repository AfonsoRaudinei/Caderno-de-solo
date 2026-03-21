# 03 — Fósforo (P): Motor de Cálculo
**SoloForte · Referências Técnicas**
Fontes: Fancelli (2020), EMBRAPA, IAC (2016), UFLA, Raij et al.

---

## 1. Conceito e Comportamento no Solo

O fósforo é o nutriente de **menor mobilidade no solo** — move-se principalmente por difusão, numa faixa de até 5 mm ao redor da raiz.

```
Lei de Fick (difusão):
D = Di × (dc/dx)

D  = taxa de difusão do nutriente no solo (mol·cm⁻² s⁻¹)
Di = coeficiente de difusão (cm² s⁻¹)
dc/dx = gradiente de concentração (mol·cm⁻³·cm⁻¹)
```

Taxa de difusão do H₂PO₄⁻: (2,0 a 4,0) × 10⁻¹¹ cm² s⁻¹ — uma das menores do solo.

**Implicações práticas:**
- P deve ser colocado próximo à raiz (sulco de semeadura)
- Solos argilosos fixam mais P (óxidos de Fe e Al)
- Al³⁺ > 0,5 cmolc/dm³ aumenta drasticamente a fixação de P
- Excesso de calcário sem incorporação pode imobilizar P–Ca

---

## 2. Extratores Utilizados no Brasil

| Extrator | Região / Uso | Unidade resultado |
|---|---|---|
| Resina trocadora de íons | SP, MT, MS (IAC) | mg/dm³ |
| Mehlich-1 (Carolina do Norte) | MG, PR, RS, SC, GO | mg/dm³ |
| Mehlich-3 | Uso crescente nacional | mg/dm³ |

> ⚠️ Os níveis críticos variam conforme o extrator. Não comparar valores entre extratores diferentes sem conversão.

---

## 3. Variáveis de Entrada

| Variável | Símbolo | Unidade | Descrição |
|---|---|---|---|
| Fósforo no solo | P | mg/dm³ | Resultado da análise pelo extrator |
| Argila | Arg | % | Classe textural para ajuste do NC |
| Extrator utilizado | — | — | Resina / Mehlich-1 / Mehlich-3 |
| Cultura | — | — | Soja / Milho / Feijão / Algodão |
| Produtividade esperada | Prod | sc/ha ou t/ha | Define dose de manutenção |

---

## 4. Níveis Críticos de P no Solo

### 4.1 Por Extrator Resina (IAC) — Cerrado e SP

| Classe Textural | Argila (%) | NC — P Resina (mg/dm³) |
|---|---|---|
| Arenoso | < 15 | 12 |
| Textura média | 15 a 35 | 20 |
| Argiloso | 36 a 60 | 30 |
| Muito argiloso | > 60 | 40 |

### 4.2 Por Extrator Mehlich-1 — MG, PR, Sul

| Classe Textural | Argila (%) | NC — P Mehlich-1 (mg/dm³) |
|---|---|---|
| Arenoso | < 15 | 8 |
| Textura média | 15 a 35 | 12 |
| Argiloso | 36 a 60 | 18 |
| Muito argiloso | > 60 | 25 |

### 4.3 Classes de Interpretação (geral)

| Classe | Produção relativa esperada |
|---|---|
| Muito Baixo | 0 a 40% |
| Baixo | 40 a 70% |
| Médio / Adequado | 71 a 90% |
| Bom | > 90% |
| Alto / Muito Alto | Sem resposta esperada à adubação |

---

## 5. Lógica de Recomendação

### 5.1 Adubação de Correção (P abaixo do NC)

Objetivo: elevar o teor de P do solo ao nível crítico.

```
Dose_corretiva (kg P₂O₅/ha) = (NC − P_atual) × Fator_solo
```

Fator_solo por classe textural (referência IAC):

| Textura | Fator_solo |
|---|---|
| Arenoso | 2,0 |
| Médio | 3,0 |
| Argiloso | 4,0 |
| Muito argiloso | 5,0 |

> O fator_solo reflete a capacidade de fixação — solos mais argilosos precisam de mais P para elevar o teor.

### 5.2 Adubação de Manutenção (P no nível ou acima)

Objetivo: repor o P exportado pela cultura.

```
Dose_manutenção (kg P₂O₅/ha) = Exportação_cultura × Fator_eficiência
```

Exportação de P₂O₅ por cultura (referência):

| Cultura | Produtividade | Exportação P₂O₅ |
|---|---|---|
| Soja | 60 sc/ha (3,6 t) | ~70 kg P₂O₅/ha |
| Milho | 150 sc/ha (9,0 t) | ~60 kg P₂O₅/ha |
| Feijão | 40 sc/ha (2,4 t) | ~30 kg P₂O₅/ha |
| Algodão | 250 @/ha (pluma) | ~60 kg P₂O₅/ha |

### 5.3 Adubação no Sulco — Referência Fancelli

```
45 a 80 kg/ha de P₂O₅ no sulco → efeito de escape de nematoides
```

> Estratégia de concentração de P no sulco reduz ataque de nematoides por "fuga" do sistema radicular.

---

## 6. Conversões de Unidade — Fósforo

| De | Para | Fator |
|---|---|---|
| P₂O₅ | P | × 0,437 |
| P | P₂O₅ | × 2,291 |
| mg/dm³ | kg/ha (0–20 cm) | × 2,0 (aproximado) |

---

## 7. Fatores que Reduzem Disponibilidade de P

| Fator | Efeito |
|---|---|
| Al³⁺ > 0,5 cmolc/dm³ | Fixação intensa de P — corrigir calagem antes |
| Excesso de Ca (calcário mal incorporado) | Imobilização P–Ca |
| pH < 5,0 | Alta fixação por óxidos de Fe e Al |
| pH > 7,0 | Precipitação como Ca₃(PO₄)₂ |
| Alto teor de Zn no sulco | Antagonismo P–Zn — reduzir co-aplicação |
| Baixa temperatura do solo | Difusão reduzida |

---

## 8. Ca Mínimo para Aproveitamento do P

```
Ca ≥ 2,4 cmolc/dm³  (nível ideal)
Ca ≥ 0,8 cmolc/dm³  (mínimo absoluto)
```

Abaixo de 0,8 cmolc/dm³ de Ca → aproveitamento de P comprometido mesmo com dose adequada.

---

## 9. Fontes e Referências

| Referência | Uso no Motor |
|---|---|
| Fancelli (2020) | Conceito, sulco, nematoides, Ca mínimo |
| IAC (2016) / Raij et al. | NC por extrator resina, fator_solo |
| EMBRAPA Cerrado | NC Mehlich-1, exportação por cultura |
| UFLA / 5ª Aproximação MG | Tabelas Mehlich-1 para MG |

---

*Documento: 03_fosforo.md · SoloForte v1 · Março 2026*
