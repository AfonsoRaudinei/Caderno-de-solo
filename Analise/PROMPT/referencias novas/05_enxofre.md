# 05 — Enxofre (S): Motor de Cálculo
**SoloForte · Referências Técnicas**
Fontes: Fancelli (2020), EMBRAPA/Sousa & Lobato, IAC (2016), UFLA/Lopes et al.

---

## 1. Conceito e Comportamento no Solo

O enxofre é absorvido pelas plantas principalmente na forma de **sulfato (SO₄²⁻)** — ânion móvel no solo, sujeito à lixiviação em solos arenosos e de baixa MO.

**Funções principais:**
- Componente de aminoácidos sulfurados (cisteína, metionina)
- Síntese de proteínas e clorofila
- Ativação de enzimas
- Formação de glucosinolatos (defesa da planta)
- Componente estrutural da ferredoxina (fotossíntese)

**Relação com o Gesso:**
O gesso agrícola (CaSO₄·2H₂O) é a principal fonte de S no Cerrado — fornece ~15% de S por tonelada aplicada. Quando o diagnóstico de gessagem é positivo, o S normalmente já é suprido pela dose de gesso recomendada.

> ⚠️ Verificar sempre: se gesso já foi recomendado → calcular S fornecido pelo gesso antes de recomendar fonte adicional de S.

---

## 2. Extrator e Unidade

| Parâmetro | Detalhe |
|---|---|
| Extrator padrão | Fosfato de cálcio monobásico (Ca(H₂PO₄)₂) |
| Unidade do resultado | mg/dm³ |
| Camada de referência | 0–20 cm (superfície) |

---

## 3. Variáveis de Entrada

| Variável | Símbolo | Unidade | Descrição |
|---|---|---|---|
| Enxofre no solo | S | mg/dm³ | Resultado da análise |
| Matéria orgânica | MO | g/dm³ | Alta MO = reserva de S orgânico |
| Argila | Arg | % | Solos arenosos = maior lixiviação |
| Gesso aplicado | Gesso_dose | kg/ha | Se já recomendado no 02_gesso.md |
| Cultura | — | — | Soja / Milho / Feijão / Algodão |

---

## 4. Níveis Críticos de S no Solo

### 4.1 Tabela de Interpretação — Extrator Fosfato de Cálcio

| Classe | S (mg/dm³) | Interpretação |
|---|---|---|
| Muito Baixo | < 5 | Deficiência severa — correção urgente |
| Baixo | 5 a 10 | Deficiência provável — recomendar S |
| Médio | 10 a 20 | Adequado para maioria das culturas |
| Alto | > 20 | Sem necessidade de correção |

**Nível crítico de referência:** 10 mg/dm³ de S-SO₄²⁻

### 4.2 Por Cultura — Exigência Relativa

| Cultura | Exigência de S | Observação |
|---|---|---|
| Algodão | Alta | Muito sensível à deficiência — prioridade |
| Soja | Alta | Parte do S vem da MO mineralizada |
| Milho | Média | Responde bem à cobertura com S |
| Feijão | Média | Sensível em solos muito arenosos |

---

## 5. S Fornecido pelo Gesso

Antes de recomendar S adicional, calcular o S já fornecido pelo gesso:

```
S_gesso (kg/ha) = Dose_gesso (kg/ha) × 0,15

Onde:
  0,15 = teor de S no gesso agrícola (15%)
```

**Se S_gesso ≥ Necessidade_S → sem fonte adicional necessária.**

Exemplos:
- 700 kg/ha gesso → 105 kg S/ha
- 1.200 kg/ha gesso → 180 kg S/ha
- 2.200 kg/ha gesso → 330 kg S/ha

> Em praticamente todos os casos de gessagem, o S fornecido supera a demanda das culturas anuais.

---

## 6. Lógica de Recomendação

### 6.1 Fluxo de Decisão

```
1. S_solo < 10 mg/dm³?
   Não → sem necessidade de S adicional
   Sim → verificar se gesso já foi recomendado

2. Gesso recomendado?
   Sim → S_gesso = Dose_gesso × 0,15
         S_gesso ≥ 20 kg/ha → S suprido pelo gesso (ok)
         S_gesso < 20 kg/ha → recomendar complementação

3. Gesso não recomendado → recomendar fonte de S direta
```

### 6.2 Doses de Referência por Cultura

| Cultura | Dose S recomendada (kg S/ha) | Momento |
|---|---|---|
| Soja | 20 a 30 | Semeadura (sulco) ou cobertura |
| Milho | 20 a 40 | Semeadura + cobertura (V4–V6) |
| Feijão | 15 a 25 | Semeadura |
| Algodão | 30 a 50 | Semeadura + cobertura |

---

## 7. Fontes de Enxofre e Teores

| Fonte | Fórmula | Teor S (%) | Teor outro nutriente |
|---|---|---|---|
| Gesso agrícola | CaSO₄·2H₂O | 15% | 20% Ca |
| Sulfato de amônio | (NH₄)₂SO₄ | 24% | 21% N |
| Superfosfato simples | Ca(H₂PO₄)₂ | 12% | 18% P₂O₅ |
| Sulfato de potássio | K₂SO₄ | 17% | 50% K₂O |
| Sulfato de magnésio | MgSO₄ | 13% | 10% Mg |
| Enxofre elementar | S | 90–99% | — |
| Tiosulfato de amônio | (NH₄)₂S₂O₃ | 26% | 12% N |

> **Enxofre elementar:** precisa ser oxidado no solo para SO₄²⁻ antes de ser absorvido — processo lento (semanas a meses). Não usar em situação de deficiência aguda.

---

## 8. Fatores que Afetam Disponibilidade de S

| Fator | Efeito |
|---|---|
| Baixa MO | Reduz mineralização do S orgânico |
| Solo arenoso | Maior lixiviação de SO₄²⁻ |
| Alta pluviosidade | Lixiviação acelerada |
| pH muito alto (> 7,0) | Reduz mineralização |
| Baixa temperatura | Reduz atividade microbiana e mineralização |
| Alto teor de Mo no solo | Antagonismo S–Mo (alto S reduz Mo disponível) |

---

## 9. Relação S × Nitrogênio

O enxofre é essencial para a síntese de aminoácidos sulfurados que fazem parte das proteínas. A relação ideal N:S na planta é:

```
Relação N:S ideal na planta = 15:1 a 20:1
```

Deficiência de S → comprometimento da síntese proteica mesmo com N abundante.

Em soja: deficiência de S reduz a eficiência da fixação biológica de N por comprometer a síntese de leghaemoglobina (proteína dos nódulos).

---

## 10. Conversões de Unidade — Enxofre

| De | Para | Fator |
|---|---|---|
| SO₃ | S | × 0,400 |
| S | SO₃ | × 2,500 |
| SO₄ | S | × 0,334 |
| mg/dm³ | kg/ha (0–20 cm) | × 2,0 (aprox.) |

---

## 11. Fontes e Referências

| Referência | Uso no Motor |
|---|---|
| Fancelli (2020), Aula 12 | S fornecido pelo gesso, relação gesso × S |
| Fancelli (2020), Aula 5 | S × Mo antagonismo |
| EMBRAPA / Sousa & Lobato | NC 10 mg/dm³, doses por cultura |
| IAC (2016) / Raij et al. | Tabela de interpretação, extrator |
| UFLA / Lopes et al. | Fontes de S e teores |

---

*Documento: 05_enxofre.md · SoloForte v1 · Março 2026*
