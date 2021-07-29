--create schema Kors;
/*
truncate table Kors.notifications
-- drop table Kors.notifications
create table Kors.notifications
(
  pcn int,
  notify_level tinyint,
  last_name varchar(50),
  first_name varchar(50),
  dept_name varchar(50),
  shift varchar(15),
  position varchar(50),
  email varchar(100),
  phone varchar(25),
  home_phone varchar(25),
  mobile varchar(25),
  off_hours tinyint
)
*/
select notify_level,shift, 
CASE 
when off_hours = 1 then 
POSITION, dept_name, last_name, first_name from Kors.notifications 
order by pcn,notify_level,shift,off_hours, position,dept_name,last_name,first_name