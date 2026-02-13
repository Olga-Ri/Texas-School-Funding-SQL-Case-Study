-- 12_final_prediction_table.sql
-- making final prediction table with enrollment, historical deficit rate, and recent trend direction

WITH latest AS (SELECT MAX(year) AS y FROM v_district_year_trends),

-- finding enrollment in the latest year
enroll AS (
  SELECT district_id, enrollment
  FROM enrollment_fact
  WHERE year = (SELECT y FROM latest)
),

-- getting deficit history rate
hist AS (
  SELECT
    k.district_id,
    k.district_name,
    COUNT(*) AS years_observed,
    AVG(CASE WHEN k.operating_margin_pct < 0 THEN 1.0 ELSE 0.0 END) AS deficit_rate
  FROM v_district_year_kpis k
  JOIN enrollment_fact e
    ON e.district_id = k.district_id AND e.year = k.year
  WHERE k.year BETWEEN 2008 AND 2024
    AND e.enrollment >= 1000
  GROUP BY k.district_id, k.district_name
  HAVING years_observed >= 10
),

-- trend direction of margin_pct_3yr_avg in the latest year
trend AS (
  WITH all_years AS (
    SELECT
      t.district_id,
      t.year,
      t.margin_pct_3yr_avg,
      LAG(t.margin_pct_3yr_avg) OVER (PARTITION BY t.district_id ORDER BY t.year) AS prev_margin_pct_3yr_avg
    FROM v_district_year_trends t
  )
  SELECT
    district_id,
    CASE
      WHEN prev_margin_pct_3yr_avg IS NULL THEN 'no_prior'
      WHEN (margin_pct_3yr_avg - prev_margin_pct_3yr_avg) > 0 THEN 'improving'
      WHEN (margin_pct_3yr_avg - prev_margin_pct_3yr_avg) < 0 THEN 'worsening'
      ELSE 'flat'
    END AS trend_direction
  FROM all_years
  WHERE year = (SELECT y FROM latest)
),

proj AS (
  WITH recent AS (
    SELECT
      t.district_id,
      t.district_name,
      t.year,
      t.margin_pct_3yr_avg,
      LAG(t.margin_pct_3yr_avg) OVER (PARTITION BY t.district_id ORDER BY t.year) AS prev_margin_pct_3yr_avg
    FROM v_district_year_trends t
  )
  SELECT
    r.district_id,
    r.district_name,
    r.year AS current_year,
    r.margin_pct_3yr_avg AS margin_current,
    r.prev_margin_pct_3yr_avg AS margin_prev,
    CASE
      WHEN (r.margin_pct_3yr_avg - r.prev_margin_pct_3yr_avg) < -0.10 THEN -0.10
      WHEN (r.margin_pct_3yr_avg - r.prev_margin_pct_3yr_avg) >  0.10 THEN  0.10
      ELSE (r.margin_pct_3yr_avg - r.prev_margin_pct_3yr_avg)
    END AS delta_capped
  FROM recent r
  WHERE r.year = (SELECT y FROM latest)
    AND r.margin_pct_3yr_avg IS NOT NULL
    AND r.prev_margin_pct_3yr_avg IS NOT NULL
)

SELECT
  p.district_id,
  p.district_name,
  p.current_year,
  enroll.enrollment,
  h.years_observed,
  ROUND(h.deficit_rate, 3) AS deficit_rate,
  trend.trend_direction,
  ROUND(p.margin_current, 4) AS margin_3yr_avg_current,
  ROUND(p.margin_current + p.delta_capped, 4) AS projected_next_year_margin_3yr_avg_capped
FROM proj p
JOIN hist h
  ON h.district_id = p.district_id
LEFT JOIN trend
  ON trend.district_id = p.district_id
LEFT JOIN enroll
  ON enroll.district_id = p.district_id
ORDER BY projected_next_year_margin_3yr_avg_capped ASC
LIMIT 25;
