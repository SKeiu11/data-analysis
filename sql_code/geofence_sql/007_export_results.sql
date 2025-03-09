EXPORT DATA
OPTIONS(
    uri='gs://raw_daimaruyu/{TABLE_NAME}_geofence_stay_counts.csv',
    format='CSV',
    overwrite=true
) AS
SELECT * FROM `rd-dapj-dev.raw_daimaruyu_data.{TABLE_NAME}_geocount`;
