select 
p.part_key,
po.part_operation_key,
p.part_no alias,
p.Part_No,p.Revision,
p.name Part_Name,
-- START CONTAINER INFO
po.Part_Operation_key,
po.operation_no,
ot.description operation_type 
--pl.localization_source_value
--select count(*) --p.part_key
from Part_v_Part_e p  -- 1038 with PCN filter
inner join part_v_part_operation_e po -- 1038 with PCN filter
on p.plexus_customer_no = po.plexus_customer_no
and p.part_key = po.part_key
inner join part_v_part_op_type_e ot 
on po.plexus_customer_no = ot.pcn
and po.part_op_type_key = ot.part_op_type_key
where p.plexus_customer_no = 300758 
--and po.part_operation_key = 8786306
and p.part_no like '%51393TJB A040%'
and p.plexus_customer_no = @PCN