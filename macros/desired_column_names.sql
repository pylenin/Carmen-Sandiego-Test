{% macro get_column_dictionary(column_index, position) %}

{% set desired_column_names = 
[
	('date_witness', 'date'), 
	('date_agent', 'date'), 
	('witness', 'string'), 
	('agent', 'string'), 
	('latitude','float'), 
	('longitude', 'float'), 
	('city', 'string'), 
	('country', 'string'), 
	('city_agent', 'string'), 
	('has_weapon', 'boolean'), 
	('has_hat', 'boolean'), 
	('has_jacket', 'boolean'), 
	('behavior', 'string')
]
%}

{{return(desired_column_names[column_index][position])}}

{% endmacro %}
