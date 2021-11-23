-- drop table Plex.accounting_balance
CREATE TABLE Plex.accounting_balance (
	pcn int,
	account_key int,
	account_no varchar(20),
	period int,
	debit decimal(19,5),
	credit decimal(19,5),
	balance decimal(19,5),
	balance_legacy decimal(19,5),
	PRIMARY KEY (pcn,account_key,period)
);
select distinct pcn,period from Plex.accounting_balance ab order by pcn,period
select * from Plex.accounting_balance ab 