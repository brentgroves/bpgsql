--drop table Plex.accounting_balance_last_full_period
create table Plex.accounting_balance_last_full_period
(
	pcn int,
	last_full_period int
	PRIMARY KEY (pcn)
)

select * from Plex.accounting_balance_last_full_period