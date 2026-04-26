# Observability Infra (Fase 5 P1)

Este diretório contém artefatos versionados para operação real da Nova Análise.

## Estrutura

- `bigquery/kpi_5min.sql`
  - views/queries para KPIs oficiais de 5 minutos.
- `cloud_monitoring/alert_policies.yaml`
  - políticas de alerta com thresholds P1.

## Pipeline alvo

1. App envia eventos estruturados para `ANALISE_TELEMETRY_ENDPOINT`.
2. Coletor grava eventos em Cloud Logging.
3. Logs são exportados para BigQuery (`analise_observability.events_raw`).
4. Queries de 5 min materializam KPIs usados no dashboard.
5. Cloud Monitoring usa métricas para alertas operacionais.

## Deploy operacional (resumo)

1. Provisionar dataset BigQuery para observabilidade.
2. Configurar export/sink de logs para `events_raw`.
3. Aplicar SQL de KPIs em `bigquery/kpi_5min.sql`.
4. Importar políticas de alerta do YAML.
5. Publicar dashboard e registrar URL no pacote de evidências.
