{{ config(materialized='table') }}

WITH stg_ww2 AS (
    SELECT * FROM {{ ref('stg_ww2_d') }}
    WHERE COUNTRY_NAME != 'Country'
)

SELECT
    -- PK & FK
    {{ dbt_utils.generate_surrogate_key(['UPPER(TRIM(COUNTRY_NAME))', 'POPULATION_1939']) }} AS id_estadistica,
    {{ dbt_utils.generate_surrogate_key(['UPPER(TRIM(COUNTRY_NAME))']) }} AS id_pais,
    
    -- TRY_CAST convertirá cualquier basura ('S2', textos raros, celdas vacías) en NULL automáticamente
    TRY_CAST(REGEXP_SUBSTR(REPLACE(POPULATION_1939, ',', ''), '^[0-9]+') AS INT) AS poblacion_1939,
    TRY_CAST(REGEXP_SUBSTR(REPLACE(MILITARY_DEATHS, ',', ''), '^[0-9]+') AS INT) AS muertes_militares,
    TRY_CAST(REGEXP_SUBSTR(REPLACE(CIVILIAN_DEATHS, ',', ''), '^[0-9]+') AS INT) AS muertes_civiles,
    TRY_CAST(REGEXP_SUBSTR(REPLACE(TOTAL_DEATHS, ',', ''), '^[0-9]+') AS INT) AS muertes_totales,
    
    -- Aquí arreglamos el problema del 'S2'
    TRY_CAST(AVG_DEATHS_PCT AS FLOAT) AS porcentaje_muertes_poblacion,
    TRY_CAST(REGEXP_SUBSTR(REPLACE(MILITARY_WOUNDED, ',', ''), '^[0-9]+') AS INT) AS heridos_militares

FROM stg_ww2