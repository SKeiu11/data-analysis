CREATE OR REPLACE TABLE `rd-dapj-dev.processed_daimaruyu_data.{TABLE_NAME}_worker_sessions` AS
WITH ordered_data AS (
    SELECT
        uuid,
        geofence AS building,
        visit_time
    FROM `rd-dapj-dev.processed_daimaruyu_data.{TABLE_NAME}_attributes`
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
        COUNTIF(time_diff IS NULL OR time_diff > 30) OVER (PARTITION BY uuid, building ORDER BY visit_time) AS session_id
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
    FORMAT_DATE("%Y-%W", DATE(start_time)) AS week_number
FROM stay_durations
WHERE total_stay_duration >= 15;
