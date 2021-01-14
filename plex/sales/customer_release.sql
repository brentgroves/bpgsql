--/////////////////////////////////////////////////////////
--Plex Screen: Customer Release
--Duplicate customer release screen
-- Differences:
-- Sometimes a shipper is displayed on the customer release screen that is not shown on this query.
-- We only show shippers that have a shipper_line with the same release key as the sales_v_release record being displayed.
-- We don't know plexes algorithm for this.

--Parameters:
-- @End_Due_Date
-- @Building_Key

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


--FUTURE Status
--select distinct release_status from sales_v_release_status
-- 	release_status
--1	Canceled
--2	Closed
--3	Hold
--4	Open
--5	Open - Scheduled
--6	Scheduled
--7	Staged

--Questions:
--Does intelliplex allow passing data table as a parameter.?  If so we could pass multiple status values.
--https://codingsight.com/passing-data-table-as-parameter-to-stored-procedures/
--//////////////////////////////////////////////////////////




--//////////////////////////////////////////////////////////
--Check Parameters
--/////////////////////////////////////////////////////////

Declare @Building_Key  int

set @Building_Key =
case
when @Building_Code = 'Plant 2' then 5643
when @Building_Code = 'Plant 3' then 5642
when @Building_Code = 'Plant 5' then 5504
when @Building_Code = 'Plant 6' then 5644
when @Building_Code = 'Plant 8' then 5641
when @Building_Code = 'Plant 9' then 5646
when @Building_Code = 'Plant 11' then 5647

end 



--SET @End_date_req = DATEADD( DAY, 1, @End_date_req )


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
shippers varchar(max),
due_date datetime,
rel_qty decimal,
qty_loaded decimal (18,3),
shipped 	decimal,  
rel_bal decimal,
release_status varchar(50),
release_type varchar(50)
)


insert into #sales_release (release_key,part_key,customer,po,release,ship_to,part_no,cust_part,part_name,ship_date,shippers,due_date,rel_qty,qty_loaded, shipped,rel_bal,release_status,release_type)
exec sproc300758_11728751_1653651 @End_Ship_Date, @Building_Key

--select distinct release_status from sales_v_release_status
-- 	release_status
--1	Canceled
--2	Closed
--3	Hold
--4	Open
--5	Open - Scheduled
--6	Scheduled
--7	Staged

--select count(*) #sales_release from #sales_release  --554 

create table #part_wip_ready_loaded
(
part_key int,
qty_wip decimal (19,5),
qty_ready decimal (19,5),
qty_loaded decimal (19,5)
);

--There are three ways of getting qty_loaded through the part_v_container, sales_v_shipper_line, and sales_shipper_container tables.
-- See sales_release SPROC for details.
--We are calculating Loaded quantities using the part_v_container and sales_v_shipper_container methods 
-- and returning the results from the sales_v_shipper_container because it
-- Links directly to a release_key.
insert into #part_wip_ready_loaded (part_key,qty_wip,qty_ready,qty_loaded)
exec sproc300758_11728751_1660208

--select count(*) #part_container_wip_ready_loaded from #part_container_wip_ready_loaded

--update #part_container_wip_ready_loaded
--set row_number =1
--select top 10 * from #part_container_wip_ready_loaded
--//////////////////////////////////////////////////////////////////////////////////////
-- Determine WIP and Ready quantities to associate with each sales_v_release.release_key
--//////////////////////////////////////////////////////////////////////////////////////


create table #sales_release_row_number
(
row_number int,
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
shippers varchar(max),
due_date datetime,
rel_qty decimal,
qty_loaded decimal (18,3),
shipped 	decimal,  
rel_bal decimal,
release_status varchar(50),
release_type varchar(50)
)

insert into #sales_release_row_number (row_number,release_key,part_key,customer,po,release,ship_to,part_no,cust_part,part_name,ship_date,shippers,due_date,rel_qty,qty_loaded, shipped,rel_bal,release_status,release_type)
(
select 
ROW_NUMBER() OVER (
  PARTITION BY sr.part_key
  ORDER BY sr.ship_date,sr.release_key
) row_number,
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
shippers,
due_date,
rel_qty,
qty_loaded,
shipped,  
rel_bal,
release_status,
release_type
from #sales_release sr
)

--select count(*) #sales_release_row_number from #sales_release_row_number --177
--where release = ''  --53


--At the due date of the sales release what quantity 
--is already needed by all earlier sales release items.
create table #sales_release_rel_due
(
row_number int,
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
shippers varchar(max),
due_date datetime,
rel_qty decimal,
qty_loaded decimal (18,3),
shipped 	decimal,  
rel_bal decimal,
rel_due  decimal,
total_rel_due decimal,
release_status varchar(50),
release_type varchar(50),
)

insert into #sales_release_rel_due (row_number,release_key,part_key,customer,po,release,ship_to,part_no,cust_part,part_name,ship_date,shippers,due_date,rel_qty,qty_loaded, shipped,rel_bal,rel_due,total_rel_due,release_status,release_type)
(
select
row_number,
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
shippers,
due_date,
rel_qty,
qty_loaded,
shipped,  
rel_bal,
ISNULL(
(  
  select 
  sum(sr2.rel_bal) 
  from #sales_release_row_number sr2
  where sr2.part_key=sr.part_key
  and sr2.row_number < sr.row_number
  and sr2.rel_bal >=0  
  --SOMETIMES REL_BAL IS LESS THAN 0 BECAUSE WE SHIP TOO MUCH IN A CONTAINER.
  --MAYBE I SHOULD SEE HOW WE ARE SUPPOSED TO HANDLE THIS SITUATION.
),0) AS rel_due,
ISNULL(
(  
  select 
  sum(sr3.rel_bal) 
  from #sales_release_row_number sr3
  where sr3.part_key=sr.part_key
  and sr3.row_number <= sr.row_number
  and sr3.rel_bal >=0  
  --SOMETIMES REL_BAL IS LESS THAN 0 BECAUSE WE SHIP TOO MUCH IN A CONTAINER.
  --MAYBE I SHOULD SEE HOW WE ARE SUPPOSED TO HANDLE THIS SITUATION.
),0) AS total_rel_due,
release_status,
release_type
from #sales_release_row_number sr
--and qty_loaded > 0
--and qty_loaded > 0
--where part_key = 	2793937
)

--select count(*) #sales_release_rel_due from #sales_release_rel_due  --177


--//////////////////////////////////////////////////////
--Add the total part quanty ready for shipment 
-- and quantity where the final operation has
-- not been completed, ie WIP.
-- Determine the qty ready that is still avail after
-- filling all previous sales release item orders.
--////////////////////////////////////////////////////////
create table #sales_release_qty_ready_avail
(
row_number int,
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
shippers varchar(max),
due_date datetime,
rel_qty decimal,
qty_loaded decimal (18,3),
shipped 	decimal,  
rel_bal decimal,
rel_due  decimal,
total_rel_due decimal,
release_status varchar(50),
release_type varchar(50),
tot_qty_ready decimal,
tot_qty_wip decimal,
qty_ready_avail decimal
)

insert into #sales_release_qty_ready_avail (row_number,release_key,part_key,customer,po,release,ship_to,part_no,cust_part,part_name,ship_date,shippers,due_date,rel_qty,qty_loaded, shipped,rel_bal,rel_due,total_rel_due,release_status,release_type,tot_qty_ready,tot_qty_wip,qty_ready_avail)
(

select
row_number,
release_key,
rd.part_key,
customer,
po,
release,
ship_to,
part_no, 
cust_part, 
part_name, 
ship_date,
shippers,
due_date,
rel_qty,
rd.qty_loaded,
shipped,  
rel_bal,
rel_due,
total_rel_due,
release_status,
release_type,
wrl.qty_ready as tot_qty_ready,
wrl.qty_wip as tot_qty_wip,
case
  when wrl.qty_ready is null then 0
  when (wrl.qty_ready >= rd.rel_due) then wrl.qty_ready - rel_due
  else 0
end as qty_ready_avail
from #sales_release_rel_due rd
left outer join #part_wip_ready_loaded wrl  --1 to 0/1
on rd.part_key=wrl.part_key
)

--select count(*)  #sales_release_qty_ready_avail from  #sales_release_qty_ready_avail
--select top(100) * from #sales_release_qty_ready_avail 



--//////////////////////////////////////////////////////
--Determine qty ready for this sales release item
-- using the previously calculated qty ready available value
-- and the current release balance.
--Also calculate the new release balance from the old 
-- and the qty ready amount
--////////////////////////////////////////////////////////
create table #sales_release_qty_ready
(
row_number int,
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
shippers varchar(max),
due_date datetime,
rel_qty decimal,
qty_loaded decimal (18,3),
shipped 	decimal,  
rel_bal decimal,
rel_due  decimal,
total_rel_due decimal,
release_status varchar(50),
release_type varchar(50),
tot_qty_ready decimal,
tot_qty_wip decimal,
qty_ready_avail decimal,
qty_ready decimal,
rel_bal2 decimal
)

insert into #sales_release_qty_ready (row_number,release_key,part_key,customer,po,release,ship_to,part_no,cust_part,part_name,
ship_date,shippers,due_date,rel_qty,qty_loaded, shipped,rel_bal,rel_due,total_rel_due,release_status,release_type,tot_qty_ready,tot_qty_wip,qty_ready_avail,qty_ready,rel_bal2)
(

select
row_number,
release_key,
rd.part_key,
customer,
po,
release,
ship_to,
part_no, 
cust_part, 
part_name, 
ship_date,
shippers,
due_date,
rel_qty,
rd.qty_loaded,
shipped,  
rel_bal,
rel_due,
total_rel_due,
release_status,
release_type,
tot_qty_ready,
tot_qty_wip,
qty_ready_avail,
case
  when (rel_bal >= qty_ready_avail) then qty_ready_avail
  else rel_bal
end as qty_ready,
case
  when (rel_bal >= qty_ready_avail) then rel_bal-qty_ready_avail
  else 0
end as rel_bal2
from #sales_release_qty_ready_avail rd
)

--select count(*)  #sales_release_qty_ready from  #sales_release_qty_ready  --177
--select top(100) * from #sales_release_qty_ready 


--//////////////////////////////////////////////////////
--From the new release balances calculate the new release
-- due value from the sum of all previously dues release
-- balances.
--////////////////////////////////////////////////////////
create table #sales_release_rel_due2
(
row_number int,
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
shippers varchar(max),
due_date datetime,
rel_qty decimal,
qty_loaded decimal (18,3),
shipped 	decimal,  
rel_bal decimal,
rel_due  decimal,
total_rel_due decimal,
release_status varchar(50),
release_type varchar(50),
tot_qty_ready decimal,
tot_qty_wip decimal,
qty_ready_avail decimal,
qty_ready decimal,
rel_bal2 decimal,
rel_due2 decimal
)

insert into #sales_release_rel_due2 (row_number,release_key,part_key,customer,po,release,ship_to,part_no,cust_part,part_name,
ship_date,shippers,due_date,rel_qty,qty_loaded, shipped,rel_bal,rel_due,total_rel_due,release_status,release_type,tot_qty_ready,tot_qty_wip,qty_ready_avail,qty_ready,rel_bal2,rel_due2)
(

select
row_number,
release_key,
rd.part_key,
customer,
po,
release,
ship_to,
part_no, 
cust_part, 
part_name, 
ship_date,
shippers,
due_date,
rel_qty,
rd.qty_loaded,
shipped,  
rel_bal,
rel_due,
total_rel_due,
release_status,
release_type,
tot_qty_ready,
tot_qty_wip,
qty_ready_avail,
qty_ready,
rel_bal2,
ISNULL((
  select sum(rel_bal2)
  from #sales_release_qty_ready rd2
  where rd2.part_key=rd.part_key
  and rd2.row_number<rd.row_number
),0) as rel_due2
from #sales_release_qty_ready rd
)

--select count(*)  #sales_release_rel_due2 from  #sales_release_rel_due2  --177
--select top(100) * from #sales_release_rel_due2 

--//////////////////////////////////////////////////////
--From the new release due values calculate the quantity
--WIP available subtracting from the new release balance
--////////////////////////////////////////////////////////
create table #sales_release_wip_avail
(
row_number int,
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
shippers varchar(max),
due_date datetime,
rel_qty decimal,
qty_loaded decimal (18,3),
shipped 	decimal,  
rel_bal decimal,
rel_due  decimal,
total_rel_due decimal,
release_status varchar(50),
release_type varchar(50),
tot_qty_ready decimal,
tot_qty_wip decimal,
qty_ready_avail decimal,
qty_ready decimal,
rel_bal2 decimal,
rel_due2 decimal,
qty_wip_avail decimal,
)

insert into #sales_release_wip_avail (row_number,release_key,part_key,customer,po,release,ship_to,part_no,cust_part,part_name,
ship_date,shippers,due_date,rel_qty,qty_loaded, shipped,rel_bal,rel_due,total_rel_due,release_status,release_type,tot_qty_ready,tot_qty_wip,qty_ready_avail,qty_ready,rel_bal2,rel_due2,qty_wip_avail)
(

select
row_number,
release_key,
rd.part_key,
customer,
po,
release,
ship_to,
part_no, 
cust_part, 
part_name, 
ship_date,
shippers,
due_date,
rel_qty,
rd.qty_loaded,
shipped,  
rel_bal,
rel_due,
total_rel_due,
release_status,
release_type,
tot_qty_ready,
tot_qty_wip,
qty_ready_avail,
qty_ready,
rel_bal2,
rel_due2,
case
when (tot_qty_wip >= rel_due2) then tot_qty_wip - rel_due2
else 0
end as qty_wip_avail
from #sales_release_rel_due2 rd
)

--select count(*)  #sales_release_wip_avail from  #sales_release_wip_avail  --177
--select top(100) * from #sales_release_wip_avail 



--//////////////////////////////////////////////////////
--Determine WIP quantity from the previously calculated
--WIP quantity available and the new release balance.
--////////////////////////////////////////////////////////
create table #sales_release_wip
(
row_number int,
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
shippers varchar(max),
due_date datetime,
rel_qty decimal,
qty_loaded decimal (18,3),
shipped 	decimal,  
rel_bal decimal,
rel_due  decimal,
total_rel_due decimal,
release_status varchar(50),
release_type varchar(50),
tot_qty_ready decimal,
tot_qty_wip decimal,
qty_ready_avail decimal,
qty_ready decimal,
rel_bal2 decimal,
rel_due2 decimal,
qty_wip_avail decimal,
qty_wip decimal
)

insert into #sales_release_wip (row_number,release_key,part_key,customer,po,release,ship_to,part_no,cust_part,part_name,
ship_date,shippers,due_date,rel_qty,qty_loaded, shipped,rel_bal,rel_due,total_rel_due,release_status,release_type,tot_qty_ready,
tot_qty_wip,qty_ready_avail,qty_ready,rel_bal2,rel_due2,qty_wip_avail,qty_wip)
(

select
row_number,
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
shippers,
due_date,
rel_qty,
qty_loaded,
shipped,  
rel_bal,
rel_due,
total_rel_due,
release_status,
release_type,
tot_qty_ready,
tot_qty_wip,
qty_ready_avail,
qty_ready,
rel_bal2,
rel_due2,
qty_wip_avail,
case
  when (rel_bal2 >= qty_wip_avail) then qty_wip_avail
  else rel_bal2
end as qty_wip
from #sales_release_wip_avail 
)

--select count(*)  #sales_release_wip from  #sales_release_wip  --177
--select top(100) * from #sales_release_wip 

--Remove unneeded columns used for debugging.
create table #customer_releases
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
qty_ready decimal,
qty_loaded decimal,
qty_wip decimal,
ship_date datetime,
shippers varchar(max),
due_date datetime,
rel_qty decimal,
shipped 	decimal,  
rel_bal decimal,
total_rel_due decimal,
release_status varchar(50),
release_type varchar(50)
);


insert into #customer_releases (release_key, part_key,customer,po,release,ship_to,part_no,cust_part,part_name,qty_ready,qty_loaded,qty_wip,ship_date,shippers,due_date,rel_qty,shipped,rel_bal,total_rel_due,release_status,release_type)
(
  select
  --s1.row_number,wr.row_number,
  sr.release_key,
  sr.part_key,
  customer,
  po,
  release,
  ship_to,
  part_no,
  cust_part,
  part_name,
  qty_ready,
  qty_loaded,
  qty_wip,
  ship_date,
  shippers,
  due_date,
  rel_qty,
  shipped,
  rel_bal,
  total_rel_due,
  release_status,
  release_type
  from #sales_release_wip sr
)

--select count(*) #customer_releases from #customer_releases
select 
  --release_key,
  --part_key,
  customer,
  po,
  release,
  ship_to,
  part_no,
  cust_part,
  part_name,
  qty_ready,
  qty_loaded,
  qty_wip,
  ship_date,
  shippers,
  due_date,
  rel_qty,
  shipped,
  rel_bal,
  total_rel_due,
  release_status,
  release_type
from #customer_releases
--where qty_loaded > 0
order by customer,po,release,part_no, ship_date,release_key
--where part_key = 2800943