CREATE OR REPLACE TABLE `rd-dapj-dev.raw_daimaruyu_data.{TABLE_NAME}` AS
SELECT 
    d.uuid, 
    d.latitude, 
    d.longitude, 
    g.zone_name AS geofence,
    TIMESTAMP(
        CONCAT(d.year, '-', d.month, '-', d.day, ' ', d.hour, ':', d.minute, ':00')
    ) AS timestamp
FROM `rd-dapj-dev.raw_daimaruyu_data.{TABLE_NAME}` AS d
JOIN `rd-dapj-dev.raw_daimaruyu_data.dmy_buil_geojson_csv` AS g
ON ST_CONTAINS(g.region, ST_GEOGPOINT(d.longitude, d.latitude));
