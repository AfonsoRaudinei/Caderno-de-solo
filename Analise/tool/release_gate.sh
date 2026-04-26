#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

is_true() {
  case "${1:-}" in
    1|true|TRUE|True|yes|YES|on|ON) return 0 ;;
    *) return 1 ;;
  esac
}

decoded_mock_define="$(python3 - <<'PY'
import base64
import os

raw = os.getenv('DART_DEFINES', '')
for token in [t.strip() for t in raw.split(',') if t.strip()]:
    decoded = token
    try:
        decoded = base64.b64decode(token + '=' * (-len(token) % 4)).decode('utf-8', errors='ignore')
    except Exception:
        pass
    if decoded.startswith('ANALISE_MOCK_MODE='):
        print(decoded)
PY
)"

echo "[GATE R] Release gate started"
echo "[GATE R] 1/5 - Mock-off policy for production/release"
if is_true "${ANALISE_MOCK_MODE:-}"; then
  echo "[GATE R][FAIL] ANALISE_MOCK_MODE=true detectado no ambiente de release."
  exit 1
fi
if [[ "${DART_DEFINES:-}" == *"ANALISE_MOCK_MODE=true"* ]]; then
  echo "[GATE R][FAIL] DART_DEFINES contém ANALISE_MOCK_MODE=true."
  exit 1
fi
if [[ "${decoded_mock_define}" == "ANALISE_MOCK_MODE=true" ]]; then
  echo "[GATE R][FAIL] DART_DEFINES (base64) contém ANALISE_MOCK_MODE=true."
  exit 1
fi
if is_true "${REQUIRE_ANALISE_TELEMETRY_ENDPOINT:-}"; then
  if [[ -z "${ANALISE_TELEMETRY_ENDPOINT:-}" ]]; then
    echo "[GATE R][FAIL] REQUIRE_ANALISE_TELEMETRY_ENDPOINT=true, mas ANALISE_TELEMETRY_ENDPOINT não foi informado."
    exit 1
  fi
fi
echo "[GATE R] Mock-off policy OK"

echo "[GATE R] 2/5 - Base quality gate"
./tool/quality_gate.sh

echo "[GATE R] 3/5 - Ground truth acceptance (Fase 1 P0)"
flutter test --reporter compact test/data/lab_templates/pdf_import_ground_truth_local_test.dart

echo "[GATE R] 4/5 - Detector/pipeline sanity"
flutter test --reporter compact \
  test/data/lab_templates/lab_detector_test.dart \
  test/data/lab_templates/pdf_import_pipeline_local_test.dart

echo "[GATE R] 5/5 - Observability readiness (P1)"
OBSERVABILITY_SKIP_TESTS=true ./tool/observability_gate.sh

echo "[GATE R] Release gate PASSED"
