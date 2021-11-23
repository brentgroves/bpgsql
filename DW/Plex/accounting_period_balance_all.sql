	WITH account_period (pcn,account_key,account_no,period)
	AS
	(
	    -- Anchor member
	    select 
	    a.pcn,
	    a.account_key,
	    a.account_no,
	    202101 period
		--select count(*) cnt
		from Plex.accounting_account a  -- high: 3,701 * 10 = 37,010 /// all: 4,362 X 10 = 43,620
		where pcn = 123681
		and left(a.account_no,1) > '3' 
	--	and account_no = '10000-000-00000'
	    UNION ALL
	    -- Recursive member that references expression_name.
	    select
	    p.pcn,
	    p.account_key,
	    p.account_no,
	    p.period+1
	    from account_period p
	    where p.period < 202110
	),
--	select count(*) from account_period -- high:37,010 all:43,620
--	select * from account_period
	account_period_balance( pcn,account_key,account_no,period,debit,credit,balance)
	as 
	(
		select a.pcn,a.account_key,a.account_no,a.period,
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
		
		--SELECT count(*)
		FROM   account_period a -- 198,110
		left outer join Plex.accounting_balance b
		on a.pcn=b.pcn
		and a.account_no = b.account_no
		and a.period=b.period
		
	),
		-- references expression name
		--select *
		--SELECT count(*)
		--FROM   account_period_balance;  -- 37,010
	--select count(*) from Plex.accounting_period_balance_high  -- 37,010
	--select * from Plex.accounting_period_balance_high  -- 37,010
	--where account_no = '41100-000-0000'
	

calc_ytd_high (period,account_no,debit,ytd_debit,credit,ytd_credit,balance,ytd_balance)
AS
(
    -- Anchor member
    select 
    period,
    account_no, 
    debit,
    debit as ytd_debit,
    credit,
    credit as ytd_credit,
    balance,
    balance as ytd_balance
    --select count(*)
	from account_period_balance
	--where period between 202101 and 202102
	where period = 202101
	--and debit > 0
	--and account_no = '41100-000-0000'
	--and left(account_no,1) < '7' --1,886
    UNION ALL
    -- Recursive member that references expression_name.
    select 
    y.period+1,
    y.account_no,
    b.debit,
    cast(y.ytd_debit+b.debit as decimal(19,5)) as ytd_debit,
    b.credit,
    cast(y.ytd_credit+b.credit as decimal(19,5)) as ytd_credit,
    b.balance,
    cast(y.ytd_balance+b.balance as decimal(19,5)) as ytd_balance
    from calc_ytd_high y
    inner join account_period_balance b 
    on y.period+1=b.period 
    and y.account_no=b.account_no
    where y.period < 202110
),
	account_period_low (pcn,account_key,account_no,period,next_period)
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
		from Plex.accounting_account_ext a  -- low: 398 * 10 = 3,980 /// all: 4,362 X 10 = 43,620
		where a.pcn = 123681
		and a.first_digit_123 =1  -- 661
		and a.start_period != 0
	--	and left(a.account_no,1) < '4' 
	--	and account_no = '10000-000-00000'
	    UNION ALL
	    -- Recursive member that references expression_name.
	    select
	    p.pcn,
	    p.account_key,
	    p.account_no,
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
--	select count(*) from account_period -- low:37,138 all:43,620
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
		
		--SELECT count(*)
		FROM   account_period_low a -- 198,110
		-- select * from Plex.accounting_balance b
		left outer join Plex.accounting_balance b
		on a.pcn=b.pcn
		and a.account_no = b.account_no
		and a.period=b.period
		
	),
	-- references expression name
	--	SELECT count(*) FROM   account_period_balance OPTION (MAXRECURSION 210);  -- 37,138
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
	join Plex.accounting_account_ext a  -- low: 398 * 10 = 3,980 /// all: 4,362 X 10 = 43,620
	on b.pcn=a.pcn
	and b.account_key=a.account_key
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
    inner join account_period_balance_low b 
    on y.next_period=b.period 
    and y.account_no=b.account_no
    where y.period < 202110
)
-- references expression name
--SELECT count(*) FROM   calc_ytd_low OPTION (MAXRECURSION 210);  -- 37,138
--SELECT period,account_no,debit,ytd_debit,credit,ytd_credit,balance,ytd_balance FROM calc_ytd_low OPTION (MAXRECURSION 210); 
/*
 * Attempted to do this but it took too long to run 
 * So ran the 2 CTE separately and inserted into 2 tables that will be unioned
 */
SELECT period,account_no,debit,ytd_debit,credit,ytd_credit,balance,ytd_balance 
FROM   calc_ytd_high where period > 202012
union
SELECT period,account_no,debit,ytd_debit,credit,ytd_credit,balance,ytd_balance FROM calc_ytd_low where period > 202012 OPTION (MAXRECURSION 210);

/*
 * Working solution
 */
select *
-- select count(*)
--into Plex.accounting_period_balance_all_2021_10
from
(
	select * 
	--select count(*)
	from Plex.accounting_period_balance_low_2021_10 -- 3,930 / all:37,138
	where period >202012
	union
	select *
	--select count(*)
	from Plex.accounting_period_balance_high_2021_10 --37,010
	where period >202012
)s
--where left(account_no,1) > '3'
order by period,account_no
-- where account_no = '20100-000-0000' OPTION (MAXRECURSION 210);

select distinct pcn,period from Plex.Account_Balances_by_Periods abbp 
select *
-- select count(*)
from Plex.Account_Balances_by_Periods p 
where p.pcn=123681 and p.period = 202110  -- 4204


select *
-- select count(*)
from Plex.accounting_period_balance_all_2021_10 b
where b.period = 202110  -- 4099



select *
-- select count(*)
from 
(
	select * from Plex.Account_Balances_by_Periods p 
	where p.pcn=123681 
	and p.period=202110
) p
left outer join Plex.accounting_period_balance_all_2021_10 b
on p.[no] = b.account_no
and p.period = b.period 
where b.account_no is null  -- 201


select *
-- select count(*)
from 
(
	select * from Plex.Account_Balances_by_Periods p 
	where p.pcn=123681 
	and p.period=202110
) p
left outer join Plex.accounting_period_balance_all_2021_10 b
on p.[no] = b.account_no
and p.period = b.period 
where p.current_balance != b.balance -- 0
--where p.current_debit != b.debit -- 0
--where p.current_credit != b.credit -- 0



select *
-- select count(*)
from Plex.accounting_period_balance_all_2021_10 b 
left outer join 
(
	select * from Plex.Account_Balances_by_Periods p 
	where p.pcn=123681 
	and p.period=202110
) p
on b.account_no = p.[no]  
and b.period = p.period   
where b.period=202110  -- 
and p.[no] is null  -- 96


select * from Plex.Account_Balances_by_Periods p 
where p.pcn=123681 
and p.period=202109

