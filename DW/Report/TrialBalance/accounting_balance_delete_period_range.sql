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
		--select distinct pcn,period from Plex.accounting_balance order by pcn,period
		delete from Plex.accounting_balance WHERE pcn = @pcn and period between @period_start and @period_end
--		delete from Archive.accounting_balance WHERE pcn = @pcn and period between @period_start and @period_end
		set @id = @id+1;
	end 
end;

select * from Plex.accounting_balance_update_period_range