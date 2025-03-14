CREATE OR REPLACE TABLE `{PROJECT_ID}.{PROCESSED_DATASET}.worker_reference` AS
SELECT 
    uuid,
    TIMESTAMP(CAST(year AS STRING) || '-' || 
             LPAD(CAST(month AS STRING), 2, '0') || '-' || 
             LPAD(CAST(day AS STRING), 2, '0') || ' ' ||
             LPAD(CAST(hour AS STRING), 2, '0') || ':' ||
             LPAD(CAST(minute AS STRING), 2, '0') || ':00') as visit_time,
    latitude,
    longitude
FROM `{PROJECT_ID}.{RAW_DATASET}.*`
WHERE _TABLE_SUFFIX IN ({WORKER_REF_TABLES});
