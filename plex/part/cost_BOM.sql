select p.part_key,p.part_no,
c.part_no,c.revision,c.cost_type,c.cost_sub_type,c.cost,b.quantity,c.cost*b.quantity tot_cost
--b.* 
from part_v_bom b
inner join part_v_part p 
on b.plexus_customer_no= p.plexus_customer_no 
and b.component_part_key = p.part_key
inner join Accelerated_Standard_Cost_Part_v_e c
on b.plexus_customer_no=c.pcn 
and p.part_key = c.part_key
where b.plexus_customer_no = 300758
and b.part_key = 2795840

/*

select * from part_v_part
where plexus_customer_no = 300758
and part_no = '10035415'
--and part_no = '001-0408-04W'


*/