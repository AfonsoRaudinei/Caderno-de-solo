#!/usr/bin/env bash
# MacBook: limpa merge pendente (com backup), valida export HTML e gera IPA build 116.
#
# Uso:
#   ./tool/audit_merge_and_export_readonly.sh   # só leitura (obrigatório antes)
#   ./tool/release_ipa_116_mac.sh               # fluxo completo
#   ./tool/release_ipa_116_mac.sh --abort-merge-only
#   ./tool/release_ipa_116_mac.sh --skip-merge   # worktree já limpa e export mergeado
#
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_ROOT="$(cd "$ROOT_DIR/.." && pwd)"
TARGET_BUILD=116
EXPORT_BRANCH="${EXPORT_BRANCH:-cursor/export-wiring-theme-6ab3}"
RELEASE_BRANCH="${RELEASE_BRANCH:-cursor/release-ipa-116-6ab3}"

MODE="full"
for arg in "$@"; do
  case "$arg" in
    --abort-merge-only) MODE="abort-only" ;;
    --skip-merge) MODE="skip-merge" ;;
    -h|--help)
      sed -n '2,12p' "$0"
      exit 0
      ;;
    *)
      echo "Argumento desconhecido: $arg"
      exit 1
      ;;
  esac
done

cd "$REPO_ROOT"

echo "== Release IPA $TARGET_BUILD =="
echo "Repo: $REPO_ROOT"
echo "Modo: $MODE"

if [[ "$MODE" != "abort-only" ]]; then
  echo
  echo "== 1/5 Auditoria read-only =="
  if ! "$ROOT_DIR/tool/audit_merge_and_export_readonly.sh"; then
    audit_code=$?
    if [[ "$audit_code" -eq 2 && -f .git/MERGE_HEAD ]]; then
      echo "Auditoria: export OK, merge pendente — continuando limpeza..."
    else
      echo "Auditoria falhou. Corrija antes do IPA."
      exit "$audit_code"
    fi
  fi
fi

echo
echo "== 2/5 Backup do trabalho local =="
STASH_NAME="wip-pre-ipa116-$(date +%Y%m%d-%H%M%S)"
if [[ -n "$(git status --porcelain)" ]]; then
  echo "Salvando stash: $STASH_NAME"
  git stash push -u -m "$STASH_NAME"
  echo "Stash criado. Recuperar depois: git stash list | rg ipa116"
else
  echo "Worktree limpa — stash não necessário."
fi

if [[ -f .git/MERGE_HEAD ]]; then
  echo
  echo "== 3/5 Abortando merge pendente =="
  git merge --abort || git reset --merge
  echo "MERGE_HEAD removido."
else
  echo
  echo "== 3/5 Sem merge pendente =="
fi

if [[ "$MODE" == "abort-only" ]]; then
  echo
  echo "Concluído (--abort-merge-only)."
  echo "Stash (se criado): git stash list"
  echo "Reaplicar trabalho: git stash pop"
  exit 0
fi

if [[ "$MODE" != "skip-merge" ]]; then
  echo
  echo "== 4/5 Trazendo export HTML + build $TARGET_BUILD =="
  git fetch origin
  if git show-ref --verify --quiet "refs/remotes/origin/$RELEASE_BRANCH"; then
    echo "Merge origin/$RELEASE_BRANCH"
    git merge "origin/$RELEASE_BRANCH" --no-edit
  elif git show-ref --verify --quiet "refs/remotes/origin/$EXPORT_BRANCH"; then
    echo "Merge origin/$EXPORT_BRANCH"
    git merge "origin/$EXPORT_BRANCH" --no-edit
  else
    echo "Branch remota não encontrada: $EXPORT_BRANCH nem $RELEASE_BRANCH"
    exit 1
  fi
else
  echo
  echo "== 4/5 Pulando merge (--skip-merge) =="
fi

cd "$ROOT_DIR"

current_build="$(grep '^version:' pubspec.yaml | sed -n 's/.*+\([0-9]*\).*/\1/p')"
if [[ "$current_build" != "$TARGET_BUILD" ]]; then
  version_name="$(grep '^version:' pubspec.yaml | sed -n 's/version:[[:space:]]*\([^+]*\)+.*/\1/p')"
  echo "Ajustando pubspec: ${version_name}+${current_build} -> ${version_name}+${TARGET_BUILD}"
  sed -i.bak "s/^version: .*/version: ${version_name}+${TARGET_BUILD}/" pubspec.yaml
  rm -f pubspec.yaml.bak
  cd "$REPO_ROOT"
  git add Analise/pubspec.yaml
  git commit -m "chore(release): bump build number to ${TARGET_BUILD} para IPA"
  cd "$ROOT_DIR"
fi

echo
echo "== 5/5 Release gate + IPA =="
chmod +x build_ios.sh
./build_ios.sh "$TARGET_BUILD"

echo
echo "✅ IPA build $TARGET_BUILD concluída."
echo "Arquivo esperado: build/ios/ipa/*.ipa"
echo
echo "Stash local (se criado): git -C \"$REPO_ROOT\" stash list"
echo "Reaplicar tema/WIP:      git -C \"$REPO_ROOT\" stash pop"
