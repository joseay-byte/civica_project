{{ config(materialized='table') }}

WITH stg_ops AS (
    SELECT * FROM {{ ref('stg_aerial_operations') }}
),
paises_normalizados AS (
    SELECT 
        *,
        -- Origen limpio
        CASE 
            WHEN UPPER(TRIM(COUNTRY_ORIGIN)) = 'USA' THEN 'UNITED STATES'
            WHEN UPPER(TRIM(COUNTRY_ORIGIN)) IN ('GREAT BRITAIN', 'UK') THEN 'UNITED KINGDOM'
            WHEN UPPER(TRIM(COUNTRY_ORIGIN)) = 'RUSSIA' THEN 'SOVIET UNION'
            WHEN UPPER(TRIM(COUNTRY_ORIGIN)) IN ('UNKNOWN OR NOT INDICATED', 'UNKNOWN', 'N/A') THEN NULL
            ELSE UPPER(TRIM(COUNTRY_ORIGIN))
        END AS pais_origen_norm,
        
        -- Objetivo limpio (Añadimos REPLACE para quitar las comillas de '"PAPUA NEW GUINEA, MANUS ISLAND"')
        CASE 
            WHEN UPPER(TRIM(REPLACE(TARGET_COUNTRY, '"', ''))) IN ('USA', 'UNITED STATES OF AMERICA', 'ALEUTIAN ISLANDS') THEN 'UNITED STATES'
            WHEN UPPER(TRIM(REPLACE(TARGET_COUNTRY, '"', ''))) IN ('GREAT BRITAIN', 'UK') THEN 'UNITED KINGDOM'
            WHEN UPPER(TRIM(REPLACE(TARGET_COUNTRY, '"', ''))) IN ('RUSSIA', 'USSR') THEN 'SOVIET UNION'
            WHEN UPPER(TRIM(REPLACE(TARGET_COUNTRY, '"', ''))) IN ('PHILIPPINE ISLANDS') THEN 'PHILIPPINES'
            WHEN UPPER(TRIM(REPLACE(TARGET_COUNTRY, '"', ''))) IN ('HOLLAND OR NETHERLANDS', 'NETHERLANDS EAST INDIES') THEN 'NETHERLANDS'
            WHEN UPPER(TRIM(REPLACE(TARGET_COUNTRY, '"', ''))) IN ('BISMARK ARCHIPELAGO', 'NEW GUINEA', 'PAPUA NEW GUINEA, MANUS ISLAND', 'NEW IRELAND', 'BOUGAINVILLE') THEN 'PAPUA AND NEW GUINEA'
            WHEN UPPER(TRIM(REPLACE(TARGET_COUNTRY, '"', ''))) IN ('CELEBES ISLANDS', 'BORNEO', 'JAVA', 'SUMATRA', 'SUMATRA MINING', 'INDONESIA', 'BALI') THEN 'DUTCH EAST INDIES'
            WHEN UPPER(TRIM(REPLACE(TARGET_COUNTRY, '"', ''))) IN ('FORMOSA AND RYUKYU ISLANDS', 'KURILE ISLANDS', 'JAPAN MINING') THEN 'JAPAN'
            WHEN UPPER(TRIM(REPLACE(TARGET_COUNTRY, '"', ''))) IN ('SOLOMON ISLANDS', 'CAROLINE ISLANDS', 'VOLCANO AND BONIN ISLANDS', 'MARSHALL ISLANDS', 'PALAU ISLANDS', 'GILBERT ISLANDS', 'MARCUS ISLANDS', 'WAKE ISLAND', 'CORAL SEA AREA', 'MARIANAS ISLANDS') THEN 'PACIFIC ISLANDS'
            WHEN UPPER(TRIM(REPLACE(TARGET_COUNTRY, '"', ''))) IN ('FRENCH INDO CHINA', 'FRENCH INDO CHINA MINING') THEN 'FRENCH INDOCHINA'
            WHEN UPPER(TRIM(REPLACE(TARGET_COUNTRY, '"', ''))) IN ('PANTELLARIA', 'SICILY', 'SARDINIA') THEN 'ITALY'
            WHEN UPPER(TRIM(REPLACE(TARGET_COUNTRY, '"', ''))) IN ('MALAY STATES', 'MALAY STATES MINING') THEN 'MALAYA & SINGAPORE'
            WHEN UPPER(TRIM(REPLACE(TARGET_COUNTRY, '"', ''))) IN ('CHINA MINING', 'MANCHURIA', 'FORMOSA') THEN 'CHINA'
            WHEN UPPER(TRIM(REPLACE(TARGET_COUNTRY, '"', ''))) IN ('KOREA OR CHOSEN', 'KOREA OR CHOSEN MINING') THEN 'KOREA'
            WHEN UPPER(TRIM(REPLACE(TARGET_COUNTRY, '"', ''))) IN ('THAILAND OR SIAM', 'THAILAND OR SIAM MINING') THEN 'THAILAND'
            WHEN UPPER(TRIM(REPLACE(TARGET_COUNTRY, '"', ''))) = 'CRETE' THEN 'GREECE'
            WHEN UPPER(TRIM(REPLACE(TARGET_COUNTRY, '"', ''))) = 'CORSICA' THEN 'FRANCE'
            WHEN UPPER(TRIM(REPLACE(TARGET_COUNTRY, '"', ''))) = 'ETHIOPIA/ABSINNYA' THEN 'ETHIOPIA'
            
            -- Territorios coloniales y mandatos
            WHEN UPPER(TRIM(REPLACE(TARGET_COUNTRY, '"', ''))) IN ('SYRIA', 'LEBANON', 'FRENCH WEST AFRICA', 'MADAGASCAR') THEN 'FRANCE'
            WHEN UPPER(TRIM(REPLACE(TARGET_COUNTRY, '"', ''))) IN ('CYPRUS', 'SUDAN') THEN 'UNITED KINGDOM'
            WHEN UPPER(TRIM(REPLACE(TARGET_COUNTRY, '"', ''))) IN ('ANDAMAN ISLANDS') THEN 'INDIA'
            WHEN UPPER(TRIM(REPLACE(TARGET_COUNTRY, '"', ''))) IN ('TIMOR') THEN 'PORTUGUESE TIMOR'
            
            WHEN UPPER(TRIM(REPLACE(TARGET_COUNTRY, '"', ''))) IN ('UNKNOWN OR NOT INDICATED', 'UNKNOWN', 'N/A', 'INDIAN OCEAN') THEN NULL
            ELSE UPPER(TRIM(REPLACE(TARGET_COUNTRY, '"', '')))
        END AS pais_objetivo_norm
    FROM stg_ops
    WHERE MISSION_DATE IS NOT NULL
),
operaciones_agrupadas AS (
    SELECT
        MISSION_DATE, pais_origen_norm, pais_objetivo_norm,
        UPPER(TRIM(AIRCRAFT_MODEL)) AS modelo_avion,
        UPPER(TRIM(AIR_FORCE)) AS fuerza_aerea,
        UPPER(TRIM(TARGET_TYPE)) AS tipo_objetivo,
        UPPER(TRIM(TARGET_INDUSTRY)) AS industria_objetivo,
        CAST(TAKEOFF_LATITUDE AS FLOAT) AS lat_origen,
        CAST(TAKEOFF_LONGITUDE AS FLOAT) AS lon_origen,
        CAST(TARGET_LATITUDE AS FLOAT) AS lat_objetivo,
        CAST(TARGET_LONGITUDE AS FLOAT) AS lon_objetivo,
        MAX(CAST(ALTITUDE_HUNDREDS_FEET AS FLOAT)) AS altitud_cientos_pies,
        SUM(CAST(TOTAL_TONS_BOMBS AS FLOAT)) AS total_toneladas_bombas
    FROM paises_normalizados
    GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11
)

SELECT
    {{ dbt_utils.generate_surrogate_key([
        'MISSION_DATE', 'pais_origen_norm', 'pais_objetivo_norm', 
        'modelo_avion', 'fuerza_aerea', 'tipo_objetivo', 'industria_objetivo',
        'lat_origen', 'lon_origen', 'lat_objetivo', 'lon_objetivo'
    ]) }} AS id_operacion,
    {{ dbt_utils.generate_surrogate_key(['MISSION_DATE']) }} AS id_fecha,
    
    CASE WHEN NULLIF(pais_origen_norm, '') IS NOT NULL THEN {{ dbt_utils.generate_surrogate_key(['pais_origen_norm']) }} ELSE NULL END AS id_pais_origen,
    CASE WHEN NULLIF(pais_objetivo_norm, '') IS NOT NULL THEN {{ dbt_utils.generate_surrogate_key(['pais_objetivo_norm']) }} ELSE NULL END AS id_pais_objetivo,
    CASE WHEN NULLIF(modelo_avion, '') IS NOT NULL OR NULLIF(fuerza_aerea, '') IS NOT NULL THEN {{ dbt_utils.generate_surrogate_key(['modelo_avion', 'fuerza_aerea']) }} ELSE NULL END AS id_aeronave,
    CASE WHEN NULLIF(tipo_objetivo, '') IS NOT NULL OR NULLIF(industria_objetivo, '') IS NOT NULL THEN {{ dbt_utils.generate_surrogate_key(['tipo_objetivo', 'industria_objetivo']) }} ELSE NULL END AS id_objetivo,

    altitud_cientos_pies,
    total_toneladas_bombas,
    lat_origen AS latitud_despegue,
    lon_origen AS longitud_despegue,
    lat_objetivo AS latitud_objetivo,
    lon_objetivo AS longitud_objetivo
FROM operaciones_agrupadas