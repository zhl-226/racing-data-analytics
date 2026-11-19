# racing-analytics — a dbt data-engineering project

A small but real **ELT pipeline** built with [dbt](https://docs.getdbt.com/) on top
of your existing 2.2M-row horse-racing dataset. It's designed to (a) prove the
data-engineering skills the internship asks for — Python + SQL, dimensional
modeling, testing, documentation — and (b) teach you dbt/SQL by leaving the
interesting parts for **you** to write.

The local stack is **dbt + DuckDB** (free, runs entirely on your laptop, no
cloud account). A BigQuery migration path is included for later.

---

## What this demonstrates

| Internship requirement | Where you show it |
|---|---|
| Proficient in SQL | the `models/**/*.sql` files you'll write |
| Data engineering experience | raw → staging → marts pipeline |
| Data transformation tools (dbt) | this whole project |
| Cloud data platforms | BigQuery target in `profiles.yml` (later step) |
| Analytics / ML context | `market_calibration` ties to your UQ/calibration work |

---

## Repo layout

```
racing-analytics/
├── dbt_project.yml        # dbt config: materialization defaults, paths
├── profiles.yml           # connection profiles (DuckDB now, BigQuery later)
├── requirements.txt
├── scripts/
│   └── make_sample.py     # regenerate seeds from the full parquet
├── seeds/                 # "raw" landing zone (CSVs)
│   ├── courses.csv        # 25 course routes (course_id -> name)
│   └── races_sample.csv   # 10,000 sampled runner rows
├── models/
│   ├── staging/           # one table per source concept (VIEWS)
│   │   ├── stg_races.sql      ✅ WORKED EXAMPLE
│   │   ├── stg_results.sql    🛠 TODO (you)
│   │   └── stg_courses.sql    🛠 TODO (you)
│   ├── marts/             # business aggregates (TABLES)
│   │   ├── race_counts_by_course.sql  ✅ WORKED EXAMPLE
│   │   ├── fct_race_results.sql       🛠 TODO (you)
│   │   ├── course_performance.sql     🛠 TODO (you)
│   │   ├── jockey_performance.sql     🛠 TODO (you)
│   │   └── market_calibration.sql     🛠 TODO (you)
│   └── schema.yml         # tests + docs (some TODOs)
└── analyses/adhoc.sql
```

---

## Quick start (5 minutes)

```bash
cd racing-analytics

# 1. Create a virtualenv and install dbt + DuckDB
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# 2. Load the seed CSVs into DuckDB (creates data/racing.duckdb)
dbt seed

# 3. Build the models (worked examples run immediately; TODO models are stubs)
dbt run

# 4. Run the tests defined in models/schema.yml
dbt test

# 5. Generate + serve the auto-generated documentation (lineage graph!)
dbt docs generate
dbt docs serve          # open http://localhost:8080
```

If everything is set up correctly, `dbt run` succeeds and `dbt test` passes the
tests on `stg_races` and `race_counts_by_course`.

---

## Your tasks (the "key parts" to complete)

The files marked 🛠 are stubs (they compile as passthroughs so `dbt run` stays
green). Replace each with the real logic described in its header comment.

Do them in this order — each builds on the previous:

1. **`models/staging/stg_results.sql`** — the runner-level fact. Rename/clean
   result columns (`rank`→`finish_rank`, `win`→`won`, …) and cast types.

2. **`models/staging/stg_courses.sql`** — decode `course_name` like `'ダ右1700m'`
   into `surface` / `direction` / `distance_m`. Uses `substr`, `case when`,
   `regexp_extract`. *This is the classic "dirty source → clean dimension" skill.*

3. **`models/marts/fct_race_results.sql`** — join the fact to the race and course
   dimensions to form the wide fact.

4. **`models/marts/course_performance.sql`** — per-course win rate, avg odds,
   and **ROI** (`(avg(win_return) - 1) * 100`).

5. **`models/marts/jockey_performance.sql`** — per-jockey aggregates (add a
   `HAVING n_rides >= 50`-style filter).

6. **`models/marts/market_calibration.sql`** — bin `market_prob` into 0.1 buckets
   and compare `avg_predicted` vs `avg_observed`. This is your calibration/UQ
   work, expressed in SQL.

7. **`models/schema.yml`** — uncomment the TODO tests as you finish each model:
   uniqueness, not-null, `relationships` (FK checks), and `accepted_range`
   (0 ≤ probability ≤ 1).

After each step: `dbt run && dbt test`, then peek at the output:

```bash
# inspect a model's rows without leaving the CLI
dbt show --inline "select * from {{ ref('course_performance') }} order by roi_pct desc limit 10"
```

---

## Learning resources (read as you go)

- **dbt fundamentals** (concepts): https://docs.getdbt.com/docs/build/models — *models, ref(), sources, tests, docs*
- **dbt + DuckDB setup**: https://docs.getdbt.com/docs/core/connect-data-platform/duckdb-setup
- **DuckDB SQL**: https://duckdb.org/docs/sql/introduction — the dialect you're writing
- **`ref()` and lineage**: https://docs.getdbt.com/reference/dbt-jinja-functions/ref
- **Tests**: https://docs.getdbt.com/docs/build/tests
- **Modeling guide (dims/facts)**: https://www.getdbt.com/blog/kimball-dimensional-model — the *why* behind staging/marts

Key idea to internalize: **dbt = "SELECT statements + lineage"**. Every model is
just a `SELECT` that reads from `{{ ref(...) }}`; dbt figures out order and
materializes the result. You're never writing `CREATE TABLE`.

---

## Regenerate the seeds from the full 2.2M rows

The committed sample is 10k rows for fast iteration. To point at the real data:

```bash
python scripts/make_sample.py --n 100000          # bigger sample
# or edit the script's RAW_PARQUET env var to point at any parquet
```

The full source lives at `~/Documents/nkb/data/processed/races_featured.parquet`
(2,240,098 rows × 83 columns). In a real production pipeline you'd register that
parquet as an external source instead of a committed CSV seed.

---

## Migrate to BigQuery (cloud warehouse — the keyword you're missing)

When you want the "Snowflake/BigQuery/Databricks" keyword on your resume:

1. Create a **BigQuery sandbox** (no credit card): https://console.cloud.google.com/bigquery
2. Create a service-account keyfile (JSON) with BigQuery roles.
3. Install the adapter: `pip install dbt-bigquery`
4. Uncomment the `bq` block in `profiles.yml`, fill in your `project` / `keyfile`,
   then run: `dbt seed --target bq && dbt run --target bq`

Bonus points: create a small table in BigQuery and write one query that joins a
`bigquery-public-data` dataset with your race data (the "join public + private
data" skill).

---

## Publish to GitHub

```bash
git init
git add .
git commit -m "racing-analytics: dbt ELT pipeline on 2.2M-row racing dataset"
git branch -M main
git remote add origin git@github.com:zhl-226/racing-analytics.git
git push -u origin main
```

Then link the repo on your resume next to the existing `github.com/zhl-226`.

---

## License / data note

The seed CSVs are derived from your private `nkb` dataset. If you push this
publicly, confirm you're OK sharing the sampled rows (or regenerate a smaller,
more aggregated sample first).
