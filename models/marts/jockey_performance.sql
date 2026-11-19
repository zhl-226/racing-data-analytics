-- =============================================================================
-- jockey_performance  (done)
-- =============================================================================
-- Purpose: aggregate a jockey's results from the wide fact.
--
-- Depends on: {{ ref('fct_race_results') }}
--
-- SPEC (one row per jockey_id):
--   jockey_id, jockey
--   n_rides        count of runners
--   n_wins         sum(won)
--   win_rate       avg(won)
--   avg_win_odds   avg(win_odds)
--   roi_pct        (avg(win_return) - 1) * 100
--   top3_rate      avg(placed)
--
-- Bonus: add a HAVING clause or WHERE to keep only jockeys with >= 50 rides so
-- the numbers aren't noise from one-off riders.
-- =============================================================================

with fct as (
    select * from {{ ref('fct_race_results') }}
)

select
    jockey_id,
    max(jockey) as jockey,
    count(*)    as n_rides,
    sum(won)    as n_wins,
    avg(won)    as win_rate,
    avg(win_odds)           as avg_win_odds,
    (avg(win_return)-1)*100 as roi_pct,
    avg(placed) as top3_rate
from fct
group by jockey_id
having count(*) >= 50
order by roi_pct desc

