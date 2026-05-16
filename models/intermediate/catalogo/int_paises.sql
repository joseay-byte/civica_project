{{ config(materialized='table') }}

WITH seed_paises AS (
    SELECT * FROM {{ ref('country_mapping') }}
),
paises_agrupados AS (
    SELECT 
        TRIM(country_name) AS nombre_pais,
        MAX(UPPER(TRIM(iso_2))) AS codigo_pais,
        MAX(TRIM(continent)) AS continente,
        MAX(UPPER(TRIM(iso_3))) AS codigo_iso3,
        MAX(is_axis) AS is_axis,
        MAX(is_allied) AS is_allied
    FROM seed_paises
    GROUP BY TRIM(country_name)
)
SELECT
    {{ dbt_utils.generate_surrogate_key(['UPPER(nombre_pais)']) }} AS id_pais,
    nombre_pais,
    codigo_pais,
    continente,
    codigo_iso3,
    CASE 
        WHEN is_axis = 1 THEN 'Axis'
        WHEN is_allied = 1 THEN 'Allies'
        ELSE 'Neutral/Other'
    END AS bando_principal
FROM paises_agrupados