Create Schema ETL




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
-- select * from ETL.Script where name like '%RecreatePer%'
(117,2,'AccountingPeriodBalanceRecreatePeriodRange',1,11)
(116,2,'AccountingPeriodBalanceDeletePeriodRange',1,10),
(6,2,'AccountingBalanceAppendPeriodRange',1,9),
(5,2,'AccountingPeriod',1,6),
(4,2,'AccountingBalanceUpdatePeriodRange',1,5),
(3,2,'AccountingYearCategoryType.dtsx',1,4),
(1,2,'AccountingAccount.dtsx',1,1),
select * from ETL.Script_History 
where script_key = 117
order by start_time  
SELECT @@version;
select * from ETL.script s 
--/* already inserted
(102,1,'Invoke-CostGrossMarginDaily',1,3),
(103,1,'Invoke-CostModelsGet',1,3),
(104,1,'Invoke-CostSubTypeBreakdownMatrix',1,3),
(105,1,'Invoke-CustomerOrdersGet',1,3),
(106,1,'Invoke-CustomerPartsGet',1,3),
(107,1,'Invoke-DailyShiftReportGet',1,3),
(108,1,'Invoke-ItemUsageSummaryGet',1,3),
(109,1,'Invoke-PartOperationGet',1,3),
(110,1,'Invoke-ReleasesGetDailyDue',1,3),
(111,1,'Invoke-ReportShippingRevenue',1,3),
(112,1,'Invoke-ShippersHistoryGet',1,3),
(113,1,'Invoke-WorkcentersGet',1,3),
(114,1,'Invoke-GetReleasesOverdue',1,3)
select distinct script_key from ETL.Script 
select distinct script_key from ETL.Script_History sh 
select * 
from ETL.Script_History sh 
where script_key = 104

--*/
-- drop table ETL.script_type  
create table ETL.script_type  
(
	script_type_key int,
	name varchar(50) null,
	CONSTRAINT PK_script_type PRIMARY KEY (script_type_key)
)
select * from ETL.script_type
insert into ETL.script_type 
values 
(1,'powershell'),
(2,'ssis')

-- drop table ETL.schedule 
create table ETL.schedule 
(
	schedule_key int not null,
	name varchar(100) not null
	CONSTRAINT PK_schedule PRIMARY KEY (schedule_key)
)
insert into ETL.schedule 
values (1,'Daily'),
(2,'Weekly'),
(3,'Monthly'),
(4,'Yearly')
-- select * from ETL.schedule s2 
select 
s.name script 
,st.name script_type 
,sch.name schedule 
from ETL.script s
join ETL.script_type st 
on s.script_type_key = st.script_type_key 
join ETL.schedule sch 
on s.schedule_key = sch.schedule_key 

create table ETL.script_source_dependancy 
(
	script_source_dependancy_key int not null,
	script_key int not null,
	source_dependancy_key int not null, 
	CONSTRAINT PK_script_source_dependancy PRIMARY KEY (script_source_dependancy_key)
)
insert into ETL.script_source_dependancy 
values 
(1,2,4) -- workcenter_get

-- drop table ETL.source_dependancy
-- truncate table ETL.source_dependancy
create table ETL.source_dependancy  
( 
	source_dependancy_key int not null,
	source_dependancy_type_key int not null,
	source_control_repo_key int null,
	
	-- Mobex authored procedure columnus
	system_name varchar(50) null,
	friendly_name varchar(100) null,
	-- Plex web service columnus 
	ws_datasource_name varchar(100) null,
	ws_datasource_key int null,
	soap_request varchar(max) null,
	
	-- Plex authored procedure columnus
	plx_procedure varchar(max) null,
	
	CONSTRAINT PK_source_dependancy PRIMARY KEY (source_dependancy_key)
)
select * from ETL.source_dependancy  
insert into ETL.source_dependancy  
values 
(3,2,2
,'sproc300758_11728751_1999565','accounting_balance_update_period_range_dw_import'
,null,null,null
,null
),
(2,2,2
,'sproc300758_11728751_1999909','accounting_year_category_type_dw_import'
,null,null,null
,null
),
(1,2,2
,'sproc300758_11728751_1978024','accounting_account_DW_Import'
,null,null,null
,null 
),
(4,1,8
,null,null
,'Workcenter_Get',4031,
'<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:dat="http://www.plexus-online.com/DataSource">
   <soap:Header />
   <soap:Body>
      <dat:ExecuteDataSource>
         <dat:ExecuteDataSourceRequest>
            <dat:DataSourceKey>4031</dat:DataSourceKey>
            <dat:InputParameters>
               <dat:InputParameter>
                  <dat:Value>$Active</dat:Value>
                  <dat:Name>Active</dat:Name>
               </dat:InputParameter >
            </dat:InputParameters>
         </dat:ExecuteDataSourceRequest>
      </dat:ExecuteDataSource>
   </soap:Body>
</soap:Envelope>
'
,null
)

select 
s.name script 
,script_proj.name script_proj  
,script_repo.name script_repo 
,st.name script_type 
,sch.name schedule 
,sd.system_name,sd.friendly_name 
,sd.ws_datasource_name
,dependancy_proj.name dependancy_proj  
,dependancy_repo.name dependancy_repo
-- select count(*)
from ETL.script s
join ETL.script_type st 
on s.script_type_key = st.script_type_key 
join ETL.schedule sch 
on s.schedule_key = sch.schedule_key 

left outer join ETL.source_control_repo script_repo  
on s.source_control_repo_key = script_repo.source_control_repo_key  
left outer join ETL.source_control_project script_proj 
on script_repo.source_control_project_key = script_proj.source_control_project_key 


left outer join ETL.script_source_dependancy ssd 
on s.script_key =ssd.script_key 
left outer join ETL.source_dependancy sd 
on ssd.source_dependancy_key = sd.source_dependancy_key 

left outer join ETL.source_control_repo dependancy_repo  
on sd.source_control_repo_key = dependancy_repo.source_control_repo_key  
left outer join ETL.source_control_project dependancy_proj 
on dependancy_repo.source_control_project_key = dependancy_proj.source_control_project_key 


select r.source_control_repo_key,r.name repo,p.name source_control_project  
from ETL.source_control_repo r 
join ETL.source_control_project p 
on r.source_control_project_key = p.source_control_project_key 
-- drop table ETL.source_dependancy_type 
create table ETL.source_dependancy_type  
( 
	source_dependancy_type_key int not null,
	name varchar(100) not null,
)
select * from ETL.source_dependancy_type 
insert into ETL.source_dependancy_type 
values 
(1,'web service'),
(2,'Mobex authored procedure'),
(3,'Plex authored procedure')


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
-- select * from ETL.Script_History 
-- truncate table ETL.script_history
declare @script_key int; 
set @script_key = 114;
--insert into ETL.script_history
	--(113,113,null,null,0)
--	insert into ETL.script_history
select @script_key,getdate(),null,0

select * from ETL.script_history
where script_key = 6



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
exec ETL.script_start 4
-- drop procedure ETL.script_start 
create procedure ETL.script_start 
(
	@script_key int
)
as 
begin 
	--declare @script_key int; 
	--set @script_key = 4;
	insert into ETL.script_history
	select @script_key,getdate(),null,0,null,null
	
end
-- truncate table ETL.script_history
select * from ETL.script_history
--delete from ETL.Script_History
--where script_history_key = 44 
where script_key =4
order by script_key, start_time desc
exec ETL.script_start 4
exec ETL.script_end 4,0 
-- drop procedure ETL.script_end 
create procedure ETL.script_end 
(
	@script_key int,
	@error_bit bit
)
as 
begin 
	--declare @script_key int;
	--set @script_key = 4;
	--declare @error_bit bit; 
	--set @error_bit = 0;
	declare @script_history_key int;
	declare @cur_time datetime;
	declare @start_time datetime; 
	set @cur_time = getdate();
	select top 1 @script_history_key=script_history_key,@start_time=start_time  
	from ETL.script_history
	where script_key = @script_key 
	and done = 0
	order by start_time desc 
  --  select @script_history_key,@start_time,DATEDIFF(ss, @start_time,@cur_time); 	
	update ETL.script_history  
	set end_time = @cur_time,
	done = 1,
	error = @error_bit,
	time = DATEDIFF(ss, @start_time,@cur_time)
	where script_history_key = @script_history_key 
end
select * from ETL.script_history order by script_key,start_time desc    
select * from ETL.script 



-- drop table ETL.source_control_repo  
-- truncate table ETL.source_control_repo 
create table ETL.source_control_repo  
(
	source_control_repo_key int,
	source_control_project_key int not null,
	name varchar(100) not null,
	CONSTRAINT PK_source_control_repo PRIMARY KEY (source_control_repo_key,source_control_project_key)
)
select r.name repo,p.name source_control_project  
from ETL.source_control_repo r 
join ETL.source_control_project p 
on r.source_control_project_key = p.source_control_project_key 
insert into ETL.source_control_repo  
values
(11,1,'AccountingPeriodBalanceRecreatePeriodRange')
(10,1,'AccountingPeriodBalanceDeletePeriodRange')
(9,1,'AccountingBalanceAppendPeriodRange')
(8,3,'PlexSoapUI'),
(7,3,'PlexSoap'),
(6,1,'AccountingPeriod'),
(5,1,'AccountingBalanceUpdatePeriodRange'),
(4,1,'AccountingYearCategoryType'),
(1,1,'AccountingAccount'),
(2,2,'MobexSQL'),
(3,1,'PlexETLScripts')


-- drop table ETL.source_control_project
-- truncate table ETL.source_control_project
create table ETL.source_control_project 
(
	source_control_project_key int,
	name varchar(100) not null,
	CONSTRAINT PK_source_control_project PRIMARY KEY (source_control_project_key)
)
select * from ETL.source_control_project
insert into ETL.source_control_project 
values 
(3,'Soap'),
(1,'PlexETLScripts'),
(2,'MobexSQL')


 