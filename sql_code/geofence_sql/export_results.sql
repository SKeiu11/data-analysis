EXPORT DATA
OPTIONS(
    uri='gs://your-bucket-name/geofence_stay_counts.csv',
    format='CSV',
    overwrite=true
) AS
SELECT * FROM `your_project.dataset.geofence_counts`;
