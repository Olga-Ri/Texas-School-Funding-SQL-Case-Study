-- 08_analysis_risk_score.sql
-- making a risk score

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
latest_year AS (
  SELECT MAX(year) AS max_year FROM v_district_year_trends
),
recent AS (
  SELECT
    t.district_id,
    t.district_name,
    t.margin_pct_3yr_avg
  FROM v_district_year_trends t
  JOIN latest_year l
    ON t.year = l.max_year
)
SELECT
  h.district_id,
  h.district_name,
  h.years_observed,
  ROUND(h.deficit_rate, 3) AS deficit_rate,
  ROUND(r.margin_pct_3yr_avg, 4) AS margin_pct_3yr_avg,

  -- higher risk score = worse / negative margin
  ROUND(
    (0.7 * h.deficit_rate) +
    (0.3 * CASE
            WHEN r.margin_pct_3yr_avg IS NULL THEN 0
            ELSE -r.margin_pct_3yr_avg
          END),
    4
  ) AS risk_score

FROM history h
LEFT JOIN recent r
  ON r.district_id = h.district_id
ORDER BY risk_score DESC
LIMIT 25;
