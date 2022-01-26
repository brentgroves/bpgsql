/*
 * Update Plex.accounting_balance_update_period_range table to be 1 years worth of periods.
 * exec Plex.set_accounting_balance_update_period_range
 */
--drop procedure Plex.set_accounting_balance_update_period_range
create procedure Plex.set_accounting_balance_update_period_range
as
begin

	declare @today datetime
	select @today=getdate()
	declare @prev_year datetime
	SELECT @prev_year = DATEADD(year,-1,GETDATE())
	declare @start_period int;
	declare @end_period int;
	select @start_period = 202102;
/*
	select @start_period =min(period) from Plex.accounting_period ap 
	where @prev_year between ap.begin_date and ap.end_date 
	and ap.pcn = 123681
*/
	select @end_period =last_full_period from Plex.accounting_balance_last_full_period p 
--	where @today between ap.begin_date and ap.end_date 
	where p.pcn = 123681
	
	--select @start_period start_period, @end_period end_period, @prev_year prev_year

	update Plex.accounting_balance_update_period_range
	set period_start=@start_period,period_end=@end_period
	where pcn=123681 -- southfield

	--select * from Plex.accounting_balance_update_period_range	
end;
	update Plex.accounting_balance_update_period_range
	set period_start=202101,period_end=202201
	where pcn=123681 -- southfield
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
		--select distinct pcn,period from Archive.accounting_balance order by pcn,period
		-- select * from Archive.accounting_balance where pcn= 300758 and period= 202201 order by pcn,period
		delete from Plex.accounting_balance WHERE pcn = @pcn and period between @period_start and @period_end
--		delete from Archive.accounting_balance WHERE pcn = @pcn and period between @period_start and @period_end
		set @id = @id+1;
	end 
end 
select * from Plex.accounting_balance_update_period_range
