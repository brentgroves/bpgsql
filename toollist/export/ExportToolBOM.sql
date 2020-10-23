
-- -- Assembly No,Part No,Part Revision,Operation Code,Tool No,Qty,Matched Set,Station,Optional,Workcenter,Sort Order
select *
into dbo.PlexToolBOM1023  -- 1083
from dbo.PlexToolBOM 
-- select * from PlexToolBOM0910B

-- truncate table PlexToolBOM
-- drop table PlexToolBOM
create table PlexToolBOM
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
insert into dbo.PlexToolBOM (Assembly_No,Part_No,Part_Revision,Operation_Code,Tool_No,Qty,Matched_Set,Station,Optional,Workcenter,Sort_Order)
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
		from PlexToolListAssemblyTemplate a  -- 367
		-- select * from PlexToolListAssembly a	
		inner join bvToolListItemsOnlyLv1 lv1 --  119, No Misc, or Fixture items; they are not associated with a tool
		on a.processid=lv1.processid   -- 1 to many
		and a.ToolNumber=lv1.ToolNumber  -- 1168
		-- where a.processid <> 61258  -- 1090 LC5C 5K651 CE 'LC5C 5K651 CE' this part_no had dashes originally until i remapped it.
		-- AFTER I UPDATE btDistinctToolList this count jumped to 1133
		-- select * from [Toollist Master] tm where tm.processid = 61258 -- LC5C-5K651-CC CD6 CONTROL ARM
	)s1 
	group by Assembly_No,Part_No,Part_Revision,Operation_Code,Tool_No,Qty,Matched_Set,Station,Optional,Workcenter,Sort_Order
	-- THERE ARE DUPS BECAUSE MULTIPLE CNC OPERATIONS MAP TO A SINGLE PLEX OPERATION AND HAVE THE SAME TOOLNUMBER.
--)s2  -- 1044
-- where a.Operation <> 'Machine Complete'

	select * from PlexToolBOM
	order by Assembly_No,Part_No,Tool_No 
/*
 * 2nd insert ToolList Fixture items
 */
insert into dbo.PlexToolBOM (Assembly_No,Part_No,Part_Revision,Operation_Code,Tool_No,Qty,Matched_Set,Station,Optional,Workcenter,Sort_Order)

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
		from PlexToolListAssemblyTemplate a  -- 367
		-- select * from PlexToolListAssembly a	
		inner join bvToolListItemsFixtureOnlyLv1 lv1 --  119, No Misc, or Fixture items; they are not associated with a tool
		on a.processid=lv1.processid   -- 1 to many
		and a.ToolNumber=lv1.ToolNumber  -- 30; = 111111
		-- where a.processid <> 61258  -- 30
	)s1 
	group by Assembly_No,Part_No,Part_Revision,Operation_Code,Tool_No,Qty,Matched_Set,Station,Optional,Workcenter,Sort_Order
-- )s2  -- 30 + 1168 

select count(*) cnt from PlexToolBOM  -- 1168 + 30 = 1198



select * 
from bvToolListItemsFixtureOnlyLv1 lv1
where lv1.processid = 61258 

-- where a.Operation <> 'Machine Complete'

/*
 * 3rd insert ToolList Misc items
 */
insert into dbo.PlexToolBOM (Assembly_No,Part_No,Part_Revision,Operation_Code,Tool_No,Qty,Matched_Set,Station,Optional,Workcenter,Sort_Order)

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
		from PlexToolListAssemblyTemplate a  -- 367
		-- select * from PlexToolListAssembly a	
		inner join bvToolListItemsMiscOnlyLv1 lv1 --  119, No Misc, or Fixture items; they are not associated with a tool
		on a.processid=lv1.processid   -- 1 to many
		and a.ToolNumber=lv1.ToolNumber  -- 9
		-- where a.processid <> 61258  -- 9
	)s1 
	group by Assembly_No,Part_No,Part_Revision,Operation_Code,Tool_No,Qty,Matched_Set,Station,Optional,Workcenter,Sort_Order
-- )s2

	
--Tool 16608 was already linked to Tool Assembly T03-MAKINO MILL COMPLETE for this the Part 10099858, Part Revision A, and Operation Final combination.
	
	select count(*) cnt from PlexToolBOM  -- 1168 + 30 + 10 = 1208
	-- exec bpDistinctToolLists HAD TO UPDATE btDistinctToolList -- The Tool Assemblies were OK because they used a view but bvToolListItemsXLv1 used btDistinctToolList which was not updeate.

	select
Assembly_No,Part_No,Part_Revision,Operation_Code,Tool_No,Qty,Matched_Set,Station,Optional,Workcenter,Sort_Order
FROM 
(
	select 
	ROW_NUMBER() OVER (
		ORDER BY part_no,operation_code,assembly_no
	) row_number,
	
	Assembly_No,Part_No,Part_Revision,Operation_Code,Tool_No,Qty,Matched_Set,Station,Optional,Workcenter,Sort_Order
	from dbo.PlexToolBOM b
) s1 
-- where Part_No = '10099858' and Tool_No = '16608'
--where s1.Part_No like '%ML3V%' -- waiting for JOSH to release these
-- where s1.Part_No like 'LC5C%'
-- where s1.Part_No = 'LC5C 5K651 CE'
where s1.Part_No not in ('10099858','10099860')  -- These have already been added to production as a test of JT Knuckles.
-- where s1.Part_No = '10049132'
and s1.row_number > 600  
-- 1083 to 1173  

10099858
order by b.Part_No,Operation_Code,b.Assembly_No

order by a.Part_No,a.Part_Revision,a.Operation_Code,a.Assembly_No
-- select count(*) cnt from bvToolListItemsInPlants  -- 31332
-- select count(*) cnt from bvToolListItemsInPlantsMoreInfo  -- 32578
-- Tool No,Qty,Matched Set,Station,Optional,Workcenter,Sort Order
--select count(*) cnt from PlexMasterToolList  -- 502
select * from PlexMasterToolList
select processid,itemNumber from bvToolListItemsInPlants where plant = '12'

select Assembly_No,Part_No,Part_Revision,Operation_Code,Tool_No,Qty,Matched_Set,Station,Optional,Workcenter,Sort_Order
FROM 
(
	select 
	ROW_NUMBER() OVER (
		ORDER BY part_no,operation_code,assembly_no
	) row_number,
	
	Assembly_No,Part_No,Part_Revision,Operation_Code,Tool_No,Qty,Matched_Set,Station,Optional,Workcenter,Sort_Order
	from dbo.PlexToolBOM b
) s1 
order by Assembly_No,Part_No,Tool_No 
where Tool_No in ('16793')
and Part_No = 'W11033021'

