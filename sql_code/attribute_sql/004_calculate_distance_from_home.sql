CREATE OR REPLACE TABLE `{PROJECT_ID}.{PROCESSED_DATASET}.{TABLE_NAME}_distance` AS
WITH tokyo_station AS (
    SELECT ST_GEOGPOINT(139.767125, 35.681236) AS location
)
SELECT
    d.*,
    ST_DISTANCE(ST_GEOGPOINT(d.longitude, d.latitude), tokyo_station.location) / 1000 AS distance_from_tokyo
FROM `{PROJECT_ID}.{CLEAN_DATASET}.{TABLE_NAME}` AS d
CROSS JOIN tokyo_station;
