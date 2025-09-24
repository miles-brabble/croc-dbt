{{ config(schema='STAGING', materialized='table') }}

with src as (
select *
    from {{ ref('crocodile_species') }}
   
),

clean as (
    select
        "Observation ID"::integer                      as observation_id,
        trim("Common Name")                            as common_name,
        trim("Scientific Name")                        as scientific_name,
        trim("Family")                                 as family,
        trim("Genus")                                  as genus,
        "Observed Length (m)"::float as observed_length_m,
        "Observed Weight (kg)"::float as observed_weight_kg,
        trim("Age Class")                              as age_class,
        trim("Sex")                                    as sex_raw,
        to_date(trim("Date of Observation"), 'DD-MM-YYYY') as date_of_observation,
        trim("Country/Region")                         as country_region,
        trim("Habitat Type")                           as habitat_type_raw,
        trim("Conservation Status")                    as conservation_status_raw,
        trim("Observer Name")                          as observer_name,
        nullif(trim("Notes"), '')                      as notes
    from src
),

normalized as (
    select
        observation_id,
        common_name,
        scientific_name,
        family,
        genus,
        observed_length_m,
        observed_weight_kg,
        case lower(sex_raw)
            when 'm' then 'Male'
            when 'f' then 'Female'
            else initcap(sex_raw)
        end as sex,

        date_of_observation,
        initcap(country_region) as country_region, 
        case
            when lower(habitat_type_raw) like '%swamp%' then 'Swamp'
            when lower(habitat_type_raw) like '%river%' then 'River'
            when lower(habitat_type_raw) like '%lake%'  then 'Lake'
            else initcap(habitat_type_raw)
        end as habitat_type,
        case lower(conservation_status_raw)
            when 'least concern' then 'Least Concern'
            when 'near threatened' then 'Near Threatened'
            when 'vulnerable' then 'Vulnerable'
            when 'endangered' then 'Endangered'
            when 'critically endangered' then 'Critically Endangered'
            else initcap(conservation_status_raw)
        end as conservation_status,
        observer_name,
        notes,
        (observed_length_m is null or observed_weight_kg is null) as is_missing_measurement,
        (date_of_observation is null)                             as is_missing_date,
        now()::timestamp                                         as load_ts,
        'RAW'                               as source_table
    from clean
)

select * from normalized
