-- drop table Plex.Account_Balances_by_Periods
create table Plex.Account_Balances_by_Periods
(
 pcn int,
 revenue decimal(19,5),
 expense decimal(19,5),
 amount decimal(19,5),
 period int,
 Period_Display VARCHAR(10),
 Category_Type VARCHAR(10),
 Category_No INT,
 Category_Name VARCHAR(50),
 [No] VARCHAR(20),
 [Name] VARCHAR(110),
 Ytd_Debit DECIMAL(18,2),
 Ytd_Credit DECIMAL(18,2),
 Current_Debit DECIMAL(18,2),
 Current_Credit DECIMAL(18,2),
 Sub_Category_No INT ,
 Sub_Category_Name VARCHAR(50) ,
 Subtotal_After INT, -- Unused
 Subtotal_Name VARCHAR(50) -- Unused
)
create view Plex.Account_Balances_by_Periods_View as
	select * 
	--select count(*)
	from Plex.Account_Balances_by_Periods  -- 7,617
	--truncate table Plex.Account_Balances_by_Periods
select * 
--select count(*)
--select distinct pcn,period
--select distinct Period_Display 
--delete 
from Plex.Account_Balances_by_Periods order by period
where period between 200812 and 200912
--where period between 201001 and 201811
--where period in (200812)  --4204
where period in (200912)  --4204
where period in (201812)  --4204
where period in (999999,0)  --4,206
where period_display != 'Total'
--where pcn = 300758
where pcn = 123681  -- 8408
and period = 202110
and category_no = 0

select * from Plex.trial_balance_2020_01
/*
 * Make a backup
 */
select * 
--into Archive.Account_Balances_by_Periods_01_27_2022  -- 671,849/663,441
from Plex.Account_Balances_by_Periods
/* 
 * Must delete final comma in CSV file before running ETL script.
 * Must cleanup Total lines when importing CSV
 */
--delete from Plex.Account_Balances_by_Periods
where period in (999999,0)  --4204/4,206
update Plex.Account_Balances_by_Periods
set pcn = 123681 where pcn is null

select count(*)
from Plex.Account_Balances_by_Periods 
where pcn=123681 and period=202201  -- 4204
--where pcn=123681 and period=202112  -- 4204
--where pcn=123681 and period=202111  -- 4204
--where pcn=123681 and period=201811  -- 4204
--where pcn=123681 and period=201001  -- 4204
--where pcn=123681 and period=200912  -- 4204
--where pcn=123681 and period=200911  -- 4204
--where pcn=123681 and period=200910  -- 4204
--where pcn=123681 and period=200909  -- 4204
--where pcn=123681 and period=200908  -- 4204
--where pcn=123681 and period=200907  -- 4204
--where pcn=123681 and period=200906  -- 4204
--where pcn=123681 and period=200905  -- 4204
--where pcn=123681 and period=200904  -- 4204
--where pcn=123681 and period=200903  -- 4204
--where pcn=123681 and period=200902  -- 4204
--where pcn=123681 and period=200901  -- 4204
--where pcn=123681 and period=200812  -- 4204


--where pcn=123681 and period=202012  -- 4204
--where pcn=123681 and period=202011  -- 4204
--where pcn=123681 and period=202010  -- 4204
--where pcn=123681 and period=202009  -- 4204
--where pcn=123681 and period=202008  -- 4204
--where pcn=123681 and period=202007  -- 4204
--where pcn=123681 and period=202006  -- 4204
--where pcn=123681 and period=202005  -- 4204
where pcn=123681 and period=202004  -- 4204
--where pcn=123681 and period=202003  -- 4204
--where pcn=123681 and period=202002  -- 4204
--where pcn=123681 and period=202001  -- 4204
--where pcn=123681 and period=201912  -- 4204
--where pcn=123681 and period=201911  -- 4204
--where pcn=123681 and period=201910  -- 4204
--where pcn=123681 and period=201909  -- 4204
--where pcn=123681 and period=201908  -- 4204
--where pcn=123681 and period=201907  -- 4204
--where pcn=123681 and period=201906  -- 4204
--where pcn=123681 and period=201905  -- 4204
--where pcn=123681 and period=201904  -- 4204
--where pcn=123681 and period=201903  -- 4204
--where pcn=123681 and period=202109  -- 4204
--where pcn=123681 and period=202108  -- 4204
--where pcn=123681 and period=202107  -- 4204
--where pcn=123681 and period=202106  -- 4204
--where pcn=123681 and period=202105  -- 4204
--where pcn=123681 and period=202104  -- 4204
--where pcn=123681 and period=202103  -- 4204
--where pcn=123681 and period=202102  -- 4204
--where pcn=123681 and period=202101  -- 4204
--where pcn=123681 and period=201902  -- 0
--where pcn=123681 and period=201901  -- 4204
--where pcn=123681 and period=201812  -- 4204


select * 
--select count(*)
--select distinct pcn,period
--delete 
from Plex.Account_Balances_by_Periods  -- 15,234

where 
--period_display != 'Total'
--and pcn = 300758
--and pcn = 123681  -- 8408
--and period = 202110
 period = 0
--and category_no = 0


/*
update Plex.Account_Balances_by_Periods 
set pcn=123681
where pcn is null and period=202110
*/
-- delete from Plex.Account_Balances_by_Periods WHERE pcn in (123681,300758)
