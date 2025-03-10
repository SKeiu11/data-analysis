CREATE OR REPLACE TABLE `rd-dapj-dev.raw_daimaruyu_data.{TABLE_NAME}_distance` AS
WITH home_locations AS (
    SELECT 
        home_prefcode,
        home_citycode,
        ST_GEOGPOINT(longitude, latitude) AS home_location
    FROM `rd-dapj-dev.raw_daimaruyu_data.home_location_mapping`
)
SELECT
    d.*,
    ST_DISTANCE(h.home_location, ST_GEOGPOINT(139.767125, 35.681236)) / 1000 AS distance_from_home  -- km単位
FROM `rd-dapj-dev.raw_daimaruyu_data.{TABLE_NAME}_transportation` AS d
LEFT JOIN home_locations AS h ON d.home_prefcode = h.home_prefcode AND d.home_citycode = h.home_citycode;
