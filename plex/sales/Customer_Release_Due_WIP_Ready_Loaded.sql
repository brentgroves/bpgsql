/*
All parts for a building with status of production
Whevever you want to use @Due_Date you must convert it to datetime.
-- CONVERT(datetime, @Due_Date)  less_than_due_date
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

-- select * from #part_building  -- 31
-- select count(*) #part_building from #part_building  --31


--//////////////////////////////////////////////////////////////////////
-- Potential Problems:
-- 1. To determine if a container quantity is WIP or Ready we now look at the
-- look at the next part operation instead of the next job operation.
-- This is to be consistent with the Plex inventory screen.  For completion, both 
-- the part and job operations are reported in this query.
-- The hard part is figuring out the filter for the WIP quantity
-- the filter for each plex screen is different.  I believe we have 
-- found the correct filter for the PRP screen which is the one
-- we are trying to duplicate

-- Notes:
-- 1. There are two ways to retrieve the quantity Loaded. We are summing
-- the part_container quantities with container_status = 'Loaded'.  
-- The other way is to sum the shipper
-- containers. From testing it seems 
-- the container serial number is the same in both tables and the sum
-- is the same also.  
-- The advantage of using the shipper_container is because the 
-- shipper_container has a sales_v_release.release_key.  
--  i.e. shipping has loaded the finished goods container to a shipper.
-- Since we know
-- what release_key the container is for there is no guessing as to 
-- which release_key the quantity loaded should be associated with.
-- * Actually there are three methods of calculating quantity_loaded.
-- The other method is to sum shipper_line quantities.
-- I believe we are using the part_container to determine these
-- quantities is because we got this logic from a plex web service.
-- 
--/////////////////////////////////////////////////////////////////////
-- Not all of these columns are necessary for the result set and 
-- could be reduced to speed up the query.
create table #part_container
(
  pcn int,
  part_key int,
  part_no varchar(100),
  operation_code varchar(30),
  serial_no varchar(25),
  quantity int,
  jo_add_to_qty_wip int,
  po_add_to_qty_wip int,
  jo_add_to_qty_ready int,
  po_add_to_qty_ready int,
  add_to_qty_loaded int,
  status varchar(10),
  container_status varchar(50),
  shippable int,
  note varchar(500),
  defect_type varchar (50),
  defect_detail_key int,
  job_op_no int,
  next_job_op_no int,
  part_op_no int,
  next_part_op_no int,
  next_job_op int,
  next_operation int,
  defective smallint,
  prime_status bit,
  consignment_status bit,
  container_type varchar(50),
  location varchar(50), 
  tracking_no varchar(50),
  test_material int,
  allow_production smallint,
  ok_status smallint,
  status_color varchar(50),
  add_date datetime
);

insert into #part_container (
  pcn,
  part_key,
  part_no,
  operation_code,
  serial_no,
  quantity,
  jo_add_to_qty_wip,
  po_add_to_qty_wip,
  jo_add_to_qty_ready,
  po_add_to_qty_ready,
  add_to_qty_loaded,
  status,
  container_status,
  shippable,
  note,
  defect_type,
  defect_detail_key,
  job_op_no,
  next_job_op_no,
  part_op_no,
  next_part_op_no,
  next_job_op,
  next_operation,
  defective,
  prime_status,
  consignment_status,
  container_type,
  location, 
  tracking_no,
  test_material,
  allow_production,
  ok_status,
  status_color,
  add_date
)

    select 
    s1.pcn,
    s1.part_key,
    s1.part_no,
    s1.operation_code,
    s1.serial_no,
    --status,
    cast(s1.quantity as int) quantity,
    case
    --when o.inventory_type = 'WIP' then pc.quantity
    --when c.container_status != 'Loaded' and l.shippable = 0 then c.quantity
    --when c.container_status != 'Loaded' and l.shippable = 0 and c.note not like '%750001%' then c.quantity
    when s1.container_status != 'Loaded' and s1.next_job_op is not null then cast(s1.quantity as int)
    else 0
    end jo_add_to_qty_wip,
    case
    --when o.inventory_type = 'WIP' then pc.quantity
    --when c.container_status != 'Loaded' and l.shippable = 0 then c.quantity
    --when c.container_status != 'Loaded' and l.shippable = 0 and c.note not like '%750001%' then c.quantity
    when s1.container_status != 'Loaded' and s1.next_operation is not null then cast(s1.quantity as int)
    else 0
    end po_add_to_qty_wip,
    case
    --when o.inventory_type = 'Finished Goods' then pc.quantity
    --when c.container_status != 'Loaded' and l.shippable = 1 then c.quantity
    --when c.container_status != 'Loaded' and (l.shippable = 1 or c.note like '%750001%') then c.quantity
      when s1.container_status != 'Loaded' and s1.next_job_op is null then cast(s1.quantity as int)
    else 0
    end jo_add_to_qty_ready,
    case
    --when o.inventory_type = 'Finished Goods' then pc.quantity
    --when c.container_status != 'Loaded' and l.shippable = 1 then c.quantity
    --when c.container_status != 'Loaded' and (l.shippable = 1 or c.note like '%750001%') then c.quantity
      when s1.container_status != 'Loaded' and s1.next_operation is null then cast(s1.quantity as int)
    else 0
    end po_add_to_qty_ready,
    case
    when s1.container_status = 'Loaded' then cast(s1.quantity as int)
    else 0
    end add_to_qty_loaded,

-- select distinct container_status from part_v_container   
--  ( Consignment Accepted,Hold,Impreg,Loaded,OK,Receiving,Rework,Scrap,Setup Part,Shipped,	Supplier Labeled,	Supplier Shipped ) = container_status
    case
    when s1.container_status != 'Loaded' and s1.next_operation is not null  then 'WIP'
    when s1.container_status != 'Loaded' and s1.next_operation is null then 'Ready'
    else 'Loaded'
    end status,
    --add_to_qty_wip,
    --add_to_qty_ready,
    --add_to_qty_loaded,
    s1.container_status,
    s1.shippable,
    s1.note,
    s1.defect_type,
    s1.defect_detail_key,
    s1.job_op_no,
    jo.op_no as next_job_op_no,
    s1.part_op_no,
    po.operation_no next_part_op_no,
    s1.next_job_op,
    s1.next_operation,
    s1.defective,
    s1.prime_status,
    s1.consignment_status,
    s1.container_type,
    s1.location, 
    s1.tracking_no,
    s1.test_material,
      
    s1.allow_production,
    s1.ok_status,
    s1.status_color,
    s1.add_date
    from
    (
    
      select 
      --top 10
      c.plexus_customer_no pcn,
      c.part_key,
      p.part_no,
      o.operation_code,
      c.serial_no,
    
      o.inventory_type,
    --when o.inventory_type = 'WIP' then pc.quantity
    --when pc.container_status != 'Loaded' and l.shippable = 0 and pc.note not like '%750001%' then pc.quantity
      c.container_status,
      l.shippable,
      cs.allow_ship,
      c.active,
      cs.allow_production,
      cs.ok_status,
      cs.color AS status_color,
      c.defect_type,
      c.defect_detail_key,
      jo.Op_No job_op_no,
      po.operation_no part_op_no,
      (  -- examine job operations
        select top(1)  --Nex job operation for job
          jo2.job_op_key 
        from part_v_job_op_e AS jo2 
        join part_v_part_operation_e AS po1  
          on po1.part_operation_key = jo2.part_operation_key
          and po1.plexus_customer_no=jo2.pcn      
        left outer join part_v_part_op_type_e AS pot 
          on po1.part_op_type_key = pot.part_op_type_key
          and po1.plexus_customer_no=pot.pcn      
        where jo2.job_key=c.job_key  -- many to 1  all job ops for containers job
          and jo2.op_no > jo.op_no  -- INTERESTING --- Only job ops > containers job op
          and ( (cs.test_material = 1 and ISNULL(pot.test,0) = 1)  --(test_material && !test) 
                or (cs.test_material = 0 and ISNULL(pot.standard,1) = 1)) --Not test_material && standard operation type
          and jo2.pcn = @PCN      
        order by
          jo2.op_no
      ) next_job_op,
      (  --examine all part operations
        select top(1)
          po.part_operation_key
        from part_v_part_operation_e as po
        join part_v_part_op_type_e as pot --1 to 1
          on po.part_op_type_key=pot.part_op_type_key
          and po.plexus_customer_no=pot.pcn      
        where po.part_key = c.part_key
          and po.operation_no > 
            (  -- find the part operation number for the container
              select
                po2.operation_no 
              from part_v_part_operation_e as po2
              where po2.part_key = c.part_key 
                and po2.part_operation_key = c.part_operation_key 
                and po2.active = 1  -- there can be only active part_operation_key record for a part operation number
                and po2.plexus_customer_no = @PCN
            )
          and po.active = 1  -- I don't think this is necessary?
          and (pot.[Standard] = 1 OR pot.test = 1)  -- What is the brackets for?  Could we have put this in the inner select abov
          and po.suboperation = 0
          and po.plexus_customer_no = @PCN          
        order by
          po.operation_no asc 
      ) as next_operation,
      cs.defective,
      cs.prime_status,
      cs.consignment_status,
      
      c.container_type,
      c.location, 
      c.tracking_no,
      cs.test_material,
      case
        when c.part_key = 0 and c.quantity = 1 and m.linear_weight > 0 then round(c.net_weight/m.linear_weight,2)
        else c.quantity
      end as quantity, 
      case
        when exists(select * from part_v_container_change2 as cc2 where cc2.serial_no = c.serial_no) then 'Yes'
        else 'no'
      end as new_change_records_exist,
      case
        when exists(select * from part_v_container_change AS cc where cc.serial_no = c.serial_no) then 'Yes'
        else 'No'
      end as old_change_records_exist,
      c.note,
      c.add_date
--      jo.
      from part_v_container_e AS c
      left outer join part_v_container_status_e AS cs -- 1 to 1
      on c.container_status = cs.container_status
      and c.plexus_customer_no=cs.plexus_customer_no
      left outer join part_v_job_op_e jo  -- 1 to 1
      on c.job_op_key= jo.job_op_key
      and c.plexus_customer_no=jo.pcn      
      left outer join part_v_part_operation_e po
      on c.part_key = po.part_key 
      and c.part_operation_key = po.part_operation_key       
      and c.plexus_customer_no=po.plexus_customer_no      
      left outer join part_v_operation_e o
      on po.operation_key=o.operation_key
      and po.plexus_customer_no=o.plexus_customer_no      
      left outer join part_v_part_e p
      on c.part_key=p.part_key
      and c.plexus_customer_no=p.plexus_customer_no      
      left outer join common_v_location_e l
      on c.location=l.location
      and c.plexus_customer_no=l.plexus_customer_no   
      left outer join common_v_location_group_e lg 
      on l.location_group_key=lg.location_group_key
      and l.plexus_customer_no=lg.pcn
      left outer join material_v_material_e as m  
      ON c.material_key=m.material_key 
      and c.plexus_customer_no=m.plexus_customer_no      
    
      where c.part_key in  -- Limit to sales_release being filled by workcenters in a specific building.
      (
        select part_key from #part_building  --parts being filled by workcenters in specific building.
      )
      and c.plexus_customer_no = @PCN
  --c.part_key = 	2684943
      and c.active = 1
      and (((cs.allow_ship = 1) and (l.location not like '%Hold%'))  
          or ((cs.allow_ship = 0) and (c.container_status ='Rework')))  -- this is the only filter that I found that gives the same results as the prp screen
--      and ((cs.allow_ship = 1) and (l.shippable = 1))  -- does not pass like prp
--      and ((cs.allow_ship = 1) and (lg.location_group <> 'Holding Area'))  -- does not pass
--      and cs.defective <> 1  -- does not pass like prp
--      and cs.container_status not in ('Scrap') -- does not pass like prp
--      and ((cs.allow_ship = 1) or ((cs.allow_ship = 0) and (c.Container_Status='Hold'))) -- does not pass like prp
    --  and (c.container_type <> 'Red Tote' and l.shippable = 1) -- does not pass like prp
    --  and not ((c.container_type = 'Red Tote') and (cs.container_status = 'OK')) -- not used by PRP
      -- and c.container_type <> 'Red Tote' -- not used by PRP
      -- and lg.location_group <> 'Holding Area'  -- not used by prp
      -- and l.shippable = 1  -- not used by prp
      and c.quantity > 0
    )s1
    left outer join part_v_job_op_e AS jo
    on s1.next_job_op = jo.job_op_key
    and s1.pcn=jo.pcn      
    
    left outer join part_v_part_operation_e AS po
    on s1.next_operation = po.part_operation_key
    and s1.pcn=po.plexus_customer_no      

-- Is this data identical to that found in the Plex PRP? Yes
-- select * from #part_container c where c.serial_no in ('AB856699') 
/*
select c.active,cs.allow_ship,c.container_status,c.* 
from part_v_container c 
left outer join part_v_container_status_e AS cs -- 1 to 1
on c.container_status = cs.container_status
and c.plexus_customer_no=cs.plexus_customer_no
where c.serial_no in ('AB856699') 
*/
/*
This is the set of containers that we assume that we can ship and has the same values as
the PRP screen; although the PRP screen does not distinguish between ready and loaded containers.
*/

create table #part_wip_ready_loaded
(
pcn int,
part_key int,
qty_wip decimal (19,5),
wip_containers varchar(max),  -- DEBUG ONLY
qty_ready decimal (19,5),
ready_containers varchar(max),
qty_loaded decimal (19,5),
loaded_containers varchar(max)
);

insert into #part_wip_ready_loaded (pcn,part_key,qty_wip,wip_containers,qty_ready,ready_containers,qty_loaded,loaded_containers)
(

  select
  pcn,
  part_key,
  sum(po_add_to_qty_wip) qty_wip,
  (
    SELECT SUBSTRING
    (
      (
        SELECT cast(', ' + pcx.serial_no + ',Tot:'  + cast(pcx.quantity as varchar(10)) as varchar(max)) 
        FROM #part_container pcx
        WHERE pcx.part_key = pc.part_key
        and pcx.container_status != 'Loaded'
        and pcx.next_operation is not null
        order by pcx.serial_no desc
        FOR XML PATH('')
      ), 
      3, 
      200000
    )    
  ) as wip_containers,
  sum(po_add_to_qty_ready) qty_ready,
  (
    SELECT SUBSTRING
    (
      (
        SELECT cast(', ' + pcx.serial_no + ',Tot:'  + cast(pcx.quantity as varchar(10)) as varchar(max))
--        SELECT ', ' + pcx.serial_no + ',Tot:'  + cast(pcx.quantity as varchar(10)) + ',job_op:'  + cast(pcx.job_op_no as varchar(10)) + ',next_job_op:'  + cast(pcx.next_job_op_no as varchar(10)) 
        FROM #part_container pcx
        WHERE pcx.part_key = pc.part_key
        and pcx.container_status != 'Loaded'
        and pcx.next_operation is null
        order by pcx.serial_no desc
        FOR XML PATH('')
      ), 
      3, 
      200000
    )    
  ) as ready_containers,
  --       when s1.container_status != 'Loaded' and s1.next_job_op is null then cast(s1.quantity as int)
  sum(add_to_qty_loaded) qty_loaded,
  (
    SELECT SUBSTRING
    (
      (
        SELECT cast(', ' + pcx.serial_no + ',Tot:'  + cast(pcx.quantity as varchar(10)) as varchar(max)) 
        FROM #part_container pcx
        WHERE pcx.part_key = pc.part_key
        and pcx.container_status = 'Loaded'
        order by pcx.serial_no desc
        FOR XML PATH('')
      ), 
      3, 
      200000
    )    
  ) as loaded_containers

  from #part_container pc
  group by pc.pcn,pc.part_key 
)

-- select r.part_key,qty_wip,qty_ready,qty_loaded from #part_wip_ready_loaded r 

/*
Debugging query
 select part_no,r.part_key,qty_wip,qty_ready,qty_loaded from #part_wip_ready_loaded r 
 left outer join part_v_part p
 on r.part_key=p.part_key
 order by p.part_no

*/

/*
	PCN
	310507/Avilla
	300758/Albion
	295933/Franklin
	300757/Alabama
	306766/Edon
	312055/ BPG WorkHolding
	295932 Fruit Port
	*/
	

/*
--///////////////////////////////////////////////////////////////////////////
-- All active sales releases for the building before the due date parameter. 
does some mobex part keys map to multiple customer_part_keys?
Even if they do the purpose of this SPROC is determine tooling totals 
which are based on tool lists that are based on Mobex part numbers
so do not group releases by customer part key.
-- Trying to duplicate the PRP screen in this SPROC as far as Inv WIP and Inv FG go
-- For customer release we are showing sales release marked as active
and rs.active = 1  --Open,Staged,Scheduled,Open - Scheduled
-- does not include Canceled, Hold,Closed
The PRP screen has a Scheduled column which brings up a job screen
I don't know if I should add scheduled jobs which have no active sales releases
in this SPROC?  Currently I am not including scheduled job quanties but only
active sales release due quantities.
--//////////////////////////////////////////////////////////////////////////
*/
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
and rs.active = 1  --Open,Staged,Scheduled,Open - Scheduled
-- does not include Canceled, Hold,Closed
and due_date < CONVERT(datetime, @By_Due_Date) --193
and sr.pcn = @PCN

-- 2994,712,680,1632
-- select count(*) #sales_release_part from #sales_release_part -- 31
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
select rp.pcn,rp.part_key,sum(rp.quantity) qty_due, sum(rp.quantity_shipped) qty_shipped
into #sales_release_due
from #sales_release_part rp -- 34
group by rp.pcn,rp.part_key
--//7/11/2021 12:00:00 AM 
--@By_Due_Date varchar(50) = '20210701',
create table #Customer_Release_Due_WIP_Ready_Loaded
(
ID int,
pcn int,
building_key int,
building_code varchar(50),
part_key int,
part_no varchar(100),
name varchar(100),
qty_due int,
qty_shipped int,
qty_wip int,
qty_ready int,
qty_loaded int,
qty_ready_or_loaded int
)

insert into #Customer_Release_Due_WIP_Ready_Loaded (ID,pcn,building_key,building_code,part_key,part_no,name,qty_due,qty_shipped,qty_wip,qty_ready,qty_loaded,qty_ready_or_loaded)
-- select rd.* from #sales_release_due rd
select 
cast(row_number() over(order by wr.pcn,p.part_no) as int) ID,
wr.pcn,
@Building_Key building_key,
b.building_code,
wr.part_key,
p.part_no,
p.name,
isnull(rd.qty_due,0) qty_due,
isnull(rd.qty_shipped,0) qty_shipped,
wr.qty_wip,wr.qty_ready,wr.qty_loaded,wr.qty_ready+wr.qty_loaded qty_ready_or_loaded
from  #part_wip_ready_loaded wr 
left outer join #sales_release_due rd
on wr.pcn=rd.pcn
and wr.part_key=rd.part_key
inner join part_v_part_e p 
on wr.pcn=p.plexus_customer_no
and wr.part_key=p.part_key
inner join common_v_building_e b
on p.plexus_customer_no = b.plexus_customer_no
and p.building_key=b.building_key

-- select * from common_v_building
select * from #Customer_Release_Due_WIP_Ready_Loaded si
order by si.part_no