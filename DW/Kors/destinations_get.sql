/*
declare @PCN integer;
set @PCN = 295932;
DECLARE @R INT, @L int, @P VARCHAR(1000)
set @L = 3
EXEC @R=Kors.destinations_get_rs @PCN,@Level=@L 
SELECT @R 
select * from kors.recipient
*/

--drop procedure Kors.destinations_get_rs
create procedure Kors.destinations_get_rs(
 @PCN int = 295932,
 @Level int = 1
)
as
begin
	
declare @x xml;
declare @Destinations varchar(1000);
select @x=(
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
select
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
select @Destinations;
   RETURN 0;
end;




/*
declare @PCN integer;
set @PCN = 295932;
DECLARE @R INT, @L int, @P VARCHAR(1000)
set @L = 5
EXEC @R=Kors.destinations_get_op @PCN,@Level=@L ,@Destinations=@P OUT
SELECT @R,@P
select * from kors.recipient
*/

--drop procedure Kors.destinations_get_op
create procedure Kors.destinations_get_op(
 @PCN int = 295932,
 @Level int = 1,
 @Destinations varchar(1000) = 'Success' OUTPUT
)
as
begin
	
declare @x xml;
select @x=(
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
select
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
   RETURN 0;
end;


SELECT 
sc.name AS 'ParameterName' , 
st.name AS 'Type' , 
sc.colid AS 'Column ID' , 
sc.isoutparam AS 'IsOutput' 
FROM syscolumns sc 
INNER JOIN systypes st 
ON sc.xtype = st.xtype 
WHERE 
id = object_id('Kors.destinations_get_op') 
AND st.name <> 'sysname' 
ORDER BY colid