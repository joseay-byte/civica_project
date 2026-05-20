{{ config(materialized='table') }}

WITH seed_paises AS (
    SELECT * FROM {{ ref('country_mapping') }}
),
paises_agrupados AS (
    SELECT 
        TRIM(country_name) AS nombre_pais_EN,
        TRIM(nombre_pais_es) AS nombre_pais,
        MAX(UPPER(TRIM(iso_2))) AS codigo_pais,
        MAX(TRIM(continent)) AS continente,
        MAX(UPPER(TRIM(iso_3))) AS codigo_iso3,
    FROM seed_paises
    GROUP BY TRIM(country_name), TRIM(nombre_pais_es)
)
SELECT
    {{ dbt_utils.generate_surrogate_key(['UPPER(nombre_pais_EN)']) }} AS id_pais,
    nombre_pais,
    codigo_pais,
    continente,
    codigo_iso3
FROM paises_agrupados