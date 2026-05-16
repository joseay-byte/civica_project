{% macro generate_database_name(custom_database_name, node) %}

    {%- if target.name == 'prod' or target.name == 'pro' -%}
        {%- if custom_database_name is not none -%}
            {{ custom_database_name | replace('DEV', 'PRO') | trim }}
        {%- else -%}
            {{ target.database | trim }}
        {%- endif -%}
    {%- else -%}
        {%- if custom_database_name is not none -%}
            {{ custom_database_name | trim }}
        {%- else -%}
            {{ target.database | trim }}
        {%- endif -%}
    {%- endif -%}

{% endmacro %}