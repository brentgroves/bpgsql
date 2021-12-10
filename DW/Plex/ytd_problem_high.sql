SELECT pcn, period,next_period,account_no,debit,ytd_debit,credit,ytd_credit,balance,ytd_balance 
from Plex.accounting_period_balance_low 
select *
--select count(*) from Plex.accounting_period_balance_low -- 37,970
-- select distinct pcn,period from Plex.trial_balance_multi_level d where d.pcn =123681 order by pcn,period -- 200812 to 202112
-- select distinct pcn,period from Plex.accounting_period_balance_low b where b.pcn =123681 order by b.pcn,b.period -- 200701 to 202111
-- select pcn,period,account_no,balance from Plex.accounting_period_balance_low b where b.pcn =123681 and period < 200812 order by b.pcn,b.period -- 200701 to 202111
-- select pcn,period,account_no,current_debit_credit from Plex.trial_balance_multi_level d where d.pcn =123681 and period be< 200901 order by pcn,period -- 200812 to 202112

-- select distinct pcn,period from Plex.Account_Balances_by_Periods b where b.pcn =123681 order by b.pcn,b.period -- 200812 to 202110
-- select pcn,period,* from Plex.Account_Balances_by_Periods b where b.pcn =123681 order by b.pcn,b.period -- 200812 to 202110

select count(*) from Plex.trial_balance_multi_level d 
where left(d.account_no,1) < '4' and d.pcn = 123681 and period = 200812 -- 570 --period between 200812 and 200901  -- 1,140

select count(*) from Plex.accounting_period_balance_low b 
where b.pcn = 123681 and b.period between 200812 and 200901  -- 120

select *
-- select distinct pcn,account_no
-- select count(*)
-- drop table Plex.TB_201001_start_period
-- select * from Plex.Reset_YTD_balance_yearly order by account_no
-- select * into Plex.Reset_YTD_balance_yearly from Plex.TB_201001_start_period
-- into Plex.TB_201001_start_period
from 
(
	select 
	b.pcn,
	b.account_no,
	b.period_key,
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
	--select d.*
	from 
	(
		select ap.period_key,ap.period_display,ap.begin_date,b.* 
		-- select count(*)
		from Plex.accounting_period_balance_high b  -- 37,230
		--select * from Plex.accounting_period ap 
		join Plex.accounting_period ap 
		on b.pcn=ap.pcn
		and b.period= ap.period -- 37,230
		where b.pcn = 123681
		and b.period < 202111  -- 37,230
		--and b.account_no = '20104-300-00000'
		--and b.account_no = '30599-300-00000'
	--	and b.period between 200812 and 201001 -- 1,043
	--where b.period between 200812 and 201006  -- 1,567
	--where b.period between 200812 and 201011 -- 2,182
	--where b.period between 200812 and 202110 -- 37,549
	--where b.period between 201012 and 201012 -- 131
	) b
	--where b.period between 201012 and 201013 -- 266
	--where b.period between 200812 and 202110 -- 37,549
	-- select distinct pcn,period from Plex.accounting_period_balance_high b order by pcn,period --goes to 202110
	-- select distinct period_display from Plex.trial_balance_multi_level d where right(period_display,2) = '21' order by period_display -- goes to 202112
	-- select distinct period from Plex.Account_Balances_by_Periods p where p.period > 202012  -- goes to 202110
	--select * from Plex.trial_balance_multi_level d where d.period = 201013  -- none
	--select distinct period_display from Plex.trial_balance_multi_level d where d.period = 201012  -- none
	--select distinct period,period_display from Plex.trial_balance_multi_level d where d.period = 201012  -- none
	--select count(*) from Plex.Account_Balances_by_Periods p where p.period = 201013  -- 4,204
	left outer join Plex.trial_balance_multi_level d 
	on b.pcn=d.pcn
	and b.account_no = d.account_no
	and b.period_display = d.period_display -- 38,345
	--where b.period between 200812 and 201001 -- 1,043
	--where b.period between 200812 and 201006  -- 1,567
	--where b.period between 200812 and 201011 -- 2,182
	--where b.period between 201012 and 201012 -- 255
	--where b.period between 200812 and 202110 -- 37,924
	
	left outer join Plex.Account_Balances_by_Periods p 
	on b.pcn=p.pcn
	and b.account_no = p.[no]
	and b.period = p.period   -- THIS IS A CONTROLLED SITUATION SO WE DON'T HAVE TO WORRY ABOUT MULTIPLE PERIODS PER MONTH 201012, 201603, ETC.
)s 	-- 37,230
where s.ytd_debit != s.PP_ytd_debit  -- 10
-- where (s.TB_ytd_balance != s.PP_ytd_balance)  -- 9
-- where (((s.TB_ytd_balance - s.PP_ytd_balance) > .01) or ((s.TB_ytd_balance - s.PP_ytd_balance) < -.01)) -- 
-- where (((s.TB_ytd_balance - s.ytd_balance) > .01) or ((s.TB_ytd_balance - s.ytd_balance) < -.01)) -- 0
-- where (s.PP_balance != s.balance) -- No differences
-- where (s.TB_balance != s.balance) -- 6 -- 1 cent

--and s.period between 200912 and 201101
--order by s.pcn,s.account_no
--where (s.TB_ytd_balance != s.ytd_balance) -- 4,116 - some big differences
--where (s.PP_ytd_balance != s.ytd_balance) -- 2,872 - some big differences
--where (s.PP_balance != s.balance) -- No differences
order by s.account_no,s.period


select s.pcn,s.period, s.account_no,s.debit,s.credit,s.net
-- select distinct pcn,account_no,period
-- select distinct pcn,account_no,period
-- select distinct pcn,period
--select count(*)
from Plex.GL_Account_Activity_Summary s  -- 38,208  -- 200812 - 202111
--order by pcn,period
--select distinct pcn,period from Plex.accounting_period_balance_low b order by pcn,period -- 200701 to 202111
left outer join Plex.accounting_period_balance_low b  -- 37,970
on s.pcn = b.pcn
and s.account_no = b.account_no 
and s.period = b.period 
where b.pcn is null  -- 29,981

left outer join Plex.trial_balance_multi_level d 
on b.pcn=d.pcn
and b.account_no = d.account_no
and b.period_display = d.period_display -- 38,345


order by pcn,account_no,period

select b.account_no,b.period,b.balance
from Plex.accounting_period_balance_low b  -- 37,970
join Plex.TB_201001_start_period s 
on b.pcn = s.pcn 
and b.account_no=s.account_no
where b.pcn = 123681 
and b.period > 201801
and b.balance > 0
order by b.account_no,b.period

-- DIFF STARTS ON 201001
select b.pcn,b.account_no,b.period,b.ytd_balance,
d.ytd_debit_credit TB_balance,
p.Ytd_Debit - p.Ytd_Credit PP_balance
from
(
	select ap.period_display,ap.begin_date,b.* 
	-- select count(*)
	from Plex.accounting_period_balance_low b  -- 37,970
	--select * from Plex.accounting_period ap 
	join Plex.accounting_period ap 
	on b.pcn=ap.pcn
	and b.period= ap.period -- 37,970
	where b.pcn = 123681
	--and b.account_no = '30600-300-00000'
	--and b.account_no = '20110-300-00000'
	and b.account_no = '20104-300-00000'
	--	and b.period between 200812 and 201001 -- 1,043
	--where b.period between 200812 and 201006  -- 1,567
	--where b.period between 200812 and 201011 -- 2,182
	--where b.period between 200812 and 202110 -- 37,549
	--where b.period between 201012 and 201012 -- 131
) b
left outer join Plex.trial_balance_multi_level d 
on b.pcn=d.pcn
and b.account_no = d.account_no
and b.period_display = d.period_display -- 38,345
left outer join Plex.Account_Balances_by_Periods p 
on b.pcn=p.pcn
and b.account_no = p.[no]
and b.period = p.period 
order by b.account_no,b.period

--where b.period between 200812 and 201001 -- 1,043
--where b.period between 200812 and 201006  -- 1,567
--where b.period between 200812 and 201011 -- 2,182
--where b.period between 200812 and 202110 -- 37,549


--where d.pcn =123681 
--and d.period between 200812 and 202110 
--and d.period between 200812 and 201001 


-- 
select 
d.pcn,
d.account_no,
d.period,
d.current_debit_credit TB_Debit_Credit, 
b.balance,
d.ytd_debit_credit TB_YTD,
b.ytd_balance
from Plex.trial_balance_multi_level d 
join Plex.accounting_period_balance_low b
on d.pcn=b.pcn
and d.account_no = b.account_no
and d.period = b.period 
where d.pcn =123681 
and d.period between 200812 and 200910 
--and d.period between 200812 and 200901 
and (d.current_debit_credit != b.balance) -- 0
and ((d.current_debit_credit != b.balance) or (d.ytd_debit_credit != b.ytd_balance))  -- 0


order by d.pcn,d.account_no,d.period -- 200812 to 202112

from Plex.trial_balance_multi_level d 

where d.pcn =123681

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


