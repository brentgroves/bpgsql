/*
All parts for a building with status of production
Whevever you want to use @Due_Date you must convert it to datetime.
23	5644	Mobex Global Plant 6
24	5645	Mobex Global Plant 7
25	5641	Mobex Global Plant 8
26	5646	Mobex Global Plant 9
*/
--SELECT CONVERT(datetime, @By_Due_Date)

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
and p.part_key not in (3031667,3031668)
)
-- select part_key from part_v_part where part_no = '10164021A'
-- select * from #part_building  -- 33
-- select count(*) #part_building from #part_building  --33
select 
--ROW_NUMBER() OVER(ORDER BY p.plexus_customer_no,p.part_no,po.operation_no) AS Row#,
p.plexus_customer_no pcn,
p.part_key,p.part_no,p.name,p.part_type,
ps.part_source_key,ps.part_source,
po.part_operation_key,po.operation_no,
o.operation_key,o.operation_code,po.description po_description,
ot.part_op_type_key,ot.description ot_description,
(
  select substring(
  (
    select ',' + c.customer_code + ' ' + cp.customer_part_no + ' ' + cp.customer_part_revision
    from part_v_customer_part_e cp 
    inner join common_v_customer_e c 
    on cp.plexus_customer_no=c.plexus_customer_no
    and cp.customer_no = c.customer_no
    where 
    cp.plexus_customer_no=p.plexus_customer_no
    and cp.part_key = p.part_key for XML PATH('')), 2, 200000) 
) customer_part_list
into #tool_list
-- select count(*)
from part_v_part_e p
inner join part_v_part_operation_e po
on p.plexus_customer_no = po.plexus_customer_no
and p.part_key = po.part_key
inner join part_v_operation_e o
on po.plexus_customer_no=o.plexus_customer_no
and po.operation_key=o.operation_key
inner join part_v_part_op_type_e ot 
on po.plexus_customer_no = ot.pcn
and po.part_op_type_key = ot.part_op_type_key
inner join part_v_part_source_e ps 
on p.plexus_customer_no = ps.pcn
and p.part_source_key=ps.part_source_key
where p.plexus_customer_no = @PCN
-- and p.part_key = 2794706
and ot.description='Production'  -- rework,cell,etc.  -- 718
and p.part_status = 'Production'  -- 308
and ps.part_source = 'Manufactured'  -- 300
and p.part_key in 
(
 select part_key from #part_building
)
--insert into #tool_list(pcn,part_key,part_no)
--values(@PCN,)
--select * from #tool_list
-- ADDED A FEW PARTS THAT HAVE MULTIPLE MACHINES BUT ONLY 1 TOOL LIST.
insert into #tool_list(pcn,part_key,part_no,name,part_type,part_source_key,
part_source,part_operation_key,operation_no,operation_key,operation_code,
po_description,part_op_type_key,ot_description,customer_part_list
)

select 
p.plexus_customer_no pcn,
p.part_key,p.part_no,p.name,p.part_type,
ps.part_source_key,ps.part_source,
po.part_operation_key,po.operation_no,
o.operation_key,o.operation_code,po.description po_description,
ot.part_op_type_key,ot.description ot_description,
(
  select substring(
  (
    select ',' + c.customer_code + ' ' + cp.customer_part_no + ' ' + cp.customer_part_revision
    from part_v_customer_part_e cp 
    inner join common_v_customer_e c 
    on cp.plexus_customer_no=c.plexus_customer_no
    and cp.customer_no = c.customer_no
    where 
    cp.plexus_customer_no=p.plexus_customer_no
    and cp.part_key = p.part_key for XML PATH('')), 2, 200000) 
) customer_part_list
-- select count(*)
from part_v_part_e p
inner join part_v_part_operation_e po
on p.plexus_customer_no = po.plexus_customer_no
and p.part_key = po.part_key
inner join part_v_operation_e o
on po.plexus_customer_no=o.plexus_customer_no
and po.operation_key=o.operation_key
inner join part_v_part_op_type_e ot 
on po.plexus_customer_no = ot.pcn
and po.part_op_type_key = ot.part_op_type_key
inner join part_v_part_source_e ps 
on p.plexus_customer_no = ps.pcn
and p.part_source_key=ps.part_source_key
where p.plexus_customer_no = @PCN
-- and p.part_key = 2794706
--and ot.description='Production'  -- rework,cell,etc.  -- 718
--and p.part_status = 'Production'  -- 308
--and ps.part_source = 'Manufactured'  -- 300
and po.operation_no = 100
and p.part_key in 
(
 	2955210, -- 2006676
 	2955205, -- 2009488
 	2955198 -- 53379
)
-- select * from #tool_list
-- select part_key from part_v_part where part_no = '53379'

select
--t.part_no jobnumber,
case
when operation_no = 100 and t.part_no in ('2006676','2009488','53379') then '"' + t.part_no + ' Horz' + '"'
when operation_no != 100 and t.part_no in ('2006676','2009488','53379') then '"' + t.part_no + ' Vert' + '"'
when t.part_no in ('2001268','2001269','2001270','2001271','2006676','2009488','48439','48439','48439','48439','48440','53379') then '"' + t.part_no + '"'
when operation_no = 100 then '"' + t.part_no + ' Horz' + '"'
else '"' + t.part_no + ' Vert' + '"'
end descr,

t.name
--p.part_type,
--ps.part_source_key,ps.part_source,
--po.part_operation_key,
--t.operation_no,
--o.operation_key,
--t.operation_code,t.po_description
--ot.part_op_type_key,ot.description ot_description,
from #tool_list t
order by part_no
