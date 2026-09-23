-- DDL for NYC Payroll Pipeline tables
-- Run in the shprod schema
use shprod;

-- 1. Pipeline Run Lifecycle Log (RUNLOG)
CREATE OR REPLACE TABLE shprod.audit_runlog (
    run_id INTEGER NOT NULL PRIMARY KEY,
    active_dt date,
    pipeline_name STRING,
    status STRING,               -- 'RUNNING', 'COMPLETED', 'FAILED'
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    total_duration_sec BIGINT,
    created_by STRING
)
USING DELTA;

-- 2. Step-Level Execution & Metrics Log (EXECUTION_LOGS)
CREATE TABLE IF NOT EXISTS shprod.audit_execution_logs (
    log_id STRING NOT NULL,
    run_id INTEGER NOT NULL,
    active_dt date,
    step_name STRING,
    source_table STRING,
    target_table STRING,
    error_table STRING,
    status STRING,
    rows_read BIGINT,
    rows_inserted BIGINT,
    rows_updated BIGINT,
    rows_quarantined BIGINT,
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    error_message STRING,
    PRIMARY KEY (log_id, run_id)
)
USING DELTA;

-- 3. Quarantine / Error Table
CREATE TABLE IF NOT EXISTS shprod.payroll_quarantine (
    pid BIGINT NOT NULL ,
    active_dt date,
    fiscal_year INT,
    agency_name STRING,
    first_name STRING,
    last_name STRING,
    mid_name STRING,
    agency_start_date DATE,
    work_location_borough STRING,
    title_description STRING,
    leave_status_as_of_june_30 STRING,
    base_salary DECIMAL(12, 2),
    pay_basis STRING,
    regular_hours DECIMAL(10, 2),
    regular_gross_paid DECIMAL(12, 2),
    ot_hours DECIMAL(10, 2),
    total_ot_paid DECIMAL(12, 2),
    total_other_pay DECIMAL(12, 2),
    rejection_reason STRING,
    run_id BIGINT NOT NULL PRIMARY KEY,
    quarantined_at TIMESTAMP
)
USING DELTA;

-- 4. Clean Staging Table (Intermediate)
CREATE TABLE IF NOT EXISTS shprod.stg_payroll_employee_nyc (
    pid BIGINT NOT NULL PRIMARY KEY,
    active_dt date,
    fiscal_year INT,
    agency_name STRING,
    first_name STRING,
    last_name STRING,
    mid_name STRING,
    agency_start_date DATE,
    work_location_borough STRING,
    title_description STRING,
    leave_status_as_of_june_30 STRING,
    base_salary DECIMAL(12, 2),
    pay_basis STRING,
    regular_hours DECIMAL(10, 2),
    regular_gross_paid DECIMAL(12, 2),
    ot_hours DECIMAL(10, 2),
    total_ot_paid DECIMAL(12, 2),
    total_other_pay DECIMAL(12, 2),
    run_id BIGINT NOT NULL,
    batch_time TIMESTAMP
)
USING DELTA;

-- 5. Final SCD Type 2 Dimension Table
CREATE TABLE IF NOT EXISTS shprod.payroll_employee_nyc (
    pid BIGINT NOT NULL PRIMARY KEY,                   -- Deterministic Hash / Business Key
    fiscal_year INT,
    agency_name STRING,
    first_name STRING,
    last_name STRING,
    mid_name STRING,
    agency_start_date DATE,
    work_location_borough STRING,
    title_description STRING,
    leave_status_as_of_june_30 STRING,
    base_salary DECIMAL(12, 2),
    pay_basis STRING,
    regular_hours DECIMAL(10, 2),
    regular_gross_paid DECIMAL(12, 2),
    ot_hours DECIMAL(10, 2),
    total_ot_paid DECIMAL(12, 2),
    total_other_pay DECIMAL(12, 2),
    active_dt DATE,
    end_dt DATE,
    run_id BIGINT NOT NULL,
    lst_uptd_run_id BIGINT NOT NULL
)
USING DELTA
CLUSTER BY (fiscal_year, active_dt, agency_name)
TBLPROPERTIES (
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact' = 'true'
);

-- 6. Gold Reporting Summary Table
CREATE TABLE IF NOT EXISTS shprod.payroll_nyc_agency_summary (
    pid BIGINT NOT NULL PRIMARY KEY,                   -- Deterministic Hash / Business Key
    fiscal_year INT,
    agency_name STRING,
    first_name STRING,
    last_name STRING,
    mid_name STRING,
    agency_start_date DATE,
    work_location_borough STRING,
    title_description STRING,
    leave_status_as_of_june_30 STRING,
    base_salary DECIMAL(12, 2),
    pay_basis STRING,
    regular_hours DECIMAL(10, 2),
    regular_gross_paid DECIMAL(12, 2),
    ot_hours DECIMAL(10, 2),
    total_ot_paid DECIMAL(12, 2),
    total_other_pay DECIMAL(12, 2),
    active_dt DATE,
    end_dt DATE,
    run_id BIGINT NOT NULL,
    lst_uptd_run_id BIGINT NOT NULL
)
USING DELTA
CLUSTER BY (fiscal_year, active_dt, agency_name)
TBLPROPERTIES (
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact' = 'true'
);
