{{ config(schema='STAGING', materialized='table') }}

select distinct
    trim("Scientific Name") as scientific_name,
    trim("Common Name")     as common_name,
    trim("Family")          as family,
    trim("Genus")           as genus
from {{ ref('crocodile_species') }}
where "Scientific Name" is not null