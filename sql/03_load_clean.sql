-- 03_load_clean.sql
-- adding the staging data into clean tables

PRAGMA foreign_keys = ON;

-- adding districts
INSERT OR IGNORE INTO district_dim (district_id, district_name, county)
SELECT
  TRIM(district_number),
  TRIM(district_name),
  NULL
FROM stg_peims_finance_slim
WHERE district_number IS NOT NULL
  AND district_number <> 'DISTRICT NUMBER'
GROUP BY district_number, district_name;

INSERT OR REPLACE INTO funding_fact (
  year,
  district_id,
  total_revenue,
  local_revenue,
  state_revenue,
  federal_revenue,
  total_expenditure
)
SELECT
  CAST(year AS INTEGER),
  TRIM(district_number),
  CAST(all_total_oper_rev_raw AS REAL),
  CAST(all_local_mo_raw AS REAL),
  CAST(all_state_rev_raw AS REAL),
  CAST(all_federal_rev_raw AS REAL),
  CAST(all_total_oper_exp_raw AS REAL)
FROM stg_peims_finance_slim
WHERE district_number <> 'DISTRICT NUMBER'
  AND year <> 0;

-- adding enrollment
INSERT OR REPLACE INTO enrollment_fact (
  year,
  district_id,
  enrollment
)
SELECT
  CAST(year AS INTEGER),
  TRIM(district_number),
  CAST(fall_survey_enrollment_raw AS INTEGER)
FROM stg_peims_finance_slim
WHERE district_number <> 'DISTRICT NUMBER'
  AND year <> 0;
