CREATE OR REPLACE TABLE `your_project.dataset.stay_time_data` AS
SELECT 
    uuid, 
    geofence, 
    timestamp, 
    LEAD(timestamp) OVER (PARTITION BY uuid, geofence ORDER BY timestamp) AS next_timestamp,
    TIMESTAMP_DIFF(
        LEAD(timestamp) OVER (PARTITION BY uuid, geofence ORDER BY timestamp), 
        timestamp, 
        MINUTE
    ) AS stay_duration
FROM `your_project.dataset.mapped_location_data`;
