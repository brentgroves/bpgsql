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
w.workcenter_key,w.workcenter_code,w.plc_name,w.name,
s.setup_key,s.setup_date,
sc.cavity_no sccavity_no,sc.Container_Note,  -- associated with output streamid???
pr.cavity_no prcavity_no, --CANT find cavity_no
s.cavity_no scavity_no,
--j.cavity_no,
c.serial_no cSerial_No,pr.Serial_No prSerial_No,
c.container_status,
c.Gross_Weight cGross_Weight,pr.gross_weight prGross_Weight,
c.tare_weight ctare_weight,pr.tare_weight prtare_weight,
c.Net_Weight cNet_Weight,pr.Net_Weight prNet_Weight,
-- CNC 103 does not have a container. WHY? 
c.tracking_no ctracking_no,j.tracking_no jtracking_no,
p.part_no,p.name,
po.operation_no,po.standard_quantity,Standard_Container_Type,
j.job_no,j.quantity,j.due_date,
jo.op_no,
pr.quantity,
--pr.tare_weight,pr.quantity,pr.record_date,
--u.last_name,u.first_name,
js.job_status
from part_v_workcenter AS W
left outer join part_v_setup s
on w.workcenter_key=s.workcenter_key
LEFT OUTER JOIN part_v_Setup_Container AS SC  
  ON SC.Workcenter_Key = S.Workcenter_Key
  AND SC.Setup_Key = S.Setup_Key
left outer join part_v_container c  
on sc.serial_no=c.serial_no
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
where
--sc.cavity_no is not null
(
w.workcenter_code = @Workcenter_code 
or
w.workcenter_key = 61312
)
and 
pr.record_date > '9/23/2019 6:00:00 AM'
and pr.record_date < '9/25/2019 6:00:00 AM'

/*
CREATE PROCEDURE [dbo].[Web_Service_Record_Production]       
(
  @PCN INT,
  @Result_Error BIT = 1 OUTPUT,
  @Result_Code INT = 999 OUTPUT,
  @Result_Message VARCHAR(150) = 'Invalid Transaction' OUTPUT,
  @PLC_Name VARCHAR(50) = '', --w.plc_name
  @Workcenter_Key INT = NULL,  --w.workcenter_key
  @Serial_No VARCHAR(25) = '', --c.serial_no
  @Quantity DECIMAL(19,5) = NULL, --pr.quantity
  @Output_Stream_Id VARCHAR(20) = '', --???--sc.cavity_no???
  @Net_Weight DECIMAL(19,5) = NULL,--c.Net_Weight
  @Gross_Weight DECIMAL(19,5) = NULL,--c.Gross_Weight
  @Tare_Weight DECIMAL(19,5) = NULL,--,c.Tare_Weight
  @New_Container BIT = NULL OUTPUT,--???
  @Container_Status VARCHAR(50) = NULL,--c.container_status
  @Production_Serialized XML = NULL, --Not Implemented
  @Piece_Serialized XML = NULL,--Not Implemented????
  @Scrap_Quantity DECIMAL(19,5) = 0,  --Asked KORS for customer data source to subtract quantity from setup container.
  @Scrap_Reason VARCHAR(50) = '',
  @Tracking_No VARCHAR(50) = '', --pr.tracking_no,c.tracking_no
  @Scrap_Coordinate_Row_Ordinal VARCHAR(10) = '', --passed in from KORS?
  @Scrap_Coordinate_Column_Ordinal VARCHAR(10) = '',--passed in from KORS?
  @Scrap_From_Production_Qty BIT = 0,--passed in from KORS?
  --passed in from KORS?
  @Add_To_Master INT = 0, --Values: 0=No Master, 1=Add to current (if none create it) 
  -- this is in part_v_master_unit but don't know how to link with other than job_op
  --What is a MASTER???
  @Master_Unit_No VARCHAR(10) = '', --add to this master or use the keyword 'NEW'  
  --see New_Serial_No below
  @Start_New_Container BIT = 0, --Start a new container after produced container is unloaded (Overrides Container_Full = 0)
  --Does this create a new part_v_container record???
  @Container_Full BIT = 1, --Unloads the produced container
  --IF WE WANT TO SCRAP AN ITEM AFTER IT HAS BEEN RECORDED SHOULD WE USE THIS???
  @Qty_Is_Container_Qty BIT = 0, --The passed quantity is the new total container quantity.  Quantity - Current Container Quty = Production Quantity
  -- IS THIS FOR TESTING PURPOSES???
  @Validate_Only BIT = 0, --Runs part of the sproc and then exits
  @Validation_Failed BIT = 0 OUTPUT,
  @Container_Note VARCHAR(500) = NULL,--sc.Container_Note
  --serial_no cSerial_No,pr.Serial_No prSerial_No
  @New_Serial_No VARCHAR(25) = '' OUTPUT, --If a new container is added and loaded after production (Start_New_Container = true) this is the new serial no
  @Record_Bin_For_Bin BIT = 0, --Set to true to record the passed in serial number as bin for bin
  --serial_no cSerial_No,pr.Serial_No prSerial_No which one???
  @Container_Class VARCHAR(50) = '',
  -- this is in part_v_master_unit but don't know how to link with other than job_op
  --What is a MASTER???
  @Recorded_Master_Unit_No VARCHAR(10) = '' OUTPUT,
  --What is it used for??
  @Recorded_Part_No VARCHAR(100) = '' OUTPUT,
  --Why do we need this??
  @Recorded_Revision VARCHAR(8) = '' OUTPUT,
  --Is this the same as the pr.quantity??
  @Recorded_Quantity DECIMAL(19,5) = 0 OUTPUT,
  --What is this used for???
  @Scan_To_Load_Allow BIT = 0, -- In bin for bin mode, if the current setup does not match the the incomming container, attempt a scan to load setup 
  --Why is this needed??
  @Job_Op_Complete_Validate BIT = 0
)
*/
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
