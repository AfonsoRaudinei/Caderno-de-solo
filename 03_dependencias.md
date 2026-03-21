# 📦 Dependências — pubspec.yaml

> Stack completa baseada no manual de boas práticas Flutter/Dart.  
> Organizada por categoria com justificativa de cada package.

---

## pubspec.yaml completo

```yaml
name: analise_solo
description: App profissional de análise e recomendação de fertilidade de solo.
version: 1.0.0+1

environment:
  sdk: ">=3.0.0 <4.0.0"
  flutter: ">=3.16.0"

dependencies:
  flutter:
    sdk: flutter

  # ─── NAVEGAÇÃO ───────────────────────────────────────────
  go_router: ^13.0.0
  # Navegação declarativa com suporte a deep links e auth guard

  # ─── GERÊNCIA DE ESTADO ──────────────────────────────────
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0
  # Reatividade fina: Calibração atualiza Recomendação em tempo real

  # ─── MODELOS IMUTÁVEIS ───────────────────────────────────
  freezed_annotation: ^2.4.0
  json_annotation: ^4.9.0
  # Entidades imutáveis + serialização JSON sem boilerplate

  # ─── REDE ────────────────────────────────────────────────
  dio: ^5.4.0
  # HTTP client com interceptors para auth, retry e logging

  # ─── CACHE LOCAL ─────────────────────────────────────────
  hive_flutter: ^1.1.0
  # Banco local rápido para calibrações e histórico offline

  # ─── AUTENTICAÇÃO SEGURA ─────────────────────────────────
  flutter_secure_storage: ^9.0.0
  # Armazenamento seguro de tokens (Keychain iOS / Keystore Android)

  # ─── UI / VISUAL iOS ─────────────────────────────────────
  cupertino_icons: ^1.0.8
  # Ícones nativos iOS

  flutter_animate: ^4.5.0
  # Animações declarativas — transições suaves 200ms

  # ─── FORMULÁRIOS ─────────────────────────────────────────
  flutter_hooks: ^0.20.0
  # Simplifica controllers de TextField e FocusNode

  # ─── LOCALIZAÇÃO (GPS) ───────────────────────────────────
  geolocator: ^11.0.0
  # Captura lat/long no campo com precisão e permissões iOS/Android

  geocoding: ^3.0.0
  # Reverse geocoding: lat/long → município e estado automaticamente

  # ─── FIREBASE ────────────────────────────────────────────
  firebase_core: ^2.27.0
  cloud_firestore: ^4.17.0
  # Banco em tempo real — sincroniza análises com o App Mapa via pins

  firebase_auth: ^4.20.0
  # Autenticação compartilhada entre SoloForte e App Mapa

  # ─── UTILITÁRIOS ─────────────────────────────────────────
  intl: ^0.19.0
  # Formatação de números, datas e localização pt-BR

  uuid: ^4.3.0
  # Geração de IDs únicos para análises e calibrações

  equatable: ^2.0.5
  # Comparação de objetos em estados Riverpod

dev_dependencies:
  flutter_test:
    sdk: flutter

  # ─── GERAÇÃO DE CÓDIGO ───────────────────────────────────
  build_runner: ^2.4.0
  freezed: ^2.5.0
  json_serializable: ^6.7.0
  riverpod_generator: ^2.3.0
  # Geração automática: dart run build_runner watch

  # ─── QUALIDADE ───────────────────────────────────────────
  flutter_lints: ^4.0.0
  # Lint oficial Flutter (analysis_options.yaml)

  mocktail: ^1.0.0
  # Mocks para testes unitários de use cases e repositories

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
  fonts:
    - family: SFPro
      fonts:
        - asset: assets/fonts/SFPro-Regular.otf
        - asset: assets/fonts/SFPro-Medium.otf
          weight: 500
        - asset: assets/fonts/SFPro-Semibold.otf
          weight: 600
```

---

## 📋 Resumo por Categoria

| Categoria | Package | Versão |
|---|---|---|
| Navegação | go_router | ^13.0.0 |
| Estado | flutter_riverpod | ^2.5.0 |
| Modelos | freezed_annotation | ^2.4.0 |
| Serialização | json_annotation | ^4.9.0 |
| HTTP | dio | ^5.4.0 |
| Cache local | hive_flutter | ^1.1.0 |
| Auth segura | flutter_secure_storage | ^9.0.0 |
| Ícones iOS | cupertino_icons | ^1.0.8 |
| Animações | flutter_animate | ^4.5.0 |
| Formulários | flutter_hooks | ^0.20.0 |
| Formatação | intl | ^0.19.0 |
| IDs únicos | uuid | ^4.3.0 |

---

## ⚡ Comandos Essenciais

```bash
# Instalar dependências
flutter pub get

# Gerar código (freezed, json, riverpod)
dart run build_runner watch --delete-conflicting-outputs

# Análise estática
flutter analyze

# Formatar código
dart format lib/

# Rodar testes
flutter test

# Build iOS
flutter build ios --release

# Build Android
flutter build appbundle --release
```

---

## 🔧 analysis_options.yaml

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - prefer_const_constructors
    - prefer_const_literals_to_create_immutables
    - avoid_print
    - use_key_in_widget_constructors
    - prefer_final_fields
    - always_use_package_imports

analyzer:
  errors:
    missing_required_param: error
    missing_return: error
```

---

*Versão 1.0*
