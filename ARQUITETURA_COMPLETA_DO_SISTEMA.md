# Mapa Estrutural do Sistema Soloforte

1. **Visão Geral do Sistema**

- **Objetivo**: O app "Analise" (codinome SoloForte) centraliza análise de fertilidade do solo e gera recomendações agrícolas. A descrição em `pubspec.yaml` define o escopo como "App profissional de análise e recomendação de fertilidade de solo".
- **Tipo de sistema**: Flutter mobile multiplataforma com foco em dispositivos iOS/Android; usa Material 3 com estética atualizada (tema inspirado no design iOS) e widgets personalizados.
- **Arquitetura geral**: Clean architecture híbrida com camadas `presentation`, `domain`, `data` e `core`. A camada de apresentação consome Riverpod + HookConsumerWidget; o domínio encapsula modelos, fórmulas e casos de uso; a camada de dados engloba datasources Firebase; o `core` expõe temas, widgets, rotas e utilitários (ex.: localização). O entrypoint (`lib/main.dart`) inicializa o Firebase e abre um `ProviderScope` com `MaterialApp.router`.
- **Princípios adotados**: centralização de constantes (`AppStrings`, `AppRoutes`), tema consistente (AppTheme/AppColors/AppTextStyles), componentes reutilizáveis (AppButton, AppInput, AppCard etc.), validações guiadas por controllers Riverpod, governança de estado declarativa e redirecionamento via `GoRouter` com autenticação tokenizada por `FlutterSecureStorage`.

2. **Estrutura de Pastas do Projeto**

Root do projeto (`/Users/.../Analise solo`)
- Documentos top-level (`01_projeto_visao_geral.md` a `09_ordem_execucao_prompts.md`) projetam contexto estratégico, mas não integram o código.
- `Analise/`: único módulo Flutter.
  - `android/`, `ios/`: configurações nativas geradas pelo Flutter.
  - `assets/`: imagens, ícones e diretórios (fonts vazio) referenciados por widgets como o ícone exibido na tela de login.
  - `build/`: artefatos compilados (ignorados para análise).
  - `firebase.json`, `codemagic.yaml`, `analysis_options.yaml`: configam integrações Firebase, pipeline Codemagic e lint.
  - `lib/`: aplicação Dart.
    - `core/`: constantes (rotas, strings), router (`go_router`), tema (AppTheme/AppColors/AppTextStyles/AppDimens), utilitários (`location_service.dart`), widgets base (AppButton, AppCard, AppInput, AppDropdown e NutrienteCard) e definição de providers compartilhados (`routerProvider`, `locationServiceProvider`).
    - `data/`: `datasources/remote` com implementações Firebase para autenticação (`auth_datasource.dart`), análise (`analise_firestore_datasource.dart`) e recomendação (`recomendacao_firestore_datasource.dart`); `datasources/local`, `models` e `repositories` existem mas estão vazios.
    - `domain/`: `formulas` (Calcário, Fósforo e Potássio), `models` (AnaliseModel e RecomendacaoModel com serialização Freezed/JSON/Firestore) e `usecases` (CalcularRecomendacaoUseCase que combina fórmulas para gerar uma recomendação). `entities` e `repositories` ainda não têm classes.
    - `presentation/`: concentra módulos `auth`, `analise`, `lab`, `historico`, `config` e `main`. Cada módulo contém páginas e controllers Riverpod que o executam.
    - `firebase_options.dart`: placeholders automáticos do FlutterFire para inicializar `FirebaseOptions` em cada plataforma.
    - `main.dart`: entrypoint.
  - `pubspec.yaml` / `pubspec.lock`: dependências listam Firebase, geolocalização, Riverpod, hooks, freezed, Dio, Hive, Flutter Secure Storage.
  - `test/`: subdividido em `domain` (testes de fórmulas) e `presentation` (teste do login controller).

3. **Arquitetura Técnica**

- **Camadas principais**:
  - `presentation`: Flutter widgets + `HookConsumerWidget` e `StatelessWidget` com Riverpod; cada página em `lib/presentation/...` consome controllers (p. ex., `loginControllerProvider`, `analiseFormControllerProvider`).
  - `domain`: modelos Freezed (`AnaliseModel`, `RecomendacaoModel`, `LocationDataModel`), fórmulas agronômicas e caso de uso (`CalcularRecomendacaoUseCase`).
  - `data`: datasources Firebase (analises, recomendacoes, auth). Controllers a nível de página consumem diretamente esses providers (`ref.read(authDatasourceProvider)`), sem repositórios intermediários implementados.
  - `core`: temas, constantes, widgets compartilhados, roteamento e utilitários (ex.: `LocationService`).
- **Separação de responsabilidades**: presentation gerencia UI e validação, domain isola regras matemáticas, data encapsula acesso a Firestore/Auth. Core provê infraestrutura transversal (tema, strings, rotas, providers). Há pouca lógica cross-layer (use case não integrado diretamente em controllers, mas existe para futura reutilização).
- **Fluxo de dependências**: `presentation` → `domain`/`data`/`core`; `domain` não referencia presentation; `data` usa Firebase e Riverpod; `core` é dependência de todas as camadas.
- **Padrões observados**: Hook + Riverpod (HookConsumerWidget + `ref.watch`, `ref.listen`), uso de `StateProvider` e `AsyncValue`, centralização de constantes de rota e strings, `GoRouter` com `ShellRoute` para abas.

4. **Módulos do Sistema**

- **Auth** (`lib/presentation/auth/...`): páginas `LoginPage`, `CadastroPage` (3 etapas) e `RecuperarSenhaPage`. Controladores Riverpod (`LoginController`, `CadastroController`, `RecuperarSenhaController`) expõem estados `AsyncValue`. Dependem de `authDatasourceProvider` → FirebaseAuth + Flutter Secure Storage (token). O segmento no login oferece navegação para cadastro/recuperação via `AppRoutes`.
- **Analise** (`lib/presentation/analise/...`): `AnalisePage` lista análises (mock) e dispara `AnaliseFormPage`. O form usa `AnaliseFormController` para mapear macros (P, K, Ca, Mg, Al, HAl) e calcular CTC/V automaticamente. Usa `LocationService` (geolocator + geocoding). O botão “Calcular Recomendação” é placeholder que leva a `AppRoutes.lab`.
- **Lab** (`lib/presentation/lab/...`): `LabPage` exibe TabBar com `CalibracaoPage` e `RecomendacaoPage` (ambas exibem textos placeholders). O layout reutiliza `AppColors` + `TextStyles`. Ainda carece de lógica real (não há controllers nem integração com domain use case). Módulos `widgets/` estão vazios.
- **Historico** (`lib/presentation/historico/historico_page.dart`): lista mock `mockData` com dismissible cards (`AppCard`) e filtros visuais, permite excluir itens localmente e navegar (`context.push(AppRoutes.lab)`). Usa `useState` para dados temporários.
- **Config** (`lib/presentation/config/...`): `ConfigPage` organiza seções de perfil, gerenciamento e sistema. Navega para `BaseDadosPage` (lista mock de referências) e `FeedbackPage`. `BaseDadosFormPage` exibe formulário de cadastro de referência. Há diretório `perfil/` vazio, portanto nenhum conteúdo para atualizar perfil ("Não identificado no código").

5. **Sistema de Rotas**

- `GoRouter` (`lib/core/router/app_router.dart`) com `initialLocation = AppRoutes.analise`, `redirect` baseado em token salvo em `FlutterSecureStorage`.
- Rotas principais:
  1. `/login` → `LoginPage` (entrada de credenciais).
  2. `/cadastro` → `CadastroPage` (3 etapas: perfil, localização, credenciais).
  3. `/recuperar-senha` → `RecuperarSenhaPage` (envia mock de link).
  4. `/` (AppRoutes.home) redireciona para `/analise`.
  5. `/analise` → `AnalisePage` dentro de `ShellRoute` (barra de navegação).
  6. `/analise/nova` → `AnaliseFormPage` (formulário detalhado).
  7. `/lab` → `LabPage` (tab serial com `CalibracaoPage` e `RecomendacaoPage`).
  8. `/historico` → `HistoricoPage`.
  9. `/config` → `ConfigPage`.
 10. `/home/config/feedback` → `FeedbackPage`.
 11. `/home/config/base-dados` → `BaseDadosPage`.
 12. `/home/config/base-dados/nova` → `BaseDadosFormPage`.
- O `ShellRoute` (`MainPage`) mantém a `NavigationBar` e troca apenas o `child`, permitindo manter o histórico interno entre abas. O `routerProvider` é um provider Riverpod que injeta dependências no `MaterialApp.router`.

6. **Gerenciamento de Estado**

- `HookConsumerWidget` + Riverpod (`hooks_riverpod`) governam o estado. `ProviderScope` engloba o app (`lib/main.dart`).
- Providers principais:
  - `routerProvider`: instancia `GoRouter` com lógica de redirecionamento (token/autenticação).
  - `locationServiceProvider`: `Provider<LocationService>` que encapsula geolocator/geocoding.
  - `loginControllerProvider`, `cadastroControllerProvider`, `recuperarSenhaControllerProvider`: `AsyncNotifier` para autenticação.
  - `cadastroStepProvider`: `StateProvider.autoDispose<int>` para controlar a etapa do cadastro.
  - `linkEnviadoProvider`: `StateProvider.autoDispose<bool>` para o resumo do link de recuperação.
  - `analiseFormControllerProvider`: `AsyncNotifier` (mapa de double) que guarda P, K, Ca, Mg, Al, HAl, CTC e V% e expõe métodos `updateValue` e `captureLocation`.
- Padrões de atualização: `ref.watch` para renderizar estado, `ref.listen` para snackbars, `state = const AsyncLoading()`/`AsyncData`/`AsyncError` para feedback.
- O formulário calcula CTC e V localmente antes de persistir, fazendo a lógica reativa totalmente dentro do controller (updateValue recalcula ao digitar).

7. **Fluxo Principal do Aplicativo**

1. **Inicialização**: `main()` chama `Firebase.initializeApp` com `DefaultFirebaseOptions` (placeholder) e inicia `ProviderScope`.
2. **Roteamento**: `MaterialApp.router` usa `routerProvider`; o `GoRouter` verifica `auth_token` via `FlutterSecureStorage`. Sem token, redireciona para `/login`; com token, permite acesso às abas.
3. **Login**: `LoginPage` valida campos, aparece segmented control (login/cadastro). `LoginController.login` usa `AuthDatasource.signInWithEmailAndPassword` → FirebaseAuth → grava `auth_token` no storage, depois `context.go(AppRoutes.home)`.
4. **Shell principal**: `MainPage` (NavigationBar) troca entre `Analise`, `Lab`, `Historico`, `Config`. Cada destino troca conteúdo por `context.go(AppRoutes.xxx)`.
5. **Fluxos dentro das abas**:
   - **Análise**: `AnalisePage` vazio mostra CTA “+ Nova Análise”; o botão abre `AnaliseFormPage` (`context.push(AppRoutes.analiseForm)`).
   - **Nova Análise**: coleta dados pessoais, localização (captura via `LocationService`), texturas/argila, macronutrientes e acidez; CTC e V são recalculados automaticamente e exibidos em cards. Botões finais chamam `context.go(AppRoutes.lab)` ou simulam salvamento local via snackbar.
   - **Lab**: `TabBarView` com `CalibracaoPage` e `RecomendacaoPage` (ambas como `Center(Text(...))`). Ainda sem integração; o caso de uso `CalcularRecomendacaoUseCase` existe mas não é invocado no UI.
   - **Histórico**: mock `mockData` (lista de análises) exibida com `Dismissible` e `AppCard`; gesto de swipe remove e mostra snackbar; tap leva a `AppRoutes.lab`.
   - **Config**: lista de seções (Perfil, Gerenciamento, Sistema). `BaseDados` e `Feedback` têm páginas dedicadas com formulários mock; `perfil/` está vazio e não é utilizado.
6. **Logout**: `CadastroController.logout` remove token. No `GoRouter`, a próxima navegação sem token volta ao login.

8. **Integrações Externas**

- **Firebase** (`firebase_core`, `firebase_auth`, `cloud_firestore`): inicializado em `main.dart`; `AuthDatasource` (login/cadastro/reset de senha) usa `FirebaseAuth`; `AnaliseFirestoreDatasource` e `RecomendacaoFirestoreDatasource` persistem documentos nas coleções `analises` e `recomendacoes` com timestamps `FieldValue.serverTimestamp`.
- **Flutter Secure Storage** (`flutter_secure_storage`): armazena o `auth_token` na autenticação (`AuthDatasource.signInWithEmailAndPassword`) e o apaga no logout; o router lê este token para permitir acesso.
- **Geolocator + Geocoding** (`geolocator`, `geocoding`): `core/utils/location_service.dart` solicita permissões, captura coordenadas e faz reverse geocode, retornando `LocationDataModel` (nome do município, estado, endereço). `AnaliseFormPage` apresenta essas informações.
- **Hive & Dio** (dependências listadas em `pubspec.yaml`): atualmente não há referências no código (`rg` não encontrou importações), indicando dependências preparadas para uso futuro.

9. **Banco de Dados (visível no código)**

- **Coleção `analises` (Firestore)**: definida em `AnaliseFirestoreDatasource`; campos esperados pelo modelo `AnaliseModel` (`lib/domain/models/analise_model.dart`): `id`, `userId`, `fazendaNome`, `talhaoNome`, `dataColeta`, `status`, `cultura`, `ph`, `fosforo`, `potassio`, `calcio`, `magnesio`, `ctc`, `saturacaoBases`, `createdAt`, `updatedAt`. Conversão de timestamps usa `TimestampConverter`.
- **Coleção `recomendacoes`**: persistida por `RecomendacaoFirestoreDatasource`; modelo `RecomendacaoModel` inclui `analiseId`, `cultura`, necessidade de calagem, `prnt`, `doseCalcario`, `p2o5`, `k2o` e `createdAt`. Todos os campos são obrigatórios (sem nullables). Timestamp tratado via `FieldValue.serverTimestamp` + `TimestampConverter`.
- **Relacionamento**: `RecomendacaoModel.analiseId` referencia `AnaliseModel.id`, estabelecendo relação 1:n de análises → recomendações.

10. **Fluxo de Dados**

- **Autenticação**: `LoginPage` → `loginController` → `authDatasource` → `FirebaseAuth` → `FlutterSecureStorage`. O estado (`AsyncValue`) ativa snackbars e navegação.
- **Cadastro**: coletado em 3 etapas; `CadastroController.registrar` comunica `FirebaseAuth.createUserWithEmailAndPassword` e atualiza `displayName` do usuário.
- **Recuperação de senha**: `RecuperarSenhaController.enviarLink` apenas simula atraso (`Future.delayed`). O estado controla `linkEnviadoProvider`.
- **Análises**: o botão “+ Nova Análise” abre o formulário; `AnaliseFormController` guarda os dados digitados em um mapa (`state`); `updateValue` recalcula `ctc` e `v` em tempo real; `captureLocation` invoca `LocationService` → geolocalização.
- **Recomendações**: embora o caso de uso `CalcularRecomendacaoUseCase` esteja disponível, ele não é invocado na UI atualmente (não há serviço que crie `AnaliseModel` nem persista `RecomendacaoModel`). Quando usado, recebe uma `AnaliseModel` e retorna `RecomendacaoModel` preenchido.
- **Banco**: os datasources `analiseFirestoreDatasource` e `recomendacaoFirestoreDatasource` expõem métodos `add`, `update`, `get` e `list`, mas nenhuma controller (por enquanto) os consome diretamente; a estrutura sugere que futuras implementações chamarão essas funções a partir de `AnaliseFormPage`/Lab.

11. **Componentes Reutilizáveis**

- **Widgets estilizados** (`lib/core/widgets`): `AppButton` (primário, secundário, texto), `AppCard`, `AppDropdown` (com listas de estados, culturas, perfis e profundidades), `AppInput` (textual/númerico/textarea) e `NutrienteCard` (accordion com animações). Todos usam `AppTheme`, `AppColors` e `AppTextStyles`.
- **Tema** (`lib/core/theme`): `AppTheme.light` (Material 3), `AppColors` para paleta iOS, `AppTextStyles` e `AppDimens` (spacing tokens). O arquivo `AppTheme` também define `AppSpacing` e `AppDimens` para bordas, alturas e espaçamentos reutilizáveis.
- **Constantes**: `lib/core/constants/app_routes.dart`, `app_strings.dart` centralizam strings e nomes de rota.
- **Utilitários**: `LocationService` e `AppRoutes`/`AppStrings` são consumidos por múltiplas páginas.

12. **Pontos Críticos do Sistema**

- **Inicialização do App**: `main.dart` chama `Firebase.initializeApp`, que precisa de `firebase_options.dart` configurado para a plataforma ativa; qualquer falha bloqueia toda a UI.
- **Autenticação**: o `redirect` do `GoRouter` depende de `auth_token` em `FlutterSecureStorage`. Se o token for removido mas o user ainda estiver logado no Firebase, o usuário ainda é enviado ao login — o fluxo força reautenticação.
- **Navegação principal**: `MainPage` e `GoRouter` compartilham rotas; cada aba é um `GoRoute` filho do `ShellRoute`, mantendo o estado de cada tela.
- **Captura de localização**: `LocationService` precisa de permissões (verifica `Geolocator.isLocationServiceEnabled` e `requestPermission`). Se o usuário negar, `AnaliseFormPage` exibe apenas o botão (sem fallback). A conversão em nome de município/estado ocorre via `geocoding.plaсemarkFromCoordinates` e pode falhar silenciosamente.
- **Sincronização de dados**: apesar do datasource oferecer `add`, `update` e `delete`, nenhuma página atualmente chama essas funções (ex.: o formulário de análise não salva em Firestore), tornando o fluxo de persistência incompleto.

13. **Mapa Geral do Sistema**

```
App (MaterialApp.router)
└─ ProviderScope (Riverpod)
   ├─ routerProvider ➜ GoRouter
   │  └─ ShellRoute (MainPage com NavigationBar)
   │     ├─ /analise ➜ AnalisePage (lista + botão)
   │     ├─ /lab ➜ LabPage (Calibração/Recomendação)
   │     ├─ /historico ➜ HistoricoPage (mock)
   │     └─ /config ➜ ConfigPage (links para base de dados/feedback)
   └─ outros providers (locationService, controllers, datasources)

Serviços externos + dados
├─ Firebase Auth (AuthDatasource)
├─ Firebase Firestore (AnaliseFirestoreDatasource, RecomendacaoFirestoreDatasource)
├─ Flutter Secure Storage (auth_token)
├─ Geolocator/Geocoding (LocationService)
└─ CalcularRecomendacaoUseCase (domains/formulas)
```

14. **Observações Técnicas**

- **Padrões**: uso consistente de `HookConsumerWidget` + Riverpod para UI reativas; controllers baseados em `AsyncNotifier` manipulam loading/erro; `AppTheme` centraliza tokens visuais.
- **Inconsistências**: o diretório `lib/presentation/config/perfil` existe mas não contém arquivos/navegação, portanto detalhes de edição de perfil estão "Não identificado no código"; `Lab` apresenta placeholders (`Center(Text('...'))`), o caso de uso `CalcularRecomendacaoUseCase` não é injetado em nenhuma UI e as coleções Firestore nunca são consumidas. O fluxo de `recomendacao` e o uso das datasources Firestore faltam implementação.
- **Dependências ociosas**: `dio` e `hive_flutter` aparecem em `pubspec.yaml`/`pubspec.lock` mas não são importadas em nenhum `.dart`, sugerindo preparo para integrações futuras.
- **Testes**: há testes unitários para as fórmulas (`test/domain/formulas/...`) e para o login controller (`test/presentation/login_controller_test.dart`), mas nenhuma cobertura de UI ou datasources.
