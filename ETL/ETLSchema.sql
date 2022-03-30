Create Schema ETL


-- mgdw.ETL.Report definition
-- Drop table
-- DROP TABLE mgdw.ETL.Report;

CREATE TABLE mgdw.ETL.Report (
	Report_Key int NOT NULL,
	Name varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	CONSTRAINT PK_Report PRIMARY KEY (Report_Key)
);

-- truncate table ETL.report
insert into ETL.report 
values (100,'Trial Balance')
,(101,'Daily Metrics')
-- select * from ETL.report



-- DROP TABLE mgdw.ETL.script;
CREATE TABLE mgdw.ETL.script (
	script_key int NOT NULL,
	script_type_key int null,
	name varchar(500) NOT NULL,
	schedule_key int not null,
	source_control_repo_key int null,
	PRIMARY KEY (script_key)
);
-- truncate TABLE mgdw.ETL.script;
insert into ETL.script 
values 
(5,2,'AccountingPeriod',100,6),
(4,2,'AccountingBalanceUpdatePeriodRange',100,5),
(3,2,'AccountingYearCategoryType.dtsx',100,4),
(1,2,'AccountingAccount.dtsx',100,1),
(2,1,'Invoke-WorkcentersGet.ps1',100,3),

--/* already inserted
(102,1,'CostGrossMarginDaily',100,3),
(103,1,'CostModelsGet',100,3),
(104,1,'CostSubTypeBreakdownMatrix',100,3),
(105,1,'CustomerOrdersGet',100,3),
(106,1,'CustomerPartsGet',100,3),
(107,1,'DailyShiftReportGet',100,3),
(108,1,'ItemUsageSummaryGet',100,3),
(109,1,'PartOperationGet',100,3),
(110,1,'ReleasesGetDailyDue',100,3),
(111,1,'ReportShippingRevenue',100,3),
(112,1,'ShippersHistoryGet',100,3),
(113,1,'WorkcentersGet',100,3)
--*/
select * from ETL.script
create table ETL.script_type  
(
	script_type_key int,
	script_type varchar(50) null,
	CONSTRAINT PK_script_type PRIMARY KEY (script_type_key)
)
select * from ETL.script_type
insert into ETL.script_type 
values 
(1,'powershell'),
(2,'ssis')


-- Drop table

-- DROP TABLE mgdw.ETL.Script_History;

CREATE TABLE mgdw.ETL.Script_History (
	Script_History_Key int IDENTITY(1,1) NOT NULL,
	Script_Key int NOT NULL,
	Start_Time datetime NULL,
	End_Time datetime NULL,
	Done bit NOT NULL,
	Error bit NULL,
	CONSTRAINT PK__Script_H__FDD5ACE1C3BEE50A PRIMARY KEY (Script_History_Key)
);

-- truncate table ETL.script_history
declare @script_key int; 
set @script_key = 114;
--insert into ETL.script_history
	--(113,113,null,null,0)
--	insert into ETL.script_history
select @script_key,getdate(),null,0

values 
(114,null,null,0),
(101,101,null,null,0),
(102,102,null,null,0),
(103,103,null,null,0),
(104,104,null,null,0),
(105,105,null,null,0),
(106,106,null,null,0),
(107,107,null,null,0),
(108,108,null,null,0),
(109,109,null,null,0),
(110,110,null,null,0),
(111,111,null,null,0),
(112,112,null,null,0),
(113,113,null,null,0)
select * from ETL.script_history
where script_key = 114


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

/*
Please call ETL.script_start and ETL.script_end.
The script_key can be found with: select * from ETL.script
Sam suggested to add a ELT.script_history

ETL Script Requirements 
ETL script schema with ETL.script, ETL.report, and ETL.report_script tables. 
Each script and report will have its own script_key and report_key and all 
the scripts needed for a report will be in the ETL.report_script table. 
There are 3 procedures: 
ETL.script_start(script_key): To be ran when the script starts.  
ETL.script_end(script_key): To be ran when the script ends.  
ETL.script_status(report_key):  procedures as I'm working on the TrialBalance automation process. 
select * from ETL.script
 */
exec ETL.script_start 114
-- drop procedure ETL.script_start 
create procedure ETL.script_start 
(
	@script_key int
)
as 
begin 
	--declare @script_key int; 
	--set @script_key = 114;
	--(113,113,null,null,0)
	insert into ETL.script_history
	select @script_key,getdate(),null,0,null
	
end
-- truncate table ETL.script_history
select * from ETL.script_history
--delete from ETL.Script_History
--where script_history_key = 12 
where script_key = 114
order by script_key, start_time desc
exec ETL.script_start 114
exec ETL.script_end 114,0 
-- drop procedure ETL.script_end 
create procedure ETL.script_end 
(
	@script_key int,
	@error_bit bit
)
as 
begin 
	--declare @script_key int;
	--set @script_key = 100
	declare @script_history_key int;
	
	select top 1 @script_history_key=script_history_key 
	from ETL.script_history
	where script_key = @script_key 
	and done = 0
	order by start_time desc 
	
	update ETL.script_history  
	set end_time = getdate(),
	done = 1,
	error = @error_bit 
	where script_history_key = @script_history_key 
end
select * from ETL.script_history order by script_key,start_time desc    
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
select * from ETL.script 

-- drop table ETL.frequency 
create table ETL.schedule 
(
	schedule_key int not null,
	schedule_no int not null,
	schedule varchar(50) not null
)
insert into ETL.schedule 
values (100,1,'Daily'),
(101,2,'Weekly'),
(102,3,'Monthly'),
(103,4,'Yearly')
select * from ETL.schedule 

 