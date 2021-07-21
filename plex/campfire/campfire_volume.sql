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
DECLARE @Due_Date varchar(50);
-- SET @Due_Date = @By_Due_Date
SET @Due_Date = '20210701'
-- SELECT CONVERT(datetime, @Due_Date)
-- select @Due_Date;
*/
--SELECT CONVERT(datetime, @By_Due_Date)

/*
SET @By_Due_Date = '2019-08-16 09:37:00'
SELECT CONVERT(datetime, @By_Due_Date)
select @varchar_date;
select top 10 * from part_v_part
declare @Due_Date date
select CAST(''' + @By_Due_Date + ''' AS datetime)
-- SELECT convert(datetime, '20210704', 112);
-- set @Due_Date = convert(datetime, @By_Due_Date, 112);
select convert(datetime, @By_Due_Date, 112);

*/
create table #part_building
(
part_key int not null
)
insert into #part_building (part_key)
(

select p.part_key
--,b.building_code 
-- into #parts_assigned_plt6
from part_v_part_e p
inner join common_v_building_e b
on p.plexus_customer_no = b.plexus_customer_no
and p.building_key=b.building_key
where p.building_key = @Building_Key
and p.part_status='Production'
and p.part_type <> 'Raw Material'
and p.plexus_customer_no = @PCN
)

create table #sales_release_part
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
insert into #sales_release_part (pcn,release_key,po_line_key,release_status_key,release_type_key,po_status_key,part_key,release_no,ship_to,ship_date, due_date,quantity,quantity_shipped)
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
quantity,
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
  select part_key from #part_building  --parts being filled by workcenters in specific building.
)
--and rs.active = 1  --Open,Staged,Scheduled,Open - Scheduled
and rs.active != 1
-- does not include Canceled, Hold,Closed
and ship_date > '6/21/2021'
-- and due_date < CONVERT(datetime, @By_Due_Date) --193
and sr.pcn = @PCN
and quantity_shipped > 0

-- 2994,712,680,1632
select count(*) #sales_release_part from #sales_release_part -- 31
select top 100 * from #sales_release_part
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
