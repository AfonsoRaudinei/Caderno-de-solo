# 01 — Clean Architecture + Riverpod (SoloForte)

> **Status:** ✅ alinhado com o código atual (camadas e decisões estão implementadas).

## Camadas principais

1. `core/`  
   Beans compartilhados: tema (`app_theme.dart`), rotas (`app_router.dart` / `AppRoutes`), strings e widgets genéricos (`app_button`, `app_card`, `app_input`, `app_dropdown`).  
2. `domain/`  
   Entidades imutáveis (`AnaliseSolo`, `AnaliseEntity`, `CalibracaoEntity`, `ReferenciaTecnica`), contratos (repositories) e uso de `freezed`/`json_serializable`.  
3. `data/`  
   *Fontes* de dados: `AnaliseLocalDatasource` (lista em memória + delays), Firestore datasources (`AnaliseFirestoreDatasource`, `RecomendacaoFirestoreDatasource`, `CalibracaoFirestoreDatasource`, `AuthDatasource`). Os repositórios concretos (`AnaliseRepositoryImpl`, etc.) são injetados por Riverpod.  
4. `presentation/`  
   Widgets divididos por feature (auth, analise, lab, historico, config). Cada tela expõe Notifiers/StateProviders e escuta os Use Cases do domínio.

```text
Widget → Riverpod Controller → UseCase → Repository → DataSource (local/remote)
``` 

## Riverpod + fluxo de dados

- `main.dart` envolve o app em `ProviderScope`.  
- `routerProvider` expõe `GoRouter` e adiciona guardas baseadas em `FlutterSecureStorage` (token `auth_token`).  
- Cada módulo usa `riverpod_annotation`: por exemplo, `analise_provider` registra `AnaliseNotifier`, que invoca `GetAnalisesUsecase`, que depende de `AnaliseRepository`.  
- `Lab` e `Config` usam `StateNotifierProvider` e `StateProvider` para gerenciar abas, perfis de calibração (`calibracaoControllerProvider`) e filtros.  
- `features/culturas/providers/culturas_provider.dart` demonstra como o app mantém estados pequenos (tipo de fonte, seleção de nutrientes, modo de visualização).

## Infraestrutura crítica e decisões

| Área | Implementação atual | Observações |
| --- | --- | --- |
| Inicialização | `main` chama `Hive.initFlutter()` + `Firebase.initializeApp()` + `DefaultFirebaseOptions.currentPlatform`. | Firebase placeholder para Android/web/macos; iOS usa chaves reais (ID `soloforte-106c8`). |
| Autenticação | `AuthDatasource` usa `FirebaseAuth`, armazena `auth_token` em `FlutterSecureStorage` e redireciona o `GoRouter`. | Controllers (login/cadastro/recuperar senha) propagam estados via `Riverpod`. |
| Firebase | Firestore com coleções `analises`, `recomendacoes`, `users/{uid}/calibracoes` (datasources) + stream para mapa (segundo app). | `AnaliseLocalDatasource` ainda atua como mock, mas a camada Firestore já existe e pode ser ativada trocando o repositório. |
| Cache local | `Hive` guarda perfis de calibração no box `calibracao_profiles_box`; consultas são sincronizadas com a UI. | Keep offline resiliente com perfis persistidos. |
| Clean decisions | Camadas não importam Flutter; `domain` é puro Dart. Tests (`test/domain`) validam fórmulas e Use Cases. |

## Pontos de extensão

- O mesmo projeto Firebase abriga o segundo app (`App Mapa`) via `GoogleService-Info.plist` + `google-services.json`.  
- Os datasources remotos podem ser ativados gradualmente; já existem testes unitários para o motor de cálculo e os controllers de auth.  
- O padrão `ProviderScope → Router → Screens` garante que novas funcionalidades (ex: `Culturas`, `Base de Dados`) encaixem sem romper as camadas.
