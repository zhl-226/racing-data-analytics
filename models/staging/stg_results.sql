-- =============================================================================
-- stg_results  (done)
-- =============================================================================
-- Purpose: the "fact grain" — one row per HORSE per RACE (a "runner").
-- This keeps only result/performance columns and renames them cleanly.
--
-- SPEC (what this model must output):
--   race_id        integer   (not null)
--   horse_id       varchar   (not null)
--   horse_name     varchar
--   sex            varchar
--   age            integer
--   jockey_id      varchar
--   jockey         varchar
--   trainer_id     varchar
--   trainer        varchar
--   finish_rank    integer   (NULL for non-finishers)
--   finish_time    double    (NULL for non-finishers)
--   margin         double    (NULL for non-finishers)
--   final_600m     double
--   win_odds       double
--   popularity     integer
--   won            integer   (1/0)
--   placed         integer   (1/0)
--   win_return     double    (payout for a 1-unit win bet; 0 when lost)
--   market_prob    double    (implied probability from odds)
--   market_log     double
--
-- HINTS:
--   1. Rename columns with `as` (rank -> finish_rank, time -> finish_time,
--      final_600 -> final_600m, win -> won, place -> placed).
--   2. `win`, `place`, `rank`, `popularity` come in as numbers; cast to the
--      target type with `cast(... as ...)` or `::`.
--   3. Leave `time`/`margin`/`rank` as-is for now (they are already NULL for
--      runners that did not finish).
-- =============================================================================

with source as (
    select * from {{ ref('races_sample') }}
),

cleaned as (
    select
        race_id,
        horse_id,
        horse_name,
        sex,
        age,
        jockey_id,
        jockey,
        trainer_id,
        trainer,
        rank::int as finish_rank,
        time      as finish_time,
        margin,
        final_600 as final_600m,
        win_odds,
        popularity,
        win       as won,
        place     as placed,
        win_return,
        market_prob,
        market_log
    from source
)

select * from cleaned
