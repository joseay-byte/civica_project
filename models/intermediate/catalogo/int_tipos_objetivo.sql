{{ config(materialized='table') }}

WITH stg_operaciones AS (
    -- Asegúrate de que el ref coincida con tu archivo staging de bombardeos
    SELECT * FROM {{ ref('stg_aerial_operations') }}
),

objetivos_unicos AS (
    -- Extraemos las combinaciones únicas de tipo e industria
    SELECT DISTINCT
        UPPER(TRIM(TARGET_TYPE)) AS tipo_objetivo,
        UPPER(TRIM(TARGET_INDUSTRY)) AS industria_objetivo
    FROM stg_operaciones
)

SELECT
    -- PK: Hash de la combinación exacta
    {{ dbt_utils.generate_surrogate_key(['tipo_objetivo', 'industria_objetivo']) }} AS id_objetivo,
    
    COALESCE(tipo_objetivo, 'UNKNOWN') AS tipo_objetivo,
    COALESCE(industria_objetivo, 'UNKNOWN') AS industria_objetivo

FROM objetivos_unicos