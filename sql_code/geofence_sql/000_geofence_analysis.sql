CREATE OR REPLACE TABLE `{PROJECT_ID}.{PROCESSED_DATASET}.{TABLE_NAME}_geofence` AS
WITH location_data AS (
    SELECT 
        uuid,
        TIMESTAMP(CAST(year AS STRING) || '-' || 
                 LPAD(CAST(month AS STRING), 2, '0') || '-' || 
                 LPAD(CAST(day AS STRING), 2, '0') || ' ' ||
                 LPAD(CAST(hour AS STRING), 2, '0') || ':' ||
                 LPAD(CAST(minute AS STRING), 2, '0') || ':00') as visit_time,
        ST_GEOGPOINT(longitude, latitude) as location
    FROM `{PROJECT_ID}.{CLEAN_DATASET}.{TABLE_NAME}`
    WHERE longitude IS NOT NULL AND latitude IS NOT NULL
),
stay_records AS (
    SELECT 
        l.uuid,
        g.zone_name as building,
        l.visit_time,
        TIMESTAMP_DIFF(
            LEAD(l.visit_time) OVER (PARTITION BY l.uuid, g.zone_name ORDER BY l.visit_time),
            l.visit_time,
            MINUTE
        ) AS duration
    FROM location_data l
    JOIN `{PROJECT_ID}.{PROCESSED_DATASET}.geofence_regions` g
    ON ST_CONTAINS(g.region, l.location)
)
SELECT
    uuid,
    building AS most_visited_building,
    SUM(duration) AS longest_stay_duration
FROM stay_records
WHERE duration > 0 AND duration < 180  -- 3時間未満の滞在のみを考慮
GROUP BY uuid, building
QUALIFY ROW_NUMBER() OVER (PARTITION BY uuid ORDER BY SUM(duration) DESC) = 1;
