# Agente Domain

## Escopo

Use para entidades, value objects, contratos, formulas, guards, mappers, services puros e use cases.

## Regras

- `domain` deve evitar imports de Flutter, UI, Firebase, Hive ou packages de infraestrutura.
- Formulas agronomicas devem ser deterministicas, testaveis e cobertas por testes unitarios.
- Prefira tipos explicitos, enums e value objects a `String`/`double?` soltos para conceitos de negocio.
- Nao mude formulas sem registrar premissas, entradas, saidas e testes afetados.
- Ao corrigir calculo, inclua caso de teste com valores de referencia.
- Nao altere dados, textos, campos ou arquivos que nao tenham sido citados no prompt ou no pedido atual.

## Performance

- Evite recomputar formulas pesadas em loops de UI; exponha use cases claros para cache/controladores quando necessario.
- Mantenha funcoes puras sempre que possivel.

## Conclusao

Use sempre o checklist final obrigatorio do agente mestre.
