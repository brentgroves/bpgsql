select * 
--into Scratch.accounting_period_balance_all_12_16  -- 40,940
--from Plex.accounting_period_balance_all
-- drop table Plex.accounting_period_balance_all
into Plex.accounting_period_balance_all
from 
(
select l.pcn,l.period,l.account_no,l.debit,l.ytd_debit,l.credit,l.ytd_credit,l.balance,l.ytd_balance 
-- select count(*)
from Plex.accounting_period_balance_low l  -- 34,508
where l.period between 202101 and 202110 -- 3,710
union
select * 
-- select count(*)
from Plex.accounting_period_balance_high  -- 37,230 + 3,710 = 40,940
)s  -- 40,940
-- select distinct pcn,period from Plex.accounting_period_balance_low b order by pcn,period --goes from 200701 to 202111
-- select distinct pcn,period from Plex.accounting_period_balance_high b order by pcn,period --goes from 202101 to 202110
-- select distinct pcn,period from Plex.accounting_period_balance_all b order by pcn,period --goes from 202101 to 202110


select p.period_display 
--select count(*)
from Plex.accounting_period_balance_all b -- 40,940
inner join Plex.accounting_period p  -- 40,940
on b.pcn=p.pcn
and b.period=p.period 
where p.period_display is NULL -- 0




/*
 * Are we missing any account periods with activity?
 */
select p.*
-- select distinct pcn, period -- 200812 to 202110
-- select count(*)
from Plex.Account_Balances_by_Periods p -- 663,441
--order by pcn,period
left outer join 
(
	select b.pcn,b.period,p.period_display,b.account_no,b.debit,b.ytd_debit,b.credit,b.ytd_credit,b.balance,b.ytd_balance 
	--select distinct pcn,period  -- 202101 to 202110
	--select count(*)
	from Plex.accounting_period_balance_all b -- 40,940
	--order by pcn,period
	inner join Plex.accounting_period p
	on b.pcn=p.pcn
	and b.period=p.period 
)b 
on p.pcn=b.pcn
and p.[no] = b.account_no
and p.period = b.period -- 
where p.pcn = 123681
and p.period between 202101 and 202110
and b.pcn is null -- 2,022
and ((p.Current_Debit !=0) or (p.Current_Credit != 0))  -- 0
order by b.pcn,b.account_no,b.period

/*
 * Our queries have account periods with activity that Plex pp does not
 * That is the purpose of this project.
 */
select *
--select count(*)
from Plex.accounting_period_balance_all b -- 40,940
left outer join Plex.Account_Balances_by_Periods p
on b.pcn = p.pcn 
and b.account_no=p.[no]
and b.period=p.period
where p.pcn is null  -- 922
--and b.period = 202101  -- 88
--and b.period = 202102  -- 88
--and b.period = 202110  -- 96
and ((b.debit !=0) or (b.credit!=0))  -- 33
--and b.period = 202101  -- 3
--and b.period = 202102  -- 2
and b.period = 202110  -- 3
order by b.account_no,b.period

/*
 * Our queries have account periods with activity that TB CSV download does not.
 * That is the purpose of this project.
 * Looks like the TB PP and the TB CSV download have the same missing accounts.
 */
select *
-- select distinct pcn,period
--select count(*)
from Plex.accounting_period_balance_all b -- 40,940

left outer join Plex.trial_balance_multi_level m
on b.pcn = m.pcn 
and b.account_no=m.account_no 
and b.period=m.period
where m.pcn is null  -- 922
--and b.period = 202101  -- 88
--and b.period = 202102  -- 88
--and b.period = 202110  -- 96
and ((b.debit !=0) or (b.credit!=0))  -- 33
--and b.period = 202101  -- 3
--and b.period = 202102  -- 2
and b.period = 202110  -- 3
order by b.account_no,b.period

/*
 * What accounts in the accounting_v_balance snapshots do not show up on the Trial Balance report?
 * See Plex.accounting_Accounts_Grid_by_Sub_Category_Get or the code in the Accounts_Grid_by_Sub_Category_Get customer data source.
 * Which is the resource for the classic chart of accounts screen, for details of how these accounts don't have sub categories and
 * the inner join filters them.
 * There are 159 accounts that get filtered but only 96 show up here because not all accounts are in the Plex.accounting_period_balance_all b table
 */
select a.*
-- select count(*)
from 
(
	select distinct b.pcn,b.account_no  -- 96
	--select count(*)
	from Plex.accounting_period_balance_all b -- 40,940
	left outer join Plex.trial_balance_multi_level m
	on b.pcn = m.pcn 
	and b.account_no=m.account_no 
	and b.period=m.period
	where m.pcn is null  -- 922
	and b.period between 202101 and 202110
	--and ((b.debit !=0) or (b.credit!=0))  -- 33

)s
inner join Plex.accounting_account a 
on s.pcn=a.pcn 
and s.account_no=a.account_no 
order by s.pcn,s.account_no  -- 96

/*
 * Verify balances of accounts not shown on the TB report.
 * For the 33 account periods that have a debit/credit != 0 there is an Plex.GL_Account_Activity_Summary.
 * And the debit/credit values are equal. 
 * The other 889 account periods have a 0 debit/credit value.
 */
select b.*
--select count(*)
from
(
	select b.*
	-- select distinct b.pcn,b.account_no
	--select count(*)
	from Plex.accounting_period_balance_all b -- 40,940
	left outer join Plex.trial_balance_multi_level m
	on b.pcn = m.pcn 
	and b.account_no=m.account_no 
	and b.period=m.period
	where m.pcn is null  -- 922
	and b.period between 202101 and 202110  -- 922
) b 
left outer join 
(
	select s.pcn,s.period, s.account_no,s.debit,s.credit,s.debit-s.credit balance
	--select count(*)
	from Plex.GL_Account_Activity_Summary s  --(),(221,202010)
	where s.pcn = 123681 
	and s.period between 202101 and 202110  -- 2,462
) s
on b.pcn=s.pcn 
and b.account_no=s.account_no
and b.period=s.period  -- 922
--where s.pcn is NULL -- 889
--and ((b.debit!=0) or (b.credit!=0))  -- 0
where s.pcn is not NULL -- 889
and ((b.debit!=s.debit) or (b.credit!=s.credit) or (b.balance!=s.balance))--0

/*
 * Are there any account periods with activity that are not shown on our query?
 */
select count(*)
from 
(
	select s.pcn,s.period, s.account_no,s.debit,s.credit,s.debit-s.credit balance
	--select count(*)
	from Plex.GL_Account_Activity_Summary s  --(),(221,202010)
	where s.pcn = 123681 
	and s.period between 202101 and 202110  -- 2,462
) s
left outer join 
(
	select b.*
	-- select distinct b.pcn,b.account_no
	--select count(*)
	from Plex.accounting_period_balance_all b -- 40,940
	where b.pcn = 123681 
	and b.period between 202101 and 202110  -- 40,940
) b 
on s.pcn=b.pcn 
and s.account_no=b.account_no 
and s.period=b.period  -- 2,462
where b.pcn is null  -- 0

/*
 * Add account periods without activity
 */
-- select * from Plex.account_period_balance_view
--drop view Plex.account_period_balance_view
create view Plex.account_period_balance_view(pcn,account_no,period,period_display,debit,ytd_debit,credit,ytd_credit,balance,ytd_balance)
as

with account_period(pcn,account_no,period,period_display)
AS
(
    -- Anchor member
    select 
    a.pcn,
    a.account_no,
    202101 period,
    '01-2021' period_display
	--select count(*) cnt
    --select *
	from Plex.accounting_account a  -- high: 3,701 * 10 = 37,010 /// all: 4,362 X 10 = 43,620
	where a.pcn = 123681 -- 4,362
--	and account_no = '10000-000-00000'
    UNION ALL
    -- Starting at 202101 make a period account record for each period upto 202110.
    select
    p.pcn,
    p.account_no,
    p.period+1,  -- this is ok if we do not want to include periods for multiple years.
    right(cast(p.period+1 as varchar(7)),2) + '-' + left(cast(p.period+1 as varchar(7)),4) as period_display
    from account_period p
    where p.period < 202110
)
select 
a.pcn,
a.account_no,
a.period,
a.period_display,
case 
when b.pcn is null then 0
else b.debit
end debit,
case 
when b.pcn is null then 0
else b.ytd_debit
end ytd_debit,
case 
when b.pcn is null then 0
else b.credit
end credit,
case 
when b.pcn is null then 0
else b.ytd_credit
end ytd_credit,
case 
when b.pcn is null then 0
else b.balance
end balance,
case 
when b.pcn is null then 0
else b.ytd_balance
end ytd_balance
--select count(*)
from account_period a
left outer join 
(
	select b.pcn,b.period,p.period_display,b.account_no,b.debit,b.ytd_debit,b.credit,b.ytd_credit,b.balance,b.ytd_balance 
	-- select distinct b.pcn,b.account_no
	--select count(*)
	from Plex.accounting_period_balance_all b -- 40,940
	--select distinct pcn,period  -- 202101 to 202110
	--select count(*)
	inner join Plex.accounting_period p
	on b.pcn=p.pcn
	and b.period=p.period 
	
	where b.pcn = 123681 
	and b.period between 202101 and 202110  -- 40,940
) b 
on a.pcn=b.pcn 
and a.account_no=b.account_no 
and a.period=b.period 
--where b.pcn is null  -- 2,680

select *
--select count(*) 
-- drop table Plex.account_period_balance
--into Plex.account_period_balance
from Plex.account_period_balance_view -- 43,630
--where period_display is NULL 

/*
 * Does the values in this view match with the CSV download and the TB PP?
 */
select b.pcn,b.account_no,
b.period,
a.revenue_or_expense,
b.debit,b.credit,b.balance,d.current_debit_credit TB_balance,b.ytd_debit,p.ytd_debit PP_ytd_debit,
b.ytd_credit,p.ytd_credit PP_ytd_credit,
b.ytd_balance,
d.ytd_debit_credit TB_ytd_balance,
p.ytd_debit-p.ytd_credit PP_ytd_balance
--b.balance -d.current_debit_credit  diff
-- select *
--select count(*) 
from Plex.account_period_balance b -- 43,630
inner join Plex.accounting_account a 
on b.pcn=a.pcn 
and b.account_no=a.account_no -- 43,630 
--from Plex.account_period_balance_view b -- 43,620  -- This view made the query non-responsive
--inner join Plex.trial_balance_multi_level d -- 42,040, 43,620 - 42,040 = 1,580 account periods do not show up on TB CSV download. TB download does not show the plex period for a multi period month, you must link to period_display
left outer join Plex.trial_balance_multi_level d -- TB download does not show the plex period for a multi period month, you must link to period_display
on b.pcn=d.pcn
and b.account_no = d.account_no
and b.period_display = d.period_display 
-- select * from Plex.Account_Balances_by_Periods p 
left outer join Plex.Account_Balances_by_Periods p -- 43,620
on b.pcn=p.pcn
and b.account_no = p.[no]
and b.period = p.period 
--inner join 
left outer join 
(
	select s.pcn,s.period, s.account_no,s.debit,s.credit,s.debit-s.credit balance
	--select count(*)
	from Plex.GL_Account_Activity_Summary s  --(),(221,202010)
	where s.pcn = 123681 
	and s.period between 202101 and 202110  -- 2,462
) s
on b.pcn=s.pcn 
and b.account_no=s.account_no
and b.period=s.period  
--where p.pcn is null and s.pcn is not null  -- 33  account periods with activity not on the TB report.
--where s.pcn is not null  -- 2,462
--where b.debit=s.debit -- 2,462
--where b.credit = s.credit -- 2,462
--where b.balance =s.balance  -- 2,462
--where b.balance !=s.balance -- 0
--where b.balance != d.current_debit_credit  -- 23
--where (b.balance - d.current_debit_credit) >  0.01 -- 0
--where b.credit != p.current_credit  -- 0 
--where b.debit != p.current_debit  -- 0 
--where (b.balance != p.Current_Debit - p.Current_Credit)   -- 0

--where b.ytd_debit != p.ytd_debit  -- 10 73100-000-0000 changed to a 'Revenue' or 'Expense' after the beginning of the year so PP_ytd_debit and PP_ytd_credit did not get reset on 2021-01. 
-- but our code only saw the current category so it reset the YTD values.
-- reset all Plex.account_period_balance for this account
-- UPDATE Plex.account_period_balance !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!11
-- update Plex.account_period_balance set ytd_debit=18912.67,ytd_credit=18912.67 where account_no = '73100-000-0000'
--where b.ytd_credit != p.ytd_credit  
--order by b.account_no,b.period
--where (d.ytd_debit_credit != (p.ytd_debit-p.ytd_credit))  -- 137
--where ((p.ytd_debit-p.ytd_credit) - d.ytd_debit_credit) > 0.01  -- 0
--where (b.ytd_balance - d.ytd_debit_credit) > 0.01  -- 0
--where (s.credit = b.credit) -- 2,462
--where (s.balance = b.balance) -- 0
-- where (s.debit = b.debit) -- 2,462
where (s.debit != b.debit) -- 0
--where ((s.ytd_balance - s.TB_ytd_balance) > .01)  -- 0

order by b.account_no,b.period


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
-- select count(*)
--select distinct b.account_no,b.category_type,d.category_type 
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
--where b.category_name = ''
--where b.category_type = ''
--where d.pcn is null

--where b.period_display = d.period_display  -- 42,040
--where b.period_display != d.period_display  -- 0
--where b.category_type != d.category_type  -- 40  -- TB report uses the category type linked to the sub_category
--where b.category_type_legacy = d.category_type  -- 42,040
where b.category_type_legacy != d.category_type  -- 0
--where b.category_name_legacy = d.category_name  -- 42,040
--where b.sub_category_name_legacy != d.sub_category_name  -- 0
--where b.sub_category_name_legacy = d.sub_category_name  -- 42,040
--where b.account_name != d.account_name  -- 0
--where b.account_name = d.account_name -- 42,040
--where b.balance = d.current_debit_credit -- 42,017
--where (b.balance - d.current_debit_credit) > 0.01 -- 0
--where b.ytd_balance = d.ytd_debit_credit -- 41,903
--where (b.ytd_balance - d.ytd_debit_credit) > 0.01 -- 0

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
