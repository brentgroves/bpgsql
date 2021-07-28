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

select Name,Primary_Plexus_Customer_No,Plexus_Customer_No,Plexus_Customer_Code,Plexus_Customer_Name from Plexus_Control_v_Customer_Group_Member
	*/
select pu.plexus_customer_no pcn, gm.plexus_customer_code,pu.last_name,pu.first_name,
pu.department_no,
pu.email,
pu.phone,
pu.home_phone,
pu.mobile 
--select count(*)
from Plexus_Control_v_Plexus_User_e pu  -- 7487
inner join Plexus_Control_v_Customer_Group_Member gm 
on pu.plexus_customer_no=gm.plexus_customer_no  -- 7487
where first_name like '%Kevin%'
-- where plexus_user_no = 11728751 -- brent
--where plexus_user_no = 11