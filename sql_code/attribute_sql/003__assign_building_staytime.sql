CREATE OR REPLACE TABLE `rd-dapj-dev.raw_daimaruyu_data.{TABLE_NAME}_building_staytime` AS
WITH stay_summaries AS (
    SELECT
        uuid,
        building AS building_name,
        SUM(total_stay_duration) AS building_staytime
    FROM `rd-dapj-dev.raw_daimaruyu_data.{TABLE_NAME}_worker_sessions`
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
    d.*,
    COALESCE(r.building_name, "Unknown") AS building_name,
    COALESCE(r.building_staytime, 0) AS building_staytime
FROM `rd-dapj-dev.raw_daimaruyu_data.{TABLE_NAME}_workers` AS d
LEFT JOIN ranked_stay AS r
ON d.uuid = r.uuid AND r.rank = 1;
