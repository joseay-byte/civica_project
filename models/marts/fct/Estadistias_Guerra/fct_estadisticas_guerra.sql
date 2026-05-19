{{ config(
    materialized='table',
    schema='gold'
) }}

with estadisticas_silver as (
    select * from {{ ref('int_estadisticas_guerra_paises') }}
)

select
    id_estadistica,
    
    id_pais,
    
    poblacion_1939,
    muertes_militares,
    muertes_civiles,
    muertes_totales,
    heridos_militares,
    
    porcentaje_muertes_poblacion
from estadisticas_silver