{{ config(
    materialized='table',
    schema='gold'
) }}

with paises_silver as (
    select * from {{ ref('int_paises') }}
)

select
    id_pais,
    nombre_pais,
    codigo_pais,
    continente,
    codigo_iso3,
    bando_principal
from paises_silver