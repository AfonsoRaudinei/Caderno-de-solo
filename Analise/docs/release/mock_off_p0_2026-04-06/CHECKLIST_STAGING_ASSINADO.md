# Checklist de Rollout P0 — Mock-Off Runtime (Assinado)

Data: 2026-04-06
Janela alvo solicitada: 08/04/2026 a 09/04/2026
Status: CONCLUÍDO (evidência técnica automatizada)

## 1) Smoke operacional (importar, salvar lote, listar, reabrir)

- [x] Importar (pipeline real)
  - Evidência: `docs/release/mock_off_p0_2026-04-06/logs/02_import_pipeline.log`
- [x] Salvar lote + idempotência + compensação/recovery
  - Evidência: `docs/release/mock_off_p0_2026-04-06/logs/03_nova_analise_flow.log`
- [x] Listar/Reabrir análise (contexto de histórico)
  - Evidência: `docs/release/mock_off_p0_2026-04-06/logs/04_historico.log`
- [x] Gate completo sem bypass
  - Evidência: `docs/release/mock_off_p0_2026-04-06/logs/05_release_gate.log`

Resumo da execução:
- `docs/release/mock_off_p0_2026-04-06/smoke_summary.log`

## 2) Confirmar 0 auto-seed e 0 mock sem flag explícita

- [x] Provider usa Firestore no caminho padrão e mock só com flag explícita.
- [x] Ausência de branch por e-mail/autoseed no runtime de análise/auth.
- [x] Sem carregamento automático de assets de seed no fluxo padrão.

Referências de código:
- `lib/core/config/app_config.dart`
- `lib/features/analise/presentation/providers/analise_provider.dart`
- `lib/data/datasources/remote/auth_datasource.dart`
- `tool/quality_gate.sh`

## 3) Endurecer política de release (bloquear ANALISE_MOCK_MODE=true)

- [x] `tool/release_gate.sh` agora falha imediatamente se `ANALISE_MOCK_MODE=true`.
- [x] Bloqueio também para `DART_DEFINES` (raw e base64).
- [x] Build iOS local força `--dart-define=ANALISE_MOCK_MODE=false`.
- [x] Pipeline Codemagic bloqueia `ANALISE_MOCK_MODE=true` e builda com define explícito false.

Teste de bloqueio (negativo):
- Comando: `ANALISE_MOCK_MODE=true ./tool/release_gate.sh`
- Resultado esperado: FAIL imediato
- Evidência: `docs/release/mock_off_p0_2026-04-06/logs/06_release_gate_mock_true_block.log`

## 4) Remover resíduos técnicos de auditoria

- [x] Removido arquivo residual:
  - `lib/features/analise/presentation/providers/analise_provider.dart.bak`
- [x] Gate de qualidade passou a falhar se houver `.bak` em caminho crítico.

## 5) Comandos executados

```bash
flutter test test/features/analise/presentation/providers/analise_provider_policy_test.dart --reporter compact
flutter test test/data/lab_templates/pdf_import_pipeline_local_test.dart --reporter compact
flutter test test/features/analise/integration/nova_analise_flow_test.dart --reporter compact
flutter test test/features/historico/presentation/historico_page_test.dart --reporter compact
./tool/release_gate.sh
ANALISE_MOCK_MODE=true ./tool/release_gate.sh
```

## Assinaturas

Assinatura técnica (automação):
- Nome: Codex
- Papel: Auditor técnico Flutter/Dart
- Data/hora (UTC): 2026-04-06T18:33:00Z
- Resultado: APROVADO

Assinatura de operação (staging owner):
- Nome: __________________________
- Data: ____/____/________
- Resultado: ______________________
