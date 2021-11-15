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
	from Plex.Account_Balances_by_Periods
	where period_display != 'Total'
select * from Plex.Account_Balances_by_Periods_View
	--truncate table Plex.Account_Balances_by_Periods
select * 
--select count(*)
select distinct pcn,period
from Plex.Account_Balances_by_Periods
where period_display != 'Total'
--where pcn = 300758
where pcn = 123681  -- 8408
and period = 202110
and category_no = 0

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
