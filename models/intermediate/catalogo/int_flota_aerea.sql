{{ config(materialized='table') }}

WITH stg_operaciones AS (
    -- Recuerda revisar que el ref() coincida con el nombre de tu archivo SQL de staging
    SELECT * FROM {{ ref('stg_aerial_operations') }}
),

aviones_unicos AS (
    -- Extraemos todas las combinaciones únicas de modelo de avión y fuerza aérea
    SELECT DISTINCT
        UPPER(TRIM(AIRCRAFT_MODEL)) AS modelo_aeronave,
        UPPER(TRIM(AIR_FORCE)) AS fuerza_aerea
    FROM stg_operaciones
    -- Evitamos meter filas completamente vacías
    WHERE AIRCRAFT_MODEL IS NOT NULL 
       OR AIR_FORCE IS NOT NULL
)

SELECT
    -- PK: El hash de la combinación
    {{ dbt_utils.generate_surrogate_key(['modelo_aeronave', 'fuerza_aerea']) }} AS id_aeronave,
    
    COALESCE(modelo_aeronave, 'UNKNOWN') AS modelo_aeronave,
    COALESCE(fuerza_aerea, 'UNKNOWN') AS fuerza_aerea

FROM aviones_unicos