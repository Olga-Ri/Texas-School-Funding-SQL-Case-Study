-- 11_prediction_simple_margin_projection.sql

WITH latest AS (SELECT MAX(year) AS y FROM v_district_year_trends),
recent AS (
  SELECT
    t.district_id,
    t.district_name,
    t.year,
    t.margin_pct_3yr_avg,
    LAG(t.margin_pct_3yr_avg) OVER (PARTITION BY t.district_id ORDER BY t.year) AS prev_margin_pct_3yr_avg
  FROM v_district_year_trends t
  JOIN enrollment_fact e
    ON e.district_id = t.district_id AND e.year = t.year
  WHERE e.enrollment >= 1000
),
curr AS (
  SELECT *
  FROM recent
  WHERE year = (SELECT y FROM latest)
    AND margin_pct_3yr_avg IS NOT NULL
    AND prev_margin_pct_3yr_avg IS NOT NULL
)
SELECT
  district_id,
  district_name,
  year AS current_year,
  ROUND(margin_pct_3yr_avg, 4) AS margin_3yr_avg_current,
  ROUND(prev_margin_pct_3yr_avg, 4) AS margin_3yr_avg_prev,
  ROUND(margin_pct_3yr_avg - prev_margin_pct_3yr_avg, 4) AS delta_last_year,
  ROUND(margin_pct_3yr_avg + (margin_pct_3yr_avg - prev_margin_pct_3yr_avg), 4) AS projected_next_year_margin_3yr_avg
FROM curr
ORDER BY projected_next_year_margin_3yr_avg ASC
LIMIT 25;
