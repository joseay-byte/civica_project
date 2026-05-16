{{ config(materialized='table') }}

WITH date_spine AS (
    SELECT DATEADD(DAY, SEQ4(), '1915-01-01'::DATE) AS fecha_completa
    FROM TABLE(GENERATOR(ROWCOUNT => 18000)) -- Aumentamos a casi 50 años
),
calendario_calculado AS (
    SELECT
        fecha_completa,
        EXTRACT(YEAR FROM fecha_completa) AS anio,
        EXTRACT(MONTH FROM fecha_completa) AS mes,
        TO_CHAR(fecha_completa, 'MMMM') AS nombre_mes,
        EXTRACT(DAY FROM fecha_completa) AS dia,
        EXTRACT(QUARTER FROM fecha_completa) AS trimestre
    FROM date_spine
    -- AQUI ESTABA EL ERROR: Cambiamos 1950 por 1960
    WHERE fecha_completa <= '1960-12-31'::DATE
)
SELECT
    {{ dbt_utils.generate_surrogate_key(['fecha_completa']) }} AS id_fecha,
    fecha_completa, anio, mes, nombre_mes, dia, trimestre
FROM calendario_calculado