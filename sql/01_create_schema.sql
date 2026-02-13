-- 01_create_schema.sql
-- Texas Public School Funding (SQL Project)
-- SQLite schema: staging -> clean tables

PRAGMA foreign_keys = ON;

--  staging tables with raw imported csv

CREATE TABLE IF NOT EXISTS stg_peims_finance_raw (
  source_file TEXT,
  district_id TEXT,
  year INTEGER,

  -- raw money fields 
  total_revenue_raw TEXT,
  local_revenue_raw TEXT,
  state_revenue_raw TEXT,
  federal_revenue_raw TEXT,
  total_expenditure_raw TEXT,

  notes TEXT
);

-- enrollment raw staging
CREATE TABLE IF NOT EXISTS stg_ccd_enrollment_raw (
  source_file TEXT,
  district_id TEXT,
  year INTEGER,
  enrollment_raw TEXT,
  district_name_raw TEXT
);


CREATE TABLE IF NOT EXISTS stg_asked_district_raw (
  source_file TEXT,
  district_id TEXT,
  district_name_raw TEXT,
  county_raw TEXT
);


-- one row per district
CREATE TABLE IF NOT EXISTS district_dim (
  district_id TEXT PRIMARY KEY,
  district_name TEXT NOT NULL,
  county TEXT
);


CREATE TABLE IF NOT EXISTS funding_fact (
  year INTEGER NOT NULL,
  district_id TEXT NOT NULL,

  total_revenue REAL,
  local_revenue REAL,
  state_revenue REAL,
  federal_revenue REAL,
  total_expenditure REAL,

  PRIMARY KEY (year, district_id),
  FOREIGN KEY (district_id) REFERENCES district_dim(district_id)
);

CREATE TABLE IF NOT EXISTS enrollment_fact (
  year INTEGER NOT NULL,
  district_id TEXT NOT NULL,
  enrollment INTEGER,

  PRIMARY KEY (year, district_id),
  FOREIGN KEY (district_id) REFERENCES district_dim(district_id)
);

CREATE INDEX IF NOT EXISTS idx_funding_year ON funding_fact(year);
CREATE INDEX IF NOT EXISTS idx_enrollment_year ON enrollment_fact(year);
