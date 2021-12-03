select * from Scratch.ytd_problem

	--drop view Scratch.accounting_period_balance_low
	create view Scratch.accounting_period_balance_low(period,account_no,debit,ytd_debit,credit,ytd_credit,balance,ytd_balance)
	as
	WITH account_period_low (pcn,account_key,account_no,period,next_period)
	AS
	(
	    -- Anchor member
	    select 
	    a.pcn,
	    a.account_key,
	    a.account_no,
	    a.start_period period,
	    case 
	    when a.start_period%100 < 12 then a.start_period+1
	    else ((a.start_period/100 + 1)*100) + 1 
	    end next_period
		--select count(*) cnt
	    --select *
		from Plex.accounting_account a  -- low: 398 * 10 = 3,980 /// all: 4,362 X 10 = 43,620
		inner join Scratch.ytd_problem p 
		on a.account_no = p.account_no
		where a.pcn = 123681
		--and a.start_period = 0  -- 1,323 accounts do not have any balance snapshot records in Plex 
		and a.low_account =1  -- 134
		and a.start_period != 0  -- 134
	--	and left(a.account_no,1) < '4' 
	--	and account_no = '10000-000-00000'
	    UNION ALL
	    -- Recursive member that references expression_name.
	    select
	    p.pcn,
	    p.account_key,
	    p.account_no,
	    -- create a record for this account with the next period
	    case 
	    when p.period%100 < 12 then p.period+1
	    else ((p.period/100 + 1)*100) + 1 
	    end period,
	    case 
	    when p.next_period%100 < 12 then p.next_period+1
	    else ((p.next_period/100 + 1)*100) + 1 
	    end next_period
	    from account_period_low p
	    where p.period < 202110
	),
--	select count(*) from account_period_low -- low:37,168 
--	select * from account_period
--	OPTION (MAXRECURSION 210)

	account_period_balance_low( pcn,account_key,account_no,period,next_period,debit,credit,balance)
	as 
	(
		select a.pcn,a.account_key,a.account_no,a.period,a.next_period,
		case 
		when b.pcn is null then 0 
		else b.debit 
		end debit,
		case 
		when b.pcn is null then 0 
		else b.credit 
		end credit,
		case 
		when b.pcn is null then 0 
		else b.balance 
		end balance
		/*
		 * Join to a balance record if one exists for each account and period
		 */
		-- SELECT count(*)
		FROM   account_period_low a -- 198,110
		-- select * from Plex.accounting_balance b
		left outer join Plex.accounting_balance b  -- There are alot more balance records now. 200812 to 202110
		on a.pcn=b.pcn
		and a.account_no = b.account_no
		and a.period=b.period
		
	),
	-- references expression name
	--SELECT count(*) FROM   account_period_balance_low OPTION (MAXRECURSION 210);  -- 15,997
	--where account_no = '41100-000-0000'
	

calc_ytd_low (period,next_period,account_no,debit,ytd_debit,credit,ytd_credit,balance,ytd_balance)
AS
(
    -- Anchor member
    select 
    b.period,
    b.next_period,
    b.account_no, 
    b.debit,
    b.debit as ytd_debit,
    b.credit,
    b.credit as ytd_credit,
    b.balance,
    b.balance as ytd_balance
    --select count(*)
	from account_period_balance_low b
	join Plex.accounting_account a  -- low: 398 * 10 = 3,980 /// all: 4,362 X 10 = 43,620
	on b.pcn=a.pcn
	and b.account_key=a.account_key
	-- Only get 1 balance record for each account.  That is the balance record with the 1st period for the account.
	where b.period = a.start_period  
	--and debit > 0
	--and account_no = '41100-000-0000'
	--and left(account_no,1) < '7' --1,886
    UNION ALL
    -- Recursive member that references expression_name.
    select 
	    case 
	    when y.period%100 < 12 then y.period+1
	    else ((y.period/100 + 1)*100) + 1 
	    end period,
	    case 
	    when y.next_period%100 < 12 then y.next_period+1
	    else ((y.next_period/100 + 1)*100) + 1 
	    end next_period,
	    y.account_no,
	    b.debit,
	    cast(y.ytd_debit+b.debit as decimal(19,5)) as ytd_debit,
	    b.credit,
	    cast(y.ytd_credit+b.credit as decimal(19,5)) as ytd_credit,
	    b.balance,
	    cast(y.ytd_balance+b.balance as decimal(19,5)) as ytd_balance
    from calc_ytd_low y
    -- join the calc_ytd_low record with the accounts next account_period_balance_low record and 
    -- create a new calc_ytd_low record for this next period.
    inner join account_period_balance_low b 
    on y.next_period=b.period 
    and y.account_no=b.account_no
    where y.period < 202110
)
-- references expression name
--SELECT count(*) FROM   calc_ytd_low OPTION (MAXRECURSION 210);  -- 15,997
SELECT period,account_no,debit,ytd_debit,credit,ytd_credit,balance,ytd_balance FROM calc_ytd_low 
--OPTION (MAXRECURSION 210); 

select * 
-- into Scratch.ytd_problem_period_balance
from Scratch.accounting_period_balance_low
order by account_no,period
OPTION (MAXRECURSION 210); 

select * from Scratch.ytd_problem_period_balance order by account_no,period

select period,count(*) 
--select count(*)
from
(
	select * FROM
	(
		select account_no,period, count(*) account_period_cnt
		from
		(
			select account_no,period from Plex.trial_balance_multi_level t 
			--where account_no = '10220-000-00000' and period = 201012
		)s 
		group by account_no,period
	)r 
	where account_period_cnt > 1
)s 
group by period	
order by period desc

select 
b.period,
b.account_no,
--b.debit,b.ytd_debit,
--b.credit,b.ytd_credit,
--b.debit-b.credit our_debit_credit
b.balance,t.current_debit_credit, 
b.ytd_balance,t.ytd_debit_credit 
from Scratch.ytd_problem_period_balance b
--select distinct pcn from Plex.trial_balance_multi_level t 
--select * from Plex.trial_balance_multi_level t where account_no = '10220-000-00000' and period = 201012
--
join Plex.trial_balance_multi_level t 
on b.account_no=t.account_no 
and b.period=t.period 
order by account_no,period

select * from Plex.accounting_balance ab where account_no = '10220-000-00000' and period between 201603 and 201604 order by account_no,period 
select * from Plex.trial_balance_multi_level t where account_no = '10220-000-00000' and period = 201603 order by period_display 

-- 03a2016,current_debit_credit:737,005.36, ytd_debit_credit:11,949,811.54
-- this coresponds to period 201603 in the accounting_v_balance view
-- 03b2016,current_debit_credit:2,220.53, ytd_debit_credit:11,952,032.08
-- this coresponds to period 201604 in the accounting_v_balance view
select * from Plex.trial_balance_multi_level t where account_no = '10220-000-00000' and period between 201603 and 201701 order by period_display 

select * from Plex.accounting_balance ab where account_no = '10220-000-00000' and period between 201012 and 201101 order by account_no 
select * from Plex.trial_balance_multi_level t where account_no = '10220-000-00000' and period = 201012 order by period_display 
--12b2010 = 5474346.28,12a2010 = 8001268.21
select * 
--into Plex.accounting_period_balance_low_2021_10_Bak
from Plex.accounting_period_balance_low_2021_10
-- drop table Plex.accounting_period_balance_low_2021_10
select * 
into Plex.accounting_period_balance_low_2021_10
from Plex.accounting_period_balance_low -- where account_no = '20100-000-0000' OPTION (MAXRECURSION 210);
OPTION (MAXRECURSION 210);

select * from Plex.accounting_period_balance_low_2021_10 b where b.account_no like '27800-000%' and b.period = 202110 order by b.account_no
select distinct pcn,period from Plex.Account_Balances_by_Periods 
select * from Plex.Account_Balances_by_Periods p where p.pcn = 123681 and p.period=202110 and p.[no] like '27800-000%' order by p.[no]
select * from Plex.accounting_account_ext where account_no = '27800-000-9806'
/*
asset/equity/expense/liability/revenue
Assets naturally have debit balances, so they should normally appear as positive numbers
Liabilities and Equity naturally have credit balances, so would normally appear as negative numbers
Revenue accounts naturally have credit balances, so normally these would be negative
Expense accounts naturally have debit balances, so normally would be positive numbers
there are exceptions in every category for a variety of reasons (of course)
*/


