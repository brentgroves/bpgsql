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
create table #recipient
(
  recipient_key int,
  pcn int,
  shift varchar(15),
  shift_std tinyint,
  dept_name varchar(50),
  position varchar(50),
  last_name varchar(50),
  first_name varchar(50),
  SMS varchar(25),
  email varchar(100),
  customer_employee_no varchar(50)  -- plex reference
)


insert into #recipient(recipient_key,pcn,shift,shift_std,dept_name,position,last_name,first_name,SMS,email,customer_employee_no)
select 
row_number() over( order by pcn,position,name,shift,last_name,first_name) recipient_key,
r.pcn,
r.shift,
r.shift_std,
r.name dept_name,
r.position,
r.last_name,
r.first_name,
r.SMS,
r.email,
r.customer_employee_no
from 
(
select 
pu.plexus_customer_no pcn, 
--gm.plexus_customer_code,
s.shift,
case 
when s.shift in ('First','1st') then 1
when s.shift in ('Second') then 2
else 3
end shift_std,
d.name,
p.position,
pu.last_name,
pu.first_name,
um.SMS,
pu.email,
e.Customer_Employee_No -- Every user gets an employee number HR has the next number written down when someone is hired
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

inner join plexus_control_v_plexus_user_messaging_e um
on pu.plexus_user_no = um.plexus_user_no
--where pu.plexus_user_no = 11728751 -- brent
where pu.plexus_customer_no = @PCN
and p.position = 'Team Leader'
and d.name in ('Cast','Tool & Mold')
and e.employee_status = 'Active' 

union

select 
pu.plexus_customer_no pcn, 
--gm.plexus_customer_code,
s.shift,
case 
when s.shift in ('First','1st') then 1
when s.shift in ('Second') then 2
else 3
end shift_std,
d.name,
p.position,
pu.last_name,
pu.first_name,
um.SMS,
pu.email,
e.Customer_Employee_No -- Every user gets an employee number HR has the next number written down when someone is hired
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
inner join plexus_control_v_plexus_user_messaging_e um
on pu.plexus_user_no = um.plexus_user_no
where pu.plexus_customer_no = @PCN
and p.position in ('Production Supervisor','Senior Process Engineer')
and e.employee_status = 'Active' 

union

select
pu.plexus_customer_no pcn, 
--gm.plexus_customer_code,
s.shift,
case 
when s.shift in ('First','1st') then 1
when s.shift in ('Second') then 2
else 3
end shift_std,
d.name,
p.position,
pu.last_name,
pu.first_name,
um.SMS,
pu.email,
e.Customer_Employee_No -- Every user gets an employee number HR has the next number written down when someone is hired
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
inner join plexus_control_v_plexus_user_messaging_e um
on pu.plexus_user_no = um.plexus_user_no
where pu.plexus_customer_no = @PCN
and p.position in ('Operations Manager','Environmental Health and Safety Manager','Tooling Engineer Manager','Tool Room Manager','Melt Manager','Maintenance Manager')
and e.employee_status = 'Active' 
--and s.shift in ('1st')
--order by s.shift

union

select 
pu.plexus_customer_no pcn, 
--gm.plexus_customer_code,
s.shift,
case 
when s.shift in ('First','1st') then 1
when s.shift in ('Second') then 2
else 3
end shift_std,
d.name,
p.position,
pu.last_name,
pu.first_name,
um.SMS,
pu.email,
e.Customer_Employee_No -- Every user gets an employee number HR has the next number written down when someone is hired
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
inner join plexus_control_v_plexus_user_messaging_e um
on pu.plexus_user_no = um.plexus_user_no
where pu.plexus_customer_no = @PCN
and p.position in ('Vice President - Fruitport')  -- PPT SAID PLANT MANAGER
and e.employee_status = 'Active' 
--and s.shift in ('1st')
--order by s.shift

union

select 
pu.plexus_customer_no pcn, 
--gm.plexus_customer_code,
case
when s.shift is null then '1st'
else s.shift
end shift,
case 
when s.shift is null then 1
when s.shift in ('First','1st') then 1
when s.shift in ('Second') then 2
else 3
end shift_std,
d.name,
p.position,
pu.last_name,
pu.first_name,
um.SMS,
pu.email,
e.Customer_Employee_No -- Every user gets an employee number HR has the next number written down when someone is hired
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

inner join plexus_control_v_plexus_user_messaging_e um
on pu.plexus_user_no = um.plexus_user_no
where p.position in ('EVP COO & General Mgr North America')  

) r

--select count(distinct r.customer_employee_no) from #recipient r  -- 36

select 
r.recipient_key,
r.pcn, 
r.shift,
r.shift_std,
r.dept_name,
r.position,
r.last_name,
r.first_name,
r.SMS,
r.email,
r.Customer_Employee_No -- Every user gets an employee number HR has the next number written down when someone is hired
from #recipient r  -- 36