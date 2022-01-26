-- Plex.max_fiscal_period_view source
-- drop view Plex.max_fiscal_period_view
create view Plex.max_fiscal_period_view(pcn,year,max_fiscal_period)
	as
	WITH fiscal_period(pcn,year,period)
	as
	(
		select pcn,year(begin_date) year,period from Plex.accounting_period --where pcn = 123681
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

select * from Plex.max_fiscal_period_view order by pcn,year

select * from Plex.accounting_period order by pcn,period
select distinct pcn from Plex.accounting_period