# Relatório — Nutrientes e Itens Cobertos pela Recomendação

Gerado em: 2026-05-29

Este relatório consolida **todos os nutrientes/parâmetros** que aparecem na camada de **recomendação** (cálculo, diagnóstico, UI e modelos).

---

## 1) Nutrientes base disponíveis na análise (entrada)

### 1.1) Entrada principal usada na engine

Fonte: `Analise/lib/domain/entities/analise_entity.dart`

Campos (nutrientes e atributos relacionados):
- pH: `ph`
- Matéria orgânica: `mo`
- Macronutrientes/complexo sortivo: `p`, `k`, `ca`, `mg`, `hAl`, `al`, `sb`, `ctc`, `vPercent`
- Enxofre: `s` (e opcional `s2040`)
- Micronutrientes: `b`, `cu`, `fe`, `mn`, `zn`
- Textura: `argila` (e opcionais `silte`, `areiaTotal`)
- Fósforo por extrator (opcional): `pMehlich`, `pResina`, `pRem`

### 1.2) Entrada “completa” (quando disponível)

Fonte: `Analise/lib/domain/entities/analise_completa.dart`

Inclui (além de pH/P/K/Ca/Mg/Al/H+Al etc.):
- S por camada: `s020`, `s2040`
- Sódio: `na`
- Micronutrientes adicionais: `ni`, `mo`, `se`, `co`
- Metadados de unidades originais (para rastreio de importação)

---

## 2) Nutrientes/itens calculados na recomendação (saída)

### 2.1) Saída “persistida” (histórico/Firestore)

Fonte: `Analise/lib/domain/models/recomendacao_model.dart`

Campos:
- Calcário: `necessidadeCalagem`, `doseCalcario`, `prnt`
- Fósforo: `p2o5`
- Potássio: `k2o`

Observação:
- Existem campos de “citação” por tema: `citacaoCalagem`, `citacaoGesso`, `citacaoFosforo`, `citacaoPotassio`, `citacaoEnxofre`, `citacaoMicronutrientes`.

### 2.2) Saída “completa” (engine)

Fonte: `Analise/lib/domain/usecases/recomendacao_engine.dart`

Blocos principais (com nutrientes/parâmetros envolvidos):

- Calcário (Calagem)
  - Dose: `doseCalcarioTHa`
  - Metas/derivações: `vEsperado`, `caEsperado`, `mgEsperado`, `relacaoCaMg`
  - Base de cálculo usa (da análise): `ctc`, `vPercent`, `ca`, `mg`, `hAl`, `al` (dependendo do método)

- Gesso (Gessagem)
  - Resultado: `gesso` (`ResultadoGesso`)
  - Envolve (da análise): argila (%), estimativas para subsolo (Ca/Al/m%) e relações com **Ca** e **S** fornecidos pelo produto

- Fósforo
  - `modoFosforo`, `ncFosforo`, `doseP2O5KgHa`
  - Envolve (da análise): `p` (e/ou `pMehlich`/`pResina`), textura (`argila`), e regras de “legacy P”

- Potássio
  - `criterioPotassio`, `ncPotassio`, `doseK2OKgHa`, `relacoesK`
  - Envolve (da análise): `k`, `ctc`, `mg`, `ca` e relações/antagonismos (K:Mg, K:Ca, %K na CTC)

- Micronutrientes (solo/foliar/grupo)
  - Estruturas: `MicroResultado` e `GrupoResultado`
  - Elementos contemplados (enum/engine): **B, Cu, Fe, Mn, Zn** (com nível crítico) e também **Mo, Co, Ni, Se** (sem NC na tabela interna)

- Diagnóstico e avisos
  - Listas: `avisos` e diagnóstico por nutriente (status OK/ausente/inválido)

---

## 3) Fórmulas/motores por nutriente (onde a regra está)

Calcário (calagem):
- `Analise/lib/domain/formulas/calcario_formula.dart`
- `Analise/lib/domain/formulas/calagem_engine.dart`

Gesso:
- `Analise/lib/domain/formulas/gesso_engine.dart`

Fósforo (P2O5):
- `Analise/lib/domain/formulas/fosforo_formula.dart`

Potássio (K2O):
- `Analise/lib/domain/formulas/potassio_formula.dart`

Enxofre (S):
- `Analise/lib/domain/formulas/enxofre_formula.dart`

Micronutrientes:
- `Analise/lib/domain/formulas/micronutrientes_engine.dart`

---

## 4) Itens exibidos como “qualidade do solo” (UI)

Fonte: `Analise/lib/features/laboratorio/presentation/recomendacao/widgets/qualidade_solo_section.dart`

Além de textura (Areia/Silte/Argila) e M.O.:
- Carbono estimado (C): `carbono = mo / 1.724`
- N estimado: `nitrogenio = mo * 1.0` (exibição como “N estimado (Fancelli)”)

