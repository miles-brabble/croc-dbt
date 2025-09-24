{{ config(schema='GOLDEN', materialized='table',
post_hook=[
    "alter table {{ this }} drop constraint if exists pk_dim_location",
    "alter table {{ this }} add constraint pk_dim_location primary key (location_id)"
  ]
) }}

with s as (
  select distinct
    country_region
  from {{ ref('staging_locations') }}
)

select
  md5(coalesce(country_region,'')) as location_id,  -- PK
  country_region
from s