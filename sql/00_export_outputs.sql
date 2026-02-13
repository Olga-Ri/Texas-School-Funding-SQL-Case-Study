.headers on
.mode csv

.output outputs/tables/06_analysis_statewide_trends.csv
.read sql/06_analysis_statewide_trends.sql

.output outputs/tables/08_analysis_risk_score.csv
.read sql/08_analysis_risk_score.sql

.output outputs/tables/10_analysis_high_risk_worsening.csv
.read sql/10_analysis_high_risk_worsening.sql

.output outputs/tables/11b_prediction_capped.csv
.read sql/11b_prediction_capped.sql

.output outputs/tables/12_final_prediction_table.csv
.read sql/12_final_prediction_table.sql

.output outputs/tables/13_analysis_revenue_growth_vs_margin.csv
.read sql/13_analysis_revenue_growth_vs_margin.sql

.output stdout
.mode column
