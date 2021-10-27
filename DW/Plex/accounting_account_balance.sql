-- TRUNCATE  table Plex.account_balance;
create table Plex.account_balance
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
 Subtotal_Name VARCHAR(50),-- Unused
 primary key (pcn,period,[no]) 
)
select * from Plex.account_balance;

/*
 * 
 * Run GL_Account_Activity_Summary ETL every day 
 * Run Account_Balance_Current_Period sproc to delete/insert new current debit/credit values
 * into Plex.account_balance records for the current period. 
 */
/*
 * 1. Calc period and period_display
 */
declare @year int;
declare @month int;
declare @period int;
declare @period_display varchar(7);
declare @zero_month varchar(2)
set @year = year(getdate());
set @month=9;
--set @month = month(getdate());
set @period = @year*100 + @month;
if (@month < 10)
begin
	set @zero_month = '0' + cast(@month as varchar(2))
end
else
begin
	set @zero_month = cast(@month as varchar(2))
end
set @period_display = cast(@year as varchar(4)) + '-' + @zero_month

--select @year year,@month month,@period period,@period_display period_display;
/*
 * 2. delete Plex.account_balance records for the current period
 * 3. insert Plex.account_balance records with the new current_debit,current_credit values.
 * 4. sum of all periods for current year and update the Plex.account_balance records with the new ytd_debit,ytd_credit values.
 */
select
a.pcn,
a.account_no,
'' revenue,
'' expense,
'' amount,
@period period,
@period_display period_display
--select count(*)
from Plex.accounting_account a 
--where a.pcn = 123681 -- 4,362
left outer join Plex.GL_Account_Activity_Summary s -- gets updated nightly with the current periods credit/debit sums
on a.pcn=s.pcn 
and a.account_no=s.account_no 


