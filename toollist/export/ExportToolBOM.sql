
-- -- Assembly No,Part No,Part Revision,Operation Code,Tool No,Qty,Matched Set,Station,Optional,Workcenter,Sort Order
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
from 
PlexToolListAssemblyTemplate a
-- select * from PlexToolListAssembly a	
inner join bvToolListItemsOnlyLv1 lv1 --  119, No Misc, or Fixture items; they are not associated with a tool
on a.processid=lv1.processid   -- 1 to many
and a.ToolNumber=lv1.ToolNumber
-- where a.Operation <> 'Machine Complete'

/*
 * 2nd insert ToolList Fixture items
 */
insert into dbo.PlexToolBOM (Assembly_No,Part_No,Part_Revision,Operation_Code,Tool_No,Qty,Matched_Set,Station,Optional,Workcenter,Sort_Order)
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
from 
PlexToolListAssemblyTemplate a
-- select * from PlexToolListAssembly a	
inner join bvToolListItemsFixtureOnlyLv1 lv1 --  119, No Misc, or Fixture items; they are not associated with a tool
on a.processid=lv1.processid   -- 1 to many
and a.ToolNumber=lv1.ToolNumber
-- where a.Operation <> 'Machine Complete'

/*
 * 3rd insert ToolList Misc items
 */
insert into dbo.PlexToolBOM (Assembly_No,Part_No,Part_Revision,Operation_Code,Tool_No,Qty,Matched_Set,Station,Optional,Workcenter,Sort_Order)
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
from 
PlexToolListAssemblyTemplate a
-- select * from PlexToolListAssembly a	
inner join bvToolListItemsMiscOnlyLv1 lv1 --  119, No Misc, or Fixture items; they are not associated with a tool
on a.processid=lv1.processid   -- 1 to many
and a.ToolNumber=lv1.ToolNumber
-- where a.Operation <> 'Machine Complete'


select * from dbo.PlexToolBOM b
order by b.Operation_Code,b.Assembly_No

order by a.Part_No,a.Part_Revision,a.Operation_Code,a.Assembly_No
-- select count(*) cnt from bvToolListItemsInPlants  -- 31332
-- select count(*) cnt from bvToolListItemsInPlantsMoreInfo  -- 32578
-- Tool No,Qty,Matched Set,Station,Optional,Workcenter,Sort Order
--select count(*) cnt from PlexMasterToolList  -- 502
select * from PlexMasterToolList
select processid,itemNumber from bvToolListItemsInPlants where plant = '12'

