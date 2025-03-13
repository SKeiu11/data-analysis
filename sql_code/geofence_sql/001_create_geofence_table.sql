CREATE OR REPLACE TABLE `rd-dapj-dev.processed_daimaruyu_data.geofence_regions`
(
    region GEOGRAPHY,
    zone_name STRING
)
OPTIONS(
    description="ジオフェンスの領域定義",
    location="asia-northeast1"
);

# GEOGRAPHYデータの挿入
INSERT INTO `rd-dapj-dev.processed_daimaruyu_data.geofence_regions`
SELECT 
    ST_GEOGFROMTEXT(geometry) as region,
    zone_name
FROM `rd-dapj-dev.raw_daimaruyu_data.dmy_buil_geojson_csv`;
