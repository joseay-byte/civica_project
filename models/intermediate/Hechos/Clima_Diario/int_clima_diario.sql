{{ config(
    materialized='incremental',
    unique_key='id_registro_clima',
    incremental_strategy='merge'
) }}

WITH stg_weather AS (
    -- Ni siquiera tocamos la columna DATE. Armamos la fecha con DATE_FROM_PARTS
    SELECT 
        STATION_ID,
        -- Sumamos 1900 a YEAR_RAW (ej: 1900 + 42 = 1942)
        DATE_FROM_PARTS(
            TRY_CAST(YEAR_RAW AS INT) + 1900, 
            TRY_CAST(MONTH_RAW AS INT), 
            TRY_CAST(DAY_RAW AS INT)
        ) AS fecha_registro,
        MAX_TEMP_C,
        MIN_TEMP_C,
        MEAN_TEMP_C,
        PRECIPITATION_MM,
        SNOWFALL_MM
    FROM {{ ref('stg_weather') }}
)

SELECT
    -- PK & FKs
    {{ dbt_utils.generate_surrogate_key(['STATION_ID', 'fecha_registro']) }} AS id_registro_clima,
    {{ dbt_utils.generate_surrogate_key(['STATION_ID']) }} AS id_estacion,
    {{ dbt_utils.generate_surrogate_key(['fecha_registro']) }} AS id_fecha,
    
    -- Blindamos también las métricas de clima con TRY_CAST por si hay letras escondidas
    TRY_CAST(MAX_TEMP_C AS FLOAT) AS temp_max_c,
    TRY_CAST(MIN_TEMP_C AS FLOAT) AS temp_min_c,
    TRY_CAST(MEAN_TEMP_C AS FLOAT) AS temp_media_c,
    TRY_CAST(PRECIPITATION_MM AS FLOAT) AS precipitacion_mm,
    TRY_CAST(SNOWFALL_MM AS FLOAT) AS nevada_mm

FROM stg_weather
WHERE STATION_ID IS NOT NULL AND fecha_registro IS NOT NULL
QUALIFY ROW_NUMBER() OVER (PARTITION BY id_estacion, id_fecha ORDER BY temp_max_c DESC) = 1