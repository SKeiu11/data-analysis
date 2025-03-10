CREATE OR REPLACE TABLE `rd-dapj-dev.raw_daimaruyu_data.{TABLE_NAME}_transportation` AS
SELECT
    d.*,
    CASE 
        WHEN d.speed BETWEEN 0 AND 2 THEN "stationary"
        WHEN d.speed BETWEEN 2 AND 8 THEN "walking"
        WHEN d.speed > 8 THEN "transport"
        ELSE "unknown"
    END AS means_of_transportation
FROM `rd-dapj-dev.raw_daimaruyu_data.{TABLE_NAME}_visit_style` AS d;
