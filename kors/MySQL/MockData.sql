
select DISTINCT Date_time_stamp  
from HourlyOEEValues 
select count(*) from HourlyOEEValues -- 480

update HourlyOEEValues 
set Cumulative_planned_production_count = Hourly_planned_production_count * (Data_hour - 6)


-- https://stackoverflow.com/questions/10351065/how-to-get-depth-in-mysql-store-procedure-recursion
SET max_sp_recursion_depth=1000;

WITH RECURSIVE cte_random (n,y) 
AS (
      SELECT 7 as n, FLOOR(RAND()*(9-0+1))+0 y
      UNION ALL
      SELECT n + 1, FLOOR(RAND()*(9-0+1))+0 y 
      FROM cte_random 
      WHERE n < 1000
    )
    
    
-- SELECT n,y 
-- FROM cte_random;
-- select * from HourlyOEEValues ho order by id
-- select id from HourlyOEEValues order by id

update HourlyOEEValues hv
inner join cte_random rv
on hv.ID = rv.n
set hv.Hourly_actual_production_count = 
case 
when rv.y = 0 and Hourly_planned_production_count = 1 then 0
when rv.y = 1 and Hourly_planned_production_count = 1 then 0
when rv.y = 2 and Hourly_planned_production_count = 1 then 2
when rv.y = 3 and Hourly_planned_production_count = 1 then 1
when rv.y = 4 and Hourly_planned_production_count = 1 then 1
when rv.y = 5 and Hourly_planned_production_count = 1 then 1
when rv.y = 6 and Hourly_planned_production_count = 1 then 1
when rv.y = 7 and Hourly_planned_production_count = 1 then 1
when rv.y = 8 and Hourly_planned_production_count = 1 then 1
when rv.y = 9 and Hourly_planned_production_count = 1 then 1
when rv.y = 0 and Hourly_planned_production_count <> 1 then Hourly_planned_production_count * 1.1
when rv.y = 1 and Hourly_planned_production_count <> 1 then Hourly_planned_production_count * 1.0
when rv.y = 2 and Hourly_planned_production_count <> 1 then Hourly_planned_production_count * 0.9
when rv.y = 3 and Hourly_planned_production_count <> 1 then Hourly_planned_production_count * 0.85
when rv.y = 4 and Hourly_planned_production_count <> 1 then Hourly_planned_production_count * 0.85
when rv.y = 5 and Hourly_planned_production_count <> 1 then Hourly_planned_production_count * 0.85
when rv.y = 6 and Hourly_planned_production_count <> 1 then Hourly_planned_production_count * 0.85
when rv.y = 7 and Hourly_planned_production_count <> 1 then Hourly_planned_production_count * 0.75
when rv.y = 8 and Hourly_planned_production_count <> 1 then Hourly_planned_production_count * 0.65
when rv.y = 9 and Hourly_planned_production_count <> 1 then Hourly_planned_production_count * 0.50
-- else 999
end 


select 
Workcenter_Code,
Part_number,
Data_hour,
Hourly_planned_production_count, 
Cumulative_planned_production_count,
Hourly_actual_production_count, 
Cumulative_actual_production_count
from HourlyOEEValues  hv 
where hv.Date_time_stamp = '2020-04-12 14:29:00'
and hv.Workcenter_Code = 'VSC_1'
order by Workcenter_Code, Data_hour 


update HourlyOEEValues hv
inner join 
(
	select Date_time_stamp,Workcenter_Code,Data_hour,Hourly_actual_production_count,
	(
		select sum(Hourly_actual_production_count)
		from HourlyOEEValues inh
		where inh.data_hour <= hv.data_hour
		and inh.Date_time_stamp = hv.date_time_stamp
		and inh.Workcenter_Code = hv.Workcenter_Code 
	) Cumulative_actual_production_count
	from HourlyOEEValues hv
) ihv
on hv.Date_time_stamp = ihv.Date_time_stamp
and hv.Workcenter_Code = ihv.Workcenter_Code
and hv.Data_hour = ihv.data_hour
set hv.Cumulative_actual_production_count = ihv.Cumulative_actual_production_count

-- select count(*) from Kors.HourlyOEEValues  --384
select Date_time_stamp,Workcenter_Code,Data_hour,Hourly_actual_production_count,
(
	select sum(Hourly_actual_production_count)
	from HourlyOEEValues inh
	where inh.data_hour <= hv.data_hour
	and inh.Date_time_stamp = hv.date_time_stamp
	and inh.Workcenter_Code = hv.Workcenter_Code 
) Cumulative_actual_production_count
from HourlyOEEValues hv
where hv.Date_time_stamp = '2020-03-29 14:29:00'
and Workcenter_Code = 'VSC_3'


SET max_sp_recursion_depth=1000;
WITH RECURSIVE cte_random (n,y) 
AS (
      SELECT 7 as n, FLOOR(RAND()*(9-0+1))+0 y
      UNION ALL
      SELECT n + 1, FLOOR(RAND()*(9-0+1))+0 y 
      FROM cte_random 
      WHERE n < 1000
    )
-- SELECT n,y 
-- FROM cte_random;
-- select * from HourlyOEEValues ho order by id
 
 
update HourlyOEEValues hv
inner join cte_random rv
on hv.ID  = rv.n
-- set scrap_count = rv.randomnumber
set Downtime_minutes = 
case 
when hv.Hourly_actual_production_count = 0  then 60
when rv.y = 0 then 0
when rv.y = 1 then 15
when rv.y = 2 then 30
when rv.y = 3 then 45
when rv.y = 4 then 0
when rv.y = 5 then 0
when rv.y = 6 then 0
when rv.y = 7 then 0
when rv.y = 8 then 0
when rv.y = 9 then 0
end 


SET max_sp_recursion_depth=1000;
WITH RECURSIVE cte_random (n,y) 
AS (
      SELECT 7 as n, FLOOR(RAND()*(9-0+1))+0 y
      UNION ALL
      SELECT n + 1, FLOOR(RAND()*(9-0+1))+0 y 
      FROM cte_random 
      WHERE n < 1000
    )
-- SELECT n,y 
-- FROM cte_random;
-- select * from HourlyOEEValues ho order by id
 
 

update HourlyOEEValues hv
inner join cte_random rv
on hv.ID = rv.n
set scrap_count = 
case 

when rv.y = 0 and Hourly_planned_production_count = 1 then hv.Hourly_actual_production_count
when rv.y = 1 and Hourly_planned_production_count = 1 then 0
when rv.y = 2 and Hourly_planned_production_count = 1 then 0
when rv.y = 3 and Hourly_planned_production_count = 1 then 0
when rv.y = 4 and Hourly_planned_production_count = 1 then 0
when rv.y = 5 and Hourly_planned_production_count = 1 then 0
when rv.y = 6 and Hourly_planned_production_count = 1 then 0
when rv.y = 7 and Hourly_planned_production_count = 1 then 0
when rv.y = 8 and Hourly_planned_production_count = 1 then 0
when rv.y = 9 and Hourly_planned_production_count = 1 then 0


when rv.y = 0 and Hourly_actual_production_count >= 5 and Hourly_actual_production_count <= 10 then 1
when rv.y = 1 and Hourly_actual_production_count >= 5 and Hourly_actual_production_count <= 10 then 0
when rv.y = 2 and Hourly_actual_production_count >= 5 and Hourly_actual_production_count <= 10 then 0
when rv.y = 3 and Hourly_actual_production_count >= 5 and Hourly_actual_production_count <= 10 then 0
when rv.y = 4 and Hourly_actual_production_count >= 5 and Hourly_actual_production_count <= 10 then 0
when rv.y = 5 and Hourly_actual_production_count >= 5 and Hourly_actual_production_count <= 10 then 0
when rv.y = 6 and Hourly_actual_production_count >= 5 and Hourly_actual_production_count <= 10 then 0
when rv.y = 7 and Hourly_actual_production_count >= 5 and Hourly_actual_production_count <= 10 then 0
when rv.y = 8 and Hourly_actual_production_count >= 5 and Hourly_actual_production_count <= 10 then 0
when rv.y = 9 and Hourly_actual_production_count >= 5 and Hourly_actual_production_count <= 10 then 0


when rv.y = 0 and Hourly_actual_production_count >= 11 and Hourly_actual_production_count <= 20 then 1
when rv.y = 1 and Hourly_actual_production_count >= 11 and Hourly_actual_production_count <= 20 then 2
when rv.y = 2 and Hourly_actual_production_count >= 11 and Hourly_actual_production_count <= 20 then 0
when rv.y = 3 and Hourly_actual_production_count >= 11 and Hourly_actual_production_count <= 20 then 0
when rv.y = 4 and Hourly_actual_production_count >= 11 and Hourly_actual_production_count <= 20 then 0
when rv.y = 5 and Hourly_actual_production_count >= 11 and Hourly_actual_production_count <= 20 then 0
when rv.y = 6 and Hourly_actual_production_count >= 11 and Hourly_actual_production_count <= 20 then 0
when rv.y = 7 and Hourly_actual_production_count >= 11 and Hourly_actual_production_count <= 20 then 0
when rv.y = 8 and Hourly_actual_production_count >= 11 and Hourly_actual_production_count <= 20 then 0
when rv.y = 9 and Hourly_actual_production_count >= 11 and Hourly_actual_production_count <= 20 then 0

when rv.y = 0 and Hourly_actual_production_count >= 20 and Hourly_actual_production_count <= 30 then 1
when rv.y = 1 and Hourly_actual_production_count >= 20 and Hourly_actual_production_count <= 30 then 2
when rv.y = 2 and Hourly_actual_production_count >= 20 and Hourly_actual_production_count <= 30 then 3
when rv.y = 3 and Hourly_actual_production_count >= 20 and Hourly_actual_production_count <= 30 then 0
when rv.y = 4 and Hourly_actual_production_count >= 20 and Hourly_actual_production_count <= 30 then 0
when rv.y = 5 and Hourly_actual_production_count >= 20 and Hourly_actual_production_count <= 30 then 0
when rv.y = 6 and Hourly_actual_production_count >= 20 and Hourly_actual_production_count <= 30 then 0
when rv.y = 7 and Hourly_actual_production_count >= 20 and Hourly_actual_production_count <= 30 then 0
when rv.y = 8 and Hourly_actual_production_count >= 20 and Hourly_actual_production_count <= 30 then 0
when rv.y = 9 and Hourly_actual_production_count >= 20 and Hourly_actual_production_count <= 30 then 0

when rv.y = 0 and Hourly_actual_production_count >= 30 and Hourly_actual_production_count <= 40 then 1
when rv.y = 1 and Hourly_actual_production_count >= 30 and Hourly_actual_production_count <= 40 then 2
when rv.y = 2 and Hourly_actual_production_count >= 30 and Hourly_actual_production_count <= 40 then 3
when rv.y = 3 and Hourly_actual_production_count >= 30 and Hourly_actual_production_count <= 40 then 4
when rv.y = 4 and Hourly_actual_production_count >= 30 and Hourly_actual_production_count <= 40 then 0
when rv.y = 5 and Hourly_actual_production_count >= 30 and Hourly_actual_production_count <= 40 then 0
when rv.y = 6 and Hourly_actual_production_count >= 30 and Hourly_actual_production_count <= 40 then 0
when rv.y = 7 and Hourly_actual_production_count >= 30 and Hourly_actual_production_count <= 40 then 0
when rv.y = 8 and Hourly_actual_production_count >= 30 and Hourly_actual_production_count <= 40 then 0
when rv.y = 9 and Hourly_actual_production_count >= 30 and Hourly_actual_production_count <= 40 then 0

else 0

end 

select DISTINCT scrap_count from HourlyOEEValues ho 

select 
Workcenter_Code,
Part_number,
Data_hour,
Hourly_planned_production_count, 
Cumulative_planned_production_count,
Hourly_actual_production_count, 
Cumulative_actual_production_count,
Downtime_minutes,
scrap_count 
from HourlyOEEValues  hv 
where hv.Date_time_stamp = '2020-04-12 14:29:00'
-- and hv.Workcenter_Code = 'VSC_1'
order by Workcenter_Code, Data_hour 


select * from HourlyOEEValues 
where Date_time_stamp = '2020-03-29 14:29:00'
and Workcenter_Code =  'VSC_2'

select DISTINCT date_time_stamp from dbo.HourlyOEEValues 
/*
 * 
 2020-03-29 14:29:00
2020-04-05 14:29:00
2020-04-12 14:29:00
2020-04-19 14:29:00
2020-04-26 14:29:00
 */









select * from HourlyOEEValues


call InsertHourlyOEEValues ('VSC_1', '1201', '4140', 7, 1, 1, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_2', '1202', '4141', 7, 5, 5, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_3', '1203', '4142', 7, 10, 10, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_4', '1204', '4143', 7, 15, 15, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_5', '1205', '4144', 7, 20, 20, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_6', '1206', '4145', 7, 25, 25, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_7', '1207', '4146', 7, 30, 30, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_8', '1208', '4147', 7, 35, 35, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_9', '1209', '4150', 7, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_10', '1209', '4150', 7, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_11', '1209', '4150', 7, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_12', '1209', '4150', 7, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00');

call InsertHourlyOEEValues ('VSC_1', '1201', '4140', 8, 1, 1, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_2', '1202', '4141', 8, 5, 5, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_3', '1203', '4142', 8, 10, 10, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_4', '1204', '4143', 8, 15, 15, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_5', '1205', '4144', 8, 20, 20, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_6', '1206', '4145', 8, 25, 25, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_7', '1207', '4146', 8, 30, 30, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_8', '1208', '4147', 8, 35, 35, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_9', '1209', '4150', 8, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_10', '1209', '4150', 8, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_11', '1209', '4150', 8, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_12', '1209', '4150', 8, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00');

call InsertHourlyOEEValues ('VSC_1', '1201', '4140', 9, 1, 1, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_2', '1202', '4141', 9, 5, 5, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_3', '1203', '4142', 9, 10, 10, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_4', '1204', '4143', 9, 15, 15, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_5', '1205', '4144', 9, 20, 20, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_6', '1206', '4145', 9, 25, 25, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_7', '1207', '4146', 9, 30, 30, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_8', '1208', '4147', 9, 35, 35, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_9', '1209', '4150', 9, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_10', '1209', '4150', 9, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_11', '1209', '4150', 9, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_12', '1209', '4150', 9, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00');


call InsertHourlyOEEValues ('VSC_1', '1201', '4140',10, 1, 1, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_2', '1202', '4141',10, 5, 5, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_3', '1203', '4142',10, 10, 10, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_4', '1204', '4143',10, 15, 15, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_5', '1205', '4144',10, 20, 20, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_6', '1206', '4145',10, 25, 25, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_7', '1207', '4146',10, 30, 30, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_8', '1208', '4147',10, 35, 35, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_9', '1209', '4150',10, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_10', '1209', '4150',10, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_11', '1209', '4150',10, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_12', '1209', '4150',10, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00');

call InsertHourlyOEEValues ('VSC_1', '1201', '4140',11, 1, 1, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_2', '1202', '4141',11, 5, 5, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_3', '1203', '4142',11, 10, 10, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_4', '1204', '4143',11, 15, 15, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_5', '1205', '4144',11, 20, 20, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_6', '1206', '4145',11, 25, 25, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_7', '1207', '4146',11, 30, 30, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_8', '1208', '4147',11, 35, 35, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_9', '1209', '4150',11, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_10', '1209', '4150',11, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_11', '1209', '4150',11, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_12', '1209', '4150',11, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00');

call InsertHourlyOEEValues ('VSC_1', '1201', '4140',12, 1, 1, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_2', '1202', '4141',12, 5, 5, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_3', '1203', '4142',12, 10, 10, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_4', '1204', '4143',12, 15, 15, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_5', '1205', '4144',12, 20, 20, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_6', '1206', '4145',12, 25, 25, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_7', '1207', '4146',12, 30, 30, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_8', '1208', '4147',12, 35, 35, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_9', '1209', '4150',12, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_10', '1209', '4150',12, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_11', '1209', '4150',12, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_12', '1209', '4150',12, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00');

call InsertHourlyOEEValues ('VSC_1', '1201', '4140',13, 1, 1, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_2', '1202', '4141',13, 5, 5, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_3', '1203', '4142',13, 10, 10, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_4', '1204', '4143',13, 15, 15, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_5', '1205', '4144',13, 20, 20, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_6', '1206', '4145',13, 25, 25, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_7', '1207', '4146',13, 30, 30, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_8', '1208', '4147',13, 35, 35, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_9', '1209', '4150',13, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_10', '1209', '4150',13, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_11', '1209', '4150',13, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_12', '1209', '4150',13, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00');

call InsertHourlyOEEValues ('VSC_1', '1201', '4140',14, 1, 1, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_2', '1202', '4141',14, 5, 5, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_3', '1203', '4142',14, 10, 10, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_4', '1204', '4143',14, 15, 15, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_5', '1205', '4144',14, 20, 20, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_6', '1206', '4145',14, 25, 25, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_7', '1207', '4146',14, 30, 30, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_8', '1208', '4147',14, 35, 35, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_9', '1209', '4150',14, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_10', '1209', '4150',14, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_11', '1209', '4150',14, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00');
call InsertHourlyOEEValues ('VSC_12', '1209', '4150',14, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00');

call InsertHourlyOEEValues ('VSC_1', '1201', '4140', 7, 1, 1, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_2', '1202', '4141', 7, 5, 5, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_3', '1203', '4142', 7, 10, 10, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_4', '1204', '4143', 7, 15, 15, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_5', '1205', '4144', 7, 20, 20, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_6', '1206', '4145', 7, 25, 25, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_7', '1207', '4146', 7, 30, 30, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_8', '1208', '4147', 7, 35, 35, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_9', '1209', '4150', 7, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_10', '1209', '4150', 7, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_11', '1209', '4150', 7, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_12', '1209', '4150', 7, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00');

call InsertHourlyOEEValues ('VSC_1', '1201', '4140', 8, 1, 1, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_2', '1202', '4141', 8, 5, 5, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_3', '1203', '4142', 8, 10, 10, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_4', '1204', '4143', 8, 15, 15, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_5', '1205', '4144', 8, 20, 20, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_6', '1206', '4145', 8, 25, 25, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_7', '1207', '4146', 8, 30, 30, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_8', '1208', '4147', 8, 35, 35, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_9', '1209', '4150', 8, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_10', '1209', '4150', 8, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_11', '1209', '4150', 8, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_12', '1209', '4150', 8, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00');

call InsertHourlyOEEValues ('VSC_1', '1201', '4140', 9, 1, 1, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_2', '1202', '4141', 9, 5, 5, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_3', '1203', '4142', 9, 10, 10, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_4', '1204', '4143', 9, 15, 15, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_5', '1205', '4144', 9, 20, 20, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_6', '1206', '4145', 9, 25, 25, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_7', '1207', '4146', 9, 30, 30, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_8', '1208', '4147', 9, 35, 35, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_9', '1209', '4150', 9, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_10', '1209', '4150', 9, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_11', '1209', '4150', 9, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_12', '1209', '4150', 9, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00');


call InsertHourlyOEEValues ('VSC_1', '1201', '4140',10, 1, 1, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_2', '1202', '4141',10, 5, 5, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_3', '1203', '4142',10, 10, 10, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_4', '1204', '4143',10, 15, 15, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_5', '1205', '4144',10, 20, 20, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_6', '1206', '4145',10, 25, 25, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_7', '1207', '4146',10, 30, 30, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_8', '1208', '4147',10, 35, 35, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_9', '1209', '4150',10, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_10', '1209', '4150',10, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_11', '1209', '4150',10, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_12', '1209', '4150',10, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00');

call InsertHourlyOEEValues ('VSC_1', '1201', '4140',11, 1, 1, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_2', '1202', '4141',11, 5, 5, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_3', '1203', '4142',11, 10, 10, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_4', '1204', '4143',11, 15, 15, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_5', '1205', '4144',11, 20, 20, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_6', '1206', '4145',11, 25, 25, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_7', '1207', '4146',11, 30, 30, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_8', '1208', '4147',11, 35, 35, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_9', '1209', '4150',11, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_10', '1209', '4150',11, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_11', '1209', '4150',11, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_12', '1209', '4150',11, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00');

call InsertHourlyOEEValues ('VSC_1', '1201', '4140',12, 1, 1, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_2', '1202', '4141',12, 5, 5, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_3', '1203', '4142',12, 10, 10, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_4', '1204', '4143',12, 15, 15, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_5', '1205', '4144',12, 20, 20, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_6', '1206', '4145',12, 25, 25, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_7', '1207', '4146',12, 30, 30, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_8', '1208', '4147',12, 35, 35, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_9', '1209', '4150',12, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_10', '1209', '4150',12, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_11', '1209', '4150',12, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_12', '1209', '4150',12, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00');

call InsertHourlyOEEValues ('VSC_1', '1201', '4140',13, 1, 1, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_2', '1202', '4141',13, 5, 5, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_3', '1203', '4142',13, 10, 10, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_4', '1204', '4143',13, 15, 15, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_5', '1205', '4144',13, 20, 20, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_6', '1206', '4145',13, 25, 25, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_7', '1207', '4146',13, 30, 30, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_8', '1208', '4147',13, 35, 35, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_9', '1209', '4150',13, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_10', '1209', '4150',13, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_11', '1209', '4150',13, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_12', '1209', '4150',13, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00');

call InsertHourlyOEEValues ('VSC_1', '1201', '4140',14, 1, 1, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_2', '1202', '4141',14, 5, 5, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_3', '1203', '4142',14, 10, 10, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_4', '1204', '4143',14, 15, 15, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_5', '1205', '4144',14, 20, 20, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_6', '1206', '4145',14, 25, 25, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_7', '1207', '4146',14, 30, 30, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_8', '1208', '4147',14, 35, 35, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_9', '1209', '4150',14, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_10', '1209', '4150',14, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_11', '1209', '4150',14, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00');
call InsertHourlyOEEValues ('VSC_12', '1209', '4150',14, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00');

call InsertHourlyOEEValues ('VSC_1', '1201', '4140', 7, 1, 1, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_2', '1202', '4141', 7, 5, 5, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_3', '1203', '4142', 7, 10, 10, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_4', '1204', '4143', 7, 15, 15, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_5', '1205', '4144', 7, 20, 20, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_6', '1206', '4145', 7, 25, 25, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_7', '1207', '4146', 7, 30, 30, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_8', '1208', '4147', 7, 35, 35, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_9', '1209', '4150', 7, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_10', '1209', '4150', 7, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_11', '1209', '4150', 7, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_12', '1209', '4150', 7, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00');

call InsertHourlyOEEValues ('VSC_1', '1201', '4140', 8, 1, 1, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_2', '1202', '4141', 8, 5, 5, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_3', '1203', '4142', 8, 10, 10, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_4', '1204', '4143', 8, 15, 15, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_5', '1205', '4144', 8, 20, 20, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_6', '1206', '4145', 8, 25, 25, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_7', '1207', '4146', 8, 30, 30, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_8', '1208', '4147', 8, 35, 35, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_9', '1209', '4150', 8, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_10', '1209', '4150', 8, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_11', '1209', '4150', 8, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_12', '1209', '4150', 8, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00');

call InsertHourlyOEEValues ('VSC_1', '1201', '4140', 9, 1, 1, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_2', '1202', '4141', 9, 5, 5, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_3', '1203', '4142', 9, 10, 10, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_4', '1204', '4143', 9, 15, 15, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_5', '1205', '4144', 9, 20, 20, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_6', '1206', '4145', 9, 25, 25, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_7', '1207', '4146', 9, 30, 30, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_8', '1208', '4147', 9, 35, 35, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_9', '1209', '4150', 9, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_10', '1209', '4150', 9, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_11', '1209', '4150', 9, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_12', '1209', '4150', 9, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00');


call InsertHourlyOEEValues ('VSC_1', '1201', '4140',10, 1, 1, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_2', '1202', '4141',10, 5, 5, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_3', '1203', '4142',10, 10, 10, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_4', '1204', '4143',10, 15, 15, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_5', '1205', '4144',10, 20, 20, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_6', '1206', '4145',10, 25, 25, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_7', '1207', '4146',10, 30, 30, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_8', '1208', '4147',10, 35, 35, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_9', '1209', '4150',10, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_10', '1209', '4150',10, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_11', '1209', '4150',10, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_12', '1209', '4150',10, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00');

call InsertHourlyOEEValues ('VSC_1', '1201', '4140',11, 1, 1, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_2', '1202', '4141',11, 5, 5, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_3', '1203', '4142',11, 10, 10, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_4', '1204', '4143',11, 15, 15, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_5', '1205', '4144',11, 20, 20, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_6', '1206', '4145',11, 25, 25, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_7', '1207', '4146',11, 30, 30, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_8', '1208', '4147',11, 35, 35, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_9', '1209', '4150',11, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_10', '1209', '4150',11, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_11', '1209', '4150',11, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_12', '1209', '4150',11, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00');

call InsertHourlyOEEValues ('VSC_1', '1201', '4140',12, 1, 1, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_2', '1202', '4141',12, 5, 5, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_3', '1203', '4142',12, 10, 10, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_4', '1204', '4143',12, 15, 15, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_5', '1205', '4144',12, 20, 20, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_6', '1206', '4145',12, 25, 25, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_7', '1207', '4146',12, 30, 30, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_8', '1208', '4147',12, 35, 35, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_9', '1209', '4150',12, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_10', '1209', '4150',12, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_11', '1209', '4150',12, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_12', '1209', '4150',12, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00');

call InsertHourlyOEEValues ('VSC_1', '1201', '4140',13, 1, 1, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_2', '1202', '4141',13, 5, 5, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_3', '1203', '4142',13, 10, 10, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_4', '1204', '4143',13, 15, 15, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_5', '1205', '4144',13, 20, 20, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_6', '1206', '4145',13, 25, 25, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_7', '1207', '4146',13, 30, 30, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_8', '1208', '4147',13, 35, 35, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_9', '1209', '4150',13, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_10', '1209', '4150',13, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_11', '1209', '4150',13, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_12', '1209', '4150',13, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00');

call InsertHourlyOEEValues ('VSC_1', '1201', '4140',14, 1, 1, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_2', '1202', '4141',14, 5, 5, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_3', '1203', '4142',14, 10, 10, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_4', '1204', '4143',14, 15, 15, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_5', '1205', '4144',14, 20, 20, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_6', '1206', '4145',14, 25, 25, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_7', '1207', '4146',14, 30, 30, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_8', '1208', '4147',14, 35, 35, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_9', '1209', '4150',14, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_10', '1209', '4150',14, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_11', '1209', '4150',14, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00');
call InsertHourlyOEEValues ('VSC_12', '1209', '4150',14, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00');


 
call InsertHourlyOEEValues ('VSC_1', '1201', '4140', 7, 1, 1, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_2', '1202', '4141', 7, 5, 5, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_3', '1203', '4142', 7, 10, 10, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_4', '1204', '4143', 7, 15, 15, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_5', '1205', '4144', 7, 20, 20, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_6', '1206', '4145', 7, 25, 25, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_7', '1207', '4146', 7, 30, 30, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_8', '1208', '4147', 7, 35, 35, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_9', '1209', '4150', 7, 38, 38, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_10', '1209', '4150', 7, 38, 38, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_11', '1209', '4150', 7, 38, 38, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_12', '1209', '4150', 7, 38, 38, 834,582, 0, 0,'2020-04-19 14:29');

call InsertHourlyOEEValues ('VSC_1', '1201', '4140', 8, 1, 1, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_2', '1202', '4141', 8, 5, 5, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_3', '1203', '4142', 8, 10, 10, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_4', '1204', '4143', 8, 15, 15, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_5', '1205', '4144', 8, 20, 20, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_6', '1206', '4145', 8, 25, 25, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_7', '1207', '4146', 8, 30, 30, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_8', '1208', '4147', 8, 35, 35, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_9', '1209', '4150', 8, 38, 38, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_10', '1209', '4150', 8, 38, 38, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_11', '1209', '4150', 8, 38, 38, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_12', '1209', '4150', 8, 38, 38, 834,582, 0, 0,'2020-04-19 14:29');

call InsertHourlyOEEValues ('VSC_1', '1201', '4140', 9, 1, 1, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_2', '1202', '4141', 9, 5, 5, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_3', '1203', '4142', 9, 10, 10, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_4', '1204', '4143', 9, 15, 15, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_5', '1205', '4144', 9, 20, 20, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_6', '1206', '4145', 9, 25, 25, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_7', '1207', '4146', 9, 30, 30, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_8', '1208', '4147', 9, 35, 35, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_9', '1209', '4150', 9, 38, 38, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_10', '1209', '4150', 9, 38, 38, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_11', '1209', '4150', 9, 38, 38, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_12', '1209', '4150', 9, 38, 38, 834,582, 0, 0,'2020-04-19 14:29');


call InsertHourlyOEEValues ('VSC_1', '1201', '4140',10, 1, 1, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_2', '1202', '4141',10, 5, 5, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_3', '1203', '4142',10, 10, 10, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_4', '1204', '4143',10, 15, 15, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_5', '1205', '4144',10, 20, 20, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_6', '1206', '4145',10, 25, 25, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_7', '1207', '4146',10, 30, 30, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_8', '1208', '4147',10, 35, 35, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_9', '1209', '4150',10, 38, 38, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_10', '1209', '4150',10, 38, 38, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_11', '1209', '4150',10, 38, 38, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_12', '1209', '4150',10, 38, 38, 834,582, 0, 0,'2020-04-19 14:29');

call InsertHourlyOEEValues ('VSC_1', '1201', '4140',11, 1, 1, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_2', '1202', '4141',11, 5, 5, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_3', '1203', '4142',11, 10, 10, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_4', '1204', '4143',11, 15, 15, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_5', '1205', '4144',11, 20, 20, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_6', '1206', '4145',11, 25, 25, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_7', '1207', '4146',11, 30, 30, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_8', '1208', '4147',11, 35, 35, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_9', '1209', '4150',11, 38, 38, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_10', '1209', '4150',11, 38, 38, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_11', '1209', '4150',11, 38, 38, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_12', '1209', '4150',11, 38, 38, 834,582, 0, 0,'2020-04-19 14:29');

call InsertHourlyOEEValues ('VSC_1', '1201', '4140',12, 1, 1, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_2', '1202', '4141',12, 5, 5, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_3', '1203', '4142',12, 10, 10, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_4', '1204', '4143',12, 15, 15, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_5', '1205', '4144',12, 20, 20, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_6', '1206', '4145',12, 25, 25, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_7', '1207', '4146',12, 30, 30, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_8', '1208', '4147',12, 35, 35, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_9', '1209', '4150',12, 38, 38, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_10', '1209', '4150',12, 38, 38, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_11', '1209', '4150',12, 38, 38, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_12', '1209', '4150',12, 38, 38, 834,582, 0, 0,'2020-04-19 14:29');

call InsertHourlyOEEValues ('VSC_1', '1201', '4140',13, 1, 1, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_2', '1202', '4141',13, 5, 5, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_3', '1203', '4142',13, 10, 10, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_4', '1204', '4143',13, 15, 15, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_5', '1205', '4144',13, 20, 20, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_6', '1206', '4145',13, 25, 25, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_7', '1207', '4146',13, 30, 30, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_8', '1208', '4147',13, 35, 35, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_9', '1209', '4150',13, 38, 38, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_10', '1209', '4150',13, 38, 38, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_11', '1209', '4150',13, 38, 38, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_12', '1209', '4150',13, 38, 38, 834,582, 0, 0,'2020-04-19 14:29');

call InsertHourlyOEEValues ('VSC_1', '1201', '4140',14, 1, 1, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_2', '1202', '4141',14, 5, 5, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_3', '1203', '4142',14, 10, 10, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_4', '1204', '4143',14, 15, 15, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_5', '1205', '4144',14, 20, 20, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_6', '1206', '4145',14, 25, 25, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_7', '1207', '4146',14, 30, 30, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_8', '1208', '4147',14, 35, 35, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_9', '1209', '4150',14, 38, 38, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_10', '1209', '4150',14, 38, 38, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_11', '1209', '4150',14, 38, 38, 834,582, 0, 0,'2020-04-19 14:29');
call InsertHourlyOEEValues ('VSC_12', '1209', '4150',14, 38, 38, 834,582, 0, 0,'2020-04-19 14:29');

call InsertHourlyOEEValues ('VSC_1', '1201', '4140', 7, 1, 1, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_2', '1202', '4141', 7, 5, 5, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_3', '1203', '4142', 7, 10, 10, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_4', '1204', '4143', 7, 15, 15, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_5', '1205', '4144', 7, 20, 20, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_6', '1206', '4145', 7, 25, 25, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_7', '1207', '4146', 7, 30, 30, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_8', '1208', '4147', 7, 35, 35, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_9', '1209', '4150', 7, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_10', '1209', '4150', 7, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_11', '1209', '4150', 7, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_12', '1209', '4150', 7, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00');

call InsertHourlyOEEValues ('VSC_1', '1201', '4140', 8, 1, 1, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_2', '1202', '4141', 8, 5, 5, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_3', '1203', '4142', 8, 10, 10, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_4', '1204', '4143', 8, 15, 15, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_5', '1205', '4144', 8, 20, 20, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_6', '1206', '4145', 8, 25, 25, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_7', '1207', '4146', 8, 30, 30, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_8', '1208', '4147', 8, 35, 35, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_9', '1209', '4150', 8, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_10', '1209', '4150', 8, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_11', '1209', '4150', 8, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_12', '1209', '4150', 8, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00');

call InsertHourlyOEEValues ('VSC_1', '1201', '4140', 9, 1, 1, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_2', '1202', '4141', 9, 5, 5, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_3', '1203', '4142', 9, 10, 10, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_4', '1204', '4143', 9, 15, 15, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_5', '1205', '4144', 9, 20, 20, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_6', '1206', '4145', 9, 25, 25, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_7', '1207', '4146', 9, 30, 30, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_8', '1208', '4147', 9, 35, 35, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_9', '1209', '4150', 9, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_10', '1209', '4150', 9, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_11', '1209', '4150', 9, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_12', '1209', '4150', 9, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00');


call InsertHourlyOEEValues ('VSC_1', '1201', '4140',10, 1, 1, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_2', '1202', '4141',10, 5, 5, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_3', '1203', '4142',10, 10, 10, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_4', '1204', '4143',10, 15, 15, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_5', '1205', '4144',10, 20, 20, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_6', '1206', '4145',10, 25, 25, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_7', '1207', '4146',10, 30, 30, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_8', '1208', '4147',10, 35, 35, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_9', '1209', '4150',10, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_10', '1209', '4150',10, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_11', '1209', '4150',10, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_12', '1209', '4150',10, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00');

call InsertHourlyOEEValues ('VSC_1', '1201', '4140',11, 1, 1, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_2', '1202', '4141',11, 5, 5, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_3', '1203', '4142',11, 10, 10, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_4', '1204', '4143',11, 15, 15, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_5', '1205', '4144',11, 20, 20, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_6', '1206', '4145',11, 25, 25, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_7', '1207', '4146',11, 30, 30, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_8', '1208', '4147',11, 35, 35, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_9', '1209', '4150',11, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_10', '1209', '4150',11, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_11', '1209', '4150',11, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_12', '1209', '4150',11, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00');

call InsertHourlyOEEValues ('VSC_1', '1201', '4140',12, 1, 1, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_2', '1202', '4141',12, 5, 5, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_3', '1203', '4142',12, 10, 10, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_4', '1204', '4143',12, 15, 15, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_5', '1205', '4144',12, 20, 20, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_6', '1206', '4145',12, 25, 25, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_7', '1207', '4146',12, 30, 30, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_8', '1208', '4147',12, 35, 35, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_9', '1209', '4150',12, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_10', '1209', '4150',12, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_11', '1209', '4150',12, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_12', '1209', '4150',12, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00');

call InsertHourlyOEEValues ('VSC_1', '1201', '4140',13, 1, 1, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_2', '1202', '4141',13, 5, 5, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_3', '1203', '4142',13, 10, 10, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_4', '1204', '4143',13, 15, 15, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_5', '1205', '4144',13, 20, 20, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_6', '1206', '4145',13, 25, 25, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_7', '1207', '4146',13, 30, 30, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_8', '1208', '4147',13, 35, 35, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_9', '1209', '4150',13, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_10', '1209', '4150',13, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_11', '1209', '4150',13, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_12', '1209', '4150',13, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00');

call InsertHourlyOEEValues ('VSC_1', '1201', '4140',14, 1, 1, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_2', '1202', '4141',14, 5, 5, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_3', '1203', '4142',14, 10, 10, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_4', '1204', '4143',14, 15, 15, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_5', '1205', '4144',14, 20, 20, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_6', '1206', '4145',14, 25, 25, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_7', '1207', '4146',14, 30, 30, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_8', '1208', '4147',14, 35, 35, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_9', '1209', '4150',14, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_10', '1209', '4150',14, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_11', '1209', '4150',14, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00');
call InsertHourlyOEEValues ('VSC_12', '1209', '4150',14, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00');


select DISTINCT Date_time_stamp  
from HourlyOEEValues 

select 
Workcenter_Code,
Part_number,
Data_hour,
Hourly_planned_production_count, 
Cumulative_planned_production_count,
Hourly_actual_production_count, 
Cumulative_actual_production_count
from HourlyOEEValues  hv 
where hv.Date_time_stamp = '2020-04-12 14:29:00'


select count(*) from HourlyOEEValues ho 




















exec InsertHourlyOEEValues ' VSC_1', '1201', '4140', 7, 41, 38, 834,582, 0, 0,'2020-03-29 14:29'
exec InsertHourlyOEEValues ' VSC_2', '1202', '4141', 7, 41, 38, 834,582, 0, 0,'2020-03-29 14:29'
exec InsertHourlyOEEValues ' VSC_3', '1203', '4142', 7, 41, 38, 834,582, 0, 0,'2020-03-29 14:29'
exec InsertHourlyOEEValues ' VSC_4', '1204', '4143', 7, 41, 38, 834,582, 0, 0,'2020-03-29 14:29'
exec InsertHourlyOEEValues ' VSC_5', '1205', '4140', 7, 41, 38, 834,582, 0, 0,'2020-03-29 14:29'
exec InsertHourlyOEEValues ' VSC_6', '1206', '4141', 7, 41, 38, 834,582, 0, 0,'2020-03-29 14:29'
exec InsertHourlyOEEValues ' VSC_7', '1207', '4142', 7, 41, 38, 834,582, 0, 0,'2020-03-29 14:29'
exec InsertHourlyOEEValues ' VSC_8', '1208', '4143', 7, 41, 38, 834,582, 0, 0,'2020-03-29 14:29'
exec InsertHourlyOEEValues ' VSC_9', '1209', '4140', 7, 41, 38, 834,582, 0, 0,'2020-03-29 14:29'
exec InsertHourlyOEEValues ' VSC_10', '1210', '4141', 7, 41, 38, 834,582, 0, 0,'2020-03-29 14:29'
exec InsertHourlyOEEValues ' VSC_11', '1211', '4142', 7, 41, 38, 834,582, 0, 0,'2020-03-29 14:29'
exec InsertHourlyOEEValues ' VSC_12', '1212', '4143', 7, 41, 38, 834,582, 0, 0,'2020-03-29 14:29'

exec InsertHourlyOEEValues ' VSC_5', '1210', '4140', 8, 41, 38, 834,582, 0, 0,'2020-03-29 14:29'
exec InsertHourlyOEEValues ' VSC_6', '1211', '4141', 8, 41, 38, 834,582, 0, 0,'2020-03-29 14:29'
exec InsertHourlyOEEValues ' VSC_7', '1212', '4142', 8, 41, 38, 834,582, 0, 0,'2020-03-29 14:29'
exec InsertHourlyOEEValues ' VSC_8', '1213', '4143', 8, 41, 38, 834,582, 0, 0,'2020-03-29 14:29'

exec InsertHourlyOEEValues ' VSC_5', '1210', '4140', 9, 41, 38, 834,582, 0, 0,'2020-03-29 14:29'
exec InsertHourlyOEEValues ' VSC_6', '1211', '4141', 9, 41, 38, 834,582, 0, 0,'2020-03-29 14:29'
exec InsertHourlyOEEValues ' VSC_7', '1212', '4142', 9, 41, 38, 834,582, 0, 0,'2020-03-29 14:29'
exec InsertHourlyOEEValues ' VSC_8', '1213', '4143', 9, 41, 38, 834,582, 0, 0,'2020-03-29 14:29'

exec InsertHourlyOEEValues ' VSC_5', '1210', '4140', 10, 41, 38, 834,582, 0, 0,'2020-03-29 14:29'
exec InsertHourlyOEEValues ' VSC_6', '1211', '4141', 10, 41, 38, 834,582, 0, 0,'2020-03-29 14:29'
exec InsertHourlyOEEValues ' VSC_7', '1212', '4142', 10, 41, 38, 834,582, 0, 0,'2020-03-29 14:29'
exec InsertHourlyOEEValues ' VSC_8', '1213', '4143', 10, 41, 38, 834,582, 0, 0,'2020-03-29 14:29'

exec InsertHourlyOEEValues ' VSC_5', '1210', '4140', 11, 41, 38, 834,582, 0, 0,'2020-03-29 14:29'
exec InsertHourlyOEEValues ' VSC_6', '1211', '4141', 11, 41, 38, 834,582, 0, 0,'2020-03-29 14:29'
exec InsertHourlyOEEValues ' VSC_7', '1212', '4142', 11, 41, 38, 834,582, 0, 0,'2020-03-29 14:29'
exec InsertHourlyOEEValues ' VSC_8', '1213', '4143', 11, 41, 38, 834,582, 0, 0,'2020-03-29 14:29'

delete hourlyoeevalues
--select * 
from hourlyoeevalues
where id = 86
where workcenter_code = 'VSC_5' 
and date_time_stamp = '2020-03-29 14:29'
and data_hour = 11

exec InsertHourlyOEEValues ' VSC_5', '1210', '4140', 12, 41, 38, 834,582, 0, 0,'2020-03-29 14:29'
exec InsertHourlyOEEValues ' VSC_6', '1211', '4141', 12, 41, 38, 834,582, 0, 0,'2020-03-29 14:29'
exec InsertHourlyOEEValues ' VSC_7', '1212', '4142', 12, 41, 38, 834,582, 0, 0,'2020-03-29 14:29'
exec InsertHourlyOEEValues ' VSC_8', '1213', '4143', 12, 41, 38, 834,582, 0, 0,'2020-03-29 14:29'

exec InsertHourlyOEEValues ' VSC_5', '1210', '4140', 13, 41, 38, 834,582, 0, 0,'2020-03-29 14:29'
exec InsertHourlyOEEValues ' VSC_6', '1211', '4141', 13, 41, 38, 834,582, 0, 0,'2020-03-29 14:29'
exec InsertHourlyOEEValues ' VSC_7', '1212', '4142', 13, 41, 38, 834,582, 0, 0,'2020-03-29 14:29'
exec InsertHourlyOEEValues ' VSC_8', '1213', '4143', 13, 41, 38, 834,582, 0, 0,'2020-03-29 14:29'

exec InsertHourlyOEEValues ' VSC_5', '1210', '4140', 14, 41, 38, 834,582, 0, 0,'2020-03-29 14:29'
exec InsertHourlyOEEValues ' VSC_6', '1211', '4141', 14, 41, 38, 834,582, 0, 0,'2020-03-29 14:29'
exec InsertHourlyOEEValues ' VSC_7', '1212', '4142', 14, 41, 38, 834,582, 0, 0,'2020-03-29 14:29'
exec InsertHourlyOEEValues ' VSC_8', '1213', '4143', 14, 41, 38, 834,582, 0, 0,'2020-03-29 14:29'

exec InsertHourlyOEEValues ' VSC_5', '1210', '4140', 7, 41, 38, 834,582, 0, 0,'2020-04-05 14:29'
exec InsertHourlyOEEValues ' VSC_6', '1211', '4141', 7, 41, 38, 834,582, 0, 0,'2020-04-05 14:29'
exec InsertHourlyOEEValues ' VSC_7', '1212', '4142', 7, 41, 38, 834,582, 0, 0,'2020-04-05 14:29'
exec InsertHourlyOEEValues ' VSC_8', '1213', '4143', 7, 41, 38, 834,582, 0, 0,'2020-04-05 14:29'

exec InsertHourlyOEEValues ' VSC_5', '1210', '4140', 8, 41, 38, 834,582, 0, 0,'2020-04-05 14:29'
exec InsertHourlyOEEValues ' VSC_6', '1211', '4141', 8, 41, 38, 834,582, 0, 0,'2020-04-05 14:29'
exec InsertHourlyOEEValues ' VSC_7', '1212', '4142', 8, 41, 38, 834,582, 0, 0,'2020-04-05 14:29'
exec InsertHourlyOEEValues ' VSC_8', '1213', '4143', 8, 41, 38, 834,582, 0, 0,'2020-04-05 14:29'

exec InsertHourlyOEEValues ' VSC_5', '1210', '4140', 9, 41, 38, 834,582, 0, 0,'2020-04-05 14:29'
exec InsertHourlyOEEValues ' VSC_6', '1211', '4141', 9, 41, 38, 834,582, 0, 0,'2020-04-05 14:29'
exec InsertHourlyOEEValues ' VSC_7', '1212', '4142', 9, 41, 38, 834,582, 0, 0,'2020-04-05 14:29'
exec InsertHourlyOEEValues ' VSC_8', '1213', '4143', 9, 41, 38, 834,582, 0, 0,'2020-04-05 14:29'

exec InsertHourlyOEEValues ' VSC_5', '1210', '4140', 10, 41, 38, 834,582, 0, 0,'2020-04-05 14:29'
exec InsertHourlyOEEValues ' VSC_6', '1211', '4141', 10, 41, 38, 834,582, 0, 0,'2020-04-05 14:29'
exec InsertHourlyOEEValues ' VSC_7', '1212', '4142', 10, 41, 38, 834,582, 0, 0,'2020-04-05 14:29'
exec InsertHourlyOEEValues ' VSC_8', '1213', '4143', 10, 41, 38, 834,582, 0, 0,'2020-04-05 14:29'

exec InsertHourlyOEEValues ' VSC_5', '1210', '4140', 11, 41, 38, 834,582, 0, 0,'2020-04-05 14:29'
exec InsertHourlyOEEValues ' VSC_6', '1211', '4141', 11, 41, 38, 834,582, 0, 0,'2020-04-05 14:29'
exec InsertHourlyOEEValues ' VSC_7', '1212', '4142', 11, 41, 38, 834,582, 0, 0,'2020-04-05 14:29'
exec InsertHourlyOEEValues ' VSC_8', '1213', '4143', 11, 41, 38, 834,582, 0, 0,'2020-04-05 14:29'
exec InsertHourlyOEEValues ' VSC_5', '1210', '4140', 11, 41, 38, 834,582, 0, 0,'2020-04-05 14:29'

exec InsertHourlyOEEValues ' VSC_5', '1210', '4140', 12, 41, 38, 834,582, 0, 0,'2020-04-05 14:29'
exec InsertHourlyOEEValues ' VSC_6', '1211', '4141', 12, 41, 38, 834,582, 0, 0,'2020-04-05 14:29'
exec InsertHourlyOEEValues ' VSC_7', '1212', '4142', 12, 41, 38, 834,582, 0, 0,'2020-04-05 14:29'
exec InsertHourlyOEEValues ' VSC_8', '1213', '4143', 12, 41, 38, 834,582, 0, 0,'2020-04-05 14:29'

exec InsertHourlyOEEValues ' VSC_5', '1210', '4140', 13, 41, 38, 834,582, 0, 0,'2020-04-05 14:29'
exec InsertHourlyOEEValues ' VSC_6', '1211', '4141', 13, 41, 38, 834,582, 0, 0,'2020-04-05 14:29'
exec InsertHourlyOEEValues ' VSC_7', '1212', '4142', 13, 41, 38, 834,582, 0, 0,'2020-04-05 14:29'
exec InsertHourlyOEEValues ' VSC_8', '1213', '4143', 13, 41, 38, 834,582, 0, 0,'2020-04-05 14:29'

exec InsertHourlyOEEValues ' VSC_5', '1210', '4140', 14, 41, 38, 834,582, 0, 0,'2020-04-05 14:29'
exec InsertHourlyOEEValues ' VSC_6', '1211', '4141', 14, 41, 38, 834,582, 0, 0,'2020-04-05 14:29'
exec InsertHourlyOEEValues ' VSC_7', '1212', '4142', 14, 41, 38, 834,582, 0, 0,'2020-04-05 14:29'
exec InsertHourlyOEEValues ' VSC_8', '1213', '4143', 14, 41, 38, 834,582, 0, 0,'2020-04-05 14:29'

exec InsertHourlyOEEValues ' VSC_5', '1210', '4140', 7, 41, 38, 834,582, 0, 0,'2020-04-12 14:29'
exec InsertHourlyOEEValues ' VSC_6', '1211', '4141', 7, 41, 38, 834,582, 0, 0,'2020-04-12 14:29'
exec InsertHourlyOEEValues ' VSC_7', '1212', '4142', 7, 41, 38, 834,582, 0, 0,'2020-04-12 14:29'
exec InsertHourlyOEEValues ' VSC_8', '1213', '4143', 7, 41, 38, 834,582, 0, 0,'2020-04-12 14:29'

exec InsertHourlyOEEValues ' VSC_5', '1210', '4140', 8, 41, 38, 834,582, 0, 0,'2020-04-12 14:29'
exec InsertHourlyOEEValues ' VSC_6', '1211', '4141', 8, 41, 38, 834,582, 0, 0,'2020-04-12 14:29'
exec InsertHourlyOEEValues ' VSC_7', '1212', '4142', 8, 41, 38, 834,582, 0, 0,'2020-04-12 14:29'
exec InsertHourlyOEEValues ' VSC_8', '1213', '4143', 8, 41, 38, 834,582, 0, 0,'2020-04-12 14:29'

exec InsertHourlyOEEValues ' VSC_5', '1210', '4140', 9, 41, 38, 834,582, 0, 0,'2020-04-12 14:29'
exec InsertHourlyOEEValues ' VSC_6', '1211', '4141', 9, 41, 38, 834,582, 0, 0,'2020-04-12 14:29'
exec InsertHourlyOEEValues ' VSC_7', '1212', '4142', 9, 41, 38, 834,582, 0, 0,'2020-04-12 14:29'
exec InsertHourlyOEEValues ' VSC_8', '1213', '4143', 9, 41, 38, 834,582, 0, 0,'2020-04-12 14:29'

exec InsertHourlyOEEValues ' VSC_5', '1210', '4140', 10, 41, 38, 834,582, 0, 0,'2020-04-12 14:29'
exec InsertHourlyOEEValues ' VSC_6', '1211', '4141', 10, 41, 38, 834,582, 0, 0,'2020-04-12 14:29'
exec InsertHourlyOEEValues ' VSC_7', '1212', '4142', 10, 41, 38, 834,582, 0, 0,'2020-04-12 14:29'
exec InsertHourlyOEEValues ' VSC_8', '1213', '4143', 10, 41, 38, 834,582, 0, 0,'2020-04-12 14:29'

exec InsertHourlyOEEValues ' VSC_5', '1210', '4140', 11, 41, 38, 834,582, 0, 0,'2020-04-12 14:29'
exec InsertHourlyOEEValues ' VSC_6', '1211', '4141', 11, 41, 38, 834,582, 0, 0,'2020-04-12 14:29'
exec InsertHourlyOEEValues ' VSC_7', '1212', '4142', 11, 41, 38, 834,582, 0, 0,'2020-04-12 14:29'
exec InsertHourlyOEEValues ' VSC_8', '1213', '4143', 11, 41, 38, 834,582, 0, 0,'2020-04-12 14:29'
exec InsertHourlyOEEValues ' VSC_5', '1210', '4140', 11, 41, 38, 834,582, 0, 0,'2020-04-12 14:29'

exec InsertHourlyOEEValues ' VSC_5', '1210', '4140', 12, 41, 38, 834,582, 0, 0,'2020-04-12 14:29'
exec InsertHourlyOEEValues ' VSC_6', '1211', '4141', 12, 41, 38, 834,582, 0, 0,'2020-04-12 14:29'
exec InsertHourlyOEEValues ' VSC_7', '1212', '4142', 12, 41, 38, 834,582, 0, 0,'2020-04-12 14:29'
exec InsertHourlyOEEValues ' VSC_8', '1213', '4143', 12, 41, 38, 834,582, 0, 0,'2020-04-12 14:29'

exec InsertHourlyOEEValues ' VSC_5', '1210', '4140', 13, 41, 38, 834,582, 0, 0,'2020-04-12 14:29'
exec InsertHourlyOEEValues ' VSC_6', '1211', '4141', 13, 41, 38, 834,582, 0, 0,'2020-04-12 14:29'
exec InsertHourlyOEEValues ' VSC_7', '1212', '4142', 13, 41, 38, 834,582, 0, 0,'2020-04-12 14:29'
exec InsertHourlyOEEValues ' VSC_8', '1213', '4143', 13, 41, 38, 834,582, 0, 0,'2020-04-12 14:29'

exec InsertHourlyOEEValues ' VSC_5', '1210', '4140', 14, 41, 38, 834,582, 0, 0,'2020-04-12 14:29'
exec InsertHourlyOEEValues ' VSC_6', '1211', '4141', 14, 41, 38, 834,582, 0, 0,'2020-04-12 14:29'
exec InsertHourlyOEEValues ' VSC_7', '1212', '4142', 14, 41, 38, 834,582, 0, 0,'2020-04-12 14:29'
exec InsertHourlyOEEValues ' VSC_8', '1213', '4143', 14, 41, 38, 834,582, 0, 0,'2020-04-12 14:29'

--delete from hourlyoeevalues
select 
--top(100)
*
--into hourlyoeevalues0213 
from hourlyoeevalues
select 
top(100) *
--count(*) cnt --14808
from hourlyoeevalues0213

