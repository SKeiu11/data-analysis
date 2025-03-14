CREATE OR REPLACE TABLE `{PROJECT_ID}.{PROCESSED_DATASET}.{TABLE_NAME}_final` AS
SELECT 
    r.*,  -- ローデータの全カラム
    a.geofence,
    a.visit_time,
    COALESCE(s.total_stay_duration, 0) AS stay_duration,
    COALESCE(w.visit_style, 'visitor') AS visit_style
FROM `{PROJECT_ID}.{RAW_DATASET}.{TABLE_NAME}` r
LEFT JOIN `{PROJECT_ID}.{PROCESSED_DATASET}.{TABLE_NAME}_attributes` a
    ON r.uuid = a.uuid
LEFT JOIN `{PROJECT_ID}.{PROCESSED_DATASET}.{TABLE_NAME}_stay_time` s
    ON r.uuid = s.uuid
LEFT JOIN `{PROJECT_ID}.{PROCESSED_DATASET}.workers` w
    ON r.uuid = w.uuid; 