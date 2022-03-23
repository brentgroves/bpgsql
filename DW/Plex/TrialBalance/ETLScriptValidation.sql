Create Schema ETL


-- Drop table ETL.report
CREATE TABLE mgdw.ETL.report (
	report_key int NOT NULL,
	name varchar(100),	
	PRIMARY KEY (report_key)
);
-- truncate table ETL.report
insert into ETL.report 
values (100,'Trial Balance')
,(101,'Daily Metrics')
-- select * from ETL.report

-- DROP TABLE mgdw.ETL.script;
CREATE TABLE mgdw.ETL.script (
	script_key int NOT NULL,
	name varchar(500) NOT NULL,
	frequency_key int not null,
	PRIMARY KEY (script_key)
);
-- truncate TABLE mgdw.ETL.script;
insert into ETL.script 
values 
(100,'AccountingAccount',100),
(101,'AccountingYearCategoryType',100),
(102,'CostGrossMarginDaily',100),
(103,'CostModelsGet',100),
(104,'CostSubTypeBreakdownMatrix',100),
(105,'CustomerOrdersGet',100),
(106,'CustomerPartsGet',100),
(107,'DailyShiftReportGet',100),
(108,'ItemUsageSummaryGet',100),
(109,'PartOperationGet',100),
(110,'ReleasesGetDailyDue',100),
(111,'ReportShippingRevenue',100),
(112,'ShippersHistoryGet',100),
(113,'WorkcentersGet',100)
select * from ETL.script

-- DROP TABLE mgdw.ETL.script_history;
CREATE TABLE mgdw.ETL.script_history (
	script_history_key int IDENTITY(1,1) PRIMARY KEY,
	script_key int not null,
	start_time datetime NULL,
	end_time datetime NULL,
	done bit not null,
);
-- truncate table ETL.script_history
insert into ETL.script_history
values 
(100,100,null,null,0),
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
-- drop table ETL.frequency 
create table ETL.frequency 
(
	frequency_key int not null,
	frequency_no int not null,
	frequency varchar(50) not null
)
insert into ETL.frequency 
values (100,1,'Daily'),
(101,2,'Weekly'),
(102,3,'Monthly'),
(103,4,'Yearly')
select * from ETL.frequency 
-- DROP TABLE mgdw.ETL.report_script;
CREATE TABLE mgdw.ETL.report_script (
	report_key int NOT NULL,
	script_key int not null
	PRIMARY KEY (script_key,report_key)
);
-- truncate table ETL.report_script 
insert into ETL.report_script  
values (100,100)
,(100,101)
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
exec ETL.script_start 101
-- drop procedure ETL.script_start 
create procedure ETL.script_start 
(
	@script_key int
)
as 
begin 
	--declare @script_key int; 
	--set @script_key = 100;
	--(113,113,null,null,0)
	insert into ETL.script_history
	select @script_key,getdate(),null,0
	
end
-- truncate table ETL.script_history
select * from ETL.script_history  
order by script_key, start_time desc

exec ETL.script_end 101 
-- drop procedure ETL.script_end 
create procedure ETL.script_end 
(
	@script_key int
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
	done = 1
	where script_history_key = @script_history_key 
end
select * from ETL.script_history order by script_key,start_time desc    
exec ETL.report_script_status 101
-- drop procedure ETL.report_script_status 
create procedure ETL.report_script_status 
(
	@report_key int
)
as 
begin 
	--declare @report_key int; 
	-- set @reportkey = 100; 
	declare @not_done int;
	declare @script_history_count int;
	
	declare @prev_day_midnight datetime;
	-- see howto/date_calc.sql 
	set @prev_day_midnight = DATEADD(dd, DATEDIFF(dd, 0, GETDATE()) - 1, 0);
	--select @prev_day_midnight; 
	declare @report_key int;
	set @report_key = 100;
	/*
	DECLARE @LOCAL_TABLEVARIABLE TABLE
	(column_1 DATATYPE, 
	 column_2 DATATYPE, 
	 column_N DATATYPE
	)
	select * from ETL.script_history
	*/
	declare @script_history table 
	( 
		row_number int,
		frequency_key int,
		frequency_no int,
		script_history_key int,
		script_key int,
		start_time datetime,
		end_time datetime,
		done int
		
	);
	with script_history_with_row 
	as 
	(
		select 
	    ROW_NUMBER() OVER(PARTITION BY h.script_key ORDER BY h.start_time desc) AS row_number,
		f.frequency_key,f.frequency_no, h.*
		from ETL.report_script rs 
		join ETL.script s 
		on rs.script_key=s.script_key 
		join ETL.script_history h 
		on s.script_key = h.script_key 
		join ETL.frequency f 
		on s.frequency_key = f.frequency_key 
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
		where frequency_no = 1
	)
	--select * from script_daily 
	select @not_done=count(*) 
	from script_daily
	where 
	((start_time is null) or 
	(end_time is null) or 
	(end_time < start_time) or 
	(end_time <= @prev_day_midnight) or  
	(done =0)); 

	with script_history_count 
	as 
	( 
		select count(*) script_history_count from @script_history 
	)
	select * from script_history_count 
	report_script_count 
	as 
	( 
		select count(*) report_script_count 
		from ETL.report_script rs 
		join ETL.script s 
		on rs.script_key=s.script_key 
		where rs.report_key = @report_key 
	)
	select * from report_script_count 
	
	if @not_done > 0 or @script_history_count = 0
	begin
		select 1 status
	end
	else 
	begin
		select 0 status
	end 
end
select * from ETL.script 

/*
 * AccountingAccount
 * mgsqlsrv
 * ssdb
 */
-- truncate table Plex.accounting_account 
select * 
--select count(*)
--into Archive.accounting_account_2022_03_22 -- 19,176
from Plex.accounting_account aa 

/*
AccountingYearCategoryType 
Order: NA  
We only use values in these  
Run this ETL Script in late December.   
It is used to add account category records for each year.  up 
This is needed in YTD calculations which rely on an account  
being a revenue/expense to determine whether to reset YTD values to 0 for every year. 
*/
-- delete from Plex.accounting_account_year_category_type where year = 2022  -- 8241

select *
--into Archive.accounting_account_year_category_type_2022_03_22  -- 24,723
-- select distinct pcn,year
-- select count(*)
from Plex.accounting_account_year_category_type aayct
 

 