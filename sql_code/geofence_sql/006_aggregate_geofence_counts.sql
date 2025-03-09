CREATE OR REPLACE TABLE `rd-dapj-dev.raw_daimaruyu_data.{TABLE_NAME}_geocount` AS
SELECT 
    geofence, 
    COUNT(*) AS count
FROM `rd-dapj-dev.raw_daimaruyu_data.{TABLE_NAME}_15-90`
GROUP BY geofence
HAVING COUNT(*) >= 10;
