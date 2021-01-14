-- #sales_release_part all the parts that are setup to run in workcenter assigned to a building
-- #sales_active_shipper_container contains only active shippers (open,pending)
--  #sales_active_shipper_container_group_release  contains the qty_loaded, sum of (open,pending) shippers
-- #sales_all_shipper_container contains all containers no matter the shipper status (open,pending,shipped,cancelled)
-- #sales_release_last_shipper last shipped and active shippers for containers in a release_key.

-- Mimics Plex sales release screen
-- ToDo:  
-- Reports: sales_release or customer_releases
-- release_status: active. 
-- release_type: Any. 

--/////////////////////////////////////////////////////
--All parts ran in each building
--////////////////////////////////////////////////////
--5650	BPG Central Stores
--5651	BPG Distribution Center
--5696	BPG Edon
--5652	BPG Metrology Lab
--5647	BPG Plant 11
--5643	BPG Plant 2
--5642	BPG Plant 3
--5504	BPG Plant 5
--5644	BPG Plant 6
--5645	BPG Plant 7
--5641	BPG Plant 8
--5646	BPG Plant 9
--5660	BPG Pole Barn
--5648	BPG Warehouse
--5649	BPG Workholding

-- Each workcenter has only 1 record, part_key, and part_operation_key.
create table #part_workcenter_building
(
part_key int,
workcenter_key int,
building_key int
)
--////////////////////////////////////////////////////////////////////////
-- All parts assigned to each workcenter.
-- We could add distinct and where clause to set
-- and capture all parts setup to run in a building.
--////////////////////////////////////////////////////////////////////////
insert into #part_workcenter_building (part_key,workcenter_key,building_key)
(
select 
--top(100) 
s.part_key,
w.workcenter_key,
w.building_key
--p.part_no,
--w.workcenter_code,
--b.building_code
from part_v_setup s  --182  
inner join part_v_workcenter w  -- 1to1 --182
on s.workcenter_key=w.workcenter_key
inner join common_v_building b  --1to1 --182  
on w.building_key=b.building_key
inner join part_v_part p  --1 to 1 --182  
on s.part_key=p.part_key
--where b.building_key = 5642
--order by s.part_key,b.building_key
)

-- select count(*) #part_workcenter_building from #part_workcenter_building  --162

--All distinct parts setup to run on workcenters assigned to a specific building
create table #part_building
(
part_key int
)

--Declare @Building_Key int
--set @Building_Key = 5641

insert into #part_building (part_key)
select distinct part_key 
from #part_workcenter_building pwb
where pwb.building_key = @Building_Key

--select count(*) #part_building from #part_building  --22


--///////////////////////////////////////////////////////////////////////////
-- Sales releases being fullfilled by work centers in a specific building
-- This set has all sales release items we want in the result set.
--//////////////////////////////////////////////////////////////////////////
create table #sales_release_part
(
  release_key int,
  po_line_key int,
  release_status_key int,
  release_type_key int,
  part_key int,
  release_no varchar(50), 
  ship_to	varchar(50),  
  ship_date datetime,
  due_date datetime,
  quantity decimal, 
  quantity_shipped int  
)


insert into #sales_release_part (release_key,po_line_key,release_status_key,release_type_key,part_key,release_no,ship_to,ship_date, due_date,quantity,quantity_shipped)
select 
--top 10
sr.release_key,
pl.po_line_key,
sr.release_status_key,
release_type_key,
pl.part_key,
release_no,
ship_to,
ship_date, 
due_date,
quantity,
quantity_shipped
from sales_v_release sr
left outer join sales_v_po_line pl --1 to 1
on sr.po_line_key=pl.po_line_key 
left outer join sales_v_release_status rs  -- 1 to 1
on sr.release_status_key=rs.release_status_key  
where pl.part_key in  -- Limit to sales_release being filled by workcenters in a specific building.
(
  select part_key from #part_building  --parts being filled by workcenters in specific building.
)
and rs.active = 1  --Open,Staged,Scheduled,Open - Scheduled
-- does not include Canceled, Hold,Closed
and due_date <= @End_Ship_Date --193
-- select count(*) #sales_release_part from #sales_release_part --5

-- #sales_release_part all the parts that are setup to run in workcenter assigned to a building
-- #sales_active_shipper_container contains only active shippers (open,pending)
--  #sales_active_shipper_container_group_release  contains the qty_loaded, sum of (open,pending) shippers
-- #sales_all_shipper_container contains all containers no matter the shipper status (open,pending,shipped,cancelled)

-- select * from sales_v_release_status
--TESTING PURPOSES BELOW THIS LINE
--and release_status not in
--(
--'Cancelled',
--'Closed'
--)
--and 
--( 
--  release_no != '' or (release_no = '' and quantity != 0)  
-- I found 1 sales release item with no release number but a released quantity this was probably on hold but I'm not sure
--)
--and (due_date <= @End_Due_Date) and (quantity > quantity_shipped)--193  -- quantity check not necessary

/* --///////////////////////////////////////////
-- mrp = Material requirement planning
--/////////////////////////////////////////////
 	release_status_key	release_status	active	include_in_mrp	color
1	70	Canceled	0	0	#CCFFCC
2	71	Open	1	1	#FFFFFF
3	72	Hold	0	0	
4	73	Closed	0	0	#9999FF
5	74	Staged	1	1	#FFFFCC
6	75	Scheduled	1	1	#CCCCCC
7	3659	Open - Scheduled	1	1	
Row Count: 7
--This color does not seem to be rendered on the customer release screen.
--/////////////////////////////////////////////
*/  --/////////////////////////////////////////


--select count(*) #sales_release_part from #sales_release_part --171


--///////////////////////////////////////////////////////////////
-- A shipper container gets created when a part container is
-- scanned into the load container to shipper screen.
-- Used to caculate the sum of loaded containers for a part.
-- This sum can also be calculated by the part_v_container.container_status = 'Loaded'
-- This sum can also be derived by summing the shipper_lines
-- See part_v_wip_ready_loaded sproc.
--//////////////////////////////////////////////////////////////
create table #sales_active_shipper_container
(
shipper_line_key int,
serial_no varchar(50),
release_key int,
quantity decimal (18,3)
);


insert into #sales_active_shipper_container (shipper_line_key,serial_no,release_key,quantity)
(
select 
--sh.shipper_no,
--ss.shipper_status,
--ss.active,
--sc.*
sc.shipper_line_key,
sc.serial_no,
sc.release_key,
sc.quantity
--sc.loaded_date
from #sales_release_part sr
left outer join sales_v_shipper_container sc --1 to many  
on sr.release_key=sc.release_key
left outer join sales_v_shipper_line sl --1 to 1
--Shipper_container primary key is shipper_line_key,serial_no,release_key combination
on sc.shipper_line_key=sl.shipper_line_key  --many to 1 ; There can be many shipper_containers for a shipper_line
left outer join sales_v_shipper sh  --1 to 1
on sl.shipper_key=sh.shipper_key
left outer join sales_v_shipper_status ss --1 to 1
on sh.shipper_status_key=ss.shipper_status_key
where ss.active = 1  
--A small set of containers that are ready to ship.  
--Although unsure of what exactly pending means.  
--The active shipper_container total is equal to the 
--loaded part_v_container on every one I have checked.
--See equivalency test below
)

--select shipper_status_key,shipper_status,active from sales_v_shipper_status
-- 	shipper_status_key	shipper_status	active
--	90	Open	1
--	91	Shipped	0
--	92	Canceled	0
--	93	Pending	1  --??


-- select count(*) #sales_active_shipper_container from #sales_active_shipper_container  --25
-- select * from #sales_active_shipper_container  

--where loaded_date is null  --0

--/////////////////////////////////////////////////////////////
-- Group the active shipper containers by release key to get the
-- total quantity 'Loaded' directly related to a release key.
-- This same sum can be calculated from part_v_container
-- where container_status='Loaded', but was not able to figure
-- out how to link part_v_container to a sales_v_release.
-- It can also be calculated more simply from adding the shipper_line
-- quantities.  See equivalency test below.  
--//////////////////////////////////////////////////////////////
create table #sales_active_shipper_container_group_release
(
release_key int,
qty_loaded decimal (18,3)
);

insert into #sales_active_shipper_container_group_release (release_key,qty_loaded)
(
select 
release_key,
sum(quantity) qty_loaded
from #sales_active_shipper_container
group by release_key
) 

--select count(*) #sales_active_shipper_container_group_release from #sales_active_shipper_container_group_release  --4

-- select * from #sales_active_shipper_container_group_release

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
create table #sales_all_shipper_container
(
release_key int,
shipper_no varchar(50),
shipper_status varchar(50),
quantity decimal,
ship_date smalldatetime,
active smallint

);

insert into #sales_all_shipper_container (release_key,shipper_no,shipper_status,quantity,ship_date,active)
(

select 
--ss.*,
--sh.shipper_no,
sr.release_key,
sh.shipper_no,
ss.shipper_status,
sc.quantity,
sh.ship_date,
ss.active

from #sales_release_part sr
left outer join sales_v_shipper_container sc --1 to many  
on sr.release_key=sc.release_key
left outer join sales_v_shipper_line sl --1 to 1
--Shipper_container primary key is shipper_line_key,serial_no,release_key combination
on sc.shipper_line_key=sl.shipper_line_key  --1 to 1
--and sc.release_key=sl.release_key
left outer join sales_v_shipper sh  --1 to 1
on sl.shipper_key=sh.shipper_key
left outer join sales_v_shipper_status ss --1 to 1
on sh.shipper_status_key=ss.shipper_status_key
)



--select count(*) #sales_shipper_line from #sales_shipper_line  --4
--select * from #sales_shipper_line  --4
--where shipper_no is not null

--select * from #sales_shipper_line
--select shipper_status_key,shipper_status,active from sales_v_shipper_status
-- 	shipper_status_key	shipper_status	active
--	90	Open	1
--	91	Shipped	0
--	92	Canceled	0
--	93	Pending	1  --??


-- //////////////////////////////////////////////////////////////
-- All shippers for each sales release
-- For each release_key we are going to show the quantity shipped
-- and the last ship date if the sales release has been shipped
-- otherwise if the shipper lines have not been shipped then
-- show the last ship_date which may represent the loaded date.
-- Why are we calling this field shipers since it never has
-- more than one shipper_no?
-- Should be called the last ship date
-- Should rename this table to #sales_releases_last_shipper?
-- //////////////////////////////////////////////////////////////

create table #sales_release_last_shipper
(
release_key int,
-- Why are we calling this field shipers since it never has
-- more than one shipper_no?
-- Should be called the last ship date
last_shipped_shipper 	varchar(50),
last_active_shipper varchar(50)
);


insert into #sales_release_last_shipper (release_key,last_shipped_shipper,last_active_shipper)
(
  select
  release_key,last_shipped_shipper,last_active_shipper
  from
  (
    -- 1 record for each release key, 
    select sl.release_key,
    (
      select top(1)
      slx.shipper_no
      from #sales_all_shipper_container slx
      where slx.release_key=sl.release_key
      and slx.shipper_status = 'Shipped'
      order by slx.ship_date desc
    ) as last_shipped_shipper,
    (
      select top(1)
      slx.shipper_no
      from #sales_all_shipper_container slx
      where slx.release_key=sl.release_key
      and slx.active = 1
      order by slx.ship_date desc
    ) as last_active_shipper
    from #sales_all_shipper_container sl  --11531
    group by sl.release_key
  )s1
)



-- select count(*) #sales_release_last_shipper from  #sales_release_last_shipper --70

-- select * from  #sales_release_last_shipper 

--select * from #sales_shipper_line
--select shipper_status_key,shipper_status,active from sales_v_shipper_status
-- 	shipper_status_key	shipper_status	active
--	90	Open	1
--	91	Shipped	0
--	92	Canceled	0
--	93	Pending	1  --??


--///////////////////////////////////////////////////////////
-- Answer question does sum derived from adding shipper
-- container quantities for a release key equal
-- value given by adding the shipper_line quantity fields.
-- Answer: yes
-- Does adding part_v_container with container_status 
-- equal 'Loaded' also give the same result.
-- Answer: Yes. Although I can't link the part_container
-- directly to a sales_release like in the other 2 methods.
--///////////////////////////////////////////////////////////
/*
 	release_key	shipper_no	quantity
'102765075',	
'101553357',	
'101034163',	
'102151711',	
'102151712',	
'102356018',	
'101094353'	



select sc.release_key,
p.part_no,
sum(sc.quantity) shipper_container_qty
from #sales_active_shipper_container sc
left outer join sales_v_release sr  --1 to 1
on sc.release_key=sr.release_key
left outer join sales_v_po_line pl --1 to 1
on sr.po_line_key=pl.po_line_key 
left outer join part_v_part p -- 1 to 1
on pl.part_key=p.part_key 
group by sc.release_key,p.part_no
having sc.release_key in
(
'102765075',	
'101553357',	
'101034163',	
'102151711',	
'102151712',	
'102356018',	
'101094353'	
)



select 
--count(*) cnt
--distinct sr.release_key  --171
sl.release_key,
p.part_no,
sum(sl.quantity) tot_calc_shipper_lines
from sales_v_shipper_line sl  --6 
left outer join sales_v_shipper sh  --1 to 1
on sl.shipper_key=sh.shipper_key
left outer join sales_v_shipper_status ss --1 to 1
on sh.shipper_status_key=ss.shipper_status_key
left outer join sales_v_release sr  --1 to 1
on sl.release_key=sr.release_key
left outer join sales_v_po_line pl --1 to 1
on sr.po_line_key=pl.po_line_key 
left outer join part_v_part p -- 1 to 1
on pl.part_key=p.part_key 
group by sl.release_key,p.part_no,ss.active
having sl.release_key in
(
'102765075',	
'101553357',	
'101034163',	
'102151711',	
'102151712',	
'102356018',	
'101094353'	
) 
and ss.active = 1  

create table #part_wip_ready_loaded
(
part_key int,
qty_wip decimal (19,5),
qty_ready decimal (19,5),
qty_loaded decimal (19,5)
);

insert into #part_wip_ready_loaded (part_key,qty_wip,qty_ready,qty_loaded)
exec sproc300758_11728751_1660208


select sr.release_key,
p.part_no,
qty_loaded
from #sales_release_part sr  --171
inner join #part_wip_ready_loaded wrl --1 to 1
on sr.part_key=wrl.part_key 
--I THINK THERE IS ONLY 1 SET OF SHIPPER_CONTAINERS FOR ANY PART_KEY BUT I'M NOT SURE.
--I COULD PROBABLY JOIN THE PART_CONTAINER TO THE SETUP_CONTAINER BY SERIAL NUMBER
-- SINCE THEY ARE THE SAME IN BOTH TABLES.
--BUT I WILL STICK WITH THE SHIPPER_CONTAINER OR SHIPPER LINE METHOD SINCE I AM GIVEN
--A RELEASE_KEY WITH BOTH TABLES.
inner join part_v_part p --1 to 1
on sr.part_key=p.part_key
where sr.release_key in
(
'102765075',	
'101553357',	
'101034163',	
'102151711',	
'102151712',	
'102356018',	
'101094353'	
)

*/
--///////////////////////////////////////////////////////////


create table #sales_release_no_rel_bal
(
release_key int,
part_key int,
customer varchar(35),
po varchar(50),
release 	varchar(50),
ship_to 	varchar(50),
part_no varchar(113), 
cust_part varchar(113), 
part_name varchar(100), 
ship_date datetime,
last_shipped_shipper 	varchar(50),
last_active_shipper varchar(50),
due_date datetime,
rel_qty decimal,
qty_loaded decimal (18,3),
shipped 	decimal,  
release_status varchar(50),
release_type varchar(50)
)



insert into #sales_release_no_rel_bal (release_key,part_key,customer,po,release,ship_to,part_no,cust_part,part_name,ship_date,
last_shipped_shipper,
last_active_shipper,
due_date,rel_qty,qty_loaded, shipped,release_status,release_type)
(
  select 
  --top 10
  sr.release_key,
  p.part_key,
  c.Customer_Code customer,
  po.po_no po,
  sr.release_no release, 
  ca.customer_address_code ship_to,
  case 
  when p.revision = '' then p.part_no
  else p.part_no + '_Rev_' + p.revision 
  end part_no,  --The report says 10025543 RevD I can't find the Rev word
  case 
  when  cp.Customer_Part_Revision = '' then cp.Customer_Part_No
  else cp.Customer_Part_No + '_Rev_' + cp.Customer_Part_Revision 
  end cust_part,  --The report says 10025543 RevD I can't find the Rev word
  p.name part_name, -- this could also be from the description in the customer_part table
  sr.ship_date,
  case 
  when sh.last_shipped_shipper is null then ''
  else sh.last_shipped_shipper
  end as last_shipped_shipper,
  case 
  when sh.last_active_shipper is null then ''
  else sh.last_active_shipper
  end as last_active_shipper,
  sr.due_date,
  sr.quantity rel_qty, 
  case 
    when sc.qty_loaded is null then 0
    else sc.qty_loaded
  end as qty_loaded,
  sr.quantity_shipped shipped,  -- this is contained right in the sales_release record
  rs.release_status,
  rt.release_type
  --rt.allow_ship
  from #sales_release_part sr  
  left outer join sales_v_po_line pl --1 to 1
  on sr.po_line_key=pl.po_line_key 
  left outer join sales_v_po po  -- 1 to 1
  on pl.po_key = po.po_key  
  left outer join common_v_customer c  --1 to 1
  on po.customer_no=c.customer_no  
  left outer join common_v_customer_address ca  --1 to 1
  on sr.ship_to = ca.Customer_Address_No  
  left outer join part_v_part p -- 1 to 1
  on pl.part_key=p.part_key 
  left outer join part_v_customer_part cp  -- 1 to 1
  on pl.customer_part_key=cp.customer_part_key 
  left outer join #sales_release_last_shipper sh  --1 to 1 
  on sr.release_key=sh.release_key  
  left outer join sales_v_release_status rs  --1 to 1
  on sr.release_status_key=rs.release_status_key  
  left outer join sales_v_release_type rt --1 to 1
  on sr.release_type_key=rt.release_type_key 
  left outer join #sales_active_shipper_container_group_release sc  -- 1 to 1
  on sr.release_key = sc.release_key
  
    --where p.part_no = 'FR3V-5K653-CB'
    --and sr.quantity != 0
    --where sr.release_no = '2019347'
    --where sr.release_no = '857-23'
)
--select release_type from sales_v_release_type
select count(*) #sales_release_no_rel_bal from #sales_release_no_rel_bal  --554

--select count(*) count_scheduled from #sales_release_no_rel_bal  
--where release_status = 'Scheduled'  --4


create table #sales_release
(
release_key int,
part_key int,
customer varchar(35),
po varchar(50),
release 	varchar(50),
ship_to 	varchar(50),
part_no varchar(112), 
cust_part varchar(101), 
part_name varchar(100), 
ship_date datetime,
last_shipped_shipper 	varchar(50),
last_active_shipper varchar(50),
due_date datetime,
rel_qty decimal,
qty_loaded decimal (18,3),
shipped 	decimal,  
rel_bal decimal,
release_status varchar(50),
release_type varchar(50)
)


 

insert into #sales_release (release_key,part_key,customer,po,release,ship_to,part_no,cust_part,part_name,ship_date,
last_shipped_shipper,
last_active_shipper,
due_date,rel_qty,qty_loaded, shipped,rel_bal,release_status,release_type)
(
select
release_key,
part_key,
customer,
po,
release,
ship_to,
part_no, 
cust_part, 
part_name, 
ship_date,
last_shipped_shipper,
last_active_shipper,
due_date,
rel_qty,
qty_loaded,
shipped, 
rel_qty - shipped - qty_loaded as rel_bal,
release_status,
release_type
from #sales_release_no_rel_bal
)
 
--select count(*) #sales_release from #sales_release  --554

select * from #sales_release 
--  FILTER APPLIED TO SALES_RELEASE_PART SET

UPDATED SALES_RELEASE_01_11_21 
ADDED LAST_ACTIVE_SHIP_DATE AND LAST_SHIPPED_SHIP_DATE

NOW WORK ON CUSTOMER_RELEASE_FRUITPORT CALLING THIS FUNCTION