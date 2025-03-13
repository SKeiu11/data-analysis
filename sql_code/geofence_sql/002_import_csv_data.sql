CREATE OR REPLACE TABLE `rd-dapj-dev.processed_daimaruyu_data.{TABLE_NAME}_calc` AS
SELECT
    uuid,
    latitude,
    longitude,
    year,
    month,
    day,
    hour,
    minute
FROM `rd-dapj-dev.raw_daimaruyu_data.{TABLE_NAME}`;
