
-- -- Assembly No,Part No,Part Revision,Operation Code,Tool No,Qty,Matched Set,Station,Optional,Workcenter,Sort Order
select count(*)
from dbo.PlexToolBOMPlant9

/*
 * BACKUP WHAT HAS ALREADY BEEN IMPORTED INTO PLEX
select *
into PlexToolBOMPlant6_6K_Knuckles_Horz
from dbo.PlexToolBOMPlant6

*/
-- select * from PlexToolBOMPlant9
-- truncate table PlexToolBOMPlant9
-- drop table PlexToolBOMPlant9
create table PlexToolBOMPlant9
(
	Assembly_No	varchar (50), --Assembly No,
	Part_No	varchar (100), --Part No,
	Part_Revision	varchar (8), --Part Revision,
	Operation_Code	varchar (30), --Operation_Code in Plex
	Tool_No	varchar (50),
	Qty int, -- Plex decimal (18,2) Quantity_Required
	Matched_Set varchar(5),
	Station varchar(5),
	Optional varchar(5),
	Workcenter varchar(5),
	Sort_Order int
)
-- select top 10 * from  bvToolListItemsInPlants inner join [ToolList
/*
 * First insert ToolList Items
 */
 -- select * from dbo.PlexToolBOMPlant9
insert into dbo.PlexToolBOMPlant9 (Assembly_No,Part_No,Part_Revision,Operation_Code,Tool_No,Qty,Matched_Set,Station,Optional,Workcenter,Sort_Order)
-- select count(*) from (
	select Assembly_No,Part_No,Part_Revision,Operation_Code,Tool_No,Qty,Matched_Set,Station,Optional,Workcenter,Sort_Order
	from 
	(
		select a.Assembly_No,a.Part_No,a.Part_Revision,a.Operation Operation_Code,
		-- select * from TL_Plex_PN_Op_Map
		-- select * from TL_Plex_PN_Map
		-- select top 10 * from bvToolListsInPlants tl
		lv1.itemNumber Tool_No, lv1.Quantity Qty,
		-- select Matched_Set_Key from part_v_tool_BOM where Matched_Set_Key is not null  -- 0
		'' Matched_Set,
		-- select Station_Key from part_v_tool_BOM where Station_Key is not null  -- 0
		'' Station,
		-- select Optional from part_v_tool_BOM where Optional <> 0  -- 0
		'' Optional,
		-- select Workcenter_Key from part_v_tool_BOM where Workcenter_Key is not null  -- 0
		'' Workcenter,
		-- select Sort_Order from part_v_tool_BOM where Sort_Order <> 0  -- 0
		0 Sort_Order
		-- select count(*) cnt
		from PlexToolListAssemblyTemplatePlant9 a  -- 8 
		-- select * from PlexToolListAssembly a	
		inner join bvToolListItemsOnlyLv1 lv1 -- No Misc, or Fixture items; they are not associated with a tool
		on a.processid=lv1.processid   -- 1 to many
		and a.ToolID=lv1.ToolID  -- --76
		-- where a.processid <> 61258  -- 1090 LC5C 5K651 CE 'LC5C 5K651 CE' this part_no had dashes originally until i remapped it.
		-- AFTER I UPDATE btDistinctToolList this count jumped to 1133
		-- select * from [Toollist Master] tm where tm.processid = 61258 -- LC5C-5K651-CC CD6 CONTROL ARM
	)s1 
	group by Assembly_No,Part_No,Part_Revision,Operation_Code,Tool_No,Qty,Matched_Set,Station,Optional,Workcenter,Sort_Order
	-- THERE ARE DUPS BECAUSE MULTIPLE CNC OPERATIONS MAP TO A SINGLE PLEX OPERATION AND HAVE THE SAME TOOLNUMBER.
	-- THE ASSEMBLY_NO INCLUDES THE CNC OPERATION; SO THE ASSEMBLY_NO WILL BE DIFFERENT, BUT THE PART,REV,PLEX OPERATION WILL BE
	-- THE SAME.
-- )s2 
-- having Part_No = '26090196'
-- where a.Operation <> 'Machine Complete'

	/*
	 * Test regular items onlyF
	 */
	select count(*) cnt from PlexToolBOMPlant9 -- 51
	select * from PlexToolBOMPlant9 
	select * from PlexToolBOMPlant9 
	order by Assembly_No,Part_No,Tool_No 

-- dbo.bvToolListItemsMiscOnlyLv1 source
/*
 * Second insert Misc ToolList Items
 */
-- select count(*) from dbo.bvToolListItemsMiscOnlyLv1 btlimol -- 244
--	select * from dbo.bvToolListItemsMiscOnlyLv1 btlimol where processid = 62158 62157 62480 62445 63269 62444 40129 41202 41207 40173 54071  48625  54522 50868 54351 54339 63710 63747 62372 63810 --63810
-- select count(*) from btDistinctToolLists tb  -- 521
-- select * from btDistinctToolLists tb  -- 521  
-- where processid = 63810
--	select * from dbo.PlexToolBOMPlant9 
insert into dbo.PlexToolBOMPlant9 (Assembly_No,Part_No,Part_Revision,Operation_Code,Tool_No,Qty,Matched_Set,Station,Optional,Workcenter,Sort_Order)
	
-- select count(*) from (
	select Assembly_No,Part_No,Part_Revision,Operation_Code,Tool_No,Qty,Matched_Set,Station,Optional,Workcenter,Sort_Order
	from 
	(
		select a.Assembly_No,a.Part_No,a.Part_Revision,a.Operation Operation_Code,
		-- select * from TL_Plex_PN_Op_Map
		-- select * from TL_Plex_PN_Map
		-- select top 10 * from bvToolListsInPlants tl
		lv1.itemNumber Tool_No, lv1.Quantity Qty,
		-- select Matched_Set_Key from part_v_tool_BOM where Matched_Set_Key is not null  -- 0
		'' Matched_Set,
		-- select Station_Key from part_v_tool_BOM where Station_Key is not null  -- 0
		'' Station,
		-- select Optional from part_v_tool_BOM where Optional <> 0  -- 0
		'' Optional,
		-- select Workcenter_Key from part_v_tool_BOM where Workcenter_Key is not null  -- 0
		'' Workcenter,
		-- select Sort_Order from part_v_tool_BOM where Sort_Order <> 0  -- 0
		0 Sort_Order
		-- select count(*) cnt
		--select *
		from PlexToolListAssemblyTemplatePlant9 a  -- 8 
		-- select * from PlexToolListAssembly a	
		inner join bvToolListItemsMiscOnlyLv1 lv1 -- No Misc, or Fixture items; they are not associated with a tool
		on a.processid=lv1.processid   -- 1 to many
		and a.ToolNumber=lv1.ToolNumber  -- --76
		-- where a.processid <> 61258  -- 1090 LC5C 5K651 CE 'LC5C 5K651 CE' this part_no had dashes originally until i remapped it.
		-- AFTER I UPDATE btDistinctToolList this count jumped to 1133
		-- select * from [Toollist Master] tm where tm.processid = 61258 -- LC5C-5K651-CC CD6 CONTROL ARM
	)s1 
	group by Assembly_No,Part_No,Part_Revision,Operation_Code,Tool_No,Qty,Matched_Set,Station,Optional,Workcenter,Sort_Order
	-- THERE ARE DUPS BECAUSE MULTIPLE CNC OPERATIONS MAP TO A SINGLE PLEX OPERATION AND HAVE THE SAME TOOLNUMBER.
	-- THE ASSEMBLY_NO INCLUDES THE CNC OPERATION; SO THE ASSEMBLY_NO WILL BE DIFFERENT, BUT THE PART,REV,PLEX OPERATION WILL BE
	-- THE SAME.
-- )s2 
-- having Part_No = '26090196'
-- where a.Operation <> 'Machine Complete'
select * from dbo.PlexToolBOMPlant9 


/*
 * Third insert Fixture ToolList Items
 */
-- select count(*) from dbo.bvToolListItemsFixtureOnlyLv1 btlimol -- 750
--	select * from dbo.bvToolListItemsFixtureOnlyLv1 btlimol where processid =  62158 62157 62480 62445 63269 62444 40129 41202 41207 40173 54071 48625 54522 50868 54351 54339 63710 63747 62372 63811 63810 --61622 --14218 --63810
-- select count(*) from btDistinctToolLists tb  -- 521
-- select * from btDistinctToolLists tb  -- 521  
-- where processid = 63810
--	select * from dbo.PlexToolBOMPlant8 

-- having Part_No = '26090196'
-- where a.Operation <> 'Machine Complete'
select * from dbo.PlexToolBOMPlant9
--	select * from dbo.PlexToolBOMPlant8 
insert into dbo.PlexToolBOMPlant9 (Assembly_No,Part_No,Part_Revision,Operation_Code,Tool_No,Qty,Matched_Set,Station,Optional,Workcenter,Sort_Order)
	
-- select count(*) from (
	select Assembly_No,Part_No,Part_Revision,Operation_Code,Tool_No,Qty,Matched_Set,Station,Optional,Workcenter,Sort_Order
	from 
	(
		select a.Assembly_No,a.Part_No,a.Part_Revision,a.Operation Operation_Code,
		-- select * from TL_Plex_PN_Op_Map
		-- select * from TL_Plex_PN_Map
		-- select top 10 * from bvToolListsInPlants tl
		lv1.itemNumber Tool_No, lv1.Quantity Qty,
		-- select Matched_Set_Key from part_v_tool_BOM where Matched_Set_Key is not null  -- 0
		'' Matched_Set,
		-- select Station_Key from part_v_tool_BOM where Station_Key is not null  -- 0
		'' Station,
		-- select Optional from part_v_tool_BOM where Optional <> 0  -- 0
		'' Optional,
		-- select Workcenter_Key from part_v_tool_BOM where Workcenter_Key is not null  -- 0
		'' Workcenter,
		-- select Sort_Order from part_v_tool_BOM where Sort_Order <> 0  -- 0
		0 Sort_Order
		-- select count(*) cnt
		--select *
		from PlexToolListAssemblyTemplatePlant9 a  -- 8 
		-- select * from PlexToolListAssembly a	
		inner join bvToolListItemsFixtureOnlyLv1 lv1 -- No Misc, or Fixture items; they are not associated with a tool
		on a.processid=lv1.processid   -- 1 to many
		
		and a.ToolNumber=lv1.ToolNumber  -- --76
		-- where a.processid <> 61258  -- 1090 LC5C 5K651 CE 'LC5C 5K651 CE' this part_no had dashes originally until i remapped it.
		-- AFTER I UPDATE btDistinctToolList this count jumped to 1133
		-- select * from [Toollist Master] tm where tm.processid = 61258 -- LC5C-5K651-CC CD6 CONTROL ARM
	)s1 
	group by Assembly_No,Part_No,Part_Revision,Operation_Code,Tool_No,Qty,Matched_Set,Station,Optional,Workcenter,Sort_Order
	-- THERE ARE DUPS BECAUSE MULTIPLE CNC OPERATIONS MAP TO A SINGLE PLEX OPERATION AND HAVE THE SAME TOOLNUMBER.
	-- THE ASSEMBLY_NO INCLUDES THE CNC OPERATION; SO THE ASSEMBLY_NO WILL BE DIFFERENT, BUT THE PART,REV,PLEX OPERATION WILL BE
	-- THE SAME.
-- )s2 
-- having Part_No = '26090196'
-- where a.Operation <> 'Machine Complete'
select * from dbo.PlexToolBOMPlant9
