/*
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
*/
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
(1,295932,1,'07:00:00','14:59:59'),
(2,295932,2,'15:00:00','22:59:59'),
(3,295932,3,'23:00:00','06:59:59')


*/
--select * from Kors.shift 



