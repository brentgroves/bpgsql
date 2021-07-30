--create schema Kors;
/*
truncate table Kors.notifications
-- drop table Kors.notifications
create table Kors.notifications
(
  notification_key int,  -- cant rely on this key because it will change with every import
  pcn int,
  notify_level tinyint,
  last_name varchar(50),
  first_name varchar(50),
  dept_name varchar(50),
  shift varchar(15),
  position varchar(50),
  email varchar(100),
  phone varchar(25),  -- recommend using this column since
  home_phone varchar(25),
  mobile varchar(25),
  off_hours tinyint,
  start_time datetime,
  end_time datetime,
  notify_type tinyint, -- 1=phone, 2=text, 3=email,
  shift_std tinyint,
  customer_employee_no varchar(50), -- Every user gets an employee number HR has the next number written down when someone is hired
  badge_no varchar(50)
)
*/
--select * from Kors.notifications 
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
