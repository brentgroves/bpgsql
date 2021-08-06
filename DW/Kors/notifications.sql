--create schema Kors;
/*
truncate table Kors.notifications
-- drop table Kors.notifications
create table Kors.notifications
(
  notification_key int,
  pcn int,
  notify_level tinyint,
  shift varchar(15),
  shift_std tinyint,
  dept_name varchar(50),
  position varchar(50),
  last_name varchar(50),
  first_name varchar(50),
  SMS varchar(25),
  email_check tinyint,  -- if email_check = 1 then if we are in the email window we will send an email rather than an SMS message.
  email varchar(100),
  customer_employee_no varchar(50)  -- plex reference
)
select * from Kors.notifications
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

-- drop table Kors.phone
/*
If we use plex_user.phone column to map employees to one of the 6 phones
we will not need this phone schema.
create table Kors.phone
(
  phone_key int,
  pcn int,
  phone_no varchar(13),
  test_no varchar(13)
)
*/
/*
insert into Kors.phone 
values
(1,295932,'phone#1','(231)670-1111'),
(2,295932,'phone#2','(231)670-2222'),
(3,295932,'phone#3','(231)670-3333'),
(4,295932,'phone#4','(231)670-4444'),
(5,295932,'phone#5','(231)670-5555'),
(6,295932,'phone#6','(231)670-6666')
select * from Kors.phone
*/
/*
-- drop table Kors.phone_user
create table Kors.phone_user
(
  phone_user_key int,
  pcn int,
  phone_key int,
  customer_employee_no int
)
insert into Kors.phone_user
values
(1,295932,1,)
*/

select 
--r.id,
--r.pcn, 
r.notify_level,
r.shift_std shift,
r.position,
r.dept_name,
r.last_name + ',' + r.first_name name,
CASE 
when r.notify_type = 1 then 'phone'
when r.notify_type = 2 then 'text'
when r.notify_type = 3 then 'email'
end notify_type,
case 
--when r.notify_type = 1 then r.phone  --  This will be used eventually but currently it does not contain any info so I won't list it.
when r.notify_type = 1 and trim(r.home_phone) <> '' then r.home_phone -- This is only being used now for one of the 6 phone numbers because it has values.
when r.notify_type = 1 and trim(r.home_phone) = '' then r.mobile -- This is only being used now for one of the 6 phone numbers because it has values.
when r.notify_type = 2 then r.mobile
else r.email
end notify,
--r.home_phone,r.mobile,r.phone,
case 
when r.off_hours = 1 then CONVERT(VARCHAR(8), start_time, 108) -- format(start_time,'HH:mm:ss') -- CONVERT(VARCHAR(15), CAST(start_time AS TIME), 0)
else 'n/a'
end start_time,
case 
when r.off_hours = 1 then CONVERT(VARCHAR(8), end_time, 108) --format(end_time,'hh:mm:ss') --CONVERT(VARCHAR(10), CAST(end_time AS TIME), 0)
else 'n/a'
end end_time
from Kors.notifications  r
--where notify_level = 1 and shift_std = 1
--where notify_level = 2 and off_hours = 0   and shift_std = 1
where notify_level = 2 and off_hours = 1   and notify_type = 2
--where notify_level = 2 and off_hours = 1   and notify_type = 3
--where notify_level = 3 and off_hours = 0   and shift_std = 3
--where notify_level = 3 and off_hours = 1   and notify_type = 2
--where notify_level = 3 and off_hours = 1   and notify_type = 3
--where notify_level = 4 and off_hours = 1   and notify_type = 2
--where notify_level = 4 and off_hours = 1   and notify_type = 3
--where notify_level = 5 and off_hours = 1   and notify_type = 2
--where notify_level = 5 and off_hours = 1   and notify_type = 3
order by r.notify_level,r.shift_std,r.position,r.dept_name,r.notify_type
