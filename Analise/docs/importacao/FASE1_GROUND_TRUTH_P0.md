# Fase 1 (P0) - Ground Truth Real e Aceite Oficial

## Meta oficial (obrigatória)
- Total mínimo: 20 PDFs reais.
- Distribuição mínima: 5 PDFs por laboratório (`sellar`, `exata_brasil`, `ibra`, `mb`).
- Taxa global de sucesso: >= 95%.
- Taxa mínima por laboratório: >= 90%.
- Sem perda de amostras: `amostras_obtidas >= amostras_esperadas`.

## Meta recomendada (margem)
- Total recomendado: 24 PDFs (6 por laboratório).

## Fonte única da verdade
- Arquivo: `docs/importacao/ground_truth_lote_local.csv`
- Diretório dos PDFs: `Analise de solo `

## Colunas obrigatórias do CSV
- `arquivo_pdf`
- `lab_esperado`
- `amostras_esperadas`
- `status_validacao_manual` (`validado` obrigatório para 100% das linhas)
- `perfil_qualidade` (`bom`, `medio`, `ruim`)

## Regra de qualidade do lote
- O CSV precisa conter pelo menos 1 PDF em cada perfil:
  - `bom`
  - `medio`
  - `ruim`

## Gate de release
- Script obrigatório: `./tool/release_gate.sh`
- O release gate executa:
  1. `./tool/quality_gate.sh`
  2. `test/data/lab_templates/pdf_import_ground_truth_local_test.dart`
  3. sanidade do detector/pipeline local

Se qualquer validação falhar, o release é bloqueado.
