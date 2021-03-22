
/*
Questions: Should we include Active -Temp2 
Employee_Status
1033  Active 
79 	  Active - TEMP
5     Active - TEMP2
select e.Employee_Status,count(*)
from personnel_v_employee_e as e  -- 5147
group by e.Employee_Status
*/

create table #Active
(
  pcn int,
  employee_status varchar(50)
);
insert into #Active (pcn,employee_status)
select distinct plexus_customer_no pcn, employee_status 
from personnel_v_employee_e where upper(employee_status) like 'ACTIVE%' or upper(employee_status) like 'TRANS%'

-- select * from #ActiveStatus

select
u.plexus_customer_no pcn, 
p.position_key,
s.shift_key,
u.department_no,
count(*) head_count
into #head_count
-- select count(*) cnt 1074 active employees
from plexus_control_v_plexus_user_e as u  -- 6643
inner join personnel_v_employee_e as e  -- 5043 
on u.plexus_customer_no = e.plexus_customer_no
and u.plexus_user_no = e.plexus_user_no  -- 1 to 1
inner join common_v_shift_e as s  -- 4533
on e.plexus_customer_no = s.plexus_customer_no
and e.shift_key = s.shift_key  -- 1 to 1
inner join common_v_position_e as p  -- inner join 4483
on u.plexus_customer_no = p.plexus_customer_no
and u.position_key = p.position_key  -- 1 to 1
inner join #Active a -- 1077
on u.plexus_customer_no = a.pcn
and e.employee_status = a.employee_status  
group by u.plexus_customer_no,p.position_key,s.shift_key,u.department_no





select 
-- pcn, plexus_customer_code, staffing_level, hours_tracked, department_code, pay_type, pay_type_2
p.plexus_customer_no pcn, 
p.position_key,
s.shift_key,
g.plexus_customer_code,
p.position,
d.department_no,
d.department_code,
s.shift_group,
-- p.hours_tracked,  -- uncomment to validate pay_type
-- d.department_code, -- uncomment to validate pay_type
case
when p.hours_tracked = 0 THEN 'Salary' 
when (p.hours_tracked = 1) and (d.department_code like '1%') THEN 'Direct' 
when (p.hours_tracked = 1) and (d.department_code not like '1%') THEN 'Indirect' 
ELSE 'Unknown' -- should never happen 
end pay_type,
ps.staffing_level
-- select count(*)
-- Assume: I think the most of the 1251 positions were part of the plex initial 
-- upload and are not valid Mobex positions  
into #staffing
from common_v_position_e p  -- 1251
-- Assume: The only valid Mobex positions are the ones with a position_shift record.
inner join common_v_position_shift_e ps -- 376
on p.plexus_customer_no=ps.pcn  -- 
and p.position_key = ps.position_key  -- 1 to many 
inner join common_v_shift_e s -- 376
on ps.pcn=s.plexus_customer_no  
and ps.shift_key = s.shift_key -- 1 to 1
inner join common_v_department_e as d -- 376
on ps.pcn = d.plexus_customer_no  
and ps.department_no = d.department_no  -- 1 to 1
inner join plexus_control_v_customer_group_member as g  -- 376
on ps.pcn = g.plexus_customer_no  -- 1 to 1
where d.active = 1  -- 54, All valid Mobex positions are currently active; but this could change.

select 
s.pcn, 
s.plexus_customer_code,
s.position,
s.department_code,
s.shift_group,
s.pay_type,
s.staffing_level,
case
  when c.head_count is null then 0
  else c.head_count 
end head_count,
case
  when c.head_count is null then s.staffing_level
  else s.staffing_level - c.head_count 
end difference
from #staffing s
left outer join #head_count c 
on s.pcn=c.pcn
and s.position_key=c.position_key
and s.shift_key=c.shift_key
and s.department_no=c.department_no
-- where s.pcn = 295932 
-- and s.position_key = 54982
order by Plexus_Customer_Code,department_code,position,shift_group  -- 376
-- Validation: PASS
-- where pay_type = 'Salary'  -- 46 records
-- where pay_type = 'Direct'  -- 3 records
-- where pay_type = 'Indirect'  -- 5 records
-- where pay_type = 'Unknown'  -- 0
-- where hours_tracked is null -- 0