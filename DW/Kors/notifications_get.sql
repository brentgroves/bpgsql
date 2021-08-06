/*
 * 
 * Just store the data in UTC, and use a calendar table to calculate offsets when you read the data (see these tips: part 1, part 2, part 3). Related:
 * https://stackoverflow.com/questions/20086189/getdate-function-to-get-date-for-my-timezone
 */
declare @midnight time
set @midnight = '23:59:59'

declare @level integer
set @level = 2


declare @cur_time time
--SELECT @cur_time = GETDATE() AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time'
set @cur_time = '19:00:00'
--select @cur_time


declare @email_hours tinyint

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
where eh.email_hours != 0
--select @email_hours


-- select * from Kors.shift 
declare @start_shift_1 time
select @start_shift_1 = shift_start from Kors.shift where shift = 1

declare @end_shift_1 time
select @end_shift_1 = shift_end from Kors.shift where shift = 1

declare @start_shift_2 time
select @start_shift_2 = shift_start from Kors.shift where shift = 2

declare @end_shift_2 time
select @end_shift_2 = shift_end from Kors.shift where shift = 2

declare @start_shift_3 time
select @start_shift_3 = shift_start from Kors.shift where shift = 3

declare @end_shift_3 time
select @end_shift_3 = shift_end from Kors.shift where shift = 3



declare @shift int 
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
select 
@start_shift_1 start_shift_1,@end_shift_1 end_shift_1,
@start_shift_2 start_shift_2,@end_shift_2 end_shift_2,
@start_shift_3 start_shift_3,@end_shift_3 end_shift_3,
@midnight midnight,
@cur_time cur_time,
@email_hours email_hours,
@shift shift


--/* Testing
select n.notify_level,n.shift_std shift,n.dept_name,n.position,
case 
when n.email_check = 1
when n.email_check = 0 then n.SMS

n.email,
n.last_name,n.first_name 
from Kors.notifications n 
where 
-- (n.off_hours = 1) and
n.notify_level = @level 
and n.shift_std = @shift

-- and (n.off_hours = 1) 

/* Level 1 test
select *  
from Kors.notifications n 
where 
-- (n.off_hours = 1) and
n.notify_level = @level 
and n.shift_std = @shift
*/
-- and (n.off_hours = 1) 



/*
SELECT @ClientName =
	CASE
		WHEN BusinessInfo.TradingName <> '' THEN BusinessInfo.TradingName
		WHEN BusinessInfo.LegalEntityName <> '' THEN BusinessInfo.LegalEntityName
		ELSE Contact.Surname + ', ' + Contact.FirstName
	END
*/
select @cur_time ct, CONVERT(VARCHAR(8), start_time, 108) st,cast(end_time as time) et, * 
from Kors.notifications n 
where 
-- (n.off_hours = 1) and
n.notify_level = @level 
and (n.off_hours = 1) 
and (end_time < start_time ) and 
(
((@cur_time >= cast(n.start_time as time)) and (@cur_time <= @midnight)) OR 
(@cur_time <= cast(n.end_time as time))
)

-- match notify level and off hours time ranges
-- select CONVERT(VARCHAR(8), end_time, 108) et,cast(end_time as time), * from Kors.notifications n 
select @cur_time ct, CONVERT(VARCHAR(8), start_time, 108) st,cast(end_time as time) et, * from Kors.notifications n 
where 
-- (n.off_hours = 1) and
n.notify_level = @level 
and (n.off_hours = 1) 
and (end_time < start_time ) and 
(
((@cur_time >= cast(n.start_time as time)) and (@cur_time <= @midnight)) OR 
(@cur_time <= cast(n.end_time as time))
)
/*
and
( 
((n.off_hours = 1) and (@cur_time >= cast(n.start_time as time)) and (@cur_time <= cast(n.end_time as time))) -- or
-- ((n.off_hours = 1) and (n.shift_std = 2) and (@cur_time between @start_shift_2 and @end_shift_2 )) or 
-- ((n.off_hours = 0) and (n.shift_std = 3) and (@cur_time >= @start_shift_3 and (@cur_time <= @midnight ))) 
)
*/
/*
-- match notify level and shift hours
select * from Kors.notifications n 
where 
n.notify_level = @level and
( 
((n.off_hours = 0) and (n.shift_std = 1) and (@cur_time between @start_shift_1 and @end_shift_1 ))  or
((n.off_hours = 0) and (n.shift_std = 2) and (@cur_time between @start_shift_2 and @end_shift_2 )) or 
((n.off_hours = 0) and (n.shift_std = 3) and (@cur_time >= @start_shift_3 and (@cur_time <= @midnight ))) 
)
*/
--@time between cast(start_time as time) and cast(end_time as time)