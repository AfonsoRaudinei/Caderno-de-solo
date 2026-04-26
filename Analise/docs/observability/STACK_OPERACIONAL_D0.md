# Stack Operacional D0 — Fase 5 (P1)

Data de decisão: 2026-04-06  
Escopo: Nova Análise (`import_*`, `save_*`)

## Decisão formal (única)

Stack aprovada para produção:
- Ingestão: coletor HTTPS de eventos estruturados (`ANALISE_TELEMETRY_ENDPOINT`)
- Logs: Google Cloud Logging
- Data warehouse: BigQuery
- Dashboard: Looker Studio
- Alertas: Cloud Monitoring Alert Policies
- Roteamento: Slack + PagerDuty + Email

## Owners

- Owner técnico (implementação): `@analise-platform`
- Owner operacional (NOC/SRE): `@analise-ops`
- Owner de produto (SLA/aceite): `@produto-analise`

## Responsabilidades por camada

- App Flutter:
  - emitir eventos `import_*` e `save_*`
  - anexar campos obrigatórios (`operationId`, `eventName`, `durationMs`, `labId`, `errorCode`)
- Coletor:
  - validar schema
  - rejeitar payload inválido (4xx)
  - escrever em Cloud Logging
- Plataforma dados:
  - materializar KPIs 5 min no BigQuery
  - manter consistência agregado vs bruto >= 99%
- Operação:
  - monitorar alertas
  - executar runbook
  - reportar incidente e MTTR

## Critério de pronto para produção

- Endpoint de ingestão configurado no build release.
- Dashboard publicado com URL única e permissão para o time.
- Alertas ativos com canal real (Slack/PagerDuty/Email).
- Fire-drill executado com diagnóstico <= 10 min.
