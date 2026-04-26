# Evidência de Aceite — Fase 1 (P0)

Data: 2026-04-06
Escopo: fechamento do critério oficial de importação robusta (ground truth local)

## Base de verdade (ground truth)

Arquivo: `docs/importacao/ground_truth_lote_local.csv`

Validação estrutural concluída:
- Total de PDFs no lote: 24
- Distribuição por laboratório:
  - sellar: 6
  - exata_brasil: 6
  - ibra: 6
  - mb: 6
- Colunas obrigatórias presentes:
  - `arquivo_pdf`
  - `lab_esperado`
  - `amostras_esperadas`
  - `status_validacao_manual`
  - `perfil_qualidade`
- `status_validacao_manual=validado`: 24/24
- Existência física de arquivo PDF para todas as linhas: 24/24

## Execução do teste oficial de aceite

Comando:

```bash
flutter test test/data/lab_templates/pdf_import_ground_truth_local_test.dart --reporter expanded
```

Resultado: **PASS**

Relatório emitido pelo teste:

```text
=== Ground Truth Import Report ===
Total esperado no lote: 24
Meta: total >= 20 | por lab >= 5 | global >= 95% | por lab >= 90%
[lab=sellar] attempted=6 ok=6 failed=0 successRate=100.00%
[lab=exata_brasil] attempted=6 ok=6 failed=0 successRate=100.00%
[lab=ibra] attempted=6 ok=6 failed=0 successRate=100.00%
[lab=mb] attempted=6 ok=6 failed=0 successRate=100.00%
[global] attempted=24 ok=24 failed=0 successRate=100.00%
```

## Lista de falhas (arquivo + motivo)

- Nenhuma falha registrada.

## Gate de release

Comando:

```bash
./tool/release_gate.sh
```

Resultado: **PASS**
- Inclui validação da etapa `Ground truth acceptance (Fase 1 P0)` com sucesso.

## Observação operacional

Para fechar a distribuição mínima por laboratório no lote local, foram adicionadas cópias de PDFs reais já validados no diretório `Analise de solo `, com novos nomes de arquivo (`sellar_gt_*`, `ibra_gt_*`, `mb_gt_*`).
