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
create table ToolListAssembly
(
	Assembly_No	varchar (50), --Assembly No,
	Part_No	varchar (100), --Part No,
	Part_Revision	varchar (8), --Part Revision,
	Operation_Code	varchar (30) --Operation_Code in Plex
)
-- Assembly No,Tool Assembly Type,Description,Part No,Part Revision,Operation,Tool Assembly Status,Include in Analysis,Analysis Note,Note,Location
insert into ToolListAssembly (Assembly_No,Part_No,Part_Revision,Operation_Code )
	select 
	-- ag.Count_PN_Rev_Assembly_No, tl.OperationDescription, 
	-- tl.Part_No,tl.Part_Revision,tl.Operation,
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
	order by tl.Part_No,tl.Part_Revision,tl.Operation_Code,tl.Assembly_No
-- FROM [Busche ToolList].dbo.[ToolList Tool] tt;
    
		select tl.Plant,tl.processid,tl.OperationDescription,tl.partNumber,tl.Plex_Part_No,tl.Revision,tl.Operation_Code,co.Count_CNC_Operations
		from 
		(
			select tl.Plant,tl.processid,tl.OperationDescription,tl.partNumber,m.Plex_Part_No,m.Revision,m.Operation_Code 
			from dbo.bvToolListsInPlants tl  -- 30
		 	inner join TL_Plex_PN_Op_Map m 
		 	on tl.processid = m.processid
		) tl 
		left outer join 
		(
		 	select m.Plex_Part_No, count(*) Count_CNC_Operations 
			from dbo.bvToolListsInPlants tl  -- 30
		 	inner join TL_Plex_PN_Op_Map m 
		 	on tl.processid = m.processid
		 	group by m.Plex_Part_No,m.Revision 
		) co 
		on tl.Plex_Part_no = co.Plex_Part_No
		-- order by tl.Plex_Part_No

 */
/*
 * All Assemblies for Edon ToolLists
 */
select distinct processid,partNumber from dbo.bvToolListsInPlants where plant = '12'  -- 30



SELECT ToolID, ProcessID, ToolNumber, OpDescription, Alternate, PartSpecific, AdjustedVolume, ToolOrder, Turret, ToolLength, OffsetNumber
FROM [Busche ToolList].dbo.[ToolList Tool];
(
-- Make sure to update ToolLists with current part numbers 
select ToolID,max(PartNumber) Part_No from [ToolList ToolPartNumber] group by ToolID
-- select count(*) from [ToolList ToolPartNumber]  -- 46,986
)

SELECT ItemID, ProcessID, Manufacturer, ToolType, ToolDescription, AdditionalNotes, Quantity, CribToolID, DetailNumber, ToolbossStock
FROM [Busche ToolList].dbo.[ToolList Fixture];

/*
	assembly_no	Tool_Assembly_Type	Description	Part_No	Revision	Operation	Tool_Assembly_Status	Include_In_Analysis	Analysis_Note	Location	update_date
1	T01	Machining	Renishaw Probe	10024895-JT	I	Machine Complete	Active	1			7/31/2020 1:51:00 PM
2	T02	Machining	4" Face Mill	10024895-JT	I	Machine Complete	Active	1			7/31/2020 2:03:00 PM
3	T03	Machining	1.25" Face Mill Cap Seats	10024895-JT	I	Machine Complete	Active	1			7/31/2020 2:07:00 PM
4	T04	Machining	M12 Tap Drill 35MM DOC	10024895-JT	I	Machine Complete	Active	1			7/31/2020 2:10:00 PM
5	T05	Machining	M12 TAP DRILL 38.5MM DOC
*/    