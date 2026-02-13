-- 04_views_kpis.sql
-- main financial KPIs by district-year

DROP VIEW IF EXISTS v_district_year_kpis;

CREATE VIEW v_district_year_kpis AS
SELECT
  f.year,
  f.district_id,
  d.district_name,

  f.total_revenue,
  f.local_revenue,
  f.state_revenue,
  f.federal_revenue,
  f.total_expenditure,

  -- operating margin amount and percentage
  (f.total_revenue - f.total_expenditure) AS operating_margin_amt,

  CASE
    WHEN f.total_revenue IS NULL OR f.total_revenue = 0 THEN NULL
    ELSE (f.total_revenue - f.total_expenditure) / f.total_revenue
  END AS operating_margin_pct,

  -- funding mix shares
  CASE WHEN f.total_revenue = 0 THEN NULL ELSE f.local_revenue   / f.total_revenue END AS local_share,
  CASE WHEN f.total_revenue = 0 THEN NULL ELSE f.state_revenue   / f.total_revenue END AS state_share,
  CASE WHEN f.total_revenue = 0 THEN NULL ELSE f.federal_revenue / f.total_revenue END AS federal_share

FROM funding_fact f
JOIN district_dim d
  ON d.district_id = f.district_id;
