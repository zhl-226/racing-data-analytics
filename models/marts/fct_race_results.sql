-- =============================================================================
-- fct_race_results  (done)
-- =============================================================================
-- Purpose: the core wide fact table — one row per runner, enriched with the
-- race and course dimensions. This is what every downstream mart reads.
--
-- JOIN logic:
--   stg_results r  (fact)
--     LEFT JOIN stg_races    ra ON ra.race_id    = r.race_id
--     LEFT JOIN stg_courses  c  ON c.course_id   = ra.course_id
--
-- SPEC (output columns — choose a consistent naming scheme):
--   race_id, race_date, race_name, organization, race_number,
--   course_id, surface, direction, distance_m,
--   horse_id, horse_name, sex, age,
--   jockey_id, jockey, trainer_id, trainer,
--   finish_rank, finish_time, margin, final_600m,
--   win_odds, popularity, won, placed, win_return, market_prob, market_log
--
-- HINTS:
--   - Qualify every column with its alias (r.race_id, ra.race_name, ...) to
--     avoid ambiguous-column errors.
--   - If two models expose the same column name (e.g. both have course_id),
--     pick ONE source in the SELECT list.
-- =============================================================================

with results as (
    select * from {{ ref('stg_results') }}
),
races as (
    select * from {{ ref('stg_races') }}
),
courses as (
    select * from {{ ref('stg_courses') }}
)

select
    -- Fact (r.)
    r.race_id,
    r.horse_id,
    r.horse_name,
    r.sex,
    r.age,
    r.jockey_id,
    r.jockey,
    r.trainer_id,
    r.trainer,
    r.finish_rank,
    r.finish_time,
    r.margin,
    r.final_600m,
    r.win_odds,
    r.popularity,
    r.won,
    r.placed,
    r.win_return,
    r.market_prob,
    r.market_log,

    -- Race dim (ra.)
    ra.race_number,
    ra.race_name,
    ra.organization,
    ra.race_date,
    ra.course_id,

    -- Course dim (c.)
    c.surface,
    c.direction,
    c.distance_m

from results r
left join races     ra on ra.race_id    = r.race_id
left join courses   c  on c.course_id   = ra.course_id