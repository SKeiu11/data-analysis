CREATE OR REPLACE TABLE `rd-dapj-dev.processed_daimaruyu_data.{TABLE_NAME}_workers` AS
WITH worker_candidates AS (
    SELECT
        w.uuid,
        w.building,
        COUNT(DISTINCT r.visit_date) AS visit_days
    FROM `rd-dapj-dev.processed_daimaruyu_data.worker_reference` AS r
    JOIN `rd-dapj-dev.processed_daimaruyu_data.{TABLE_NAME}_worker_sessions` AS w
    ON r.uuid = w.uuid AND r.building = w.building
    GROUP BY w.uuid, w.building
    HAVING visit_days >= 3
)
SELECT
    d.*,
    CASE 
        WHEN w.uuid IS NOT NULL THEN "worker"
        ELSE "visitor"
    END AS visit_style
FROM `rd-dapj-dev.processed_daimaruyu_data.{TABLE_NAME}_attributes` AS d
LEFT JOIN worker_candidates AS w 
ON d.uuid = w.uuid AND d.geofence = w.building;
