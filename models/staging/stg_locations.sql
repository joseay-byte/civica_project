{{ config(materialized='view') }}

WITH source AS (
    SELECT * FROM {{ source('raw_data', 'RAW_LOCATIONS') }}
),

renamed_and_cast AS (
    SELECT
        -- Limpiamos posibles espacios en blanco con TRIM
        TRIM(Name) AS location_name,
        TRIM(Type) AS location_type,
        TRIM(Location) AS city_region,
        TRIM(Country) AS country,
        
        -- Convertimos a FLOAT para cálculos geográficos
        CAST(lat AS FLOAT) AS latitude,
        CAST(lon AS FLOAT) AS longitude,
        
        -- Normalizamos etiquetas
        UPPER(TRIM(affiliation)) AS affiliation,
        UPPER(TRIM(strategic_value)) AS strategic_value
    FROM source
)

SELECT * FROM renamed_and_cast