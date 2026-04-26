-- Fase 5 P1 - KPIs de 5 minutos
-- Ajuste os identificadores de projeto/dataset antes de aplicar.
-- Fonte esperada: `${PROJECT_ID}.${DATASET}.events_raw`

-- Janela base de 5 minutos
WITH base_5m AS (
  SELECT
    TIMESTAMP_TRUNC(TIMESTAMP(timestampUtc), MINUTE, 5) AS window_start,
    eventName,
    labId,
    appVersion,
    platform,
    environment,
    SAFE_CAST(durationMs AS INT64) AS duration_ms,
    errorCode,
    operationId,
    batchId,
    idempotencyKeyHash
  FROM `${PROJECT_ID}.${DATASET}.events_raw`
  WHERE eventName IN (
    'import_started',
    'import_completed',
    'import_failed',
    'save_started',
    'save_committed',
    'save_failed',
    'save_compensated',
    'save_idempotent_replay'
  )
)

-- KPI principal por janela/lab/plataforma/versão
SELECT
  window_start,
  COALESCE(labId, 'unknown') AS labId,
  appVersion,
  platform,
  environment,
  COUNTIF(eventName = 'import_started') AS import_started_count,
  COUNTIF(eventName = 'import_completed') AS import_completed_count,
  COUNTIF(eventName = 'import_failed') AS import_failed_count,
  SAFE_DIVIDE(
    COUNTIF(eventName = 'import_completed'),
    NULLIF(COUNTIF(eventName = 'import_started'), 0)
  ) AS taxa_importacao_sucesso,
  SAFE_DIVIDE(
    COUNTIF(eventName = 'import_failed'),
    NULLIF(COUNTIF(eventName = 'import_started'), 0)
  ) AS erro_por_laboratorio,
  COUNTIF(eventName = 'save_started') AS save_started_count,
  COUNTIF(eventName = 'save_committed') AS save_committed_count,
  COUNTIF(eventName = 'save_failed') AS save_failed_count,
  COUNTIF(eventName = 'save_compensated') AS save_compensated_count,
  COUNTIF(eventName = 'save_idempotent_replay') AS save_idempotent_replay_count,
  APPROX_QUANTILES(IF(eventName = 'save_committed', duration_ms, NULL), 100)[OFFSET(50)] AS save_duration_ms_p50,
  APPROX_QUANTILES(IF(eventName = 'save_committed', duration_ms, NULL), 100)[OFFSET(95)] AS save_duration_ms_p95,
  APPROX_QUANTILES(IF(eventName = 'save_committed', duration_ms, NULL), 100)[OFFSET(99)] AS save_duration_ms_p99,
  ARRAY_AGG(DISTINCT operationId IGNORE NULLS LIMIT 5) AS sample_operation_ids
FROM base_5m
GROUP BY window_start, labId, appVersion, platform, environment
ORDER BY window_start DESC;
