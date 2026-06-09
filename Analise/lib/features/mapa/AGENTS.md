# Agente Feature Mapa

## Escopo

Use para mapa, pins, camadas, filtros geograficos e visualizacao espacial.

## Regras

- O motor esperado e `flutter_map + latlong2`; nao trocar por Google Maps sem decisao explicita.
- Separe estado de filtro/camada da renderizacao do mapa.
- Evite recalcular markers pesados a cada build; use providers/seletores/cache quando aplicavel.
- Dados geograficos devem tratar coordenadas ausentes ou invalidas de forma visivel e nao fatal.
- Nao altere dados, textos, campos ou arquivos que nao tenham sido citados no prompt ou no pedido atual.

## Conclusao

Use sempre o checklist final obrigatorio do agente mestre.
