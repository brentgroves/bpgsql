-- exec Plex.account_period_balance_delete_period_range
-- drop procedure Plex.account_period_balance_delete_period_range
create procedure Plex.account_period_balance_delete_period_range
as
begin
	declare @start_id int;
	declare @end_id int;
	select @start_id = min(id),@end_id = max(id) from Plex.accounting_balance_update_period_range
	--select * from Plex.accounting_balance_update_period_range
	declare @id int;
	set @id=@start_id;
	--select @start_id start_id,@end_id end_id,@id id
	--select * from Plex.accounting_balance_update_period_range
	declare @pcn int;
	declare @period_start int;
	declare @period_end int;
	select @pcn=pcn,@period_start=period_start,@period_end=period_end from Plex.accounting_balance_update_period_range where id = @id
--	select @id id,@pcn pcn,@period_start period_start,@period_end period_end
--	select @pcn=pcn,@period_start=period_start,@period_end=period_end from Plex.accounting_balance_update_period_range where id = 7
	--select @pcn pcn, @id id, @start_id start_id,@end_id end_id, @period_start period_start,@period_end period_end 
	
	while @id <=@end_id
	begin
		select @pcn=pcn,@period_start=period_start,@period_end=period_end from Plex.accounting_balance_update_period_range where id = @id
		--print N'pcn=' + cast(@pcn as varchar(6)) + N',period_start=' + cast(@period_start as varchar(6)) + N', period_end=' + cast(@period_end as varchar(6))
		--select distinct pcn,period from Archive.account_period_balance_01_26_2022 order by pcn,period
		--select distinct pcn,period from Plex.account_period_balance order by pcn,period
		-- select count(*) from Plex.account_period_balance --4,595
		delete from Plex.account_period_balance WHERE pcn = @pcn and period between @period_start and @period_end
--		delete from Archive.account_period_balance WHERE pcn = @pcn and period between @period_start and @period_end
		set @id = @id+1;
	end 
end 
select * from Plex.accounting_balance_update_period_range
/*
 * Make backup
 */
select *
--into Archive.account_period_balance_2022_02_16 -- 98,892
--select count(*)
from Plex.account_period_balance

declare @pcn int;
set @pcn = 123681
declare @period_start int;
declare @period_end int;
select @period_start = 202102,@period_end = 202111;
--select @pcn,@period_start,@period_end;select * from Archive.account_period_balance_01_03_2022 

insert into Plex.account_period_balance
--select count(*) from Archive.account_period_balance_01_03_2022  WHERE pcn = @pcn and period between @period_start and @period_end  -- 39,267
select * from Archive.account_period_balance_01_03_2022 WHERE pcn = @pcn and period between @period_start and @period_end

select * from Archive.account_period_balance_12_30 
select count(*) from Archive.account_period_balance_12_30 -- 43,630
select distinct pcn,period from Archive.account_period_balance_12_30 order by pcn,period

select * from Archive.account_period_balance_01_03_2022 
select count(*) from Archive.account_period_balance_01_03_2022 -- 43,630
select distinct pcn,period from Archive.account_period_balance_01_03_2022 order by pcn,period

select * from Plex.account_period_balance ab 
select count(*) from Plex.account_period_balance ab --4,363/43,630
select distinct pcn,period from Plex.account_period_balance  order by pcn,period

select *
--into Archive.accounting_balance_01_03_2022
from Plex.accounting_balance



select * 
--select count(*) from Archive.account_period_balance_01_03_2022 ab -- 43,630
--into Archive.account_period_balance_01_03_2022
--select count(*) from Plex.account_period_balance ab -- 43,630
from Plex.account_period_balance b -- 43,630

