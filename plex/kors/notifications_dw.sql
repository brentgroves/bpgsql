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
create table #result
(
  id int,
  pcn int,
  notify_level tinyint,
  last_name varchar(50),
  first_name varchar(50),
  dept_name varchar(50),
  shift varchar(15),
  position varchar(50),
  email varchar(100),
  phone varchar(25),
  home_phone varchar(25),
  mobile varchar(25),
  off_hours tinyint,  -- if off_hours = 1 then use the start and end time instead of the standard shift time to determine when to notify them.
  start_time datetime,
  end_time datetime,
  notify_type tinyint, -- 1=phone, 2=text, 3=email,
  shift_std tinyint
)

insert into #result(id,pcn,notify_level,last_name,first_name,dept_name,shift,position,email,phone,home_phone,mobile,off_hours,start_time,end_time,notify_type,shift_std)
select 
row_number() over( order by pcn,notify_level,shift, position,name,last_name,first_name) id,
r.pcn,
r.notify_level,
r.last_name,
r.first_name,
r.name dept_name,
r.shift,
r.position,
r.email,
r.phone,
r.home_phone,
r.mobile,
r.off_hours,
r.start_time,
r.end_time,
r.notify_type, -- 1=phone, 2=text, 3=email
r.shift_std
from 
(
select 
pu.plexus_customer_no pcn, 
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
0 off_hours,
cast('1900-01-01T00:00:00' as datetime) start_time,
cast('1900-01-01T00:00:00' as datetime) end_time,
1 notify_type, -- 1=phone, 2=text, 3=email
case 
when s.shift in ('First','1st') then 1
when s.shift in ('Second') then 2
else 3
end shift_std
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
pu.plexus_customer_no pcn, 
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
0 off_hours,
cast('1900-01-01T00:00:00' as datetime) start_time,
cast('1900-01-01T00:00:00' as datetime) end_time,
1 notify_type, -- 1=phone, 2=text, 3=email
case 
when s.shift in ('First','1st') then 1
when s.shift in ('Second') then 2
else 3
end shift_std
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
pu.plexus_customer_no pcn, 
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
1 off_hours,
cast('1900-01-01T06:00:01' as datetime) start_time,
cast('1900-01-01T19:00:00' as datetime) end_time,
2 notify_type, -- 1=phone, 2=text, 3=email
case 
when s.shift in ('First','1st') then 1
when s.shift in ('Second') then 2
else 3
end shift_std
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
pu.plexus_customer_no pcn, 
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
1 off_hours,
cast('1900-01-01T19:00:01' as datetime) start_time,
cast('1900-01-01T06:00:00' as datetime) end_time,
3 notify_type, -- 1=phone, 2=text, 3=email
case 
when s.shift in ('First','1st') then 1
when s.shift in ('Second') then 2
else 3
end shift_std
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
pu.plexus_customer_no pcn, 
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
0 off_hours,
cast('1900-01-01T00:00:00' as datetime) start_time,
cast('1900-01-01T00:00:00' as datetime) end_time,
1 notify_type, -- 1=phone, 2=text, 3=email
case 
when s.shift in ('First','1st') then 1
when s.shift in ('Second') then 2
else 3
end shift_std
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
pu.plexus_customer_no pcn, 
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
1 off_hours,
cast('1900-01-01T06:00:01' as datetime) start_time,
cast('1900-01-01T19:00:00' as datetime) end_time,
2 notify_type, -- 1=phone, 2=text, 3=email
case 
when s.shift in ('First','1st') then 1
when s.shift in ('Second') then 2
else 3
end shift_std
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
pu.plexus_customer_no pcn, 
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
1 off_hours,
cast('1900-01-01T19:00:01' as datetime) start_time,
cast('1900-01-01T06:00:00' as datetime) end_time,
3 notify_type, -- 1=phone, 2=text, 3=email
case 
when s.shift in ('First','1st') then 1
when s.shift in ('Second') then 2
else 3
end shift_std
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
pu.plexus_customer_no pcn, 
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
1 off_hours,
cast('1900-01-01T06:00:01' as datetime) start_time,
cast('1900-01-01T19:00:00' as datetime) end_time,
2 notify_type, -- 1=phone, 2=text, 3=email
case 
when s.shift in ('First','1st') then 1
when s.shift in ('Second') then 2
else 3
end shift_std

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
pu.plexus_customer_no pcn, 
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
1 off_hours,
cast('1900-01-01T19:00:01' as datetime) start_time,
cast('1900-01-01T06:00:00' as datetime) end_time,
3 notify_type, -- 1=phone, 2=text, 3=email
case 
when s.shift in ('First','1st') then 1
when s.shift in ('Second') then 2
else 3
end shift_std

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
pu.plexus_customer_no pcn, 
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
1 off_hours,
cast('1900-01-01T06:00:01' as datetime) start_time,
cast('1900-01-01T19:00:00' as datetime) end_time,
2 notify_type, -- 1=phone, 2=text, 3=email
case 
when s.shift in ('First','1st') then 1
when s.shift in ('Second') then 2
else 3
end shift_std

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

union

select 
pu.plexus_customer_no pcn, 
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
1 off_hours,
cast('1900-01-01T19:00:01' as datetime) start_time,
cast('1900-01-01T06:00:00' as datetime) end_time,
3 notify_type, -- 1=phone, 2=text, 3=email
case 
when s.shift in ('First','1st') then 1
when s.shift in ('Second') then 2
else 3
end shift_std

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

) r

select 
r.id,
r.pcn, 
r.notify_level,
r.last_name,
r.first_name,
r.dept_name,
r.shift,
r.position,
r.email,
r.phone,
r.home_phone,
r.mobile,
r.off_hours,
r.start_time,
r.end_time,
r.notify_type,
r.shift_std
from #result r
--where notify_level = 1 and shift_std = 3
--where notify_level = 2 and off_hours = 0   and shift_std = 3
--where notify_level = 2 and off_hours = 1   and notify_type = 2
--where notify_level = 2 and off_hours = 1   and notify_type = 3
--where notify_level = 3 and off_hours = 0   and shift_std = 3
--where notify_level = 3 and off_hours = 1   and notify_type = 2
--where notify_level = 3 and off_hours = 1   and notify_type = 3
--where notify_level = 4 and off_hours = 1   and notify_type = 2
--where notify_level = 4 and off_hours = 1   and notify_type = 3
--where notify_level = 5 and off_hours = 1   and notify_type = 2
--where notify_level = 5 and off_hours = 1   and notify_type = 3
