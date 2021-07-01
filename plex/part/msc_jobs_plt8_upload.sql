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
and p.part_no not in ('10037207','H2GC 5K651 AB','H2GC 5K652 AB','51210T6N A000','51215T6N A000','52210T6N A020','52215T6N A020','H2GZ-5500-A','H2GZ-5500-B','L222884','L222885','R552103','R552111','R558149') -- Navistar Vista Knuckle LH , 1 machine runs left hand and right hand at the same time, so we only need 1 tool list.
)
-- '51210T6N A000','52210T6N A020'
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
and po.operation_no = 100  -- Just pick any operation_no for these parts,
and p.part_no in 
(
 '501-0994-03','501-0994-05','501-0994-05W','501-1234-00','501-1234-01','501-1234-02','501-1234-03','501-1234-04','501-1234-05','501-1234-06','501-1234-08','26088055',
 '51210T6N A000','H2GC 5K651 AB','H2GC 5K652 AB','51210T6N A000','52210T6N A020','H2GZ-5500-A','H2GZ-5500-B','L222884','L222885','R552103','R552111','R558149'
)
-- select * from part_v_part where part_key = 2796140   3091510  -- 501-0994-03
-- select * from #tool_list
-- select part_key from part_v_part where part_no = '10037207'
-- 'L222884','L222885','R552103','R552111','R558149'
select
--t.part_no jobnumber,
--Plant 8 case 
t.part_key jobnumber,
case
when t.part_no in ('001-0408-04D','001-0408-04W','001-0408-05D','001-0408-05W','001-0408-06D',
'001-0408-06W','001-0518-12','001-0518-13','001-0518-14','001-0518-15','001-0924-00','001-0924-01','001-0924-02','001-0924-03') and operation_no = 100 then  t.part_no + ' Horz' 
when t.part_no in ('001-0408-04D','001-0408-04W','001-0408-05D','001-0408-05W','001-0408-06D',
'001-0408-06W','001-0518-12','001-0518-13','001-0518-14','001-0518-15','001-0924-00','001-0924-01','001-0924-02','001-0924-03') and operation_no = 130 then  t.part_no + ' Hone' 
when t.part_no in ('501-0994-03','501-0994-05','501-0994-05W','501-1234-00','501-1234-01','501-1234-02','501-1234-03','501-1234-04','501-1234-05','501-1234-06','501-1234-08') and operation_no = 100 then t.part_no + ' OP 10/20' 
when t.part_no in ('501-0994-03','501-0994-05','501-0994-05W','501-1234-00','501-1234-00W','501-1234-01','501-1234-02','501-1234-03','501-1234-04','501-1234-05','501-1234-06','501-1234-07','501-1234-08') and operation_no = 120 then t.part_no + ' 3rd Op'
when t.part_no in ('501-0994-03','501-0994-05','501-0994-05W','501-1234-00','501-1234-00W','501-1234-01','501-1234-02','501-1234-03','501-1234-04','501-1234-05','501-1234-06','501-1234-07','501-1234-08') and operation_no = 150 then t.part_no + ' Hone'
when t.part_no in ('501-1234-00W','501-1234-07') and operation_no = 110 then  t.part_no + ' OP 10/20' 

when t.part_no in ('YZ502895','R562293','26088055') and operation_no = 100 then  t.part_no + ' OP 10 Lathe' 
when t.part_no in ('26088055') and operation_no = 120 then  t.part_no + ' OP 20 Mill'
when t.part_no in ('YZ502895','R562293') and operation_no = 140 then t.part_no + ' OP 20 Mill'


when t.part_no in ('2013962') and operation_no = 110 then  t.part_no + ' Horz'
when t.part_no in ('2013962') and operation_no = 170 then t.part_no + ' Vert' 
when t.part_no in ('R556656','R328011','R344400','R542461','R543985','R254462','R254463','R254464','R254465','10037203','10037207','19X354217','26088054','PR3C-3C260-DA','PR3C-3C260-EA') then  t.part_no 

when t.part_no in ('51210T6N A000','52210T6N A020','H2GZ-5500-A','H2GZ-5500-B','HXE66422','L222884','L222885','R552103','R552111','R558149','PR3C-3C259-DA','PR3C-3C259-EA') then  t.part_no 

when t.part_no in ('TR121895','TR117178','TR117178','TR114674','R568616','51393TJB A040M1','51394TJB A040M1','H2GC 5K651 AB','H2GC 5K652 AB')  then t.part_no
when t.part_no in ('52119429AB','52121221AF','52210T6N A020','52215T6N A020','68400221AA','CBO1410373','CBO1410417','CBO1410792','H151940','H151941','H224079','H224080')  then t.part_no

when operation_no = 100 then t.part_no + ' Horz'
else t.part_no + ' Vert' 
end descr,
t.part_no alias,
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
