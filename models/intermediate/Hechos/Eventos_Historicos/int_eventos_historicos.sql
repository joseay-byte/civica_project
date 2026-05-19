{{ config(materialized='table') }}

WITH stg_events AS (
    SELECT * FROM {{ ref('stg_events') }}
    WHERE EVENT_NAME != 'Event'
),
fechas_procesadas AS (
    SELECT
        *,
        TRIM(SPLIT_PART(EVENT_DATE_RAW, '-', 1)) AS fecha_inicio_str,
        CASE 
            WHEN CONTAINS(EVENT_DATE_RAW, '-') THEN TRIM(SPLIT_PART(EVENT_DATE_RAW, '-', 2))
            ELSE TRIM(EVENT_DATE_RAW)
        END AS fecha_fin_str
    FROM stg_events
),
fechas_casteadas AS (
    SELECT 
        *,
        COALESCE(TRY_TO_DATE(fecha_inicio_str, 'DD Mon YYYY'), TRY_TO_DATE(fecha_inicio_str, 'YYYY-MM-DD')) AS fecha_inicio_date,
        COALESCE(TRY_TO_DATE(fecha_fin_str, 'DD Mon YYYY'), TRY_TO_DATE(fecha_fin_str, 'YYYY-MM-DD')) AS fecha_fin_date
    FROM fechas_procesadas
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['EVENT_NAME', 'EVENT_DATE_RAW']) }} AS id_evento,
    
    -- Trampa de Nulos arreglada:
    CASE WHEN fecha_inicio_date IS NOT NULL 
         THEN {{ dbt_utils.generate_surrogate_key(['fecha_inicio_date']) }} ELSE NULL END AS id_fecha_inicio,
         
    CASE WHEN fecha_fin_date IS NOT NULL 
         THEN {{ dbt_utils.generate_surrogate_key(['fecha_fin_date']) }} ELSE NULL END AS id_fecha_fin,
         
    TRIM(EVENT_NAME) AS nombre_evento,
    UPPER(TRIM(THEATER)) AS teatro_operaciones,
    UPPER(TRIM(EVENT_TYPE)) AS tipo_evento,
    UPPER(TRIM(WINNER_SIDE)) AS bando_ganador
FROM fechas_casteadas