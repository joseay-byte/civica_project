{{ config(materialized='table') }}

WITH stg_events AS (
    SELECT * FROM {{ ref('stg_events') }} WHERE EVENT_NAME != 'Event'
),
aliados AS (
    SELECT EVENT_NAME, EVENT_DATE_RAW, TRIM(f.value::STRING) AS pais_crudo, 'ALLIED' AS bando
    FROM stg_events, LATERAL FLATTEN(input => SPLIT(ALLIED_PARTICIPANTS, ',')) f
    WHERE ALLIED_PARTICIPANTS IS NOT NULL AND ALLIED_PARTICIPANTS NOT IN ('N/A', 'None')
),
eje AS (
    SELECT EVENT_NAME, EVENT_DATE_RAW, TRIM(f.value::STRING) AS pais_crudo, 'AXIS' AS bando
    FROM stg_events, LATERAL FLATTEN(input => SPLIT(AXIS_PARTICIPANTS, ',')) f
    WHERE AXIS_PARTICIPANTS IS NOT NULL AND AXIS_PARTICIPANTS NOT IN ('N/A', 'None')
),
todos_participantes AS (
    SELECT * FROM aliados UNION ALL SELECT * FROM eje
),
paises_normalizados AS (
    SELECT
        EVENT_NAME, EVENT_DATE_RAW, bando,
        CASE 
            WHEN UPPER(TRIM(SPLIT_PART(pais_crudo, '(', 1))) IN ('USA', 'UNITED STATES OF AMERICA') THEN 'UNITED STATES'
            WHEN UPPER(TRIM(SPLIT_PART(pais_crudo, '(', 1))) IN ('UK', 'GREAT BRITAIN', 'ENGLAND') THEN 'UNITED KINGDOM'
            WHEN UPPER(TRIM(SPLIT_PART(pais_crudo, '(', 1))) IN ('RUSSIA', 'USSR', 'SOVIET UNION WITH VARIOUS FACTIONS', 'GEORGIAN RESISTANCE') THEN 'SOVIET UNION'
            WHEN UPPER(TRIM(SPLIT_PART(pais_crudo, '(', 1))) IN ('REPUBLIC OF CHINA', 'MANCHUKUO') THEN 'CHINA'
            WHEN UPPER(TRIM(SPLIT_PART(pais_crudo, '(', 1))) IN ('FRENCH RESISTANCE', 'VICHY FRANCE', 'FREE FRANCE') THEN 'FRANCE'
            WHEN UPPER(TRIM(SPLIT_PART(pais_crudo, '(', 1))) IN ('SPANISH NATIONALISTS', 'SPANISH REPUBLICANS') THEN 'SPAIN'
            WHEN UPPER(TRIM(SPLIT_PART(pais_crudo, '(', 1))) = 'GERMAN RESISTANCE' THEN 'GERMANY'
            WHEN UPPER(TRIM(SPLIT_PART(pais_crudo, '(', 1))) = 'ITALIAN RESISTANCE' THEN 'ITALY'
            WHEN UPPER(TRIM(SPLIT_PART(pais_crudo, '(', 1))) IN ('POLISH RESISTANCE', 'POLISH JEWISH RESISTANCE') THEN 'POLAND'
            WHEN UPPER(TRIM(SPLIT_PART(pais_crudo, '(', 1))) IN ('SLOVAKIA', 'SLOVAK RESISTANCE') THEN 'CZECHOSLOVAKIA'
            WHEN UPPER(TRIM(SPLIT_PART(pais_crudo, '(', 1))) IN ('ALLIES', 'AXIS', 'N/A', 'NONE', 'UNKNOWN') THEN NULL
            ELSE UPPER(TRIM(SPLIT_PART(pais_crudo, '(', 1)))
        END AS pais_norm
    FROM todos_participantes WHERE pais_crudo != ''
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['EVENT_NAME', 'EVENT_DATE_RAW', 'pais_norm']) }} AS id_evento_participante,
    {{ dbt_utils.generate_surrogate_key(['EVENT_NAME', 'EVENT_DATE_RAW']) }} AS id_evento,
    
    CASE WHEN NULLIF(pais_norm, '') IS NOT NULL THEN {{ dbt_utils.generate_surrogate_key(['pais_norm']) }} ELSE NULL END AS id_pais,
    MAX(bando) AS bando
FROM paises_normalizados
WHERE pais_norm IS NOT NULL
GROUP BY 1, 2, 3