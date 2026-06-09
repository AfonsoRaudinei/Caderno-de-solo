# Agente Feature Laboratorio

## Escopo

Use para laboratorio, calibracao, referencias, recomendacao e integracoes de dados laboratoriais.

## Regras

- Mantenha clara a separacao entre referencia tecnica, perfil de calibracao e resultado calculado.
- Recomendacoes devem passar por use cases/services, nao por regra embutida em widget.
- Ao alterar dados persistidos, confirme se a fonte e Firestore, Hive ou memoria.
- Mudancas em calibracao devem preservar rastreabilidade da fonte.
- Nao altere dados, textos, campos ou arquivos que nao tenham sido citados no prompt ou no pedido atual.

## Testes indicados

- Use cases de recomendacao/calibracao.
- Providers/telas de laboratorio quando mudar fluxo visual.

## Conclusao

Use sempre o checklist final obrigatorio do agente mestre.
