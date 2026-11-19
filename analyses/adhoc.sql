-- Ad-hoc queries. Analyses don't get built into the warehouse; they're just
-- for exploring. Run with:  dbt compile  (or copy into DuckDB / `dbt show`).
--
-- Example: peek at the course counts once the mart exists.

select * from {{ ref('race_counts_by_course') }}
order by n_races desc
limit 10
