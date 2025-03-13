CREATE OR REPLACE TABLE `rd-dapj-dev.processed_daimaruyu_data.{TABLE_NAME}_15-90` AS
SELECT *
FROM `rd-dapj-dev.processed_daimaruyu_data.{TABLE_NAME}_stay_time`
WHERE total_stay_duration BETWEEN 15 AND 90;
