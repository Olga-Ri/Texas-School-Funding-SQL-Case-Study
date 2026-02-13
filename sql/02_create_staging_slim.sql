DROP TABLE IF EXISTS stg_peims_finance_slim;

CREATE TABLE stg_peims_finance_slim (
  district_number TEXT,
  district_name TEXT,
  year INTEGER,

  all_local_mo_raw TEXT,
  all_state_rev_raw TEXT,
  all_federal_rev_raw TEXT,
  all_total_oper_rev_raw TEXT,
  all_total_oper_exp_raw TEXT,

  fall_survey_enrollment_raw TEXT
);
