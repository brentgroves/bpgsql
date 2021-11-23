CREATE TABLE Plex.accounting_account_balance
-- account_no	start_period	debit	credit	YTD
(
  pcn INT NOT NULL,
  account_no VARCHAR(20) NOT NULL,
  debit decimal(19,5),
  credit decimal(19,5),
  balance decimal(19,5),
  PRIMARY KEY CLUSTERED
  (
    PCN,account_no
  )
);
select distinct pcn,period from Plex.account_balance