-- Web_Service_Record_Prodcution is the actual code.
-- This is just some notes to try to understand what it it doing.

select top 100 * from part_v_part
select top 100 * from part_v_job
select top 100 * from part_v_job_op
select top 100 * from part_v_job_status  --DON'T KNOW HOW TO RELATE THIS TO JOB
select top 100 * from part_v_operator  -- DON'T KNOW HOW TO LINK THIS TO NAME
select top 100 * from part_v_part_operation  -- DON'T KNOW HOW THIS RELATES TO JOB OPERATION.
select top 100 * from part_v_production


/*
part job production
*/

DECLARE @PLC_Name VARCHAR(50)
set @PLC_Name = 'CNC103'


select top 100 
pr.setup_key,pr.tare_weight,
pr.quantity,pr.record_date,pr.record_by,
u.last_name,u.first_name,
w.workcenter_code,w.plc_name,w.name,
j.job_no,o.op_no,j.quantity,j.due_date,
o.description,
s.job_status,
p.part_no,p.name
from part_v_production pr
left outer join part_v_workcenter AS W
on pr.workcenter_key=w.workcenter_key
left outer join Plexus_Control_v_Plexus_User u
on pr.record_by=u.plexus_user_no
left outer join part_v_part p  --WHY ARE THESE NOT LINKING TO THE WORK CENTER?
on pr.part_key=p.part_key
left outer join part_v_job_op o --each production record is for a specific job operation.
on pr.job_op_key=o.job_op_key
left outer join part_v_job j 
on o.job_key = j.job_key
left outer join part_v_job_status s
on j.job_status_key=s.job_status_key
where w.plc_name = @PLC_Name 
and pr.record_date > '9/23/2019 6:00:00 AM'



select top 100 * from part_v_cell_production
where production_date >= '9/23/2019 06:00:00'
select top 100 * from part_v_container
where location like '%CNC 103%'
select top 100 * from part_v_container_status

