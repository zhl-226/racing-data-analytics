-- =============================================================================
-- market_calibration  (TODO — complete this)
-- =============================================================================
-- Purpose: a probability-calibration curve — the same idea as your model
-- calibration work, done in pure SQL. Shows whether the market's implied
-- probability (market_prob) matches the observed win frequency.
--
-- Depends on: {{ ref('fct_race_results') }}
--
-- SPEC (one row per 0.1-wide probability bucket):
--   bucket         the bin label, e.g. '0.10-0.20'
--   avg_predicted  avg(market_prob) in the bucket
--   n_runs         count
--   avg_observed   avg(won) in the bucket  (the actual win frequency)
--
-- A well-calibrated market has avg_predicted ~= avg_observed in every bucket.
--
-- HINTS:
--   - Build the bucket with a CTE, e.g.
--       floor(market_prob * 10) / 10  as bucket_low
--   - Then group by bucket_low and label it with string concat.
--   - Filter to rows where market_prob is not null.
-- =============================================================================

with fct as (
    select * from {{ ref('fct_race_results') }}
    where market_prob is not null
),

binned as (
    select
        market_prob,
        won,
        floor(market_prob * 10)/10 as bucket_low
    from fct
)

select
    bucket_low,
    round(bucket_low, 1)::varchar || '-' || round((bucket_low+0.1),1)::varchar as bucket_label,
    count(*)                    as n_runs,
    round(avg(market_prob), 4)  as avg_predicted,
    round(avg(won), 4)          as avg_observed
from binned
group by bucket_low
order by bucket_low
