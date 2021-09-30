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
select * from Kors.notification  -- 50


// BACKUP
select * 
into Kors.notification_09_30
from Kors.notification

select * from Kors.notification_09_30
*/