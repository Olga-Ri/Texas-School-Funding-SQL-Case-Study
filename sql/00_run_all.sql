-- 00_run_all.sql
-- how to rebuild data pipeline

.read sql/01_create_schema.sql
.read sql/02_create_staging_slim.sql

.mode csv
DELETE FROM stg_peims_finance_slim;
.import 'data/processed/peims_slim.csv' stg_peims_finance_slim

DELETE FROM stg_peims_finance_slim
WHERE district_number = 'DISTRICT NUMBER';

-- read tables with cleaned data
.read sql/03_load_clean.sql
.read sql/04_views_kpis.sql
.read sql/05_views_trends.sql
.read sql/06_analysis_statewide_trends.sql
.read sql/07_analysis_district_risk.sql
.read sql/08_analysis_risk_score.sql
.read sql/09_analysis_recent_trend_direction.sql
.read sql/10_analysis_high_risk_worsening.sql
.read sql/11a_prediction_raw.sql
.read sql/11b_prediction_capped.sql
.read sql/11c_prediction_capping_audit.sql
.read sql/12_final_prediction_table.sql
.read sql/13_analysis_revenue_growth_vs_margin.sql

.mode column
.headers on
