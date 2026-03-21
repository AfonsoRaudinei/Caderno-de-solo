#!/bin/bash

# Este script limpa o projeto, atualiza as dependências, incrementa o número da build no pubspec.yaml
# e compila a versão release do iOS (IPA) para a App Store.

echo "🧹 Limpando o projeto..."
flutter clean

echo "📦 Atualizando dependências..."
flutter pub get

# Extrai a versão atual do pubspec.yaml (ex: version: 1.0.1+9)
CURRENT_VERSION_LINE=$(grep "version: " pubspec.yaml)
CURRENT_VERSION_STRING=$(echo $CURRENT_VERSION_LINE | awk '{print $2}')

# Separa a versão (ex: 1.0.1) do build number (ex: 9)
VERSION_NAME=$(echo $CURRENT_VERSION_STRING | cut -d '+' -f 1)
BUILD_NUMBER=$(echo $CURRENT_VERSION_STRING | cut -d '+' -f 2)

# Incrementa o build number
NEW_BUILD_NUMBER=$((BUILD_NUMBER + 1))
NEW_VERSION_STRING="${VERSION_NAME}+${NEW_BUILD_NUMBER}"

echo "📈 Atualizando versão: $CURRENT_VERSION_STRING -> $NEW_VERSION_STRING"

# Atualiza o pubspec.yaml
# Compatível com o sed do macOS e do Linux
sed -i.bak "s/version: $CURRENT_VERSION_STRING/version: $NEW_VERSION_STRING/g" pubspec.yaml
rm pubspec.yaml.bak

echo "🍏 Compilando iOS (IPA)..."
# Passamos explicitamente o nome e número atualizados para o comando de build
flutter build ipa --release --export-method app-store --build-name "$VERSION_NAME" --build-number "$NEW_BUILD_NUMBER"

if [ $? -eq 0 ]; then
  echo "✅ Build finalizada com sucesso!"
  echo "Nova versão gerada: $NEW_VERSION_STRING"
else
  echo "❌ Erro ao compilar a IPA."
  exit 1
fi
