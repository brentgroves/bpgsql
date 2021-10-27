/*
	PCN
	310507/Avilla
	300758/Albion
	295933/Franklin
	300757/Alabama
	306766/Edon
	312055/ BPG WorkHolding
	1	123681 / Southfield
2	295932 FruitPort
3	295933
4	300757
5	300758
6	306766
7	310507
8	312055
	*/
/*
 * Do we have the correct number of accounts?
 */
select count(*)
from Plex.GL_Account_Activity_Summary 
where pcn = 123681  -- 264  Ok

/*
 * Are these totals correct?
 * Trial Balance Report
 * 11010-000-0000,                     ,506,504.55                         ,9,488,679.66 --pass
 * DW
 * 11010-000-0000,4834944.39,4328439.84,506504.55,139185766.43,129697086.77,9488679.66 -- same as plex
 */
select 
b.pcn,b.Period_Display,
b.[No],b.Name, 
b.Current_Debit,b.Current_Credit, 
b.Current_Debit-b.Current_Credit current_diff, 
b.Ytd_Debit,b.Ytd_Credit,
b.Ytd_Debit-b.Ytd_Credit ytd_diff
from Plex.Account_Balances_by_Periods_View b
where pcn = 123681
and no = '11010-000-0000'

/*
 * Are these values the same as Plex report?
 * Trial Balance Report
 * 11010-000-0000,                     ,506,504.55                         ,9,488,679.66 --pass 
 * DW
 * 11010-000-0000,4834944.39,4328439.84,506504.55 -- same as plex report
 * 
 * Account Activity Detail report
 * 10120-000-0000,1,850,927.72,1,938,600.30,87,672.58 -- pass
 * 
 * DW
 * 10120-000-0000,1850927.72,1938600.30,-87672.58 -- same as plex report
 * 
 */
select s.pcn,s.period, s.account_no,s.account_name,s.debit,s.credit,s.debit-credit period_diff
from Plex.GL_Account_Activity_Summary s
where pcn = 123681  -- 264  Ok
and s.account_no in ('11010-000-0000','10120-000-0000')
/*
 * How many accounts are there?
 * How many active accounts are there?
 * select * from Plex.accounting_account
 */
select count(*)
from Plex.accounting_account
where  
pcn = 123681 -- 4,362
and active = 1 --3,327

/*
 * How many accounts are missing from the Southfield Trial Balance by Multi Period report 
 */
select count(*)
from Plex.Account_Balances_by_Periods_View
where pcn = 123681  -- 4204

select count(*)
from Plex.accounting_account a
left outer join Plex.Account_Balances_by_Periods_View v 
on a.pcn=v.pcn 
and a.account_no = v.[No] 
where a.pcn = 123681 -- 4,362
and v.pcn is null  -- 158
and a.active = 1  -- 137

/*
 * Which accounts are missing from the Trial Balance report
 */
--drop table Plex.missing_accounts_2021_09
--select count(*)
--select a.pcn,a.account_no,a.account_name,a.active
into Plex.missing_accounts_2021_09
from Plex.accounting_account a  -- 18,010
left outer join Plex.Account_Balances_by_Periods_View b  
on a.pcn=b.pcn 
and  a.account_no=b.no -- 18,010
where a.pcn = 123681  -- 4,362
and b.pcn is null  -- 158
select * from Plex.missing_accounts_2021_09


/*
 * Out of these missing accounts which accounts had activity 2021_09
 */


--select count(*)
--select m.pcn,m.account_no,m.account_name
from Plex.missing_accounts_2021_09 m 
left outer join Plex.GL_Account_Activity_Summary s 
on m.pcn=s.pcn 
and  m.account_no=s.account_no 
where m.pcn = 123681  
and s.pcn is not null  -- 3

/*
 * Are there any accounts with activity that are on
 * the trial balance report but are not on the 
 * active detail summary? NO
 */
select count(*)
from Plex.Account_Balances_by_Periods_View b
--where b.pcn = 123681  -- 4,204
left outer join Plex.GL_Account_Activity_Summary s  
on b.pcn=s.pcn 
and  b.no=s.account_no 
where b.pcn = 123681  -- 4,204
and s.pcn is null  -- 3,943
and (b.Current_Debit = 0 or b.Current_Credit = 0) -- 3,943
--and (b.Current_Debit > 0 or b.Current_Credit > 0) -- 0


/*
 * Debit/Credit totals for all Southfied accounts for 2021-09  
 */
-- drop table Plex.SouthfieldDebitCreditTotals202109
select 
r.pcn,
r.period_display,
r.account_no,
r.account_name,
r.debit,
r.credit,
r.debit-r.credit diff
into Plex.SouthfieldDebitCreditTotals202109
from 
(
	select 
	a.pcn,
	'2021-09' period_display,
	a.account_no,
	a.account_name,
	case
	when s.pcn is null then 0 
	else s.debit 
	end debit,
	case
	when s.pcn is null then 0 
	else s.credit 
	end credit
	--s.period, s.account_no,s.account_name,s.debit,s.credit,s.debit-credit period_diff
	--select count(*)
	--select s.*
	from Plex.accounting_account a  -- 18,010
	left outer join Plex.GL_Account_Activity_Summary s 
	on a.pcn=s.pcn 
	and  a.account_no=s.account_no -- 18,010
	where a.pcn = 123681  -- 4,362
)r 


/*
 * Should we use Plex.SouthfieldDebitCreditTotals202109 
 * or Plex.account_balances_by_periods
 * or should we use a combination?
 */
-- Does revenue,expense,or amount have any value but 0/null? No
select count(*) 
from Plex.account_balances_by_periods b
--where b.pcn = 123681 -- 8408
--and b.amount is null  -- 8408
--where b.pcn = 300758 -- 6826
-- and b.amount = 0 -- 6826
where b.amount != 0 -- 0

--where b.pcn = 123681 -- 8408
--and b.expense is null  -- 8408
--where b.pcn = 300758 -- 6826
-- and b.expense = 0 -- 6826
--where b.expense != 0 -- 0

--where b.pcn = 123681 -- 8408
--and b.revenue is null  -- 8408
--where b.pcn = 300758 -- 6826
-- and b.revenue = 0 -- 6826
--where b.revenue != 0 -- 0

/*
 * Should we attempt add category number?
 * Albion only has 0 but all Southfield accounts have a non-zero account_no
 */
/*
There is not a 1 to 1 mapping of category_account to account for Southfield
so unless we know how the Revenue Analysis by period data source
decides which category number to choose we will set it to 0
this should not affect the accounting spreadsheet since 
the Albion PCN only shows 0 in the category number field of the CSV file. 
  
select count(*) cnt
from accounting_v_account_e a
--where a.plexus_customer_no = 123681  -- 4362
--and a.active = 1 -- 3327
inner join accounting_v_category_account_e c
on a.plexus_customer_no=c.plexus_customer_no
and a.account_no=c.account_no
where a.plexus_customer_no = 123681  -- 4204
*/

/*
 * What should we put in the category_name column?
 * Albion has no data in this column.
 * Southfield has 15 names but we don't know which
 * how the revenue analysis by period report 
 * chooses which category so leave this column blank
 */
select distinct b.Category_Name 
--select count(*)
from Plex.Account_Balances_by_Periods b 
where b.pcn = 123681  -- 15
where b.pcn = 300758 -- 0

/*
 * Validate set by checking totals for a few accounts. 
 */
select '' Revenue,'' Expense,'' Amount, t.Period 
--select count(*)
from Plex.SouthfieldDebitCreditTotals202109 t -- 4,362
--where t.account_no = '12400-000-0000' --	Raw Materials - Purchased Components
--where  t.account_no = '11010-000-0000' --	AR - Trade, Products
--where t.account_no = '10120-000-0000' --	Cash Operating Wells Fargo-General-General

select * from Plex.SouthfieldDebitCreditTotals202109 t -- 4,362

/*
 * Generate
 */

/*
Duplicate Trial Balancess by Period
Reason: This is what accounting needs for Southfied since the Plex Trial Balances by Period report is missing accounts.
Method:
GL_Account_Activity_Summary_V2_DW_Import:
This procedure is called by an ETL script nightly to populate the Plex.GL_Account_Activity_Summary table
with updated values from the current period.
Only a PCN list is needed as an parameter.
Only new account values for the current are calculated.
All other periods are left untouched.
The table contains a pcn and year column.
All reporting will be done by calling a sproc in the DW.
To Do: 
Create a sproc to update Plex.GL_Account_Activity_Summary_YTD table
CREATE TABLE GL_Account_Activity_Summary_YTD
(
  pcn INT NOT NULL,
  year int not null,
  account_no VARCHAR(20) NOT NULL,
  ytd_debit decimal(19,5),
  ytd_credit decimal(19,5),
  PRIMARY KEY CLUSTERED
  (
    PCN,year,account_no
  )
);
 
*/
select 
r.pcn,
r.revenue,
r.expense,
r.amount,
r.period,
r.period_display,
r.category_type,
r.category_no,
r.category_name,
r.[no],
r.name,
r.ytd_debit,
r.ytd_credit,
r.ytd_debit-r.ytd_credit diff,  -- for debug only
r.current_debit,
r.current_credit,
r.current_debit-r.current_credit diff  -- for debug only
from 
(
	select 
	a.pcn,
	'' revenue,  -- the account_balances_by_periods plex authored procedure shows only blank values in the query and csv file for Albion and Southfield.
	'' expense, -- the account_balances_by_periods plex authored procedure shows only blank values in the query and csv file for Albion and Southfield.
	'' amount, -- the account_balances_by_periods plex authored procedure shows only blank values in the query and csv file for Albion and Southfield.
	s.period, 
	--cast(s.year as varchar) + '-' + cast(s.period as varchar),
	'2021-09' period_display,  
	a.category_type,
	0 category_no,  -- Albion has all zeros.
	'' category_name, -- Albion has all blanks.
	a.account_no [no],
	a.account_name name,
	0 ytd_debit,--GL_Account_Activity_Summary_YTD
	0 ytd_credit,--GL_Account_Activity_Summary_YTD
	case
	when s.pcn is null then 0 
	else s.debit 
	end current_debit,
	case
	when s.pcn is null then 0 
	else s.credit 
	end current_credit,
	0 sub_category_no,  -- Albion has all zeros. select * from Plex.Account_Balances_by_Periods b where b.pcn = 300758
	'' sub_category_name, -- Albion does has all blanks.
	0 subtotal_after, -- Albion has all zeros. select distinct(subtotal_after) from Plex.Account_Balances_by_Periods b where b.pcn = 300758
	'' subtotal_name -- Albion has all zeros.
	-- select
	--s.period, s.account_no,s.account_name,s.debit,s.credit,s.debit-credit period_diff
	--select count(*)
	--select s.*
	from Plex.accounting_account a  -- 18,010
	left outer join Plex.GL_Account_Activity_Summary s 
	on a.pcn=s.pcn 
	and  a.account_no=s.account_no -- 18,010
	where a.pcn = 123681  -- 4,362
)r 

-- select * from Plex.accounting_account a
