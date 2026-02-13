-- 07_analysis_district_risk.sql
-- finding districts with repeated more spending than revenue and weak recent margins


--finding how many years operating margin < 0
SELECT
  k.district_id,
  k.district_name,
  COUNT(*) AS years_observed,
  SUM(CASE WHEN k.operating_margin_amt < 0 THEN 1 ELSE 0 END) AS deficit_years,
  ROUND(1.0 * SUM(CASE WHEN k.operating_margin_amt < 0 THEN 1 ELSE 0 END) / COUNT(*), 3) AS deficit_rate
FROM v_district_year_kpis k
JOIN enrollment_fact e
  ON e.district_id = k.district_id AND e.year = k.year
WHERE k.year BETWEEN 2008 AND 2024
  AND e.enrollment >= 1000
GROUP BY k.district_id, k.district_name
HAVING years_observed >= 10
ORDER BY deficit_years DESC, deficit_rate DESC
LIMIT 25;


-- getting most recent 3-year average margin 
WITH latest AS (
  SELECT MAX(year) AS max_year FROM v_district_year_trends
)
SELECT
  t.district_id,
  t.district_name,
  t.year,
  ROUND(t.margin_pct_3yr_avg, 4) AS margin_pct_3yr_avg
FROM v_district_year_trends t
JOIN latest l
  ON t.year = l.max_year
JOIN enrollment_fact e
  ON e.district_id = t.district_id AND e.year = t.year
WHERE t.margin_pct_3yr_avg IS NOT NULL
  AND e.enrollment >= 1000
ORDER BY t.margin_pct_3yr_avg ASC
LIMIT 25;

