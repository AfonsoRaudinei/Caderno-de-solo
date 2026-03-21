# 07 — Build e distribuição iOS (TestFlight & Codemagic)

> **Status:** ✅ pipeline codemagic + script manual documentados; siga checklist de validação antes de subir para TestFlight.

## Codemagic workflow (`Analise/codemagic.yaml`)

- Workflow `ios-testflight` (mac_mini_m1)  
  1. `flutter pub get`  
  2. `dart run build_runner build --delete-conflicting-outputs` (geração Freezed/Riverpod)  
  3. `flutter analyze`, `flutter test`  
  4. `flutter build ios --release --no-codesign` + `xcodebuild archive`  
- Artefatos: IPA (`build/ios/ipa/*.ipa`), logs e `flutter_drive.log`.  
- Publicação: App Store Connect integral (`integration: apple_developer_portal`) com `submit_to_testflight: true`.
- Variáveis de ambiente necessárias no dashboard Codemagic / GitHub Secrets: `APP_STORE_CONNECT_PRIVATE_KEY`, `KEY_IDENTIFIER`, `ISSUER_ID`, `FLUTTER_VERSION` (se desejar sobrescrever), `FIREBASE_SERVICE_ACCOUNT` (se fizer deploys automatizados).

## Script local `build_ios.sh`

1. `flutter clean`  
2. `flutter pub get`  
3. Lê `version: 1.0.1+11`, separa `build number` e incrementa (`sed` compatível Linux/macOS).  
4. Atualiza `pubspec.yaml` com o novo build number  
5. Executa `flutter build ipa --release --export-method app-store --build-name <versão> --build-number <build>`  
6. Loga sucesso ou falha.  

> Use este script antes de enviar manualmente para App Store (ou como pré-step para Codemagic) para manter o `version/build` sincronizado.

## Checklist TestFlight / App Store

1. `flutter analyze` (sem erros).  
2. `flutter test` (todos os testes unitários).  
3. `dart run build_runner build --delete-conflicting-outputs`.  
4. `flutter build ios --release` (em mac + `flutter precache`).  
5. Arquive (`xcodebuild archive ... -archivePath build/ios/Runner.xcarchive`) e exporte IPA (`flutter build ipa`).  
6. Submeta pelo App Store Connect / Codemagic (prefira pipeline).  
7. No App Store Connect, atribua release notes e monitorar crash reports.

## Permissões e Info.plist

- Adicione as strings de permissão no `ios/Runner/Info.plist` (confirmado pelo prompt 14):  
  - `NSLocationWhenInUseUsageDescription` e `NSLocationAlwaysAndWhenInUseUsageDescription`  
  - `NSCameraUsageDescription`  
- Garanta que os `entitlements` estejam em sincronia com o bundle ID configurado no Firebase e no App Store Connect.

## Dicas extras

- Mantenha o arquivo `firebase.json` atualizado com os `appId`s iOS/Android.  
- Se precisar rodar o build em máquina local sem Codemagic, use `build_ios.sh` e depois `xcodebuild -exportArchive` manual.  
- TestFlight exige que o número da build (`+NN`) seja incremental; o script `build_ios.sh` já cuida disso.  
- Para distribuição de produção, registre certificados e provisioning profiles no portal Apple e sincronize com Codemagic via `app_store_credentials`.
