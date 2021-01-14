--//////////////////////////////////////////////////////////////////////
-- Potential Problems:
-- 1. To determine if a container quantity is WIP or Ready we look at the
-- Next part operation instead of the Next job operation.  This
-- method will probably fail when a part container is being reworked.
-- No testing has been performed.

-- Notes:
-- 1. There are two ways to retrieve the quantity Loaded. We are summing
-- the part_container quantities.  The other way is to sum the part
-- containers with container_status = 'Loaded'. From testing it seems 
-- the container serial number is the same in both tables and the sum
-- is the same also.  
-- The advantage of using the shipper_container is because the 
-- shipper_container has a sales_v_release.release_key.  Since we know
-- what release_key the container is for there is no guessing as to 
-- which release_key the quantity loaded should be associated with.
-- * Actually there are three methods of calculating quantity_loaded.
-- The other method is to sum shipper_line quantities.
-- I believe we are using the part_container to determine these
-- quantities is because we got this logic from a plex web service.
-- 
--/////////////////////////////////////////////////////////////////////

create table #part_container
(
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
    when s1.container_status != 'Loaded' and s1.next_job_op is not null  then 'WIP'
    when s1.container_status != 'Loaded' and s1.next_job_op is null then 'Ready'
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
        from part_v_job_op AS jo2 
        join part_v_part_operation AS po1  
          on po1.part_operation_key = jo2.part_operation_key
        left outer join part_v_part_op_type AS pot 
          on po1.part_op_type_key = pot.part_op_type_key
        where jo2.job_key=c.job_key  -- many to 1  all job ops for containers job
          and jo2.op_no > jo.op_no  -- INTERESTING --- Only job ops > containers job op
          and ( (cs.test_material = 1 and ISNULL(pot.test,0) = 1)  --(test_material && !test) 
                or (cs.test_material = 0 and ISNULL(pot.standard,1) = 1)) --Not test_material && standard operation type
        order by
          jo2.op_no
      ) next_job_op,
      (  --examine all part operations
        select top(1)
          po.part_operation_key
        from part_v_part_operation as po
        join part_v_part_op_type as pot --1 to 1
          on po.part_op_type_key=po.part_op_type_key
        where po.part_key = c.part_key
          and po.operation_no > 
            (  -- find the part operation number for the container
              select
                po2.operation_no 
              from part_v_part_operation as po2
              where c.part_key = po2.part_key 
                and c.part_operation_key = po2.part_operation_key 
                and po2.active = 1  -- there can be only active part_operation_key record for a part operation number
            )
          and po.active = 1  -- I don't think this is necessary?
          and (pot.[Standard] = 1 OR pot.test = 1)  -- What is the brackets for?  Could we have put this in the inner select abov
          and po.suboperation = 0
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
      from part_v_container AS c
      left outer join part_v_container_status AS cs -- 1 to 1
      on c.container_status = cs.container_status
      left outer join part_v_job_op jo  -- 1 to 1
      on c.job_op_key= jo.job_op_key
      left outer join part_v_operation o
      on jo.operation_key=o.operation_key
      left outer join part_v_part_operation po
      on c.part_key = po.part_key 
      and c.part_operation_key = po.part_operation_key       
      left outer join part_v_part p
      on c.part_key=p.part_key
      left outer join common_v_location l
      on c.location=l.location
      left outer join material_v_material as m  
      ON c.material_key=m.material_key 
    
      where 
      --c.part_key = 	2684943
      c.active = 1
      and cs.allow_ship = 1 
      and c.quantity > 0
      --and l.shippable = 1
    )s1
    left outer join part_v_job_op AS jo
    on s1.next_job_op = jo.job_op_key
    left outer join part_v_part_operation AS po
    on s1.next_operation = po.part_operation_key

/*
This is the set of containers that we can ship.
We can tell if they are loaded the only question
is to find out if they are WIP or ready.
Sometimes there is a next part op but not a next job op.
*/
-- select * from part_v_container_status Allow_Ship=OK,Loaded,Staged,Impreg. 
-- select container_status,next_job_op,jo_add_to_qty_ready,* from #part_container
-- where jo_add_to_qty_ready > 0
-- where jo_add_to_qty_wip <> po_add_to_qty_wip

create table #part_wip_ready_loaded
(
part_key int,
qty_wip decimal (19,5),
wip_containers varchar(max),  -- DEBUG ONLY
qty_ready decimal (19,5),
ready_containers varchar(max),
qty_loaded decimal (19,5),
loaded_containers varchar(max)
);

insert into #part_wip_ready_loaded (part_key,qty_wip,wip_containers,qty_ready,ready_containers,qty_loaded,loaded_containers)
(

  select
  part_key,
  sum(jo_add_to_qty_wip) qty_wip,
  (
    SELECT SUBSTRING
    (
      (
        SELECT cast(', ' + pcx.serial_no + ',Tot:'  + cast(pcx.quantity as varchar(10)) as varchar(max)) 
        FROM #part_container pcx
        WHERE pcx.part_key = pc.part_key
        and pcx.container_status != 'Loaded'
        and pcx.next_job_op is not null
        order by pcx.serial_no desc
        FOR XML PATH('')
      ), 
      3, 
      200000
    )    
  ) as wip_containers,
  sum(jo_add_to_qty_ready) qty_ready,
  (
    SELECT SUBSTRING
    (
      (
        SELECT cast(', ' + pcx.serial_no + ',Tot:'  + cast(pcx.quantity as varchar(10)) as varchar(max))
--        SELECT ', ' + pcx.serial_no + ',Tot:'  + cast(pcx.quantity as varchar(10)) + ',job_op:'  + cast(pcx.job_op_no as varchar(10)) + ',next_job_op:'  + cast(pcx.next_job_op_no as varchar(10)) 
        FROM #part_container pcx
        WHERE pcx.part_key = pc.part_key
        and pcx.container_status != 'Loaded'
        and pcx.next_job_op is null
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
  group by pc.part_key 
)
select part_key,qty_wip,qty_ready,qty_loaded from #part_wip_ready_loaded where qty_ready > 0
-- select part_key,qty_wip,wip_containers,qty_ready,ready_containers,qty_loaded,loaded_containers from #part_wip_ready_loaded where qty_ready > 0
--select count(*) #part_container_wip_ready_loaded from #part_container_wip_ready_loaded  --415
-- select job_key,job_op_key,* from part_v_container where serial_no = 'AB757307'
/*
The release item will be for HXE66422
but the painting is for HXE66422R
containers for HXE66422 will be at the final operation so will show as Ready but they still need to be painted 
How do we know when we have made enough?
*/
-- select * from #part_wip_ready_loaded 

