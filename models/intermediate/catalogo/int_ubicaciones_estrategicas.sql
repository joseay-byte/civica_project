{{ config(materialized='table') }}

WITH stg_locations AS (
    SELECT * FROM {{ ref('stg_locations') }} 
    WHERE LOCATION_NAME IS NOT NULL AND LATITUDE IS NOT NULL AND LONGITUDE IS NOT NULL
),
paises_normalizados AS (
    SELECT 
        *,
        CASE 
            WHEN UPPER(TRIM(COUNTRY)) IN ('USA', 'UNITED STATES OF AMERICA', 'US VIRGIN ISLANDS') THEN 'UNITED STATES'
            WHEN UPPER(TRIM(COUNTRY)) IN ('UK', 'GREAT BRITAIN', 'ENGLAND', 'HONG KONG') THEN 'UNITED KINGDOM'
            WHEN UPPER(TRIM(COUNTRY)) IN ('RUSSIA', 'USSR') THEN 'SOVIET UNION'
            WHEN UPPER(TRIM(COUNTRY)) IN ('BRITISH WESTERN PACIFIC TERRITORIES', 'US PACIFIC ISLANDS') THEN 'PACIFIC ISLANDS'
            WHEN UPPER(TRIM(COUNTRY)) = 'DANZIG' THEN 'POLAND'
            WHEN UPPER(TRIM(COUNTRY)) = 'TAIWAN' THEN 'CHINA'
            WHEN UPPER(TRIM(COUNTRY)) IN ('AUSTRALIAN PAPUA', 'AUSTRALIAN NEW GUINEA') THEN 'PAPUA AND NEW GUINEA'
            WHEN UPPER(TRIM(COUNTRY)) = 'SINGAPORE' THEN 'MALAYA & SINGAPORE'
            WHEN UPPER(TRIM(COUNTRY)) IN ('UNKNOWN', 'N/A') THEN NULL
            ELSE UPPER(TRIM(COUNTRY))
        END AS pais_norm
    FROM stg_locations
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['LOCATION_NAME', 'LATITUDE', 'LONGITUDE']) }} AS id_ubicacion,
    
    CASE WHEN NULLIF(pais_norm, '') IS NOT NULL THEN {{ dbt_utils.generate_surrogate_key(['pais_norm']) }} ELSE NULL END AS id_pais,
    
    TRIM(LOCATION_NAME) AS nombre_ubicacion,
    TRIM(LOCATION_TYPE) AS tipo_ubicacion,
    TRIM(CITY_REGION) AS ciudad_region,
    CAST(LATITUDE AS FLOAT) AS latitud,
    CAST(LONGITUDE AS FLOAT) AS longitud,
    UPPER(TRIM(AFFILIATION)) AS afiliacion_bando,
    UPPER(TRIM(STRATEGIC_VALUE)) AS valor_estrategico
FROM paises_normalizados