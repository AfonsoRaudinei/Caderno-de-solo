#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "[GATE O] Observability gate started"

echo "[GATE O] 1/5 - Contrato de telemetria e sink remoto"
rg -n "telemetryVersion|operationId|sessionId|appVersion|platform|environment" \
  lib/features/analise/application/observability/analise_telemetry.dart >/dev/null
rg -n "HttpAnaliseTelemetrySink|ANALISE_TELEMETRY_ENDPOINT|analiseTelemetryEndpoint" \
  lib/features/analise/application/providers/analise_telemetry_provider.dart \
  lib/core/config/app_config.dart >/dev/null
echo "[GATE O] Contrato e sink remoto OK"

echo "[GATE O] 2/5 - Artefatos operacionais versionados"
required_files=(
  "docs/observability/dashboard_minimo_spec.yaml"
  "docs/observability/FASE5_OPERACAO_OBSERVABILIDADE.md"
  "docs/observability/STACK_OPERACIONAL_D0.md"
  "docs/observability/runbook/RUNBOOK_ALERTAS_P1.md"
  "infra/observability/README.md"
  "infra/observability/bigquery/kpi_5min.sql"
  "infra/observability/cloud_monitoring/alert_policies.yaml"
  "docs/observability/evidencias/producao_p1_2026-04-13/PACOTE_EVIDENCIAS.md"
  "docs/observability/evidencias/producao_p1_2026-04-13/FIRE_DRILL_RELATORIO.md"
)
for file in "${required_files[@]}"; do
  [[ -f "$file" ]] || { echo "[GATE O][FAIL] Arquivo ausente: $file"; exit 1; }
done
echo "[GATE O] Artefatos versionados OK"

echo "[GATE O] 3/5 - Testes críticos de observabilidade"
if [[ "${OBSERVABILITY_SKIP_TESTS:-false}" == "true" ]]; then
  echo "[GATE O] Testes pulados por OBSERVABILITY_SKIP_TESTS=true"
else
  flutter test --reporter compact \
    test/core/config/app_config_test.dart \
    test/features/analise/application/observability/analise_telemetry_test.dart \
    test/features/analise/application/providers/analise_telemetry_provider_test.dart \
    test/data/lab_templates/pdf_import_service_telemetry_test.dart
fi
echo "[GATE O] Testes de observabilidade OK"

echo "[GATE O] 4/5 - Evidência de produção (modo estrito opcional)"
if [[ "${OBSERVABILITY_REQUIRE_PRODUCTION_EVIDENCE:-false}" == "true" ]]; then
  if rg -n "PENDENTE_" docs/observability/evidencias/producao_p1_2026-04-13/PACOTE_EVIDENCIAS.md >/dev/null; then
    echo "[GATE O][FAIL] Evidência de produção incompleta (placeholders pendentes)."
    exit 1
  fi
fi
echo "[GATE O] Evidência validada (modo atual)"

echo "[GATE O] 5/5 - Sanidade de rastreabilidade"
rg -n "operationId|batchId|idempotencyKeyHash|errorCode|durationMs" \
  docs/observability/FASE5_OPERACAO_OBSERVABILIDADE.md \
  infra/observability/bigquery/kpi_5min.sql >/dev/null
echo "[GATE O] Rastreabilidade OK"

echo "[GATE O] Observability gate PASSED"
