/*
How do we know if a workcenter is down?
What are the different status types a workcenter can be in?

Try to immatate the Plex production status screen
Look at the workcenter log and find out when the workcenter is down.
*/
  SELECT
  w.workcenter_key,
  w.building_key,
  w.workcenter_group,
  W.Workcenter_Code,
--  WT.Job_Setup,
  -- w.part_key,  -- nothing here
  s.part_key,
  s.part_operation_key,
  s.job_op_key,
  s.setup_date,
  wl.log_date,
--  s.setup_mode,
--  s.production_mode,
  wl.workcenter_status_key,
  ws.description
 
--  s.*
FROM  part_v_workcenter AS w
inner join part_v_Workcenter_Type AS wt
on w.plexus_customer_no = wt.plexus_customer_no
and WT.Workcenter_Type = W.Workcenter_Type
inner join part_v_setup AS s
on w.plexus_customer_no=s.plexus_customer_no
and w.workcenter_key=s.workcenter_key
inner join part_v_workcenter_log wl
on w.plexus_customer_no = wl.plexus_customer_no
and w.workcenter_key = wl.workcenter_key
inner join part_v_workcenter_status ws
on wl.workcenter_status_key=ws.workcenter_status_key
where w.plexus_customer_no = @PCN
and w.workcenter_key = 60740
--and w.workcenter_key in ( 60740, 60741)
and wl.log_date > '7/19/2021'  -- 110 rows
order by wl.log_date desc

/*
What has a workcenter_status_key
select workcenter_status_key,description,* from part_v_Workcenter_Status
select * from part_v_timeblock  -- 0 records
select * from part_v_Workcenter_Event_Status  -- 32 rows
select * from part_v_workcenter_log wl  -- many records
where wl.workcenter_key in ( 60740, 60741)
and wl.log_date > '7/18/2021'  -- 110 rows
*/