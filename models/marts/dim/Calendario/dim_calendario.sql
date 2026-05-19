{{ config(
    materialized='table',
    schema='gold'
) }}

with calendario_silver as (
    select * from {{ ref('int_calendario') }}
)

select
    id_fecha,
    fecha_completa,
    anio as anio_operacion,
    mes as numero_mes,
    nombre_mes,
    dia as dia_mes,
    trimestre
from calendario_silver