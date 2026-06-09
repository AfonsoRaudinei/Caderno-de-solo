# Agente Feature Historico

## Escopo

Use para listagem, filtros, detalhe historico e remocao/consulta de registros anteriores.

## Regras

- Confirme fonte de dados antes de alterar: mock, repository local, Firestore ou Hive.
- Exclusao deve ser explicita e testada; nao remova dados por efeito colateral de filtro/navegacao.
- Listas devem usar builders e estado granular.
- Preserve ordenacao e filtros esperados pelo usuario.
- Nao altere dados, textos, campos ou arquivos que nao tenham sido citados no prompt ou no pedido atual.

## Conclusao

Use sempre o checklist final obrigatorio do agente mestre.
