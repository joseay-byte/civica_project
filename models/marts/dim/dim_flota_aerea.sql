{{ config(
    materialized='table',
    schema='gold'
) }}

with flota_silver as (
    select * from {{ ref('int_flota_aerea') }}
)

select
    id_aeronave,
    modelo_aeronave,
    fuerza_aerea
from flota_silver