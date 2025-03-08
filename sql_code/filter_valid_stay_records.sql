CREATE OR REPLACE TABLE `your_project.dataset.valid_stay_data` AS
SELECT *
FROM `your_project.dataset.stay_time_data`
WHERE stay_duration BETWEEN 15 AND 90;
