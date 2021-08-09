/*
 * Fake SPROC that returns only 1 or 2 recipients per level
 * Use a slightly modified version of the notification_get SPROC
 */

/*
 * 
 */
-- select * from Kors.notification_test1
--exec Kors.make_notification_test1
--drop procedure Kors.make_notification_test1;
create procedure Kors.make_notification_test1
as
begin
IF OBJECT_ID (N'Kors.notification_test1', N'U') IS NOT NULL  
DROP TABLE Kors.notification_test1; 

select n.*
into Kors.notification_test1
--select n.*
from Kors.notification n
inner join Kors.notification_subset s 
on n.pcn=s.pcn 
and n.customer_employee_no = s.customer_employee_no
end;
/* Level 1 test
select *  
from Kors.notifications n 
where 
-- (n.off_hours = 1) and
n.notify_level = @level 
and n.shift_std = @shift
*/
-- and (n.off_hours = 1) 




