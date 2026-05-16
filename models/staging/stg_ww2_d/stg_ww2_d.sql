{{ config(materialized='view') }}

WITH source AS (
    SELECT * FROM {{ source('raw_data', 'RAW_WW2_D') }}
),

renamed_and_cast AS (
    SELECT
        -- País
        TRIM(Country) AS country_name,
        
        -- Población antes de la guerra (Mantenemos VARCHAR por las comas y notas)
        TRIM(population_before) AS population_1939,
        
        -- Muertes Militares y Civiles
        TRIM(Military) AS military_deaths,
        TRIM(Civilian) AS civilian_deaths,
        
        -- Total de muertes y porcentajes
        TRIM(Total_deaths) AS total_deaths,
        TRIM(Deaths_percentage) AS deaths_pct_population,
        TRIM(Average_Deaths_percentage) AS avg_deaths_pct,
        
        -- Heridos militares
        TRIM(Military_wounded) AS military_wounded
        
    FROM source
)

SELECT * FROM renamed_and_cast
WHERE country_name != 'Country'