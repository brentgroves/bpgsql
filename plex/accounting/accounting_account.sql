-- drop table Plex.accounting_account
-- truncate table Plex.accounting_account
create table Plex.accounting_account
(
pcn int,
account_key int,
Account_No	varchar (20),
Account_Name	varchar (110),
Category_Type	varchar (10),
  PRIMARY KEY CLUSTERED
  (
    PCN,account_key
  )
)
select * from Plex.accounting_account