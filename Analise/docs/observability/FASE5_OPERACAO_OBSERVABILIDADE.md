# Fase 5 (P1): Operação e Observabilidade - Nova Análise

## Objetivo
Garantir diagnóstico rápido em produção para os fluxos de importação e salvamento da Nova Análise (modelo em colunas A1, A2...).

## Contrato de Telemetria
- Versão: `1.0.0` (`telemetryVersion`)
- Campos obrigatórios em todos os eventos:
  - `eventName`
  - `timestampUtc`
  - `operationId`
  - `sessionId`
  - `appVersion`
  - `platform`
  - `environment`
- Campos contextuais suportados:
  - `labId`
  - `columnCount`
  - `batchId`
  - `idempotencyKeyHash`
  - `status`
  - `errorCode`
  - `durationMs`
  - `confidence`

## Eventos de Importação
- `import_started`
- `import_extract_finished`
- `import_detect_finished`
- `import_parse_finished`
- `import_validate_finished`
- `import_fallback_opened`
- `import_fallback_selected_lab`
- `import_completed`
- `import_failed`

## Eventos de Salvar
- `save_started`
- `save_validation_blocked`
- `save_persisting`
- `save_committed`
- `save_failed`
- `save_compensated`
- `save_idempotent_replay`

## LGPD / Segurança
- Campos com PII (`produtor`, `fazenda`, `talhao`, `propriedade`, `proprietario`, `municipio`) são removidos antes de emitir telemetria.
- `idempotencyKey` não é emitida em claro; apenas `idempotencyKeyHash`.

## Métricas Operacionais (KPIs)
- `taxa_importacao_sucesso = import_completed / import_started`
- `erro_por_laboratorio = import_failed(labId) / import_started(labId)`
- `tempo_salvar_p50/p95/p99` a partir de `durationMs` em eventos `save_committed`
- Complementares:
  - `% fallback manual` (`import_fallback_opened / import_started`)
  - `% compensação` (`save_compensated / save_started`)
  - `% replay idempotente` (`save_idempotent_replay / save_started`)

## Dashboard Mínimo (produção)
1. Saúde geral (24h/7d):
   - Taxa de importação
   - Taxa de falha total
   - `save_duration_ms` p95
2. Diagnóstico por laboratório:
   - Ranking de `import_failed` por `labId`
   - Top `errorCode`
   - Distribuição de `confidence` e fallback
3. Persistência:
   - `save_committed`, `save_failed`, `save_compensated`, `save_idempotent_replay`
   - Drilldown por `operationId` e `batchId`

## Alertas P1
- `taxa_importacao_sucesso < 95%` por 15 min
- `erro_por_laboratorio > 10%` por 30 min
- `save_p95 > 3s` por 30 min
- `save_compensated > 1%` por 30 min

Payload mínimo do alerta:
- `window`
- `labId` (quando aplicável)
- `errorCode` dominante
- `sampleOperationIds` (até 5)

## Runbook Curto
1. Abrir painel "Diagnóstico por laboratório" e identificar `labId` com maior falha.
2. Filtrar por `errorCode` dominante.
3. Abrir eventos por `operationId` para reconstruir trilha (`import_*` ou `save_*`).
4. Se `save_compensated` subir: validar datasource ativo e latência de persistência.
5. Se `import_fallback_opened` subir: revisar regras de detecção desse laboratório.

## Implementação no Repositório (P1)
- Sink remoto HTTP configurável no app:
  - `ANALISE_TELEMETRY_ENDPOINT`
  - `ANALISE_TELEMETRY_API_KEY` (opcional)
- Fallback local com `debugPrint` mantido para desenvolvimento.
- Provider central:
  - `lib/features/analise/application/providers/analise_telemetry_provider.dart`
- Contrato/sanitização:
  - `lib/features/analise/application/observability/analise_telemetry.dart`

## Artefatos Operacionais Versionados
- Decisão de stack e owners:
  - `docs/observability/STACK_OPERACIONAL_D0.md`
- SQL de KPIs 5 min:
  - `infra/observability/bigquery/kpi_5min.sql`
- Políticas de alerta:
  - `infra/observability/cloud_monitoring/alert_policies.yaml`
- Runbook operacional:
  - `docs/observability/runbook/RUNBOOK_ALERTAS_P1.md`
- Pacote de evidências:
  - `docs/observability/evidencias/producao_p1_2026-04-13/`

## Gate de Observabilidade
- Script: `tool/observability_gate.sh`
- Valida:
  - contrato de eventos e presença de sink remoto
  - artefatos operacionais obrigatórios
  - testes críticos de telemetria
  - rastreabilidade mínima (`operationId`, `batchId`, `errorCode`, `durationMs`)
- Modo estrito opcional para release de produção:
  - `OBSERVABILITY_REQUIRE_PRODUCTION_EVIDENCE=true`
  - bloqueia se ainda houver placeholders no pacote de evidências.
