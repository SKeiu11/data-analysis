WITH geofence AS (
  SELECT 
    zone_name,
    ST_GEOGFROMGEOJSON(geojson_geometry) AS region
  FROM `your_project.your_dataset.geojson_table`
),
filtered_data AS (
  SELECT 
    d.uuid, 
    d.latitude, 
    d.longitude, 
    g.zone_name AS geofence,
    TIMESTAMP(
        CONCAT(
            CAST(d.year AS STRING), '-', 
            LPAD(CAST(d.month AS STRING), 2, '0'), '-', 
            LPAD(CAST(d.day AS STRING), 2, '0'), ' ', 
            LPAD(CAST(d.hour AS STRING), 2, '0'), ':', 
            LPAD(CAST(d.minute AS STRING), 2, '0'), ':00'
        )
    ) AS timestamp
  FROM `your_project.your_dataset.raw_data` AS d
  JOIN geofence AS g
  ON ST_CONTAINS(g.region, ST_GEOGPOINT(d.longitude, d.latitude))
),
stay_time AS (
  SELECT 
    uuid, 
    geofence, 
    timestamp, 
    LEAD(timestamp) OVER (PARTITION BY uuid ORDER BY timestamp) AS next_timestamp,
    TIMESTAMP_DIFF(LEAD(timestamp) OVER (PARTITION BY uuid ORDER BY timestamp), timestamp, MINUTE) AS stay_duration
  FROM filtered_data
)
SELECT geofence, MEDIAN(stay_duration) AS median_stay
FROM stay_time
WHERE stay_duration BETWEEN 15 AND 90  -- 滞在時間を 15〜90 分の範囲に限定
GROUP BY geofence
ORDER BY median_stay DESC
LIMIT 10;
