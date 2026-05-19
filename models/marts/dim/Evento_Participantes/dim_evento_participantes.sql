{{ config(
    materialized='table',
    schema='gold'
) }}

with puente_silver as (
    select * from {{ ref('int_evento_participantes') }}
)

select
    id_evento_participante,
    id_evento,
    id_pais,
    bando
from puente_silver