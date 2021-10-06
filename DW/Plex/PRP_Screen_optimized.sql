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
32	5609	Mobex Global Edon	
33	5668	Edon Plant 2	Edon Plant 2
*/
/*
	PCN
	310507/Avilla
	300758/Albion
	295933/Franklin
	300757/Alabama
	306766/Edon
	312055/ BPG WorkHolding
2	295932 Fruit Port
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

-- reduce part set
create table #part
(
pcn int not null,
part_key int not null,
building_key int not null,
building_code varchar(50) not null
)
insert into #part (pcn,part_key,building_key,building_code)
(

select 
p.plexus_customer_no pcn,
p.part_key,
p.building_key,
b.building_code 
from part_v_part_e p
inner join common_v_building_e b
on p.plexus_customer_no = b.plexus_customer_no
and p.building_key=b.building_key
where 
p.part_status='Production'
and p.part_type <> 'Raw Material'
and p.plexus_customer_no = @PCN
and p.building_key <> 5642  -- plant 3 albion
)



-- select * from #part  -- 114
/*
Reduce huge set of containers
*/
-- reduce container set
create table #containers
(
pcn int not null,
part_key int not null,
building_key int not null,
building_code varchar(50) not null
)
      select c.plexus_customer_no pcn,
      c.container_key,
      c.part_key
      into #container
      --select count(*)
      from part_v_container_e AS c  -- 6,766,306
  --    where c.active = 1 
  --    and c.part_key = 0 -- 0
  --    and c.part_key is null -- 0
--      where c.plexus_customer_no = @PCN -- 924,683
      inner join #part ps 
      on c.plexus_customer_no = ps.pcn
      and c.part_key=ps.part_key 
      left outer join common_v_location_e l  -- 1 to 1
      on c.location=l.location
      and c.plexus_customer_no=l.plexus_customer_no   
      left outer join part_v_container_status_e AS cs -- 1 to 1
      on c.container_status = cs.container_status
      and c.plexus_customer_no=cs.plexus_customer_no
      -- container filter
      where c.active = 1
      and (((cs.allow_ship = 1) and (l.location not like '%Hold%'))  
          or ((cs.allow_ship = 0) and (c.container_status ='Rework')))  -- this is the only filter that I found that gives the same results as the prp screen
      and c.quantity > 0   -- 	14,494 Without being joined to #part, 1141 with being joined to #part, 1.6 secs for 1 PCN
      

/*
reduce huge sales release set
*/
select 
sr.pcn,
sr.release_key
--select count(*)  -- 270
into #release  -- sales release subset
from sales_v_release_e sr -- 1,175,205
-- This has the part key. If there is no po_line we don't know what part the sales release is for.
inner join sales_v_po_line_e pl --1 to 1
on sr.pcn = pl.pcn
and sr.po_line_key=pl.po_line_key 
inner join sales_v_release_status_e rs  -- 1 to 1
on sr.pcn = rs.pcn
and sr.release_status_key=rs.release_status_key  
inner join #part sp
on pl.pcn = sp.pcn
and pl.part_key=sp.part_key

where rs.active = 1  --Open,Staged,Scheduled,Open - Scheduled
-- does not include Canceled, Hold,Closed
and due_date < CONVERT(datetime, @By_Due_Date) --193
and sr.pcn = @PCN

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
  serial_no varchar(25),
  quantity int,
  jo_add_to_qty_wip int,
  po_add_to_qty_wip int,
  jo_add_to_qty_ready int,
  po_add_to_qty_ready int,
  add_to_qty_loaded int,
  container_status varchar(50),
  next_operation int
);

insert into #part_container (
  pcn,
  part_key,
  serial_no,
  quantity,
  jo_add_to_qty_wip,
  po_add_to_qty_wip,
  jo_add_to_qty_ready,
  po_add_to_qty_ready,
  add_to_qty_loaded,
  container_status,
  next_operation
)

    select 
    s1.pcn,
    s1.part_key,
    s1.serial_no,
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
    s1.container_status,
    s1.next_operation
    from
    (
    
      select 
      c.plexus_customer_no pcn,
      c.part_key,
      c.serial_no,
      c.container_status,
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
      case
        when c.part_key = 0 and c.quantity = 1 and m.linear_weight > 0 then round(c.net_weight/m.linear_weight,2)
        else c.quantity
      end as quantity 
      from #container sc -- reduced container set
      inner join part_v_container_e AS c
      on sc.pcn=c.plexus_customer_no
      and sc.container_key=c.container_key
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
      left outer join material_v_material_e as m  
      ON c.material_key=m.material_key 
      and c.plexus_customer_no=m.plexus_customer_no      
    )s1
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

--select r.pcn,r.part_key,qty_wip,qty_ready,qty_loaded from #part_wip_ready_loaded r 

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
  part_key int,
  quantity decimal, 
  quantity_shipped int,
  past_due int
)


insert into #sales_release_part (
pcn,
part_key,
quantity,quantity_shipped,past_due)
select 
sr.pcn,
pl.part_key,
quantity,
quantity_shipped,
case 
when getdate() > sr.due_date then sr.quantity - sr.quantity_shipped
else 0
end past_due
from #release r  --  reduced release set
inner join sales_v_release_e sr -- 1,175,205
on r.pcn=sr.pcn
and r.release_key=sr.release_key
inner join sales_v_po_line_e pl --1 to 1
on sr.pcn = pl.pcn
and sr.po_line_key=pl.po_line_key 
inner join sales_v_po_e po  -- 1 to 1
on pl.pcn = po.pcn
and pl.po_key=po.po_key  
inner join sales_v_release_status_e rs  -- 1 to 1
on sr.pcn = rs.pcn
and sr.release_status_key=rs.release_status_key  
inner join #part sp
on pl.pcn = sp.pcn
and pl.part_key=sp.part_key

select rp.pcn,rp.part_key,sum(rp.quantity) qty_rel, sum(rp.quantity_shipped) qty_shipped, sum(rp.quantity - rp.quantity_shipped) qty_due, sum(rp.past_due) past_due
into #sales_release_due
from #sales_release_part rp -- 34
group by rp.pcn,rp.part_key
--//7/11/2021 12:00:00 AM 

create table #Customer_Release_Due_WIP_Ready_Loaded
(
ID int,
pcn int,
building_key int,
building_code varchar(50),
part_key int,
part_no varchar(100),
name varchar(100),
qty_rel int,
qty_shipped int,
qty_due int,
past_due int,
qty_wip int,
qty_ready int,
qty_loaded int,
qty_ready_or_loaded int
)

insert into #Customer_Release_Due_WIP_Ready_Loaded (ID,pcn,building_key,building_code,part_key,part_no,name,qty_rel,qty_shipped,qty_due,past_due,qty_wip,qty_ready,qty_loaded,qty_ready_or_loaded)
-- select rd.* from #sales_release_due rd
select 
cast(row_number() over(order by pb.pcn,b.building_code,rd.qty_due desc) as int) ID,
pb.pcn,
p.building_key,
b.building_code,
pb.part_key,
p.part_no,
p.name,
isnull(rd.qty_rel,0) qty_rel,
isnull(rd.qty_shipped,0) qty_shipped,
isnull(rd.qty_due,0) qty_due,
isnull(rd.past_due,0) past_due,
isnull(wr.qty_wip,0) qty_wip,
isnull(wr.qty_ready,0) qty_ready,
isnull(wr.qty_loaded,0) qty_loaded,
case
when wr.pcn is null then 0
else wr.qty_ready+wr.qty_loaded 
end qty_ready_or_loaded
from #part pb
inner join part_v_part_e p 
on pb.pcn=p.plexus_customer_no
and pb.part_key=p.part_key
inner join common_v_building_e b
on p.plexus_customer_no = b.plexus_customer_no
and p.building_key=b.building_key
left outer join #part_wip_ready_loaded wr
on pb.pcn=wr.pcn
and pb.part_key=wr.part_key
left outer join #sales_release_due rd
on pb.pcn=rd.pcn
and pb.part_key=rd.part_key
where (wr.pcn is not null) or (rd.pcn is not null)
-- select * from common_v_building
select * from #Customer_Release_Due_WIP_Ready_Loaded si
where name not like '%K Body%'
and name not like '%Hone%'

and si.building_key = 5641
--where part_no like  '%10115487%'
order by si.pcn,si.building_code,si.qty_due desc