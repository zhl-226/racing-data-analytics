#!/usr/bin/env python3
"""Quick SQL practice against the local DuckDB database — no dbt needed.

Usage:
    .venv/bin/python scripts/practice.py                        # run practice/practice.sql
    .venv/bin/python scripts/practice.py practice/foo.sql       # run any SQL file
    .venv/bin/python scripts/practice.py --sql "select count(*) from analytics.races_sample"
    .venv/bin/python scripts/practice.py --list                 # show available tables

This is the "practice unit": edit practice/practice.sql, run it, iterate.
"""
import argparse
import sys
from pathlib import Path

import duckdb
import pandas as pd

ROOT = Path(__file__).resolve().parents[1]
DB = ROOT / "data" / "racing.duckdb"
DEFAULT_SQL = ROOT / "practice" / "practice.sql"


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("file", nargs="?", help="SQL file to run (default: practice/practice.sql)")
    ap.add_argument("--sql", help="inline SQL instead of a file")
    ap.add_argument("--list", action="store_true", help="list available tables")
    args = ap.parse_args()

    if not DB.exists():
        sys.exit(f"Database not found: {DB}\nRun `dbt seed && dbt run` first.")

    con = duckdb.connect(str(DB))

    if args.list:
        rows = con.execute(
            "select table_schema || '.' || table_name as t "
            "from information_schema.tables order by 1"
        ).fetchall()
        for (t,) in rows:
            print(t)
        return

    if args.sql:
        sql = args.sql
    else:
        f = Path(args.file) if args.file else DEFAULT_SQL
        if not f.exists():
            sys.exit(f"File not found: {f}")
        sql = f.read_text()
        print(f"-- running {f}\n")

    try:
        con.execute(sql)
        df = con.fetchdf()
        if df.shape[1] == 0:
            print("OK (no result set)")
        else:
            with pd.option_context("display.max_rows", 100,
                                   "display.max_columns", 50,
                                   "display.width", 220):
                print(df.to_string(index=False))
    except Exception as e:  # surface a readable error
        print(f"ERROR: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
