{{ config(materialized='view') }}

WITH source AS (
    SELECT * FROM {{ source('raw_data', 'RAW_AERIAL_OPERATIONS') }}
),

renamed_and_cast AS (
    SELECT
        -- Fechas
        CAST(Mission_Date AS DATE) AS mission_date,
        
        -- Origen
        TRIM(Country) AS country_origin,
        TRIM(Takeoff_Base) AS takeoff_base,
        TRIM(Takeoff_Location) AS takeoff_location_name,
        TRY_CAST(Takeoff_Latitude AS FLOAT) AS takeoff_latitude,
        TRY_CAST(Takeoff_Longitude AS FLOAT) AS takeoff_longitude,
        
        -- Objetivo
        TRIM(Target_Country) AS target_country,
        TRIM(Target_City) AS target_city,
        TRIM(Target_Type) AS target_type,
        TRIM(Target_Industry) AS target_industry,
        TRY_CAST(Target_Latitude AS FLOAT) AS target_latitude,
        TRY_CAST(Target_Longitude AS FLOAT) AS target_longitude,
        
        -- Datos Técnicos
        TRIM(Air_Force) AS air_force,
        TRIM(Aircraft_Series) AS aircraft_model,
        CAST(Altitude_Hundreds_of_Feet AS FLOAT) AS altitude_hundreds_feet,
        
        -- Peso total
        TRY_CAST(Total_Weight_Tons AS FLOAT) AS total_tons_bombs
        
    FROM source
)

SELECT * FROM renamed_and_cast
