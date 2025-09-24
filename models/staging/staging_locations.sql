{{ config(schema='STAGING', materialized='table') }}

select distinct
    initcap(trim("Country/Region")) as country_region
from {{ ref('crocodile_species') }}
where "Country/Region" is not null