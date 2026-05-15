{{ config(materialized='view') }}

WITH source AS (
    SELECT * FROM {{ source('raw_data', 'RAW_STATION_WEATHER') }}
),

renamed_and_cast AS (
    SELECT
        -- El WBAN es el identificador único de la estación
        TRIM(WBAN) AS station_id,
        
        -- Nombre de la estación y país
        TRIM(NAME) AS station_name,
        TRIM(STATE_COUNTRY_ID) AS country_code,
        
        -- Elevación (convertimos a número entero)
        CAST(ELEV AS INT) AS elevation,
        
        -- Usamos las columnas de Latitude/Longitude que suelen venir ya en formato decimal
        CAST(Latitude AS FLOAT) AS latitude,
        CAST(Longitude AS FLOAT) AS longitude
        
    FROM source
)

SELECT * FROM renamed_and_cast