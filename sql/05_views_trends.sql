-- 05_views_trends.sql

DROP VIEW IF EXISTS v_district_year_trends;

CREATE VIEW v_district_year_trends AS
SELECT
  k.*,

  -- year-over-year deltas
  (k.total_revenue - LAG(k.total_revenue) OVER (PARTITION BY k.district_id ORDER BY k.year)) AS rev_yoy_change,
  (k.total_expenditure - LAG(k.total_expenditure) OVER (PARTITION BY k.district_id ORDER BY k.year)) AS exp_yoy_change,

  -- year-over-year % changes 
  CASE
    WHEN LAG(k.total_revenue) OVER (PARTITION BY k.district_id ORDER BY k.year) IS NULL
      OR LAG(k.total_revenue) OVER (PARTITION BY k.district_id ORDER BY k.year) = 0
    THEN NULL
    ELSE (k.total_revenue - LAG(k.total_revenue) OVER (PARTITION BY k.district_id ORDER BY k.year))
         / LAG(k.total_revenue) OVER (PARTITION BY k.district_id ORDER BY k.year)
  END AS rev_yoy_pct,

  CASE
    WHEN LAG(k.total_expenditure) OVER (PARTITION BY k.district_id ORDER BY k.year) IS NULL
      OR LAG(k.total_expenditure) OVER (PARTITION BY k.district_id ORDER BY k.year) = 0
    THEN NULL
    ELSE (k.total_expenditure - LAG(k.total_expenditure) OVER (PARTITION BY k.district_id ORDER BY k.year))
         / LAG(k.total_expenditure) OVER (PARTITION BY k.district_id ORDER BY k.year)
  END AS exp_yoy_pct,

  -- stability indicator
  AVG(k.operating_margin_pct) OVER (
    PARTITION BY k.district_id
    ORDER BY k.year
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
  ) AS margin_pct_3yr_avg

FROM v_district_year_kpis k;
