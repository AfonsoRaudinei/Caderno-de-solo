#!/usr/bin/env bash
# Guard anti-regressão: módulos de produto obrigatórios no Caderno de Solo.
# Falha se Clientes (ou shell mínimo) sumirem — causa raiz da regressão IPA 178/179.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "[GATE M] Product modules guard started"

fail() {
  echo "[GATE M][FAIL] $*"
  exit 1
}

require_file() {
  local path="$1"
  [[ -f "$path" ]] || fail "arquivo obrigatório ausente: $path"
}

require_dir() {
  local path="$1"
  [[ -d "$path" ]] || fail "módulo obrigatório ausente: $path"
}

# ── Features de produto invioláveis ──────────────────────────────────────────
require_dir "lib/features/clientes"
require_dir "lib/features/analise"
require_dir "lib/features/laboratorio"
require_dir "lib/features/mapa"
require_dir "lib/features/config"
require_dir "lib/features/main"
require_dir "lib/features/auth"

# ── Superfície mínima do módulo Clientes ─────────────────────────────────────
require_file "lib/features/clientes/presentation/clientes_page.dart"
require_file "lib/features/clientes/presentation/clientes_list_screen.dart"
require_file "lib/features/clientes/presentation/cliente_form_screen.dart"
require_file "lib/features/clientes/presentation/cliente_detail_screen.dart"
require_file "lib/features/clientes/presentation/fazenda_form_screen.dart"
require_file "lib/features/clientes/presentation/talhao_form_screen.dart"
require_file "lib/features/clientes/application/providers/cliente_provider.dart"
require_file "lib/features/clientes/data/datasources/cliente_firestore_datasource.dart"

# ── Rotas e shell ────────────────────────────────────────────────────────────
ROUTES="lib/core/constants/app_routes.dart"
ROUTER="lib/core/router/app_router.dart"
MAIN="lib/features/main/presentation/main_page.dart"

require_file "$ROUTES"
require_file "$ROUTER"
require_file "$MAIN"

rg -q "static const String clientes = '/clientes'" "$ROUTES" \
  || fail "AppRoutes.clientes ausente em $ROUTES"

rg -q "ClientesPage" "$ROUTER" \
  || fail "ClientesPage não registrado em $ROUTER"

rg -q "path: AppRoutes.clientes" "$ROUTER" \
  || fail "rota AppRoutes.clientes ausente no shell em $ROUTER"

rg -q "label: 'Clientes'" "$MAIN" \
  || fail "aba Clientes ausente em MainPage ($MAIN)"

# Contagem mínima de arquivos dart no módulo (evita pasta vazia)
CLIENTES_DART_COUNT="$(find lib/features/clientes -name '*.dart' | wc -l | tr -d ' ')"
if [[ "$CLIENTES_DART_COUNT" -lt 15 ]]; then
  fail "módulo clientes incompleto ($CLIENTES_DART_COUNT arquivos .dart; esperado >= 15)"
fi

# Export options obrigatório para builds IPA com build number travado
require_file "tool/export_options_app_store.plist"
rg -q "manageAppVersionAndBuildNumber" "tool/export_options_app_store.plist" \
  || fail "export_options_app_store.plist sem manageAppVersionAndBuildNumber"

echo "[GATE M] Product modules guard PASSED (clientes=$CLIENTES_DART_COUNT dart files)"
