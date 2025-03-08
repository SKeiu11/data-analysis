CREATE OR REPLACE TABLE `your_project.dataset.worker_data` AS
SELECT *
FROM `your_project.dataset.stay_time_data`
WHERE uuid IN (SELECT uuid FROM `your_project.dataset.worker_list`);
