{% macro add_column_names(seed='AMERICA') %}

{% set macro_query %}
SELECT * FROM {{ref(seed)}}
{% endset %}

{% set results = run_query(macro_query) %}
  
{% if execute %}
{# Return the first column #}
{% set column_list = results.columns.keys() %}
{% else %}
{% set column_list = [] %}
{% endif %}

{{return(column_list)}}

{% endmacro %}
