{{ config(schema='GOLDEN', materialized='table',
post_hook=[
    "alter table {{ this }} drop constraint if exists pk_dim_observer",
    "alter table {{ this }} add constraint pk_dim_observer primary key (observer_id)"
  ]
) }}

with s as (
  select distinct observer_name
  from {{ ref('staging_croc') }}
  where observer_name is not null
)

select
  md5(coalesce(observer_name,'')) as observer_id,  -- PK
  observer_name
from s