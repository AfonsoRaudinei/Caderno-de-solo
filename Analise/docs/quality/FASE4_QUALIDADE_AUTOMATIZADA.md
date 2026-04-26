# Fase 4 (P1) - Qualidade Automatizada

## Escopo implementado

- Widget tests da tabela em colunas (`A1`, `A2`, ...).
- Golden tests da `NovaAnaliseScreen` em layout compacto.
- Integration test do fluxo completo (validar/salvar/recarregar).
- Gate de CI com bloqueio por regressão funcional/visual.

## Suites

- Widget tests:
  - `test/features/analise/presentation/widgets/analise_table_widget_test.dart`
- Golden tests:
  - `test/features/analise/presentation/screens/nova_analise_screen_golden_test.dart`
  - baselines em `test/features/analise/goldens/`
- Integration tests:
  - `test/features/analise/integration/nova_analise_flow_test.dart`

## Como atualizar goldens com segurança

1. Rode:
   - `flutter test test/features/analise/presentation/screens/nova_analise_screen_golden_test.dart --update-goldens`
2. Revise diffs visuais em `test/features/analise/goldens/`.
3. No PR:
   - explique o motivo da mudança visual;
   - confirme que o layout compacto e o modelo em colunas foram preservados.

## Gate de qualidade

- Script: `./tool/quality_gate.sh`
- CI:
  - `codemagic.yaml` (Gate E)
  - `.github/workflows/quality-gate.yml` (PR/push)

## Política de merge

- Falha em analyze/tests/golden/integration = merge bloqueado.
- Branch protection deve exigir o check `Quality Gate`.
