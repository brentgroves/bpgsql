DROP PROCEDURE UpdateAssemblyMachiningHistory;
CREATE PROCEDURE UpdateAssemblyMachiningHistory
(
	IN pCNC_Approved_Workcenter_Key INT,  
	IN pSet_No INT,
	IN pBlock_No INT,
	IN pEnd_Time datetime,
	OUT pReturnValue INT 
)
BEGIN
	/*
	set @pCNC_Approved_Workcenter_Key = 2;
	set @pSet_No = 1;
	set @pBlock_No = 1;
	set @pStart_Time = '2020-09-05 09:50:00';
	set @pEnd_Time = '2020-09-05 10:00:00.0';
	*/
	set @Key_To_Update = (
	select amh.Assembly_Machining_History_Key
   	from CNC_Approved_Workcenter caw 
	inner join Datagram_Set_Block bl 
	on caw.Plexus_Customer_No = bl.Plexus_Customer_No 
	and caw.Workcenter_Key = bl.Workcenter_Key 
	and caw.CNC_Key = bl.CNC_Key
	and caw.Part_Key = bl.Part_Key
	and caw.Part_Operation_Key = bl.Part_Operation_Key -- 1 to 1
	inner join Assembly_Machining_History amh
	on bl.Plexus_Customer_No = amh.Plexus_Customer_No
	and bl.Workcenter_Key = amh.Workcenter_Key
	and bl.CNC_Key = amh.CNC_Key
	and bl.Part_Key = amh.Part_Key 
	and bl.Part_Operation_Key = amh.Part_Operation_Key
	and bl.Assembly_Key = amh.Assembly_Key
	-- where caw.CNC_Approved_Workcenter_Key=@pCNC_Approved_Workcenter_Key 
    -- and bl.Set_No = @pSet_No and bl.Block_No = @pBlock_No
   	where caw.CNC_Approved_Workcenter_Key=pCNC_Approved_Workcenter_Key 
    and bl.Set_No = pSet_No and bl.Block_No = pBlock_No
   	order by amh.Assembly_Machining_History_Key desc 
	LIMIT 1 OFFSET 0
	);
	update Assembly_Machining_History amh
	-- set Run_Time = TIMESTAMPDIFF(SECOND, amh.Start_Time, @pEnd_Time)
	set Run_Time = TIMESTAMPDIFF(SECOND, amh.Start_Time, pEnd_Time)
	where Assembly_Machining_History_Key = @Key_To_Update;

	set pReturnValue = 0;
	
END;	

