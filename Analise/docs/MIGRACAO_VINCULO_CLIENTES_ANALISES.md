# Migração — Vínculo Clientes ↔ Análises

> Etapas 2–6 da unificação hierárquica Cliente → Fazenda → Talhão → Análises.

## Campos adicionados em `analises/{id}`

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| `clienteId` | `string` | Não | FK para `clientes/{clienteId}` |
| `fazendaId` | `string` | Não | FK para subcoleção `fazendas` |
| `talhaoId` | `string` | Não | FK para subcoleção `talhoes` |
| `vinculoStatus` | `string` | Não | `manual`, `inferido` ou `pendente` |

Os campos legados `produtor`, `fazenda` e `talhao` **permanecem** para retrocompatibilidade, exibição e App Mapa.

## Estratégia de migração

1. **Registros antigos:** nunca apagados. Leitura funciona sem FKs.
2. **Reparo lazy:** `AnaliseNotifier.repararVinculosLegados()` infere vínculos por nome quando Cliente/Fazenda/Talhão existem no cadastro.
3. **Status `pendente`:** gravado quando não há correspondência; a análise continua visível na aba Análise.
4. **`cliente.analiseIds`:** atualizado via `FieldValue.arrayUnion` após vínculo inferido ou manual.
5. **Importação PDF (Etapa 3):** `showHierarquiaSelecaoSheet` exige Cliente → Propriedade → Talhão antes do save; `AplicarHierarquiaAnalisesUsecase` grava FKs com `vinculoStatus: manual`; `registrarVinculosPosSalvar` sincroniza `analiseIds`.
6. **IDs preservados:** nenhum documento é recriado; apenas `update` com campos novos.
7. **Migração em massa (Etapa 6):** `AnaliseNotifier.executarMigracaoVinculosLegados()` — job opcional acionado em Config → Sincronização de dados; infere FKs e marca `pendente` quando não há match; sincroniza `analiseIds`.

## Migração em massa (Etapa 6)

| Modo | Quando roda | Marca `pendente` |
| --- | --- | --- |
| **Lazy** | Lista de análises / aba Análises do cliente | Não |
| **Massa** | Config → “Vincular análises legadas” (confirmação) | Sim |

Use case: `MigrarVinculosLegadosUsecase` (planejamento) + persistência no `AnaliseNotifier`.

Resultado exposto em `MigracaoVinculosResult`: total, já vinculadas, reparadas, pendentes, falhas.

## Índices Firestore recomendados

Criar no console Firebase (Composite indexes):

```
Collection: analises
Fields: userId ASC, clienteId ASC, dataCadastro DESC

Collection: analises
Fields: userId ASC, talhaoId ASC, safra DESC
```

Queries atuais por `userId` continuam funcionando sem índice adicional.

## UI — Detalhe do cliente (Etapa 4)

`ClienteDetailScreen` organizada em abas:

| Aba | Conteúdo |
| --- | --- |
| Resumo | Dados do cliente, QR token, contadores |
| Propriedades | CRUD de fazendas (expandível) |
| Talhões | Lista plana de todos os talhões |
| Análises | `analisesPorClienteProvider` + badge de vínculo pendente |
| Recomendações | `recomendacoesPorClienteProvider` via `analiseIds` das análises filtradas |

## Rotas go_router (Etapa 5)

Toda navegação Cliente → Fazenda → Talhão usa `go_router` (sem `MaterialPageRoute`).

| Rota | Tela |
| --- | --- |
| `/clientes/:id` | Detalhe (`?tab=` opcional: propriedades, talhoes, recomendacoes) |
| `/clientes/:id/analises` | Detalhe na aba Análises |
| `/clientes/:id/fazenda/nova` | Nova propriedade |
| `/clientes/:id/fazenda/:fazendaId/editar` | Editar propriedade |
| `/clientes/:id/fazenda/:fazendaId/talhao/novo` | Novo talhão |
| `/clientes/:id/fazenda/:fazendaId/talhao/:talhaoId/editar` | Editar talhão |

Helpers: `AppRoutes.clienteAnalisesPath`, `fazendaEditarPath`, `talhaoEditarPath`, `clienteDetalheComAbaPath`.

## Fallback de leitura

- FK ausente → UI usa `produtor` / `fazenda` / `talhao` (strings).
- FK parcial → tratar como não vinculado; exibir badge "Vínculo pendente" na aba Análises do detalhe do cliente (Etapa 4).
