{{ config(schema='GOLDEN', materialized='table',
post_hook=[
    "alter table {{ this }} drop constraint if exists pk_dim_species",
    "alter table {{ this }} add constraint pk_dim_species primary key (species_id)"
  ]
    ) }}

with s as (
  select distinct
    scientific_name,
    common_name,
    family,
    genus
  from {{ ref('staging_species') }}
)

select
  md5(coalesce(scientific_name,'') || '|' || coalesce(common_name,'')) as species_id,  
  scientific_name,
  common_name,
  family,
  genus
from s