-- =============================================================================
-- stg_races  (WORKED EXAMPLE — leave as-is, study the pattern)
-- =============================================================================
-- Purpose: take the denormalized raw seed (one row per HORSE per RACE) and
-- reduce it to one row per RACE. This is the first "normalization" step.
--
-- The source has race-level columns repeated on every horse's row. Because they
-- are constant within a race_id, `max()` acts as an "any value" picker inside
-- the GROUP BY. This is the standard dbt pattern for de-duplicating.
-- =============================================================================

with source as (
    select * from {{ ref('races_sample') }}
),

races as (
    select
        race_id,

        -- Race identity
        max(race_number) as race_number,
        max(race_name)   as race_name,
        max(org)         as organization,

        -- Course / conditions (constant per race)
        max(course_id)  as course_id,
        max(surface)    as surface_code,
        max(direction)  as direction_code,
        max(distance)   as distance_m,

        -- Scheduling
        max(year)  as race_year,
        max(month) as race_month,
        max(day)   as race_day,
        cast(max(date) as date) as race_date,

        -- Field
        max(num_horses) as num_horses

    from source
    group by 1
)

select * from races
