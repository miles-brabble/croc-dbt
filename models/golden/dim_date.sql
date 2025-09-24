{{ config(schema='GOLDEN', materialized='table',
post_hook=[
    "alter table {{ this }} drop constraint if exists pk_dim_date",
    "alter table {{ this }} add constraint pk_dim_date primary key (date_id)"
  ]
) }}

with d as (
  select distinct date_of_observation::date as dte
  from {{ ref('staging_croc') }}
  where date_of_observation is not null
)

select
  (extract(year from dte)::int * 10000
   + extract(month from dte)::int * 100
   + extract(day   from dte)::int)                             as date_id,   
  dte                                                          as date,
  extract(year  from dte)::int                                 as year,
  extract(month from dte)::int                                 as month,
  to_char(dte, 'Dy')                                           as day_name,
  to_char(dte, 'Mon')                                          as month_name,
  date_trunc('week', dte)::date                                as week_start
from d
