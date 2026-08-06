#!/usr/bin/env bash
# Auditoria READ-ONLY: estado de merge + export HTML SoloForte v4.
# Não altera arquivos, não faz commit, não aborta merge.
set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_ROOT="$(cd "$ROOT_DIR/.." && pwd)"

pass=0
fail=0
warn=0

ok()   { echo "  ✅ $1"; pass=$((pass + 1)); }
bad()  { echo "  ❌ $1"; fail=$((fail + 1)); }
note() { echo "  ⚠️  $1"; warn=$((warn + 1)); }

section() {
  echo
  echo "== $1 =="
}

cd "$REPO_ROOT"

section "Git / merge"
echo "Repo: $REPO_ROOT"
echo "Branch: $(git branch --show-current 2>/dev/null || echo '?')"
echo "HEAD: $(git rev-parse --short HEAD 2>/dev/null || echo '?')"

if [[ -f .git/MERGE_HEAD ]]; then
  merge_commit="$(cat .git/MERGE_HEAD)"
  note "MERGE_HEAD presente — merge incompleto"
  echo "     MERGE_HEAD: $merge_commit ($(git log -1 --oneline "$merge_commit" 2>/dev/null || echo 'commit inacessível'))"
  if [[ -f .git/MERGE_MSG ]]; then
    echo "     MERGE_MSG:"
    sed 's/^/       /' .git/MERGE_MSG
  fi
else
  ok "Sem MERGE_HEAD (não há merge pendente)"
fi

if [[ -d .git/rebase-merge || -d .git/rebase-apply ]]; then
  note "Rebase em andamento"
fi

if [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
  changed="$(git status --porcelain | wc -l | tr -d ' ')"
  note "Worktree com $changed arquivo(s) modificado(s)/não rastreado(s)"
  echo "     (primeiros 20)"
  git status --porcelain | head -20 | sed 's/^/       /'
else
  ok "Worktree limpa"
fi

section "Arquivos export HTML (escopo v1)"
check_file() {
  local rel="$1"
  if [[ -f "$REPO_ROOT/$rel" ]]; then ok "$rel"; else bad "$rel ausente"; fi
}

check_file "Analise/assets/templates/recomendacao_soloforte_v4.html"
check_file "Analise/lib/domain/export/recomendacao_export_context.dart"
check_file "Analise/lib/domain/export/recomendacao_html_mapper.dart"
check_file "Analise/lib/domain/export/disponibilidade_nutrientes_calculator.dart"
check_file "Analise/lib/features/laboratorio/application/recomendacao_export_context_builder.dart"
check_file "Analise/lib/features/laboratorio/services/recomendacao_html_renderer.dart"
check_file "Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_html_exporter.dart"
check_file "Analise/lib/features/laboratorio/presentation/providers/recomendacao_export_provider.dart"
check_file "Analise/test/features/laboratorio/presentation/recomendacao/recomendacao_screen_export_test.dart"

if rg -q "assets/templates/" "$REPO_ROOT/Analise/pubspec.yaml" 2>/dev/null; then
  ok "pubspec.yaml registra assets/templates/"
else
  bad "pubspec.yaml não registra assets/templates/"
fi

section "Wiring da tela de recomendação"
SCREEN="$REPO_ROOT/Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart"
if [[ ! -f "$SCREEN" ]]; then
  bad "recomendacao_screen.dart ausente"
else
  if rg -q "exportRecomendacaoProvider" "$SCREEN"; then
    ok "usa exportRecomendacaoProvider"
  else
    bad "NÃO usa exportRecomendacaoProvider"
  fi

  if rg -q "Key\\('btn_exportar_pdf'\\)" "$SCREEN"; then
    ok "Key btn_exportar_pdf presente"
  else
    bad "Key btn_exportar_pdf ausente"
  fi

  if rg -q "Exportar relatorio" "$SCREEN"; then
    ok "label Exportar relatorio presente"
  else
    bad "label Exportar relatorio ausente"
  fi

  if rg -q "btn_compartilhar_recomendacao" "$SCREEN"; then
    bad "ainda referencia btn_compartilhar_recomendacao (legado)"
  else
    ok "sem btn_compartilhar_recomendacao"
  fi

  if rg -q "RecomendacaoHtmlExporter\\(\\)\\.exportar" "$SCREEN"; then
    bad "chama RecomendacaoHtmlExporter().exportar direto na tela"
  else
    ok "tela não chama RecomendacaoHtmlExporter direto"
  fi
fi

section "Versão / IPA"
if [[ -f "$ROOT_DIR/pubspec.yaml" ]]; then
  version_line="$(grep '^version:' "$ROOT_DIR/pubspec.yaml" | head -1)"
  echo "  $version_line"
  build_num="$(echo "$version_line" | sed -n 's/.*+\([0-9][0-9]*\).*/\1/p')"
  if [[ "$build_num" == "116" ]]; then
    ok "build number já é 116"
  else
    note "build number atual: ${build_num:-?} (IPA alvo: 116)"
  fi
fi

section "Flutter (se disponível)"
if command -v flutter >/dev/null 2>&1; then
  echo "  $(flutter --version 2>/dev/null | head -1)"
  cd "$ROOT_DIR"
  if flutter analyze \
    lib/domain/export \
    lib/features/laboratorio/presentation/providers/recomendacao_export_provider.dart \
    lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart \
    >/tmp/audit_export_analyze.log 2>&1; then
    ok "flutter analyze (escopo export)"
  else
    bad "flutter analyze falhou — ver /tmp/audit_export_analyze.log"
  fi
  if flutter test \
    test/domain/export \
    test/features/laboratorio/application/recomendacao_export_context_builder_test.dart \
    test/features/laboratorio/services/recomendacao_html_renderer_test.dart \
    test/features/laboratorio/presentation/recomendacao/recomendacao_screen_export_test.dart \
    >/tmp/audit_export_test.log 2>&1; then
    ok "flutter test export (7 testes esperados)"
  else
    bad "flutter test export falhou — ver /tmp/audit_export_test.log"
  fi
else
  note "flutter não encontrado no PATH — pulando analyze/test"
fi

section "Veredito"
if [[ -f .git/MERGE_HEAD ]]; then
  note "Bloqueio: resolver MERGE_HEAD antes de commit/IPA"
fi

if [[ "$fail" -eq 0 && ! -f .git/MERGE_HEAD ]]; then
  echo "  🟢 IMPLEMENTADO — pronto para preparar IPA 116"
  echo "     Próximo: ./tool/release_ipa_116_mac.sh"
  exit 0
elif [[ "$fail" -eq 0 ]]; then
  echo "  🟡 EXPORT OK — mas merge pendente impede release"
  echo "     Próximo: ./tool/release_ipa_116_mac.sh --abort-merge-only"
  exit 2
else
  echo "  🔴 PARCIAL — corrigir itens ❌ antes do IPA"
  echo "     Sugestão: git fetch origin && git merge origin/cursor/export-wiring-theme-6ab3"
  exit 1
fi

echo
echo "Resumo: ✅ $pass  ❌ $fail  ⚠️ $warn"
