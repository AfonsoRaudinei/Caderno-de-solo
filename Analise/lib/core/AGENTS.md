# Agente Core

## Escopo

Use para tema, rotas, constantes, services compartilhados, utilitarios e widgets reutilizaveis.

## Regras

- `core` nao deve depender de feature especifica.
- Componentes compartilhados precisam ser genericos e configuraveis.
- Mudancas em tema, rotas e widgets base tem alto impacto; rode analise e teste de navegacao/widget quando possivel.
- Nao coloque regra agronomica, parsing de PDF ou acesso direto a Firestore em widgets de `core`.
- Prefira tokens existentes: `AppColors`, `AppTextStyles`, `AppDimens`.
- Nao altere dados, textos, campos ou arquivos que nao tenham sido citados no prompt ou no pedido atual.

## Conclusao

Use sempre o checklist final obrigatorio do agente mestre.
