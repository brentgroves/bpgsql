--drop table Plex.revenue_analysis_by_part
--truncate table Plex.revenue_analysis_by_part
create table Plex.revenue_analysis_by_part
(
	pcn int,
	period int,
	customer varchar(50),
	part varchar(50), 
--	revenue float,
	revenue decimal(19,5),
	quantity int,
	total_percent float,
	material decimal(19,5),
	labor decimal(19,5),
	overhead decimal(19,5),
	subcontract int,
	total decimal(19,5),
	net_margin decimal(19,5),	
--	primary key (customer,part)
)
ALTER TABLE Plex.revenue_analysis_by_part 
ALTER COLUMN customer varchar(50);
select *
-- pcn,customer,part 
from Plex.revenue_analysis_by_part
where pcn is null and period is null

update Plex.revenue_analysis_by_part
set pcn=300758,
period=202101
where pcn is null and period is null

select *
-- pcn,customer,part 
from Plex.revenue_analysis_by_part
where 
--pcn=123681
--and period=202101
--and period=202110
--and period=202109
pcn=300758
and period=202101
--and period=202110
--and period=202109
