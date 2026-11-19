-- =============================================================================
-- race_counts_by_course  (WORKED EXAMPLE — leave as-is, study the pattern)
-- =============================================================================
-- Purpose: a simple aggregate mart — one row per course route, with basic
-- descriptive stats. Depends only on stg_races, so it runs end-to-end today.
--
-- Note the use of {{ ref('stg_races') }}: dbt resolves this to the staging model
-- and builds a dependency graph automatically (run order, lineage, docs).
-- =============================================================================

with races as (
    select * from {{ ref('stg_races') }}
),

by_course as (
    select
        course_id,
        count(*)            as n_races,
        avg(distance_m)     as avg_distance_m,
        avg(num_horses)     as avg_field_size,
        min(race_date)      as first_race_date,
        max(race_date)      as last_race_date
    from races
    group by 1
)

select * from by_course
