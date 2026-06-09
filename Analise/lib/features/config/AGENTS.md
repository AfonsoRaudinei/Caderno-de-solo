# Agente Feature Config

## Escopo

Use para configuracoes, perfil, feedback, base de dados e preferencias do usuario.

## Regras

- Configuracoes persistidas precisam declarar fonte da verdade: Firestore, Hive ou memoria.
- Nao misture regra agronomica com tela de configuracao; referencias tecnicas devem ficar em dados/servicos apropriados.
- Feedback e perfil devem tratar erro de rede e estado vazio.
- Nao altere dados, textos, campos ou arquivos que nao tenham sido citados no prompt ou no pedido atual.

## Conclusao

Use sempre o checklist final obrigatorio do agente mestre.
