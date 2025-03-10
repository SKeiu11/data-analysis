CREATE OR REPLACE TABLE `rd-dapj-dev.raw_daimaruyu_data.dmy_buil_geojson_csv` AS
SELECT 
    string_field_0 AS zone_name,  
    ST_GEOGFROMTEXT(string_field_1) AS region  
FROM `rd-dapj-dev.raw_daimaruyu_data.dmy_buil_geojson_csv`
WHERE region LIKE 'MULTIPOLYGON%';
