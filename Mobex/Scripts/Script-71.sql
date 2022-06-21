
--drop table Plex.accounting_period;
create table Plex.accounting_period 
(
	pcn int,
	period_key int,
	period int,
	fiscal_order int,
	begin_date datetime,
	end_date datetime,
	period_display varchar(7),
	quarter_group tinyint,
	primary key (pcn,period_key)
	
)

plexus_customer_no,period,fiscal_order,begin_date,end_date,period_display,quarter_group

select * from Plex.accounting_period