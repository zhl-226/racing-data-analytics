-- =============================================================================
-- horse_recent_form  (BONUS — window functions)
-- =============================================================================
-- Purpose: one row per runner, enriched with that horse's PRIOR form using
-- window functions. This is the single most-asked SQL topic in interviews.
--
-- Depends on: {{ ref('fct_race_results') }}
--
-- Window functions aggregate "over a window of rows" WITHOUT collapsing the
-- result (unlike GROUP BY, which shrinks to one row per group). Three parts:
--   PARTITION BY  = the "group" (here: one horse)
--   ORDER BY      = the row order inside the partition (here: race date)
--   frame         = which rows the function can see (e.g. "last 5 rows")
--
-- SPEC (output columns):
--   race_id, horse_id, race_date, finish_rank,
--   race_order         row_number() over (partition by horse_id order by race_date, race_id)
--                          -> 1 = first career race, 2 = second, ...
--   prev_finish_rank   lag(finish_rank) over (same partition/order)
--                          -> this horse's finish rank in its PREVIOUS race
--   prev_won           lag(won) over (same)
--   rolling_win_rate_5 avg(won) over (same partition/order,
--                          rows between 4 preceding and current row)
--                          -> win rate over the horse's last 5 races
--
-- NOTES:
--   lag(...) returns NULL on a horse's very first race (no "previous") — correct.
--   race_date is not unique per horse (a horse may run once per day), so the
--   ORDER BY uses (race_date, race_id) as a stable tiebreaker.
-- =============================================================================

with fct as (
    select race_id, horse_id, race_date, finish_rank, won
    from {{ ref('fct_race_results') }}
),

with_form as (
    select
        race_id,
        horse_id,
        race_date,
        finish_rank,

        row_number() over (partition by horse_id order by race_date, race_id) as race_order,
        lag(finish_rank) over (partition by horse_id order by race_date, race_id) as prev_finish_rank,
        lag(won) over (partition by horse_id order by race_date, race_id) as prev_won,

        avg(won) over (partition by horse_id order by race_date, race_id
                       rows between 4 preceding and current row)
                       as rolling_win_rate_5
    from fct
)

select * from with_form
