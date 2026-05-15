{{ config(materialized='table') }}

WITH seed_paises AS (
    SELECT * FROM {{ ref('country_mapping') }}
)

SELECT
    -- PK: Hash del nombre del país
    {{ dbt_utils.generate_surrogate_key(['UPPER(TRIM(country_name))']) }} AS id_pais,
    
    TRIM(country_name) AS nombre_pais,
    UPPER(TRIM(iso_2)) AS codigo_pais,
    TRIM(continent) AS continente,
    UPPER(TRIM(iso_3)) AS codigo_iso3,
    
    CASE 
        WHEN is_axis = 1 THEN 'Axis'
        WHEN is_allied = 1 THEN 'Allies'
        ELSE 'Neutral/Other'
    END AS bando_principal
FROM seed_paises