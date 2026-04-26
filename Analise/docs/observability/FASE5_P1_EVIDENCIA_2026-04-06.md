# Evidência de Execução — Fase 5 (P1)

Data: 2026-04-06  
Escopo: sair de spec local para operação real rastreável da Nova Análise.

## Entregas aplicadas no código

- Telemetria com sink remoto HTTP configurável:
  - `ANALISE_TELEMETRY_ENDPOINT`
  - `ANALISE_TELEMETRY_API_KEY` (opcional)
  - `ENABLE_ANALISE_TELEMETRY_IN_DEBUG` (diagnóstico controlado)
- Fallback local com `DebugPrint` preservado para ambiente de desenvolvimento.
- Provider de telemetria seleciona sink remoto somente em profile/release (ou debug explícito).

Arquivos:
- `lib/core/config/app_config.dart`
- `lib/features/analise/application/observability/analise_telemetry.dart`
- `lib/features/analise/application/providers/analise_telemetry_provider.dart`

## Entregas operacionais versionadas

- Decisão de stack + owners:
  - `docs/observability/STACK_OPERACIONAL_D0.md`
- Infra de métricas/alertas:
  - `infra/observability/bigquery/kpi_5min.sql`
  - `infra/observability/cloud_monitoring/alert_policies.yaml`
- Runbook:
  - `docs/observability/runbook/RUNBOOK_ALERTAS_P1.md`
- Pacote de evidências de produção:
  - `docs/observability/evidencias/producao_p1_2026-04-13/PACOTE_EVIDENCIAS.md`
  - `docs/observability/evidencias/producao_p1_2026-04-13/FIRE_DRILL_RELATORIO.md`

## Gate e CI

- Gate dedicado criado:
  - `tool/observability_gate.sh`
- Integração:
  - `tool/quality_gate.sh` (execução obrigatória)
  - `tool/release_gate.sh` (readiness de observabilidade)
- Build iOS/Codemagic preparados para receber endpoint/API key:
  - `build_ios.sh`
  - `codemagic.yaml`

## Situação de aceite operacional P1

- `dashboard_minimo_spec.yaml`: definido e versionado.
- Instrumentação de eventos `import_*` e `save_*`: ativa no app.
- Pipeline para produção: habilitado no app via endpoint configurável.
- Publicação efetiva de dashboard/alerta em produção: **depende de credenciais e execução no ambiente cloud**.

Sem a publicação no ambiente cloud e preenchimento do pacote de evidências reais, o aceite operacional P1 permanece pendente.
