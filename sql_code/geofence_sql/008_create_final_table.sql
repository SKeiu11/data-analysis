CREATE OR REPLACE TABLE `rd-dapj-dev.processed_daimaruyu_data.{TABLE_NAME}_final` AS
SELECT 
    r.*,  -- ローデータの全カラム
    a.geofence,
    a.visit_time,
    COALESCE(s.total_stay_duration, 0) AS stay_duration,
    COALESCE(w.visit_style, 'visitor') AS visit_style
FROM `rd-dapj-dev.raw_daimaruyu_data.{TABLE_NAME}` r
LEFT JOIN `rd-dapj-dev.processed_daimaruyu_data.{TABLE_NAME}_attributes` a
    ON r.uuid = a.uuid
LEFT JOIN `rd-dapj-dev.processed_daimaruyu_data.{TABLE_NAME}_stay_time` s
    ON r.uuid = s.uuid
LEFT JOIN `rd-dapj-dev.processed_daimaruyu_data.{TABLE_NAME}_workers` w
    ON r.uuid = w.uuid; 