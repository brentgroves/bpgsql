/*
Validate with PRP, Customer_Releases, and Customer Shipping, Shipper History
*/
/*
All parts for a building with status of production
Whevever you want to use @Due_Date you must convert it to datetime.
-- CONVERT(datetime, @Due_Date)  less_than_due_date
-- '7/22/2001 12:00:00 AM',
19	5647	Mobex Global Plant 11
20	5643	Mobex Global Plant 2
21	5642	Mobex Global Plant 3
22	5504	Mobex Global Plant 5
23	5644	Mobex Global Plant 6
24	5645	Mobex Global Plant 7
25	5641	Mobex Global Plant 8
26	5646	Mobex Global Plant 9
*/

/*
convert sales release window to an actual datetime.
*/

--Declare @By_Due_Date varchar(50) 
--set @By_Due_Date = '8/28/2021 12:00:00 AM'


Declare @Todays_Date datetime 
set @Todays_Date = CAST(getdate() as DATE)
Declare @By_Due_Date datetime 
set @By_Due_Date = DATEADD (dd , @ForwardDayWindow + 1 , @Todays_Date ) 

-- add 1 to day and strip time.

/*
Start of Month X months ago.
*/

Declare @From_Shipped_Date datetime 
set @From_Shipped_Date = DATEADD(month,-@BackwardMonthWindow,DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0)) 
-- select @From_Shipped_Date FromShippedDate, @By_Due_Date ByDueDate



/*
Some PCN do not have parts assigned to building
So this query will have to be rethought for those PCN.
For this reason I added the pcn to the #part_building set.

*/
create table #part_building
(
pcn int not null,
part_key int not null
)
insert into #part_building (pcn,part_key)
(
select 
p.plexus_customer_no pcn,
p.part_key
--,b.building_code 
-- into #parts_assigned_plt6
from part_v_part_e p
inner join common_v_building_e b
on p.plexus_customer_no = b.plexus_customer_no
and p.building_key=b.building_key
where p.building_key = @Building_Key
and p.part_status='Production'
--- and p.part_type <> 'Raw Material' -- see NOTE# 1 below.
and p.plexus_customer_no = @PCN
)

-- select count(*) cnt_parts_in_building from #part_building

/*  NOTE #1
What part_type should be included in campfire volume data?
I don't know this field seems to be a category like 'Bearing, Sleeve, Manifolds'
But it also contains data such as 'Production Material' and 'Raw Material'
Don't think I should filter on this field unless absolutely necessary because
of it's ambiguity and it would probably require a uniquey filter for every PCN.
select distinct part_type from part_v_part_e p

What part_status should be included in campfire volume data?
select distinct plexus_customer_no,part_status from part_v_part_e p order by part_status,plexus_customer_no
There are different values of part_status for different PCN.
I have chosen to filter by 'Production' but may very well have change this value to be 
different for each PCN.  Part_status of 'Production' is in 7 of the PCN.

*/

create table #sales_release_active  -- This corresponds to the #sales_release_part set in the customer_release_due_xxx sprocs
(
  pcn int,
  release_key int,
  po_line_key int,
  release_status_key int,
  release_type_key int,
  po_status_key int,
  part_key int,
  release_no varchar(50), 
  ship_to	varchar(50),  
  ship_date datetime,
  due_date datetime,
  quantity decimal, 
  quantity_shipped int, 
  past_due int
  
)
insert into #sales_release_active (pcn,release_key,po_line_key,release_status_key,release_type_key,po_status_key,part_key,release_no,ship_to,ship_date, due_date,quantity,quantity_shipped,past_due)
select 
--top 10
sr.pcn,
sr.release_key,
pl.po_line_key,
sr.release_status_key,
release_type_key,
po.po_status_key,
pl.part_key,
sr.release_no,
sr.ship_to,
sr.ship_date, 
sr.due_date,
sr.quantity,  -- This is the quantity the customer wants.
sr.quantity_shipped,
case 
when getdate() > sr.due_date then sr.quantity - sr.quantity_shipped
else 0
end past_due
from sales_v_release_e sr
-- This has the part key. If there is no po_line we don't know what part the sales release is for.
inner join sales_v_po_line_e pl --1 to 1
on sr.pcn = pl.pcn
and sr.po_line_key=pl.po_line_key 
inner join sales_v_po_e po  -- 1 to 1
on pl.pcn = po.pcn
and pl.po_key=po.po_key  
inner join sales_v_release_status_e rs  -- 1 to 1
on sr.pcn = rs.pcn
and sr.release_status_key=rs.release_status_key  
where pl.part_key in  -- Limit to sales_release being filled by workcenters in a specific building.
(
  select part_key from #part_building pb  --parts being filled by workcenters in specific building.
  where pb.pcn = @PCN
)
and rs.active = 1  --Open,Staged,Scheduled,Open - Scheduled
--and due_date < CONVERT(datetime, @By_Due_Date) --193
--and due_date between @From_Shipped_Date and @By_Due_Date 
and due_date < @By_Due_Date --193
and sr.pcn = @PCN

-- select count(*) #sales_release_active from #sales_release_active -- 
/*
-- Start Debugging
select part_key, sum(quantity) from 
( 
select part_key, quantity from #sales_release_active 
where part_key = 2800320
--and due_date < CONVERT(datetime, @By_Due_Date) --193
and due_date < @By_Due_Date --193

) sr
group by part_key

select * from #sales_release_active 
where part_key = 2800320
and due_date < @By_Due_Date --193
--and due_date < CONVERT(datetime, @By_Due_Date) --193
order by due_date
--End Debugging
*/
/*
The active release status for all 13 PCN are: Open, Scheduled, Staged.
'Open - Scheduled' is only in 5 PCN.
*/

/*
The #sales_release_active set contains all active sales releases.  
From this set we can determine the total quantity due and shipped for each part.
Validation: This set can be verified from the Plex PRP screen.
*/

select ra.pcn,ra.part_key,sum(ra.quantity) qty_rel, sum(ra.quantity_shipped) qty_shipped, sum(ra.quantity - ra.quantity_shipped) qty_due, sum(ra.past_due) past_due
into #sales_release_active_due
from #sales_release_active ra 
group by ra.pcn,ra.part_key

-- select count(*) cnt_active from #sales_release_active_due  -- 36
--select * from #sales_release_active_due
/*
Volume shipped:
The sales_release_active_due set contains the volume shipped for the active sales releases.
This can be used to validate the shipped total on the PRP screen.
But to calc the total volume shipped we look at all sales release within a given date window active and inactive.
Validation: Shipper history report.
part_v_shipper_container
part_v_shipper

sales_v_shipper.po_key

*/

create table #sales_release_shipped
(
  pcn int,
  release_key int,
  release_type_key int,
  release_status_key int,
  release_no varchar(50), 
  shipper_key int,
  shipper_no varchar(50),
  part_key int,
  due_date datetime,
  ship_date datetime,
  serial_no varchar(40),
  quantity int,  -- THESE NEED SUMMED 
  quantity_shipped int  -- THIS IS JUST DEBUGGING PURPOSE
)
insert into #sales_release_shipped (pcn,release_key,release_type_key,release_status_key,release_no,shipper_key,shipper_no,part_key,due_date,ship_date,serial_no,quantity,quantity_shipped)
select
sr.pcn,
sr.release_key,
sr.release_type_key,
sr.release_status_key,
sr.release_no,
sh.shipper_key,
sh.shipper_no,
sl.part_key,
sr.due_date,
sh.ship_date,
c.serial_no,
c.quantity,
sr.quantity_shipped
--sh.*,
--c.*
-- select count(*)
from sales_v_release_e sr
inner join sales_v_Shipper_Line_Release_e slr
on sr.pcn=slr.pcn
and sr.release_key= slr.release_key
inner join sales_v_shipper_line_e sl
on slr.pcn=sl.pcn
and slr.shipper_line_key=sl.shipper_line_key  -- 213987
inner join sales_v_shipper_e sh
on sl.pcn=sh.pcn
and sl.shipper_key = sh.shipper_key -- 213987
inner join sales_v_shipper_container_e c
on sl.pcn=c.pcn
and sl.shipper_line_key=c.shipper_line_key  -- 2,046,828
where sl.part_key in  -- Limit to sales_release being filled by workcenters in a specific building.
(
  select part_key from #part_building pb  --parts being filled by workcenters in specific building.
  where pb.pcn = @PCN
)
--and rs.active != 1 -- Canceled, Hold,Closed  
and sh.ship_date > @From_Shipped_Date
--and due_date > CONVERT(datetime, @From_Shipped_Date) 
and sr.pcn = @PCN
and sr.quantity_shipped != 0


/*
Shipped Quantity by ship_date
*/

/*
The inactive release status for all 13 PCN are the same: Canceled,Closed,Hold

select pcn,release_status,active from sales_v_release_status_e rs where rs.active = 0 order by release_status,pcn
*/

select ri.pcn,ri.part_key, sum(ri.quantity) qty_shipped
into #sales_release_total_shipped
from #sales_release_shipped ri 
group by ri.pcn,ri.part_key

--select count(*) cnt_inactive_shipped from #sales_release_inactive_shipped sh -- 52


/*
The parts in #sales_release_total_shipped set should be a superset of #sales_release_active
But #part_building should be a superset of #sales_release_total_shipped
But there are over twice as many parts assigned to a building than there are parts that have been shipped
Because we did not filter by part type as discussed earlier
*/

-- sum(ra.quantity) qty_due, sum(ra.quantity_shipped) qty_shipped
create table #campfire_volume
(
ID int,
pcn int,
part_key int,
name varchar(100),
part_no varchar(100),
qty_rel_active_sales_release int,
qty_shipped_active_sales_release int,
--qty_shipped_inactive_sales_release int,
qty_shipped int,
qty_due int,
past_due int
)
insert into #campfire_volume (ID,pcn,part_key,name,part_no,
qty_rel_active_sales_release,
qty_shipped_active_sales_release,
--qty_shipped_inactive_sales_release,
qty_shipped,
qty_due,past_due)

select 
cast(row_number() over(order by pb.pcn,p.part_no) as int) ID,
pb.pcn,
pb.part_key,
p.name,
p.part_no,
case
when ad.qty_rel is null then 0
else ad.qty_rel
end qty_rel_active_sales_release,
case 
when ad.qty_shipped is null then 0
else ad.qty_shipped
end qty_shipped_active_sales_release,
isnull(sh.qty_shipped,0) qty_shipped,
isnull(ad.qty_due,0) qty_due,
isnull(ad.past_due,0) past_due
from #part_building pb
inner join part_v_part_e p
on pb.pcn=p.plexus_customer_no
and pb.part_key=p.part_key
left outer join #sales_release_active_due ad 
on pb.pcn = ad.pcn
and pb.part_key = ad.part_key
left outer join #sales_release_total_shipped sh 
on pb.pcn = sh.pcn
and pb.part_key = sh.part_key
where (ad.pcn is not null) or (sh.pcn is not null)
--select count(*) cnt_result from #result r
--where r.qty_due_active_sales_release != 0 or r.qty_shipped != 0

select r.pcn,r.part_key,r.name,r.part_no,r.qty_rel_active_sales_release,
r.qty_shipped_active_sales_release,
r.qty_shipped,
r.qty_due,
r.past_due
from #campfire_volume r

--where r.qty_due_active_sales_release != 0 or r.qty_shipped != 0
order by name


