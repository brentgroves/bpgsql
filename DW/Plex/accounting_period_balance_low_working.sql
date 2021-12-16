	create view Plex.max_fiscal_period_view(pcn,year,max_fiscal_period)
	as
	WITH fiscal_period(pcn,year,period)
	as
	(
		select pcn,year(begin_date) year,period 
		--select distinct pcn,period
		from Plex.accounting_period where pcn = 123681  -- 200601 to > 204103
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
--into Plex.max_fiscal_period
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
		    --select distinct a.pcn,a.start_period 
			from Plex.accounting_account a  -- 18,015
			--where a.pcn = 123681  -- 4,363 a low account was added 
			--and a.account_no in 
			--(
			--	select account_no from Plex.Reset_YTD_balance_yearly r  -- 22
			--)  -- 22
			--where a.pcn = 123681  -- 4,363 a low account was added 
			--and a.revenue_or_expense != 0 -- 3,723
			--and a.revenue_or_expense = 0 -- 640 a low account was added 
			--where a.pcn = 123681  -- 4,363 a low account was added 
			--and a.start_period =0  -- 3,031, -- 4,363-3,031= 1,332
	   		--left outer join Plex.max_fiscal_period m 
	   		inner join Plex.max_fiscal_period m 
	        on a.pcn=m.pcn
	        and (a.start_period/100) = m.[year]
			where a.pcn = 123681  -- 1,332 accounts have accounts have a balance snapshot 
			and a.revenue_or_expense =0  -- 376  -- 22 low accounts will not be in this set because they have a category_type of revenue or expense
			--and a.account_no = '10220-000-00000'
	),
	--select count(*) from anchor_member  -- 376
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
		from anchor_member a  -- low: 376
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
	    --where p.period < 202111
	   where p.period < 202110
	),
	--select max(period),max(next_period)  -- 202110,202111
	--select count(*) 
	--from account_period_low -- low:34,508 
	--OPTION (MAXRECURSION 210)
	--select * from account_period_low --where period =201013

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
		FROM account_period_low a -- 198,110
		-- select * from Plex.accounting_balance b
		left outer join Plex.accounting_balance b  
		on a.pcn=b.pcn
		and a.account_no = b.account_no
		and a.period=b.period
		
	)
	select *
	--SELECT count(*) 
	FROM   account_period_balance_low -- 34,508 
	

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

select *
--SELECT count(*) -- 34,508
-- drop table Plex.account_period_balance_low
-- select count(*) from Plex.account_period_balance_low  -- 34,884
-- select *
-- into  Scratch.account_period_balance_low_12_15
-- from Plex.account_period_balance_low  -- 34,884
--	into Plex.account_period_balance_low
	--select count(*)
	FROM   Plex.account_period_balance_low_view
	--order by pcn,account_no,period
	OPTION (MAXRECURSION 210);  -- 34,884, old value = 37,970
--	SELECT count(*) FROM   Plex.account_period_balance_low OPTION (MAXRECURSION 210);  -- 37,970
	--where account_no = '41100-000-0000'

-- drop view Plex.calc_ytd_low_view	
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
	from Plex.account_period_balance_low b  -- 34,508,
	join Plex.accounting_account a  -- 34,508 
	on b.pcn=a.pcn
	and b.account_key=a.account_key
	-- Only get 1 balance record for each account.  That is the balance record with the 1st period for the account.
	where b.period = a.start_period  -- 376  
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
    --select distinct next_period from Plex.account_period_balance_low b order by next_period  -- 200702 to 202111
    --select distinct period from Plex.account_period_balance_low b order by period  -- 200701 to 202110
    inner join Plex.account_period_balance_low b 
--    select dinner join Plex.account_period_balance_low b 
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
    where y.period < 202110
)
-- references expression name
--SELECT count(*) FROM   calc_ytd_low OPTION (MAXRECURSION 210);  -- 34,508
SELECT pcn,period,next_period,account_no,debit,ytd_debit,credit,ytd_credit,balance,ytd_balance FROM calc_ytd_low 
--order by period,account_no


select *
--into Scratch.accounting_period_balance_low_12_15 
--select count(*) -- 34,508, old: 34,884
-- drop table Plex.accounting_period_balance_low
from Plex.accounting_period_balance_low 

select *
--select count(*) -- 34,508
--into Plex.accounting_period_balance_low
from Plex.calc_ytd_low_view  
OPTION (MAXRECURSION 210);



