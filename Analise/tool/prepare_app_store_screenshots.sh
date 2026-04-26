#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RAW_DIR="${1:-$ROOT_DIR/docs/release/screenshots/raw}"
OUT_BASE="${2:-$ROOT_DIR/docs/release/screenshots}"
OUT_69="$OUT_BASE/iphone_69"
OUT_65="$OUT_BASE/iphone_65"

mkdir -p "$OUT_69" "$OUT_65"

if [ ! -d "$RAW_DIR" ]; then
  echo "❌ Diretório de entrada não encontrado: $RAW_DIR"
  exit 1
fi

INPUTS=()
while IFS= read -r file; do
  INPUTS+=("$file")
done < <(find "$RAW_DIR" -maxdepth 1 -type f \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' \) | sort)

if [ "${#INPUTS[@]}" -eq 0 ]; then
  echo "❌ Nenhuma imagem encontrada em: $RAW_DIR"
  exit 1
fi

process_image() {
  local src="$1"
  local out="$2"
  local target_w="$3"
  local target_h="$4"
  local tmp_scaled
  tmp_scaled="$(mktemp -t screenshot_scaled_XXXXXX.png)"

  local src_w src_h
  src_w="$(sips -g pixelWidth "$src" | awk '/pixelWidth/ {print $2}')"
  src_h="$(sips -g pixelHeight "$src" | awk '/pixelHeight/ {print $2}')"

  # Compara razão de aspecto sem usar ponto flutuante.
  local left right
  left=$(( src_w * target_h ))
  right=$(( target_w * src_h ))

  if [ "$left" -gt "$right" ]; then
    # Mais larga que o alvo: iguala altura e corta largura.
    sips --resampleHeight "$target_h" "$src" --out "$tmp_scaled" >/dev/null
    local scaled_w
    scaled_w="$(sips -g pixelWidth "$tmp_scaled" | awk '/pixelWidth/ {print $2}')"
    local offset_x=$(( (scaled_w - target_w) / 2 ))
    sips --cropToHeightWidth "$target_h" "$target_w" \
      --cropOffset 0 "$offset_x" \
      "$tmp_scaled" --out "$out" >/dev/null
  elif [ "$left" -lt "$right" ]; then
    # Mais alta que o alvo: iguala largura e corta altura.
    sips --resampleWidth "$target_w" "$src" --out "$tmp_scaled" >/dev/null
    local scaled_h
    scaled_h="$(sips -g pixelHeight "$tmp_scaled" | awk '/pixelHeight/ {print $2}')"
    local offset_y=$(( (scaled_h - target_h) / 2 ))
    sips --cropToHeightWidth "$target_h" "$target_w" \
      --cropOffset "$offset_y" 0 \
      "$tmp_scaled" --out "$out" >/dev/null
  else
    # Mesma razão de aspecto.
    sips --resampleHeightWidth "$target_h" "$target_w" "$src" --out "$out" >/dev/null
  fi

  rm -f "$tmp_scaled"
}

i=1
for src in "${INPUTS[@]}"; do
  name="$(printf "%02d_%s.png" "$i" "$(basename "$src" | sed 's/\.[^.]*$//; s/[^A-Za-z0-9_-]/_/g')")"
  process_image "$src" "$OUT_69/$name" 1320 2868
  process_image "$src" "$OUT_65/$name" 1242 2688
  i=$((i + 1))
done

verify_dir() {
  local dir="$1"
  local expected_w="$2"
  local expected_h="$3"
  local fail=0
  while IFS= read -r file; do
    local w h
    w="$(sips -g pixelWidth "$file" | awk '/pixelWidth/ {print $2}')"
    h="$(sips -g pixelHeight "$file" | awk '/pixelHeight/ {print $2}')"
    if [ "$w" -ne "$expected_w" ] || [ "$h" -ne "$expected_h" ]; then
      echo "❌ Dimensão inválida: $file => ${w}x${h} (esperado ${expected_w}x${expected_h})"
      fail=1
    fi
  done < <(find "$dir" -maxdepth 1 -type f -name '*.png' | sort)
  return "$fail"
}

verify_dir "$OUT_69" 1320 2868
verify_dir "$OUT_65" 1242 2688

count_69="$(find "$OUT_69" -maxdepth 1 -type f -name '*.png' | wc -l | tr -d ' ')"
count_65="$(find "$OUT_65" -maxdepth 1 -type f -name '*.png' | wc -l | tr -d ' ')"

echo "✅ Screenshots preparados."
echo "   - 6.9\": $count_69 arquivo(s) em $OUT_69"
echo "   - 6.5\": $count_65 arquivo(s) em $OUT_65"
