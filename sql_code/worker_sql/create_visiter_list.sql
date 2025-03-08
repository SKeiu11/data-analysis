CREATE OR REPLACE TABLE `your_project.dataset.visitor_list` AS
SELECT DISTINCT uuid
FROM `your_project.dataset.stay_time_data`
WHERE uuid NOT IN (SELECT uuid FROM `your_project.dataset.worker_list`);
