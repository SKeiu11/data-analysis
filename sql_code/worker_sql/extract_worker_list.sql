CREATE OR REPLACE TABLE `your_project.dataset.worker_list` AS
WITH weekly_stays AS (
    SELECT
        uuid,
        building,
        week_number,
        COUNT(*) AS visit_count
    FROM `your_project.dataset.stay_time_data`
    GROUP BY uuid, building, week_number
),
worker_candidates AS (
    SELECT
        uuid,
        building
    FROM weekly_stays
    WHERE visit_count >= 3
    GROUP BY uuid, building
)
SELECT uuid FROM worker_candidates;
