{{ config(
    materialized='table',
    schema='gold'
) }}

with objetivos_silver as (
    select * from {{ ref('int_tipos_objetivo') }}
)

select
    id_objetivo,
    tipo_objetivo,
    industria_objetivo
from objetivos_silver