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

select count(*) cnt_parts_in_building from #part_building

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
  quantity_shipped int  
)
insert into #sales_release_active (pcn,release_key,po_line_key,release_status_key,release_type_key,po_status_key,part_key,release_no,ship_to,ship_date, due_date,quantity,quantity_shipped)
select 
--top 10
sr.pcn,
sr.release_key,
pl.po_line_key,
sr.release_status_key,
release_type_key,
po.po_status_key,
pl.part_key,
release_no,
ship_to,
ship_date, 
due_date,
quantity,  -- This is the quantity the customer wants.
quantity_shipped
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
and due_date < CONVERT(datetime, @By_Due_Date) --193
and sr.pcn = @PCN

-- select count(*) #sales_release_active from #sales_release_active -- 
-- select top 100 * from #sales_release_active

/*
The active release status for all 13 PCN are: Open, Scheduled, Staged.
'Open - Scheduled' is only in 5 PCN.

select pcn,release_status,active from sales_v_release_status_e rs where rs.active = 1 order by release_status,pcn
*/

/*
The #sales_release_active set contains all active sales releases.  
From this set we can determine the total quantity due and shipped for each part.
Validation: This set can be verified from the Plex PRP screen.
*/

select ra.pcn,ra.part_key,sum(ra.quantity) qty_due, sum(ra.quantity_shipped) qty_shipped
into #sales_release_active_due
from #sales_release_active ra 
group by ra.pcn,ra.part_key

select count(*) cnt_active from #sales_release_active_due  -- 36
-- select * from #sales_release_due
/*
Volume shipped:
The sales_release_due set contains the volume shipped for the active sales releases.
So we only need to determine the volume shipped for the inactive sales releases.
Validation: Shipper history report.
*/

create table #sales_release_inactive
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
  quantity_shipped int  
)
insert into #sales_release_inactive (pcn,release_key,po_line_key,release_status_key,release_type_key,po_status_key,part_key,release_no,ship_to,ship_date, due_date,quantity,quantity_shipped)
select 
--top 10
sr.pcn,
sr.release_key,
pl.po_line_key,
sr.release_status_key,
release_type_key,
po.po_status_key,
pl.part_key,
release_no,
ship_to,
ship_date, 
due_date,
quantity,  -- This is the quantity the customer wants.
quantity_shipped
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
and rs.active != 1 -- Canceled, Hold,Closed  
and due_date > CONVERT(datetime, @From_Shipped_Date) 
and sr.pcn = @PCN
and sr.quantity_shipped != 0

/*
The inactive release status for all 13 PCN are the same: Canceled,Closed,Hold

select pcn,release_status,active from sales_v_release_status_e rs where rs.active = 0 order by release_status,pcn
*/

select ri.pcn,ri.part_key, sum(ri.quantity_shipped) qty_shipped
into #sales_release_inactive_shipped
from #sales_release_inactive ri 
group by ri.pcn,ri.part_key

select count(*) cnt_inactive_shipped from #sales_release_inactive_shipped sh -- 52


/*
combine #sales_release_active_due and #sales_release_inactive_shipped to get the total quantity shipped.
The parts in #sales_release_inactive_shipped set should be a superset of #sales_release_active
But #part_building should be a superset of #sales_release_inactive_shipped
But there are over twice as many parts assigned to a building than there are parts that have been shipped
Because we did not filter by part type as discussed earlier
*/

-- sum(ra.quantity) qty_due, sum(ra.quantity_shipped) qty_shipped
select 
pb.pcn,
pb.part_key,
p.name,
p.part_no,
case
when ad.qty_due is null then 0
else ad.qty_due
end qty_due_active_sales_release,
case 
when ad.qty_shipped is null then 0
else ad.qty_shipped
end qty_shipped_active_sales_release,
case
when sh.qty_shipped is null then 0
else sh.qty_shipped
end qty_shipped_inactive_sales_release,
case
when ad.qty_shipped is null and sh.qty_shipped is null then 0
when ad.qty_shipped is null and sh.qty_shipped is not null then sh.qty_shipped
when ad.qty_shipped is not null and sh.qty_shipped is null then ad.qty_shipped
when ad.qty_shipped is not null and sh.qty_shipped is not null then ad.qty_shipped + sh.qty_shipped
end qty_shipped
into #result
from #part_building pb
inner join part_v_part_e p
on pb.pcn=p.plexus_customer_no
and pb.part_key=p.part_key
left outer join #sales_release_active_due ad 
on pb.pcn = ad.pcn
and pb.part_key = ad.part_key
left outer join #sales_release_inactive_shipped sh 
on pb.pcn = sh.pcn
and pb.part_key = sh.part_key

select count(*) cnt_result from #result r
where r.qty_due_active_sales_release != 0 or r.qty_shipped != 0

select r.pcn,r.part_key,r.name,r.part_no,r.qty_due_active_sales_release,r.qty_shipped_active_sales_release,
r.qty_shipped_inactive_sales_release,
r.qty_shipped from #result r
where r.qty_due_active_sales_release != 0 or r.qty_shipped != 0
order by name


/*
Debugging line
select p.part_no,p.name,ps.po_status,po.Expiration_Date,rs.release_status,rt.release_type,rt.allow_ship,r.* 
from #sales_release_part r -- 34
inner join sales_v_po_line_e pl --1 to 1
on r.pcn = pl.pcn
and r.po_line_key=pl.po_line_key 
inner join sales_v_po_e po  -- 1 to 1
on pl.pcn = po.pcn
and pl.po_key=po.po_key  
inner join sales_v_po_status_e ps  -- 1 to 1
on po.pcn = ps.pcn
and po.po_status_key=ps.po_status_key  
inner join sales_v_release_status_e rs  -- 1 to 1
on r.pcn = rs.pcn
and r.release_status_key=rs.release_status_key  
inner join sales_v_release_type_e rt  -- 1 to 1
on r.pcn = rt.pcn
and r.release_type_key=rt.release_type_key  
inner join part_v_part_e p 
on r.pcn=p.plexus_customer_no
and r.part_key=p.part_key
where p.part_no like '2015898' order by part_no, due_date asc
*/