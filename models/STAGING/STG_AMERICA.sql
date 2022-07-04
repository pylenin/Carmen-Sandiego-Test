{% set COUNTRY = 'AMERICA' %}
{% set column_list = add_column_names(seed=COUNTRY) %}


select 
	{% for i in range(column_list|length) %}
	  CAST("{{column_list[i]}}" AS {{get_column_dictionary(i, 1)}}) AS {{get_column_dictionary(i,0)}}{% if not loop.last -%},{% endif -%} 		
	{% endfor %}
FROM {{ref(COUNTRY)}}
