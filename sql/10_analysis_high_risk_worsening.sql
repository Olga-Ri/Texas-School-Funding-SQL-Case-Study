-- 10_analysis_high_risk_worsening.sql

WITH risk AS (
  WITH eligible AS (
    SELECT
      k.district_id,
      k.district_name,
      k.year,
      k.operating_margin_pct
    FROM v_district_year_kpis k
    JOIN enrollment_fact e
      ON e.district_id = k.district_id AND e.year = k.year
    WHERE k.year BETWEEN 2008 AND 2024
      AND e.enrollment >= 1000
  ),
  history AS (
    SELECT
      district_id,
      district_name,
      COUNT(*) AS years_observed,
      AVG(CASE WHEN operating_margin_pct < 0 THEN 1.0 ELSE 0.0 END) AS deficit_rate
    FROM eligible
    GROUP BY district_id, district_name
    HAVING years_observed >= 10
  ),
  latest_year AS (SELECT MAX(year) AS max_year FROM v_district_year_trends),
  recent AS (
    SELECT
      t.district_id,
      t.margin_pct_3yr_avg
    FROM v_district_year_trends t
    JOIN latest_year l
      ON t.year = l.max_year
  )
  SELECT
    h.district_id,
    h.district_name,
    h.years_observed,
    h.deficit_rate,
    r.margin_pct_3yr_avg
  FROM history h
  LEFT JOIN recent r
    ON r.district_id = h.district_id
),
trend AS (
  WITH latest AS (SELECT MAX(year) AS y FROM v_district_year_trends),
  recent AS (
    SELECT
      t.district_id,
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
    r.year,
    (r.margin_pct_3yr_avg - r.prev_margin_pct_3yr_avg) AS delta_margin_3yr_avg,
    CASE
      WHEN r.prev_margin_pct_3yr_avg IS NULL THEN 'no_prior'
      WHEN (r.margin_pct_3yr_avg - r.prev_margin_pct_3yr_avg) > 0 THEN 'improving'
      WHEN (r.margin_pct_3yr_avg - r.prev_margin_pct_3yr_avg) < 0 THEN 'worsening'
      ELSE 'flat'
    END AS trend_direction
  FROM recent r
  JOIN latest l
    ON r.year = l.y
)
SELECT
  r.district_id,
  r.district_name,
  r.years_observed,
  ROUND(r.deficit_rate, 3) AS deficit_rate,
  ROUND(r.margin_pct_3yr_avg, 4) AS margin_pct_3yr_avg,
  ROUND(t.delta_margin_3yr_avg, 4) AS delta_margin_3yr_avg,
  t.trend_direction
FROM risk r
JOIN trend t
  ON t.district_id = r.district_id
WHERE t.trend_direction = 'worsening'
ORDER BY r.deficit_rate DESC, t.delta_margin_3yr_avg ASC
LIMIT 25;
