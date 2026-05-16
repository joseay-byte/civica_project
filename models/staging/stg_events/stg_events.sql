{{ config(materialized='view') }}

WITH source AS (
    SELECT * FROM {{ source('raw_data', 'RAW_EVENTS') }}
),

renamed_and_cast AS (
    SELECT
        -- Nombre del evento (Batalla, Tratado, etc.)
        TRIM(Event) AS event_name,
        
        -- Mantenemos la fecha como texto porque contiene rangos (ej. 1939 - 1945)
        TRIM(Date) AS event_date_raw,
        
        -- Participantes de cada bando
        TRIM(Participants_Allies) AS allied_participants,
        TRIM(Participants_Axis) AS axis_participants,
        
        -- Normalizamos el bando ganador y el teatro de operaciones a mayúsculas
        UPPER(TRIM(Winner_Side)) AS winner_side,
        UPPER(TRIM(Theater)) AS theater,
        
        -- Tipo de evento (Battle, Treaty, War, etc.)
        TRIM(Type) AS event_type
        
    FROM source
)

SELECT * FROM renamed_and_cast
WHERE event_name != 'Event'