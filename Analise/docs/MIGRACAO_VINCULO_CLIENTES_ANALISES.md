# Migração — Vínculo Clientes ↔ Análises

> Etapa 2 da unificação hierárquica Cliente → Fazenda → Talhão → Análises.

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
4. **`cliente.analiseIds`:** atualizado via `FieldValue.arrayUnion` após vínculo inferido ou manual (Etapa 3).
5. **IDs preservados:** nenhum documento é recriado; apenas `update` com campos novos.

## Índices Firestore recomendados

Criar no console Firebase (Composite indexes):

```
Collection: analises
Fields: userId ASC, clienteId ASC, dataCadastro DESC

Collection: analises
Fields: userId ASC, talhaoId ASC, safra DESC
```

Queries atuais por `userId` continuam funcionando sem índice adicional.

## Fallback de leitura

- FK ausente → UI usa `produtor` / `fazenda` / `talhao` (strings).
- FK parcial → tratar como não vinculado; exibir badge "Vínculo pendente" (Etapa 4).
