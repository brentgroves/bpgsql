	create view Plex.max_fiscal_period_view(pcn,year,max_fiscal_period)
	as
	WITH fiscal_period(pcn,year,period)
	as
	(
		select pcn,year(begin_date) year,period from Plex.accounting_period where pcn = 123681
	),
	--select * from fiscal_period
	max_fiscal_period(pcn,year,max_fiscal_period)
	as
	(
	  SELECT pcn,year,max(period) max_fiscal_period
	  FROM fiscal_period
	  group by pcn,year
	)
--	select count(*) cnt from max_fiscal_period
	select * from max_fiscal_period
	
select *
-- drop table Plex.max_fiscal_period
into Plex.max_fiscal_period
from Plex.max_fiscal_period_view	

select * from Plex.max_fiscal_period

	--drop view Plex.account_period_balance_low_view
	create view Plex.account_period_balance_low_view(pcn,account_key,account_no,period,next_period,debit,credit,balance)
	as
	with anchor_member(pcn,account_key,account_no,period,next_period)
	as 
	(
		    select 
		    a.pcn,
		    a.account_key,
		    a.account_no,
		    a.start_period period,
		    case 
		    when a.start_period < m.max_fiscal_period then a.start_period+1
		    else ((a.start_period/100 + 1)*100) + 1 
		    end next_period
		    --m.max_fiscal_period
		    
			--select count(*) cnt
		    --select *
			from Plex.accounting_account a  -- low: 398 * 10 = 3,980 /// all: 4,362 X 10 = 43,620
	   		join Plex.max_fiscal_period m 
	        on a.pcn=m.pcn
	        and (a.start_period/100) = m.[year]
			
			where a.pcn = 123681
			--and a.start_period = 0  -- 1,323 accounts do not have any balance snapshot records in Plex 
			and a.low_account =1  -- 661
			and a.start_period != 0  -- 398
			--and a.start_period != 0  -- 398
		--	and a.account_no = '10220-000-00000'
		--	and left(a.account_no,1) < '4' 
		--	and account_no = '10000-000-00000'	
	),
	--select count(*) from anchor_member  -- 398
--	account_period_low (pcn,account_key,account_no,period,next_period,max_fiscal_period,max_fiscal_next_period)
--	account_period_low (pcn,account_key,account_no,period,next_period,max_fiscal_period)
	account_period_low (pcn,account_key,account_no,period,next_period)
	AS
	(
	    -- Add max_fiscal_next_period to Anchor member
	    select 
	    a.pcn,
	    a.account_key,
	    a.account_no,
	    a.period,
		a.next_period
--	    a.max_fiscal_period,
	--    m.max_fiscal_period max_fiscal_next_period
		--select count(*) cnt
	    --select *
		from anchor_member a  -- low: 398 * 10 = 3,980 /// all: 4,362 X 10 = 43,620
  --		join max_fiscal_period m 
  --      on a.pcn=m.pcn
 --       and (a.next_period/100) = m.[year]
	    UNION ALL
	    -- Recursive member that references expression_name.
	    select
	    p.pcn,
	    p.account_key,
	    p.account_no,
	    -- create a record for this account with the next period
	    case 
	    when p.period < m.max_fiscal_period then p.period+1
	   -- when p.period%100 < 12 then p.period+1
	    else ((p.period/100 + 1)*100) + 1 
	    end period,
	    case 
	    when p.next_period < n.max_fiscal_period then p.next_period+1
	    else ((p.next_period/100 + 1)*100) + 1 
	    end next_period
	    --m.max_fiscal_period,
	    --n.max_fiscal_period max_fiscal_next_period
	    from account_period_low p
   		join Plex.max_fiscal_period m 
        on p.pcn=m.pcn
        and (p.period/100) = m.[year]
   		join Plex.max_fiscal_period n 
        on p.pcn=n.pcn
        and (p.next_period/100) = n.[year]
	    where p.period < 202111
	   -- where p.period < 202110
	),
--	select count(*) from account_period_low -- low:37,970 
	--select * from account_period_low --where period =201013
--	drop table Plex.accounting_period_low
	--select * 
	--into Plex.accounting_period_low
	--from Plex.accounting_period_low_view
	--OPTION (MAXRECURSION 210)

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
		left outer join Plex.accounting_balance b  -- 1 to many in case of multiple periods in a single month
		on a.pcn=b.pcn
		and a.account_no = b.account_no
		and a.period=b.period
		
	)
	-- references expression name
	SELECT * FROM   account_period_balance_low; 


	SELECT distinct period FROM   Plex.account_period_balance_low order by period; 

CREATE TABLE Plex.account_period_balance_low(
	pcn int,
	account_key int,
	account_no varchar(20),
	period int,
	next_period int,
	debit decimal(19,5),
	credit decimal(19,5),
	balance decimal(19,5),
--	balance_legacy decimal(19,5),
	PRIMARY KEY (pcn,account_key,period)
);


SELECT * 
-- drop table Plex.account_period_balance_low
	into Plex.account_period_balance_low
	--select count(*)
	FROM   Plex.account_period_balance_low_view
	--order by pcn,account_no,period
	OPTION (MAXRECURSION 210);  -- 37,970
--	SELECT count(*) FROM   Plex.account_period_balance_low OPTION (MAXRECURSION 210);  -- 37,970
	--where account_no = '41100-000-0000'

	
--with calc_ytd_low (pcn,period,next_period,account_no,debit,ytd_debit,credit,ytd_credit,balance,ytd_balance)
create view Plex.calc_ytd_low_view(pcn,period,next_period,account_no,debit,ytd_debit,credit,ytd_credit,balance,ytd_balance)
as
with calc_ytd_low (pcn,period,next_period,account_no,debit,ytd_debit,credit,ytd_credit,balance,ytd_balance)
AS
(
    -- Anchor member
    select
    b.pcn,
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
	from Plex.account_period_balance_low b  -- 37,970
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
    	y.pcn,
	    case 
	    when y.period < m.max_fiscal_period then y.period+1
	 --   when y.period%100 < 12 then y.period+1
	    else ((y.period/100 + 1)*100) + 1 
	    end period,
	    case 
	    when y.next_period < n.max_fiscal_period then y.next_period+1
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
    --select * from Plex.account_period_balance_low b  -- 37970
    --select count(*) from Plex.account_period_balance_low b  -- 37970
    --select distinct next_period from Plex.account_period_balance_low b order by next_period  -- 37970
    --select distinct period from Plex.account_period_balance_low b order by period  -- 37970
    inner join Plex.account_period_balance_low b 
--    inner join Plex.account_period_balance_low b 
    on y.pcn=b.pcn
    and y.next_period=b.period 
    and y.account_no=b.account_no
    --select * from max_fiscal_period m 
	inner join Plex.max_fiscal_period m 
    on y.pcn=m.pcn
    and (y.period/100) = m.[year]
	inner join Plex.max_fiscal_period n 
    on y.pcn=n.pcn
    and (y.next_period/100) = n.[year]
    where y.period < 202111
)
-- references expression name
--SELECT count(*) FROM   calc_ytd_low OPTION (MAXRECURSION 210);  -- 37,970
SELECT pcn,period,next_period,account_no,debit,ytd_debit,credit,ytd_credit,balance,ytd_balance FROM calc_ytd_low 
--order by period,account_no
select * 
--select count(*)
--into 
from Plex.calc_ytd_low_view -- 37,970
OPTION (MAXRECURSION 210); 

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


