{{ config(schema='GOLDEN', materialized='table',
post_hook=[
    "alter table {{ this }} drop constraint if exists pk_dim_conservation_status",
    "alter table {{ this }} add constraint pk_dim_conservation_status primary key (status_id)"
  ]
) }}

with s as (
  select distinct conservation_status
  from {{ ref('staging_croc') }}
  where conservation_status is not null
)

select
  md5(coalesce(conservation_status,'')) as status_id,  -- PK
  conservation_status
from s