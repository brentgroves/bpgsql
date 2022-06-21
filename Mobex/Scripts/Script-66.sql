-- Plex.Account_Balances_by_Periods_View source

create view Plex.Account_Balances_by_Periods_View as
	select * 
	--select count(*)
	from Plex.Account_Balances_by_Periods
	where period_display != 'Total';