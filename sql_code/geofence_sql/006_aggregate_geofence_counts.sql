CREATE OR REPLACE TABLE `rd-dapj-dev.processed_daimaruyu_data.{TABLE_NAME}_geocount` AS
SELECT 
    building AS geofence,
    COUNT(DISTINCT uuid) as unique_visitors,
    AVG(total_stay_duration) as avg_stay_duration
FROM `rd-dapj-dev.processed_daimaruyu_data.{TABLE_NAME}_stay_time`
GROUP BY building;
