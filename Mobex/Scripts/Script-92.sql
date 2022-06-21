-- DROP TABLE mgdw.Plex.daily_shift_report;
-- TRUNCATE TABLE mgdw.Plex.daily_shift_report;
-- drop table Plex.daily_shift_report
CREATE TABLE mgdw.Plex.daily_shift_report (
	department_no int NULL,
	department_code varchar(60) NULL,
	workcenter_code varchar(200) NULL
	
);

select * from Plex.daily_shift_report