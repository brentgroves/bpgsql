-- Use Plex procedure: accounting_balance_dw_import
-- drop table Plex.accounting_balance
CREATE TABLE Plex.accounting_balance
-- account_no	start_period	debit	credit	YTD
(
  pcn INT NOT NULL,
  account_no VARCHAR(20) NOT NULL,
  period int not null,
  debit decimal(19,5),
  credit decimal(19,5),
  balance decimal(19,5),
  PRIMARY KEY CLUSTERED
  (
    PCN,account_no,period
  )
);
select distinct pcn,period from Plex.accounting_balance ORDER by pcn,period
select * from Plex.accounting_balance