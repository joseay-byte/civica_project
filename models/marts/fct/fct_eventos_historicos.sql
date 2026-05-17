{{ config(
    materialized='table',
    schema='gold'
) }}

with eventos_silver as (
    select * from {{ ref('int_eventos_historicos') }}
)

select
    id_evento,
    
    id_fecha_inicio,
    
    -- Nota de diseño: Al ser el evento la entidad principal de esta estrella, 
    -- actuarán como una "Dimensión Degenerada" dentro de la misma tabla de hechos.
    nombre_evento,
    teatro_operaciones,
    tipo_evento,
    bando_ganador
from eventos_silver