# Arquivo 65 - Mapa: Pins das Analises com Localizacao + Card no Clique

Data: 24/04/2026

## Objetivo

1. Permitir registrar `latitude`/`longitude` na analise (ja existia na tabela de Nova/Editar Analise).
2. Exibir no **Mapa** um **pin** para cada analise salva que possua localizacao.
3. Ao clicar (1 toque) no pin, mostrar um card com os dados principais da amostra/analise.
4. No detalhe da analise, o botao **Mapa** deve abrir a aba de mapa ja focando a analise selecionada.

## Escopo Executado

### Fonte dos pins

- Pins sao derivados da lista real de analises do app (Riverpod `analiseNotifierProvider`).
- Criterio: so entra no mapa se `latitude != null` e `longitude != null`.

Arquivo:
- `lib/features/mapa/providers/mapa_analise_provider.dart`

### Modelo de pin enriquecido

- `MapPin` passou a carregar tambem dados de exibicao (amostra, produtor, fazenda, cultura, safra, laboratorio, profundidade, descricao do local).

Arquivo:
- `lib/features/mapa/domain/map_engine.dart`

### Clique no pin + card de detalhes

- O engine `flutter_map` passou a renderizar markers com `onTap` (1 toque) e destaque visual do pin selecionado.
- A tela `MapaPage` mantem o estado do pin selecionado e exibe um card (overlay) com os dados.

Arquivos:
- `lib/features/mapa/data/flutter_map_engine.dart`
- `lib/features/mapa/presentation/mapa_page.dart`

### Abertura do mapa focando a analise

- A rota `AppRoutes.mapa` aceita `?analiseId=<id>` (query param).
- `MapaPage` recebe `initialAnaliseId` e, ao abrir, centraliza e abre o card do pin correspondente (se existir).
- No detalhe da analise, o botao **Mapa** navega para `'/mapa?analiseId=<id>'`.

Arquivos:
- `lib/core/router/app_router.dart`
- `lib/features/analise/presentation/screens/analise_detail_screen.dart`

## Checklist de Auditoria (Codigo)

### 1) Cadastro de localizacao

- Campo de localizacao existe na tabela de analise:
  - `GPS`, `latitude`, `longitude`, `descricaoLocal`.
  - Evidencia: `lib/features/analise/presentation/widgets/analise_table_widget.dart`.
- Captura GPS preenche latitude/longitude/descricao:
  - Evidencia: `lib/features/analise/presentation/controllers/nova_analise_controller.dart`.
- Salvar converte latitude/longitude para `double` na entidade:
  - Evidencia: `lib/features/analise/domain/models/analise_draft.dart`.

Status: OK

### 2) Pins no mapa

- Pins provenientes do provider de analises (nao datasource local isolado).
- Filtro por presenca de coordenadas.

Evidencia:
- `lib/features/mapa/providers/mapa_analise_provider.dart`

Status: OK

### 3) Clique no pin e card

- Marker com `onTap` chamando callback de pin.
- `MapaPage` exibe card com:
  - Talhao/titulo
  - Cultura, safra, profundidade
  - No amostra, produtor, fazenda, laboratorio, descricao do local
  - Coordenadas formatadas

Evidencia:
- `lib/features/mapa/data/flutter_map_engine.dart`
- `lib/features/mapa/presentation/mapa_page.dart`

Status: OK

### 4) "Mapa" no detalhe abre e foca a analise

- Detalhe da analise navega para `'/mapa?analiseId=<id>'`.
- Rota do mapa le query param e passa para `MapaPage`.

Evidencia:
- `lib/features/analise/presentation/screens/analise_detail_screen.dart`
- `lib/core/router/app_router.dart`

Status: OK

### 5) Qualidade minima

- `flutter analyze` executado nos arquivos-alvo do modulo de mapa e rotas.
- Resultado: sem erros (No issues found).

Status: OK

## Checklist de Homologacao (Manual, App Rodando)

Observacao: estes passos sao os que "fecham" 100% do ponto de vista de produto, porque validam comportamento em runtime.

1. Criar uma analise e capturar GPS (ou digitar lat/long).
2. Salvar e confirmar que a analise aparece na lista (sem crash).
3. Abrir a aba **Mapa**:
   - Confirmar que existe um pin na posicao capturada.
4. Tocar 1 vez no pin:
   - Confirmar que aparece o card com dados da amostra (sem precisar de duplo clique).
5. Abrir o detalhe da analise e tocar em **Mapa**:
   - Confirmar que abre o mapa ja centralizado e com o card do pin daquela analise.
6. Repetir com 2 analises diferentes (com coordenadas diferentes):
   - Confirmar que cada pin abre seu card correto.

Status: PENDENTE (execucao/print)

## Criterios de Conclusao "100%"

- OK Codigo implementado e analisado sem erros.
- OK Pins aparecem apenas quando ha coordenadas.
- OK Clique unico no pin mostra dados principais.
- OK Botao "Mapa" abre e foca a analise correta.
- PENDENTE Homologacao manual realizada e confirmada (passos acima).

## Proximas melhorias (opcionais)

- Ao tocar no card: "Abrir detalhe" (navegar para `AnaliseDetailScreen`).
- Agrupamento de pins (cluster) quando houver muitas analises.
- Filtro por safra/cultura/produtor no mapa.
