# SQL practice exercises

Work top to bottom. Each exercise is one query you can put in
`practice/practice.sql` (or pass with `--sql "..."`). Most target
`analytics.races_sample` (10k runner rows). Don't peek ahead — the point is to
build the muscle memory.

## Unit 1 — SELECT / filtering / ordering

1. Return 5 rows of any race (any columns).
2. All **winners**: rows where `win = 1`.
3. Winners sorted by `win_odds` ascending (favourites first).
4. Runners with `market_prob >= 0.5` (strong favourites).
5. Runners from `org` = 'JRA' (or whatever org codes exist — inspect first).
   *Hint: `select distinct org from analytics.races_sample`.*

## Unit 2 — Aggregation / GROUP BY

6. How many rows total? (`count(*)`)
7. How many **distinct** races? (`count(distinct race_id)`)
8. Runners per `surface` (count, grouped).
9. Average `win_odds` per `org`.
10. Win rate per `sex`: `avg(win)` grouped by `sex`.
11. Average field size (`num_horses`) per `year`.

## Unit 3 — String / date / CASE WHEN

12. Count runners per `year` (use the `year` column, or extract from `date`).
13. Bucket `win_odds`: `favorite` (< 2), `mid` (2–5), `longshot` (> 5); count each.
    *Hint: `case when win_odds < 2 then 'favorite' ... end`.*
14. Month name from `month` (1 → 'Jan', …) using a `case when`.

## Unit 4 — Joins

15. Join `analytics.races_sample` to `analytics.courses` on `course_id`; show
    `race_id`, `horse_name`, and the readable `course_name`.

## Unit 5 — Window functions (the big one)

16. Favourite rank within each race: `row_number() over (partition by race_id order by win_odds)`.
17. Previous finish position per horse: `lag(rank) over (partition by horse_id order by date)`.
    *Compare against the raw `prev_race_rank` column when it exists — spot check.*
18. `rank()` vs `dense_rank()` vs `row_number()` over `order by win_odds` for one race — see the difference on ties.
19. Cumulative win count per horse over time:
    `sum(win) over (partition by horse_id order by date)`.

## Unit 6 — Calibration (ties to your UQ work)

20. Bucket `market_prob` into 0.1-wide bins (`floor(market_prob*10)/10`); for each
    bin show `avg(market_prob)` (predicted) vs `avg(win)` (observed) and count.
    A well-calibrated market has predicted ≈ observed.
    *This is exactly the `market_calibration` mart — do it by hand first, then
    compare with your dbt model.*
