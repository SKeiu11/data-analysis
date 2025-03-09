CREATE OR REPLACE TABLE `rd-dapj-dev.raw_daimaruyu_data.{TABLE_NAME}` AS
SELECT 
    d.uuid, 
    d.latitude, 
    d.longitude, 
    g.zone_name AS geofence,
    TIMESTAMP(
        CONCAT(d.year, '-', d.month, '-', d.day, ' ', d.hour, ':', d.minute, ':00')
    ) AS timestamp
FROM `your_project.dataset.raw_location_data` AS d
JOIN `your_project.dataset.geofences` AS g
ON ST_CONTAINS(g.region, ST_GEOGPOINT(d.longitude, d.latitude));
