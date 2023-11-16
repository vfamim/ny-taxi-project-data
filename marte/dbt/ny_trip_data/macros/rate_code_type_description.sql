{# 
  This macro returns the description of the ratecodeid 
#}

{% macro rate_code_type_description(ratecodeid) -%}

  case {{ ratecodeid }} 
    when 1.0 then 'Standard rate'
    when 2.0 then 'JFK'
    when 3.0 then 'Newark'
    when 4.0 then 'Nassau or Westchester'
    when 5.0 then 'Negotiated fare'
    when 6.0 then 'Group ride'
  end

{%- endmacro %}

