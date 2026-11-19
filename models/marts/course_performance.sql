-- =============================================================================
-- course_performance  (done)
-- =============================================================================
-- Purpose: performance metrics per course route, from the wide fact.
--
-- Depends on: {{ ref('fct_race_results') }}
--
-- SPEC (one row per course_id):
--   course_id
--   n_runs        count of runners
--   n_races       count of distinct race_id
--   win_rate      avg(won)            (0..1)
--   avg_win_odds  avg(win_odds)
--   avg_market_prob  avg(market_prob)
--   roi_pct       (avg(win_return) - 1) * 100   -- % profit on 1-unit win bets
--
-- WHY this matters for an interview: win_rate vs market_prob shows whether the
-- market is calibrated per course; roi_pct shows if any course is systematically
-- mispriced. Same skills as your UQ/calibration work.
-- =============================================================================

with fct as (
    select * from {{ ref('fct_race_results') }}
)

select
    course_id,
    count(*)                as n_runs,
    count(distinct race_id) as n_races,
    avg(won)                as win_rate,
    avg(win_odds)           as avg_win_odds,
    avg(market_prob)        as avg_market_prob,
    (avg(win_return)-1)*100 as roi_pct

from fct
group by course_id
order by roi_pct desc
