-- 13_analysis_revenue_growth_vs_margin.sql
-- statewide revenue growth vs operating margin trend 

WITH yearly AS (
  SELECT
    year,
    SUM(total_revenue)     AS total_rev,
    SUM(total_expenditure) AS total_exp
  FROM funding_fact
  WHERE year BETWEEN 2008 AND 2024
  GROUP BY year
),
kpis AS (
  SELECT
    year,
    total_rev,
    total_exp,
    (total_rev - total_exp) AS surplus,
    (1.0 * (total_rev - total_exp) / NULLIF(total_rev, 0)) AS margin_pct
  FROM yearly
),
calc AS (
  SELECT
    year,
    total_rev,
    total_exp,
    surplus,
    margin_pct,

    (total_rev - LAG(total_rev) OVER (ORDER BY year))
      / NULLIF(LAG(total_rev) OVER (ORDER BY year), 0) AS rev_yoy_pct,

    (total_exp - LAG(total_exp) OVER (ORDER BY year))
      / NULLIF(LAG(total_exp) OVER (ORDER BY year), 0) AS exp_yoy_pct,

    (margin_pct - LAG(margin_pct) OVER (ORDER BY year)) AS margin_pct_point_change
  FROM kpis
)
SELECT
  year,
  total_rev AS statewide_total_revenue,
  total_exp AS statewide_total_expenditure,
  ROUND(margin_pct, 4) AS statewide_operating_margin_pct,
  ROUND(rev_yoy_pct, 4) AS revenue_yoy_pct,
  ROUND(exp_yoy_pct, 4) AS expenditure_yoy_pct,
  ROUND(margin_pct_point_change, 4) AS margin_pct_point_change
FROM calc
ORDER BY year;
