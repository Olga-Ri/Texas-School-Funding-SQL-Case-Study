-- 09_analysis_recent_trend_direction.sql
--  margin 3yr avg trend

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
)
SELECT
  r.district_id,
  r.district_name,
  r.year,
  ROUND(r.margin_pct_3yr_avg, 4) AS margin_pct_3yr_avg,
  ROUND(r.prev_margin_pct_3yr_avg, 4) AS prev_margin_pct_3yr_avg,
  ROUND(r.margin_pct_3yr_avg - r.prev_margin_pct_3yr_avg, 4) AS delta_margin_3yr_avg,
  CASE
    WHEN r.prev_margin_pct_3yr_avg IS NULL THEN 'no_prior'
    WHEN (r.margin_pct_3yr_avg - r.prev_margin_pct_3yr_avg) > 0 THEN 'improving'
    WHEN (r.margin_pct_3yr_avg - r.prev_margin_pct_3yr_avg) < 0 THEN 'worsening'
    ELSE 'flat'
  END AS trend_direction
FROM recent r
JOIN latest l
  ON r.year = l.y
WHERE r.margin_pct_3yr_avg IS NOT NULL
ORDER BY delta_margin_3yr_avg ASC
LIMIT 25;
