Period,Category Type,Category Name,Sub Category Name,No,Name,Current Debit/(Credit),YTD Debit/(Credit)
"10-2021","Asset","Current Assets","Receivables","10220-000-00000","Accounts Receivable","0","6353429.89999998",
-- drop table Plex.trial_balance_multi_level
create table Plex.trial_balance_multi_level
(
 pcn int null,
 period int null,
 period_display varchar(7),
 category_type VARCHAR(10),
 category_name VARCHAR(50),
 sub_category_name VARCHAR(50) ,
 account_no VARCHAR(20),
 account_name VARCHAR(110),
 current_debit_credit DECIMAL(18,2),
 ytd_debit_credit DECIMAL(18,2)
 primary key (period_display,account_no)  -- when this gets imported there is a period_display but no period.
)
select distinct pcn,period 
from Plex.trial_balance_multi_level order by pcn,period  
select count(*) from Plex.trial_balance_multi_level  -- 668,436/664,232
where period = 202111

select * 
-- select count(*)
--select count(*) from Archive.trial_balance_multi_level_01_02_2022  -- 668,436 (200812-202112) -- I deleted 202112 because this period did not close as of 01-07-2022.
--into Archive.trial_balance_multi_level_01_02_2022
from Plex.trial_balance_multi_level  -- 58,856

where period_display like '%Total%'  -- 4204  

-- 
/*
 * The last account_no record contains a total record with a YTD debit_credit value 
 * which is the same as that found in the last periods ytd_debit_credit column
 */

select s1.*,s2.current_debit_credit 
-- select count(*)
from Plex.trial_balance_multi_level s1  -- 58,856
join Plex.trial_balance_multi_level s2
on s1.account_no=s2.account_no
and s1.ytd_debit_credit=s2.current_debit_credit
and s2.period_display='Total'
and s1.period_display='12-2009'  -- 4,204
order by s1.account_no

/*
 * Must delete ending comma from each line before running TrialBalance ETL script.  regular expression is ',$'
 */
/*
 * Must cleanup Total lines when importing CSV
 */
--delete from Plex.trial_balance_multi_level
where period_display='Total'  --4,204

update Plex.trial_balance_multi_level -- 4204
set period = cast (right(period_display,4) + left(period_display,2) as int),
pcn = 123681
where pcn is null
,

select *
--SELECT DISTINCT pcn,period
--SELECT DISTINCT pcn,period_display 
--select count(*)
from Plex.trial_balance_multi_level
--order by pcn,period_display  
where pcn=123681 and period=202203  -- 4204.
--where pcn=123681 and period=202202  -- 4204.
--where pcn=123681 and period=202201  -- 4204.
--where pcn=123681 and period=202112  -- 4204.
--where pcn=123681 and period=202111  -- 4204
--where pcn=123681 and period=201801  -- 4204
--where pcn=123681 and period=201712  -- 4204
--where pcn=123681 and period=201401  -- 4204
--where pcn=123681 and period=201312  -- 4204
--where pcn=123681 and period=201001  -- 4204
--where pcn=123681 and period=200912  -- 4204
--where pcn=123681 and period=200911  -- 4204
--where pcn=123681 and period=200910  -- 4204
--where pcn=123681 and period=200908  -- 4204
--where pcn=123681 and period=200907  -- 4204
--where pcn=123681 and period=200906  -- 4204
--where pcn=123681 and period=200905  -- 4204
--where pcn=123681 and period=200905  -- 4204
--where pcn=123681 and period=200903  -- 4204
--where pcn=123681 and period=200902  -- 4204
--where pcn=123681 and period=200901  -- 4204
--where pcn=123681 and period=200812  -- 4204

Compare Trial Balance download with Accounting_p_Account_Balances_by_Periods_Get. 
/*
 * How does trial balance multi level calculate the current_debit_credit and ytd_debit_credit values?
 * How can you get the same current_debit_credit and ytd_debit_credit values using the 
 * Accounting_p_Account_Balances_by_Periods_Get procedure?
 */
select s.period,s.account_no,
s.current_debit,s.current_credit,
--s.current_debit-s.current_credit current_debit_minus_credit,
s.Account_Balances_by_Periods_Get_debit_credit, -- Account_Balances_by_Periods_Get
s.trial_balance_debit_credit -- trial_balance_multi_level
--s.calc_debit_credit,s.calc_debit_credit_legacy,
--s.debit_balance,s.debit_balance_legacy
--,p.Current_Debit,p.Current_Credit
--select count(*)
from 
(
	select d.pcn,d.period,d.account_no,
	--a.debit_balance,a.debit_balance_legacy,
	d.current_debit_credit trial_balance_debit_credit,-- trial_balance_multi_level
	p.Current_Debit,p.Current_Credit,
	p.current_debit-p.current_credit Account_Balances_by_Periods_Get_debit_credit 	-- Account_Balances_by_Periods_Get
	/*  THIS IS WRONG YOU ALWAY TAKE p.current_debit-p.current_credit
	case 
	when a.debit_balance = 1 then p.current_debit-p.current_credit
	when a.debit_balance = 0 then p.current_credit - p.current_debit 
	else 999.99
	end calc_debit_credit, 
	case 
	when a.debit_balance_legacy = 1 then p.current_debit-p.current_credit
	when a.debit_balance_legacy = 0 then p.current_credit - p.current_debit 
	else 999.99
	end calc_debit_credit_legacy 
	*/
	-- select distinct pcn,period from Plex.Account_Balances_by_Periods order by pcn,period
	--select distinct pcn,period
	--select count(*)
	from Plex.trial_balance_multi_level d -- 54,652
	--order by pcn,period {200812,200912}
	join Plex.Account_Balances_by_Periods p -- static_calc
	on d.pcn=p.pcn 
	and d.account_no = p.[no]
	and d.period = p.period 
	join Plex.accounting_account a 
	on d.pcn = a.pcn 
	and d.account_no = a.account_no -- 54,652
	--where a.pcn is null  -- 0
	--where d.pcn= 123681 and p.period = 200812  -- 4,204
)s
where s.pcn= 123681 
and s.period between 200812 and 200912 
--and s.trial_balance_debit_credit = s.Account_Balances_by_Periods_Get_debit_credit   -- 54,646
and s.trial_balance_debit_credit != s.Account_Balances_by_Periods_Get_debit_credit   -- 6 All 1 cent OFF 
--and s.period = 200812  -- 4,204

where s.calc_debit_credit = s.current_debit_credit and s.debit_balance = 0 and s.calc_debit_credit != 0 -- 0  
where s.calc_debit_credit = s.current_debit_credit and s.debit_balance = 0 -- 184  
where s.calc_debit_credit = s.current_debit_credit and s.debit_balance = 1 -- 3997  

where s.calc_debit_credit_legacy != s.current_debit_credit  -- 23
where s.calc_debit_credit != s.current_debit_credit  -- 23
where s.calc_debit_credit = s.current_debit_credit  -- 4,181

/*
 * Count of Accounts are the same for periods 200812 through 200912 
 */
select *
--select count(*)
from Plex.trial_balance_multi_level d 
where d.pcn = 123681 
and account_no = '10220-000-00000' and period between 201603 and 201604
and d.period between 200812 and 200912  -- 54,652

select * from Plex.accounting_account where account_no = '10220-000-00000'
select *
--select count(*)
from Plex.Account_Balances_by_Periods p 
where p.pcn = 123681 and p.period = 200812  -- 4204
where p.pcn = 123681 and p.period between 200812 and 200912  -- 54,652

select * 
--select count(*)
--into 
from Plex.calc_ytd_low_view -- 37,970
OPTION (MAXRECURSION 210); 

select count(*)
from Plex.trial_balance_multi_level d 

select count(*)
from Plex.trial_balance_multi_level d 
left outer join Plex.Account_Balances_by_Periods p 
on d.pcn = p.pcn 
and d.account_no = p.[no]
and d.period=p.period
where d.period between 200812 and 200912  -- 54,652
and p.pcn is null -- 0

--where p.period = 200912  -- 4204
--where p.period = 200911  -- 4204
--where p.period = 200910  -- 4204
--where p.period = 200909  -- 4204
--where p.period = 200908  -- 4204
--where p.period = 200907  -- 4204
--where p.period = 200906  -- 4204
--where p.period = 200905  -- 4204
--where p.period = 200904  -- 4204
--where p.period = 200903  -- 4204
--where p.period = 200902  -- 4204
--where p.period = 200901  -- 4204
--where p.period = 200812  -- 4204
where p.pcn is null  -- 0

select count(*)
from Plex.Account_Balances_by_Periods p 
left outer join Plex.trial_balance_multi_level d 
on d.pcn = p.pcn 
and d.account_no = p.[no]
and d.period=p.period  
where p.period between 200812 and 200912  -- 54,652
and d.pcn is NULL -- 0

select count(*)
from Plex.trial_balance_multi_level d 
where d.period between 200812 and 200912  -- 54652

select *
--select count(*)
from Plex.Account_Balances_by_Periods p 
where p.period between 200812 and 200912  -- 54652


