select * from Plex.account_period_balance 

-- drop procedure Plex.account_period_balance_recreate_period_range
create procedure Plex.account_period_balance_recreate_period_range
as 
begin

/*
 * Make a backup
 */
--select *
--into Archive.account_period_balance_01_07_2022 -- 160,655 
--from Plex.account_period_balance b order by pcn,period
-- select count(*) from Archive.account_period_balance_01_26_2022 

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
declare @anchor_period int;
declare @anchor_period_display varchar(7);

declare @cnt int
/*
select * 
--into Scratch.accounting_balance_update_period_range
from Plex.accounting_balance_update_period_range r

update Plex.accounting_balance_update_period_range
set period_start=202102,period_end=202112
where pcn=123681 -- southfield

update Plex.accounting_balance_update_period_range
set period_start=202002,period_end=202112
where pcn=300758 -- albion
select * from Plex.accounting_balance_update_period_range r
 */
-- select * from Plex.accounting_balance_update_period_range r

-- select * from Scratch.accounting_balance_update_period_range r
--select * from Plex.accounting_balance_update_period_range r 
-- update Plex.accounting_balance_update_period_range set period_end = 202201 where id in (6,7)
select @min_id = min(id),@max_id=max(id) from Plex.accounting_balance_update_period_range r 
set @id = @min_id;

select @pcn=r.pcn,@period_start=r.period_start, @period=r.period_start,@period_end=r.period_end,
@max_fiscal_period=m.max_fiscal_period
--select * from Plex.accounting_balance_update_period_range r
from Plex.accounting_balance_update_period_range r
inner join Plex.max_fiscal_period_view m 
on r.pcn=m.pcn
and (r.period_start/100) = m.[year]
where id = @min_id;
--select @pcn pcn,@period period,@period_start period_start,@period period ,@period_end period_end  
/* Don't automate this until 2022-02 when we have 1 years worth of valid periods
delete from 
Plex.account_period_balance 
where pcn=@pcn
and period between @period_start and @period_end

delete Plex.account_period_balance where  pcn = 300758
*/


--select count(*) from Plex.account_period_balance b --4,363/160,655
--select distinct pcn,period from Plex.account_period_balance b order by pcn,period
--select distinct pcn,period from Archive.account_period_balance_01_03_2022 b order by pcn,period -- 202101 - 202110
--select count(*) from Archive.account_period_balance_01_03_2022 -- 43,630
--select distinct pcn,period from Archive.account_period_balance_12_30 b order by pcn,period -- 202101 - 202110
--select count(*) from Archive.account_period_balance_12_30 -- 43,630
-- delete Plex.account_period_balance where  period between 202102 and 202111
-- delete Plex.account_period_balance where  pcn = 300758
/*
select * 
into Plex.account_period_balance_anchor  -- 4,363 Edon only
from Plex.account_period_balance
 */
select @prev_period=max(b.period)
from Plex.account_period_balance b
where b.pcn = @pcn
select @prev_period prev_period 
set @anchor_period = @prev_period;

select @anchor_period_display=p.period_display 
from Plex.accounting_period p 
where p.pcn = @pcn
and p.period = @anchor_period

--set @period=202101;
if @period%100 = 1 
begin
	set @first_period=1;
end 
else 
begin 
	set @first_period=0;
end
/*
are there any new accounts to add?
		select count(*)
		from Plex.accounting_account a   
		left outer join Plex.account_period_balance b 
		on a.pcn=b.pcn 
		and a.account_no=b.account_no 
		and b.period = @anchor_period
		where a.pcn = @pcn 
		and b.pcn is null
*/
/*
select @pcn pcn,@anchor_period anchor_period,@anchor_period_display anchor_period_display,
@period period,
@prev_period prev_period,@period_start period_start,
@first_period first_period,@period_end period_end,@period period,@max_fiscal_period max_fiscal_period,@min_id min_id,@max_id max_id,@id id

 print '@pcn=' + cast(@pcn as varchar(6)) 
 + ',@period_start=' + cast(@period_start as varchar(6))
 + ',@period_end=' + cast(@period_end as varchar(6)) 
 + ',@period=' + cast(@period as varchar(6))
 + ',@prev_period=' + cast(@prev_period as varchar(6))     
 + ',@anchor_period=' + cast(@anchor_period as varchar(6))     
 + ',@first_period=' + cast(@first_period as varchar(1))
 + ',@max_fiscal_period=' + cast(@max_fiscal_period as varchar(6))
 + ',@min_id=' + cast(@min_id as varchar(2))
 + ',@max_id=' + cast(@max_id as varchar(2))
 + ',@id=' + cast(@id as varchar(2));
*/

while @id <= @max_id
begin
    /*
     * Update the anchor period. Add records for new accounts.
     * select * from Plex.account_period_balance_anchor
     */
    -- delete from Plex.account_period_balance 
    --select count(*) from Plex.account_period_balance 
   -- select count(*) from Archive.account_period_balance_12_30 apb 
   -- where pcn=123681 and period=202101 and debit=0 and ytd_debit = 0 and credit = 0 and ytd_credit =0 and balance = 0 and ytd_balance =0  -- 3,815
    insert into Plex.account_period_balance 
	    select 
	    @pcn pcn,
	    a.account_no,
	    @anchor_period period,
	    @anchor_period_display period_display,
	    0 debit,
	    0 ytd_debit,
	    0 credit,
	    0 ytd_credit,
	    0 balance,
	    0 ytd_balance
	    -- select count(*) from Plex.accounting_account where pcn = 123681  -- 4,363/4,595
	    -- select distinct pcn,period from Plex.account_period_balance b order by pcn,period 
	    -- select count(*) from Plex.account_period_balance b where pcn = 123681 and period = 202103  -- 4,595
		from Plex.accounting_account a   
		left outer join Plex.account_period_balance b 
		on a.pcn=b.pcn 
		and a.account_no=b.account_no 
		and b.period = @anchor_period
		where a.pcn = @pcn 
		and b.pcn is null
			
    while @period <= @period_end
    begin
	    print '@period=' + cast(@period as varchar(6) )
	   	+ ', @first_period=' + cast(@first_period as varchar(1))
	   	+ ', @prev_period=' + cast(@prev_period as varchar(6))
	   	+ ', @max_fiscal_period=' + cast(@max_fiscal_period as varchar(6));
	   	-- THERE ARE MANY ACCOUNTS AND BALANCE SNAPSHOTS.
	   -- MAKE SURE THAT ACCOUNTS WITH NO ACTIVITY STILL SHOW UP ON THE REPORT.
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
		    -- select count(*) from Plex.accounting_account where pcn = 123681  -- 4,595/4,363
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
			from period_balance b  -- will contain all the accounts labled with just one period
			inner join Plex.account_period_balance p
			-- select * from Plex.account_period_balance p where p.period = 202101 
			-- select distinct pcn,period from Plex.accounting_balance b order by pcn,period (123681,200812,202111)
			--inner join period_balance b 
			on b.pcn = p.pcn 
		--	and p.period=b.period -- WHY IS THIS REMOVED?  because it's in the WHERE clause now and should be @prev_period not b.period.
			and b.account_no = p.account_no 
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
		
		set @prev_period = @period
		
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
	if @id <= @max_id
	begin
	 	select @pcn=r.pcn,@period_start=r.period_start,
	 	@period=r.period_start,
	 	@period_end=r.period_end,
	 	@max_fiscal_period=m.max_fiscal_period 
		from Plex.accounting_balance_update_period_range r
		inner join Plex.max_fiscal_period_view m 
		on r.pcn=m.pcn
		and (r.period_start/100) = m.[year]
		where id = @id;
	
		select @prev_period=max(b.period)
		from Plex.account_period_balance b
		where b.pcn = @pcn	
		
		-- if pcn has no account_period_balance records.
		if @prev_period is null 
		begin
			set @prev_period=202101
		end 
		set @anchor_period = @prev_period;		
		
	
		select @anchor_period_display=p.period_display 
		from Plex.accounting_period p 
		where p.pcn = @pcn
		and p.period = @anchor_period
	
		if @period%100 = 1 
		begin
			set @first_period=1;
		end 
		else 
		begin 
			set @first_period=0;
		end		
		select @pcn pcn,@anchor_period anchor_period,@anchor_period_display anchor_period_display,@prev_period prev_period,@period_start period_start,
		@first_period first_period,@period_end period_end,@period period,@max_fiscal_period max_fiscal_period,@min_id min_id,@max_id max_id,@id id
		
		 print '@pcn=' + cast(@pcn as varchar(6)) 
		 + ',@period_start=' + cast(@period_start as varchar(6))
		 + ',@period_end=' + cast(@period_end as varchar(6)) 
		 + ',@period=' + cast(@period as varchar(6))
		 + ',@prev_period=' + cast(@prev_period as varchar(6))     
		 + ',@anchor_period=' + cast(@anchor_period as varchar(6))     
		 + ',@first_period=' + cast(@first_period as varchar(1))
		 + ',@max_fiscal_period=' + cast(@max_fiscal_period as varchar(6))
		 + ',@min_id=' + cast(@min_id as varchar(2))
		 + ',@max_id=' + cast(@max_id as varchar(2))
		 + ',@id=' + cast(@id as varchar(2));

	end	
	
	
end 
end
-- pcn,account_no,period,period_display,debit,ytd_debit,credit,ytd_credit,balance,ytd_balance
--select * from account_period_balance;  -- 4,363
select count(*) from Plex.account_period_balance b -- 4,595*12=     45950+9190
where b.pcn=123681 
--and b.period = 202101 -- 4,595
--and b.period = 202112 -- 4,595
and b.period = 202112 -- 4,595
-- 813-704-1772
-- 
select * from Plex.account_period_balance apb where period = 202111
-- select distinct pcn,period from Plex.account_period_balance order by pcn,period 

/*
 * Format to be like CSV download
 */
--select * from Plex.accounting_account a where a.account_no = '10220-000-00000' 
declare @pcn int;
set @pcn = 123681;

exec Report.trial_balance 202202,202202
SELECT @@ROWCOUNT;  -- 4,595
exec Report.trial_balance 202201,202202
SELECT @@ROWCOUNT;   -- 9,190
exec Report.trial_balance 202201,202203
SELECT @@ROWCOUNT;   -- 9,190 + 4,595 =13,785

CREATE PROCEDURE Report.trial_balance
@start_period int,
@end_period int 
AS 
begin

select 
--b.period,
b.period_display,
a.category_type,
-- don't use legacy category type even though it is on the real TB report. I think it will be less confusing 
-- for the Southfield PCN which hass missing accounts.
-- b.category_type_legacy category_type,  
/*
 * The Plex TB report uses the category type of the category linked to the account via the  category_account view. 
 * I believe Plex now mostly uses the account category located directly on the accounting_v_account view so I used 
 * this column instead of the one linked via the account_category view. 
 */
a.category_name_legacy category_name,
a.sub_category_name_legacy sub_category_name,
a.account_no,
--a.account_no [no],
a.account_name,
b.balance current_debit_credit,
b.ytd_balance ytd_debit_credit
--select *
--select count(*)
--select distinct pcn,period from Plex.account_period_balance b order by pcn,period -- 123,681 (202101 to 202111)
--Yinto Archive.account_period_balance_03_22_2022 -- 115,374
from Plex.account_period_balance b -- 43,620
--where b.pcn = @pcn  -- 50,545
inner join Plex.accounting_account a -- 43,620
on b.pcn=a.pcn 
and b.account_no=a.account_no 
where b.pcn = 123681  -- 50,545,55,140
AND b.period BETWEEN @start_period AND @end_period
order by b.period_display,a.account_no 
--where a.category_type != a.category_type_legacy 
--where b.period_display is not NULL -- 40,940
--where b.period_display is NULL -- 40,940?
--where a.account_no = '10220-000-00000' 
END 

select * from ssis.ScriptComplete sc 

select 
--b.period,
b.period_display,
a.category_type,
-- don't use legacy category type even though it is on the real TB report. I think it will be less confusing 
-- for the Southfield PCN which hass missing accounts.
-- b.category_type_legacy category_type,  
/*
 * The Plex TB report uses the category type of the category linked to the account via the  category_account view. 
 * I believe Plex now mostly uses the account category located directly on the accounting_v_account view so I used 
 * this column instead of the one linked via the account_category view. 
 */
a.category_name_legacy category_name,
a.sub_category_name_legacy sub_category_name,
a.account_no,
--a.account_no [no],
a.account_name,
b.balance current_debit_credit,
b.ytd_balance ytd_debit_credit
--select count(*)
--select distinct pcn,period from Plex.account_period_balance b order by pcn,period -- 123,681 (202101 to 202111)
from Plex.account_period_balance b -- 43,620
--where b.pcn = @pcn  -- 50,545
inner join Plex.accounting_account a -- 43,620
on b.pcn=a.pcn 
and b.account_no=a.account_no 
where b.pcn = 123681  -- 50,545,55,140,64,330
--AND b.period = 202201  -- 4,595
--AND b.period = 202202  -- 4,595
and a.account_no = '12400-000-0000'
--and a.account_no='11010-000-0000'
--and a.account_no = '10220-000-00000' 
order by a.account_no,b.period 
--where a.category_type != a.category_type_legacy 
--where b.period_display is not NULL -- 40,940
--where b.period_display is NULL -- 40,940
