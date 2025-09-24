{{ config(schema='GOLDEN', materialized='table',
  post_hook=[
    "alter table {{ this }} drop constraint if exists fk_fact_species",
    "alter table {{ this }} add constraint fk_fact_species foreign key (species_id) references {{ ref('dim_species') }}(species_id)",
    "alter table {{ this }} drop constraint if exists fk_fact_location",
    "alter table {{ this }} add constraint fk_fact_location foreign key (location_id) references {{ ref('dim_location') }}(location_id)",
    "alter table {{ this }} drop constraint if exists fk_fact_date",
    "alter table {{ this }} add constraint fk_fact_date foreign key (date_id) references {{ ref('dim_date') }}(date_id)",
    "alter table {{ this }} drop constraint if exists fk_fact_status",
    "alter table {{ this }} add constraint fk_fact_status foreign key (status_id) references {{ ref('dim_conservation_status') }}(status_id)",
    "alter table {{ this }} drop constraint if exists fk_fact_observer",
    "alter table {{ this }} add constraint fk_fact_observer foreign key (observer_id) references {{ ref('dim_observer') }}(observer_id)"
  ]
)}}

with s as (
  select *
  from {{ ref('staging_croc') }}
),
sp as (
  select species_id, scientific_name, common_name
  from {{ ref('dim_species') }}
),
lo as (
  select location_id, country_region
  from {{ ref('dim_location') }}
),
dt as (
  select date_id, date
  from {{ ref('dim_date') }}
),
st as (
  select status_id, conservation_status
  from {{ ref('dim_conservation_status') }}
),
ob as (
  select observer_id, observer_name
  from {{ ref('dim_observer') }}
)

select
  -- FKs into dims
  sp.species_id,
  lo.location_id,
  dt.date_id,
  st.status_id,
  ob.observer_id,

  -- degenerate/natural keys & measures
  s.observation_id,                       -- natural key from source
  s.observed_length_m,
  s.observed_weight_kg,

  -- optional descriptive attrs (keep in fact if useful)
  s.sex,
  s.habitat_type,

  -- audit
  s.load_ts

from s
left join sp on sp.scientific_name = s.scientific_name
left join lo on lo.country_region  = s.country_region
left join dt on dt.date            = s.date_of_observation::date
left join st on st.conservation_status = s.conservation_status
left join ob on ob.observer_name   = s.observer_name