select * 
-- drop table Plex.accounting_period_balance_all
--into Plex.accounting_period_balance_all
from 
(
select l.pcn,l.period,l.account_no,l.debit,l.ytd_debit,l.credit,l.ytd_credit,l.balance,l.ytd_balance 
-- select count(*)
from Plex.accounting_period_balance_low l  -- 3,710
where l.period between 202101 and 202110
union
select * 
-- select count(*)
from Plex.accounting_period_balance_high  -- 37,230 + 3,710 = 40,940
)s  -- 40,940
-- select distinct pcn,period from Plex.accounting_period_balance_low b order by pcn,period --goes from 200701 to 202111
-- select distinct pcn,period from Plex.accounting_period_balance_high b order by pcn,period --goes from 202101 to 202110
select *
-- select count(*)
from 
(
	select
	b.pcn,
	b.account_no,
	b.period,
	b.period_display,
	b.debit,
	b.credit,
	b.balance,
	p.current_debit-p.current_credit PP_balance,
	d.current_debit_credit TB_balance,
	b.ytd_balance,
	p.ytd_debit - p.ytd_credit PP_ytd_balance,
	d.ytd_debit_credit TB_ytd_balance,
	
	--b.debit,
	p.current_debit PP_Debit, 
	--	b.credit,
	p.current_credit PP_credit, 
	b.ytd_debit,
	p.ytd_debit PP_ytd_debit,
	b.ytd_credit,
	p.ytd_credit PP_ytd_credit
	--select count(*)
	from 
	(
		select b.pcn,b.period,p.period_display,b.account_no,b.debit,b.ytd_debit,b.credit,b.ytd_credit,b.balance,b.ytd_balance 
		from Plex.accounting_period_balance_all b -- 40,940
		inner join Plex.accounting_period p
		on b.pcn=p.pcn
		and b.period=p.period 
	)b 
	left outer join Plex.trial_balance_multi_level d -- TB download does not show the plex period for a multi period month, you must link to period_display
	on b.pcn=d.pcn
	and b.account_no = d.account_no
	and b.period_display = d.period_display -- 38,345
	left outer join Plex.Account_Balances_by_Periods p 
	on b.pcn=p.pcn
	and b.account_no = p.[no]
	and b.period = p.period -- 40,940
)s
--where s.debit != s.PP_debit  -- 0 
--where s.credit != s.PP_credit  -- 0 
--where s.balance != s.PP_balance  -- 0
--where (s.TB_balance != s.balance) -- 23 -- 1 cent
--where (((s.TB_balance - s.balance) > .01) or ((s.TB_balance - s.balance) < -.01)) -- 0
--where (s.TB_balance != s.PP_balance) -- 23 -- 1 cent
where (((s.TB_balance - s.PP_balance) > .01) or ((s.TB_balance - s.PP_balance) < -.01)) -- 0

--where s.ytd_debit != s.PP_ytd_debit  -- 10 73100-000-0000 changed from a 'Revenue' or 'Expense' so PP_ytd_debit and PP_ytd_credit did not get reset on 2021-01. Plex ticket.
-- this did not affect ytd values because 202012 had 0 YTD_balance so no reset was needed.

where (s.ytd_balance != s.PP_ytd_balance) -- 0
--where (s.TB_ytd_balance != s.PP_ytd_balance)  -- 137
-- where (((s.TB_ytd_balance - s.PP_ytd_balance) > .01) or ((s.TB_ytd_balance - s.PP_ytd_balance) < -.01)) -- 0
-- where (((s.TB_ytd_balance - s.ytd_balance) > .01) or ((s.TB_ytd_balance - s.ytd_balance) < -.01)) -- 0

order by s.account_no,s.period

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
order by b.account_no,b.period

/*
 * Our queries have account periods with activity that TB CSV download does not.
 * That is the purpose of this project.
 */
select *
--select count(*)
from Plex.accounting_period_balance_all b -- 40,940
left outer join Plex.trial_balance_multi_level m
on b.pcn = m.pcn 
and b.account_no=m.account_no 
and b.period=m.period
where m.pcn is null  -- 922
order by b.account_no,b.period

/*
 * What accounts with activity do not show up on the Trial Balance report?
 */
select a.*
from 
(
	select distinct b.pcn,b.account_no
	--select count(*)
	from Plex.accounting_period_balance_all b -- 40,940
	left outer join Plex.trial_balance_multi_level m
	on b.pcn = m.pcn 
	and b.account_no=m.account_no 
	and b.period=m.period
	where m.pcn is null  -- 96
)s
inner join Plex.accounting_account a 
on s.pcn=a.pcn 
and s.account_no=a.account_no 
order by s.pcn,s.account_no  -- 96

/*
 * Verify balances of accounts not shown on the TB report
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
	where m.pcn is null  -- 96
) b 
inner join 
(
	select s.pcn,s.period, s.account_no,s.debit,s.credit,s.debit-s.credit balance
	--select count(*)
	from Plex.GL_Account_Activity_Summary s  --(),(221,202010)
	where s.pcn = 123681 
	and s.period between 202101 and 202110  -- 2,462
) s
on b.pcn=s.pcn 
and b.account_no=s.account_no
and b.period=s.period  -- 33
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
--drop view Plex.account_period_balance_view
create view Plex.account_period_balance_view(pcn,account_no,period,debit,ytd_debit,credit,ytd_credit,balance,ytd_balance)
as

with account_period(pcn,account_no,period)
AS
(
    -- Anchor member
    select 
    a.pcn,
    a.account_no,
    202101 period
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
    p.period+1  -- this is ok if we do not want to include periods for multiple years.
    from account_period p
    where p.period < 202110
)
select 
a.pcn,
a.account_no,
a.period,
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
	select b.*
	-- select distinct b.pcn,b.account_no
	--select count(*)
	from Plex.accounting_period_balance_all b -- 40,940
	where b.pcn = 123681 
	and b.period between 202101 and 202110  -- 40,940
) b 
on a.pcn=b.pcn 
and a.account_no=b.account_no 
and a.period=b.period 
--where b.pcn is null  -- 2,680

select count(*) from Plex.account_period_balance_view -- 43,620
-- select count(*) from account_period -- 43,620


