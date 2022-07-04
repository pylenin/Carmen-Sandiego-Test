SELECT 'ASIA' AS GEOGRAPHY, *
FROM {{ref('STG_ASIA')}}

UNION ALL

SELECT 'PACIFIC' AS GEOGRAPHY, *
FROM {{ref('STG_PACIFIC')}}

UNION ALL

SELECT 'INDIAN' AS GEOGRAPHY, *
FROM {{ref('STG_INDIAN')}}

UNION ALL

SELECT 'EUROPE' AS GEOGRAPHY, *
FROM {{ref('STG_EUROPE')}}

UNION ALL

SELECT 'AUSTRALIA' AS GEOGRAPHY, *
FROM {{ref('STG_AUSTRALIA')}}

UNION ALL

SELECT 'ATLANTIC' AS GEOGRAPHY, *
FROM {{ref('STG_ATLANTIC')}}

UNION ALL

SELECT 'AFRICA' AS GEOGRAPHY, *
FROM {{ref('STG_AFRICA')}}

UNION ALL

SELECT 'AMERICA' AS GEOGRAPHY, *
FROM {{ref('STG_AMERICA')}}

