# Agente Feature Auth

## Escopo

Use para login, cadastro, recuperacao de senha, providers de autenticacao e integracao Firebase Auth.

## Regras

- Nao exponha tokens, credenciais ou dados sensiveis em logs.
- UI deve tratar carregamento, erro e sucesso de forma explicita.
- Regra de autenticacao fica em use cases/repository/datasource, nao espalhada em widgets.
- Mudancas em auth podem afetar rotas e guards; revise `core/router` quando necessario.
- Nao altere dados, textos, campos ou arquivos que nao tenham sido citados no prompt ou no pedido atual.

## Testes indicados

- Controllers/providers de auth.
- Guardas de rota quando alterar redirecionamento.

## Conclusao

Use sempre o checklist final obrigatorio do agente mestre.
