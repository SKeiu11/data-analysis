EXPORT DATA
OPTIONS(
    uri='gs://raw_daimaruyu/geofence_stay_counts/*.csv',
    format='CSV',
    overwrite=true
) AS
SELECT * FROM `rd-dapj-dev.processed_daimaruyu_data.{TABLE_NAME}_geocount`;
