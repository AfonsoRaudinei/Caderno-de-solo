# 11 — Plano de Auditoria por Blocos e Agentes de Manutenção (SoloForte)

> **Status:** 🔄 plano definido; 6 agentes permanentes configurados; blocos 1–6 ainda ⬜.
> **Ambiente de execução:** Cursor (Composer / Agent mode), usando o mesmo padrão `.cursor/rules/*.mdc` já validado em `RELATORIO_BLACKMODE_AUDITORIA.md`.
> **Escopo:** somente orientação e configuração de agentes. Nenhum código Dart é gerado por este documento — cada bloco descreve *o que* auditar, *como* configurar o agente no Cursor e *qual* relatório ele deve produzir.
> **Atualizado em:** 2026-08-25

---

## 0. Achado imediato (cruzamento dos docs 00–10 com o relatório de auditoria mais recente)

Ao ler os 11 documentos do projeto em conjunto, apareceu uma divergência que deve ser o primeiro item tratado pelo Bloco 4:

| Documento | O que diz existir na navegação/telas |
| --- | --- |
| `04_SCREENS_SPEC.md` | 4 abas (Análise, Lab, Histórico, Config) + Culturas por rota dedicada. |
| `02_FOLDER_STRUCTURE.md` | `presentation/` com auth, analise, lab, historico, config, culturas. |
| `RELATORIO_BLACKMODE_AUDITORIA.md` (08/08/2026, mais recente) | Código real já contém módulos **Clientes** (`clientes_page`, `clientes_list_screen`, `cliente_detail_screen`, `cliente_form_screen`, `fazenda_form_screen`, `talhao_form_screen`) e **Mapa** (`mapa_page.dart`, `flutter_map_engine.dart`), além de citar Agenda/Carteira/Clima como módulos **mencionados em uma skill mas inexistentes no repositório**. |

Diagnóstico Fase 1 (2026-08-25) confirma o mesmo no código: bottom nav = **Clientes, Lab, Mapa, Config** (`Analise/lib/features/main/presentation/main_page.dart`).

Ou seja: `02_FOLDER_STRUCTURE.md` e `04_SCREENS_SPEC.md` estão desatualizados em relação ao código atual. Isso é tratado como item de abertura do Bloco 4 (Presentation) e deve gerar atualização desses dois documentos ao final da auditoria — não apenas um relatório novo.

---

## 1. Objetivo

Estabelecer uma auditoria completa do SoloForte por **camada de arquitetura** (não por risco pontual), produzindo um relatório por bloco no padrão já usado em `RELATORIO_BLACKMODE_AUDITORIA.md`, e deixar configurados **6 agentes permanentes** no Cursor para que a manutenção do projeto deixe de depender de auditorias avulsas e passe a ter dono por área.

Dois produtos distintos saem deste plano:

1. **Auditoria única, sequencial, por camada** (Blocos 1 a 6) — executada uma vez para levantar o estado atual real do código frente aos docs `00`–`10`.
2. **6 agentes permanentes** (`.cursor/rules/agente-*.mdc`) — ativos depois da auditoria, cada um dono de uma fatia do projeto, para revisões contínuas em cada PR/branch.

---

## 2. Mecânica geral no Cursor

O projeto já tem o padrão certo: `RELATORIO_BLACKMODE_AUDITORIA.md` cita o contrato `.cursor/rules/soloforte-blackmode.mdc` v1.0. Este plano estende o mesmo padrão.

**Passo a passo genérico para qualquer bloco ou agente deste plano:**

1. Criar o arquivo de regra em `.cursor/rules/<nome>.mdc` com front-matter (`description`, `globs`, `alwaysApply`) seguido do prompt/persona em Markdown.
2. Abrir uma sessão nova de **Composer/Agent** no Cursor (não Ask — Agent mode tem acesso a múltiplos arquivos e pode navegar a árvore).
3. No primeiro turno, referenciar a regra com `@` (ou deixar `alwaysApply: true`/`globs` fazer o match automático) e os documentos-base relevantes: `@00_PROJECT_INDEX.md @09_ERRORS_AND_RISKS.md @10_ROADMAP.md` mais o(s) doc(s) específico(s) do bloco.
4. Pedir explicitamente **modo leitura**: "audite, não corrija — liste achados com arquivo:linha e severidade". Isso replica a metodologia "Auditoria read-only" que já funcionou no Modo Black.
5. O agente entrega um relatório `docs/RELATORIO_AUDITORIA_<BLOCO>.md` seguindo o template da seção 3.6.
6. Correções de código só entram em uma **segunda sessão**, separada, após o relatório ser revisado por você — nunca no mesmo turno da auditoria.
7. Ao fechar um bloco, atualizar `09_ERRORS_AND_RISKS.md` (novos riscos) e `10_ROADMAP.md` (status de fase) — isso mantém os dois documentos "vivos" como o projeto já exige.

**Regra de ouro para todos os agentes:** nunca abrir uma PR/commit de correção sem o relatório de auditoria correspondente já revisado. Auditoria e correção são sessões diferentes.

---

## 3. Blocos de auditoria — varredura completa por camada

Ordem sequencial única (execução de ponta a ponta uma vez). Cada bloco roda em uma sessão de Agent isolada, escopada à pasta indicada, para não misturar contexto.

### Bloco 1 — CORE

- **Escopo:** `Analise/lib/core/` (theme, constants, router, widgets compartilhados: `AppButton`, `AppCard`, `AppInput`, `AppDropdown`, `NutrienteCard`, `NumFieldWidget`, `MapPreviewWidget`, `AppBottomTabBar`).
- **Referências:** `01_ARCHITECTURE.md`, `03_DESIGN_SYSTEM.md`, `RELATORIO_BLACKMODE_AUDITORIA.md` (seção "Infraestrutura de tema").
- **Checklist:**
  - `AppColors`/`AppTextStyles`/`AppDimens` batem com os tokens documentados em `03_DESIGN_SYSTEM.md` (inclusive paleta do Modo Black: `#0D0D0D`, `#1C1C1E`, `#242426`, `#1428A0`)?
  - Algum widget em `core/widgets/` ainda lê cor hardcoded em vez de `Theme.of(context)`/`context.appPalette`?
  - `AppInput`/`AppInputNumerico`/`NumFieldWidget` continuam garantindo o limite de 7 dígitos (`LengthLimitingTextInputFormatter(7)`) em 100% dos usos, sem exceção introduzida por feature nova?
  - `app_router.dart` reflete todas as rotas realmente usadas (inclusive Clientes/Mapa, ver Seção 0)?
  - Guard de autenticação (`FlutterSecureStorage` / `auth_token`) está centralizado ou duplicado em telas?
- **Entregável:** `docs/RELATORIO_AUDITORIA_CORE.md`.

### Bloco 2 — DOMAIN

- **Escopo:** `Analise/lib/domain/` (entities, models, usecases, formulas) + `Analise/test/domain/`.
- **Referências:** `01_ARCHITECTURE.md`, `08_AGRO_FORMULAS.md`, `09_ERRORS_AND_RISKS.md` (itens 5 — "Riscos introduzidos pela v2").
- **Checklist:**
  - `domain/` continua livre de imports Flutter (regra Clean Architecture do `01_ARCHITECTURE.md`)?
  - `FosforoData.valorParaCalculo` e o fallback resina/mehlich cobrem os 4 laboratórios (Exata Brasil, Sellar/Embrapa, MB Agronegócios, IBRA) sem regressão?
  - Ambiguidade do **K duplicado no laudo Exata** (item pendente do `09_ERRORS_AND_RISKS.md`) já tem regra oficial implementada, ou continua em aberto?
  - Granulometria em g/kg no `gesso_engine.dart`: conversão para `%` está correta ponta a ponta (`conversoes.dart`)?
  - Fatores de conversão (`pToP2O5=2.291`, `kMgDm3Factor=391`, `gessoEquivalenteGrama=86`, etc.) batem 1:1 com `08_AGRO_FORMULAS.md` — nenhuma constante diverge silenciosamente entre código e doc?
  - Todo usecase novo tem teste correspondente em `test/domain/formulas`?
- **Entregável:** `docs/RELATORIO_AUDITORIA_DOMAIN.md`.

### Bloco 3 — DATA

- **Escopo:** `Analise/lib/data/` (datasources local + Firestore, repositórios, `base_dados/`, `culturas_data.dart`) **e** datasources em `Analise/lib/features/*/data/`.
- **Referências:** `05_FIREBASE_CONFIG.md`, `09_ERRORS_AND_RISKS.md` (itens 2 e 3).
- **Checklist:**
  - `AnaliseLocalDatasource` (mock) e `AnaliseFirestoreDatasource` (real): qual é o provider ativo hoje, e isso está explícito em algum `AppConfig`/flag de ambiente, ou é implícito no código?
  - Estratégia mock↔Firestore por ambiente (pendência #4 do `09_ERRORS_AND_RISKS.md`) foi formalizada?
  - `firestore.rules` já existe no repositório? (Documento `05` afirma que **não** existia em 18/03/2026 — o arquivo está em `Analise/firestore.rules`; o Bloco 3 deve confirmar conteúdo vs doc.)
  - Coleções `analises`, `recomendacoes`, `users/{uid}/calibracoes` **e** `clientes` / `cliente_tokens` gravam timestamps de forma consistente?
  - Existe algum ponto de escrita que ainda usa schema v1 (campos planos) enquanto a UI já assume v2 (objetos aninhados, ex: `FosforoData`)? Esse é o risco mais crítico apontado no roadmap (fase 11).
  - Sincronização com o segundo app (App Mapa) — leitura da coleção `analises` por `usuarioId`/`status` continua compatível com o schema atual?
- **Entregável:** `docs/RELATORIO_AUDITORIA_DATA.md`.

### Bloco 4 — PRESENTATION (sub-blocos por feature, mesma sessão pode encadear)

- **Escopo e ordem sugerida** (cada um é curto, rode em sequência dentro do mesmo bloco):
  1. **Auth** (login, cadastro, recuperar senha) — Modo Black **pendente** aqui (design glass claro intencional, ver `RELATORIO_BLACKMODE_AUDITORIA.md` seção 4).
  2. **Análise** (`AnaliseFormPage` v2, 9 seções colapsáveis, 4 laboratórios).
  3. **Lab** (Calibração + Recomendação, `DefaultTabController(length: 2)`).
  4. **Histórico**.
  5. **Config** (Perfil, Base de Dados, Feedback, Modo Black switch, rota oculta `/config/calculos`).
  6. **Culturas** (rota dedicada + atalho no Lab).
  7. **Clientes e Mapa** — módulos existentes no código mas **ausentes** de `02_FOLDER_STRUCTURE.md` e `04_SCREENS_SPEC.md` (ver Seção 0). Auditar e, ao final, atualizar os dois documentos.
- **Referências:** `03_DESIGN_SYSTEM.md`, `04_SCREENS_SPEC.md`, `RELATORIO_BLACKMODE_AUDITORIA.md` (inventário completo de páginas/telas).
- **Checklist:**
  - Toda tela nova (Clientes, Mapa) segue os tokens de `03_DESIGN_SYSTEM.md` e o contrato Modo Black, ou foi criada fora do sistema de design?
  - `login_page.dart`, `cadastro_page.dart`, `recuperar_senha_page.dart`: status ainda é "glass claro pendente"? Decidir e documentar se isso é definitivo ou entra na fila de correção.
  - `potassio_card_widget.dart` / `fosforo_card_widget.dart`: texto branco em chip selecionado — migrar para `colorScheme.onPrimary` como sugerido no relatório anterior, ou manter?
  - `AnaliseFormPage` v2: os toggles de unidade (`% / g/kg`), seletor de fonte P (resina/mehlich) e bottom bar (`Salvar rascunho` / `Concluir análise`) estão 100% conectados à persistência final, ou ainda há mock no meio do fluxo (pendência #1 do roadmap)?
  - Módulos citados em skills antigas mas inexistentes (Agenda, Carteira, Clima, SideMenu) — confirmar que continuam fora de escopo e remover menções obsoletas de docs/skills, se houver.
- **Entregável:** `docs/RELATORIO_AUDITORIA_PRESENTATION.md` + atualização de `02_FOLDER_STRUCTURE.md` e `04_SCREENS_SPEC.md`.

### Bloco 5 — INFRA & BUILD

- **Escopo:** `Analise/pubspec.yaml`, `Analise/codemagic.yaml`, `build_ios.sh`, `Analise/ios/Runner/Info.plist`, `Analise/firebase.json`, `Analise/lib/firebase_options.dart`.
- **Referências:** `06_DEPENDENCIES.md`, `07_BUILD_DISTRIBUTION.md`, `05_FIREBASE_CONFIG.md` (seção "Operações sugeridas antes do deploy").
- **Checklist:**
  - Versões do `pubspec.yaml` ainda batem com a tabela do `06_DEPENDENCIES.md`, ou alguma dependência foi bumped sem atualizar o doc?
  - `firebase_options.dart`: Android/web/macos continuam com placeholders? Isso bloqueia build oficial multi-plataforma — confirmar se segue relevante (projeto parece iOS-first).
  - `Info.plist` tem as 3 strings de permissão exigidas (`NSLocationWhenInUseUsageDescription`, `NSLocationAlwaysAndWhenInUseUsageDescription`, `NSCameraUsageDescription`)?
  - `build_ios.sh` incrementa o build number corretamente e está sincronizado com o `version` declarado no `pubspec.yaml`?
  - Secrets do Codemagic (`APP_STORE_CONNECT_PRIVATE_KEY`, `KEY_IDENTIFIER`, `ISSUER_ID`, `FIREBASE_SERVICE_ACCOUNT`) — checklist de presença (sem expor valores).
  - `codemagic.yaml` inclui `flutter test test/presentation/calibracao/` antes do IPA?
- **Entregável:** `docs/RELATORIO_AUDITORIA_BUILD.md`.

### Bloco 6 — CONSOLIDAÇÃO & QA

- **Escopo:** `Analise/test/`, mais os 5 relatórios anteriores.
- **Referências:** todos os relatórios gerados nos Blocos 1–5, `09_ERRORS_AND_RISKS.md`, `10_ROADMAP.md`.
- **Checklist:**
  - `flutter analyze` sem erros e `flutter test` 100% verde (replicar o critério já usado no Modo Black: "4/4 passed").
  - Cobertura de teste do fluxo de formulário v2 e da camada de integração de dados (pendência explícita da fase 13 do roadmap).
  - Consolidar todos os achados novos dos Blocos 1–5 dentro de `09_ERRORS_AND_RISKS.md` (nova seção "7. Achados da auditoria por camada — 2026-08-25").
  - Atualizar `10_ROADMAP.md` com uma linha nova (fase 15 — "Auditoria por camadas") e status por bloco.
  - Decidir explicitamente o destino das pendências do Modo Black (auth glass, chips de potássio/fósforo, PDF generator, engine de mapa) — cada uma vira um item rastreável, não fica solta em um relatório antigo.
- **Entregável:** `docs/RELATORIO_AUDITORIA_CONSOLIDADO.md` + PRs de atualização em `09_ERRORS_AND_RISKS.md` e `10_ROADMAP.md`.

### Template de relatório (usar em todos os blocos)

Mesma estrutura do `RELATORIO_BLACKMODE_AUDITORIA.md`, que já funcionou bem:

```
# Relatório — Auditoria [Bloco]
Data / Contrato (.mdc usado) / Branch

## 1. Resumo executivo
## 2. Inventário de arquivos auditados (tabela: arquivo | módulo | status)
## 3. Achados (severidade: crítico / atenção / nota)
## 4. Arquivos que precisarão de correção (lista, sem corrigir ainda)
## 5. Verificação de qualidade (flutter analyze / flutter test)
## 6. Pendências para próxima iteração
```

---

## 4. Os 6 agentes permanentes (`.cursor/rules/agente-*.mdc`)

Local real das regras: **raiz do repositório** `.cursor/rules/` — o mesmo diretório de `soloforte-blackmode.mdc`. O Cursor aplica regras do workspace root, não de `Analise/.cursor/rules/` (essa pasta **não existia** no setup).

Globs usam o prefixo `Analise/` porque a raiz Flutter é `Analise/`, não a raiz do git.

### 4.1 `agente-arquitetura.mdc`

Guardião da Clean Architecture + Riverpod. Gatilho: PR/branch em `Analise/lib/core/`, `domain/` ou `data/`.

### 4.2 `agente-firebase.mdc`

Dono de Firestore/Auth e sincronização com o App Mapa. Gatilho: datasources remotos, schema, `firestore.rules`, `firebase_options.dart`.

### 4.3 `agente-design-system.mdc`

Guardião do Design System iOS e do contrato Modo Black. Gatilho: `presentation/`, `features/`, `core/theme/`, `core/widgets/`.

### 4.4 `agente-formulas.mdc`

Guardião das fórmulas agronômicas. Gatilho: `domain/formulas/`, `domain/usecases/`.

### 4.5 `agente-build-release.mdc`

Guardião do pipeline TestFlight e de `pubspec.yaml`. Gatilho: `pubspec.yaml`, `codemagic.yaml`, `build_ios.sh`, `Info.plist`.

### 4.6 `agente-qa-testes.mdc`

Guardião de testes e consolidação em `09`/`10`. Único com `alwaysApply: true`.

Persona completa de cada agente está no respectivo `.mdc`.

---

## 5. Fluxo de trabalho contínuo (depois da auditoria única)

1. Toda branch nova roda automaticamente sob o agente cujo `globs` casa com os arquivos tocados (Cursor aplica a regra por match de path).
2. Mudanças que cruzam camadas (ex: novo campo em `AnaliseModel` que afeta `domain`, `data` e `presentation`) disparam mais de um agente — rode cada um em uma sessão própria, não tente um agente genérico fazer os três papéis.
3. `agente-qa-testes` sempre fecha o ciclo antes do merge.
4. A cada 2–4 semanas (ou a cada release para TestFlight), repita os Blocos 1–6 da Seção 3 como auditoria de regressão completa, não apenas incremental.

---

## 6. Checklist prático de setup no Cursor

1. [x] Confirmar pasta `.cursor/rules/` na **raiz do repositório** (já existia com `soloforte-blackmode.mdc`). Não criar `Analise/.cursor/rules/` — o Cursor não carrega regras dali neste workspace.
2. [x] Criar os 6 arquivos da Seção 4 com front-matter e prompt.
3. [ ] Rodar o Bloco 1 (Core) em uma sessão de Agent **isolada**, modo leitura.
4. [ ] Repetir para os Blocos 2 a 6, nesta ordem, sempre em sessões separadas.
5. [ ] Ao final do Bloco 6, revisar e aprovar manualmente as atualizações propostas em `09_ERRORS_AND_RISKS.md`, `10_ROADMAP.md`, `02_FOLDER_STRUCTURE.md` e `04_SCREENS_SPEC.md`.
6. [x] A partir daqui, os 6 agentes permanentes ficam no repositório para PRs futuros, conforme Seção 5.

**Prompt sugerido para a próxima sessão (Bloco 1):**

```text
Audite o Bloco 1 — CORE conforme docs/11_AUDITORIA_AGENTES.md.
Modo leitura: não corrija código Dart.
Escopo: Analise/lib/core/
Referências: @docs/11_AUDITORIA_AGENTES.md @docs/01_ARCHITECTURE.md @docs/03_DESIGN_SYSTEM.md @docs/RELATORIO_BLACKMODE_AUDITORIA.md
Entregue docs/RELATORIO_AUDITORIA_CORE.md no template da seção 3.6.
```

---

## 7. Rastreamento

| Bloco/Agente | Status | Relatório / arquivo esperado |
| --- | --- | --- |
| Bloco 1 — Core | ⬜ pendente | `docs/RELATORIO_AUDITORIA_CORE.md` |
| Bloco 2 — Domain | ⬜ pendente | `docs/RELATORIO_AUDITORIA_DOMAIN.md` |
| Bloco 3 — Data | ⬜ pendente | `docs/RELATORIO_AUDITORIA_DATA.md` |
| Bloco 4 — Presentation | ⬜ pendente | `docs/RELATORIO_AUDITORIA_PRESENTATION.md` |
| Bloco 5 — Build | ⬜ pendente | `docs/RELATORIO_AUDITORIA_BUILD.md` |
| Bloco 6 — Consolidação | ⬜ pendente | `docs/RELATORIO_AUDITORIA_CONSOLIDADO.md` |
| Agente Arquitetura | ✅ configurado | `.cursor/rules/agente-arquitetura.mdc` |
| Agente Firebase | ✅ configurado | `.cursor/rules/agente-firebase.mdc` |
| Agente Design System | ✅ configurado | `.cursor/rules/agente-design-system.mdc` |
| Agente Fórmulas | ✅ configurado | `.cursor/rules/agente-formulas.mdc` |
| Agente Build & Release | ✅ configurado | `.cursor/rules/agente-build-release.mdc` |
| Agente QA & Testes | ✅ configurado | `.cursor/rules/agente-qa-testes.mdc` |
