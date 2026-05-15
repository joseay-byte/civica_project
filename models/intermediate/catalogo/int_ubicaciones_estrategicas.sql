{{ config(materialized='table') }}

WITH stg_locations AS (
    -- RECUERDA: Cambia 'stg_locations' por el nombre exacto de tu archivo sql en la carpeta staging
    SELECT * FROM {{ ref('stg_locations') }} 
),

final AS (
    SELECT
        -- PK: Hash de nombre + lat + long (usamos los tres por si hay bases con el mismo nombre en distintos lugares)
        {{ dbt_utils.generate_surrogate_key(['LOCATION_NAME', 'LATITUDE', 'LONGITUDE']) }} AS id_ubicacion,
        
        -- FK: Hash del país estandarizado para que coincida con la PK de int_paises
        {{ dbt_utils.generate_surrogate_key(['UPPER(TRIM(COUNTRY))']) }} AS id_pais,
        
        TRIM(LOCATION_NAME) AS nombre_ubicacion,
        TRIM(LOCATION_TYPE) AS tipo_ubicacion,
        TRIM(CITY_REGION) AS ciudad_region,
        
        -- Casteo explícito a FLOAT para asegurar que Snowflake lo trate como números decimales y Power BI los lea como coordenadas
        CAST(LATITUDE AS FLOAT) AS latitud,
        CAST(LONGITUDE AS FLOAT) AS longitud,
        
        UPPER(TRIM(AFFILIATION)) AS afiliacion_bando,
        UPPER(TRIM(STRATEGIC_VALUE)) AS valor_estrategico

    FROM stg_locations
    -- Filtramos posibles nulos severos donde no haya nombre ni coordenadas
    WHERE LOCATION_NAME IS NOT NULL 
      AND LATITUDE IS NOT NULL 
      AND LONGITUDE IS NOT NULL
)

SELECT * FROM final