# SQL practice unit

Practice SQL against the real dataset, anytime, without running dbt.

```bash
# from the project root
.venv/bin/python scripts/practice.py --list              # see the tables
.venv/bin/python scripts/practice.py --sql "select count(*) from analytics.races_sample"
.venv/bin/python scripts/practice.py                      # run practice/practice.sql
```

Edit `practice/practice.sql` with one query, run it, iterate. Exercises are in
`practice/exercises.md` (progressive: filtering → aggregation → joins → window
functions → calibration).

## Tables

| table | grain | notes |
|---|---|---|
| `analytics.races_sample` | one horse per race | raw, denormalized — richest |
| `analytics.courses` | one course route | `course_id`, `course_name` |
| `analytics_staging.stg_races` | one race | de-duplicated |
| `analytics_staging.stg_results` | one runner | fact grain |
| `analytics_marts.race_counts_by_course` | one course | aggregate |

## Key columns in `analytics.races_sample`

- `race_id`, `race_number`, `race_name`, `course_id`, `org`, `year`, `month`, `day`, `date`
- `surface`, `direction`, `distance` (int codes), `num_horses`
- `horse_id`, `horse_name`, `sex`, `age`, `jockey_id`, `jockey`, `trainer_id`, `trainer`
- `rank`, `time`, `margin`, `final_600`, `win_odds`, `popularity`
- `win` (1/0), `place` (1/0), `win_return`, `market_prob`, `market_log`
