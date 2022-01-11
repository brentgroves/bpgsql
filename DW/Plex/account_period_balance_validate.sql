/*
 * Backup
 */
--select * 
--into Archive.account_period_balance_12_30
--from Plex.account_period_balance b -- 43,630
/*
 * Does the values in this view match with the CSV download and the TB PP?
 */
declare @pcn int;
set @pcn= 123681;
declare @period_start int;
set @period_start = 202101;
declare @period_end int;
set @period_end = 202111;
/*
select b.pcn,b.account_no,
b.period,
a.revenue_or_expense,
b.debit,b.credit,b.balance,d.current_debit_credit TB_balance,b.ytd_debit,p.ytd_debit PP_ytd_debit,
b.ytd_credit,p.ytd_credit PP_ytd_credit,
b.ytd_balance,
d.ytd_debit_credit TB_ytd_balance,
p.ytd_debit-p.ytd_credit PP_ytd_balance
*/
--b.balance -d.current_debit_credit  diff
-- select *
select count(*) 
from Plex.account_period_balance b -- 43,630/170,863
inner join Plex.accounting_account a 
on b.pcn=a.pcn 
and b.account_no=a.account_no -- 43,630 /170,863
--from Plex.account_period_balance_view b -- 43,620  -- This view made the query non-responsive
--inner join Plex.trial_balance_multi_level d -- 42,040, 43,620 - 42,040 = 1,580 account periods do not show up on TB CSV download. TB download does not show the plex period for a multi period month, you must link to period_display
--select distinct pcn,period from Plex.trial_balance_multi_level d order by pcn,period 
--select * from Plex.trial_balance_multi_level d where pcn=123681 and period=202112 -- all 0 since imported in november

left outer join Plex.trial_balance_multi_level d -- TB download does not show the plex period for a multi period month, you must link to period_display
on b.pcn=d.pcn
and b.account_no = d.account_no
and b.period_display = d.period_display 
-- select * from Plex.Account_Balances_by_Periods p 
--select distinct pcn,period from Plex.Account_Balances_by_Periods p order by pcn,period -- 123,681 (200812-202110)
--select * from Plex.Account_Balances_by_Periods p where pcn=123681
-- select  
left outer join Plex.Account_Balances_by_Periods p -- 43,620
on b.pcn=p.pcn
and b.account_no = p.[no]
and b.period = p.period 
--inner join 
left outer join 
(
	select s.pcn,s.period, s.account_no,s.debit,s.credit,s.debit-s.credit balance
	--select count(*)
--select distinct pcn,period from Plex.GL_Account_Activity_Summary s order by pcn,period -- 123,681 (200812-202111)
--select * from Plex.GL_Account_Activity_Summary s where pcn=123681 and period = 202111  -- dont know when this was imported probably in early december
	from Plex.GL_Account_Activity_Summary s  --(),(221,202010)
	where s.pcn = 123681 
	and s.period between 202101 and 202111  -- 2,462/2,718
) s
on b.pcn=s.pcn 
and b.account_no=s.account_no
and b.period=s.period  

--where b.pcn=@pcn and b.period between @period_start and @period_end  -- 50,545
--where b.pcn=@pcn and b.period between @period_start and @period_end and p.pcn is not null -- 46,244
--where b.pcn=@pcn and b.period between @period_start and @period_end and d.pcn is not null -- 46,244
--where b.pcn=@pcn and b.period between @period_start and @period_end and p.pcn is null and s.pcn is not null  -- 33/36  account periods with activity not on the TB report.
--where b.pcn=@pcn and b.period between @period_start and @period_end and s.pcn is not null  -- 2,462/2,718


--where b.pcn=@pcn and b.period between @period_start and @period_end and b.debit=s.debit -- 2,462/2,718
--where b.pcn=@pcn and b.period between @period_start and @period_end and (s.debit != b.debit) -- 0
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.credit = s.credit -- 2,462/2,718
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.balance =s.balance  -- 2,462/2,718
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.balance !=s.balance -- 0



--where b.pcn=@pcn and b.period between @period_start and @period_end and b.balance = d.current_debit_credit  -- 46,220
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.balance != d.current_debit_credit  -- 23/24
--where b.pcn=@pcn and b.period between @period_start and @period_end and (b.balance - d.current_debit_credit) >  0.01 -- 0

--where b.pcn=@pcn and b.period between @period_start and @period_end and b.credit = p.current_credit  -- 46,244
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.credit != p.current_credit  -- 0 

--where b.pcn=@pcn and b.period between @period_start and @period_end and b.debit = p.current_debit  -- 46,244
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.debit != p.current_debit  -- 0 

--where b.pcn=@pcn and b.period between @period_start and @period_end and (b.balance = p.Current_Debit - p.Current_Credit)   -- 46,244
--where b.pcn=@pcn and b.period between @period_start and @period_end and (b.balance != p.Current_Debit - p.Current_Credit)   -- 0

--where b.pcn=@pcn and b.period between @period_start and @period_end and b.ytd_credit = p.ytd_credit  -- 46,244
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.ytd_credit != p.ytd_credit  -- 0
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.ytd_debit = p.ytd_debit  -- 46,244
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.ytd_debit != p.ytd_debit  -- 0

--where b.pcn=@pcn and b.period between @period_start and @period_end and (d.ytd_debit_credit = (p.ytd_debit-p.ytd_credit))  -- 46,093
--where b.pcn=@pcn and b.period between @period_start and @period_end and (d.ytd_debit_credit != (p.ytd_debit-p.ytd_credit))  -- 137/151
--where b.pcn=@pcn and b.period between @period_start and @period_end and ((p.ytd_debit-p.ytd_credit) - d.ytd_debit_credit) > 0.01  -- 0

--where b.pcn=@pcn and b.period between @period_start and @period_end and (b.ytd_balance = d.ytd_debit_credit) -- 46,093
--where b.pcn=@pcn and b.period between @period_start and @period_end and (b.ytd_balance != d.ytd_debit_credit) -- 151
--where b.pcn=@pcn and b.period between @period_start and @period_end and (b.ytd_balance - d.ytd_debit_credit) > 0.01  -- 0

/*
 * 'Revenue' or 'Expense' low accounts have no credit/debit values. 
 */
--where b.pcn=@pcn and b.period between @period_start and @period_end and a.category_type in ('Revenue','Expense') and left(b.account_no,1) < 4  -- 22*10/242
--and ((b.credit = 0) and (b.debit = 0) and (b.balance =0))  -- 220/242
--where b.pcn=@pcn and b.period between @period_start and @period_end and a.category_type in ('Revenue','Expense') and left(b.account_no,1) < 4  -- 22*10/242
--and ((b.credit != 0) or (b.debit != 0) or (b.balance !=0))  -- 0
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.ytd_debit != p.ytd_debit  -- 0
-- 10 73100-000-0000 changed to a 'Revenue' or 'Expense' after the beginning of the year so PP_ytd_debit and PP_ytd_credit did not get reset on 2021-01. 
-- but our code only saw the current category so it reset the YTD values.
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
set @period_end = 202111;

select 
--b.pcn,b.period,
b.period_display,
b.category_type_legacy category_type,  -- use legacy category type for the report.
b.category_name_legacy category_name,
b.sub_category_name_legacy sub_category_name,
b.account_no,
b.account_name,
b.balance current_debit_credit,
b.ytd_balance ytd_debit_credit
--d.category_type TB_category_type,
--b.debit,b.ytd_debit,b.credit,b.ytd_credit,b.balance,b.ytd_balance


declare @pcn int;
set @pcn= 123681;
declare @period_start int;
set @period_start = 202101;
declare @period_end int;
--set @period_end = 202101;
set @period_end = 202111;



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
--	from Archive.account_period_balance_01_03_2022 b -- 43,630 
	from Plex.account_period_balance b -- 43,630 
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

left outer join Plex.accounting_account a
on b.pcn = a.pcn 
and b.account_no=a.account_no 
-- select * from Plex.missing_accounts_2021_09  -- 158
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.category_type_legacy = ''  -- 4,301 -- all periods
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.category_name_legacy = ''  -- 4,301 -- all periods
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.category_name_legacy = ''  -- 1,590/3,910, 1 period, There are now 159+232=391 TB missing accounts
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.category_type = ''  -- 0

--where b.pcn=@pcn and b.period between @period_start and @period_end and d.pcn is null  -- 1,590/4,301

--where b.pcn=@pcn and b.period between @period_start and @period_end and b.period_display = d.period_display  -- 42,244/46,244
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.period_display != d.period_display  -- 0
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.category_type != d.category_type  -- 40/44  -- TB report uses the category type linked to the sub_category
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.category_type_legacy = d.category_type  -- 42,040/46,244
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.category_type_legacy != d.category_type  -- 0

--where b.pcn=@pcn and b.period between @period_start and @period_end and b.category_name_legacy = d.category_name  -- 42,040/46,244
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.sub_category_name_legacy != d.sub_category_name  -- 0
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.sub_category_name_legacy = d.sub_category_name  -- 42,040/46,244
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.account_name != d.account_name  -- 0
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.account_name = d.account_name -- 42,040/46,244
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.balance = d.current_debit_credit -- 42,017/46,220
--where b.pcn=@pcn and b.period between @period_start and @period_end and (b.balance - d.current_debit_credit) > 0.01 -- 0
--where b.pcn=@pcn and b.period between @period_start and @period_end and b.ytd_balance = d.ytd_debit_credit -- 41,903/46,093
--where b.pcn=@pcn and b.period between @period_start and @period_end and (b.ytd_balance - d.ytd_debit_credit) > 0.01 -- 0

/*
 * What category_type is being used on the new chart of accounts multiple level?
 */
select * from Plex.accounting_account a 
where a.pcn = 123681 
and a.category_type != a.category_type_legacy -- 163  -- 73100-000-0000,40591-300-00000 (5 digit old account)
-- 73100-000-0000 category_type = Expense (ytd resets yearly), category_type_legacy=Liability
/*
 * How is the TB report treating 73100-000-0000
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
select 
b.period,
b.period_display,
a.category_type,
-- b.category_type_legacy category_type,  -- use legacy category type for the report.
/*
 * The Plex TB report uses the category type of the category linked to the account via the  category_account view. 
 * I believe Plex now mostly uses the account category located directly on the accounting_v_account view so I used 
 * this column instead of the one linked via the account_category view. 
 */
a.category_name_legacy category_name,
--a.sub_category_name_legacy sub_category_name,
a.account_no [no],
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
where a.account_no = '10220-000-00000' 

/*
 * Backup
 */
select * 
-- select count(*) from Archive.account_period_balance_12_30  -- 43,630
--into Archive.account_period_balance_12_30
from Plex.account_period_balance b -- 43,630
