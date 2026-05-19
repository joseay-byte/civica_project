{{ config(
    materialized='table',
    schema='gold'
) }}

with operaciones_silver as (
    select * from {{ ref('int_operaciones_aereas') }}
)

select
    id_operacion,
    
    id_fecha,
    id_pais_origen,
    id_pais_objetivo,
    id_aeronave,
    id_objetivo,
    
    altitud_cientos_pies,
    total_toneladas_bombas,
    -- Eliminamos latitud y longitud del despegue porque la gran mayoria son nulls
    -- latitud_despegue,
    -- longitud_despegue,
    latitud_objetivo,
    longitud_objetivo
from operaciones_silver