{{ config(materialized='table') }}

with yellow_data as (
  select
    *,
    'Yellow' as service_type
  from
    {{ ref("stg_yellow_tripdata") }}
),
dim_zone as (
  select * from {{ ref("dim_zones") }}
  where borough != 'Unknown'
)
select 
    yd.tripid, 
    yd.vendorid, 
    yd.service_type,
    yd.ratecodeid,
    yd.pickup_locationid, 
    dz.borough as pickup_borough, 
    dz.zone as pickup_zone, 
    --yd.dropoff_locationid,
    dz.borough as dropoff_borough, 
    dz.zone as dropoff_zone,  
    yd.pickup_datetime, 
    yd.dropoff_datetime, 
    yd.store_and_fwd_flag, 
    yd.passenger_count, 
    yd.trip_distance, 
    --yd.trip_type, 
    yd.fare_amount, 
    yd.extra, 
    yd.mta_tax, 
    yd.tip_amount, 
    yd.tolls_amount, 
    --yd.ehail_fee, 
    yd.improvement_surcharge, 
    --yd.total_amount, 
    yd.payment_type, 
    yd.payment_type_desc, 
    yd.congestion_surcharge 
from yellow_data as yd
inner join dim_zone as dz
on yd.pickup_locationid = dz.locationid
