{{ config(
    materialized='table',
    schema='gold'
) }}

with estaciones_silver as (
    select * from {{ ref('int_estaciones_clima') }}
)

select
    id_estacion,
    id_pais,
    nombre_estacion,
    elevacion,
    latitud,
    longitud
from estaciones_silver