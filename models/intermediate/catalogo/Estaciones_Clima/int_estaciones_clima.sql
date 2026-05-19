{{ config(materialized='table') }}

WITH stg_stations AS (
    -- Asegúrate de que este ref coincida con tu archivo de staging
    SELECT * FROM {{ ref('stg_stations_weather') }} 
),

dim_paises AS (
    -- Traemos el ID, el código para el cruce y el nombre para tu "capricho" ;)
    SELECT 
        id_pais, 
        codigo_pais, 
        nombre_pais 
    FROM {{ ref('int_paises') }}
),

final AS (
    SELECT
        -- PK: Hash del ID de la estación
        {{ dbt_utils.generate_surrogate_key(['s.STATION_ID']) }} AS id_estacion,
        
        -- FK: Para mantener la integridad del modelo estrella
        p.id_pais,
        
        TRIM(s.STATION_NAME) AS nombre_estacion,
        
        -- Columna descriptiva: El nombre del país que querías
        COALESCE(p.nombre_pais, 'Unknown') AS nombre_pais,
        
        CAST(s.ELEVATION AS FLOAT) AS elevacion,
        CAST(s.LATITUDE AS FLOAT) AS latitud,
        CAST(s.LONGITUDE AS FLOAT) AS longitud
        
    FROM stg_stations s
    -- Cruzamos por el código corto (AL, US, etc) para obtener la info completa
    LEFT JOIN dim_paises p ON UPPER(TRIM(s.COUNTRY_CODE)) = UPPER(TRIM(p.codigo_pais))
    WHERE s.STATION_ID IS NOT NULL
)

SELECT * FROM final