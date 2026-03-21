# 🚀 Ordem de Execução — SoloForte Flutter/Dart

> Prompts prontos para usar no IDX com Gemini/Claude.  
> Baseado no padrão visual já construído no SoloForte (imagens de referência).  
> Execute **um prompt por vez**. Valide antes de avançar.

---

## 📋 Visão Geral da Ordem

```
FASE 1 — Fundação          (Prompts 1 a 3)
FASE 2 — Autenticação      (Prompts 4 a 6)
FASE 3 — Core do App       (Prompts 7 a 10)
FASE 4 — Firebase          (Prompts 11 a 12)
FASE 5 — Finalização       (Prompts 13 a 14)
```

## 📌 Status Atual (sincronizado com `docs/10_ROADMAP.md`)

> Atualizado em 2026-03-18

| Prompt | Status | Nota |
| --- | --- | --- |
| 1 | ✅ | Concluído |
| 2 | ✅ | Concluído |
| 3 | ✅ | Concluído |
| 4 | ✅ | Concluído |
| 5 | ✅ | Concluído |
| 6 | ✅ | Concluído |
| 7 | ✅ | Bottom nav com 4 abas alinhada |
| 8 | ✅ | Lab com 2 tabs (Calibração e Recomendação) |
| 9 | 🔄 | Fluxo v2 do formulário ainda pendente no caminho principal |
| 10 | ✅ | Concluído |
| 11 | 🔄 | Integração Firestore requer validação E2E e regras |
| 12 | 🔄 | Localização integrada, faltando validação operacional final |
| 13 | ✅ | Concluído |
| 14 | ✅ | Concluído |

---

## FASE 1 — FUNDAÇÃO

---

### PROMPT 1 — Estrutura do Projeto

```
Crie um projeto Flutter chamado "soloforte" com Clean Architecture.

Estrutura de pastas:
lib/
├── core/
│   ├── theme/
│   ├── constants/
│   ├── utils/
│   └── widgets/
├── data/
│   ├── models/
│   ├── datasources/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   ├── usecases/
│   └── formulas/
└── presentation/
    ├── auth/
    ├── analise/
    ├── lab/
    ├── historico/
    └── config/

Configure o pubspec.yaml com:
- go_router: ^13.0.0
- flutter_riverpod: ^2.5.0
- riverpod_annotation: ^2.3.0
- freezed_annotation: ^2.4.0
- json_annotation: ^4.9.0
- dio: ^5.4.0
- hive_flutter: ^1.1.0
- flutter_secure_storage: ^9.0.0
- cupertino_icons: ^1.0.8
- flutter_animate: ^4.5.0
- flutter_hooks: ^0.20.0
- intl: ^0.19.0
- uuid: ^4.3.0
- geolocator: ^11.0.0
- geocoding: ^3.0.0
- firebase_core: ^2.27.0
- cloud_firestore: ^4.17.0
- firebase_auth: ^4.20.0

Dev: build_runner, freezed, json_serializable, riverpod_generator, flutter_lints, mocktail

Crie também o analysis_options.yaml com flutter_lints.
Não crie nenhuma tela ainda.
```

---

### PROMPT 2 — Tema e Design System iOS

```
Crie o Design System completo do SoloForte em:
lib/core/theme/

Arquivos:
1. app_colors.dart — Paleta completa:
   - primary: #007AFF (Azul iOS)
   - primaryDark: #0051D5
   - bgPrimary: #FFFFFF
   - bgSecondary: #F5F5F7
   - textPrimary: #1D1D1F
   - textSecond: #86868B
   - textTertiary: #C7C7CC
   - success: #34C759
   - error: #FF3B30
   - bgSuccess: #E8F5E9
   - bgError: #FFEBEE
   - border: #D1D1D6
   - borderSoft: #E5E5E7
   - Nutrientes: calcario #5AC8FA, gesso #FFCC00, potassio #FF9500,
     fosforo #FF3B30, enxofre #34C759, micronut #AF52DE

2. app_text_styles.dart — Hierarquia:
   - sectionLabel: 12px, w500, letterSpacing 0.5, cor textSecond
   - body: 15px, w400
   - label: 14px, w500
   - value: 17px, w600
   - headline: 22px, w700
   - caption: 12px, w400, cor textSecond

3. app_theme.dart — ThemeData:
   - Material 3
   - Fonte: system (-apple-system / SF Pro)
   - NavigationBar estilo iOS Tab Bar
   - InputDecoration padrão com borda #D1D1D6, radius 8px
   - Focus: borda #007AFF + boxShadow rgba(0,122,255,0.1)
   - ElevatedButton: gradiente #007AFF → #0051D5, radius 12px

Filosofia: iOS/Apple — minimalismo, dados em destaque, sem elementos desnecessários.
```

---

### PROMPT 3 — Widgets Base Reutilizáveis

```
Crie os widgets base em lib/core/widgets/:

1. app_button.dart
   - AppButton: botão primário com gradiente #007AFF → #0051D5
   - AppButtonSecondary: fundo #E5E5E7, texto #86868B
   - Parâmetros: label, onPressed, isLoading (mostra CircularProgressIndicator)
   - Animação: transition 200ms, translateY(-1px) no tap

2. app_card.dart
   - AppCard: container com:
     background: rgba(255,255,255,0.95)
     borderRadius: 12px
     boxShadow: 0 1px 3px rgba(0,0,0,0.08), 0 2px 8px rgba(0,0,0,0.04)
     padding: 20px

3. app_input.dart
   - AppInput: TextField estilizado iOS
   - Parâmetros: label, hint, controller, keyboardType, obscureText,
     maxLength (padrão 7 para campos numéricos), suffixIcon, errorText
   - Validação inline: erro em vermelho #FF3B30 abaixo do campo

4. app_dropdown.dart
   - AppDropdown<T>: DropdownButton estilizado
   - Borda #D1D1D6, radius 8px, seta customizada
   - Usar para seleções com 3+ opções (compacto)

5. nutriente_card.dart
   - Card expansível (accordion) para cada nutriente
   - Cor da borda lateral baseada no nutriente (calcário=azul, gesso=amarelo etc)
   - Estado: expandido / recolhido com animação suave

Todos os widgets devem ser StatelessWidget com parâmetros claros e documentação ///.
```

---

## FASE 2 — AUTENTICAÇÃO

---

### PROMPT 4 — Tela de Login

```
Crie a tela de Login em lib/presentation/auth/login/

Visual baseado nas imagens do SoloForte:
- Logo centralizado no topo (ícone + "SoloForte" + "Simples. Poderoso. Teu.")
- Segmented control: [Login | Cadastro] — ao clicar em Cadastro navega para /cadastro
- Card branco com:
  - Campo Email (AppInput)
  - Campo Senha (AppInput, obscureText, toggle visibilidade com ícone 👁)
  - Link "Recuperar senha" → /recuperar-senha
- Botão "Entrar" (AppButton primário, largura total)
- Background: gradiente #F5F5F7 → #E5E5E7

Arquivos:
- login_page.dart — UI
- login_controller.dart — Riverpod StateNotifier
  - Estados: idle, loading, error(String), success
  - Modo desenvolvimento: qualquer email/senha válidos = acesso (banner amarelo informativo)

Validações:
- Email: formato válido
- Senha: mínimo 6 caracteres
- Erro: toast/snackbar vermelho discreto

Navegação:
- Sucesso → /home (tab Análise)
- Token salvo em flutter_secure_storage
```

---

### PROMPT 5 — Cadastro em 3 Etapas

```
Crie a tela de Cadastro em lib/presentation/auth/cadastro/

Visual baseado nas imagens do SoloForte — stepper no topo com 3 etapas:
● 1 Conta (ativo/azul) — ○ 2 Perfil — ○ 3 Fazenda
Linha conectora entre os círculos

ETAPA 1 — Conta (Dados de acesso):
- Nome completo (AppInput, obrigatório)
- Email (AppInput, obrigatório)
- Senha (AppInput, obscureText) + Confirmar senha (lado a lado)
- Indicador de força da senha (barra colorizada):
  - Critérios: ✓/✗ Mínimo 8 chars, Letra maiúscula, Letra minúscula, Número
  - Verde quando todos ok
- Botão "Próximo" (direita)

ETAPA 2 — Perfil (Localização):
- Tipo de Perfil (AppDropdown): Produtor / Consultor / Administrador
- Estado (AppDropdown): todos os 27 estados brasileiros (siglas)
- Foto de Perfil (opcional): preview circular + botão "Escolher foto"
  - Formatos: JPG, PNG, WEBP. Máximo 5MB
- Botão "Próximo"

ETAPA 3 — Fazenda (Detalhes):
- Nome da Empresa (AppInput, obrigatório)
- Logo da Empresa (opcional): preview + botão "Escolher logo"
  - Formatos: JPG, PNG, WEBP, SVG. Máximo 5MB
- Card de confirmação (fundo verde claro #E8F5E9):
  ✓ "Confira seus dados antes de finalizar"
  Lista: Nome, Email, Tipo, Localização, Empresa, Foto, Logo
- Botão "Finalizar Cadastro"

Arquivos:
- cadastro_page.dart
- cadastro_controller.dart — Riverpod, gerencia etapa atual e dados
```

---

### PROMPT 6 — Recuperar Senha

```
Crie a tela de Recuperar Senha em lib/presentation/auth/recuperar_senha/

Visual baseado nas imagens do SoloForte:
- Logo SoloForte centralizado (igual ao login)
- Subtítulo: "Gestão Agrícola Inteligente"
- Card branco centralizado:
  - Ícone envelope azul (#007AFF) com fundo azul claro, radius 12px
  - Título: "Recuperar senha" (bold)
  - Subtítulo: "Digite seu email para receber as instruções de redefinição"
  - Campo Email (AppInput)
  - Botão "Enviar link de redefinição" (AppButton, largura total)
- Após envio: card de confirmação verde com mensagem de sucesso
- Link "Voltar ao login" no rodapé

Arquivo:
- recuperar_senha_page.dart
- Estado: idle / loading / success / error
```

---

## FASE 3 — CORE DO APP

---

### PROMPT 7 — Navegação Principal (Bottom Nav)

```
Crie a estrutura de navegação principal em lib/presentation/

1. main_page.dart — Scaffold com NavigationBar (Material 3):
   4 tabs:
   - Índice 0: ícone science_outlined → label "Análise" → AnalisePage
   - Índice 1: ícone biotech_outlined → label "Lab" → LabPage
   - Índice 2: ícone history_outlined → label "Histórico" → HistoricoPage
   - Índice 3: ícone settings_outlined → label "Config" → ConfigPage

   Visual:
   - backgroundColor: Colors.white
   - indicatorColor: #007AFF com opacity 0.1
   - Selecionado: azul #007AFF
   - Não selecionado: #86868B

2. Configure go_router em lib/core/constants/app_router.dart:
   Rotas:
   - /login
   - /cadastro
   - /recuperar-senha
   - /home (ShellRoute com MainPage)
     - /home/analise
     - /home/lab
     - /home/historico
     - /home/config
   
   Guard de autenticação:
   - Se não logado → redireciona para /login
   - Se logado → redireciona para /home/analise

3. main.dart:
   - ProviderScope (Riverpod)
   - MaterialApp.router com go_router
   - Tema: AppTheme.light()
   - Locale: pt_BR
```

---

### PROMPT 8 — Tela Lab (Calibração + Recomendação)

```
Crie a tela Lab em lib/presentation/lab/

lab_page.dart — Container com TabBar interna no topo:
- Tab 0: "Calibração"
- Tab 1: "Recomendação"
- labelColor: #007AFF
- indicatorColor: #007AFF
- indicatorSize: TabBarIndicatorSize.label
- Swipe horizontal entre as tabs (TabBarView)

CALIBRAÇÃO (lib/presentation/lab/calibracao/calibracao_page.dart):
ListView com NutrienteCard expansível para cada nutriente.
Ordem visual (Fósforo e Enxofre próximos, Enxofre e Gesso próximos):

1. Calcário 🪨 (cor borda: #5AC8FA)
   - Método: Dropdown [IAC, Embrapa, SMP, V%]
   - pH alvo: AppInput numérico (max 7 dígitos)
   - PRNT (%): AppInput numérico (max 7 dígitos)
   - Referência técnica: Dropdown (Base de Dados)

2. Gesso 💎 (cor borda: #FFCC00)
   - Método: Dropdown [Embrapa, IAC, Percentual argila]
   - Teor Ca no gesso (%): AppInput numérico (max 7 dígitos)
   - Referência técnica: Dropdown

3. Fósforo 🔴 (cor borda: #FF3B30)
   - Extrator: Dropdown [Mehlich-1, Resina, Mehlich-3]
   - Classe de solo: Dropdown [Arenoso, Médio, Argiloso]
   - Nível crítico (mg/dm³): AppInput numérico (max 7 dígitos)
   - Referência técnica: Dropdown

4. Enxofre 🟢 (cor borda: #34C759) — logo abaixo de Fósforo e Gesso
   - Nível crítico (mg/dm³): AppInput numérico (max 7 dígitos)
   - Fonte: Dropdown [Gesso, Sulfato de amônio, Outro]
   - Referência técnica: Dropdown

5. Potássio ⚡ (cor borda: #FF9500)
   - Nível crítico (mmolc/dm³): AppInput numérico (max 7 dígitos)
   - % K na CTC alvo: AppInput numérico (max 7 dígitos)
   - Referência técnica: Dropdown

6. Micronutrientes 🔬 (cor borda: #AF52DE)
   - Sub-cards para B, Cu, Fe, Mn, Zn
   - Nível crítico + Extrator para cada

Botão "Salvar Calibração" fixo no rodapé.
Dropdown "Perfis salvos" no topo para carregar calibração anterior.

RECOMENDAÇÃO (lib/presentation/lab/recomendacao/recomendacao_page.dart):
- Atualiza automaticamente via Riverpod ao mudar calibração
- Um AppCard por nutriente com:
  - Nome do nutriente + resultado (ex: 2,5 t/ha)
  - Método utilizado
  - Números sobrescritos de referência (clicáveis → modal)
- Seção "Referências" ao final listando as fontes
- Botão "Salvar Recomendação"
```

---

### PROMPT 9 — Tela Análise de Solo

```
Crie a tela de Análise em lib/presentation/analise/

analise_page.dart:
- AppBar: "Análise de Solo" + ícone de chat (comentário)
- Botão "+ Nova Análise" (AppButton, azul, largura total)
- Filtros abaixo:
  - Período: dois campos de data lado a lado
  - Fazenda: AppDropdown
  - Talhão: AppDropdown
  - Lab.: AppDropdown
  - Busca: AppInput texto

analise_form_page.dart — Formulário em seções com AppCard por seção:

SEÇÃO 1 — Identificação:
- Nome da área/talhão: AppInput
- Cultura: AppDropdown [Soja, Milho, Algodão, Cana, Café, Pastagem, Outro]
- Data da coleta: DatePicker estilo iOS
- Laboratório: AppInput (opcional)

SEÇÃO 2 — Localização:
- Botão "📍 Usar localização atual" → captura GPS via geolocator
- Exibe: Lat / Long / Precisão / Município (reverse geocoding automático)
- Descrição da área: AppInput (ex: "Talhão 3 - norte")

SEÇÃO 3 — Dados Físicos:
- Textura/Argila (%): AppDropdown ou AppInput numérico (max 7 dígitos)
- Profundidade: AppDropdown [0-20cm, 0-40cm]

SEÇÃO 4 — pH e Tampão:
- pH em água: AppInput numérico (max 7 dígitos)
- pH SMP: AppInput numérico (max 7 dígitos)
- pH CaCl₂: AppInput numérico (max 7 dígitos)

SEÇÃO 5 — Macronutrientes:
Grid 2 colunas:
- Fósforo P (mg/dm³), Potássio K (mmolc/dm³)
- Cálcio Ca (mmolc/dm³), Magnésio Mg (mmolc/dm³)
- Enxofre S (mg/dm³)
Todos AppInput numérico max 7 dígitos

SEÇÃO 6 — Acidez e CTC:
- Alumínio Al (mmolc/dm³): AppInput numérico (max 7 dígitos)
- H+Al (mmolc/dm³): AppInput numérico (max 7 dígitos)
- CTC: calculado automaticamente (exibir somente leitura, destaque azul)
- V% Saturação de bases: calculado automaticamente (destaque)

SEÇÃO 7 — Micronutrientes (expansível, recolhido por padrão):
- B, Cu, Fe, Mn, Zn — todos AppInput numérico max 7 dígitos

Botões no rodapé:
- "Calcular" → gera recomendação → navega para Lab > Recomendação
- "Salvar Rascunho" (AppButtonSecondary)
```

---

### PROMPT 10 — Histórico e Configurações

```
Crie as telas restantes:

HISTÓRICO (lib/presentation/historico/historico_page.dart):
- Lista de análises com AppCard compacto por item:
  - Título: nome da área
  - Subtítulo: cultura + data formatada pt-BR
  - Badge status: "Rascunho" (cinza) / "Completo" (verde)
  - Swipe left → excluir (com dialog de confirmação)
  - Tap → abrir análise completa
- Filtros no topo: data, cultura, área (igual à tela Análise)
- Estado vazio: ilustração + "Nenhuma análise encontrada"

CONFIGURAÇÕES (lib/presentation/config/config_page.dart):
Seções com ListTile estilo iOS Ajustes:

PERFIL:
- Avatar circular + nome + email
- ListTile: Nome, Email (leitura), Tipo de perfil, Empresa
- ListTile: "Alterar senha" → modal

BASE DE DADOS (lib/presentation/config/base_dados/):
- Lista de referências técnicas com CRUD completo
- AppCard por referência: nome + tipo + ano
- FAB "+" para adicionar nova referência
- Formulário de referência:
  - Nome: AppInput
  - Tipo: AppDropdown [Boletim, Tese, Artigo, Embrapa, IAC, Outro]
  - Autor(es): AppInput
  - Ano: AppInput numérico (max 4 dígitos)
  - Fórmula associada: AppDropdown [Calcário, Gesso, P, K, S, Micro]
  - Descrição: TextArea
  - Link/DOI: AppInput (opcional)

FEEDBACK (lib/presentation/config/feedback/):
- Tipo: AppDropdown [Bug, Sugestão, Elogio, Outro]
- Mensagem: TextArea
- Switch: "Permitir contato"
- Botão "Enviar"
- Confirmação visual após envio
```

---

## FASE 4 — FIREBASE

---

### PROMPT 11 — Firebase Auth + Firestore

```
Configure Firebase no projeto SoloForte:

1. Crie lib/firebase_options.dart (estrutura base — será substituído pelo flutterfire configure)

2. Inicialize Firebase no main.dart:
   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

3. Crie lib/data/datasources/remote/auth_datasource.dart:
   - signInWithEmailAndPassword
   - createUserWithEmailAndPassword
   - sendPasswordResetEmail
   - signOut
   - authStateChanges (Stream<User?>)
   - Salvar token em flutter_secure_storage

4. Crie lib/data/datasources/remote/analise_firestore_datasource.dart:
   Coleção: /analises
   - criarAnalise(Analise analise) → Future<String> (retorna ID)
   - atualizarAnalise(String id, Analise analise) → Future<void>
   - excluirAnalise(String id) → Future<void>
   - streamAnalisesPorUsuario(String uid) → Stream<List<Analise>>
   - buscarAnalisePorId(String id) → Future<Analise>

5. Crie lib/data/datasources/remote/recomendacao_firestore_datasource.dart:
   Coleção: /recomendacoes
   - salvarRecomendacao(Recomendacao rec) → Future<String>
   - streamRecomendacoesPorUsuario(String uid) → Stream<List<Recomendacao>>

6. Models com json_serializable (freezed):
   - AnaliseModel (todos os campos do documento 06)
   - RecomendacaoModel
   - UsuarioModel

Regras Firestore (firestore.rules):
allow read, write: if request.auth.uid == resource.data.usuarioId;
```

---

### PROMPT 12 — Localização GPS

```
Implemente a captura de localização em lib/core/utils/location_service.dart:

LocationService:
- requestPermission() → Future<bool>
  Solicita permissão de localização (iOS + Android)
  
- getCurrentLocation() → Future<LocationData>
  Retorna: latitude, longitude, accuracy (metros)
  Timeout: 10 segundos
  
- reverseGeocode(double lat, double lng) → Future<LocationAddress>
  Retorna: municipio, estado, enderecoCompleto
  Usar package geocoding

LocationData (freezed):
  latitude: double
  longitude: double
  accuracy: double
  municipio: String
  estado: String
  descricao: String (preenchido manualmente pelo usuário)

Integrar no analise_form_page.dart:
- Botão "📍 Usar localização atual":
  1. Solicitar permissão se necessário
  2. Loading no botão durante captura
  3. Preencher campos automaticamente
  4. Exibir: "Porto Nacional, TO · ±5m"
  5. Erro: dialog com opção de digitar manualmente
```

---

## FASE 5 — FINALIZAÇÃO

---

### PROMPT 13 — Testes e Qualidade

```
Crie testes unitários para as regras de negócio críticas:

test/domain/formulas/
- calcario_formula_test.dart
  Testar: método SMP, método V%, método IAC
  Cenários: pH abaixo do ideal, pH no ideal, PRNT variável

- fosforo_formula_test.dart
  Testar: extrator Mehlich-1, nível crítico por classe de argila

- potassio_formula_test.dart
  Testar: % K na CTC, nível crítico

test/domain/usecases/
- calcular_recomendacao_usecase_test.dart
  Testar: análise completa → recomendação correta
  Usar mocktail para mockar repositories

test/presentation/
- login_controller_test.dart
  Testar: login válido, email inválido, senha curta, loading state

Execute: flutter test
Meta: cobertura nos módulos críticos (fórmulas + auth)
```

---

### PROMPT 14 — Build e TestFlight

```
Prepare o projeto para distribuição iOS via TestFlight:

1. Atualize ios/Runner/Info.plist com permissões:
   - NSLocationWhenInUseUsageDescription:
     "O SoloForte usa sua localização para registrar o ponto de coleta."
   - NSLocationAlwaysAndWhenInUseUsageDescription: (mesmo texto)
   - NSCameraUsageDescription:
     "Para fotografar a área de coleta e documentar a análise."

2. Crie codemagic.yaml na raiz (para build sem Mac):
   - workflow: ios-testflight
   - instance_type: mac_mini_m1
   - flutter: stable
   - Scripts: pub get → build_runner → flutter build ios → xcode archive
   - Publishing: app_store_connect com submit_to_testflight: true
   - Variáveis: APP_STORE_CONNECT_PRIVATE_KEY, KEY_IDENTIFIER, ISSUER_ID

3. Verifique pubspec.yaml:
   version: 1.0.0+1
   (incrementar build number a cada upload TestFlight)

4. Execute checklist final:
   flutter clean
   flutter pub get
   dart run build_runner build --delete-conflicting-outputs
   flutter analyze (zero erros)
   flutter test (todos passando)
   flutter build ios --release (se tiver Mac)
```

---

## ✅ Checklist Geral de Validação

Após cada prompt, valide:

```
PROMPT 1:  [ ] Estrutura de pastas criada  [ ] flutter pub get sem erros
PROMPT 2:  [ ] Tema aplicado  [ ] Cores corretas no preview
PROMPT 3:  [ ] Widgets renderizam  [ ] Props funcionam
PROMPT 4:  [ ] Login funciona  [ ] Banner dev mode aparece
PROMPT 5:  [ ] Stepper avança entre etapas  [ ] Validações ativas
PROMPT 6:  [ ] Email enviado  [ ] Tela de confirmação aparece
PROMPT 7:  [ ] 4 tabs navegam  [ ] Guard de auth funciona
PROMPT 8:  [ ] Swipe entre Calibração e Recomendação  [ ] Cards expandem
PROMPT 9:  [ ] GPS captura localização  [ ] CTC calcula automaticamente
PROMPT 10: [ ] CRUD Base de Dados funciona  [ ] Swipe delete no histórico
PROMPT 11: [ ] Dados salvam no Firestore  [ ] Stream atualiza a UI
PROMPT 12: [ ] Permissão GPS solicitada  [ ] Reverse geocoding retorna cidade
PROMPT 13: [ ] flutter test passa  [ ] flutter analyze zero erros
PROMPT 14: [ ] codemagic.yaml válido  [ ] Info.plist com permissões
```

---

## 📌 Dicas de Uso no IDX

- **Um prompt por sessão** — não acumule prompts
- **Valide o preview** antes de avançar
- **Se travar:** descreva o erro + cole o stack trace no próximo prompt
- **Referência visual:** as imagens do SoloForte (IMG_3161 a IMG_3171) mostram o padrão esperado
- **Documentos de apoio:** consulte os .md deste projeto conforme necessário

---

*Versão 1.0 — 14 prompts — SoloForte Flutter/Dart*
