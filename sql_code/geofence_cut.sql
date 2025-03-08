WITH geofence AS (
  SELECT ST_GEOGFROMTEXT("""
    POLYGON((
      139.758951 35.690991,
      139.758897 35.690434,
      139.759949 35.690181,
      139.760957 35.689327,
      139.761668 35.687231,
      139.761239 35.685732,
      139.760529 35.684574,
      139.762675 35.684190,
      139.759634 35.674957,
      139.762853 35.672955,
      139.764054 35.673339,
      139.764333 35.673687,
      139.762231 35.674071,
      139.763539 35.674716,
      139.763738 35.674546,
      139.764207 35.674557,
      139.764634 35.674419,
      139.765171 35.675296,
      139.765584 35.675230,
      139.766895 35.677088,
      139.771075 35.683617,
      139.771376 35.684697,
      139.770453 35.686301,
      139.768986 35.687990,
      139.766884 35.689001,
      139.764352 35.689384,
      139.763279 35.690186,
      139.760887 35.691127,
      139.758951 35.690991
    ))
  """) AS region
)
SELECT 
    uuid, 
    latitude, 
    longitude, 
    TIMESTAMP(
        CONCAT(
            CAST(year AS STRING), '-', 
            LPAD(CAST(month AS STRING), 2, '0'), '-', 
            LPAD(CAST(day AS STRING), 2, '0'), ' ', 
            LPAD(CAST(hour AS STRING), 2, '0'), ':', 
            LPAD(CAST(minute AS STRING), 2, '0'), ':00'
        )
    ) AS datetime,
    home_prefcode,
    home_citycode
FROM `rd-dapj-dev.raw_daimaruyu_data.PDP_20211008`
WHERE ST_CONTAINS(
    (SELECT region FROM geofence),
    ST_GEOGPOINT(longitude, latitude)
);