-- Scratch space: put ONE query here, then run:
--     .venv/bin/python scripts/practice.py
--
-- Tables available (after `dbt seed && dbt run`):
--   analytics.races_sample            <- 10k raw runner rows (richest for practice)
--   analytics.courses                 <- 25 course routes
--   analytics_staging.stg_races       <- 1 row per race
--   analytics_staging.stg_results     <- 1 row per runner (fact grain)
--   analytics_marts.race_counts_by_course

-- Example:
select count(*) as n_rows from analytics.races_sample;
