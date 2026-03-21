# 🍎 TestFlight + IPA — Flutter no IDX (Project IDX)

> Guia completo para distribuir o SoloForte via TestFlight  
> e gerar o arquivo `.ipa` para distribuição.  
> ⚠️ Build iOS **obrigatoriamente requer Mac ou serviço de CI com Mac**.  
> O IDX (Linux) compila Dart/Android — para iOS precisa de etapa extra.

---

## 🔑 Pré-requisitos obrigatórios

```
[ ] Apple Developer Account ativa — https://developer.apple.com
    → Individual: U$99/ano
    → Empresa: U$299/ano

[ ] Xcode instalado (Mac) — ou usar Codemagic/GitHub Actions (CI)
    → Xcode 15+ recomendado

[ ] Bundle ID registrado no Apple Developer Portal
    → Exemplo: com.seudominio.soloforte

[ ] Certificados e Provisioning Profiles configurados
    → Distribution Certificate
    → App Store Provisioning Profile
```

---

## 🗂️ Passo 1 — Configurar Bundle ID no Flutter

### `ios/Runner.xcodeproj` — via Xcode

```
Abrir: ios/Runner.xcodeproj no Xcode
→ Runner (target)
→ Signing & Capabilities
→ Bundle Identifier: com.seudominio.soloforte
→ Team: selecionar sua Apple Developer Account
→ Automatically manage signing: ✅ ativado (recomendado)
```

### `pubspec.yaml` — versão do app

```yaml
version: 1.0.0+1
#         ^   ^
#         |   build number (incrementar a cada TestFlight)
#         versão exibida ao usuário
```

> ⚠️ **Regra TestFlight:** o `build number` (+1) deve ser incrementado a cada upload. Nunca repetir.

---

## 🔥 Passo 2 — Firebase no iOS

Após registrar o app iOS no Firebase Console:

```bash
# Instalar FlutterFire CLI (uma vez)
dart pub global activate flutterfire_cli

# Configurar — roda na raiz do projeto
flutterfire configure

# Selecionar:
# → Projeto Firebase do SoloForte
# → Plataformas: iOS + Android
# Gera automaticamente: lib/firebase_options.dart
```

### Verificar `ios/Runner/GoogleService-Info.plist`

```
Deve existir após o flutterfire configure.
Se não: baixar manualmente do Firebase Console e colocar aqui.
```

---

## 📋 Passo 3 — Permissões iOS (Info.plist)

Abrir `ios/Runner/Info.plist` e adicionar:

```xml
<!-- Localização GPS — obrigatório para análise de solo -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>O SoloForte usa sua localização para registrar o ponto de coleta da análise de solo.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>O SoloForte usa sua localização para registrar o ponto de coleta da análise de solo.</string>

<!-- Câmera — futuro (fotos de campo) -->
<key>NSCameraUsageDescription</key>
<string>Para fotografar a área de coleta e documentar a análise.</string>

<!-- Rede local — Firebase -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
</dict>
```

---

## 🏗️ Passo 4 — Build do IPA

### Opção A — Mac local (mais rápido)

```bash
# Na raiz do projeto Flutter

# 1. Limpar build anterior
flutter clean

# 2. Instalar dependências
flutter pub get

# 3. Gerar código (freezed, riverpod)
dart run build_runner build --delete-conflicting-outputs

# 4. Build iOS release
flutter build ios --release

# 5. Abrir no Xcode para arquivar
open ios/Runner.xcworkspace
```

**No Xcode:**
```
Product → Archive
→ Aguardar build completo
→ Window → Organizer → Archives
→ Selecionar o archive gerado
→ "Distribute App"
→ "App Store Connect"
→ "Upload"
→ Seguir assistente
```

---

### Opção B — Codemagic (sem Mac — recomendado para IDX)

> Melhor opção se você desenvolve só no IDX (sem Mac disponível).

**1. Criar conta:** https://codemagic.io (gratuito para projetos pequenos)

**2. Conectar repositório** (GitHub, GitLab ou Bitbucket)

**3. Criar arquivo `codemagic.yaml` na raiz do projeto:**

```yaml
workflows:
  ios-testflight:
    name: iOS TestFlight
    max_build_duration: 60
    instance_type: mac_mini_m1

    environment:
      flutter: stable
      xcode: latest
      cocoapods: default
      ios_signing:
        distribution_type: app_store
        bundle_identifier: com.seudominio.soloforte

    scripts:
      - name: Instalar dependências
        script: flutter pub get

      - name: Gerar código
        script: dart run build_runner build --delete-conflicting-outputs

      - name: Flutter build iOS
        script: |
          flutter build ios --release --no-codesign

      - name: Build IPA (Xcode Archive)
        script: |
          xcode-project build-ipa \
            --workspace ios/Runner.xcworkspace \
            --scheme Runner

    artifacts:
      - build/ios/ipa/*.ipa
      - /tmp/xcodebuild_logs/*.log

    publishing:
      app_store_connect:
        api_key: $APP_STORE_CONNECT_PRIVATE_KEY
        key_id: $APP_STORE_CONNECT_KEY_IDENTIFIER
        issuer_id: $APP_STORE_CONNECT_ISSUER_ID
        submit_to_testflight: true
        beta_groups:
          - Testadores internos
```

**4. Variáveis de ambiente no Codemagic:**
```
APP_STORE_CONNECT_PRIVATE_KEY    → chave .p8 do App Store Connect
APP_STORE_CONNECT_KEY_IDENTIFIER → Key ID
APP_STORE_CONNECT_ISSUER_ID      → Issuer ID
```

> Essas chaves são geradas em:  
> App Store Connect → Usuários e acesso → Chaves → Chaves da API

---

### Opção C — GitHub Actions (alternativa ao Codemagic)

```yaml
# .github/workflows/ios_testflight.yml

name: iOS TestFlight

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: macos-latest

    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
          channel: 'stable'

      - name: Instalar dependências
        run: flutter pub get

      - name: Gerar código
        run: dart run build_runner build --delete-conflicting-outputs

      - name: Instalar certificados
        uses: apple-actions/import-codesign-certs@v2
        with:
          p12-file-base64: ${{ secrets.CERTIFICATES_P12 }}
          p12-password: ${{ secrets.CERTIFICATES_P12_PASSWORD }}

      - name: Instalar Provisioning Profile
        uses: apple-actions/download-provisioning-profiles@v1
        with:
          bundle-id: com.seudominio.soloforte
          issuer-id: ${{ secrets.APPSTORE_ISSUER_ID }}
          api-key-id: ${{ secrets.APPSTORE_KEY_ID }}
          api-private-key: ${{ secrets.APPSTORE_PRIVATE_KEY }}

      - name: Build e Archive
        run: flutter build ipa --release

      - name: Upload para TestFlight
        uses: apple-actions/upload-testflight-build@v1
        with:
          app-path: build/ios/ipa/*.ipa
          issuer-id: ${{ secrets.APPSTORE_ISSUER_ID }}
          api-key-id: ${{ secrets.APPSTORE_KEY_ID }}
          api-private-key: ${{ secrets.APPSTORE_PRIVATE_KEY }}
```

---

## 🧪 Passo 5 — Configurar TestFlight

**No App Store Connect** (https://appstoreconnect.apple.com):

```
1. Meus Apps → "+" → Novo App
   → Plataforma: iOS
   → Nome: SoloForte
   → Bundle ID: com.seudominio.soloforte
   → SKU: soloforte-001

2. Após upload do build (via Xcode ou CI):
   TestFlight → Builds → selecionar build enviado
   → Aguardar processamento (5-30 min)
   → Status: "Pronto para testar"

3. Adicionar testadores:
   Testadores internos: até 100 pessoas (sem revisão Apple)
   Testadores externos: até 10.000 pessoas (revisão beta ~1 dia)

4. Enviar convite:
   → e-mail com link de instalação via app TestFlight
```

---

## 📁 Onde fica o .ipa gerado

```bash
# Build local (Mac)
build/ios/ipa/SoloForte.ipa

# Codemagic
→ Artifacts da build no dashboard

# GitHub Actions
→ Artifacts da action ou direto no TestFlight
```

---

## 🔢 Versionamento — regra obrigatória

| Situação | O que incrementar |
|---|---|
| Correção de bug | `1.0.1+2` (patch + build) |
| Nova funcionalidade | `1.1.0+3` (minor + build) |
| Mudança grande | `2.0.0+4` (major + build) |
| Só novo build TestFlight | `1.0.0+2` (só build number) |

```bash
# Incrementar versão antes de cada build TestFlight
# Em pubspec.yaml:
version: 1.0.0+2  # build number sempre maior que o anterior
```

---

## ✅ Checklist completo — TestFlight

```
PRÉ-BUILD
[ ] Apple Developer Account ativa
[ ] Bundle ID criado no Developer Portal
[ ] App criado no App Store Connect
[ ] Certificados e Profiles configurados
[ ] firebase_options.dart gerado (flutterfire configure)
[ ] GoogleService-Info.plist em ios/Runner/
[ ] Permissões de localização no Info.plist
[ ] Build number incrementado no pubspec.yaml

BUILD
[ ] flutter clean
[ ] flutter pub get
[ ] dart run build_runner build
[ ] flutter build ios --release (Mac)
    OU codemagic.yaml configurado (IDX)

UPLOAD
[ ] Archive gerado no Xcode → Upload para App Store Connect
    OU Codemagic fez upload automático
[ ] Build aparece no TestFlight (aguardar 5-30 min)
[ ] Status: "Pronto para testar"

DISTRIBUIÇÃO
[ ] Testadores internos adicionados
[ ] Convites enviados por e-mail
[ ] Testadores instalam app TestFlight → instalam SoloForte
```

---

## 📱 Para o App Mapa — mesmo processo

O segundo app segue **exatamente o mesmo fluxo**, com:

```
Bundle ID diferente: com.seudominio.appmapa
App separado no App Store Connect
Build number independente
Mesmo Firebase project (google-services.json e GoogleService-Info.plist próprios)
```

---

*Versão 1.0 — TestFlight + IPA — SoloForte Flutter*
