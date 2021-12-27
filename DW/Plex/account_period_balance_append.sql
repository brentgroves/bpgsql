-- mgdw.Plex.accounting_balance_update_period_range definition

-- Drop table

-- DROP TABLE mgdw.Plex.accounting_balance_update_period_range;

CREATE TABLE mgdw.Plex.accounting_balance_update_period_range (
	id int IDENTITY(1,1) NOT NULL,
	pcn int NULL,
	period_start int NULL,
	period_end int NULL,
	PRIMARY KEY (id)
);
select * from Plex.accounting_balance_update_period_range

select *
-- drop table Archive.accounting_balance
into Archive.accounting_balance 
--select count(*) 
from Plex.accounting_balance  -- 52,138

select * 
select distinct pcn,period
from Archive.accounting_balance order by pcn,period


update Plex.accounting_balance_update_period_range 
set period_start = 202104,
period_end = 202105
where pcn = 123681

update Plex.accounting_balance_update_period_range 
set period_start = 202106,
period_end = 202107
where pcn = 300758

/*
 * Create accounting_balance_delete_period procedure to delete records
 * which fall into the pcn ranges found in the Plex.accounting_balance_update_period_range records. 
 */
-- exec Plex.accounting_balance_delete_period_range
-- drop procedure Plex.accounting_balance_delete_period_range
create procedure Plex.accounting_balance_delete_period_range
as
begin
	declare @start_id int;
	declare @end_id int;
	select @start_id = min(id),@end_id = max(id) from Plex.accounting_balance_update_period_range
	declare @id int;
	set @id=@start_id;
	--select @start_id start_id,@end_id end_id,@id id
	-- select * from Plex.accounting_balance_update_period_range
	declare @pcn int;
	declare @period_start int;
	declare @period_end int;
	--	select @pcn=pcn,@period_start=period_start,@period_end=period_end from Plex.accounting_balance_update_period_range where id = 4
	while @id <=@end_id
	begin
		select @pcn=pcn,@period_start=period_start,@period_end=period_end from Plex.accounting_balance_update_period_range where id = @id
		print N'pcn=' + cast(@pcn as varchar(6)) + N',period_start=' + cast(@period_start as varchar(6)) + N', period_end=' + cast(@period_end as varchar(6))
		--select distinct pcn,period from Archive.accounting_balance order by pcn,period
		delete from Archive.accounting_balance WHERE pcn = @pcn and period between @period_start and @period_end
		set @id = @id+1;
	end 
end 

select distinct pcn,period from Plex.accounting_balance ab order by pcn,period

select 
DECLARE @CursorTestID INT = 1;
DECLARE @RunningTotal BIGINT = 0;
DECLARE @RowCnt BIGINT = 0;

-- get a count of total rows to process 
SELECT @RowCnt = COUNT(0) FROM dbo.CursorTest;
 
WHILE @CursorTestID <= @RowCnt
BEGIN
   UPDATE dbo.CursorTest 
   SET RunningTotal = @RunningTotal  + @CursorTestID
   WHERE CursorTestID = @CursorTestID;

   SET @RunningTotal += @CursorTestID
    
   SET @CursorTestID = @CursorTestID + 1 
 
END

/*
 * Create a procedure to record pcn,account_no, year, category, and revenue_or_expense value.
 * What category do we use?  
 */

create procedure Plex.account_period_balance_create
as
begin
/*
 * What will be the starting period? 3 periods ago.
 */
/*
 * What is the latest period in accounting _v_balance?
 */
declare @latest_period int;

select @latest_period = max(period) 

from Plex.accounting_balance b
where b.pcn = 123681
--select @current_period current_period, @latest_period latest_period
/*
 * How many records in the last 6 periods
 */
select count(*)
from Plex.accounting_balance b
where b.pcn = 123681
and b.period between 202106 and 202110 -- 1,278

/*
select 
@current_period current_period,
(@current_period - 3) period_min_3,
(((@current_period/100)-1) * 100) + 12, 
(((@current_period/100)-1) * 100) + 11, 
(((@current_period/100)-1) * 100) + 10 
*/
/*
 * Max fiscal period previous year
 */

declare @prev_year_max_fiscal_period int
select @prev_year_max_fiscal_period=(max_fiscal_period%100) 
from Plex.max_fiscal_period m
where m.pcn = 123681
--and m.[year] = 2010
and m.[year] =  ((@current_period/100)-1);

--select @prev_year_max_fiscal_period
/*
 * 3 periods ago?
 */
/*
select 
case 
when ((@current_period%100) - 3) >= 1 then (@current_period - 3) 
when ((@current_period%100) - 3) = 0 then (((@current_period/100)-1) * 100) + @prev_year_max_fiscal_period
when ((@current_period%100) - 3) = -1 then (((@current_period/100)-1) * 100) + (@prev_year_max_fiscal_period-1)
when ((@current_period%100) - 3) = -2 then (((@current_period/100)-1) * 100) + (@prev_year_max_fiscal_period-2)
end start_period,
case 
when ((@current_period%100) - 2) >= 1 then (@current_period - 2) 
when ((@current_period%100) - 2) = 0 then (((@current_period/100)-1) * 100) + @prev_year_max_fiscal_period
when ((@current_period%100) - 2) = -1 then (((@current_period/100)-1) * 100) + (@prev_year_max_fiscal_period-1)
when ((@current_period%100) - 2) = -2 then (((@current_period/100)-1) * 100) + (@prev_year_max_fiscal_period-2)
end next_period,
p.*
from Plex.accounting_period p
where pcn = 123681  -- 200601 to > 204103
*/
declare @start_period int 
set @start_period = 
	case 
	when ((@current_period%100) - 3) >= 1 then (@current_period - 3) 
	when ((@current_period%100) - 3) = 0 then (((@current_period/100)-1) * 100) + @prev_year_max_fiscal_period
	when ((@current_period%100) - 3) = -1 then (((@current_period/100)-1) * 100) + (@prev_year_max_fiscal_period-1)
	when ((@current_period%100) - 3) = -2 then (((@current_period/100)-1) * 100) + (@prev_year_max_fiscal_period-2)
	end;
declare @next_period int 
set @next_period =
	case 
	when ((@current_period%100) - 2) >= 1 then (@current_period - 2) 
	when ((@current_period%100) - 2) = 0 then (((@current_period/100)-1) * 100) + @prev_year_max_fiscal_period
	when ((@current_period%100) - 2) = -1 then (((@current_period/100)-1) * 100) + (@prev_year_max_fiscal_period-1)
	when ((@current_period%100) - 2) = -2 then (((@current_period/100)-1) * 100) + (@prev_year_max_fiscal_period-2)
	end;
--select @start_period,@next_period
	--drop view Plex.account_period_balance_low_view
with account_period(pcn,account_key,account_no,period,next_period)
as 
(
	-- anchor member
	select 
	a.pcn,
	a.account_key,
	a.account_no,
	@start_period period,
	@next_period next_period
	--m.max_fiscal_period
	
	--select count(*) cnt
	--select *
	--select distinct a.pcn,a.start_period 
	from Plex.accounting_account a  -- 18,015
	where a.pcn = 123681  -- 4,363 a low account was added 
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
    from account_period p
	join Plex.max_fiscal_period m 
    on p.pcn=m.pcn
    and (p.period/100) = m.[year]
	join Plex.max_fiscal_period n 
    on p.pcn=n.pcn
    and (p.next_period/100) = n.[year]
    --where p.period < 202111
   where p.period < @current_period
),
--select count(*) from account_period  -- 4,363 * 4 = 17,452
account_period_balance( pcn,account_key,account_no,period,next_period,debit,credit,balance)
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
	FROM account_period a -- 198,110
	-- select * from Plex.accounting_balance b
	left outer join Plex.accounting_balance b  
	on a.pcn=b.pcn
	and a.account_no = b.account_no
	and a.period=b.period
)
--SELECT count(*) FROM   account_period_balance -- 4,363 * 4 = 17,452
SELECT * FROM   account_period_balance -- 4,363 * 4 = 17,452
end

CREATE TABLE Plex.account_period_balance_append(
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

insert into Plex.account_period_balance_append
exec Plex.account_period_balance_create

select * from Plex.account_period_balance_append


create procedure Plex.calc_ytd
as
begin
/*
 * What will be the starting period? 3 periods ago.
 */
declare @todays_date datetime;
set @todays_date = getdate();
--select @todays_date;
/*
 * What period is it today?
 */
declare @current_period int;

select @current_period = period 
--select pcn,year(begin_date) year,period,* 
--select distinct pcn,period
from Plex.accounting_period p
where pcn = 123681  -- 200601 to > 204103
and @todays_date between p.begin_date and p.end_date 

--select @current_period

declare @prev_year_max_fiscal_period int
select @prev_year_max_fiscal_period=(max_fiscal_period%100) 
from Plex.max_fiscal_period m
where m.pcn = 123681
--and m.[year] = 2010
and m.[year] =  ((@current_period/100)-1);

--select @prev_year_max_fiscal_period
/*
 * 3 periods ago?
 */
declare @start_period int 
set @start_period = 
	case 
	when ((@current_period%100) - 3) >= 1 then (@current_period - 3) 
	when ((@current_period%100) - 3) = 0 then (((@current_period/100)-1) * 100) + @prev_year_max_fiscal_period
	when ((@current_period%100) - 3) = -1 then (((@current_period/100)-1) * 100) + (@prev_year_max_fiscal_period-1)
	when ((@current_period%100) - 3) = -2 then (((@current_period/100)-1) * 100) + (@prev_year_max_fiscal_period-2)
	end;
declare @next_period int 
set @next_period =
	case 
	when ((@current_period%100) - 2) >= 1 then (@current_period - 2) 
	when ((@current_period%100) - 2) = 0 then (((@current_period/100)-1) * 100) + @prev_year_max_fiscal_period
	when ((@current_period%100) - 2) = -1 then (((@current_period/100)-1) * 100) + (@prev_year_max_fiscal_period-1)
	when ((@current_period%100) - 2) = -2 then (((@current_period/100)-1) * 100) + (@prev_year_max_fiscal_period-2)
	end;
--select @start_period,@next_period
with calc_ytd (pcn,period,next_period,account_no,debit,ytd_debit,credit,ytd_credit,balance,ytd_balance)
as
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
	from Plex.account_period_balance_append b  -- 34,508,
	join Plex.accounting_account a  -- 34,508 
	on b.pcn=a.pcn
	and b.account_key=a.account_key
	-- Only get 1 balance record for each account.  That is the balance record with the 1st period for the account.
	where b.period = @start_period  -- 376  
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
    from calc_ytd y
    -- join the calc_ytd_low record with the accounts next account_period_balance_low record and 
    -- create a new calc_ytd_low record for this next period.
    --select * from Plex.account_period_balance_low b  -- 37970
    --select count(*) from Plex.account_period_balance_low b  -- 37970
    --select distinct next_period from Plex.account_period_balance_low b order by next_period  -- 200702 to 202111
    --select distinct period from Plex.account_period_balance_low b order by period  -- 200701 to 202110
--    inner join Plex.account_period_balance b 
    inner join Plex.account_period_balance_append b 
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
   	where y.period < @current_period
)
-- references expression name
--SELECT count(*) FROM   calc_ytd-- OPTION (MAXRECURSION 210);  -- 34,508
SELECT pcn,period,next_period,account_no,debit,ytd_debit,credit,ytd_credit,balance,ytd_balance FROM calc_ytd
end

exec Plex.calc_ytd

/*
 * Make backup of Plex.accounting_balance before appending records to it 
 */

create schema Archive

select *
--select distinct pcn,period -- 200812 to 202110
--select count(*)  -- 52,138
from Archive.account_balance_12_21 b
--from Plex.accounting_balance b
where b.pcn = 123681  -- 40,698
and b.period = 202110
order by period 


