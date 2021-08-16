/*
declare @PCN integer;
set @PCN = 295932;
DECLARE @R INT, @L int, @P VARCHAR(1000)
set @L = 1;
EXEC @R=Kors.destinations_get @PCN,@Level=@L,@Destinations=@P OUT --OUT is short for OUTPUT, you can use either one
SELECT @R, @P
select * from kors.recipient
*/
--drop procedure Kors.destinations_get;
create procedure Kors.destinations_get(
 @PCN int,
 @Level int,
 @Destinations varchar(1000) OUTPUT
)
as
begin
	
declare @x xml;

select @x=(
select
--',' +
/* Debug section
n.notify_level,
--n.email_check,
case 
when n.email_check = 0 then cast (r.shift_std as varchar) 
else 'N/A'
end shift,
r.[position],r.dept_name,r.last_name,
*/ 
CASE 
when n.email_check = 0 then ' Lv' + cast(n.notify_level as varchar) + '-Shift' + cast(r.shift_std as varchar) + '-' + left(r.first_name,1) + r.last_name + '-2604380796@vtext.com' + CHAR(13) + CHAR(10) -- r.SMS
else ' Lv' + cast(n.notify_level as varchar) + '-' + left(r.first_name,1) + r.last_name + '-' + '2604380796@vtext.com,' + r.email + CHAR(13) + CHAR(10)
end --notify
from Kors.notification n
--from Kors.notification_test1 n
inner join Kors.recipient r 
on n.pcn=r.pcn
and n.customer_employee_no=r.customer_employee_no
where n.notify_level = @Level
and 
(
	n.pcn = @PCN
	or r.last_name = 'Kenrick'
)
order by n.notify_level,n.email_check,r.shift_std,r.[position],r.dept_name, r.last_name 

for xml path(''),type);
select @Destinations=(@x.value('(./text())[1]','nvarchar(max)'));
--select len(@x.value('(./text())[1]','nvarchar(max)')) j  -- 834
--   SET @Destinations='SOME VALUE';
   RETURN 0;
end;
