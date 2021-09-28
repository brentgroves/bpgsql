/*
 * 
-- Kevins mobile: 260-438-0796
--create schema Kors;
truncate table Kors.recipient
-- drop table Kors.recipient
create table Kors.recipient
(
  recipient_key int,
  pcn int,
  shift varchar(15),
  shift_std tinyint,
  dept_name varchar(50),
  position varchar(50),
  last_name varchar(50),
  first_name varchar(50),
  SMS varchar(25),
--  email_check tinyint,  -- if email_check = 1 then if we are in the email window we will send an email rather than an SMS message.
  email varchar(100),
  customer_employee_no varchar(50)  -- plex reference
)
select * from Kors.recipient
SELECT CONVERT (varchar, SERVERPROPERTY('collation')) AS 'Server Collation';
-- mgsqlmi SQL_Latin1_General_CP1_CI_AS
SELECT name, collation_name FROM sys.databases;
*/

create table Kors.OLEDBTest
(
  TestColumn varchar(50)  -- plex reference
)
select * from Kors.OLEDBTest
/*
truncate table Kors.notification
-- drop table Kors.notification
create table Kors.notification
(
  notification_key int,
  pcn int,
  notify_level tinyint,
  email_check tinyint,  -- if email_check = 1 then if we are in the email window we will send an email rather than an SMS message.
  customer_employee_no varchar(50)  -- plex reference
)
select * from Kors.notification
*/
/*
-- drop table Kors.email_hours
-- truncate table Kors.email_hours
create table Kors.email_hours
(
  email_hours_key int,
  pcn int,
  email_start time(0),
  email_end time(0),
  primary key (email_hours_key)
) 
*/
/*
 * -- select * from Kors.email_hours
insert into Kors.email_hours
values
(1,295932,'19:00:00','06:00:00')
*/

/*
 * Don't want to hard code shift times in SPROCS so make a table.
*/
/*
-- drop table Kors.shift
-- truncate table Kors.shift
create table Kors.shift
(
  shift_key int,
  pcn int,
  shift int,
  shift_start time(0),
  shift_end time(0),
  primary key (shift_key)
) 
*/ 
/*
insert into Kors.shift
values
(1,295932,1,'06:00:00','13:59:59'),
(2,295932,2,'14:00:00','21:59:59'),
(3,295932,3,'22:00:00','05:59:59')
select * from Kors.shift

*/
--select * from Kors.shift 
/*
-- do this from the master database
-- CREATE LOGIN kors
-- WITH PASSWORD = 't`8V8Uj\/*ht>;M6';
*/

/*
 * Do this from the database with the schema you want to access
 */
CREATE USER [kors]
FROM LOGIN [kors]
WITH DEFAULT_SCHEMA=Kors;
ALTER ROLE db_owner ADD MEMBER [kors];

/****** Object:  Table [Kors].[notification]    Script Date: 9/27/2021 4:41:27 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- mgsqlsrv has not been updated with the primary key yet
-- may need to find another pk because of pcn of ceo
CREATE TABLE [Kors].[notification](
	[notification_key] [int] not NULL,
	[pcn] [int] not NULL,
	[notify_level] [tinyint] not NULL,
	[email_check] [tinyint] not NULL,
	[customer_employee_no] [varchar](50) not NULL,
	primary key (notification_key,pcn)
)
select * from [Kors].[notification]
-- delete from [Kors].[notification] where notify_level = 5
select count(*) from [Kors].[notification]  -- 50
GO

--CREATE TABLE notification (notification_key INT, pcn INT, notify_level TINYINT, email_check TINYINT, customer_employee_no VARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS);




