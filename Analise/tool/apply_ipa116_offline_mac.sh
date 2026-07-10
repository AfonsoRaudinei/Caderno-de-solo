#!/usr/bin/env bash
# Aplica export HTML + scripts IPA 116 via patches locais (sem GitHub).
# Uso (na raiz do repo "Caderno de Solo"):
#   ./Analise/tool/apply_ipa116_offline_mac.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PATCH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/patches-ipa116"

cd "$ROOT"

if [[ ! -d "$PATCH_DIR" ]] || [[ -z "$(ls -A "$PATCH_DIR"/*.patch 2>/dev/null)" ]]; then
  echo "❌ Patches não encontrados em: $PATCH_DIR"
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "⚠️  Worktree suja — criando stash antes dos patches..."
  git stash push -u -m "wip antes apply_ipa116_offline $(date +%Y%m%d-%H%M%S)"
fi

if [[ -f .git/MERGE_HEAD ]]; then
  echo "⚠️  Abortando merge pendente..."
  git merge --abort || git reset --merge
fi

echo "📦 Aplicando patches locais..."
git am "$PATCH_DIR"/*.patch

chmod +x Analise/tool/audit_merge_and_export_readonly.sh \
         Analise/tool/release_ipa_116_mac.sh 2>/dev/null || true

echo "✅ Patches aplicados. HEAD: $(git rev-parse --short HEAD)"
echo "Próximo:"
echo "  cd Analise && ./tool/audit_merge_and_export_readonly.sh"
