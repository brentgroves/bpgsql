

DECLARE @R INT;
declare @cur_time time;
declare @Dest varchar(1000);
declare @Lvl integer;
set @Lvl = 5
declare @PCN integer;
set @PCN = 295932;
set @cur_time = '06:00:01';
--set @cur_time = '06:00:00'
--set @cur_time = '00:00:00'
--set @cur_time = '19:00:00'
--set @cur_time = '18:59:59'

DECLARE @R INT;
declare @cur_time time;
declare @Dest varchar(1000);
declare @Lvl integer;
set @Lvl = 4
declare @PCN integer;
set @PCN = 295932;
set @cur_time = '06:00:01';
--set @cur_time = '06:00:00'
--set @cur_time = '00:00:00'
--set @cur_time = '19:00:00'
--set @cur_time = '18:59:59'

DECLARE @R INT;
declare @cur_time time;
declare @Dest varchar(1000);
declare @Lvl integer;
set @Lvl = 3
declare @PCN integer;
set @PCN = 295932;
set @cur_time = '06:00:01'
--set @cur_time = '06:00:00'
--set @cur_time = '05:59:59'
--set @cur_time = '00:00:00'
--set @cur_time = '22:00:00'
--set @cur_time = '21:59:59'
--set @cur_time = '19:00:00'
--set @cur_time = '18:59:59'
--set @cur_time = '14:00:00'
--set @cur_time = '13:59:59'
--set @cur_time = '06:00:00'

DECLARE @R INT;
declare @cur_time time;
declare @Dest varchar(1000);
declare @Lvl integer;
set @Lvl = 2
declare @PCN integer;
set @PCN = 295932;
set @cur_time = '06:00:01'
--set @cur_time = '06:00:00'
--set @cur_time = '05:59:59'
--set @cur_time = '00:00:00'
--set @cur_time = '22:00:00'
--set @cur_time = '21:59:59'
--set @cur_time = '19:00:00'
--set @cur_time = '18:59:59'
--set @cur_time = '14:00:00'
--set @cur_time = '13:59:59'
--set @cur_time = '06:00:00'

DECLARE @R INT;
declare @cur_time time;
declare @Dest varchar(1000);
declare @Lvl integer;
set @Lvl = 5
declare @PCN integer;
set @PCN = 295932;
--set @cur_time = '06:00:01'
--set @cur_time = '06:00:00'
--set @cur_time = '05:59:59'
--set @cur_time = '00:00:00'
--set @cur_time = '22:00:00'
--set @cur_time = '21:59:59'
--set @cur_time = '19:00:00'
--set @cur_time = '18:59:59'
set @cur_time = '14:00:00'
--set @cur_time = '13:59:59'
--set @cur_time = '06:00:00'
-- select * from Kors.notification n 
-- select * from Kors.recipient r 
--select getdate() AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time'
--exec @R=Kors.notifications_get @PCN,@Level=@Lvl,@Destinations = @Dest OUT,@dbg_time=@cur_time; --, @cur_time
--select @R,@Dest;
exec @R=Kors.notifications_get_rs @PCN,@Level=@Lvl
--0@Destinations = @Dest OUT
select @R





DECLARE @R INT;
declare @cur_time time;
declare @Dest varchar(1000);
declare @Lvl integer;
set @Lvl = 5
declare @PCN integer;
set @PCN = 295932;
set @cur_time = '06:00:01';
--set @cur_time = '06:00:00'
--set @cur_time = '00:00:00'
--set @cur_time = '19:00:00'
--set @cur_time = '18:59:59'

DECLARE @R INT;
declare @cur_time time;
declare @Dest varchar(1000);
declare @Lvl integer;
set @Lvl = 4
declare @PCN integer;
set @PCN = 295932;
set @cur_time = '06:00:01';
--set @cur_time = '06:00:00'
--set @cur_time = '00:00:00'
--set @cur_time = '19:00:00'
--set @cur_time = '18:59:59'

DECLARE @R INT;
declare @cur_time time;
declare @Dest varchar(1000);
declare @Lvl integer;
set @Lvl = 3
declare @PCN integer;
set @PCN = 295932;
set @cur_time = '06:00:01'
--set @cur_time = '06:00:00'
--set @cur_time = '05:59:59'
--set @cur_time = '00:00:00'
--set @cur_time = '22:00:00'
--set @cur_time = '21:59:59'
--set @cur_time = '19:00:00'
--set @cur_time = '18:59:59'
--set @cur_time = '14:00:00'
--set @cur_time = '13:59:59'
--set @cur_time = '06:00:00'

DECLARE @R INT;
declare @cur_time time;
declare @Dest varchar(1000);
declare @Lvl integer;
set @Lvl = 2
declare @PCN integer;
set @PCN = 295932;
set @cur_time = '06:00:01'
--set @cur_time = '06:00:00'
--set @cur_time = '05:59:59'
--set @cur_time = '00:00:00'
--set @cur_time = '22:00:00'
--set @cur_time = '21:59:59'
--set @cur_time = '19:00:00'
--set @cur_time = '18:59:59'
--set @cur_time = '14:00:00'
--set @cur_time = '13:59:59'
--set @cur_time = '06:00:00'

DECLARE @R INT
declare @cur_time time
declare @dbg_time time
declare @Dest varchar(1000)
declare @Lvl integer
set @Lvl = 4
declare @PCN integer
set @PCN = 295932
set @cur_time = '06:00:01'
--set @cur_time = '06:00:00'
--set @cur_time = '05:59:59'
--set @cur_time = '00:00:00'
--set @cur_time = '22:00:00'
--set @cur_time = '21:59:59'
--set @cur_time = '19:00:00'
--set @cur_time = '18:59:59'
--set @cur_time = '14:00:00'
--set @cur_time = '13:59:59'
--set @cur_time = '06:00:00'

--select getdate() AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time'
exec @R=Kors.notifications_get_rs @PCN,@Level=@Lvl
--exec @R=Kors.notifications_get_rs @PCN,@Level=@Lvl,@dbg_time=@cur_time; --, @cur_time
select @R,@Dest,@dbg_time;
-- 2604380796@vtext.com
SELECT * FROM Kors.notification -- 50
select * from Kors.recipient -- 35
where customer_employee_no = 054109

--select * from Kors.notification
-- select * from Kors.recipient
--drop procedure Kors.notifications_get_op;






SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
select * from [Kors].notification
--drop procedure Kors.notifications_get_rs;
--select * from Kors.recipient
-- select * from Kors.notification n 
create procedure [Kors].[notifications_get_rs](
 @PCN integer = 295932,
 @Level integer = 1,
 @dbg_time time = null
)
as
begin
declare @Destinations varchar(1000);
declare @midnight time;
set @midnight = '23:59:59';

--declare @level integer;

declare @cur_time time;
--declare @dbg_time time;
--set @dbg_time = '23:59:59';
SELECT
@cur_time = 
case 
when @dbg_time is null then GETDATE() AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time'
else @dbg_time 
end 
--select @cur_time
--set @level = 5;
--set @cur_time = '06:00:01';
--set @cur_time = '06:00:00'
--set @cur_time = '00:00:00'
--set @cur_time = '19:00:00'
--set @cur_time = '18:59:59'
--set @cur_time = '07:00:00'

--set @level = 4
--set @cur_time = '06:00:01'
--set @cur_time = '06:00:00'
--set @cur_time = '00:00:00'
--set @cur_time = '19:00:00'
--set @cur_time = '18:59:59'
--set @cur_time = '07:00:00'

--set @level = 3
--set @cur_time = '06:59:59'
--set @cur_time = '06:00:01'
--set @cur_time = '06:00:00'
--set @cur_time = '00:00:00'
--set @cur_time = '23:00:00'
--set @cur_time = '22:59:59'
--set @cur_time = '19:00:00'
--set @cur_time = '18:59:59'
--set @cur_time = '15:00:00'
--set @cur_time = '14:59:59'
--set @cur_time = '07:00:00'

--set @level = 2
--set @cur_time = '06:59:59'
--set @cur_time = '06:00:01'
--set @cur_time = '06:00:00'
--set @cur_time = '00:00:00'
--set @cur_time = '23:00:00'
--set @cur_time = '22:59:59'
--set @cur_time = '19:00:00'
--set @cur_time = '18:59:59'
--set @cur_time = '15:00:00'
--set @cur_time = '14:59:59'
--set @cur_time = '07:00:00'

--set @level = 1
--set @cur_time = '06:59:59'
--set @cur_time = '00:00:00'
--set @cur_time = '23:00:00'
--set @cur_time = '22:59:59'
--set @cur_time = '15:00:00'
--set @cur_time = '14:59:59'
--set @cur_time = '07:00:00'
--select @cur_time


declare @email_hours tinyint;

select
@email_hours =
case 
when count(*) > 0 then 1
else 0
end 
from 
(
-- debug section
--	declare @PCN int;
--	set @PCN = 295932;
--	declare @midnight time;
--	set @midnight = '23:59:59';
--	declare @cur_time time;
--	set @cur_time = '06:00:01';
	--set @cur_time = '06:00:00'
	--set @cur_time = '00:00:00'
	--set @cur_time = '19:00:00'
	--set @cur_time = '18:59:59'

	select 
	case 
	when (eh.email_start > eh.email_end) -- Does the window contain midnight
	and 
	(
	((@cur_time >= eh.email_start ) and (@cur_time <= @midnight)) or 
	((@cur_time <= eh.email_end))
	) then 1
	when (@cur_time between eh.email_start and eh.email_end) then 1 
	else 0
	end email_hours 
	from Kors.email_hours eh
	where eh.pcn =@PCN
) eh 
where eh.email_hours != 0;
--select @email_hours


-- select * from Kors.shift 
declare @start_shift_1 time;
select @start_shift_1 = shift_start from Kors.shift where shift = 1 and pcn =@PCN;

declare @end_shift_1 time;
select @end_shift_1 = shift_end from Kors.shift where shift = 1 and pcn =@PCN;

declare @start_shift_2 time;
select @start_shift_2 = shift_start from Kors.shift where shift = 2 and pcn =@PCN;

declare @end_shift_2 time;
select @end_shift_2 = shift_end from Kors.shift where shift = 2 and pcn =@PCN;

declare @start_shift_3 time;
select @start_shift_3 = shift_start from Kors.shift where shift = 3 and pcn =@PCN;

declare @end_shift_3 time;
select @end_shift_3 = shift_end from Kors.shift where shift = 3 and pcn =@PCN;



declare @shift int; 
select @shift = 
CASE 
when ((@cur_time >= @start_shift_1) and (@cur_time <= @end_shift_1)) then 1
when ((@cur_time >= @start_shift_2) and (@cur_time <= @end_shift_2)) then 2
when 
(
((@cur_time >= @start_shift_3) and (@cur_time <= @midnight)) OR 
(@cur_time <= @end_shift_3)
) then 3
end;

/*
select 
@start_shift_1 start_shift_1,@end_shift_1 end_shift_1,
@start_shift_2 start_shift_2,@end_shift_2 end_shift_2,
@start_shift_3 start_shift_3,@end_shift_3 end_shift_3,
@midnight midnight,
@cur_time cur_time,
@email_hours email_hours,
@shift shift;
select * 
into Kors.notification_test1
from Kors.notification;
*/
/*
select n.notify_level,r.shift_std shift,r.position,r.dept_name,
case 
when n.email_check = 1 and @email_hours = 1 then r.email
when n.email_check = 1 and @email_hours = 0 then '1112223333@vtext.com' -- n.SMS
when n.email_check = 0 then '1112223333@vtext.com' --n.SMS
end notification,
--n.email,
r.last_name,r.first_name 
--select *
from Kors.notification_test1 n
inner join Kors.recipient r 
on n.pcn=r.pcn
and n.customer_employee_no=r.customer_employee_no

where 
n.notify_level = @level 
AND
(
	(
		r.shift_std = @shift
		and n.email_check = 0
	)
	or 
	(
		n.email_check = 1
	)
)
order by n.email_check,r.[position],r.dept_name,r.last_name; 
*/

select @Destinations = 
SUBSTRING
(  (
		select
		',' +
		case 
		when @dbg_time is not null and n.email_check = 1 and @email_hours = 1 then r.first_name + ' ' + r.last_name + ' - ' + r.email
		when @dbg_time is not null and n.email_check = 1 and @email_hours = 0 then r.first_name + ' ' + r.last_name + ' - ' + r.SMS
		when @dbg_time is not null and n.email_check = 0 then r.first_name + ' ' + r.last_name  + '- ' + r.SMS
--		when @dbg_time is null and n.email_check = 1 and @email_hours = 1 then 'bgroves@mobexglobal.com' --r.email
		when @dbg_time is null and n.email_check = 1 and @email_hours = 1 then r.email
--		when @dbg_time is null and n.email_check = 1 and @email_hours = 0 then '2604380796@vtext.com' -- n.SMS
		when @dbg_time is null and n.email_check = 1 and @email_hours = 0 then r.SMS
--		when @dbg_time is null and n.email_check = 0 then '2604380796@vtext.com' --n.SMS
		when @dbg_time is null and n.email_check = 0 then r.SMS
		end --notification
		from Kors.notification n
--		from Kors.notification_test1 n
		inner join Kors.recipient r 
		on n.pcn=r.pcn
		and n.customer_employee_no=r.customer_employee_no
		
		where 
		n.notify_level = @Level 
		and 
		(
			(((n.email_check = 0 ) or ((n.email_check = 1) and (@email_hours = 0))) and (r.SMS is not null) and (r.SMS != ''))-- going to send sms
		 or ((n.email_check = 1) and (@email_hours=1)  and (r.email is not null) and (r.email != ''))  -- going to send email
		)
		and 
		(
			n.pcn = @PCN
			or r.last_name = 'Kenrick'
		)
		AND
		(
			(
				r.shift_std = @shift
				and n.email_check = 0
			)
			or 
			(
				n.email_check = 1
			)
		) FOR XML PATH('')
	),2,20000)
   -- SET @Destinations='SOME VALUE';
	declare @valid integer; 
	select 
		@valid =
		CASE
			when @Destinations is null then 0
			else 1
		end 
	--select @valid;
	declare @Results varchar(1000);
    select @Results =
    case 
    when @valid = 1 then @Destinations
	else '2604380796@vtext.com' 
	end;
	select @Results;
   RETURN 0;
end;
GO













SELECT 
sc.name AS 'ParameterName' , 
st.name AS 'Type' , 
sc.colid AS 'Column ID' , 
sc.isoutparam AS 'IsOutput' 
FROM syscolumns sc 
INNER JOIN systypes st 
ON sc.xtype = st.xtype 
WHERE 
id = object_id('Kors.notifications_get_op') 
AND st.name <> 'sysname' 
ORDER BY colid