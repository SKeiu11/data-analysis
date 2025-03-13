CREATE OR REPLACE TABLE `rd-dapj-dev.processed_daimaruyu_data.{TABLE_NAME}_attributes` AS
SELECT 
    d.uuid,
    g.zone_name AS geofence,
    PARSE_TIMESTAMP(
        "%Y-%m-%d %H:%M:%S",
        CONCAT(
            SAFE_CAST(d.year AS STRING), '-',
            FORMAT("%02d", d.month), '-',
            FORMAT("%02d", d.day), ' ',
            FORMAT("%02d", d.hour), ':',
            FORMAT("%02d", d.minute), ':00'
        )
    ) AS visit_time
FROM `rd-dapj-dev.processed_daimaruyu_data.{TABLE_NAME}_calc` AS d
LEFT JOIN `rd-dapj-dev.raw_daimaruyu_data.dmy_buil_geojson_csv` AS g
ON ST_CONTAINS(g.region, ST_GEOGPOINT(d.longitude, d.latitude));
