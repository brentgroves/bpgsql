select p.part_no,p.name,p.part_type,po.operation_no,o.operation_code,po.description,
ot.description,
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
from part_v_part_e p
inner join part_v_part_operation po
on p.plexus_customer_no = po.plexus_customer_no
and p.part_key = po.part_key
inner join part_v_operation o
on po.operation_key=o.operation_key
inner join part_v_part_op_type ot 
on po.plexus_customer_no = ot.pcn
and po.part_op_type_key = ot.part_op_type_key
where p.plexus_customer_no = 300758
and p.part_key = 2794706
and ot.description='Production'  -- rework,cell,etc.

/*
 * DataDirect ODBC driver does not allow XML clause.
 */
*/