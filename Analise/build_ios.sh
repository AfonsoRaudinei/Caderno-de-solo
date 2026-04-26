#!/bin/bash

# Este script limpa o projeto, atualiza as dependências, incrementa o número da build no pubspec.yaml
# e compila a versão release do iOS (IPA) para a App Store.

echo "🧹 Limpando o projeto..."
flutter clean

echo "📦 Atualizando dependências..."
flutter pub get

echo "🛡️ Executando Release Gate..."
./tool/release_gate.sh

# Extrai a versão atual do pubspec.yaml (ex: version: 1.0.1+9)
CURRENT_VERSION_LINE=$(grep "version: " pubspec.yaml)
CURRENT_VERSION_STRING=$(echo $CURRENT_VERSION_LINE | awk '{print $2}')

# Separa a versão (ex: 1.0.1) do build number (ex: 9)
VERSION_NAME=$(echo $CURRENT_VERSION_STRING | cut -d '+' -f 1)
BUILD_NUMBER=$(echo $CURRENT_VERSION_STRING | cut -d '+' -f 2)

# Permite forçar o build number via primeiro argumento: ./build_ios.sh 32
if [ -n "$1" ]; then
  if ! [[ "$1" =~ ^[0-9]+$ ]]; then
    echo "❌ Build number inválido: $1"
    exit 1
  fi
  NEW_BUILD_NUMBER="$1"
else
  # Incrementa o build number
  NEW_BUILD_NUMBER=$((BUILD_NUMBER + 1))
fi
NEW_VERSION_STRING="${VERSION_NAME}+${NEW_BUILD_NUMBER}"

echo "📈 Atualizando versão: $CURRENT_VERSION_STRING -> $NEW_VERSION_STRING"

# Atualiza o pubspec.yaml
# Compatível com o sed do macOS e do Linux
sed -i.bak "s/version: $CURRENT_VERSION_STRING/version: $NEW_VERSION_STRING/g" pubspec.yaml
rm pubspec.yaml.bak

echo "🍏 Compilando iOS (IPA)..."
# Passamos explicitamente o nome e número atualizados para o comando de build
if [ "${REQUIRE_ANALISE_TELEMETRY_ENDPOINT:-false}" = "true" ] && [ -z "${ANALISE_TELEMETRY_ENDPOINT:-}" ]; then
  echo "❌ ANALISE_TELEMETRY_ENDPOINT obrigatório para este build e não informado."
  exit 1
fi

BUILD_ARGS=(
  --release
  --export-method app-store
  --dart-define=ANALISE_MOCK_MODE=false
  --build-name "$VERSION_NAME"
  --build-number "$NEW_BUILD_NUMBER"
)

if [ -n "${ANALISE_TELEMETRY_ENDPOINT:-}" ]; then
  BUILD_ARGS+=(--dart-define=ANALISE_TELEMETRY_ENDPOINT="${ANALISE_TELEMETRY_ENDPOINT}")
fi

if [ -n "${ANALISE_TELEMETRY_API_KEY:-}" ]; then
  BUILD_ARGS+=(--dart-define=ANALISE_TELEMETRY_API_KEY="${ANALISE_TELEMETRY_API_KEY}")
fi

flutter build ipa "${BUILD_ARGS[@]}"

if [ $? -eq 0 ]; then
  echo "✅ Build finalizada com sucesso!"
  echo "Nova versão gerada: $NEW_VERSION_STRING"
else
  echo "❌ Erro ao compilar a IPA."
  exit 1
fi
