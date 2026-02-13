-- 11c_prediction_capping_audit.sql

WITH latest AS (SELECT MAX(year) AS y FROM v_district_year_trends),
history AS (
  SELECT district_id
  FROM v_district_year_trends
  WHERE margin_pct_3yr_avg IS NOT NULL
  GROUP BY district_id
  HAVING COUNT(*) >= 10
),
recent AS (
  SELECT
    t.district_id,
    t.year,
    t.margin_pct_3yr_avg,
    LAG(t.margin_pct_3yr_avg) OVER (PARTITION BY t.district_id ORDER BY t.year) AS prev_margin_pct_3yr_avg
  FROM v_district_year_trends t
  JOIN enrollment_fact e
    ON e.district_id = t.district_id AND e.year = t.year
  JOIN history h
    ON h.district_id = t.district_id
  WHERE e.enrollment >= 1000
),
curr AS (
  SELECT *
  FROM recent
  WHERE year = (SELECT y FROM latest)
    AND margin_pct_3yr_avg IS NOT NULL
    AND prev_margin_pct_3yr_avg IS NOT NULL
),
calc AS (
  SELECT
    district_id,
    (margin_pct_3yr_avg - prev_margin_pct_3yr_avg) AS delta_raw,
    CASE
      WHEN (margin_pct_3yr_avg - prev_margin_pct_3yr_avg) < -0.10 THEN -0.10
      WHEN (margin_pct_3yr_avg - prev_margin_pct_3yr_avg) >  0.10 THEN  0.10
      ELSE (margin_pct_3yr_avg - prev_margin_pct_3yr_avg)
    END AS delta_capped
  FROM curr
)
SELECT
  COUNT(*) AS districts_scored,
  SUM(CASE WHEN delta_raw <> delta_capped THEN 1 ELSE 0 END) AS districts_capped,
  ROUND(1.0 * SUM(CASE WHEN delta_raw <> delta_capped THEN 1 ELSE 0 END) / COUNT(*), 4) AS pct_capped
FROM calc;
