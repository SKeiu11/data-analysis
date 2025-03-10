CREATE OR REPLACE TABLE `rd-dapj-dev.raw_daimaruyu_data.worker_reference` AS
SELECT uuid, building, DATE(visit_time) AS visit_date
FROM `rd-dapj-dev.raw_daimaruyu_data.*`
WHERE _TABLE_SUFFIX IN ({WORKER_REF_TABLES});
