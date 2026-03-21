# 06 — Dependências documentadas (`pubspec.yaml`)

> **Status:** ✅ pubspec e assets documentados. O projeto usa Flutter 3.16+ com Dart 3.0+. Uso principal do IDX + Firebase.

## Ambiente

- `sdk: ">=3.0.0 <4.0.0"` garante compatibilidade com null safety e o novo analisador do Dart.  
- `flutter: ">=3.16.0"` abre Material 3, suporte oficial a `go_router` 13 e `flutter_riverpod` 2.5+.

## Dependências principais

| Pacote | Versão | Justificativa |
| --- | --- | --- |
| `go_router ^13.0.0` | ~ | Navegação declarativa com `ShellRoute` e proteção de rotas. |
| `flutter_riverpod ^2.5.0` + `hooks_riverpod ^2.6.1` + `riverpod_annotation ^2.3.0` | ~ | Gerência de estado reativa, geração de providers e suporte a Hooks. |
| `freezed_annotation` + `json_annotation` | ~ | Modelos imutáveis e serialização Firestore. |
| `dio ^5.4.0` | ~ | Cliente HTTP preparado para futuras integrações (mesmo que hoje só Firestore). |
| `hive_flutter ^1.1.0` | ~ | Cache local dos perfis de calibração. |
| `flutter_secure_storage ^9.0.0` | ~ | Persistência segura do token (`auth_token`). |
| `flutter_animate ^4.5.0` | ~ | Pequenas animações (botões, cards). |
| `flutter_hooks ^0.20.0` | ~ | Simplifica controllers de formulário nas telas de auth. |
| `geolocator ^11.0.0` + `geocoding ^3.0.0` | ~ | Planejamento para localização (botão de captura). Atualmente a ação só simula coordenadas. |
| `firebase_core ^2.27.0`, `cloud_firestore ^4.17.0`, `firebase_auth ^4.20.0` | ~ | Integração Firebase (autenticação + Firestore) usada por auth + datasources. |
| `intl ^0.20.2` | ~ | Formatação de datas/globais. |
| `uuid ^4.3.0` | ~ | Geração de IDs para análises e recomendações. |
| `equatable ^2.0.5` | ~ | Comparação rápida em entidades (alguns providers podem adotar). |
| `flutter_localizations` | sdk | Localização pt-BR no `MaterialApp.router`.
| `cupertino_icons ^1.0.8` | ~ | Ícones iOS para abas e botões. |

## Dev dependencies

| Pacote | Versão | Propósito |
| --- | --- | --- |
| `flutter_test` (sdk) | - | Execução da suíte Flutter. |
| `build_runner ^2.4.0` | ~ | Gera código `freezed` + `riverpod`. |
| `freezed ^2.5.0` | ~ | Geração de classes imutáveis. |
| `json_serializable ^6.7.0` | ~ | Serialização JSON. |
| `riverpod_generator ^2.3.0` | ~ | Geração de providers anotados. |
| `flutter_lints ^4.0.0` | ~ | Regras de lint recomendadas para Flutter 3. |
| `mocktail ^1.0.4` | ~ | Mocks/espionagem nos testes (`login_controller_test`). |

## Assets contabilizados

- `assets/images/` e `assets/icons/` hospedam logos, ícones e branding do app.  
- `PROMPT/dados referencias/` inclui markdowns usados em `BaseDadosDetailPage`.  
- Declare novos assets em `flutter.assets` sempre que adicionar imagens, ícones ou markdowns extras.
