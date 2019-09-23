-- Web_Service_Record_Prodcution is the actual code.
-- This is just some notes to try to understand what it it doing.

select top 100 * from part_v_part
select top 100 * from part_v_job
select top 100 * from part_v_job_op
select top 100 * from part_v_job_status  --DON'T KNOW HOW TO RELATE THIS TO JOB
select top 100 * from part_v_operator  -- DON'T KNOW HOW TO LINK THIS TO NAME
select top 100 * from part_v_part_operation  -- DON'T KNOW HOW THIS RELATES TO JOB OPERATION.
select top 100 * from part_v_production
select top 100 * from part_v_setup

/*
work centers production records
*/

--DECLARE @PLC_Name VARCHAR(50)
--set @PLC_Name = 'CNC103'
DECLARE @Workcenter_code VARCHAR(50)
set @Workcenter_code = 'CNC103'


select top 100 
w.workcenter_code,w.plc_name,w.name,
s.setup_key,s.setup_date,
c.serial_no,c.container_status,
p.part_no,p.name,
po.operation_no,po.standard_quantity,Standard_Container_Type,
j.job_no,j.quantity,j.due_date,
jo.op_no,
--pr.tare_weight,pr.quantity,pr.record_date,
--u.last_name,u.first_name,
js.job_status
from part_v_workcenter AS W
left outer join part_v_setup s
on w.workcenter_key=s.workcenter_key
left outer join part_v_setup_container c  
on s.setup_key=c.setup_key
left outer join part_v_part p  
on s.part_key=p.part_key
left outer join part_v_part_operation po  
on s.part_operation_key=po.part_operation_key
--left outer join Part_Container_Type ct
--on po.
left outer join part_v_job_op jo --each production record is for a specific job operation.
on s.job_op_key=jo.job_op_key
left outer join part_v_job j 
on jo.job_key = j.job_key
left outer join part_v_job_status js
on j.job_status_key=js.job_status_key
left outer join part_v_production pr 
on s.setup_key=pr.setup_key
left outer join Plexus_Control_v_Plexus_User u
on pr.record_by=u.plexus_user_no
where w.workcenter_code = @Workcenter_code 
and pr.record_date > '9/23/2019 6:00:00 AM'


--DECLARE @Workcenter_code VARCHAR(50)
--set @Workcenter_code = 'CNC103'

select top 100 
w.workcenter_code,w.plc_name,w.name,
s.setup_key,s.setup_date,
c.container_status,c.serial_no
from part_v_workcenter AS W
left outer join part_v_setup s
on w.workcenter_key=s.workcenter_key
left outer join part_v_setup_container c  
on s.setup_key=c.setup_key
where w.workcenter_code = @Workcenter_code 
--and pr.record_date > '9/23/2019 6:00:00 AM'




select top 100 * from part_v_cell_production
where production_date >= '9/23/2019 06:00:00'
select top 100 * from part_v_container
where location like '%CNC 103%'
select top 100 * from part_v_container_status


