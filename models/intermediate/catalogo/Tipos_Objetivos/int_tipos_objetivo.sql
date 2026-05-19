{{ config(materialized='table') }}

WITH stg_operaciones AS (
    SELECT * FROM {{ ref('stg_aerial_operations') }}
),

objetivos_unicos AS (
    -- Aplicamos el COALESCE aquí mismo para que las columnas ya nazcan limpias de nulos
    SELECT DISTINCT
        COALESCE(UPPER(TRIM(TARGET_TYPE)), 'UNKNOWN') AS tipo_objetivo,
        COALESCE(UPPER(TRIM(TARGET_INDUSTRY)), 'UNKNOWN') AS industria_objetivo
    FROM stg_operaciones
),

categorias_asignadas AS (
    SELECT 
        tipo_objetivo,
        industria_objetivo,
        CASE
            -- 1. Infraestructura Aérea
            WHEN tipo_objetivo LIKE '%AIRDROME%' OR tipo_objetivo LIKE '%AIRFIELD%' OR tipo_objetivo LIKE '%AIRCRAFT%' OR tipo_objetivo LIKE '%AVIATION%' OR tipo_objetivo LIKE '%RUNWAY%' OR industria_objetivo LIKE '%AIR%' THEN 'Infraestructura Aérea'
            
            -- 2. Infraestructura Ferroviaria
            WHEN tipo_objetivo LIKE '%RAIL%' OR tipo_objetivo LIKE '%TRAIN%' OR tipo_objetivo LIKE '%LOCOMOTIVE%' OR tipo_objetivo LIKE '%YARD%' OR industria_objetivo LIKE '%RAIL%' OR industria_objetivo LIKE '%TRACKS%' THEN 'Infraestructura Ferroviaria'
            
            -- 3. Infraestructura Vial y Puentes
            WHEN tipo_objetivo LIKE '%ROAD%' OR tipo_objetivo LIKE '%BRIDGE%' OR tipo_objetivo LIKE '%HIGHWAY%' OR tipo_objetivo LIKE '%VEHICLE%' OR tipo_objetivo LIKE '%TRANSPORT%' THEN 'Infraestructura Vial y Puentes'
            
            -- 4. Naval y Puertos
            WHEN tipo_objetivo LIKE '%PORT%' OR tipo_objetivo LIKE '%SHIP%' OR tipo_objetivo LIKE '%SUBMARINE%' OR tipo_objetivo LIKE '%NAVAL%' OR tipo_objetivo LIKE '%DOCK%' OR tipo_objetivo LIKE '%WATER%' OR tipo_objetivo LIKE '%PORTS%' THEN 'Infraestructura Naval y Puertos'
            
            -- 5. Defensas y Artillería
            WHEN tipo_objetivo LIKE '%GUN%' OR tipo_objetivo LIKE '%FLAK%' OR tipo_objetivo LIKE '%DEFENSE%' OR tipo_objetivo LIKE '%RADAR%' OR tipo_objetivo LIKE '%EMPLACEMENT%' THEN 'Defensas y Artillería'
            
            -- 6. Táctico y Tropas
            WHEN tipo_objetivo LIKE '%TROOP%' OR tipo_objetivo LIKE '%TACTICAL%' OR tipo_objetivo LIKE '%BIVOUAC%' OR tipo_objetivo LIKE '%CAMP%' OR industria_objetivo LIKE '%TACTICAL%' THEN 'Táctico y Tropas'
            
            -- 7. Combustible y Energía
            WHEN tipo_objetivo LIKE '%OIL%' OR tipo_objetivo LIKE '%FUEL%' OR tipo_objetivo LIKE '%GAS%' OR tipo_objetivo LIKE '%POWER%' OR industria_objetivo LIKE '%REFINER%' OR industria_objetivo LIKE '%UTILITIES%' THEN 'Combustible y Energía'
            
            -- 8. Industria Pesada
            WHEN tipo_objetivo LIKE '%FACTORY%' OR tipo_objetivo LIKE '%PLANT%' OR tipo_objetivo LIKE '%STEEL%' OR tipo_objetivo LIKE '%IRON%' OR tipo_objetivo LIKE '%WORKS%' OR industria_objetivo LIKE '%MANUFACTURING%' THEN 'Industria Pesada'
            
            -- 9. Suministros y Almacenamiento
            WHEN tipo_objetivo LIKE '%DUMP%' OR tipo_objetivo LIKE '%DEPOT%' OR tipo_objetivo LIKE '%STORAGE%' OR tipo_objetivo LIKE '%WAREHOUSE%' OR tipo_objetivo LIKE '%SUPPLY%' THEN 'Suministros y Almacenes'
            
            -- 10. Comunicaciones y Mando
            WHEN tipo_objetivo LIKE '%COMMUNICATION%' OR tipo_objetivo LIKE '%RADIO%' OR tipo_objetivo LIKE '%TELEPHONE%' OR tipo_objetivo LIKE '%HQ%' OR tipo_objetivo LIKE '%HEADQUARTER%' THEN 'Comunicaciones y Mando'
            
            -- 11. Zonas Civiles y Urbanas
            WHEN tipo_objetivo LIKE '%CITY%' OR tipo_objetivo LIKE '%TOWN%' OR tipo_objetivo LIKE '%VILLAGE%' OR tipo_objetivo LIKE '%BUILDING%' OR tipo_objetivo LIKE '%AREA%' THEN 'Zonas Urbanas y Civiles'
            
            -- 12. Desconocido
            ELSE 'Desconocido / Otros'
        END AS macro_categoria
    FROM objetivos_unicos
)

SELECT
    -- PK: Hash limpio pasando solo los nombres de las columnas
    {{ dbt_utils.generate_surrogate_key(['tipo_objetivo', 'industria_objetivo']) }} AS id_objetivo,
    
    tipo_objetivo,
    industria_objetivo,
    macro_categoria

FROM categorias_asignadas