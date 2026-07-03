#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "[GATE E] Quality gate started"

echo "[GATE E] 1/9 - Architecture boundaries (domain imports)"
DOMAIN_VIOLATIONS="$(rg -n "import 'package:soloforte/features/.*/presentation|import 'package:soloforte/features/.*/application|import 'package:soloforte/presentation" -S lib/domain lib/features/*/domain || true)"
if [[ -n "$DOMAIN_VIOLATIONS" ]]; then
  echo "[GATE E][FAIL] Domain boundary violations found:"
  echo "$DOMAIN_VIOLATIONS"
  exit 1
fi
echo "[GATE E] Domain boundaries OK"

echo "[GATE E] 2/9 - Cross-feature presentation imports"
python3 - <<'PY'
from pathlib import Path
import re
import sys

root = Path("lib/features")
issues = []
for f in root.rglob("presentation/**/*.dart"):
    txt = f.read_text(encoding="utf-8", errors="ignore")
    me = f.parts[2] if len(f.parts) > 2 else None
    for i, line in enumerate(txt.splitlines(), 1):
        m = re.search(r"import 'package:soloforte/features/([^/]+)/presentation/", line)
        if m and m.group(1) != me:
            issues.append((str(f), i, line.strip()))

if issues:
    print("[GATE E][FAIL] Cross-feature presentation violations:")
    for file, line, content in issues:
        print(f"  - {file}:{line}: {content}")
    sys.exit(1)

print("[GATE E] Cross-feature presentation OK")
PY

echo "[GATE E] 3/9 - Runtime mock policy guards"
SEED_IDENTITY_VIOLATIONS="$(rg -n "raudyneyb@gmail.com|_seedAccount\\(|auto-seed" -g '*.dart' lib/features/analise/presentation/providers/analise_provider.dart lib/data/datasources/remote/auth_datasource.dart || true)"
if [[ -n "$SEED_IDENTITY_VIOLATIONS" ]]; then
  echo "[GATE E][FAIL] Seed/runtime identity-specific logic found:"
  echo "$SEED_IDENTITY_VIOLATIONS"
  exit 1
fi

DEBUG_MOCK_VIOLATIONS="$(rg -n "FORCE_FIRESTORE_IN_DEBUG|useFirestore => .*kDebugMode|kDebugMode.*useFirestore" lib/core/config/app_config.dart || true)"
if [[ -n "$DEBUG_MOCK_VIOLATIONS" ]]; then
  echo "[GATE E][FAIL] Implicit mock selection by debug mode found:"
  echo "$DEBUG_MOCK_VIOLATIONS"
  exit 1
fi

RUNTIME_ASSET_VIOLATIONS="$(rg -n "ref\\.read\\(analiseLocalDatasourceProvider\\)|localDataSource\\.getAnalises\\(|assets/lab_data" -g '*.dart' lib/features/analise/presentation/providers/analise_provider.dart lib/data/datasources/remote/auth_datasource.dart || true)"
if [[ -n "$RUNTIME_ASSET_VIOLATIONS" ]]; then
  echo "[GATE E][FAIL] Runtime flow references local seed assets/mock loading:"
  echo "$RUNTIME_ASSET_VIOLATIONS"
  exit 1
fi

BAK_VIOLATIONS="$(rg --files lib/features/analise/presentation/providers | rg '\.bak$' || true)"
if [[ -n "$BAK_VIOLATIONS" ]]; then
  echo "[GATE E][FAIL] Arquivos residuais .bak encontrados em caminho crítico:"
  echo "$BAK_VIOLATIONS"
  exit 1
fi
echo "[GATE E] Runtime mock policy OK"

echo "[GATE E] 4/9 - Static analysis"
flutter analyze

echo "[GATE E] 5/9 - Critical tests with coverage"
flutter test --coverage --reporter compact \
  test/core/config/app_config_test.dart \
  test/core/router/app_router_test.dart \
  test/main_test.dart \
  test/presentation/login_controller_test.dart \
  test/data/datasources/remote/auth_datasource_test.dart \
  test/features/laboratorio/data/laudo_repository_impl_test.dart \
  test/features/laboratorio/presentation/laudo_notifier_test.dart \
  test/features/laboratorio/presentation/recomendacao/recomendacao_screen_test.dart \
  test/features/historico/presentation/historico_page_test.dart \
  test/domain/usecases/recomendacao_engine_test.dart

echo "[GATE E] 6/9 - Analise widget and persistence tests"
flutter test --reporter compact \
  test/features/analise/domain/validation/analise_data_contract_test.dart \
  test/features/analise/application/providers/analise_telemetry_provider_test.dart \
  test/features/analise/presentation/providers/analise_provider_policy_test.dart \
  test/features/analise/presentation/controllers/nova_analise_controller_test.dart \
  test/features/analise/presentation/widgets/analise_table_widget_test.dart \
  test/features/analise/data/datasources/analise_local_datasource_batch_test.dart

echo "[GATE E] 7/9 - Golden and integration tests"
flutter test --reporter compact test/features/analise/integration/nova_analise_flow_test.dart

if [[ "${QUALITY_RUN_FULL_TESTS:-false}" == "true" ]]; then
  echo "[GATE E] Optional full suite enabled (QUALITY_RUN_FULL_TESTS=true)"
  flutter test --reporter compact
fi

echo "[GATE E] 8/9 - Coverage thresholds"
python3 tool/coverage_gate.py coverage/lcov.info

echo "[GATE E] 9/9 - Observability gate"
./tool/observability_gate.sh

echo "[GATE E] Quality gate PASSED"
