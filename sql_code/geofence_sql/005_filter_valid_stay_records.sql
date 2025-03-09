CREATE OR REPLACE TABLE `rd-dapj-dev.raw_daimaruyu_data.{TABLE_NAME}_15-90` AS
SELECT *
FROM `rd-dapj-dev.raw_daimaruyu_data.{TABLE_NAME}`
WHERE stay_duration BETWEEN 15 AND 90;
