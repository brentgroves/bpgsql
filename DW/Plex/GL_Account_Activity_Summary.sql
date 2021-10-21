-- drop table Plex.GL_Account_Activity_Summary

CREATE TABLE Plex.GL_Account_Activity_Summary
(
  pcn INT NOT NULL,
  period int not null,
  account_no VARCHAR(20) NOT NULL,
  account_name varchar(110),
  debit decimal(19,5),
  credit decimal(19,5),
  PRIMARY KEY CLUSTERED
  (
    PCN,period,account_no
  )
);

select * from Plex.GL_Account_Activity_Summary