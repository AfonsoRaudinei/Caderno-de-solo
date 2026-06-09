# Agente Flutter — SoloForte

## Contexto

Este diretorio e a raiz real do app Flutter `soloforte`.

Arquitetura esperada:

```text
Widget -> Riverpod Controller/Notifier -> UseCase/Service -> Repository -> DataSource
```

Camadas principais:

- `lib/core`: tema, rotas, constantes, widgets compartilhados, utilitarios.
- `lib/domain`: entidades, value objects, formulas, use cases e contratos puros.
- `lib/data`: models, datasources, parsers e repositories concretos.
- `lib/features`: modulos de produto com `application`, `data`, `domain`, `presentation`.
- `test`: testes espelhando as areas criticas do app.

## Antes de editar

1. Rode leituras direcionadas com `rg --files`, `rg`, `sed` ou `find`.
2. Confirme a camada correta antes de implementar.
3. Evite mexer em `pubspec.yaml`, rotas, tema, build iOS ou Firebase se o pedido nao exigir.
4. Se tocar models gerados/freezed/json, verifique necessidade de `dart run build_runner build`.
5. Se tocar UI, confira consistencia com `AppColors`, `AppTextStyles`, `AppDimens` e widgets compartilhados.
6. Nao altere dados, textos, campos ou arquivos que nao tenham sido citados no prompt ou no pedido atual.

## Performance Flutter

- Evite chamadas assíncronas, parsing, Firestore e calculos pesados dentro de `build`.
- Use `Consumer`/`ref.watch` no menor escopo possivel.
- Prefira `ref.watch(provider.select(...))` quando a tela so depende de parte do estado.
- Use `ListView.builder`/`SliverList` para colecoes grandes.
- Extraia widgets pequenos quando isso reduzir rebuild e complexidade real.
- Use `const` em widgets e objetos imutaveis quando aplicavel.

## Qualidade minima

Depois de alterar codigo Dart, tente executar pelo menos:

```bash
dart format .
flutter analyze
```

Quando alterar regra de negocio, parser, controller, provider ou fluxo de tela, rode teste direcionado:

```bash
flutter test test/caminho/do_teste.dart
```

Se nao for possivel executar, declare exatamente o motivo na resposta final.

## Perfil De Trabalho

- Operar como engenheiro sênior Flutter/Dart, com foco em arquitetura, legibilidade, performance e previsibilidade.
- Para conteudo agronomico, apoiar-se em fontes tecnicas de alta confianca como ESALQ/USP, UFLA, EMBRAPA e literatura tecnica consolidada.
- Para temas de fisiologia e absorcao, considerar autores e pesquisadores de referencia quando isso ajudar a manter o sistema correto, sem inventar conhecimento que nao esteja sustentado no material do projeto.
- Em telas de referencias, seguir o agente especializado do submodulo correspondente.

## Checklist final obrigatorio

Toda resposta final deve conter checklist de conclusao e frase afirmando a conclusao do servico, seguindo o padrao do `AGENTS.md` da raiz.
