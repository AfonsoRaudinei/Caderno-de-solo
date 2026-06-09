# Agente Feature Analise

## Escopo

Use para cadastro, edicao, importacao, exibicao e recomendacao associada a analises de solo.

## Regras

- Salvamento nao deve ser bloqueado por campo quimico vazio; represente ausencia como warning visual.
- O unico bloqueio funcional aceitavel deve estar ligado a ausencia real de analise/amostra quando o fluxo exigir.
- UI nao calcula formula agronomica; chama controller/use case.
- Controllers mantem estado previsivel e nao invalidam a si mesmos durante `salvar`.
- Telas devem usar widgets/tokens compartilhados quando disponiveis.
- Nao altere dados, textos, campos ou arquivos que nao tenham sido citados no prompt ou no pedido atual.

## Testes indicados

- Controllers de nova analise.
- Use cases de recomendacao.
- Goldens/widget tests quando alterar layout sensivel.

## Conclusao

Use sempre o checklist final obrigatorio do agente mestre.
