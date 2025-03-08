CREATE OR REPLACE TABLE `your_project.dataset.raw_location_data` AS
SELECT 
    uuid,
    latitude,
    longitude,
    CAST(year AS STRING) AS year,
    LPAD(CAST(month AS STRING), 2, '0') AS month,
    LPAD(CAST(day AS STRING), 2, '0') AS day,
    LPAD(CAST(hour AS STRING), 2, '0') AS hour,
    LPAD(CAST(minute AS STRING), 2, '0') AS minute
FROM `rd-dapj-dev.raw_daimaruyu_data.PDP_*`;
