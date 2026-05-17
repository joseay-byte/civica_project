{{ config(
    materialized='table',
    schema='gold'
) }}

with clima_silver as (
    select * from {{ ref('int_clima_diario') }}
)

select
    id_registro_clima,
    
    id_estacion,
    id_fecha,
    
    temp_max_c,
    temp_min_c,
    temp_media_c,
    precipitacion_mm,
    nevada_mm
from clima_silver