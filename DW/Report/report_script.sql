-- mgdw.Report.Report definition
-- Drop table
-- DROP TABLE mgdw.report.report;

CREATE TABLE Report.report (
	report_key int NOT NULL,
	name varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	CONSTRAINT PK_report PRIMARY KEY (report_key)
);

-- truncate table Report.report
insert into Report.report 
values (100,'Trial Balance')
,(101,'Daily Metrics')
-- select * from Report.report
-- drop table Report.report_column 
CREATE TABLE Report.report_column (
	report_column_key int NOT NULL,
	report_key int not null,
	dw_column_key int not null, 
	name varchar(100) NULL,
	CONSTRAINT PK_report_column PRIMARY KEY (report_column_key)
);
-- truncate table Report.report_column 
insert into Report.report_column  
values 
(1,101,1,'Direct Labor') --'Direct_Labor_Cost'

select r.name report
,rc.name dw_column
from Report.report r 
join Report.report_column rc 
on r.report_key = rc.report_key 



select r.name report
,rc.name dw_column
,dd.name datum 
,d.name datasource
,s.name script 
,scp.name devop_proj
,scr.name script_repo 
,dci.name issue 
from Report.report r 
join Report.report_column rc 
on r.report_key = rc.report_key 
join Datasource.datasource_datum_column ddc 
on rc.dw_column_key = ddc.dw_column_key 
join DataSource.datasource_datum dd  
on ddc.datasource_datum_key=dd.datasource_datum_key 
join DataSource.datasource d 
on dd.datasource_key = d.datasource_key 
join DataSource.datasource_script dss 
on d.datasource_key = dss.datasource_key 
join ETL.script s 
on dss.script_key = s.script_key 
join ETL.source_control_repo scr 
on s.source_control_repo_key = scr.source_control_repo_key 
join ETL.source_control_project scp 
on scr.source_control_project_key = scp.source_control_project_key 
join Datasource.datasource_datum_column_issue dci 
on ddc.datasource_datum_column_key = dci.datasource_datum_column_key 




select dws.name dw_schema,dwt.name dw_table,dwc.name dw_column 
from DataSource.dw_schema dws
join DataSource.dw_table dwt 
on dws.dw_schema_key = dwt.dw_schema_key 
join DataSource.dw_column dwc 
on dwt.dw_table_key = dwc.dw_table_key 


/*
 * OLD Schema
 */

select 
r.Name report,
s.name script_name,
sc.schedule. 
from DataSource.datasource d 
join ETL.report_script rs 
on d.
join ETL.script s 
on rs.script_key=s.script_key 
join ETL.Report r 
on rs.Report_Key = r.Report_Key 
--join ETL.script_history h 
--on s.script_key = h.script_key 
join ETL.schedule sc  
on s.schedule_key = sc.schedule_key  
join DataSource.source_control_repo sr
on 
where rs.report_key = 100 


-- mgdw.ETL.Report_Script definition
-- Drop table
-- DROP TABLE mgdw.ETL.Report_Script;
CREATE TABLE mgdw.ETL.Report_Script (
	Report_Key int NOT NULL,
	Script_Key int NOT NULL,
	CONSTRAINT PK_report_script PRIMARY KEY (Report_Key,Script_Key)
);
-- truncate table ETL.report_script 
insert into ETL.report_script  
values 
(100,5),--'AccountingPeriod',100,6),
(100,4),--'AccountingBalanceUpdatePeriodRange',100,5),
(100,3),--'AccountingYearCategoryType.dtsx',100,4),
(100,1),--'AccountingAccount.dtsx',100,1),
(100,2),--'Invoke-WorkcentersGet.ps1',100,3),
--/* already inserted
(101,102),--,'CostGrossMarginDaily',100),
(101,103),--'CostModelsGet',100),
(101,104),--'CostSubTypeBreakdownMatrix',100),
(101,107),--'DailyShiftReportGet',100),
(101,109),--'PartOperationGet',100),
(101,113)--,'WorkcentersGet',100)
--*/
select * from ETL.report_script


exec ETL.report_script_status 100
-- drop procedure ETL.report_script_status 
create procedure ETL.report_script_status 
(
	@report_key int
)
as 
begin 
	declare @report_key int; 
	set @report_key = 100; 
	declare @not_done_or_error int;
	declare @script_history_count int;
	declare @report_script_count int;
	declare @prev_day_midnight datetime;
	-- see howto/date_calc.sql 
	set @prev_day_midnight = DATEADD(dd, DATEDIFF(dd, 0, GETDATE()) - 1, 0);
	--select @prev_day_midnight; 
	--declare @report_key int;
	--set @report_key = 101;
	declare @script_history table 
	( 
		row_number int,
		schedule_key int,
		schedule_no int,
		script_history_key int,
		script_key int,
		start_time datetime,
		end_time datetime,
		done bit,
		error bit
		
	);
	with script_history_with_row 
	as 
	(
		select 
	    ROW_NUMBER() OVER(PARTITION BY h.script_key ORDER BY h.start_time desc) AS row_number,
		sc.schedule_key,sc.schedule_no, h.*
		from ETL.report_script rs 
		join ETL.script s 
		on rs.script_key=s.script_key 
		join ETL.script_history h 
		on s.script_key = h.script_key 
		join ETL.schedule sc  
		on s.schedule_key = sc.schedule_key  
		where rs.report_key = @report_key 
		--and f.frequency_no = 1
	),
	--select * from script_history_with_row
	script_history 
	as 
	(
		select * from script_history_with_row where row_number = 1
	)
	insert into @script_history 
	select * from script_history;
	--select * from @script_history 
	with script_daily 
	as 
	(
		--declare @report_key int;
		-- set @report_key = 100;
		select * 
		from @script_history  
		where schedule_no = 1
	)
	--select * from script_daily 
	select @not_done_or_error=count(*) 
	from script_daily
	where 
	((start_time is null) or 
	(end_time is null) or 
	(end_time < start_time) or 
	(end_time <= @prev_day_midnight) or  
	(done =0) or 
	(error = 1)); 
	--select @not_done_or_error not_done_or_error; 
	select @script_history_count=count(*) from @script_history; 
	--select @script_history_count script_history_count;  
	select @report_script_count=count(*)  
	from ETL.report_script rs 
	join ETL.script s 
	on rs.script_key=s.script_key 
	where rs.report_key = @report_key; 
	--select @report_script_count report_script_count 
	if ( @not_done_or_error  > 0 or 
		 @script_history_count < @report_script_count
		) 
	begin
		select 1 status
	end
	else 
	begin
		select 0 status
	end 
end
