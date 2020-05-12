


update HourlyOEEValues 
set Cumulative_planned_production_count = Hourly_planned_production_count * (Data_hour - 6)
from HourlyOEEValues hv


with randowvalues
    as(
    -- generates a 0 based number from 0 to number - 1
       select 1 id, CAST(RAND(CHECKSUM(NEWID()))*10 as int) randomnumber
        union  all
        select id + 1, CAST(RAND(CHECKSUM(NEWID()))*10 as int)  randomnumber
		--select id + 1, RAND(CHECKSUM(NEWID()))*100  randomnumber
        from randowvalues
        where 
          id < 1000
      )

--select Hourly_actual_production_count 
--from HourlyOEEValues 
--where Data_hour < = current.Data_hour 


update HourlyOEEValues 
set Hourly_actual_production_count = 
case 
when rv.randomnumber = 0 and Hourly_planned_production_count = 1 then 0
when rv.randomnumber = 1 and Hourly_planned_production_count = 1 then 0
when rv.randomnumber = 2 and Hourly_planned_production_count = 1 then 2
when rv.randomnumber = 3 and Hourly_planned_production_count = 1 then 1
when rv.randomnumber = 4 and Hourly_planned_production_count = 1 then 1
when rv.randomnumber = 5 and Hourly_planned_production_count = 1 then 1
when rv.randomnumber = 6 and Hourly_planned_production_count = 1 then 1
when rv.randomnumber = 7 and Hourly_planned_production_count = 1 then 1
when rv.randomnumber = 8 and Hourly_planned_production_count = 1 then 1
when rv.randomnumber = 9 and Hourly_planned_production_count = 1 then 1
when rv.randomnumber = 0 and Hourly_planned_production_count <> 1 then Hourly_planned_production_count * 1.1
when rv.randomnumber = 1 and Hourly_planned_production_count <> 1 then Hourly_planned_production_count * 1.0
when rv.randomnumber = 2 and Hourly_planned_production_count <> 1 then Hourly_planned_production_count * 0.9
when rv.randomnumber = 3 and Hourly_planned_production_count <> 1 then Hourly_planned_production_count * 0.85
when rv.randomnumber = 4 and Hourly_planned_production_count <> 1 then Hourly_planned_production_count * 0.85
when rv.randomnumber = 5 and Hourly_planned_production_count <> 1 then Hourly_planned_production_count * 0.85
when rv.randomnumber = 6 and Hourly_planned_production_count <> 1 then Hourly_planned_production_count * 0.85
when rv.randomnumber = 7 and Hourly_planned_production_count <> 1 then Hourly_planned_production_count * 0.75
when rv.randomnumber = 8 and Hourly_planned_production_count <> 1 then Hourly_planned_production_count * 0.65
when rv.randomnumber = 9 and Hourly_planned_production_count <> 1 then Hourly_planned_production_count * 0.50
end 
--set scrap_count = rv.randomnumber
from HourlyOEEValues hv
inner join randowvalues rv
on hv.ID - 65 = rv.id
OPTION(MAXRECURSION 1000)
--select id from HourlyOEEValues  order by id


update dbo.HourlyOEEValues 
set Cumulative_actual_production_count =
(
	select sum(Hourly_actual_production_count)
	from HourlyOEEValues inh
	where inh.data_hour <= hv.data_hour
	and inh.Date_time_stamp = hv.date_time_stamp
	and inh.Workcenter_Code = hv.Workcenter_Code 
) 
from HourlyOEEValues hv
/* MYSQL
update 
HourlyOEEValues as hv 
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
) as inh on hv.Date_time_stamp = inh.Date_time_stamp
and hv.Workcenter_Code = inh.Workcenter_Code
and hv.Data_hour = inh.Data_hour 
set hv.Cumulative_actual_production_count = inh.Cumulative_actual_production_count
-- from HourlyOEEValues hv
where hv.Date_time_stamp = '2020-03-29 14:29:00'
and Workcenter_Code = 'VSC_3'
 */

with cte_random(n,y)
    as(
    -- generates a 0 based number from 0 to number - 1
       select 66 n, CAST(RAND(CHECKSUM(NEWID()))*10 as int) y
        union  all
        select n + 1, CAST(RAND(CHECKSUM(NEWID()))*10 as int) y
		--select id + 1, RAND(CHECKSUM(NEWID()))*100  randomnumber
        from cte_random
        where 
          n < 1000
      )

update HourlyOEEValues 
set Downtime_minutes = 
case 
when hv.Hourly_actual_production_count = 0  then 60
when rv.y = 0 then 0
when rv.y = 1 then 15
when rv.y = 2 then 30
when rv.y = 3 then 45
when rv.y = 4 then 60
when rv.y = 5 then 0
when rv.y = 6 then 0
when rv.y = 7 then 0
when rv.y = 8 then 0
when rv.y = 9 then 0

end 
from HourlyOEEValues hv
inner join cte_random rv
on hv.ID = rv.n
OPTION(MAXRECURSION 1000)



with cte_random(n,y)
    as(
    -- generates a 0 based number from 0 to number - 1
       select 66 n, CAST(RAND(CHECKSUM(NEWID()))*10 as int) y
	   --select 1 id, RAND(CHECKSUM(NEWID()))*100 randomnumber
        union  all
        select n + 1, CAST(RAND(CHECKSUM(NEWID()))*10 as int)  y
		--select id + 1, RAND(CHECKSUM(NEWID()))*100  randomnumber
        from cte_random
        where 
          n < 1000
      )
      
update HourlyOEEValues 
--set Hourly_actual_production_count = rv.randomnumber
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
from HourlyOEEValues hv
inner join cte_random rv
on hv.ID  = rv.n
OPTION(MAXRECURSION 1000)

select 
Workcenter_Code,
Part_number,
Data_hour,
Hourly_planned_production_count, 
Cumulative_planned_production_count,
Hourly_actual_production_count, 
Cumulative_actual_production_count
from dbo.HourlyOEEValues  hv 
where hv.Date_time_stamp = '2020-04-12 14:29:00'
and hv.Workcenter_Code = 'VSC_1'
order by Workcenter_Code, Data_hour    

select * from dbo.HourlyOEEValues 
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
select count(*) from dbo.HourlyOEEValues where Date_time_stamp = '2020-03-29 14:29:00'  --96
select count(*) from dbo.HourlyOEEValues where Date_time_stamp = '2020-04-05 14:29:00'  --96
select count(*) from dbo.HourlyOEEValues where Date_time_stamp = '2020-04-12 14:29:00'  --96
select count(*) from dbo.HourlyOEEValues where Date_time_stamp = '2020-04-19 14:29:00'  --96
select count(*) from dbo.HourlyOEEValues where Date_time_stamp = '2020-04-26 14:29:00'  --96


delete from dbo.HourlyOEEValues where Date_time_stamp = '2020-03-29 14:29:00'
exec InsertHourlyOEEValues 'VSC_1', '1201', '4140', 7, 1, 1, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_2', '1202', '4141', 7, 5, 5, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_3', '1203', '4142', 7, 10, 10, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_4', '1204', '4143', 7, 15, 15, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_5', '1205', '4144', 7, 20, 20, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_6', '1206', '4145', 7, 25, 25, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_7', '1207', '4146', 7, 30, 30, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_8', '1208', '4147', 7, 35, 35, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_9', '1209', '4150', 7, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_10', '1209', '4150', 7, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_11', '1209', '4150', 7, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_12', '1209', '4150', 7, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00';

exec InsertHourlyOEEValues 'VSC_1', '1201', '4140', 8, 1, 1, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_2', '1202', '4141', 8, 5, 5, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_3', '1203', '4142', 8, 10, 10, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_4', '1204', '4143', 8, 15, 15, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_5', '1205', '4144', 8, 20, 20, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_6', '1206', '4145', 8, 25, 25, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_7', '1207', '4146', 8, 30, 30, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_8', '1208', '4147', 8, 35, 35, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_9', '1209', '4150', 8, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_10', '1209', '4150', 8, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_11', '1209', '4150', 8, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_12', '1209', '4150', 8, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00';

exec InsertHourlyOEEValues 'VSC_1', '1201', '4140', 9, 1, 1, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_2', '1202', '4141', 9, 5, 5, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_3', '1203', '4142', 9, 10, 10, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_4', '1204', '4143', 9, 15, 15, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_5', '1205', '4144', 9, 20, 20, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_6', '1206', '4145', 9, 25, 25, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_7', '1207', '4146', 9, 30, 30, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_8', '1208', '4147', 9, 35, 35, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_9', '1209', '4150', 9, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_10', '1209', '4150', 9, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_11', '1209', '4150', 9, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_12', '1209', '4150', 9, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00';


exec InsertHourlyOEEValues 'VSC_1', '1201', '4140',10, 1, 1, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_2', '1202', '4141',10, 5, 5, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_3', '1203', '4142',10, 10, 10, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_4', '1204', '4143',10, 15, 15, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_5', '1205', '4144',10, 20, 20, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_6', '1206', '4145',10, 25, 25, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_7', '1207', '4146',10, 30, 30, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_8', '1208', '4147',10, 35, 35, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_9', '1209', '4150',10, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_10', '1209', '4150',10, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_11', '1209', '4150',10, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_12', '1209', '4150',10, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00';

exec InsertHourlyOEEValues 'VSC_1', '1201', '4140',11, 1, 1, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_2', '1202', '4141',11, 5, 5, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_3', '1203', '4142',11, 10, 10, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_4', '1204', '4143',11, 15, 15, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_5', '1205', '4144',11, 20, 20, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_6', '1206', '4145',11, 25, 25, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_7', '1207', '4146',11, 30, 30, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_8', '1208', '4147',11, 35, 35, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_9', '1209', '4150',11, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_10', '1209', '4150',11, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_11', '1209', '4150',11, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_12', '1209', '4150',11, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00';

exec InsertHourlyOEEValues 'VSC_1', '1201', '4140',12, 1, 1, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_2', '1202', '4141',12, 5, 5, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_3', '1203', '4142',12, 10, 10, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_4', '1204', '4143',12, 15, 15, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_5', '1205', '4144',12, 20, 20, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_6', '1206', '4145',12, 25, 25, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_7', '1207', '4146',12, 30, 30, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_8', '1208', '4147',12, 35, 35, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_9', '1209', '4150',12, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_10', '1209', '4150',12, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_11', '1209', '4150',12, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_12', '1209', '4150',12, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00';

exec InsertHourlyOEEValues 'VSC_1', '1201', '4140',13, 1, 1, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_2', '1202', '4141',13, 5, 5, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_3', '1203', '4142',13, 10, 10, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_4', '1204', '4143',13, 15, 15, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_5', '1205', '4144',13, 20, 20, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_6', '1206', '4145',13, 25, 25, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_7', '1207', '4146',13, 30, 30, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_8', '1208', '4147',13, 35, 35, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_9', '1209', '4150',13, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_10', '1209', '4150',13, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_11', '1209', '4150',13, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_12', '1209', '4150',13, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00';

exec InsertHourlyOEEValues 'VSC_1', '1201', '4140',14, 1, 1, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_2', '1202', '4141',14, 5, 5, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_3', '1203', '4142',14, 10, 10, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_4', '1204', '4143',14, 15, 15, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_5', '1205', '4144',14, 20, 20, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_6', '1206', '4145',14, 25, 25, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_7', '1207', '4146',14, 30, 30, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_8', '1208', '4147',14, 35, 35, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_9', '1209', '4150',14, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_10', '1209', '4150',14, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_11', '1209', '4150',14, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00';
exec InsertHourlyOEEValues 'VSC_12', '1209', '4150',14, 38, 38, 834,582, 0, 0,'2020-03-29 14:29:00';




delete from dbo.HourlyOEEValues where Date_time_stamp = '2020-04-05 14:29:00'
exec InsertHourlyOEEValues 'VSC_1', '1201', '4140', 7, 1, 1, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_2', '1202', '4141', 7, 5, 5, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_3', '1203', '4142', 7, 10, 10, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_4', '1204', '4143', 7, 15, 15, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_5', '1205', '4144', 7, 20, 20, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_6', '1206', '4145', 7, 25, 25, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_7', '1207', '4146', 7, 30, 30, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_8', '1208', '4147', 7, 35, 35, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_9', '1209', '4150', 7, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_10', '1209', '4150', 7, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_11', '1209', '4150', 7, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_12', '1209', '4150', 7, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00';

exec InsertHourlyOEEValues 'VSC_1', '1201', '4140', 8, 1, 1, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_2', '1202', '4141', 8, 5, 5, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_3', '1203', '4142', 8, 10, 10, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_4', '1204', '4143', 8, 15, 15, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_5', '1205', '4144', 8, 20, 20, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_6', '1206', '4145', 8, 25, 25, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_7', '1207', '4146', 8, 30, 30, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_8', '1208', '4147', 8, 35, 35, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_9', '1209', '4150', 8, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_10', '1209', '4150', 8, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_11', '1209', '4150', 8, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_12', '1209', '4150', 8, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00';

exec InsertHourlyOEEValues 'VSC_1', '1201', '4140', 9, 1, 1, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_2', '1202', '4141', 9, 5, 5, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_3', '1203', '4142', 9, 10, 10, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_4', '1204', '4143', 9, 15, 15, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_5', '1205', '4144', 9, 20, 20, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_6', '1206', '4145', 9, 25, 25, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_7', '1207', '4146', 9, 30, 30, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_8', '1208', '4147', 9, 35, 35, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_9', '1209', '4150', 9, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_10', '1209', '4150', 9, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_11', '1209', '4150', 9, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_12', '1209', '4150', 9, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00';


exec InsertHourlyOEEValues 'VSC_1', '1201', '4140',10, 1, 1, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_2', '1202', '4141',10, 5, 5, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_3', '1203', '4142',10, 10, 10, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_4', '1204', '4143',10, 15, 15, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_5', '1205', '4144',10, 20, 20, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_6', '1206', '4145',10, 25, 25, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_7', '1207', '4146',10, 30, 30, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_8', '1208', '4147',10, 35, 35, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_9', '1209', '4150',10, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_10', '1209', '4150',10, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_11', '1209', '4150',10, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_12', '1209', '4150',10, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00';

exec InsertHourlyOEEValues 'VSC_1', '1201', '4140',11, 1, 1, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_2', '1202', '4141',11, 5, 5, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_3', '1203', '4142',11, 10, 10, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_4', '1204', '4143',11, 15, 15, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_5', '1205', '4144',11, 20, 20, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_6', '1206', '4145',11, 25, 25, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_7', '1207', '4146',11, 30, 30, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_8', '1208', '4147',11, 35, 35, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_9', '1209', '4150',11, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_10', '1209', '4150',11, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_11', '1209', '4150',11, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_12', '1209', '4150',11, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00';

exec InsertHourlyOEEValues 'VSC_1', '1201', '4140',12, 1, 1, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_2', '1202', '4141',12, 5, 5, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_3', '1203', '4142',12, 10, 10, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_4', '1204', '4143',12, 15, 15, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_5', '1205', '4144',12, 20, 20, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_6', '1206', '4145',12, 25, 25, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_7', '1207', '4146',12, 30, 30, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_8', '1208', '4147',12, 35, 35, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_9', '1209', '4150',12, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_10', '1209', '4150',12, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_11', '1209', '4150',12, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_12', '1209', '4150',12, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00';

exec InsertHourlyOEEValues 'VSC_1', '1201', '4140',13, 1, 1, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_2', '1202', '4141',13, 5, 5, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_3', '1203', '4142',13, 10, 10, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_4', '1204', '4143',13, 15, 15, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_5', '1205', '4144',13, 20, 20, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_6', '1206', '4145',13, 25, 25, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_7', '1207', '4146',13, 30, 30, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_8', '1208', '4147',13, 35, 35, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_9', '1209', '4150',13, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_10', '1209', '4150',13, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_11', '1209', '4150',13, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_12', '1209', '4150',13, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00';

exec InsertHourlyOEEValues 'VSC_1', '1201', '4140',14, 1, 1, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_2', '1202', '4141',14, 5, 5, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_3', '1203', '4142',14, 10, 10, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_4', '1204', '4143',14, 15, 15, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_5', '1205', '4144',14, 20, 20, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_6', '1206', '4145',14, 25, 25, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_7', '1207', '4146',14, 30, 30, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_8', '1208', '4147',14, 35, 35, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_9', '1209', '4150',14, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_10', '1209', '4150',14, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_11', '1209', '4150',14, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00';
exec InsertHourlyOEEValues 'VSC_12', '1209', '4150',14, 38, 38, 834,582, 0, 0,'2020-04-05 14:29:00';


delete from dbo.HourlyOEEValues where Date_time_stamp = '2020-04-12 14:29:00'
exec InsertHourlyOEEValues 'VSC_1', '1201', '4140', 7, 1, 1, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_2', '1202', '4141', 7, 5, 5, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_3', '1203', '4142', 7, 10, 10, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_4', '1204', '4143', 7, 15, 15, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_5', '1205', '4144', 7, 20, 20, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_6', '1206', '4145', 7, 25, 25, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_7', '1207', '4146', 7, 30, 30, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_8', '1208', '4147', 7, 35, 35, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_9', '1209', '4150', 7, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_10', '1209', '4150', 7, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_11', '1209', '4150', 7, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_12', '1209', '4150', 7, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00';

exec InsertHourlyOEEValues 'VSC_1', '1201', '4140', 8, 1, 1, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_2', '1202', '4141', 8, 5, 5, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_3', '1203', '4142', 8, 10, 10, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_4', '1204', '4143', 8, 15, 15, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_5', '1205', '4144', 8, 20, 20, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_6', '1206', '4145', 8, 25, 25, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_7', '1207', '4146', 8, 30, 30, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_8', '1208', '4147', 8, 35, 35, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_9', '1209', '4150', 8, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_10', '1209', '4150', 8, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_11', '1209', '4150', 8, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_12', '1209', '4150', 8, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00';

exec InsertHourlyOEEValues 'VSC_1', '1201', '4140', 9, 1, 1, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_2', '1202', '4141', 9, 5, 5, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_3', '1203', '4142', 9, 10, 10, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_4', '1204', '4143', 9, 15, 15, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_5', '1205', '4144', 9, 20, 20, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_6', '1206', '4145', 9, 25, 25, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_7', '1207', '4146', 9, 30, 30, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_8', '1208', '4147', 9, 35, 35, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_9', '1209', '4150', 9, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_10', '1209', '4150', 9, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_11', '1209', '4150', 9, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_12', '1209', '4150', 9, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00';


exec InsertHourlyOEEValues 'VSC_1', '1201', '4140',10, 1, 1, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_2', '1202', '4141',10, 5, 5, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_3', '1203', '4142',10, 10, 10, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_4', '1204', '4143',10, 15, 15, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_5', '1205', '4144',10, 20, 20, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_6', '1206', '4145',10, 25, 25, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_7', '1207', '4146',10, 30, 30, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_8', '1208', '4147',10, 35, 35, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_9', '1209', '4150',10, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_10', '1209', '4150',10, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_11', '1209', '4150',10, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_12', '1209', '4150',10, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00';

exec InsertHourlyOEEValues 'VSC_1', '1201', '4140',11, 1, 1, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_2', '1202', '4141',11, 5, 5, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_3', '1203', '4142',11, 10, 10, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_4', '1204', '4143',11, 15, 15, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_5', '1205', '4144',11, 20, 20, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_6', '1206', '4145',11, 25, 25, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_7', '1207', '4146',11, 30, 30, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_8', '1208', '4147',11, 35, 35, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_9', '1209', '4150',11, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_10', '1209', '4150',11, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_11', '1209', '4150',11, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_12', '1209', '4150',11, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00';

exec InsertHourlyOEEValues 'VSC_1', '1201', '4140',12, 1, 1, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_2', '1202', '4141',12, 5, 5, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_3', '1203', '4142',12, 10, 10, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_4', '1204', '4143',12, 15, 15, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_5', '1205', '4144',12, 20, 20, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_6', '1206', '4145',12, 25, 25, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_7', '1207', '4146',12, 30, 30, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_8', '1208', '4147',12, 35, 35, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_9', '1209', '4150',12, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_10', '1209', '4150',12, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_11', '1209', '4150',12, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_12', '1209', '4150',12, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00';

exec InsertHourlyOEEValues 'VSC_1', '1201', '4140',13, 1, 1, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_2', '1202', '4141',13, 5, 5, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_3', '1203', '4142',13, 10, 10, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_4', '1204', '4143',13, 15, 15, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_5', '1205', '4144',13, 20, 20, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_6', '1206', '4145',13, 25, 25, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_7', '1207', '4146',13, 30, 30, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_8', '1208', '4147',13, 35, 35, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_9', '1209', '4150',13, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_10', '1209', '4150',13, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_11', '1209', '4150',13, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_12', '1209', '4150',13, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00';

exec InsertHourlyOEEValues 'VSC_1', '1201', '4140',14, 1, 1, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_2', '1202', '4141',14, 5, 5, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_3', '1203', '4142',14, 10, 10, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_4', '1204', '4143',14, 15, 15, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_5', '1205', '4144',14, 20, 20, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_6', '1206', '4145',14, 25, 25, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_7', '1207', '4146',14, 30, 30, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_8', '1208', '4147',14, 35, 35, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_9', '1209', '4150',14, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_10', '1209', '4150',14, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_11', '1209', '4150',14, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00';
exec InsertHourlyOEEValues 'VSC_12', '1209', '4150',14, 38, 38, 834,582, 0, 0,'2020-04-12 14:29:00';


exec InsertHourlyOEEValues 'VSC_1', '1201', '4140', 7, 1, 1, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues 'VSC_2', '1202', '4141', 7, 5, 5, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues 'VSC_3', '1203', '4142', 7, 10, 10, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues 'VSC_4', '1204', '4143', 7, 15, 15, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues 'VSC_5', '1205', '4144', 7, 20, 20, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues 'VSC_6', '1206', '4145', 7, 25, 25, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues 'VSC_7', '1207', '4146', 7, 30, 30, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues 'VSC_8', '1208', '4147', 7, 35, 35, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues 'VSC_9', '1209', '4150', 7, 38, 38, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues 'VSC_10', '1209', '4150', 7, 38, 38, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues 'VSC_11', '1209', '4150', 7, 38, 38, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues 'VSC_12', '1209', '4150', 7, 38, 38, 834,582, 0, 0,'2020-04-19 14:29'

exec InsertHourlyOEEValues ' VSC_1', '1201', '4140', 8, 1, 1, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_2', '1202', '4141', 8, 5, 5, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_3', '1203', '4142', 8, 10, 10, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_4', '1204', '4143', 8, 15, 15, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_5', '1205', '4144', 8, 20, 20, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_6', '1206', '4145', 8, 25, 25, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_7', '1207', '4146', 8, 30, 30, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_8', '1208', '4147', 8, 35, 35, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_9', '1209', '4150', 8, 38, 38, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_10', '1209', '4150', 8, 38, 38, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_11', '1209', '4150', 8, 38, 38, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_12', '1209', '4150', 8, 38, 38, 834,582, 0, 0,'2020-04-19 14:29'

exec InsertHourlyOEEValues ' VSC_1', '1201', '4140', 9, 1, 1, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_2', '1202', '4141', 9, 5, 5, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_3', '1203', '4142', 9, 10, 10, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_4', '1204', '4143', 9, 15, 15, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_5', '1205', '4144', 9, 20, 20, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_6', '1206', '4145', 9, 25, 25, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_7', '1207', '4146', 9, 30, 30, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_8', '1208', '4147', 9, 35, 35, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_9', '1209', '4150', 9, 38, 38, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_10', '1209', '4150', 9, 38, 38, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_11', '1209', '4150', 9, 38, 38, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_12', '1209', '4150', 9, 38, 38, 834,582, 0, 0,'2020-04-19 14:29'


exec InsertHourlyOEEValues ' VSC_1', '1201', '4140',10, 1, 1, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_2', '1202', '4141',10, 5, 5, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_3', '1203', '4142',10, 10, 10, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_4', '1204', '4143',10, 15, 15, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_5', '1205', '4144',10, 20, 20, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_6', '1206', '4145',10, 25, 25, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_7', '1207', '4146',10, 30, 30, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_8', '1208', '4147',10, 35, 35, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_9', '1209', '4150',10, 38, 38, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_10', '1209', '4150',10, 38, 38, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_11', '1209', '4150',10, 38, 38, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_12', '1209', '4150',10, 38, 38, 834,582, 0, 0,'2020-04-19 14:29'

exec InsertHourlyOEEValues ' VSC_1', '1201', '4140',11, 1, 1, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_2', '1202', '4141',11, 5, 5, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_3', '1203', '4142',11, 10, 10, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_4', '1204', '4143',11, 15, 15, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_5', '1205', '4144',11, 20, 20, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_6', '1206', '4145',11, 25, 25, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_7', '1207', '4146',11, 30, 30, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_8', '1208', '4147',11, 35, 35, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_9', '1209', '4150',11, 38, 38, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_10', '1209', '4150',11, 38, 38, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_11', '1209', '4150',11, 38, 38, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_12', '1209', '4150',11, 38, 38, 834,582, 0, 0,'2020-04-19 14:29'

exec InsertHourlyOEEValues ' VSC_1', '1201', '4140',12, 1, 1, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_2', '1202', '4141',12, 5, 5, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_3', '1203', '4142',12, 10, 10, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_4', '1204', '4143',12, 15, 15, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_5', '1205', '4144',12, 20, 20, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_6', '1206', '4145',12, 25, 25, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_7', '1207', '4146',12, 30, 30, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_8', '1208', '4147',12, 35, 35, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_9', '1209', '4150',12, 38, 38, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_10', '1209', '4150',12, 38, 38, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_11', '1209', '4150',12, 38, 38, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_12', '1209', '4150',12, 38, 38, 834,582, 0, 0,'2020-04-19 14:29'

exec InsertHourlyOEEValues ' VSC_1', '1201', '4140',13, 1, 1, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_2', '1202', '4141',13, 5, 5, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_3', '1203', '4142',13, 10, 10, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_4', '1204', '4143',13, 15, 15, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_5', '1205', '4144',13, 20, 20, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_6', '1206', '4145',13, 25, 25, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_7', '1207', '4146',13, 30, 30, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_8', '1208', '4147',13, 35, 35, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_9', '1209', '4150',13, 38, 38, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_10', '1209', '4150',13, 38, 38, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_11', '1209', '4150',13, 38, 38, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_12', '1209', '4150',13, 38, 38, 834,582, 0, 0,'2020-04-19 14:29'

exec InsertHourlyOEEValues ' VSC_1', '1201', '4140',14, 1, 1, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_2', '1202', '4141',14, 5, 5, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_3', '1203', '4142',14, 10, 10, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_4', '1204', '4143',14, 15, 15, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_5', '1205', '4144',14, 20, 20, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_6', '1206', '4145',14, 25, 25, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_7', '1207', '4146',14, 30, 30, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_8', '1208', '4147',14, 35, 35, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_9', '1209', '4150',14, 38, 38, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_10', '1209', '4150',14, 38, 38, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_11', '1209', '4150',14, 38, 38, 834,582, 0, 0,'2020-04-19 14:29'
exec InsertHourlyOEEValues ' VSC_12', '1209', '4150',14, 38, 38, 834,582, 0, 0,'2020-04-19 14:29'

-- delete from HourlyOEEValues
-- where Date_time_stamp = '2020-04-26 14:29:00'
exec InsertHourlyOEEValues 'VSC_1', '1201', '4140', 7, 1, 1, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_2', '1202', '4141', 7, 5, 5, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_3', '1203', '4142', 7, 10, 10, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_4', '1204', '4143', 7, 15, 15, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_5', '1205', '4144', 7, 20, 20, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_6', '1206', '4145', 7, 25, 25, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_7', '1207', '4146', 7, 30, 30, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_8', '1208', '4147', 7, 35, 35, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_9', '1209', '4150', 7, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_10', '1209', '4150', 7, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_11', '1209', '4150', 7, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_12', '1209', '4150', 7, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00';

exec InsertHourlyOEEValues 'VSC_1', '1201', '4140', 8, 1, 1, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_2', '1202', '4141', 8, 5, 5, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_3', '1203', '4142', 8, 10, 10, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_4', '1204', '4143', 8, 15, 15, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_5', '1205', '4144', 8, 20, 20, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_6', '1206', '4145', 8, 25, 25, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_7', '1207', '4146', 8, 30, 30, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_8', '1208', '4147', 8, 35, 35, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_9', '1209', '4150', 8, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_10', '1209', '4150', 8, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_11', '1209', '4150', 8, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_12', '1209', '4150', 8, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00';

exec InsertHourlyOEEValues 'VSC_1', '1201', '4140', 9, 1, 1, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_2', '1202', '4141', 9, 5, 5, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_3', '1203', '4142', 9, 10, 10, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_4', '1204', '4143', 9, 15, 15, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_5', '1205', '4144', 9, 20, 20, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_6', '1206', '4145', 9, 25, 25, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_7', '1207', '4146', 9, 30, 30, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_8', '1208', '4147', 9, 35, 35, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_9', '1209', '4150', 9, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_10', '1209', '4150', 9, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_11', '1209', '4150', 9, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_12', '1209', '4150', 9, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00';


exec InsertHourlyOEEValues 'VSC_1', '1201', '4140',10, 1, 1, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_2', '1202', '4141',10, 5, 5, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_3', '1203', '4142',10, 10, 10, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_4', '1204', '4143',10, 15, 15, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_5', '1205', '4144',10, 20, 20, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_6', '1206', '4145',10, 25, 25, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_7', '1207', '4146',10, 30, 30, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_8', '1208', '4147',10, 35, 35, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_9', '1209', '4150',10, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_10', '1209', '4150',10, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_11', '1209', '4150',10, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_12', '1209', '4150',10, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00';

exec InsertHourlyOEEValues 'VSC_1', '1201', '4140',11, 1, 1, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_2', '1202', '4141',11, 5, 5, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_3', '1203', '4142',11, 10, 10, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_4', '1204', '4143',11, 15, 15, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_5', '1205', '4144',11, 20, 20, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_6', '1206', '4145',11, 25, 25, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_7', '1207', '4146',11, 30, 30, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_8', '1208', '4147',11, 35, 35, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_9', '1209', '4150',11, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_10', '1209', '4150',11, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_11', '1209', '4150',11, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_12', '1209', '4150',11, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00';

exec InsertHourlyOEEValues 'VSC_1', '1201', '4140',12, 1, 1, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_2', '1202', '4141',12, 5, 5, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_3', '1203', '4142',12, 10, 10, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_4', '1204', '4143',12, 15, 15, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_5', '1205', '4144',12, 20, 20, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_6', '1206', '4145',12, 25, 25, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_7', '1207', '4146',12, 30, 30, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_8', '1208', '4147',12, 35, 35, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_9', '1209', '4150',12, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_10', '1209', '4150',12, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_11', '1209', '4150',12, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_12', '1209', '4150',12, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00';

exec InsertHourlyOEEValues 'VSC_1', '1201', '4140',13, 1, 1, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_2', '1202', '4141',13, 5, 5, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_3', '1203', '4142',13, 10, 10, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_4', '1204', '4143',13, 15, 15, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_5', '1205', '4144',13, 20, 20, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_6', '1206', '4145',13, 25, 25, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_7', '1207', '4146',13, 30, 30, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_8', '1208', '4147',13, 35, 35, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_9', '1209', '4150',13, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_10', '1209', '4150',13, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_11', '1209', '4150',13, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_12', '1209', '4150',13, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00';

exec InsertHourlyOEEValues 'VSC_1', '1201', '4140',14, 1, 1, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_2', '1202', '4141',14, 5, 5, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_3', '1203', '4142',14, 10, 10, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_4', '1204', '4143',14, 15, 15, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_5', '1205', '4144',14, 20, 20, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_6', '1206', '4145',14, 25, 25, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_7', '1207', '4146',14, 30, 30, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_8', '1208', '4147',14, 35, 35, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_9', '1209', '4150',14, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_10', '1209', '4150',14, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_11', '1209', '4150',14, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00';
exec InsertHourlyOEEValues 'VSC_12', '1209', '4150',14, 38, 38, 834,582, 0, 0,'2020-04-26 14:29:00';



select DISTINCT Date_time_stamp  
from dbo.HourlyOEEValues 
select count(*) from hourlyoeevalues  --480























