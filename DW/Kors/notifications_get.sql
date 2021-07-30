declare @level integer
set @level = 2
declare @cur_time time
set @cur_time = '05:00:01'

declare @start_shift_1 time
set @start_shift_1 = '07:00:01'

declare @end_shift_1 time
set @end_shift_1 = '15:00:00'

declare @start_shift_2 time
set @start_shift_2 = '15:00:01'

declare @end_shift_2 time
set @end_shift_2 = '23:00:00'

declare @start_shift_3 time
set @start_shift_3 = '23:00:01'

declare @end_shift_3 time
set @end_shift_3 = '06:00:00'

declare @midnight time
set @midnight = '23:59:59'
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