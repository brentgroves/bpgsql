/*
 * Create accounting_balance_delete_period procedure to delete records
 * which fall into the pcn ranges found in the Plex.accounting_balance_update_period_range records. 
 * This table is updated from Plex with current values.  I don't know if it is necessary to 
 * have a different period range for each PCN, so I assumed it was.
 */
-- exec Plex.accounting_balance_delete_period_range
-- drop procedure Plex.accounting_balance_delete_period_range
create procedure Plex.accounting_balance_delete_period_range
as
begin
	declare @start_id int;
	declare @end_id int;
	select @start_id = min(id),@end_id = max(id) from Plex.accounting_balance_update_period_range
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
		select @pcn=pcn,@period_start=period_start,@period_end=period_end from Plex.accounting_balance_update_period_range where id = @id
	--	print N'pcn=' + cast(@pcn as varchar(6)) + N',period_start=' + cast(@period_start as varchar(6)) + N', period_end=' + cast(@period_end as varchar(6))
		--select distinct pcn,period from Archive.accounting_balance_2022_01_25 order by pcn,period
		--select distinct pcn,period from Plex.accounting_balance order by pcn,period
		-- select * from Archive.accounting_balance where pcn= 300758 and period= 202201 order by pcn,period
		delete from Plex.accounting_balance WHERE pcn = @pcn and period between @period_start and @period_end
--		delete from Archive.accounting_balance WHERE pcn = @pcn and period between @period_start and @period_end
		set @id = @id+1;
	end 
end 
select * from Plex.accounting_balance_update_period_range

select * from Archive.accounting_balance ab -- 52,138
select count(*) from Archive.accounting_balance ab -- 46,055
select count(*) from Plex.accounting_balance ab -- 49,503/46,055
select distinct pcn,period from Archive.accounting_balance_2022_01_25 order by pcn,period
select distinct pcn,period from Plex.accounting_balance order by pcn,period
select * from Plex.accounting_balance order by pcn,period



select * 
into Archive.accounting_balance_2022_01_25 
from Plex.accounting_balance ab -- 52,138

select * from Plex.accounting_balance ab -- 52,138
u--46,681/52,749
select distinct pcn,period from Archive.accounting_balance ab order by pcn,period

select count(*) from Plex.accounting_balance ab -- 46,681/52,749
select distinct pcn,period from Plex.accounting_balance ab order by pcn,period

select *
--into Archive.accounting_balance_01_03_2022
from Plex.accounting_balance



select * 
--select count(*) from Archive.account_period_balance_01_03_2022 ab -- 43,630
--into Archive.account_period_balance_01_03_2022
--select count(*) from Plex.account_period_balance ab -- 43,630
from Plex.account_period_balance b -- 43,630


