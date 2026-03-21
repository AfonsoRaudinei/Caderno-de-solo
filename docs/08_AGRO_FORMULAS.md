# 08 — Fórmulas agronômicas (calcário, gesso, fósforo, potássio)

> **Status:** ✅ motor de cálculo implementado em `domain/formulas` e coberto por testes em `test/domain/formulas`.

## Calcário (`calcario_formula.dart`)

| Método | Base técnica | Execução | Observações |
| --- | --- | --- | --- |
| `metodoSMP` | SMP (índice quimiométrico) | Retorna toneladas/ha ajustadas pelo PRNT. | `NC = nc × 100 / prnt` (tabela simplificada por faixas). |
| `metodoV` | Saturação por bases (V%) | `((vDesejado - vAtual) × ctc) / prnt`. | Método padrão atual no `CalcularRecomendacaoUseCase` (meta 70%). |
| `metodoIAC` | Índice de saturação de Ca + Mg (IAC) | `(caDesejado - caAtual) × 100 / prnt`. | Complementar para foco em Ca/Mg. |

## Gesso (`gesso_engine.dart`)

- Diagnóstico: `Ca_sub < 0,5`, `Al_sub > 0,5`, `m% > 25`.
- Métodos: `metodo1Argila`, `metodo2Textura`, `metodo3VSubCTC`, `metodo4CTCeCa`.
- Casos especiais: `soloSodico`, `excessoPotassio`.
- `ResultadoGesso` retorna dose, aporte de S/Ca e observações.

## Fósforo (`fosforo_formula.dart`)

- `nivelCriticoMehlich1(argila)`:
  - 15 mg/dm³ (arenoso)
  - 8 mg/dm³ (médio)
  - 4 mg/dm³ (argiloso)
- `recomendacao(fosforoData, pCritico)` retorna `(pCritico - pAtual) × 10` kg/ha de P₂O₅.
- Se `pAtual >= pCritico`, retorna `0`.

### FosforoData — modelo de entrada (v2)

```dart
FosforoData {
  double? pResina,
  double? pMehlich,
  double? pRemanescente,
  FonteP fontePrincipal, // resina | mehlich
}
```

`FosforoData.valorParaCalculo` resolve o valor de P conforme `fontePrincipal`, com fallback para a outra fonte quando necessário.

**Compatibilidade entre labs (entrada de P):**

- Exata Brasil: P Mehlich + P Resina + P Remanescente
- Sellar/Embrapa: P Mehlich + P Resina
- MB Agronegócios: P Mehlich
- IBRA: P Resina + P Remanescente

## Potássio (`potassio_formula.dart`)

- `participacaoAtual(kAtual, ctc)` calcula participação (%) de K na CTC.
- `recomendacao(ctc, kAtual, participacaoDesejada)` usa déficit para dose de K₂O.
- Conversão: `deficitK × 941`.

## Conversões (`conversoes.dart`)

| Conversão | Valor |
| --- | --- |
| `pToP2O5` / `p2O5ToP` | 2.291 / 0.437 |
| `kMgDm3Factor` | 391 |
| `kToK2O` / `k2OToK` | 1.205 / 0.830 |
| `caToCaO` / `caOToCa` | 1.399 / 0.715 |
| `mgToMgO` / `mgOToMg` | 1.658 / 0.602 |
| `sToSO3` / `sToSO4` | 2.5 / 2.996 |
| `mgDm3ToKgHa` | 2.0 |
| `kgHaToTHa` / `tHaToKgHa` | conversão kg/t |
| `gessoEquivalenteGrama` | 86 |
