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

--declare @cur_time time;
--declare @level integer;
--set @level = 1
--set @cur_time = '06:59:59'
--set @cur_time = '00:00:00'
--set @cur_time = '23:00:00'
--set @cur_time = '22:59:59'
--set @cur_time = '15:00:00'
--set @cur_time = '14:59:59'
--set @cur_time = '07:00:00'
--select @cur_time

declare @cur_time time;
declare @level integer;

set @level = 2
--set @cur_time = '06:59:59'
--set @cur_time = '06:00:01'
--set @cur_time = '06:00:00'
--set @cur_time = '00:00:00'
set @cur_time = '23:00:00'
--set @cur_time = '22:59:59'
--set @cur_time = '19:00:00'
--set @cur_time = '18:59:59'
--set @cur_time = '15:00:00'
--set @cur_time = '14:59:59'
--set @cur_time = '07:00:00'

exec Kors.notifications_get @level,@cur_time
--drop procedure Kors.notifications_get;
create procedure Kors.notifications_get
 @level integer,
 @dbg_time time = null
as
begin
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
) eh 
where eh.email_hours != 0;
--select @email_hours


-- select * from Kors.shift 
declare @start_shift_1 time;
select @start_shift_1 = shift_start from Kors.shift where shift = 1;

declare @end_shift_1 time;
select @end_shift_1 = shift_end from Kors.shift where shift = 1;

declare @start_shift_2 time;
select @start_shift_2 = shift_start from Kors.shift where shift = 2;

declare @end_shift_2 time;
select @end_shift_2 = shift_end from Kors.shift where shift = 2;

declare @start_shift_3 time;
select @start_shift_3 = shift_start from Kors.shift where shift = 3;

declare @end_shift_3 time;
select @end_shift_3 = shift_end from Kors.shift where shift = 3;



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
select 

SUBSTRING
(  (
		select
		',' +
		case 
		when @dbg_time is not null and n.email_check = 1 and @email_hours = 1 then r.email
		when @dbg_time is not null and n.email_check = 1 and @email_hours = 0 then r.last_name +'''' + r.first_name + '''' + 'SMS'
		when @dbg_time is not null and n.email_check = 0 then r.last_name +'''' + r.first_name + '''' + 'SMS'
		when n.email_check = 1 and @email_hours = 1 then 'bgroves@mobexglobal.com' --r.email
		when n.email_check = 1 and @email_hours = 0 then '1112223333@vtext.com' -- n.SMS
		when n.email_check = 0 then '1112223333@vtext.com' --n.SMS
		end --notification
--		from Kors.notification n
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
		) FOR XML PATH('')
	),2,20000)
end;
