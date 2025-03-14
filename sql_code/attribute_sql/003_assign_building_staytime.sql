CREATE OR REPLACE TABLE `{PROJECT_ID}.{PROCESSED_DATASET}.{TABLE_NAME}_building_staytime` AS
WITH stay_summaries AS (
    SELECT
        uuid,
        building AS building_name,
        SUM(total_stay_duration) AS building_staytime
    FROM `{PROJECT_ID}.{PROCESSED_DATASET}.worker_sessions`
    GROUP BY uuid, building
),
ranked_stay AS (
    SELECT
        uuid,
        building_name,
        building_staytime,
        RANK() OVER (PARTITION BY uuid ORDER BY building_staytime DESC) AS rank
    FROM stay_summaries
)
SELECT
    w.uuid,
    w.visit_style,
    COALESCE(r.building_name, "Unknown") AS building_name,
    COALESCE(r.building_staytime, 0) AS building_staytime
FROM `{PROJECT_ID}.{PROCESSED_DATASET}.workers` AS w
LEFT JOIN ranked_stay AS r
ON w.uuid = r.uuid AND r.rank = 1;
