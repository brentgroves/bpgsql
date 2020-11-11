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
