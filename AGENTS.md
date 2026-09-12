# Agente Mestre — Caderno de Solo

## Recomendacao

Use um modelo hibrido:

- Este arquivo e a fonte global de verdade para qualquer trabalho no repositorio.
- `Analise/AGENTS.md` define as regras do app Flutter/Dart.
- `AGENTS.md` em subpastas de camada ou feature adiciona apenas contexto local.

Nao crie um agente gigante para todos os modulos. Ele fica dificil de manter e faz o agente carregar contexto irrelevante. Tambem nao duplique todas as regras em cada modulo. Instrucao duplicada gera conflito e desatualiza rapido.

## Regra de entrada

Antes de alterar qualquer coisa:

1. Identifique se o pedido e pergunta, auditoria, implementacao ou correcao.
2. Localize os arquivos reais com `rg --files` ou `find`.
3. Leia os arquivos tocados antes de propor ou editar.
4. Declare o escopo operacional: arquivos permitidos, camada afetada e o que fica fora.
5. Preserve alteracoes locais que nao foram feitas por voce.
6. Nao altere dados, textos, campos ou arquivos que nao tenham sido citados no prompt ou no pedido atual.

## Agentes locais

- `.agents/flutter-code-reviewer.md`: revisor senior Flutter/Dart para parecer tecnico. Use quando o pedido mencionar agente revisor, revisao de codigo ou validacao tecnica das mudancas.

## Raiz do app

O projeto Flutter fica em `Analise/`, nao na raiz do repositorio.

Comandos de qualidade devem rodar a partir de `Analise/`, salvo quando o pedido for sobre documentacao da raiz:

```bash
flutter analyze
flutter test
dart format .
```

## Diretrizes Flutter/Dart

- Siga Clean Architecture: UI chama controller/provider, controller chama use case, use case chama repository, repository chama datasource.
- `domain/` deve continuar puro Dart sempre que possivel.
- Widgets nao fazem parsing, regra agronomica, Firestore direto ou operacao pesada.
- Use Riverpod de forma granular; evite providers globais para estado efemero de tela.
- Prefira `const`, imutabilidade, builders para listas longas e `select`/providers especificos para reduzir rebuild.
- Nao coloque trabalho pesado no `build`; parsing grande deve ir para service/usecase/isolate quando necessario.
- Formate e analise antes de concluir quando houver edicao de codigo.

## Perfil De Trabalho

- Atue como engenheiro sênior Flutter/Dart com rigor de produto e performance.
- Trate o contexto agronomico com o mesmo nivel de exigencia de um especialista, usando referencias tecnicas fortes e verificaveis.
- Quando o pedido for sobre referencias, tabelas agronomicas ou absorcao de nutrientes, siga o agente especifico do modulo de referencias antes de propor alteracoes.

## Regras de negocio inviolaveis

- Campos ausentes em analise viram warning visual, nao bloqueio fatal de salvamento.
- Profundidade padrao quando o PDF nao informar: `0-20` cm.
- Conversao de K em templates Sellar: `k_mgdm3 / 391`.
- Formulas agronomicas ficam em dominio/use cases/services, nunca embutidas em tela.
- Metodos agronomicos devem ser tipados por enum/value object, nao comparados por label de UI.
- Nao trocar `flutter_map + latlong2` por Google Maps sem decisao explicita.
- Persistencia local padrao do projeto e Hive; nao introduzir SQLite sem decisao explicita.
- **Modulos de produto core** (nao remover em branches paralelas sem merge de volta):
  `clientes`, `analise`, `laboratorio`, `mapa`, `config`, `main`, `auth`.
- Em especial, `lib/features/clientes/` + rota `/clientes` + aba Clientes no `MainPage`
  sao obrigatorios. O gate `tool/product_modules_guard.sh` bloqueia release se sumirem.

## Padrao de conclusao obrigatorio

Toda resposta final de servico deve terminar com:

```text
Checklist de conclusao:
- [ ] Escopo atendido
- [ ] Arquivos alterados revisados
- [ ] Qualidade verificada ou limitacao declarada
- [ ] Riscos/pendencias informados

Conclusao: servico concluido.
```

Marque com `[x]` apenas o que foi realmente cumprido. Se algo nao foi executado, mantenha `[ ]` e explique a limitacao antes da conclusao.

## Cursor Cloud specific instructions

Contexto duravel para agentes rodando neste ambiente de nuvem. O toolchain (Flutter
3.44.9 stable + Android SDK) ja vem instalado no snapshot; o startup script roda
apenas `flutter pub get` em `Analise/`. Nao reinstale dependencias aqui.

- **Raiz do app**: todos os comandos Flutter rodam de `Analise/` (nao da raiz do repo).
- **Toolchain**: `flutter`/`dart` estao no PATH (symlinks em `/usr/local/bin` -> `/opt/flutter`).
  Android SDK em `~/android-sdk` (`ANDROID_SDK_ROOT` no `~/.bashrc`). `flutter doctor`
  fica verde para Flutter, Android e Chrome.
- **Lint/test/build** (de `Analise/`): `flutter analyze`, `flutter test`,
  `flutter build apk --debug`. O gate de CI e `./tool/quality_gate.sh` (roda guard de
  modulos + analyze + um subconjunto alvo de testes + coverage). Veja
  `Analise/.github/workflows/quality-gate.yml`.
- **Nao ha modo mock/offline em runtime**: `AppConfig.useFirestore` e sempre `true`.
  O app exige o projeto Firebase real (`soloforte-106c8`) + login + verificacao de
  e-mail para chegar as telas de produto (clientes/analise). Fluxos autenticados na
  GUI precisam de credenciais de teste + config do App Check.
- **Firebase por plataforma**: iOS tem chaves reais em `firebase_options.dart`.
  Android usa placeholders (`TODO_ANDROID_API_KEY`) e nao ha `android/app/google-services.json`.
  Web e macOS lancam `UnsupportedError` de proposito.
- **Rodar a GUI nao e viavel neste ambiente**: iOS exige macOS; Web/Linux desktop nao
  sao suportados pelo `firebase_options.dart`; e o emulador Android **nao inicializa**
  aqui (kernel convidado nao executa sob a virtualizacao aninhada, mesmo com `/dev/kvm`
  presente — a VM fica `offline`). Valide mudancas via `flutter test` (widget/integration
  headless renderizam as telas reais) e `flutter build apk --debug`.
- **Suite completa vs CI**: com Flutter 3.44.9, ~14 testes de regressao de UI falham por
  uma assertion de debug do framework (`ListTile background color ... may be invisible`).
  O `quality_gate.sh` roda um subconjunto alvo que passa; a suite completa nao e o gate.
- **Gate pre-existente**: `./tool/quality_gate.sh` para no passo 2 por um import
  cross-feature ja commitado (`recomendacao_screen.dart` importa `config_controller.dart`).
  Isso e questao de codigo da branch, nao do ambiente.
