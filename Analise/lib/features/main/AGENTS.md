# Agente Feature Main

## Escopo

Use para shell principal, abas, composicao de navegacao e estrutura geral de telas autenticadas.

## Regras

- Mudancas aqui podem afetar todo o app; revise rotas em `core/router` quando necessario.
- Nao coloque regra de negocio em shell/abas.
- Preserve estado de abas quando a arquitetura usa shell/indexed stack.
- Evite rebuild global por estado local de uma aba.
- Nao altere dados, textos, campos ou arquivos que nao tenham sido citados no prompt ou no pedido atual.

## Conclusao

Use sempre o checklist final obrigatorio do agente mestre.
