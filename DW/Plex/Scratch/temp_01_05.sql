declare @pcn int;
declare @period_start int;
declare @period_end int;
declare @period int;
declare @max_fiscal_period int;

declare @id int;
declare @min_id int;
declare @max_id int;

declare @prev_period int;
declare @first_period int;

declare @cnt int
/*
select * 
into Scratch.accounting_balance_update_period_range
from Plex.accounting_balance_update_period_range r
update Plex.accounting_balance_update_period_range
set period_start=202002 
where id=20
 */
-- select * from Plex.accounting_balance_update_period_range r

-- select * from Scratch.accounting_balance_update_period_range r
select @min_id = min(id),@max_id=max(id) from Plex.accounting_balance_update_period_range r 
set @id = @min_id;

select @pcn=r.pcn,@period_start=r.period_start, @period=r.period_start,@period_end=r.period_end,
@max_fiscal_period=m.max_fiscal_period
from Plex.accounting_balance_update_period_range r
inner join Plex.max_fiscal_period m 
on r.pcn=m.pcn
and (r.period_start/100) = m.[year]
where id = @min_id;

--select distinct pcn,period from Plex.account_period_balance b
-- delete Plex.account_period_balance where pcn=123681 and period=202102
select @prev_period=max(b.period)
from Plex.account_period_balance b
where b.pcn = @pcn

--set @period=202101;
if @period%100 = 1 
begin
	set @first_period=1;
end 
else 
begin 
	set @first_period=0;
end

select @pcn pcn,@prev_period prev_period,@period_start period_start,@first_period first_period,@period_end period_end,@period period,@max_fiscal_period max_fiscal_period,@min_id min_id,@max_id max_id,@id id



while @id <= @max_id
begin
     print '@pcn=' + cast(@pcn as varchar(6)) 
     + ',@period_start=' + cast(@period_start as varchar(6))
     + ',@period_end=' + cast(@period_end as varchar(6)) 
     + ',@period=' + cast(@period as varchar(6))
     + ',@first_period=' + cast(@first_period as varchar(1))
     + ',@max_fiscal_period=' + cast(@max_fiscal_period as varchar(6))
     --+ ',@min_id=' + cast(@min_id as varchar(2))
     --+ ',@max_id=' + cast(@max_id as varchar(2))
     + ',@id=' + cast(@id as varchar(2));

    while @period <= @period_end
    begin
	    print '@period=' + cast(@period as varchar(6) )
	   	+ '@first_period=' + cast(@first_period as varchar(1));
		with period_balance(pcn,account_no,period,debit,credit,balance)
--		with account_period(pcn,account_no,period)
		as 
		(
		    select 
		    a.pcn,
		    a.account_no,
			@period period,
			case 
			when b.debit is null then 0 
			else b.debit 
			end debit,
			case 
			when b.credit is null then 0 
			else b.credit 
			end credit,
			case 
			when b.balance is null then 0 
			else b.balance 
			end balance
		    -- select count(*) from Plex.accounting_account where pcn = 123681  -- 4,363
			from Plex.accounting_account a   
			left outer join Plex.accounting_balance b 
			on a.pcn=b.pcn 
			and a.account_no=b.account_no 
			and b.period = @period
			where a.pcn = @pcn  
		),
		--select @cnt=count(*) from period_balance;
		--print '@cnt=' + cast(@cnt as varchar(4));
account_period_balance(pcn,account_no,period,period_display,debit,ytd_debit,credit,ytd_credit,balance,ytd_balance)
--,ending_period,ending_ytd_debit,ending_ytd_credit,ending_ytd_balance,next_period)
as 
(	
--select * from Plex.accounting_period ap where pcn = 300758
	select b.pcn,b.account_no,b.period,ap.period_display,
	case 
	when b.debit is null then 0
	else b.debit
	end debit,
	cast(
		case 
		when (@first_period=0) and (a.revenue_or_expense = 1) and (b.debit is null) then p.ytd_debit 
		when (@first_period=0) and (a.revenue_or_expense = 1) and (b.debit is not null) then p.ytd_debit + b.debit 
		when (@first_period=0) and (a.revenue_or_expense = 0) and (b.debit is null) then p.ytd_debit 
		when (@first_period=0) and (a.revenue_or_expense = 0) and (b.debit is not null) then p.ytd_debit + b.debit
		when (@first_period=1) and (a.revenue_or_expense = 1) and (b.debit is null) then 0 
		when (@first_period=1) and (a.revenue_or_expense = 1) and (b.debit is not null) then b.debit 
		when (@first_period=1) and (a.revenue_or_expense = 0) and (b.debit is null) then p.ytd_debit 
		when (@first_period=1) and (a.revenue_or_expense = 0) and (b.debit is not null) then p.ytd_debit + b.debit 
		end as decimal(19,5) 
	) ytd_debit, 
	case 
	when b.credit is null then 0
	else b.credit
	end credit,
	cast(
		case 
		when (@first_period=0) and (a.revenue_or_expense = 1) and (b.credit is null) then p.ytd_credit 
		when (@first_period=0) and (a.revenue_or_expense = 1) and (b.credit is not null) then p.ytd_credit + b.credit 
		when (@first_period=0) and (a.revenue_or_expense = 0) and (b.credit is null) then p.ytd_credit 
		when (@first_period=0) and (a.revenue_or_expense = 0) and (b.credit is not null) then p.ytd_credit + b.credit
		when (@first_period=1) and (a.revenue_or_expense = 1) and (b.credit is null) then 0 
		when (@first_period=1) and (a.revenue_or_expense = 1) and (b.credit is not null) then b.credit 
		when (@first_period=1) and (a.revenue_or_expense = 0) and (b.credit is null) then p.ytd_credit 
		when (@first_period=1) and (a.revenue_or_expense = 0) and (b.credit is not null) then p.ytd_credit + b.credit 
		end as decimal(19,5)
	) ytd_credit, 	
	case 
	when b.balance is null then 0
	else b.balance
	end balance,
	cast(
		case 
		when (@first_period=0) and (a.revenue_or_expense = 1) and (b.balance is null) then p.ytd_balance 
		when (@first_period=0) and (a.revenue_or_expense = 1) and (b.balance is not null) then p.ytd_balance + b.balance 
		when (@first_period=0) and (a.revenue_or_expense = 0) and (b.balance is null) then p.ytd_balance 
		when (@first_period=0) and (a.revenue_or_expense = 0) and (b.balance is not null) then p.ytd_balance + b.balance
		when (@first_period=1) and (a.revenue_or_expense = 1) and (b.balance is null) then 0 
		when (@first_period=1) and (a.revenue_or_expense = 1) and (b.balance is not null) then b.balance 
		when (@first_period=1) and (a.revenue_or_expense = 0) and (b.balance is null) then p.ytd_balance 
		when (@first_period=1) and (a.revenue_or_expense = 0) and (b.balance is not null) then p.ytd_balance + b.balance 
		end as decimal(19,5)
	) ytd_balance	
	-- below this line is columns used for debugging.
--	n.ending_period,p.ytd_debit ending_ytd_debit,p.ytd_credit ending_ytd_credit, p.balance ending_ytd_balance,n.next_period
	--select *
	from Plex.account_period_balance p
	-- select distinct pcn,period from Plex.accounting_balance b order by pcn,period (123681,200812,202111)
	inner join period_balance b 
	on p.pcn = b.pcn 
--	and p.period=b.period 
	and p.account_no = b.account_no 
	inner join Plex.accounting_period ap 
	on b.pcn=ap.pcn 
	and b.period=ap.period 
	inner join Plex.accounting_account_year_category_type a
	on p.pcn = a.pcn 
	and p.account_no =a.account_no
	and (p.period/100)=a.[year]
	where p.period = @prev_period

)
--select @cnt=count(*) from account_period_balance;  -- 4,363
--account_period_balance(pcn,account_no,period,period_display,debit,ytd_debit,credit,ytd_credit,balance,ytd_balance)
insert into Plex.account_period_balance
select pcn,account_no,period,period_display,debit,ytd_debit,credit,ytd_credit,balance,ytd_balance from account_period_balance;  -- 4,363

		print '@cnt=' + cast(@cnt as varchar(4));
		
	    if @period < @max_fiscal_period 
	    begin 
		    set @period=@period+1
		end 
		else 
		begin 
			set @period=((@period/100 + 1)*100) + 1 
		end 
		select @max_fiscal_period=m.max_fiscal_period
		from Plex.max_fiscal_period_view m 
		where m.pcn = @pcn 
		and m.year = @period/100

		if @period%100 = 1 
		begin
			set @first_period=1;
		end 
		else 
		begin 
			set @first_period=0;
		end
		
		
	end 

    set @id=@id+1;
 	select @pcn=r.pcn,@period_start=r.period_start,
 	@period=r.period_start,
 	@period_end=r.period_end,
 	@max_fiscal_period=m.max_fiscal_period 
	from Plex.accounting_balance_update_period_range r
	inner join Plex.max_fiscal_period_view m 
	on r.pcn=m.pcn
	and (r.period_start/100) = m.[year]
	where id = @id;
end 

-- pcn,account_no,period,period_display,debit,ytd_debit,credit,ytd_credit,balance,ytd_balance
--insert into Plex.account_period_balance
select pcn,account_no,period,period_display,debit,ytd_debit,credit,ytd_credit,balance,ytd_balance from account_period_balance;  -- 4,363
--select * from account_period_balance;  -- 4,363
-- select count(*) from Plex.account_period_balance apb 
-- 813-704-1772
-- 
-- select * from Plex.account_period_balance apb 
-- select distinct pcn,period from Plex.account_period_balance order by pcn,period 

