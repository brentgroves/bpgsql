        DECLARE var1 int;
        DECLARE var2 int;
        DECLARE var3 int;
        SELECT id, foo, bar INTO var1, var2, var3 from page WHERE name="bob";
        CALL someAwesomeSP (var1 , var2 , var3 );
       
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

CREATE PROCEDURE TEST1()
BEGIN
	DECLARE Alternate_Tool_Key int DEFAULT 0;
	DECLARE Regrind_Tool_Key int DEFAULT 0;
	DECLARE Tool_Key int DEFAULT 0;
	DECLARE Assembly_Key int DEFAULT 0;
	set @pCNC_Approved_Workcenter_Key = 2;
	set @pTool_Var = 1;  -- Assembly_Key = 13
	-- set @pTool_Var = 12; -- REWORK tool_key 8
	-- set @pTool_Var = 22; -- REWORK tool_key 15
	-- set @pTool_Var = 15; -- alt in use  Alternate_Tool_Key=12,Primary_Tool_key 13
	set @pCurrent_Value = 12;
	set @pRunning_Total = 24;
	set @pLast_Update = '2020-08-28 10:15:49';
	set @pCNC_Approved_Workcenter_Key = 2;
	-- select * from Tool_Var_Map tv 
	-- select * from Part_v_Tool_BOM
/*
    	select pl.PCN Plexus_Customer_No,pl.Part_Key,
    	cpl.Part_Operation_Key,pl.Assembly_Key,pl.Tool_Key,cpl.Current_Value,cpl.Running_Total,cpl.Last_Update 
	    from Part_v_Tool_Op_Part_Life pl
		inner join CNC_Tool_Op_Part_Life cpl
		on pl.Tool_Op_Part_Life_Key = cpl.Tool_Op_Part_Life_Key -- 1 to 1
		where pl.Tool_Key = 1 and pl.Assembly_Key = 13
 */

    select tv.Tool_Key INTO Tool_Key
    -- caw.CNC_Approved_Workcenter_Key,tv.Tool_Var,aiu.Alternate_Tool_Key
    -- CNC_Approved_Workcenter caw 
	from CNC_Approved_Workcenter caw 
	inner join Tool_Var_Map tv 
	on caw.Plexus_Customer_No = tv.Plexus_Customer_No  -- 
	and caw.CNC_Approved_Workcenter_Key = tv.CNC_Approved_Workcenter_Key  -- 1 to many
	where caw.CNC_Approved_Workcenter_Key=@pCNC_Approved_Workcenter_Key 
    and tv.Tool_Var = @pTool_Var;

    select 
    tv.Assembly_Key INTO Assembly_Key
    -- caw.CNC_Approved_Workcenter_Key,tv.Tool_Var,aiu.Alternate_Tool_Key
    -- CNC_Approved_Workcenter caw 
	from CNC_Approved_Workcenter caw 
	inner join Tool_Var_Map tv 
	on caw.Plexus_Customer_No = tv.Plexus_Customer_No  -- 
	and caw.CNC_Approved_Workcenter_Key = tv.CNC_Approved_Workcenter_Key  -- 1 to many
	where caw.CNC_Approved_Workcenter_Key=@pCNC_Approved_Workcenter_Key 
    and tv.Tool_Var = @pTool_Var;
   
    SELECT Assembly_Key,Tool_Key;
	-- update
	
    select aiu.Alternate_Tool_Key INTO Alternate_Tool_Key
    -- caw.CNC_Approved_Workcenter_Key,tv.Tool_Var,aiu.Alternate_Tool_Key
    -- CNC_Approved_Workcenter caw 
	from CNC_Approved_Workcenter caw 
	inner join Tool_Var_Map tv 
	on caw.Plexus_Customer_No = tv.Plexus_Customer_No  -- 
	and caw.CNC_Approved_Workcenter_Key = tv.CNC_Approved_Workcenter_Key  -- 1 to many
	left outer join Tool_BOM_Alternate_In_Use_V2 aiu 
	on caw.Plexus_Customer_No = aiu.Plexus_Customer_No 
	and caw.CNC_Approved_Workcenter_Key = aiu.CNC_Approved_Workcenter_Key 
	and tv.Assembly_Key = aiu.Assembly_Key 
	and tv.Tool_Key = aiu.Primary_Tool_Key -- 1 to 1/0
	where caw.CNC_Approved_Workcenter_Key=@pCNC_Approved_Workcenter_Key 
    and tv.Tool_Var = @pTool_Var;
   
    SELECT Alternate_Tool_Key;
    if Alternate_Tool_Key is not null then
    	set Tool_Key = Alternate_Tool_Key;
        SELECT 'Alternate_Tool_Key is not null';
    end if;

   	select tiu.Tool_Key into Regrind_Tool_Key 
	from CNC_Approved_Workcenter caw 
	inner join Tool_Var_Map tv 
	on caw.Plexus_Customer_No = tv.Plexus_Customer_No  -- 
	and caw.CNC_Approved_Workcenter_Key = tv.CNC_Approved_Workcenter_Key  -- 1 to many
	left outer join Tool_Inventory_In_Use_V2 tiu 
	on caw.Plexus_Customer_No = tiu.Plexus_Customer_No 
	and caw.CNC_Approved_Workcenter_Key = tiu.CNC_Approved_Workcenter_Key 
	and tv.Assembly_Key = tiu.Assembly_Key 
	and tv.Tool_Key = tiu.Primary_Tool_Key -- 1 to 1/0
	where caw.CNC_Approved_Workcenter_Key=@pCNC_Approved_Workcenter_Key 
    and tv.Tool_Var = @pTool_Var;

    if Regrind_Tool_Key is not null then
    	set Tool_Key = Regrind_Tool_Key;
        SELECT 'Regrind_Tool_Key is not null';
    end if;
   	select Tool_Key;
   
    select pl.*
   	from CNC_Approved_Workcenter caw 
    inner join
    (
    	select pl.PCN Plexus_Customer_No,pl.Part_Key,
    	cpl.Part_Operation_Key,pl.Assembly_Key,pl.Tool_Key 
	    from Part_v_Tool_Op_Part_Life pl
		inner join CNC_Tool_Op_Part_Life cpl
		on pl.Tool_Op_Part_Life_Key = cpl.Tool_Op_Part_Life_Key -- 1 to 1
	) pl 
	on caw.Plexus_Customer_No = pl.Plexus_Customer_No 
	and caw.Part_Key = pl.Part_Key 
	and caw.Part_Operation_Key = pl.Part_Operation_Key 
	where caw.CNC_Approved_Workcenter_Key=@pCNC_Approved_Workcenter_Key 
	and pl.Assembly_Key = Assembly_Key
	and pl.Tool_Key = Tool_Key; 

	-- where caw.CNC_Approved_Workcenter_Key=pCNC_Approved_Workcenter_Key 
    -- and tv.Tool_Var = Tool_Var
     set pReturnValue = 0;

END;


OPTION #2
	select 
	-- p.CNC_Key,p.Part_Key,p.Operation_Key,b.Set_No,b.Block_No,b.Assembly_Key,
	a.Increment_By into pIncrementBy  --<-- HERE
	from CNC_Part_Operation p
	inner join CNC_Part_Operation_Set_Block b 
	on p.CNC_Key = b.CNC_Key
	and p.Part_Key = b.Part_Key
	and p.Operation_Key = b.Operation_Key
	inner join CNC_Part_Operation_Assembly a
	on b.CNC_Key = a.CNC_Key
	and b.Part_Key = a.Part_Key
	and b.Operation_Key = a.Operation_Key
	and b.Assembly_Key = a.Assembly_Key
