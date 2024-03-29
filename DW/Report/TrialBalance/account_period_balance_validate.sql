/*
 * Important Backups
 */
select * 
--into Archive.account_balance_06_15_2022 -- 48,114
from Plex.accounting_balance ab -- 46,926

select * 
INTO Archive.account_period_balance_2022_06_15  -- 140,713
--INTO Archive.account_period_balance_2022_06_10  -- 140,713
from Plex.account_period_balance 

/*
 * Definitions
 */
select distinct pcn,(year)  from Plex.accounting_account_year_category_type aayct 
select count(*) from Plex.accounting_account_year_category_type aayct  -- 24,811, 24,767, 24,723
select count(*) from Scratch.accounting_account_year_category_type aayct  -- 24,811, 24,767, 24,723
WHERE year = 2022 -- 8,285
select * from Plex.accounting_account_year_category_type aayct  -- 24,767, 24,723

select distinct pcn,account_no from Plex.accounting_account aa order by pcn,account_no 
select count(*) from Plex.accounting_account  -- 19,286,19,176
select count(*) from Scratch.accounting_account_06_03  -- 19,286  -- 19,286,19,176

select * from Plex.accounting_account  -- 19,286,19,176
where account_no like '73250%' --22 73250

--select * from Plex.accounting_account  -- 19,286,19,176
where pcn = 123681 -- 4,617
select distinct pcn,period from Plex.accounting_period ap 
select count(*) from Plex.accounting_period ap -- 1418
select count(*) from Scratch.accounting_period ap -- 1418
select * from Plex.accounting_period
where pcn = 123681 and period between 202201 and 202206 -- 2022-06-03 19:50:00.000
order by pcn,period 
select * from Plex.accounting_balance_update_period_range -- 202105/202204
select * from Scratch.accounting_balance_update_period_range -- 202105/202204
select count(*) from Plex.accounting_balance ab -- 48,113, 48,023/ 47,546 / 46,926
select count(*) from Scratch.accounting_balance ab -- 48,113, 48,023/ 47,546 / 46,926
select * 
--into Archive.account_balance_06_10 -- 
from Plex.accounting_balance ab -- 46,926
where account_no like '73250%' --22 73250 
select * from Plex.account_period_balance ab -- 46,926
where account_no like '73250-000%' --22 73250 
and pcn = 123681 
order by period 
select distinct pcn,period from Plex.accounting_balance  order by pcn,period  --, 200812 to 202204
select count(*) from Plex.account_period_balance apb -- 140,713/ 132,428,123,659,131,900, 123,615
select count(*) from Scratch.account_period_balance apb -- 140,713/ 132,428,123,659,131,900, 123,615
where period < 202107  -- 41293
select count(*) from Archive.account_period_balance_2022_06_11 apb -- 140,713/ 132,428,123,659,131,900, 123,615
where period < 202107  -- 41293
select * from Plex.accounting_account  -- 19,286,19,176
where account_no like '73250%' --22 73250 
select * from Plex.account_period_balance apb -- 131,900, 123,615
where account_no like '73250%' --22 73250 
and pcn = 123681 order by account_no 
select distinct pcn,period from Archive.account_period_balance_05_12_2022 order by pcn,period  --, 200812 to 202204
select distinct pcn,period from Plex.account_period_balance order by pcn,period -- 202101 to 202203
select * 
--INTO Archive.account_period_balance_2022_06_10  -- 140,713
from Plex.account_period_balance 
Accounting_account: AccountingAccount ETL Script 
select * 
into Archive.accounting_account_2022_02_16
from Plex.accounting_account aa 
select count(*) from Plex.accounting_account aa -- 19,286/19,176
--select count(*) from Archive.accounting_account_2022_02_16
where pcn = 123681  -- 4,595

AccountingYearCategoryType: Run this ETL Script in late December.  
It is used to add account category records for each year.  
This is needed in YTD calculations which rely on if an account 
is a revenue/expense to determine whether to reset YTD values to 0 for every year. 
select distinct pcn,(year)  from Plex.accounting_account_year_category_type aayct 
select count(*) from Plex.accounting_account_year_category_type aayct  -- 24,723
select * 
--into Archive.accounting_account_year_category_type_2022_02_16
-- select count(*) from Archive.accounting_account_year_category_type_2022_02_16  -- 24,723
-- select count(*)
from Plex.accounting_account_year_category_type aayct  -- 24,811/ 24,723
--where pcn = 123681 -- 13,785  
where [year] = 2021 -- 8,241

-- delete from Plex.accounting_account_year_category_type
where [year] = 2021 -- 4,595



AccountBalancesByPeriod: Procedure that calls a Plex authored SPROC. Cannot 
create a Plex SQL SPROC for this because we don’t have the code for many of the sub-procedures.  
Can only call this procedure for the Albion PCN from an ETL script, but 
we can download a CSV and import that with an ETL script for any PCN. 
select distinct pcn,period from plex.Account_Balances_by_Periods order by pcn,period desc

TrialBalance ETL script that takes as input the Plex Trial Balance CSV file.   
select distinct pcn,period from Plex.trial_balance_multi_level order by pcn,period desc

GL_Account_Activity_Summary ETL script is used to validate accounts no longer showing in 
the Trial Balance Multi level report.

 Accounting_period ETL script is used to refresh the DW accounting_period table containing 
 start and end period dates and fiscal order info 
 select *
 -- select count(*)
 -- select distinct pcn from Archive.accounting_period_2022_02_16 -- 1,274 -- 123681 (204612)
 -- select distinct pcn,period from Archive.accounting_period_2022_02_16 -- 1,274 -- 123681 (204612)
 -- select distinct pcn,period from Archive.accounting_period -- 123681 (204612)
 -- select distinct pcn from Archive.accounting_period
 -- select count(*) from Archive.accounting_period_2022_02_16 -- 1,274
 --into Archive.accounting_period_2022_02_16 
 from Plex.accounting_period p  -- 1,346
 left outer join Archive.accounting_period_2022_02_16 a 
 on p.pcn = a.pcn 
 and p.period_key = a.period_key 
 where a.pcn is null 

-2. Run the Accounting_account ETL script.  
Issue: This is used to generate records in account_period_balance. Since the previous 12 months account_period_balance gets  regenerated 
when a new period gets appended if the category type changes or an account somehow gets removed the previous 12 months worth of records get be affected.  

-1: AccountingYearCategoryType: Run this ETL Script in late December.   
It is used to add account category records for each year.  up 
This is needed in YTD calculations which rely on if an account  
is a revenue/expense to determine whether to reset YTD values to 0 for every year. 

0. Run the Accounting_period ETL script 
Accounting_period ETL script is used to refresh the DW accounting_period table containing  
start and end period dates and fiscal order info. I think period in the distant future get added periodically. 
 
1. AccountingBalanceUpdatePeriodRange ETL script to update the Plex.accounting_balance_update_period_range table  
select * from Plex.accounting_balance_update_period_range abupr  
Validated: 2022-02-18

2. Run the AccountingBalanceAppendPeriodRange ETL script which uses the values in the the Plex.accounting_balance_update_period_range table 
to determine what range of Plex.accounting_balance records to update. 
a. run the Plex.accounting_balance_delete_period_range 
-- SELECT distinct pcn,period FROM Plex.accounting_balance order by pcn,period 
--delete from Plex.accounting_balance where pcn = 300758
b. run the Plex.accounting_balance_append_period_range_DW_Import procedure to refresh/add Plex.accounting_balance records with current values. 
Validated: 2022-02-18


3. run the AccountPeriodBalanceDeletePeriodRange ETL Script to delete the periods that are to be recalculated 
-- select distinct pcn,period from Plex.account_period_balance apb order by pcn,period
--using start and end period in the Plex.accounting_balance_update_period_range table. 
Validated: 2022-02-18

4. Run the AccountPeriodBalanceRecreatePeriodRange ETL Script to run the Plex.account_period_balance_recreate_period_range procedure 
-- select distinct pcn,period from Plex.account_period_balance order by pcn,period
Validated: 2022-02-18

5. Add or update Plex.trial_balance_multi_level records using the TrialBalance ETL script.  If you are sure there have been no changes 
to previous period values then just run the script for the current period. 
select distinct pcn,period from Plex.trial_balance_multi_level order by pcn,period

6. Add or update Plex.Account_Balances_by_Periods using the AccountBalancesByPeriod  ETL script.  If you are sure there have been no changes 
to previous period values then just run the script for the current period. 
select distinct pcn,period from Plex.Account_Balances_by_Periods order by pcn,period

7. Add or update Plex.GL_Account_Activity_Summary using the GLAccountActivitySummary  ETL script.  If you are sure there have been no changes 
to previous period values then just run the script for the current period. 
select distinct pcn,period from Plex.GL_Account_Activity_Summary order by pcn,period

8. Validate period balance calculations from Plex.account_period_balance_validate  
-- mgdw.Plex.accounting_balance definition

select * from ETL.Script s 
-- Drop table

-- DROP TABLE mgdw.Plex.accounting_balance;

CREATE TABLE mgdw.Plex.accounting_balance (
	pcn int NOT NULL,
	account_key int NOT NULL,
	account_no varchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	period int NOT NULL,
	debit decimal(19,5) NULL,
	credit decimal(19,5) NULL,
	balance decimal(19,5) NULL,
	CONSTRAINT PK__accounti__34E7554F34C584AF PRIMARY KEY (pcn,account_key,period)
);



The computed trial_balance multi level report table 
select distinct pcn,period from Plex.account_period_balance b order by pcn, period desc
 
Add a new period to the Plex.account_period_balance table.
select distinct pcn,period from Plex.Account_Balances_by_Periods order by pcn,period
select *
--into Archive.Account_Balances_by_Periods_2022_01_24
--select count(*)
from Plex.Account_Balances_by_Periods -- 667,645
select count(*) from Archive.Account_Balances_by_Periods_2022_01_24  -- 667,645
/*
 * Backup
 */
--select * 
--into Archive.account_period_balance_12_30
--from Plex.account_period_balance b -- 43,630
--select count(*) from Archive.account_period_balance_2022_06_04 -- 140,713
/*
 * When was the last posting to occur for each period.
 */
declare @pcn int;
set @pcn= 123681;
declare @period_start int;
set @period_start = 202101;
declare @period_end int;
set @period_end = 202205;
--select *
-- select count(*)
select pcn,period,add_date,update_date 
-- select count(*) from Archive.accounting_period_2022_06_04 -- 1417
--into Archive.accounting_period_2022_06_01 -- 1417
from Plex.accounting_period ap 
where pcn=@pcn
and period between 202101 and 202205  --2022-06-03 19:50:00.000
order by period 
select *
from Plex.accounting_period ap 
where pcn=123681
and period between 202101 and 202204
order by period 

/*
 * Does the values in this view match with the CSV download and the TB PP?
 */

/*
select b.pcn,b.account_no,
b.period,
a.revenue_or_expense,
b.debit snapshot_debit,s.debit GL_debit,p.current_debit PP_debit,
b.credit snapshot_credit,s.credit GL_credit,p.current_credit PP_credit,
b.balance,(p.Current_Debit - p.Current_Credit) PP_debit_credit, d.current_debit_credit TB_balance,
b.ytd_debit,p.ytd_debit PP_ytd_debit,
b.ytd_credit,p.ytd_credit PP_ytd_credit,
b.ytd_balance,
d.ytd_debit_credit TB_ytd_balance,
p.ytd_debit-p.ytd_credit PP_ytd_balance,
(b.ytd_balance - d.ytd_debit_credit) Diff_of_ytd_balances

*/

/*
 * Are there any accounts that we are not showing in our report?
 */
declare @pcn int;
set @pcn= 123681;
declare @period_start int;
set @period_start = 202101;
declare @period_end int;
set @period_end = 202205;

select count(*)
from Plex.trial_balance_multi_level t -- 685,252
--left outer join Scratch.account_period_balance b -- 123,615
left outer join Plex.account_period_balance b -- 123,615
on b.pcn=t.pcn
and b.account_no = t.account_no
and b.period = t.period -- 688,665
where t.period between @period_start and @period_end -- 67,264/2021-01 to 2022-04
and b.pcn is null -- 0

/*
 * Are there any accounts that we are not showing in our report?
 */
declare @pcn int;
set @pcn= 123681;
declare @period_start int;
set @period_start = 202101;
declare @period_end int;
set @period_end = 202205;

select count(*)
from Plex.Account_Balances_by_Periods p -- 43,620
--left outer join Scratch.account_period_balance b -- 123,615
left outer join Plex.account_period_balance b -- 123,615
on b.pcn=p.pcn
and b.account_no = p.[no]
and b.period = p.period -- 688,665
where p.period between @period_start and @period_end -- 70,677/2021-01 to 2022-04
and b.pcn is null -- 0

/*
 * Are there any accounts that we are not showing in our report?
 */
declare @pcn int;
set @pcn= 123681;
declare @period_start int;
set @period_start = 202101;
declare @period_end int;
set @period_end = 202205;

select count(*)
from Plex.GL_Account_Activity_Summary s -- 39,612
--left outer join Scratch.account_period_balance b -- 123,615
left outer join Plex.account_period_balance b -- 123,615
on b.pcn=s.pcn
and b.account_no = s.account_no
and b.period = s.period -- 39,612
where s.period between @period_start and @period_end -- 3,953/2021-01 to 2022-04
and b.pcn is null -- 0

/*
 * Does python generated TB records match the Azure Pipeline records
 */
select * from Scratch.accounting_balance_update_period_range
--exec Scratch.accounting_balance_delete_period_range
select count(*) from Scratch.accounting_balance ab -- 48,114/40,883
--exec Scratch.account_period_balance_delete_period_range  --99,420
select count(*) from Scratch.account_period_balance ab -- 140,713/41,293
--exec Scratch.account_period_balance_recreate_period_range

select * from Plex.accounting_balance_update_period_range
--exec Plex.accounting_balance_delete_period_range
select count(*) from Plex.accounting_balance ab -- 48,114/40,883
--exec Plex.account_period_balance_delete_period_range  -- 99,420
select count(*) from Plex.account_period_balance ab -- 140,713/41,293
--exec Plex.account_period_balance_recreate_period_range


declare @pcn int;
set @pcn= 123681;
declare @period_start int;
set @period_start = 202101;
declare @period_end int;
set @period_end = 202205;

select count(*)
from Scratch.account_period_balance b 
where b.period between @period_start and @period_end -- 140,713/2021-01 to 2021-05 

select count(*)
from Plex.account_period_balance b 
where b.period between @period_start and @period_end -- 140,713/2021-01 to 2022-05



declare @pcn int;
set @pcn= 123681;
declare @period_start int;
set @period_start = 202101;
declare @period_end int;
set @period_end = 202205;

select count(*)
from Plex.account_period_balance b 
LEFT OUTER JOIN Scratch.account_period_balance ab 
ON b.pcn=ab.pcn 
AND b.account_no=ab.account_no 
AND b.period=ab.period
where b.period between @period_start and @period_end -- 3,953/2021-01 to 2022-04
and ab.pcn is null -- 0

/*
 * Swith left and right tables. Does python generated TB records match the Azure Pipeline records
 */
declare @pcn int;
set @pcn= 123681;
declare @period_start int;
set @period_start = 202101;
declare @period_end int;
set @period_end = 202205;

select count(*)
from Scratch.account_period_balance ab 
LEFT OUTER JOIN Plex.account_period_balance b
ON b.pcn=ab.pcn 
AND b.account_no=ab.account_no 
AND b.period=ab.period
where b.period between @period_start and @period_end -- 3,953/2021-01 to 2022-04
and b.pcn is null -- 0

/*
 * Does python generated TB records match the Azure Pipeline records
 */
declare @pcn int;
set @pcn= 123681;
declare @period_start int;
set @period_start = 202101;
declare @period_end int;
set @period_end = 202205;

/*
select b.account_no,b.period,b.debit, ab.debit s_debit,
b.credit, ab.credit s_credit, b.balance, ab.balance s_balance, 
b.ytd_debit, ab.ytd_debit,b.ytd_credit, ab.ytd_credit,b.ytd_balance, ab.ytd_balance 
*/
select count(*)
from Plex.account_period_balance b 
LEFT OUTER JOIN Scratch.account_period_balance ab 
ON b.pcn=ab.pcn 
AND b.account_no=ab.account_no 
AND b.period=ab.period
--where b.pcn=@pcn and b.period between @period_start and @period_end  --78,423/2021-01 to 2022-05
--where b.pcn=@pcn and b.period between @period_start and @period_end and ab.pcn is not null --78,423/2021-01 to 2022-05 
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.debit=ab.debit --78,423/2021-01 to 2022-05
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.credit = ab.credit  --78,423/2021-01 to 2022-05
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.balance =ab.balance  --78,423/2021-01 to 2022-05
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.ytd_credit = ab.ytd_credit  --78,423/2021-01 to 2022-05
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.ytd_debit = ab.ytd_debit  --78,423/2021-01 to 2022-05
where b.pcn=@pcn and b.period between @period_start and @period_end and b.ytd_balance = ab.ytd_balance --78,423/2021-01 to 2022-05


select * 
--into Archive.Script_History_06_06
from ETL.Script_History sh 
where Script_Key in (1,3,4,5,6,116,117)
and Start_Time > '2022-06-15' 
order by Script_History_Key desc
-- delete from ETL.Script_History
where Script_Key in (1,3,4,5,6,116,117)
and Start_Time > '2022-06-15' 



--b.balance -d.current_debit_credit  diff

declare @pcn int;
set @pcn= 123681;
declare @period_start int;
set @period_start = 202101;
declare @period_end int;
set @period_end = 202205;

/*
SElect 
b.period,b.account_no
,b.credit our_credit, p.current_credit pp_credit
,s.debit gl_debit, b.debit our_debit
,b.ytd_credit our_ytd_credit,p.Ytd_Credit pp_ytd_credit
,b.ytd_debit our_ytd_debit,p.Ytd_Debit  pp_ytd_debit
,b.ytd_balance our_ytd_balance, p.Ytd_Debit - p.Ytd_Credit pp_ytd_balance, d.ytd_debit_credit tb_ytd_debit_credit 
*/
select count(*) 
from Plex.account_period_balance b -- 140,713/123,615
--where b.period between 202101 and 202203
--and b.pcn = 123681 -- 4595*15=45950+22975 = 68925
inner join Plex.accounting_account a 
on b.pcn=a.pcn 
and b.account_no=a.account_no -- 766,413
--LEFT OUTER JOIN Scratch.account_period_balance ab 
--ON b.pcn=ab.pcn 
--AND b.account_no=ab.account_no 
--AND b.period=ab.period
left outer join Plex.trial_balance_multi_level d -- TB download does not show the plex period for a multi period month, you must link to period_display
on b.pcn=d.pcn
and b.account_no = d.account_no
and b.period_display = d.period_display 
-- select * from Plex.Account_Balances_by_Periods p 
--select distinct pcn,period from Plex.Account_Balances_by_Periods p order by pcn,period -- 123,681 (200812-202110)
--select * from Plex.Account_Balances_by_Periods p where pcn=123681
-- select  
--select top(10) *
--into Scratch.Account_Balances_by_Periods
--select *
--into Archive.Account_Balances_by_Periods_2022_01_11  -- 667,645
--from Plex.Account_Balances_by_Periods p
left outer join Plex.Account_Balances_by_Periods p -- 43,620
on b.pcn=p.pcn
and b.account_no = p.[no]
and b.period = p.period 
--inner join 
left outer join 
(
	select s.pcn,s.period, s.account_no,s.debit,s.credit,s.debit-s.credit balance
	--select count(*)
--select distinct pcn,period from Plex.GL_Account_Activity_Summary s order by pcn,period -- 123,681 (200812-202203)
--select * from Plex.GL_Account_Activity_Summary s where pcn=123681 and period = 202111  -- dont know when this was imported probably in early december
	from Plex.GL_Account_Activity_Summary s  --(),(221,202010)
--	where s.pcn = 123681 
--	and s.period between 202101 and 202201  -- 2,462/2,718/2,975
) s
on b.pcn=s.pcn 
and b.account_no=s.account_no
and b.period=s.period  
--where b.pcn=@pcn and b.period between @period_start and @period_end  --78,423/2021-01 to 2022-05, 73,806/2021-01 to 2022-04/68,925/2021-01 to 2022-03 -- 69,189
--where b.pcn=@pcn and b.period between @period_start and @period_end and ab.pcn is not null 
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.debit=ab.debit  
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.credit = ab.credit  
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.balance =ab.balance  
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.ytd_credit = ab.ytd_credit  
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.ytd_debit = ab.ytd_debit  
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.ytd_balance = ab.ytd_balance 


--where b.pcn=@pcn and b.period=202201 and b.account_no = '73100-000-0000'
--DEBUG ONLY where b.pcn=@pcn and b.period between @period_start and @period_end and b.account_no like '4%' and b.period = 202201 and b.credit  > 0
--where b.pcn=@pcn and b.period between @period_start and @period_end and p.pcn is not null -- 71,468/2021-01 to 2022-05, 67,264/2021-01 to 2022-04, 63,060/2021-01 to 2022-03
--where b.pcn=@pcn and b.period between @period_start and @period_end and p.pcn is null and s.pcn is not null  --56/2021-01 to 2022-05, 53/2021-01 to 2022-04 --5/2021-01 to 2022-03 -- 47/2021-01 to 2022-03 --42/2021-01 to 2022-01 -- 38/2021-01 to 2021-12  account periods with activity not on the TB report.


--where b.pcn=@pcn and b.period between @period_start and @period_end and s.pcn is not null  --4,190/2021-01 to 2022-05-pulled-06-14,--4,186/2021-01 to 2022-05-pulled-06-04 --4,177/2021-01 to 2022-05--3,953/2021-01 to 2022-04 --3,696/2021-01 to 2022-03 --3,446/2021-01 to 2022-02-- 3,217/2021-01 to 2022-01 -- 2,975/2021-01 to 2021-12
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.debit=s.debit  --4,190/2021-01 to 2022-05-pulled-06-14--4,186/2021-01 to 2022-05-pulled-06-04--4,177/2021-01 to 2022-05--3,953/2021-01 to 2022-04 --3,696/2021-01 to 2022-03 --3,446/2021-01 to 2022-02-- 3,217/2021-01 to 2022-01 -- 2,975/2021-01 to 2021-12
--where b.pcn=@pcn and b.period between @period_start and @period_end and (s.debit != b.debit) -- 0/2021-01 to 2022-04 -- 0/2021-01 to 2022-03 -- 0/2021-01 to 2021-12

--where b.pcn=@pcn and b.period between @period_start and @period_end and b.credit = s.credit  --4,190/2021-01 to 2022-05-pulled-06-14--4,186/2021-01 to 2022-05-pulled-06-04--4,177/2021-01 to 2022-05--3,953/2021-01 to 2022-04 -- 3,696/2021-01 to 2022-03 -- 2,975/2021-01 to 2021-12
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.credit != s.credit -- 0/2021-01 to 2022-05 -- 0/2021-01 to 2022-04 -- 0/2021-01 to 2022-03 
--select b.credit, * from Plex.accounting_balance b where pcn= 123681 and period = 202201 and account_no = '39100-000-0000'
--39100-000-0000 - Retained Earnings -Year End Close Credit	1,826,771.83, 2022-01 was last updated on 2/11/2022 4:45:00 PM
-- but this Year End Close transaction has a date of 2/18/2022 9:30:50 AM
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.balance =s.balance  --4,190/2021-01 to 2022-05-pulled-06-14--4,186/2021-01 to 2022-05-pulled-06-04--4,177/2021-01 to 2022-05--3,953/2021-01 to 2022-04 -- 3,696/2021-01 to 2022-03 -- 2,975/2021-01 to 2021-12
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.balance !=s.balance -- 0

--where b.pcn=@pcn and b.period between @period_start and @period_end and b.balance = d.current_debit_credit  --71,432/2021-01 to 2022-05 --67,228/2021-01 to 2022-04 --63,028/2021-01 to 2022-03 --50,423/2021-01 to 2021-12
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.balance != d.current_debit_credit  -- 36/2021-01 to 2022-05 -- 36/2021-01 to 2022-04 -- 32/2021-01 to 2022-03 -- 25/2021-01 to 2021-12
--where b.pcn=@pcn and b.period between @period_start and @period_end and (b.balance - d.current_debit_credit) >  0.01 -- 0/2021-01 to 2022-05-- 0/2021-01 to 2022-04 -- 0/2021-01 to 2022-03 -- 0/2021-01 to 2021-12
--where a.account_no = '22500-000-0000' and b.period=202203

--where b.pcn=@pcn and b.period between @period_start and @period_end and b.credit = p.current_credit  -- 71,468/2021-01 to 2022-05-- 67,264/2021-01 to 2022-04 -- 63,060/2021-01 to 2022-03 --50,448/2021-01 to 2021-12
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.credit != p.current_credit  -- 0/2021-01 to 2022-05 -- 0/2021-01 to 2022-04 -- 0/2021-01 to 2022-03 --0/0 
-- failed on 49300-000-0000
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.debit = p.current_debit  -- 71,468/2021-01 to 2022-05-- 67,264/2021-01 to 2022-04-- 63,060/2021-01 to 2022-03 -- 50,448/2021-01 to 2021-12
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.debit != p.current_debit  -- 0/2021-01 to 2022-01 -- 0 
--22600-000-0000, 22900-000-0000 signs are reversed

--where b.pcn=@pcn and b.period between @period_start and @period_end and (b.balance = p.Current_Debit - p.Current_Credit)  -- 71,468/2021-01 to 2022-05-- 67,264/2021-01 to 2022-04 -- 63,056/2021-01 to 2022-03 -- 50,448/2021-01 to 2021-12
--where b.pcn=@pcn and b.period between @period_start and @period_end and (b.balance != p.Current_Debit - p.Current_Credit)   -- 0/2021-01 to 2022-01 --0/2021-01 to 2021-12

--where b.pcn=@pcn and b.period between @period_start and @period_end and b.ytd_credit = p.ytd_credit  -- 71,463/2021-01 to 2022-05-- 67,260/2021-01 to 2022-04-- 63,057/2021-01 to 2022-03 -- 50,448/2021-01 to 2021-12--
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.ytd_credit != p.ytd_credit  -- 5/2021-01 to 2022-05-- 4/2021-01 to 2022-04 -- 3/2021-01 to 2021-12
-- ISSUE: 1 ACCOUNT,73100-000-0000, IS NOT THE SAME
-- See issue section at the bottom of this procedure and the Mobex Plex procedure: accounting_year_category_type_issue 
-- 73100-000-0000 has different category_types in accounting_v_account it is an Expense and in accounting_v_category_type it is a liability
-- Conclusion: The Plex TB report and Plex authored procedure is wrong to not reset YTD values.
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.ytd_debit = p.ytd_debit  -- 71,463/2021-01 to 2022-05-- 67,260/2021-01 to 2022-04--63,053/2021-01 to 2022-03 -- 50,448/2021-01 to 2021-12
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.ytd_debit != p.ytd_debit  -- 5/2021-01 to 2022-05-- 4/2021-01 to 2022-04 -- 3/2021-01 to 2022-03 -- 0/2021-01 to 2021-12
-- ISSUE: 1 ACCOUNT IS NOT THE SAME
-- See issue section at the bottom of this procedure and the Mobex Plex procedure: accounting_year_category_type_issue 
-- 73100-000-0000 has different category_types in accounting_v_account it is an Expense and in accounting_v_category_type it is a liability
-- Conclusion: The Plex TB report and Plex authored procedure is wrong to not reset YTD values.
--WHere b.pcn=@pcn and b.period between @period_start and @period_end and (d.ytd_debit_credit = (p.ytd_debit-p.ytd_credit))  --71,248/2021-01 to 2022-05-pulled-06-14--71,250/2021-01 to 2022-05-pulled-06-04--71,249/2021-01 to 2022-05--67,056/2021-01 to 2022-04 --62,861/2021-01 to 2022-01 -- 50,286/2021-01 to 2021-12
--where b.pcn=@pcn and b.period between @period_start and @period_end and (d.ytd_debit_credit != (p.ytd_debit-p.ytd_credit))  --220/2021-01 to 2022-05-pulled-06-14--218/2021-01 to 2022-05-pulled-06-04--219/2021-01 to 2022-05--208/2021-01 to 2022-04 --199/2021-01 to 2022-01 -- 162/2021-01 to 2021-12
--where b.pcn=@pcn and b.period between @period_start and @period_end and (((p.ytd_debit-p.ytd_credit) - d.ytd_debit_credit) > 0.01 or ((p.ytd_debit-p.ytd_credit) - d.ytd_debit_credit) < -0.01)   -- 0/2021-01 to 2022-04 -- 0/2021-01 to 2022-03 

--where b.pcn=@pcn and b.period between @period_start and @period_end and (b.ytd_balance = d.ytd_debit_credit) --71,243/2021-01 to 2022-05-pulled-06-14--71,245/2021-01 to 2022-05-pulled-06-04 --71,244/2021-01 to 2022-04--67,052/2021-01 to 2022-04 67,052/2021-01 to 2022-03-- 62,860/2021-01 to 2022-03 -- 50,286/2021-01 to 2021-12
--where b.pcn=@pcn and b.period between @period_start and @period_end and (b.ytd_balance != d.ytd_debit_credit) --225/2021-01 to 2022-05-pulled-06-14--223/2021-01 to 2022-05-pulled-06-04-- 224/2021-01 to 2022-05-- 212/2021-01 to 2022-04-- 200/2021-01 to 2022-01 -- 162/2021-01 to 2021-12
--where b.pcn=@pcn and b.period between @period_start and @period_end and ((b.ytd_balance - d.ytd_debit_credit) > 0.01 or (b.ytd_balance - d.ytd_debit_credit) < -0.01)  -- 5/2021-01 to 2022-05 -- 4/2021-01 to 2022-04-- 3/2021-01 to 2022-03
-- ISSUE: 1 ACCOUNT IS NOT THE SAME
-- See issue section at the bottom of this procedure and the Mobex Plex procedure: accounting_year_category_type_issue 
-- 73100-000-0000 has different category_types in accounting_v_account it is an Expense and in accounting_v_category_type it is a liability
-- Conclusion: The Plex TB report and Plex authored procedure is wrong to not reset YTD values.


/*
 * 'Revenue' or 'Expense' low accounts have no credit/debit values. 
 */
--where b.pcn=@pcn and b.period between @period_start and @period_end and a.category_type in ('Revenue','Expense') and left(b.account_no,1) < 4  -- 22*15=330/2021-01 to 2022-03, 22*13=286/2021-01 to 2022-01  -- 22*12=264/2021-01 to 2021-12
--and ((b.credit = 0) and (b.debit = 0) and (b.balance =0))  -- 22*15=330/2021-01 to 2022-03, 22*13=286/2021-01 to 2022-01  -- 264/2021-01 to 2021-12
--where b.pcn=@pcn and b.period between @period_start and @period_end and a.category_type in ('Revenue','Expense') and left(b.account_no,1) < 4  -- 22*13=286/2021-01 to 2022-01  -- 22*12/2021-01 to 2021-12
--and ((b.credit != 0) or (b.debit != 0) or (b.balance !=0))  -- 0/2021-01 to 2022-01  --0/2021-01 to 2021-12
-- See issue section at the bottom of this procedure and the Mobex Plex procedure: accounting_year_category_type_issue 
-- 73100-000-0000 has different category_types in accounting_v_account it is an Expense and in accounting_v_category_type it is a liability


-- reset all Plex.account_period_balance for this account
-- UPDATE Plex.account_period_balance !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!11
-- update Plex.account_period_balance set ytd_debit=18912.67,ytd_credit=18912.67 where account_no = '73100-000-0000'

/*
 * Do any new accounts show up on the TB report? Not as of Jan 7 for period 2021-11
 */
select * 
from Archive.accounting_new_accounts_01_07 a 
inner join Plex.trial_balance_multi_level d
on a.pcn=d.pcn 
and a.account_no = d.account_no 

/*
 * Validate the non debit/credit fields
 * Period display as Period
 * category type as 'Category Type'
 * category name as 'Category Name'
 * sub category name as 'Sub Category Name'
 * account no as 'No'
 * account name as 'Name'
 * balance as 'Current Debit/(Credit)'
 * ytd_balance as 'YTD Debit/(Credit)'
 */




declare @pcn int;
set @pcn= 123681;
declare @period_start int;
set @period_start = 202101;
declare @period_end int;
--set @period_end = 202101;
set @period_end = 202203;



select count(*)
--select distinct b.pcn,b.account_no,b.category_type,a.active,a.revenue_or_expense,a.category_type_legacy,a.sub_category_name_legacy 
--into Archive.tb_missing_accounts_after_new_accounts_added_01_2022
from 
(
	select b.pcn,b.period,b.period_display,b.account_no,a.account_name, 
	a.category_type,
	a.category_type_legacy, 
	a.category_name_legacy,
	a.sub_category_name_legacy,
	b.balance,
	b.ytd_balance
	-- select count(*)
	--from Archive.account_period_balance_01_03_2022 b -- 43,630 
	from Plex.account_period_balance b -- 4,595 
	--select * from Plex.accounting_account a
	inner join Plex.accounting_account a
	on b.pcn=a.pcn 
	and b.account_no=a.account_no 
--	where category_type = ''  -- 0
--	where category_type_legacy = ''  -- 1,590
--	where category_name_legacy = ''  -- 1,590
--	where sub_category_name_legacy = ''  -- 1,590
)b 
--order by b.pcn,b.period_display,b.account_no

-- select count(*) from Plex.trial_balance_multi_level d where pcn = 123681 and d.period between 202101 and 202110  -- 42,040
-- select * from Plex.trial_balance_multi_level d where pcn = 123681 and d.period between 202101 and 202110  -- 42,040
left outer join Plex.trial_balance_multi_level d -- TB download does not show the plex period for a multi period month, you must link to period_display
--inner join Plex.trial_balance_multi_level d -- TB download does not show the plex period for a multi period month, you must link to period_display
on b.pcn=d.pcn
and b.account_no = d.account_no
and b.period_display = d.period_display 
-- select * from Plex.accounting_account a where a.account_no = '73100-000-0000'
left outer join Plex.accounting_account a
on b.pcn = a.pcn 
and b.account_no=a.account_no 
--where b.account_no = '73100-000-0000'
-- select * from Plex.missing_accounts_2021_09  -- 158
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.category_type_legacy = ''  --5,865/2021-01 to 2022-03 -- 4,692/2021-01 to 2021-12
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.category_name_legacy = ''  --5,865/2021-01 to 2022-03 -- 4,692/2021-01 to 2021-12
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.category_type = ''  -- 0/2021-01 to 2022-03 -- 0/2021-01 to 2021-12

--where b.pcn=@pcn and b.period between @period_start and @period_end and b.period_display = d.period_display  -- 63,060/2021-01 to 2022-03 -- 50,448/2021-01 to 2021-12
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.period_display != d.period_display  --0/2021-01 to 2022-03 --  0/2021-01 to 2021-12
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.category_type != d.category_type  -- 60/2021-01 to 2022-03 -- 48/2021-01 to 2021-12  -- TB report uses the category type linked to the sub_category
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.category_type_legacy = d.category_type  -- 63,060/2021-01 to 2022-02 -- 50,448/2021-01 to 2021-12
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.category_type_legacy != d.category_type  -- 0/2021-01 to 2022-01 -- 0/2021-01 to 2021-12

--where b.pcn=@pcn and b.period between @period_start and @period_end and b.category_name_legacy = d.category_name  -- 63,060/2021-01 to 2022-03 -- 50,448/2021-01 to 2021-12
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.sub_category_name_legacy != d.sub_category_name  -- 0/2021-01 to 2022-03 -- 0/2021-01 to 2021-12
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.sub_category_name_legacy = d.sub_category_name  -- 63,060/2021-01 to 2022-01 -- 50,448/2021-01 to 2021-12
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.account_name != d.account_name  -- 0/2021-01 to 2022-03 -- 0/2021-01 to 2021-12
where b.pcn=@pcn and b.period between @period_start and @period_end and b.account_name = d.account_name -- 63,060/2021-01 to 2022-03 -- 50,448/2021-01 to 2021-12

/*
 * What category_type is being used on the new chart of accounts multiple level?
 */
select * 
select count(*)
from Plex.accounting_account a 
where a.pcn = 123681 
and a.category_type != a.category_type_legacy -- 396  -- 73100-000-0000,40591-300-00000 (5 digit old account)
-- 73100-000-0000 category_type = Expense (ytd resets yearly), category_type_legacy=Liability
/*
 * How is the TB Itreport treating 73100-000-0000
 * In 2019 there were debits far exceeded credit values
 * In 2020 debit/credit values where equal.
 * TB is treating it as an Expense since it's YTD values match our procedures values.
 * So TB is using the accounting_v_account category_type YTD reset purposes.
 * But it seems to be using the category linked to the accounting_v_category_account view
 * for the category_type in the CSV file download.
 * Chart of Accounts plex screen lists this account as an Expense so it must
 * also be using the accounting_v_account category_type column.
 * The classic Chart of Accounts plex screen no longer works so I can't test 
 * its category type for that account.
 * So I decided to use the accounting_v_account category_type column for both the
 * YTD reset condition and the CSV category name since I thought that would be 
 * less confusing even though 40 account_period_balance records will have different category types 
 * shown on our report compared to the actual Plex TB CSV download.
 */

select * 
from Plex.accounting_balance b
--from Plex.account_period_balance_high b
where b.account_no = '73100-000-0000'
order by b.period 


select * from Plex.accounting_account a 
where a.pcn = 123681 
and left(a.account_no,1) < '4' 
and a.category_type in ('Revenue','Expense')  -- 22

select * from Plex.accounting_account a 
where a.pcn = 123681 
and left(a.account_no,1) > 3 
and a.category_type not in ('Revenue','Expense')  -- 0


/*
 * Format to be like CSV download
 */
--select * from Plex.accounting_account a where a.account_no = '10220-000-00000' 
declare @pcn int;
set @pcn= 123681;
declare @period_start int;
set @period_start = 202205;
declare @period_end int;
--set @period_end = 202101;
set @period_end = 202205;

select 
--b.period,
b.period_display,
a.category_type,
-- b.category_type_legacy category_type,  -- use legacy category type for the report.
/*
 * The Plex TB report uses the category type of the category linked to the account via the  category_account view. 
 * I believe Plex now mostly uses the account category located directly on the accounting_v_account view so I used 
 * this column instead of the one linked via the account_category view. 
 */
-- select category_name from Plex.accounting_account aa -- no category_name 
a.category_name_legacy category_name,
a.sub_category_name_legacy sub_category_name,
a.account_no,
a.account_name,
b.balance current_debit_credit,
b.ytd_balance ytd_debit_credit
--select count(*)
from Plex.account_period_balance b -- 43,620
inner join Plex.accounting_account a -- 43,620
on b.pcn=a.pcn 
and b.account_no=a.account_no 
--order by b.period_display,a.account_no 
--where a.category_type != a.category_type_legacy 
--where b.period_display is not NULL -- 40,940
--where b.period_display is NULL -- 40,940
where b.pcn = @pcn 
AND b.period BETWEEN @period_start AND @period_end 
order by b.period,b.account_no 
a.account_no = '10220-000-00000' 

/*
 * Backup
 */
select * 
-- select count(*) from Archive.account_period_balance_12_30  -- 43,630
--into Archive.account_period_balance_12_30
from Plex.account_period_balance b -- 43,630


/* ISSUE SECTION
 * 
Question: Why is Plex and Mobex Authored procedures differ in YTD. Credit/Debit/Balance values in 2022-01 for 73100-000-0000 only? 
Note: 73100-000-0000 changed to a 'Revenue' or 'Expense' but the Plex Authored procedure is still not resetting this value in 2022-01.  
It was a liability account before it changed. 
Account Details: Plexus_customer_no=123681/Southfield and account_no = '73100-000-0000' 
Name: Freight - In Machining-General-General 
Created: 1/16/2019 12:23:28 PM 
Update: 2/18/2020 11:53:42 AM 
Testing Details: Mobex authored procedure: accounting_year_category_type_issue 
Research: Shows that account 73100-000-0000 has different category_types. 
In accounting_v_account it is an Expense and in accounting_v_category_type it is a liability.  
There are 4 accounts with this same issue but none of the others had any activity.  
Conclusion: Since this account is an Expense account and not a liability account, we should go with the YTD calculation of the Mobex authored procedure 

 
select 
a.plexus_customer_no pcn,a.account_key,a.account_no,a.account_name,a.active,
a.category_type category_type,  --  This is new way of identifying the category type.  The old method used the following views category_account->category->category_type

case 
when c.plexus_customer_no is null then 0
else c.category_no
end category_no_legacy, -- legacy method of categorizing accounts
case
when c.plexus_customer_no is null then ''
else c.category_name
end category_name_legacy, -- legacy method of categorizing accounts
case
when t.category_type is null then ''
else t.category_type 
end category_type_legacy, -- legacy method of categorizing accounts
case
when sc.sub_category_no is null then 0
else sc.sub_category_no
end sub_category_no_legacy, -- legacy method of categorizing accounts
case
when sc.sub_category_name is null then ''
else sc.sub_category_name
end sub_category_name_legacy, -- legacy method of categorizing accounts

case
when t2.category_type is null then ''
else t2.category_type 
end sub_category_type_legacy, -- legacy method of categorizing accounts
-- select distinct [in] from accounting_v_category_type -- Credit/Debit
-- select count(*) from accounting_v_category_type where [in] = 'Credit' -- 3
-- select count(*) from accounting_v_category_type where [in] = 'Debit' -- 2
case
when a.category_type in ('Revenue','Expense') then 1
else 0
end revenue_or_expense

--ca.*,
--ca.category_name,
--b.*,
--sa.*,
--cc.*,
--t.*,
--a.*
-- select count(*)
-- select *
from accounting_v_account_e  a -- 36,636
--where a.plexus_customer_no=123681  -- 4362 
join accounting_v_category_type act -- This is the value used by the new method of configuring plex accounts. 
on a.category_type=act.category_type  -- 36,636

-- Category numbers linked to an account by the a category_account record will no longer be supported by Plex
left outer join accounting_v_category_account_e ca  --
on a.plexus_customer_no=ca.plexus_customer_no
and a.account_no=ca.account_no
--where a.plexus_customer_no=123681  -- 4204 

left outer join accounting_v_category_e c  --
on ca.plexus_customer_no=c.plexus_customer_no
and ca.category_no=c.category_no

left outer join accounting_v_category_type t -- This is the value used by the old method of configuring plex accounts. 
on c.category_type=t.category_type
--where a.plexus_customer_no=123681  -- 4204
--and t.[in] = 'Debit' -- 3998
--and t.[in] = 'Credit' -- 206

-- sub category numbers linked to an account by the sub category_account record will no longer be supported by Plex
left outer JOIN accounting_v_sub_category_account_e AS sca
--JOIN accounting_v_Sub_Category_Account_e AS SCA -- 4,204 for 123681
ON a.plexus_customer_no = sca.plexus_customer_no
and a.account_no = sca.account_no

left outer join accounting_v_sub_category_e sc  --
on sca.plexus_customer_no=sc.plexus_customer_no
and sca.sub_category_no=sc.sub_category_no

left outer join accounting_v_category_e c2  --
on sc.plexus_customer_no=c2.plexus_customer_no
and sc.category_no=c2.category_no

left outer join accounting_v_category_type t2 -- This is another value used by the old method of configuring plex accounts. 
on c2.category_type=t2.category_type


where a.plexus_customer_no = 123681
and a.account_no = '73100-000-0000'

select b.pcn,b.period,b.account_no,
d.category_type DL_category_type,p.category_type PP_category_type,a.category_type MP_category_type,
p.current_credit,b.credit, 
p.ytd_credit PP_ytd_credit,b.ytd_credit,
b.* 
from Plex.account_period_balance b 
join Plex.accounting_account a 
on b.pcn=a.pcn
and b.account_no=a.account_no
join Plex.Account_Balances_by_Periods p -- 43,620
on b.pcn=p.pcn
and b.account_no = p.[no]
and b.period = p.period 
join Plex.trial_balance_multi_level d 
on b.pcn=d.pcn
and b.account_no = d.account_no
and b.period_display = d.period_display 
where b.period in (202112,202201) and b.account_no = '73100-000-0000'
*/


/*
 * Archive
For 2022-01 PP current_credit is 0 but PP_YTD_credit is 18,912.67 
In this procedure the account is shown to be a revenue_or_expense type.
And in our procedure we would reset the YTD_credit to zero at the beginning of the year.
What is PP_YTD_credit and account_period_balance ytd_credit in 2021-12? 18,912.67
select d.*,p.current_credit,b.credit, 
p.ytd_credit PP_ytd_credit,b.ytd_credit,
b.* 
from Plex.account_period_balance b 
join Plex.Account_Balances_by_Periods p -- 43,620
on b.pcn=p.pcn
and b.account_no = p.[no]
and b.period = p.period 
join Plex.trial_balance_multi_level d 
on b.pcn=d.pcn
and b.account_no = d.account_no
and b.period_display = d.period_display 
where b.period = 202112 and b.account_no = '73100-000-0000'

The Plex Authored procedure treated this account as a non revenue_or_expense and did NOT reset the YTD_credit on 2022-01.
Why?
How does our Mobex authored procedure determine if an account is a revenue_or_expense? 
Looks at the account category_type value from the end of the previous year.

--From the Plex.accounting_account_year_category_type account record for the previous year. 

How does the Plex.accounting_account_year_category_type account determine if the account is a revenue_or_expense?
From the our Plex procedure accounting_year_category_type_dw_import?
How? a.category_type in ('Revenue','Expense') then 1

Did the category_type change from previous years? Yes. 73100-000-0000 changed to a 'Revenue' or 'Expense'
Created: 1/16/2019 12:23:28 PM
Update: 2/18/2020 11:53:42 AM - I believe this was when the category_type was changed to an Expense.

Plexus_customer_no=123681 and account_no = '73100-000-0000'
Created: 1/16/2019 12:23:28 PM
Update: 2/18/2020 11:53:42 AM

Are there any diffences between 73100-000-0000 and another expense category_type account that would cause 
Plex authored stored procedure to not treat it as other revenue_or_expense accounts and reset it's 
YTD values at the beginning of each year? Compare to an account which has a current credit 
value in 2022-01: 47100-000-0000	Chip and Scrap Sales
Differences: Price_Component	is True for 47100-000-0000 and false for 73100-000-0000
Conclusion: The price_component differenced does not appear to be significant.  
where plexus_customer_no = 123681
--and Price_Component = 0 and left(account_no,1) > '3'  -- 991
--and Price_Component = 0 and left(account_no,1) < '4'  -- 358

--and Price_Component = 1 and category_type in ('Revenue','Expense') -- 2942
--and Price_Component = 0 and category_type in ('Revenue','Expense') -- 1013
--and Price_Component = 0 and category_type in ('Revenue','Expense') and left(account_no,1) > '3'  -- 991
--and Price_Component = 1 and category_type in ('Revenue','Expense') and left(account_no,1) > '3'  -- 2,942
--and Price_Component = 0 and category_type in ('Revenue','Expense') and left(account_no,1) < '4'  -- 22
--and Price_Component = 1 and category_type in ('Revenue','Expense') and left(account_no,1) < '4'  -- 0

select * from Plex.accounting_account_year_category_type
where pcn=123681 and account_no = '73100-000-0000'/73100-000-0000
*/