CREATE OR REPLACE TABLE `rd-dapj-dev.processed_daimaruyu_data.{TABLE_NAME}_distance` AS
WITH home_locations AS (
    SELECT 
        home_prefcode,
        home_citycode,
        ST_GEOGPOINT(longitude, latitude) AS home_location
    FROM `rd-dapj-dev.processed_daimaruyu_data.home_location_mapping`
),
tokyo_station AS (
    SELECT ST_GEOGPOINT(139.767125, 35.681236) AS location
)
SELECT
    d.*,
    ST_DISTANCE(h.home_location, tokyo_station.location) / 1000 AS distance_from_tokyo
FROM `rd-dapj-dev.clean_daimaruyu_data.{TABLE_NAME}` AS d
CROSS JOIN tokyo_station
LEFT JOIN home_locations AS h 
    ON d.home_prefcode = h.home_prefcode 
    AND d.home_citycode = h.home_citycode;
