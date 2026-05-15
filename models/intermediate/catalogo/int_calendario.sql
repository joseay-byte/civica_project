{{ config(materialized='table') }}

WITH date_spine AS (
    SELECT 
        DATEADD(DAY, SEQ4(), '1930-01-01'::DATE) AS fecha_completa
    FROM 
        TABLE(GENERATOR(ROWCOUNT => 7670)) -- Aprox 21 años de días
),

calendario_calculado AS (
    SELECT
        fecha_completa,
        EXTRACT(YEAR FROM fecha_completa) AS anio,
        EXTRACT(MONTH FROM fecha_completa) AS mes,
        TO_CHAR(fecha_completa, 'MMMM') AS nombre_mes,
        EXTRACT(DAY FROM fecha_completa) AS dia,
        EXTRACT(QUARTER FROM fecha_completa) AS trimestre
    FROM 
        date_spine
    WHERE 
        fecha_completa <= '1950-12-31'::DATE
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['fecha_completa']) }} AS id_fecha,
    fecha_completa,
    anio,
    mes,
    nombre_mes,
    dia,
    trimestre
FROM 
    calendario_calculado