SELECT distinct date_witness, city, country, city_agent, latitude, longitude
FROM {{ref('STG_ALL_GEO')}}