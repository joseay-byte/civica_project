{{ config(materialized='view') }}

WITH source AS (
    SELECT * FROM {{ source('raw_data', 'RAW_WEATHER') }}
),

renamed_and_cast AS (
    SELECT
        -- Identificador de la estación (unimos con la tabla de estaciones luego)
        TRIM(STA) AS station_id,
        
        -- Convertimos la fecha de VARCHAR a DATE
        CAST(Date AS DATE) AS date,
        
        -- Temperaturas en Celsius (usando FLOAT para decimales)
        CAST(MaxTemp AS FLOAT) AS max_temp_c,
        CAST(MinTemp AS FLOAT) AS min_temp_c,
        CAST(MeanTemp AS FLOAT) AS mean_temp_c,
        
        -- Precipitaciones y nieve
        -- Nota: A veces vienen con "T" de traza, Snowflake lo manejará como NULL si falla el cast
        TRY_CAST(Precip AS FLOAT) AS precipitation_mm,
        TRY_CAST(Snowfall AS FLOAT) AS snowfall_mm,
        
        -- Metadatos de tiempo originales por si acaso
        CAST(YR AS INT) AS year_raw,
        CAST(MO AS INT) AS month_raw,
        CAST(DA AS INT) AS day_raw
        
    FROM source
)

SELECT * FROM renamed_and_cast