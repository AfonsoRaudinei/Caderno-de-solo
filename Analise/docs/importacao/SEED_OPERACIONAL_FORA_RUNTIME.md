# Seed Operacional (Fora do Runtime)

## Política P0
- O app não executa auto-seed na abertura, login, importação ou salvamento.
- Seed de dados de demonstração é processo administrativo explícito.

## Ferramenta
- Script: `tool/export_lab_data_seed.dart`
- Comando:
  - `dart run tool/export_lab_data_seed.dart --confirm`
  - opcional: `--out build/seed/analises_seed_bundle.jsonl`

## Saída
- Arquivo JSONL com todos os JSONs de `assets/lab_data`.
- Cada linha inclui:
  - `sourceFile`
  - `exportedAtUtc`
  - `payload`

## Uso esperado
1. Exportar bundle com o script.
2. Realizar import administrativo no backend (processo controlado/auditável).
3. Registrar operação (responsável, data, ambiente, lote).
