# Runbook Operacional — Alertas P1 Nova Análise

## Payload mínimo esperado no alerta

- `window`
- `labId` (quando aplicável)
- `errorCode` dominante
- `sampleOperationIds` (até 5)

## Playbook por alerta

1. `import_success_drop`
- Verificar painel Saúde Geral (24h/7d).
- Abrir Diagnóstico por Lab e identificar laboratório dominante.
- Inspecionar `errorCode` dominante e trilha por `operationId`.

2. `lab_error_spike`
- Filtrar `labId` afetado.
- Correlacionar versão (`appVersion`) e plataforma.
- Revisar etapa de falha (`extract/detect/parse/validate`).

3. `save_latency_high`
- Verificar p95 e p99 de `save_duration_ms`.
- Correlacionar com `save_compensated` e `save_failed`.
- Escalar para owner de persistência se duração > 30 min.

4. `save_compensation_high`
- Abrir operação por `batchId` e `operationId`.
- Confirmar convergência para estado terminal (`committed`/`compensated`).
- Se crescimento contínuo, ativar mitigação operacional e on-call.

## SLA operacional

- TTA (triagem): <= 10 min
- Diagnóstico inicial: <= 20 min
- Comunicação no canal operacional: <= 30 min
