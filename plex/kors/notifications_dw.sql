/*
	PCN
	310507/Avilla
	300758/Albion
	295933/Franklin
	300757/Alabama
	306766/Edon
	312055/ BPG WorkHolding
	1	123681
2	295932 Fruit Port
3	295933
4	300757
5	300758
6	306766
7	310507
8	312055
	*/

select 
--pu.plexus_customer_no pcn, 
--gm.plexus_customer_code,
1 notify_level,
pu.last_name,
pu.first_name,
d.name,
--pu.department_no,
--d.department_code,
--s.shift_key,
s.shift,
--s.start_time,
--s.stop_time,
p.position,
--e.employee_status,
pu.email,
pu.phone,
pu.home_phone,
pu.mobile,
0 off_hours
--select count(*)
from Plexus_Control_v_Plexus_User_e pu  -- 7487
inner join Plexus_Control_v_Customer_Group_Member gm  -- there is no enterprise version of this view 
on pu.plexus_customer_no=gm.plexus_customer_no  -- 7487
inner join common_v_position_e p -- 6240
on pu.plexus_customer_no= p.plexus_customer_no
and pu.position_key=p.position_key
inner join personnel_v_employee_e as e  -- 5681
on pu.plexus_customer_no = e.plexus_customer_no
and pu.plexus_user_no = e.plexus_user_no  -- 1 to 1
inner join common_v_shift_e as s  -- 5145
on e.plexus_customer_no = s.plexus_customer_no
and e.shift_key = s.shift_key  
inner join common_v_department_e d 
on pu.plexus_customer_no=d.plexus_customer_no
and pu.department_no=d.department_no  -- 1281
where pu.plexus_customer_no = @PCN
and p.position = 'Team Leader'
and d.name in ('Cast','Tool & Mold')
--and s.shift in ('First','Second','Third')  
 
union

select 
--pu.plexus_customer_no pcn, 
--gm.plexus_customer_code,
2 notify_level,
pu.last_name,
pu.first_name,
d.name,
--pu.department_no,
--d.department_code,
--s.shift_key,
s.shift,
--s.start_time,
--s.stop_time,
p.position,
--e.employee_status,
pu.email,
pu.phone,
pu.home_phone,
pu.mobile,
0 off_hours
--select count(*)
from Plexus_Control_v_Plexus_User_e pu  -- 7487
inner join Plexus_Control_v_Customer_Group_Member gm  -- there is no enterprise version of this view 
on pu.plexus_customer_no=gm.plexus_customer_no  -- 7487
inner join common_v_position_e p -- 6240
on pu.plexus_customer_no= p.plexus_customer_no
and pu.position_key=p.position_key
inner join personnel_v_employee_e as e  -- 5681
on pu.plexus_customer_no = e.plexus_customer_no
and pu.plexus_user_no = e.plexus_user_no  -- 1 to 1
inner join common_v_shift_e as s  -- 5145
on e.plexus_customer_no = s.plexus_customer_no
and e.shift_key = s.shift_key  
inner join common_v_department_e d 
on pu.plexus_customer_no=d.plexus_customer_no
and pu.department_no=d.department_no  -- 1281
where pu.plexus_customer_no = @PCN
and p.position in ('Production Supervisor','Senior Process Engineer')
-- and s.shift in ('First','Second','Third')
-- order by s.shift

union

select 
--pu.plexus_customer_no pcn, 
--gm.plexus_customer_code,
2 notify_level,
pu.last_name,
pu.first_name,
d.name,
--pu.department_no,
--d.department_code,
--s.shift_key,
s.shift,
--s.start_time,
--s.stop_time,
p.position,
--e.employee_status,
pu.email,
pu.phone,
pu.home_phone,
pu.mobile,
1 off_hours
--select count(*)
from Plexus_Control_v_Plexus_User_e pu  -- 7487
inner join Plexus_Control_v_Customer_Group_Member gm  -- there is no enterprise version of this view 
on pu.plexus_customer_no=gm.plexus_customer_no  -- 7487
inner join common_v_position_e p -- 6240
on pu.plexus_customer_no= p.plexus_customer_no
and pu.position_key=p.position_key
inner join personnel_v_employee_e as e  -- 5681
on pu.plexus_customer_no = e.plexus_customer_no
and pu.plexus_user_no = e.plexus_user_no  -- 1 to 1
inner join common_v_shift_e as s  -- 5145
on e.plexus_customer_no = s.plexus_customer_no
and e.shift_key = s.shift_key  
inner join common_v_department_e d 
on pu.plexus_customer_no=d.plexus_customer_no
and pu.department_no=d.department_no  -- 1281
where pu.plexus_customer_no = @PCN
and p.position in ('Operations Manager','Environmental Health and Safety Manager','Tooling Engineer Manager','Tool Room Manager','Melt Manager','Maintenance Manager')
--and s.shift in ('1st')
--order by s.shift

union

select 
--pu.plexus_customer_no pcn, 
--gm.plexus_customer_code,
2 notify_level,
pu.last_name,
pu.first_name,
d.name,
--pu.department_no,
--d.department_code,
--s.shift_key,
s.shift,
--s.start_time,
--s.stop_time,
p.position,
--e.employee_status,
pu.email,
pu.phone,
pu.home_phone,
pu.mobile,
0 off_hours
--select count(*)
from Plexus_Control_v_Plexus_User_e pu  -- 7487
inner join Plexus_Control_v_Customer_Group_Member gm  -- there is no enterprise version of this view 
on pu.plexus_customer_no=gm.plexus_customer_no  -- 7487
inner join common_v_position_e p -- 6240
on pu.plexus_customer_no= p.plexus_customer_no
and pu.position_key=p.position_key
inner join personnel_v_employee_e as e  -- 5681
on pu.plexus_customer_no = e.plexus_customer_no
and pu.plexus_user_no = e.plexus_user_no  -- 1 to 1
inner join common_v_shift_e as s  -- 5145
on e.plexus_customer_no = s.plexus_customer_no
and e.shift_key = s.shift_key  
inner join common_v_department_e d 
on pu.plexus_customer_no=d.plexus_customer_no
and pu.department_no=d.department_no  -- 1281
where pu.plexus_customer_no = @PCN
and p.position in ('Production Supervisor','Senior Process Engineer')
-- and s.shift in ('First','Second','Third')
-- order by s.shift

union

select 
--pu.plexus_customer_no pcn, 
--gm.plexus_customer_code,
3 notify_level,
pu.last_name,
pu.first_name,
d.name,
--pu.department_no,
--d.department_code,
--s.shift_key,
s.shift,
--s.start_time,
--s.stop_time,
p.position,
--e.employee_status,
pu.email,
pu.phone,
pu.home_phone,
pu.mobile,
1 off_hours
--select count(*)
from Plexus_Control_v_Plexus_User_e pu  -- 7487
inner join Plexus_Control_v_Customer_Group_Member gm  -- there is no enterprise version of this view 
on pu.plexus_customer_no=gm.plexus_customer_no  -- 7487
inner join common_v_position_e p -- 6240
on pu.plexus_customer_no= p.plexus_customer_no
and pu.position_key=p.position_key
inner join personnel_v_employee_e as e  -- 5681
on pu.plexus_customer_no = e.plexus_customer_no
and pu.plexus_user_no = e.plexus_user_no  -- 1 to 1
inner join common_v_shift_e as s  -- 5145
on e.plexus_customer_no = s.plexus_customer_no
and e.shift_key = s.shift_key  
inner join common_v_department_e d 
on pu.plexus_customer_no=d.plexus_customer_no
and pu.department_no=d.department_no  -- 1281
where pu.plexus_customer_no = @PCN
and p.position in ('Operations Manager','Environmental Health and Safety Manager','Tooling Engineer Manager','Tool Room Manager','Melt Manager','Maintenance Manager')
--and s.shift in ('1st')
--order by s.shift

union

select 
--pu.plexus_customer_no pcn, 
--gm.plexus_customer_code,
4 notify_level,
pu.last_name,
pu.first_name,
d.name,
--pu.department_no,
--d.department_code,
--s.shift_key,
s.shift,
--s.start_time,
--s.stop_time,
p.position,
--e.employee_status,
pu.email,
pu.phone,
pu.home_phone,
pu.mobile,
0 off_hours
--select count(*)
from Plexus_Control_v_Plexus_User_e pu  -- 7487
inner join Plexus_Control_v_Customer_Group_Member gm  -- there is no enterprise version of this view 
on pu.plexus_customer_no=gm.plexus_customer_no  -- 7487
inner join common_v_position_e p -- 6240
on pu.plexus_customer_no= p.plexus_customer_no
and pu.position_key=p.position_key
inner join personnel_v_employee_e as e  -- 5681
on pu.plexus_customer_no = e.plexus_customer_no
and pu.plexus_user_no = e.plexus_user_no  -- 1 to 1
inner join common_v_shift_e as s  -- 5145
on e.plexus_customer_no = s.plexus_customer_no
and e.shift_key = s.shift_key  
inner join common_v_department_e d 
on pu.plexus_customer_no=d.plexus_customer_no
and pu.department_no=d.department_no  -- 1281
where pu.plexus_customer_no = @PCN
and p.position in ('Vice President - Fruitport')  -- PPT SAID PLANT MANAGER
--and s.shift in ('1st')
--order by s.shift
union

select 
--pu.plexus_customer_no pcn, 
--gm.plexus_customer_code,
5 notify_level,
pu.last_name,
pu.first_name,
d.name,
--pu.department_no,
--d.department_code,
--s.shift_key,
case
when s.shift is null then '1st'
else s.shift
end shift,
--s.start_time,
--s.stop_time,
p.position,
--e.employee_status,
pu.email,
pu.phone,
pu.home_phone,
pu.mobile,
0 off_hours
--select count(*)
from Plexus_Control_v_Plexus_User_e pu  -- 7487
inner join Plexus_Control_v_Customer_Group_Member gm  -- there is no enterprise version of this view 
on pu.plexus_customer_no=gm.plexus_customer_no  -- 7487
inner join common_v_position_e p -- 6240
on pu.plexus_customer_no= p.plexus_customer_no
and pu.position_key=p.position_key

inner join personnel_v_employee_e as e  -- 5681
on pu.plexus_customer_no = e.plexus_customer_no
and pu.plexus_user_no = e.plexus_user_no  -- 1 to 1

left outer join common_v_shift_e as s  -- 5145  Paul Kenrick does not have a shift record.
on e.plexus_customer_no = s.plexus_customer_no
and e.shift_key = s.shift_key  

inner join common_v_department_e d 
on pu.plexus_customer_no=d.plexus_customer_no
and pu.department_no=d.department_no  -- 1281
where p.position in ('EVP COO & General Mgr North America')   

--pu.plexus_customer_no = @PCN  HE IS NOT IN THIS PCN
--and s.shift in ('1st')
--order by s.shift

/* Debug
select name from common_v_department_e where plexus_customer_no = @PCN order by name
select p.position from common_v_position_e p where p.plexus_customer_no = @PCN order by position

select p.*
from Plexus_Control_v_Plexus_User_e pu  -- 7487
inner join Plexus_Control_v_Customer_Group_Member gm  -- there is no enterprise version of this view 
on pu.plexus_customer_no=gm.plexus_customer_no  -- 7487
inner join common_v_position_e p -- 6240
on pu.plexus_customer_no= p.plexus_customer_no
and pu.position_key=p.position_key
where last_name like '%Kenrick%' 
*/
