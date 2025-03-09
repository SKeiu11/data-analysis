CREATE OR REPLACE TABLE `rd-dapj-dev.raw_daimaruyu_data.{TABLE_NAME}` AS
WITH ordered_data AS (
    SELECT
        uuid,
        geofence AS building,
        TIMESTAMP_SECONDS(timestamp) AS visit_time
    FROM `rd-dapj-dev.raw_daimaruyu_data.{TABLE_NAME}`
),
session_data AS (
    SELECT
        uuid,
        building,
        visit_time,
        LAG(visit_time) OVER (PARTITION BY uuid, building ORDER BY visit_time) AS prev_time,
        TIMESTAMP_DIFF(visit_time, LAG(visit_time) OVER (PARTITION BY uuid, building ORDER BY visit_time), MINUTE) AS time_diff
    FROM ordered_data
),
session_grouping AS (
    SELECT
        *,
        SUM(CASE WHEN time_diff IS NULL OR time_diff > 30 THEN 1 ELSE 0 END) OVER (PARTITION BY uuid, building ORDER BY visit_time) AS session_id
    FROM session_data
),
stay_durations AS (
    SELECT
        uuid,
        building,
        session_id,
        MIN(visit_time) AS start_time,
        MAX(visit_time) AS end_time,
        TIMESTAMP_DIFF(MAX(visit_time), MIN(visit_time), MINUTE) AS total_stay_duration
    FROM session_grouping
    GROUP BY uuid, building, session_id
)
SELECT
    uuid,
    building,
    start_time,
    end_time,
    total_stay_duration,
    EXTRACT(WEEK FROM start_time) AS week_number
FROM stay_durations
WHERE total_stay_duration >= 15;
