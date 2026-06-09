# Agente Data

## Escopo

Use para datasources, models, repositories concretos, templates de laboratorio, parsers de PDF e serializacao.

## Regras

- Repositories concretos implementam contratos do `domain`; nao deixe UI acessar datasource diretamente.
- Parsers devem preservar dados ausentes como ausencia/warning, nao inventar valor silenciosamente salvo regra documentada.
- Profundidade padrao para PDF sem profundidade: `0-20` cm.
- Template Sellar converte K por `k_mgdm3 / 391`.
- Diferencie erro de parsing, dado ausente e formato desconhecido.
- Ao alterar parser, rode teste especifico do laboratorio/template quando existir.
- Nao altere dados, textos, campos ou arquivos que nao tenham sido citados no prompt ou no pedido atual.

## Performance

- Parsing grande nao deve bloquear UI; mantenha servicos desacoplados para permitir isolate/compute.
- Evite multiplas leituras repetidas do mesmo arquivo/dado quando um cache local simples resolver.

## Conclusao

Use sempre o checklist final obrigatorio do agente mestre.
