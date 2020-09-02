-- Assembly No,Part No,Part Revision,Operation Code,Tool No,Qty,Matched Set,Station,Optional,Workcenter,Sort Order
-- Assembly No,Part No,Part Revision,Operation Code,Tool No,Qty,Matched Set,Station,Optional,Workcenter,Sort Order
/*
select 
ta.Assembly_No,
p.Part_No,
p.Revision Part_Revision,
o.Operation_Code
from part_v_tool_assembly ta
left outer join part_v_tool_assembly_part ap 
on ta.assembly_key=ap.assembly_key -- 1 to many
left outer join part_v_part p 
on ap.part_key=p.part_key  -- 1 to 1
left outer join part_v_operation o 
on ap.operation_key=o.operation_key  -- 1 to 1
    where ta.add_by = 11728751
-- select * from part_v_tool_assembly_part ap 
*/    
-- Busche Tool List

-- Assembly No,Tool Assembly Type,Description,Part No,Part Revision,Operation,Tool Assembly Status,Include in Analysis,Analysis Note,Note,Location
select * from ToolListAssembly 
-- drop table PlexToolListAssembly
select * from dbo.PlexToolListAssembly 
create table PlexToolListAssembly
(
	ProcessID int,
	ToolNumber int,
	Assembly_No	varchar (50), --Assembly No,
	Part_No	varchar (100), --Part No,
	Part_Revision	varchar (8), --Part Revision,
	Operation_Code	varchar (30) --Operation_Code in Plex
)
-- Assembly No,Tool Assembly Type,Description,Part No,Part Revision,Operation,Tool Assembly Status,Include in Analysis,Analysis Note,Note,Location
insert into PlexToolListAssembly (ProcessID,ToolNumber,Assembly_No,Part_No,Part_Revision,Operation_Code )
	select 
	-- ag.Count_PN_Rev_Assembly_No, tl.OperationDescription, 
	-- tl.Part_No,tl.Part_Revision,tl.Operation,
	tl.ProcessID,
	tl.ToolNumber,
	case 
		when ag.Count_PN_Rev_Op_Assembly_No > 1 then tl.Assembly_No + '-' + tl.OperationDescription 
		else tl.Assembly_No
	end Assembly_No,
	tl.Part_No,
	tl.Part_Revision,
	tl.Operation_Code
	from 
	(
		select
		tl.ProcessID,
		tt.ToolNumber,
		tl.OperationDescription,
		case 
			when (tt.ToolNumber < 10) then 'T0' + cast(tt.ToolNumber as varchar(3)) 
			when (tt.ToolNumber >= 10) then 'T' + cast(tt.ToolNumber as varchar(3))
		end Assembly_No,
		m.Plex_Part_No Part_No,
		m.Revision Part_Revision,
		m.Operation_Code
		from bvToolListsInPlants tl
		inner join [ToolList Tool] tt  -- 307
		on tl.processid = tt.ProcessID
		inner join TL_Plex_PN_Op_Map m 
		on tl.processid = m.processid  -- 307
	)tl
	inner join 
	(
		select Assembly_No,Part_No,Part_Revision,Operation_Code,count(*) Count_PN_Rev_Op_Assembly_No
		from 
		(
			select 
			case 
				when (tt.ToolNumber < 10) then 'T0' + cast(tt.ToolNumber as varchar(3)) 
				when (tt.ToolNumber >= 10) then 'T' + cast(tt.ToolNumber as varchar(3))
			end Assembly_No,
			m.Plex_Part_No Part_No,
			m.Revision Part_Revision,
			m.Operation_Code 
			from bvToolListsInPlants tl
			inner join [ToolList Tool] tt  -- 307
			on tl.processid = tt.ProcessID
			inner join TL_Plex_PN_Op_Map m 
			on tl.processid = m.processid  -- 307
		)tl 
		group by Assembly_No,Part_No,Part_Revision,Operation_Code
	)ag	
	on tl.Assembly_No=ag.Assembly_No and tl.Part_No=ag.Part_No and tl.Part_Revision=ag.Part_Revision and tl.Operation_Code = ag.Operation_Code 
	where tl.Part_No = '6788776'

-- -- Assembly No,Part No,Part Revision,Operation Code,Tool No,Qty,Matched Set,Station,Optional,Workcenter,Sort Order
create table PlexToolBOM
(
	processid int,
	Assembly_No	varchar (50), --Assembly No,
	Part_No	varchar (100), --Part No,
	Part_Revision	varchar (8), --Part Revision,
	Operation_Code	varchar (30) --Operation_Code in Plex
)
-- select top 10 * from  bvToolListItemsInPlants inner join [ToolList
select a.Assembly_No,a.Part_No,a.Part_Revision,a.Operation_Code,
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
from PlexToolListAssembly a	
inner join bvToolListItemsOnlyLv1 lv1 --  119, No Misc, or Fixture items; they are not associated with a tool
on a.processid=lv1.processid   -- 1 to many
and a.ToolNumber=lv1.ToolNumber
order by a.Operation_Code,a.Assembly_No

order by a.Part_No,a.Part_Revision,a.Operation_Code,a.Assembly_No
-- select count(*) cnt from bvToolListItemsInPlants  -- 31332
-- select count(*) cnt from bvToolListItemsInPlantsMoreInfo  -- 32578
-- Tool No,Qty,Matched Set,Station,Optional,Workcenter,Sort Order
--select count(*) cnt from PlexMasterToolList  -- 502
select * from PlexMasterToolList
select processid,itemNumber from bvToolListItemsInPlants where plant = '12'

