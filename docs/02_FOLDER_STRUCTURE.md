# 02 — Estrutura de pastas do SoloForte

> **Status:** ✅ árvore documentada e explicada. O repo Flutter vive dentro da subpasta `Analise/`.

```text
/ (root do repositório)
├── Analise/                        # projeto Flutter no Google Project IDX
│   ├── android/                    # wrapper Android gerado pelo Flutter
│   ├── ios/                        # projeto Xcode / Runner + recursos Apple
│   ├── assets/                     # ícones, imagens e arquivos markdown utilizados pelo app
│   ├── build/                      # artefatos temporários (não comitar)
│   ├── codemagic.yaml             # workflow de CI/CD para TestFlight
│   ├── firebase.json              # mapeamento dos apps Firebase (iOS, Dart)
│   ├── lib/                        # código fonte principal
│   │   ├── core/                   # tema, constantes, widgets compartilhados e utilitários
│   │   ├── data/                   # models, datasources (local + Firestore) e repositórios
│   │   ├── domain/                 # entidades/formatos, use cases e fórmulas puras
│   │   ├── features/               # implementações granulares (analise, culturas, formulários)
│   │   └── presentation/           # telas (auth, main, lab, config, histórico, etc.)
│   ├── PROMPT/                    # biblioteca de referências técnicas em markdown + dados agrícolas
│   ├── pubspec.yaml               # dependências Flutter + assets
│   └── test/                       # testes unitários das fórmulas e controllers
├── docs/                           # esta pasta com documentação organizada per topic
├── 01_projeto_visao_geral.md       # documentação legada (avisar em 09_ERRORS_AND_RISKS)
├── ... (02_arquitetura.md, 03_dependencias.md etc.)
└── manual-flutter-dart.md          # guia complementar
```

## Detalhes por camada dentro de `Analise/lib`

- `core/`  
  - `theme/`: `AppTheme`, `AppColors`, `AppTextStyles`, tokens de espaçamento.  
  - `constants/`: `AppRoutes`, `AppStrings`, `Numeros` e helpers.  
  - `router/`: `app_router.dart` cuida da shell route com a `MainPage` (aba de navegação).  
  - `widgets/`: `AppButton`, `AppCard`, `AppInput`, `AppDropdown`, `NutrienteCard`, `NumFieldWidget`, `MapPreviewWidget`.

- `data/`  
  - `datasources/local`: `AnaliseLocalDatasource` (mock), `CalibracaoHiveDatasource`.  
  - `datasources/remote`: Firestore datasources (`analise`, `recomendacao`, `calibracao`), `AuthDatasource`.  
  - `base_dados/`: referências técnicas embarcadas, usadas pela tela de Config > Base de Dados.  
  - `culturas_data.dart`: dataset ESALQ + EMBRAPA para o módulo Culturas.

- `domain/`  
  - `entities/`: `AnaliseSolo`, `Produtor`, `AnaliseEntity`, `CalibracaoEntity`, `ResultadoGesso`.  
  - `models/`: `AnaliseModel`, `RecomendacaoModel` (freezed + json_serializable).  
  - `usecases/`: `CalcularRecomendacaoUseCase` centraliza fórmulas.  
  - `formulas/`: `calcario_formula.dart`, `gesso_engine.dart`, `fosforo_formula.dart`, `potassio_formula.dart`, `conversoes.dart`.

- `presentation/`  
  - `auth/`: login, cadastro e recuperar senha com Riverpod controllers.  
  - `analise/`: `AnaliseListScreen`, `NovaAnaliseScreen`, `AnaliseDetailScreen`, widgets de cards/filtros.  
  - `lab/`: `LabPage` (TabBar), `calibracao/` (perfil + cards de nutrientes), `recomendacao/` (mock + provider).  
  - `historico/`: lista com swipe-to-delete, mock data.  
  - `config/`: tela principal com seções de perfil, dados (Base de Dados, Feedback) e sistema.
  - `culturas/` (geralmente sob `features`): UI de seleção de autores, cultivares e tecnologias, com provider e widgets customizados.

## Observações extras

- Cada pasta de `presentation` pode gerar subnavegação (`GoRouter` → `ShellRoute` / `MainPage`).  
- O diretório `PROMPT/dados referencias/` guarda os md referenciados pela Base de Dados (vírgula, gesso, etc.).  
- Todo o fluxo de build/test passa por `codemagic.yaml` e o script local `build_ios.sh` documentado em `07_BUILD_DISTRIBUTION.md`.
