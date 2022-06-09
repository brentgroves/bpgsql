--delete from Plex.accounting_balance_update_period_range where pcn in (123681,300758)
-- truncate TABLE mgdw.Plex.accounting_balance_update_period_range;
select * from Plex.accounting_balance_update_period_range
select * 
--into Archive.accounting_balance_update_period_range
from Plex.accounting_balance_update_period_range 
where pcn in (123681,300758)

-- truncate table Scratch.accounting_account_year_category_type  -- 8,285
select *
--select count(*)
from Scratch.accounting_account_year_category_type  -- 8,285
where pcn in (123681,300758)
and [year] = 2022  -- 8,285

-- truncate table  Scratch.accounting_account_06_03
select *
--select count(*)
from Scratch.accounting_account_06_03  -- 19,286


-- truncate table Scratch.accounting_period  
select *
--into Archive.accounting_period_2022_03_21 -- 1,346
-- select count(*)
from Scratch.accounting_period ap -- 1,418
where period between 202201 and 202205
and pcn = 123681
where period_key = 167272


select * 
--into Archive.Script_History_06_06
from ETL.Script_History sh 
where Script_Key in (1,3,5)
and Start_Time > '2022-06-08' 
order by Script_History_Key desc
-- delete from ETL.Script_History
where Script_Key in (1,3,5)
and Start_Time > '2022-06-08' 

-- mgdw.Plex.accounting_balance_update_period_range definition

-- Drop table

-- DROP TABLE mgdw.Plex.accounting_balance_update_period_range;
-- truncate TABLE mgdw.Plex.accounting_balance_update_period_range;
CREATE TABLE mgdw.Plex.accounting_balance_update_period_range (
	id int IDENTITY(1,1) NOT NULL,
	pcn int NULL,
	period_start int NULL,
	period_end int NULL,
	CONSTRAINT PK__accounti__3213E83F2CF7C4AE PRIMARY KEY (id)
);
select * from Plex.accounting_balance_update_period_range
insert into Plex.accounting_balance_update_period_range (pcn,period_start,period_end) 
      values (123681,202106,202205)

-- mgdw.Plex.accounting_period definition

-- Drop table

-- DROP TABLE mgdw.Scratch.accounting_period;
declare @dt datetime= '1900-01-01';
CREATE TABLE Scratch.accounting_period (
	pcn int NOT NULL,
	period_key int NOT NULL,
	period int NULL,
	fiscal_order int NULL,
	begin_date datetime NULL,
	end_date datetime NULL,
	period_display varchar(7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	quarter_group tinyint NULL,
	period_status int null,
	add_date datetime null,
	update_date datetime null,
	CONSTRAINT PK__accounting_period PRIMARY KEY (pcn,period_key)
);
select *
--into Scratch.accounting_period  -- 1418
from Plex.accounting_period ap 
where add_date = '2012-03-19 15:06:07.360'
2012-03-19 15:06:07.360
--where add_date = '2012-03-19 15:06:07.360000000'
-- truncate table Scratch.accounting_period  
select *
--into Archive.accounting_period_2022_03_21 -- 1,346
-- select count(*)
from Scratch.accounting_period ap -- 1,418
where period between 202201 and 202205
and pcn = 123681
where period_key = 167272

    im2='''insert into Scratch.accounting_period (pcn,period_key,period,period_display,fiscal_order,quarter_group,
									  			  begin_date,end_date,period_status,add_date, update_date) 
    		values (?,?,?,?,?,?,?,?,?,?,?)''' 
--values (123681,45758,200601,1,'2006-01-01 00:00:00.000','2006-01-31 00:00:00.000','01-2006',1,0,'1900-01-01 00:00:00.000','2009-09-02 16:13:00.000')
--	   (123681,45758,200601, '01-2006', 1, 1, '2006-01-01 00:00:00', '2006-01-31 23:59:59', 0, None, '2009-09-02 16:13:00')
--drop procedure Report.accounting_period
insert into Scratch.t1
exec Report.accounting_period 202201,202203
create procedure Report.accounting_period
@start_period int,
@end_period int
as 
select 
period,
period_display,
begin_date,
end_date,
case 
	when period_status = 1 then 'Active'
	else 'Closed'
end status,
update_date updated 
from Plex.accounting_period
where period between @start_period and @end_period
and pcn = 123681
order by pcn,period desc 



-- mgdw.Plex.accounting_account_year_category_type definition

-- Drop table

-- DROP TABLE mgdw.Plex.accounting_account_year_category_type;

CREATE TABLE mgdw.Plex.accounting_account_year_category_type (
	id int IDENTITY(1,1) NOT NULL,
	pcn int NULL,
	account_no varchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[year] int NULL,
	category_type varchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	revenue_or_expense bit NULL,
	CONSTRAINT PK__accounti__3213E83FF126C7A5 PRIMARY KEY (id),
	CONSTRAINT UQ__accounti__22DAE7B5B1F76486 UNIQUE (pcn,account_no,[year])
);
CREATE UNIQUE NONCLUSTERED INDEX UQ__accounti__22DAE7B5B1F76486 ON mgdw.Plex.accounting_account_year_category_type (pcn, account_no, [year]);

-- truncate table Scratch.accounting_account_year_category_type
select *
--select count(*)
from Scratch.accounting_account_year_category_type  -- 8,285
where pcn in (123681,300758)
and [year] = 2022  -- 8,285


--insert into Scratch.accounting_account_year_category_type (pcn,account_no,[year],category_type,revenue_or_expense)
values(123681,10000-000-00000,2022,'Asset',0)

Scratch.accounting_account_year_category_type 

select * 
--into Scratch.accounting_account_year_category_type  -- 24,811
--select count(*)
from Plex.accounting_account_year_category_type
where pcn in (123681,300758)
and [year] = 2022  -- 8,285


CREATE TABLE mgdw.Scratch.accounting_account_06_03 (
	pcn int NOT NULL,
	account_key int NOT NULL,
	account_no varchar(20),
	account_name varchar(110),
	active bit NULL,
	category_type varchar(10),
	category_no_legacy int NULL,
	category_name_legacy varchar(50),
	category_type_legacy varchar(10),
	sub_category_no_legacy int,
	sub_category_name_legacy varchar(50),
	sub_category_type_legacy varchar(10),
	revenue_or_expense bit NULL,
	start_period int NULL,
	PRIMARY KEY (pcn,account_key)
);
-- truncate table  Scratch.accounting_account_06_03
select *
--select count(*)
from Scratch.accounting_account_06_03
select * 
--into Scratch.accounting_account_06_03
select count(*)
from Plex.accounting_account aa -- 19,286
where pcn in (123681) -- 4617
where account_key = 400825 

select * from ETL.Script s where script_key = 1
select * from ETL.Script_History sh where script_key = 1
order by end_time desc 
--truncate table Scratch.accounting_account_06_03
--delete from Scratch.accounting_account_06_03 where pcn in (99999)
select distinct(pcn) from Scratch.accounting_account_06_03
select count(*) from Scratch.accounting_account_06_03
--set @PCNList = '123681,300758,310507,306766,300757'
where pcn in (123681) -- 4,617
--insert into Scratch.accounting_account_06_03
values 
(123681,629753,'10000-000-00000','Cash - Comerica General',0,'Asset',0,'category-name-legacy','cattypeleg',0,'subcategory-name-legacy','subcattleg',0,201604)
--(123681,629753,"10000-000-00000","Cash - Comerica General",0,"Asset",0,"category-name-legacy","category-type-legacy",0,"subcategory-name-legacy","subcategory_type_legacy",0,201604)
select * 
--into Scratch.accounting_account_06_03
from Plex.accounting_account aa where account_key = 400825 