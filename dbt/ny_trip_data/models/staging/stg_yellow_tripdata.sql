{{config(materialized='view') }}

select 
    -- identifiers
    {{ dbt_utils.surrogate_key(['vendorid', 'tpep_pickup_datetime' ]) }} as tripid,
    cast(vendorid as integer) as vendorid,
    cast(ratecodeid as integer) as ratecodeid,
    cast(pulocationid as integer) as pickup_locationid,
    cast(dolocationid as integer) as dolocationid,

    -- timestamp
    cast(tpep_pickup_datetime as timestamp) as pickup_datetime,
    cast(tpep_dropoff_datetime as timestamp) as dropoff_datetime,
    
    -- trip info
    store_and_fwd_flag,
    cast(passenger_count as integer) as passenger_count,
    cast(trip_distance as numeric) as trip_distance,
    
    -- payment info
    cast(fare_amount as numeric) as fare_amount,
    cast(extra as numeric) as extra,
    cast(mta_tax as numeric) as mta_tax,
    cast(tip_amount as numeric) as tip_amount,
    cast(tolls_amount as numeric) as tolls_amount,
    improvement_surcharge,
    cast(payment_type as integer) as payment_type,
    {{ get_payment_type_description("payment_type") }} as payment_type_desc,
    cast(congestion_surcharge as integer) as congestion_surcharge,
    cast(airport_fee as integer) as airport_fee
from {{ source('staging', 'rides') }}
where vendorid is not null

{% if var('is_test_run', default=true) %}

limit 100

{% endif %}
