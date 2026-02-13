-- 11b_prediction_capped.sql

WITH latest AS (
  SELECT MAX(year) AS y FROM v_district_year_trends
),

-- only getting districts with (>= 10 years of margin_3yr_avg values)
history AS (
  SELECT
    district_id,
    COUNT(*) AS years_with_margin
  FROM v_district_year_trends
  WHERE margin_pct_3yr_avg IS NOT NULL
  GROUP BY district_id
  HAVING years_with_margin >= 10
),

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
    district_name,
    year AS current_year,
    margin_pct_3yr_avg AS margin_current,
    prev_margin_pct_3yr_avg AS margin_prev,
    (margin_pct_3yr_avg - prev_margin_pct_3yr_avg) AS delta_raw,

    CASE
      WHEN (margin_pct_3yr_avg - prev_margin_pct_3yr_avg) < -0.10 THEN -0.10
      WHEN (margin_pct_3yr_avg - prev_margin_pct_3yr_avg) >  0.10 THEN  0.10
      ELSE (margin_pct_3yr_avg - prev_margin_pct_3yr_avg)
    END AS delta_capped
  FROM curr
)

SELECT
  district_id,
  district_name,
  current_year,
  ROUND(margin_current, 4) AS margin_3yr_avg_current,
  ROUND(margin_prev, 4) AS margin_3yr_avg_prev,
  ROUND(delta_raw, 4) AS delta_last_year_raw,
  ROUND(delta_capped, 4) AS delta_last_year_capped,
  ROUND(margin_current + delta_capped, 4) AS projected_next_year_margin_3yr_avg_capped
FROM calc
ORDER BY projected_next_year_margin_3yr_avg_capped ASC
LIMIT 25;
