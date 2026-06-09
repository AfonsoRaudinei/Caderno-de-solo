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
