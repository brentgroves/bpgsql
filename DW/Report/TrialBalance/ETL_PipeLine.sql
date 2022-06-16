select count(*) from Plex.accounting_account  -- 19,286,19,176
select count(*) from Scratch.accounting_account_06_03  -- 19,286  -- 19,286,19,176

select count(*) from Plex.accounting_account_year_category_type aayct  -- 24,811, 24,767, 24,723
select count(*) from Scratch.accounting_account_year_category_type aayct  -- 24,811, 24,767, 24,723

select count(*) from Plex.accounting_period ap -- 1418
select count(*) from Scratch.accounting_period ap -- 1418
select * from Plex.accounting_period
where pcn = 123681 and period between 202201 and 202206 -- 2022-06-03 19:50:00.000
order by pcn,period 

select * from Plex.accounting_balance_update_period_range -- 202105/202204
select * from Scratch.accounting_balance_update_period_range -- 202105/202204

--exec Plex.accounting_balance_delete_period_range
select count(*) from Plex.accounting_balance ab -- 48,114,40,883
select count(*) from Scratch.accounting_balance ab -- 48,114, 48,023/ 47,546 / 46,926

--exec Plex.account_period_balance_delete_period_range
select count(*) from Plex.account_period_balance apb -- 140,713/41,293 132,428,123,659,131,900, 123,615
select count(*) from Scratch.account_period_balance apb -- 140,713/ 132,428,123,659,131,900, 123,615


--exec Scratch.account_period_balance_recreate_period_range
--exec Scratch.account_period_balance_recreate_period_range
select * 
-- select count(*)

--into Scratch.account_period_balance
from Scratch.account_period_balance  -- 68,995
select distinct pcn,period from Scratch.account_period_balance order by pcn,period  -- 41,293
--select distinct pcn,period from Plex.account_period_balance order by pcn,period  -- 41,293


select * from Scratch.accounting_balance_update_period_range
exec Scratch.account_period_balance_delete_period_range
WAITFOR DELAY '00:00:30'
as
begin
	declare @start_id int;
	declare @end_id int;
	select @start_id = min(id),@end_id = max(id) from Scratch.accounting_balance_update_period_range

--select count(*) from Plex.account_period_balance -- 140,713
--select * from Plex.accounting_balance_update_period_range
--select * from Scratch.accounting_balance_update_period_range
--delete from Scratch.account_period_balance WHERE pcn in (123681,300758) and period between 202106 and 202205

-- drop table Scratch.accounting_balance
-- truncate table Scratch.accounting_balance
select * 
-- select count(*)
--into Scratch.accounting_balance
--from mgdw.Scratch.accounting_balance  --48,113
from mgdw.Plex.accounting_balance -- 48,113
--delete from Scratch.accounting_balance WHERE pcn in (123681,300758) and period between 202106 and 202205
-- truncate TABLE mgdw.Plex.accounting_balance_update_period_range;
select * from Scratch.accounting_balance_update_period_range
select * 
--into Archive.accounting_balance_update_period_range
from Scratch.accounting_balance_update_period_range 
where pcn in (123681,300758)

-- drop table Scratch.accounting_account_year_category_type  -- 8,285
select *
-- select distinct pcn,year 
--select count(*)
--into Scratch.accounting_account_year_category_type  -- 
--from Plex.accounting_account_year_category_type  -- 
from Scratch.accounting_account_year_category_type  -- 
--order by pcn,year
where pcn in (123681,300758)
and [year] in (2022)  -- 8,285
--and [year] in (2021)  -- 8,285
--and [year] in (2021,2022)  -- 16,570

-- truncate table  Scratch.accounting_account_06_03
select *
--select count(*)
from Scratch.accounting_account_06_03  -- 19,286


-- truncate table Scratch.accounting_period  
select *
--into Archive.accounting_period_2022_03_21 -- 1,346
-- select count(*)
from Scratch.accounting_period ap -- 1,418
where period between 202201 and 202205
and pcn = 123681
where period_key = 167272

2022-04-29 15:45:00.000
2022-04-29 15:49:00.000
2022-04-29 15:55:00.000
2022-05-18 13:55:00.000
2022-06-13 08:35:00.000

select *
--into Archive.accounting_period_2022_03_21 -- 1,346
-- select count(*)
from Plex.accounting_period ap -- 1,418
where period between 202201 and 202205
and pcn = 123681

2022-04-29 15:45:00.000
2022-04-29 15:49:00.000
2022-04-29 15:55:00.000
2022-05-18 13:55:00.000
2022-06-13 08:35:00.000

select * 
--into Archive.Script_History_06_06
from ETL.Script_History sh 
where Script_Key in (1,3,4,5,6,116,117)
and Start_Time > '2022-06-15' 
order by Script_History_Key desc
-- delete from ETL.Script_History
where Script_Key in (1,3,4,5,6,116,117)
and Start_Time > '2022-06-15' 

select * from ETL.Script s 
-- mgdw.Plex.accounting_balance definition

-- select * from Plex.max_fiscal_period_view 
-- select * from Scratch.max_fiscal_period_view 

create view Scratch.max_fiscal_period_view(pcn,year,max_fiscal_period)
	as
	WITH fiscal_period(pcn,year,period)
	as
	(
		select pcn,year(begin_date) year,period from Scratch.accounting_period --where pcn = 123681
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
	select * from max_fiscal_period;

exec Scratch.account_period_balance_recreate_period_range

-- drop procedure Scratch.account_period_balance_recreate_period_range

-- drop procedure Plex.account_period_balance_recreate_period_range
--create procedure Plex.account_period_balance_recreate_period_range
-- drop procedure Scratch.account_period_balance_recreate_period_range
create procedure Scratch.account_period_balance_recreate_period_range
as 
begin
SET NOCOUNT ON;
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
select @min_id = min(id),@max_id=max(id) from Scratch.accounting_balance_update_period_range r 
set @id = @min_id;

select @pcn=r.pcn,@period_start=r.period_start, @period=r.period_start,@period_end=r.period_end,
@max_fiscal_period=m.max_fiscal_period
--select * from Plex.accounting_balance_update_period_range r
from Scratch.accounting_balance_update_period_range r
inner join Scratch.max_fiscal_period_view m 
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
--select distinct pcn,period from Scratch.account_period_balance b order by pcn,period

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
from Scratch.account_period_balance b
where b.pcn = @pcn
--select @prev_period prev_period 
set @anchor_period = @prev_period;

select @anchor_period_display=p.period_display 
from Scratch.accounting_period p 
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
*/
/*
select @pcn pcn,@anchor_period anchor_period,@anchor_period_display anchor_period_display,
@period period,
@prev_period prev_period,@period_start period_start,
@first_period first_period,@period_end period_end,@period period,@max_fiscal_period max_fiscal_period,@min_id min_id,@max_id max_id,@id id
*/
/*
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
	 * Add new account records to Plex.accounting_account_year_category_type 
	 * for the @anchor_period's year if not already added.
	 */
	with account_year_category_type
	as
	(
		select a.*
		-- select count(*)
		from Scratch.accounting_account_06_03 a  
		--where a.pcn=123681 -- 4,617
		inner join Scratch.accounting_account_year_category_type y
		on a.pcn = y.pcn 
		and a.account_no =y.account_no
		where y.[year] = (@prev_period/100) 
		and a.pcn = @pcn
	),
	--select count(*) from account_year_category_type  -- 4,595
	add_account_year_category_type
	as 
	( 	select a.*
		from Scratch.accounting_account_06_03 a  
		left outer join account_year_category_type y 
		on a.pcn = y.pcn 
		and a.account_no =y.account_no
		where y.pcn is null -- there is no account_year_category_type records for the @prev_period year so we must add them.
		and a.pcn = @pcn
	)
	--	select * from add_account_year_category_type	-- 22
	/*
	 * backup Plex.accounting_account_year_category_type
	SELECT * 
	--INTO Archive.accounting_account_year_category_type -- 24767
	FROM Scratch.accounting_account_year_category_type
	 */
	
	INSERT INTO Scratch.accounting_account_year_category_type (pcn,account_no,YEAR,category_type,revenue_or_expense)
		select y.pcn,y.account_no,(@prev_period/100) year,y.category_type,y.revenue_or_expense	
		from Scratch.accounting_account_year_category_type y
		where y.[year] = (@period_end/100) -- there is no account_year_category_type records for the @prev_period year so we must add them.
		and y.pcn = @pcn
		and y.account_no in 
		( 
			select account_no from add_account_year_category_type
		)

	/*
     * Update the anchor period. Add records for new accounts.
     * select * from Plex.account_period_balance_anchor
     */
    -- delete from Plex.account_period_balance 
    --select count(*) from Plex.account_period_balance 
   -- select count(*) from Archive.account_period_balance_12_30 apb 
   -- where pcn=123681 and period=202101 and debit=0 and ytd_debit = 0 and credit = 0 and ytd_credit =0 and balance = 0 and ytd_balance =0  -- 3,815
    insert into Scratch.account_period_balance 
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
	    -- select count(*) from Plex.account_period_balance b where pcn = 123681 and period = 202101  -- 4,595
		from Scratch.accounting_account_06_03 a   
		left outer join Scratch.account_period_balance b 
		on a.pcn=b.pcn 
		and a.account_no=b.account_no 
		and b.period = @anchor_period
		where a.pcn = @pcn 
		and b.pcn is null
			
    while @period <= @period_end
    begin
--	    print '@period=' + cast(@period as varchar(6) )
--	   	+ ', @first_period=' + cast(@first_period as varchar(1))
--	   	+ ', @prev_period=' + cast(@prev_period as varchar(6))
--	   	+ ', @max_fiscal_period=' + cast(@max_fiscal_period as varchar(6));
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
			from Scratch.accounting_account_06_03 a   
			left outer join Scratch.accounting_balance b 
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
			inner join Scratch.account_period_balance p
			-- select * from Plex.account_period_balance p where p.period = 202101 
			-- select distinct pcn,period from Plex.accounting_balance b order by pcn,period (123681,200812,202111)
			--inner join period_balance b 
			on b.pcn = p.pcn 
		--	and p.period=b.period -- WHY IS THIS REMOVED?  because it's in the WHERE clause now and should be @prev_period not b.period.
			and b.account_no = p.account_no 
			inner join Scratch.accounting_period ap 
			on b.pcn=ap.pcn 
			and b.period=ap.period 
			inner join Scratch.accounting_account_year_category_type a
			on p.pcn = a.pcn 
			and p.account_no =a.account_no
			and (p.period/100)=a.[year]
			where p.period = @prev_period  
		
		)
		--select @cnt=count(*) from account_period_balance;  -- 4,363
		--account_period_balance(pcn,account_no,period,period_display,debit,ytd_debit,credit,ytd_credit,balance,ytd_balance)
		insert into Scratch.account_period_balance
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
		from Scratch.max_fiscal_period_view m 
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
		from Scratch.accounting_balance_update_period_range r
		inner join Scratch.max_fiscal_period_view m 
		on r.pcn=m.pcn
		and (r.period_start/100) = m.[year]
		where id = @id;
	
		select @prev_period=max(b.period)
		from Scratch.account_period_balance b
		where b.pcn = @pcn	
		
		-- if pcn has no account_period_balance records.
		if @prev_period is null 
		begin
			set @prev_period=202101
		end 
		set @anchor_period = @prev_period;		
		
	
		select @anchor_period_display=p.period_display 
		from Scratch.accounting_period p 
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
/*
		select @pcn pcn,@anchor_period anchor_period,@anchor_period_display anchor_period_display,@prev_period prev_period,@period_start period_start,
		@first_period first_period,@period_end period_end,@period period,@max_fiscal_period max_fiscal_period,@min_id min_id,@max_id max_id,@id id
		*/
/*		
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
	end	
	
	
end 
end;


create procedure Scratch.account_period_balance_delete_period_range
as
begin
	declare @start_id int;
	declare @end_id int;
	select @start_id = min(id),@end_id = max(id) from Scratch.accounting_balance_update_period_range
	-- select * from Plex.accounting_balance_update_period_range
	declare @id int;
	set @id=@start_id;
	--select @start_id start_id,@end_id end_id,@id id
	--select * from Plex.accounting_balance_update_period_range
	declare @pcn int;
	declare @period_start int;
	declare @period_end int;
--	select @pcn=pcn,@period_start=period_start,@period_end=period_end from Plex.accounting_balance_update_period_range where id = 6
--	select @id id,@pcn pcn,@period_start period_start,@period_end period_end
--	select @pcn=pcn,@period_start=period_start,@period_end=period_end from Scratch.accounting_balance_update_period_range where id = 7
-- select * from Scratch.accounting_balance_update_period_range
--	select @end_id end_id,@pcn pcn,@period_start period_start,@period_end period_end
	
	while @id <=@end_id
	begin
		select @pcn=pcn,@period_start=period_start,@period_end=period_end from Scratch.accounting_balance_update_period_range where id = @id
		--print N'pcn=' + cast(@pcn as varchar(6)) + N',period_start=' + cast(@period_start as varchar(6)) + N', period_end=' + cast(@period_end as varchar(6))
		--select distinct pcn,period from Archive.account_period_balance_01_26_2022 order by pcn,period
		--select distinct pcn,period from Plex.account_period_balance order by pcn,period
		-- select count(*) from Plex.account_period_balance 4,595
		delete from Scratch.account_period_balance WHERE pcn = @pcn and period between @period_start and @period_end
--		delete from Archive.account_period_balance WHERE pcn = @pcn and period between @period_start and @period_end
		set @id = @id+1;
	end 
end;


-- mgdw.Plex.account_period_balance definition

-- Drop table

-- DROP TABLE mgdw.Scratch.account_period_balance;

select * 
--into Scratch.account_period_balance
from Plex.account_period_balance

CREATE TABLE mgdw.Scratch.account_period_balance (
	pcn int NULL,
	account_no varchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	period int NULL,
	period_display varchar(7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	debit decimal(19,5) NULL,
	ytd_debit decimal(19,5) NULL,
	credit decimal(19,5) NULL,
	ytd_credit decimal(19,5) NULL,
	balance decimal(19,5) NULL,
	ytd_balance decimal(19,5) NULL
);

-- Drop table

-- DROP TABLE mgdw.Scratch.accounting_balance;
select * 
--into mgdw.Scratch.accounting_balance
from mgdw.Scratch.accounting_balance
CREATE TABLE mgdw.Scratch.accounting_balance (
	pcn int NOT NULL,
	account_key int NOT NULL,
	account_no varchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	period int NOT NULL,
	debit decimal(19,5) NULL,
	credit decimal(19,5) NULL,
	balance decimal(19,5) NULL,
	CONSTRAINT PK__Scratch_accounting__balance PRIMARY KEY (pcn,account_key,period)
);
INSERT INTO Scratch.accounting_balance
(pcn, account_key, account_no, period, debit, credit, balance)
VALUES(0, 0, '', 0, 0, 0, 0);


select * 
--into Archive.account_balance_06_10 -- 
from Scratch.accounting_balance ab 

select * 
--into Archive.account_balance_06_10 -- 
from Plex.accounting_balance ab 

create procedure Scratch.accounting_balance_delete_period_range
as
begin
	declare @start_id int;
	declare @end_id int;
	select @start_id = min(id),@end_id = max(id) from Scratch.accounting_balance_update_period_range
	-- select * from Plex.accounting_balance_update_period_range
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
		select @pcn=pcn,@period_start=period_start,@period_end=period_end from Scratch.accounting_balance_update_period_range where id = @id
	--	print N'pcn=' + cast(@pcn as varchar(6)) + N',period_start=' + cast(@period_start as varchar(6)) + N', period_end=' + cast(@period_end as varchar(6))
		--select distinct pcn,period from Archive.accounting_balance order by pcn,period
		delete from Scratch.accounting_balance WHERE pcn = @pcn and period between @period_start and @period_end
--		delete from Archive.accounting_balance WHERE pcn = @pcn and period between @period_start and @period_end
		set @id = @id+1;
	end 
end;


-- mgdw.Plex.accounting_balance_update_period_range definition

-- Drop table

-- DROP TABLE mgdw.Plex.accounting_balance_update_period_range;
-- truncate TABLE mgdw.Plex.accounting_balance_update_period_range;
CREATE TABLE mgdw.Plex.accounting_balance_update_period_range (
	id int IDENTITY(1,1) NOT NULL,
	pcn int NULL,
	period_start int NULL,
	period_end int NULL,
	CONSTRAINT PK__accounti__3213E83F2CF7C4AE PRIMARY KEY (id)
);
select * from Plex.accounting_balance_update_period_range
insert into Plex.accounting_balance_update_period_range (pcn,period_start,period_end) 
      values (123681,202106,202205)

-- mgdw.Plex.accounting_period definition

-- Drop table

-- DROP TABLE mgdw.Scratch.accounting_period;
declare @dt datetime= '1900-01-01';
CREATE TABLE Scratch.accounting_period (
	pcn int NOT NULL,
	period_key int NOT NULL,
	period int NULL,
	fiscal_order int NULL,
	begin_date datetime NULL,
	end_date datetime NULL,
	period_display varchar(7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	quarter_group tinyint NULL,
	period_status int null,
	add_date datetime null,
	update_date datetime null,
	CONSTRAINT PK__accounting_period PRIMARY KEY (pcn,period_key)
);
select *
--into Scratch.accounting_period  -- 1418
from Plex.accounting_period ap 
where add_date = '2012-03-19 15:06:07.360'
2012-03-19 15:06:07.360
--where add_date = '2012-03-19 15:06:07.360000000'
-- truncate table Scratch.accounting_period  
select *
--into Archive.accounting_period_2022_03_21 -- 1,346
-- select count(*)
from Scratch.accounting_period ap -- 1,418
where period between 202201 and 202205
and pcn = 123681
where period_key = 167272

    im2='''insert into Scratch.accounting_period (pcn,period_key,period,period_display,fiscal_order,quarter_group,
									  			  begin_date,end_date,period_status,add_date, update_date) 
    		values (?,?,?,?,?,?,?,?,?,?,?)''' 
--values (123681,45758,200601,1,'2006-01-01 00:00:00.000','2006-01-31 00:00:00.000','01-2006',1,0,'1900-01-01 00:00:00.000','2009-09-02 16:13:00.000')
--	   (123681,45758,200601, '01-2006', 1, 1, '2006-01-01 00:00:00', '2006-01-31 23:59:59', 0, None, '2009-09-02 16:13:00')
--drop procedure Report.accounting_period
insert into Scratch.t1
exec Report.accounting_period 202201,202203
create procedure Report.accounting_period
@start_period int,
@end_period int
as 
select 
period,
period_display,
begin_date,
end_date,
case 
	when period_status = 1 then 'Active'
	else 'Closed'
end status,
update_date updated 
from Plex.accounting_period
where period between @start_period and @end_period
and pcn = 123681
order by pcn,period desc 



-- mgdw.Plex.accounting_account_year_category_type definition

-- Drop table

-- DROP TABLE mgdw.Scratch.accounting_account_year_category_type;

CREATE TABLE mgdw.Plex.accounting_account_year_category_type (
	id int IDENTITY(1,1) NOT NULL,
	pcn int NULL,
	account_no varchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[year] int NULL,
	category_type varchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	revenue_or_expense bit NULL,
	CONSTRAINT PK__accounti__3213E83FF126C7A5 PRIMARY KEY (id),
	CONSTRAINT UQ__accounti__22DAE7B5B1F76486 UNIQUE (pcn,account_no,[year])
);
CREATE UNIQUE NONCLUSTERED INDEX UQ__accounti__22DAE7B5B1F76486 ON mgdw.Plex.accounting_account_year_category_type (pcn, account_no, [year]);

-- truncate table Scratch.accounting_account_year_category_type
select *
--select count(*)
from Scratch.accounting_account_year_category_type  -- 8,285
where pcn in (123681,300758)
and [year] = 2022  -- 8,285


--insert into Scratch.accounting_account_year_category_type (pcn,account_no,[year],category_type,revenue_or_expense)
values(123681,10000-000-00000,2022,'Asset',0)

Scratch.accounting_account_year_category_type 

select * 
--into Scratch.accounting_account_year_category_type  -- 24,811
--select count(*)
from Plex.accounting_account_year_category_type
where pcn in (123681,300758)
and [year] = 2022  -- 8,285

--drop TABLE mgdw.Scratch.accounting_account_06_03 
CREATE TABLE mgdw.Scratch.accounting_account_06_03 (
	pcn int NOT NULL,
	account_key int NOT NULL,
	account_no varchar(20),
	account_name varchar(110),
	active bit NULL,
	category_type varchar(10),
	category_no_legacy int NULL,
	category_name_legacy varchar(50),
	category_type_legacy varchar(10),
	sub_category_no_legacy int,
	sub_category_name_legacy varchar(50),
	sub_category_type_legacy varchar(10),
	revenue_or_expense bit NULL,
	start_period int NULL,
	PRIMARY KEY (pcn,account_key)
);
-- truncate table  Scratch.accounting_account_06_03
select *
--select count(*)
from Scratch.accounting_account_06_03
select * 
--into Scratch.accounting_account_06_03
select count(*)
from Plex.accounting_account aa -- 19,286
where pcn in (123681) -- 4617
where account_key = 400825 

select * from ETL.Script s where script_key = 1
select * from ETL.Script_History sh where script_key = 1
order by end_time desc 
--truncate table Scratch.accounting_account_06_03
--delete from Scratch.accounting_account_06_03 where pcn in (99999)
select distinct(pcn) from Scratch.accounting_account_06_03
select count(*) from Scratch.accounting_account_06_03
--set @PCNList = '123681,300758,310507,306766,300757'
where pcn in (123681) -- 4,617
--insert into Scratch.accounting_account_06_03
values 
(123681,629753,'10000-000-00000','Cash - Comerica General',0,'Asset',0,'category-name-legacy','cattypeleg',0,'subcategory-name-legacy','subcattleg',0,201604)
--(123681,629753,"10000-000-00000","Cash - Comerica General",0,"Asset",0,"category-name-legacy","category-type-legacy",0,"subcategory-name-legacy","subcategory_type_legacy",0,201604)
select * 
--into Scratch.accounting_account_06_03
from Plex.accounting_account aa where account_key = 400825 