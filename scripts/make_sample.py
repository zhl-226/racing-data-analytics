#!/usr/bin/env python3
"""Generate dbt seed CSVs from the full processed parquet.

Usage:
    python scripts/make_sample.py [--n 10000] [--seed 42]

Reads the feature parquet (races_featured.parquet), keeps a curated subset of
columns relevant to analytics, and writes:
    seeds/races_sample.csv   -> N randomly-sampled rows (denormalized "raw" layer)
    seeds/courses.csv        -> distinct course dimension (course_id -> name)

Set RAW_PARQUET to override the default parquet path.
"""
import argparse
import os
from pathlib import Path

import pandas as pd
import pyarrow.parquet as pq

DEFAULT_PARQUET = os.environ.get(
    "RAW_PARQUET",
    str(Path.home() / "Documents" / "nkb" / "data" / "processed" / "races_featured.parquet"),
)

# Curated columns (subset of the 83 in the source). Order matters for the seed.
COLS = [
    "race_id", "race_number", "race_name", "course_id", "course_raw",
    "surface", "direction", "distance",
    "year", "month", "day", "date", "org", "num_horses",
    "horse_id", "horse_name", "sex", "age",
    "jockey_id", "jockey", "trainer_id", "trainer",
    "rank", "time", "margin", "final_600",
    "win_odds", "popularity", "win", "place", "win_return",
    "market_prob", "market_log",
]


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--n", type=int, default=10_000, help="rows to sample")
    parser.add_argument("--seed", type=int, default=42)
    args = parser.parse_args()

    root = Path(__file__).resolve().parents[1]
    seeds_dir = root / "seeds"
    seeds_dir.mkdir(exist_ok=True)

    print(f"Reading {DEFAULT_PARQUET}")
    df = pq.read_table(DEFAULT_PARQUET, columns=COLS).to_pandas()

    # date is a timestamp; serialize as ISO date string for a stable CSV.
    df["date"] = df["date"].dt.strftime("%Y-%m-%d")

    sample = df.sample(n=args.n, random_state=args.seed).sort_values(["date", "race_id", "rank"])
    sample = sample.reset_index(drop=True)

    out_races = seeds_dir / "races_sample.csv"
    sample.to_csv(out_races, index=False)
    print(f"Wrote {len(sample)} rows -> {out_races}")

    # Course dimension: most common name per course_id.
    courses = (
        df.groupby("course_id", as_index=False)
        .agg(course_name=("course_raw", lambda s: s.value_counts().idxmax()))
        .sort_values("course_id")
    )
    out_courses = seeds_dir / "courses.csv"
    courses.to_csv(out_courses, index=False)
    print(f"Wrote {len(courses)} courses -> {out_courses}")


if __name__ == "__main__":
    main()
