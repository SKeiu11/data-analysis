CREATE OR REPLACE TABLE `rd-dapj-dev.processed_daimaruyu_data.{TABLE_NAME}_workers` AS
WITH daily_stay_time AS (
    SELECT
        uuid,
        building,
        DATE(start_time) as visit_date,
        start_time,
        end_time,
        -- 8-20時の間の滞在時間のみを計算
        TIMESTAMP_DIFF(
            LEAST(
                end_time,
                TIMESTAMP(DATE(end_time), TIME(20, 0, 0))
            ),
            GREATEST(
                start_time,
                TIMESTAMP(DATE(start_time), TIME(8, 0, 0))
            ),
            MINUTE
        ) as business_hours_duration
    FROM `rd-dapj-dev.processed_daimaruyu_data.{TABLE_NAME}_worker_sessions`
    WHERE 
        -- 8-20時の間に少しでも重なるセッションのみを対象とする
        EXTRACT(HOUR FROM start_time) < 20 AND
        EXTRACT(HOUR FROM end_time) > 8
),
total_daily_stay AS (
    SELECT
        uuid,
        building,
        visit_date,
        SUM(business_hours_duration) as total_business_hours
    FROM daily_stay_time
    GROUP BY uuid, building, visit_date
)
SELECT DISTINCT
    d.uuid,
    'worker' as visit_style
FROM total_daily_stay d
WHERE total_business_hours >= 360;  -- 6時間以上
