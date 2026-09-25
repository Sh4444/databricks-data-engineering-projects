create or replace view shprod.payroll_employee_nyc_view as
select * from shprod.payroll_employee_nyc where end_dt = '9999-12-31';