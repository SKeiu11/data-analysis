CREATE OR REPLACE TABLE `{PROJECT_ID}.{PROCESSED_DATASET}.{TABLE_NAME}_geofence` AS
WITH stay_records AS (
    SELECT 
        uuid,
        geofence AS building,
        visit_time,
        TIMESTAMP_DIFF(
            LEAD(visit_time) OVER (PARTITION BY uuid, geofence ORDER BY visit_time),
            visit_time,
            MINUTE
        ) AS duration
    FROM `{PROJECT_ID}.{CLEAN_DATASET}.{TABLE_NAME}`
    WHERE geofence IS NOT NULL
)
SELECT
    uuid,
    building AS most_visited_building,
    SUM(duration) AS longest_stay_duration
FROM stay_records
GROUP BY uuid, building
QUALIFY ROW_NUMBER() OVER (PARTITION BY uuid ORDER BY SUM(duration) DESC) = 1;
