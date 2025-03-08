CREATE OR REPLACE TABLE `your_project.dataset.geofence_counts` AS
SELECT 
    geofence, 
    COUNT(*) AS count
FROM `your_project.dataset.valid_stay_data`
GROUP BY geofence
HAVING COUNT(*) >= 10;
