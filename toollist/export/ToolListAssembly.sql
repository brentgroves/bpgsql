-- Busche Tool List

-- Assembly No,Tool Assembly Type,Description,Part No,Part Revision,Operation,Tool Assembly Status,Include in Analysis,Analysis Note,Note,Location
create table ToolListAssembly
(
	Assembly_No	varchar (50), --Assembly No,
	Tool_Assembly_Type	varchar (50), --Tool Assembly Type,
	Description	varchar (100), --Description,
	Part_No	varchar (100), --Part No,
	Revision	varchar (8), --Part Revision,
	Operation	varchar (30), --Operation_Code in Plex,
	Tool_Assembly_Status	varchar (50),  --Tool Assembly Status
	Include_In_Analysis smallint,  --Include in Analysis
	Analysis_Note	varchar (500), --Analysis Note,
	Note	varchar (500), -- Note,
	Location varchar (5), --	I don't know what this is 
	-- ProcessID int NOT NULL,
	-- Plex_Part_No varchar(100) NOT NULL,
	-- Revision varchar(8) NOT NULL,
	-- Operation_Code	varchar (30) NOT NULL
)
-- Assembly No,Tool Assembly Type,Description,Part No,Part Revision,Operation,Tool Assembly Status,Include in Analysis,Analysis Note,Note,Location

	select 
	-- ag.Count_PN_Rev_Assembly_No, tl.OperationDescription, 
	tl.Part_No,tl.Part_Revision,tl.Operation,
	case 
		when ag.Count_PN_Rev_Assembly_No > 1 then tl.Assembly_No + '-' + tl.OperationDescription 
		else tl.Assembly_No
	end Assembly_No,
	tl.Tool_Assembly_Type,tl.Description,tl.Part_No,tl.Part_Revision,tl.Operation,tl.Tool_Assembly_Status,tl.Include_In_Analysis,tl.Analysis_Note,tl.Note,tl.Location 
	from 
	(
		select
		tl.OperationDescription,
		case 
			when (tt.ToolNumber < 10) then 'T0' + cast(tt.ToolNumber as varchar(3)) 
			when (tt.ToolNumber >= 10) then 'T' + cast(tt.ToolNumber as varchar(3))
		end Assembly_No,
		'Machining' Tool_Assembly_Type,
		tt.OpDescription Description,
		-- tl.PartNumber,
		m.Plex_Part_No Part_No,
		m.Revision Part_Revision,
		m.Operation_Code Operation,
		'Active' Tool_Assembly_Status,
		1 Include_In_Analysis,
		'' Analysis_Note,
		'' Note,
		'' Location
		
		-- select * from bvToolListsInPlants where partNumber = '10049132' -- ,pid= 50542,  in map pid 61788
		-- select count(*) cnt
		from bvToolListsInPlants tl
		inner join [ToolList Tool] tt  -- 307
		on tl.processid = tt.ProcessID
		inner join TL_Plex_PN_Op_Map m 
		on tl.processid = m.processid  -- 307
	)tl
	inner join 
	(
		select Assembly_No,Part_No,Part_Revision,Operation,count(*) Count_PN_Rev_Assembly_No
		from 
		(
			select 
			case 
				when (tt.ToolNumber < 10) then 'T0' + cast(tt.ToolNumber as varchar(3)) 
				when (tt.ToolNumber >= 10) then 'T' + cast(tt.ToolNumber as varchar(3))
			end Assembly_No,
			m.Plex_Part_No Part_No,
			m.Revision Part_Revision,
			m.Operation_Code Operation
			-- select * from bvToolListsInPlants where partNumber = '10049132' -- ,pid= 50542,  in map pid 61788
			-- select count(*) cnt
			from bvToolListsInPlants tl
			inner join [ToolList Tool] tt  -- 307
			on tl.processid = tt.ProcessID
			inner join TL_Plex_PN_Op_Map m 
			on tl.processid = m.processid  -- 307
		)tl 
		group by Assembly_No,Part_No,Part_Revision,Operation
	)ag	
	on tl.Assembly_No=ag.Assembly_No and tl.Part_No=ag.Part_No and tl.Part_Revision=ag.Part_Revision and tl.Operation = ag.Operation 
	where tl.Part_No = '6788776'
	order by tl.Part_No,tl.Part_Revision,tl.Operation,tl.Assembly_No
-- FROM [Busche ToolList].dbo.[ToolList Tool] tt;
/*
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
 * 
62421	6788776	2	Machine A-WIP
62422	6788776	2	Machine A-WIP
62423	6788776	2	Machine Complete
 */
/* Obsolete use TL_Plex_PN_Op_Map
 * but only place that has the Busche ToolList part number
 */
create table TL_Plex_PN_Map
(
TL_Part_No	varchar (100), --Part No,
Plex_Part_No	varchar (100), --Part No,
Revision	varchar (8) --Part Revision
)

insert into TL_Plex_PN_Map (TL_Part_No,Plex_Part_No,Revision)

-- values ('6788776L','6788776','02')
-- values ('6788776V',	'6788776','02')
-- values ('10041563',	'10041563','H')
-- values ('W11033021','W11033021','E')
-- values ('W11033021L','W11033021','E')
-- values ('10041881',	'10041881','H')
-- values ('6674013781','6674013781','A')
-- values ('6654026981','6654026981','A')
-- values ('10066950',	'10066950','A')
-- values ('10047275',	'10047275','D')
-- values ('W10751752','W10751752','E')
-- values ('10049132',	'10049132','D')
-- values ('10024899',	'10024896-JT','I')
-- values ('10024898',	'10024895-JT','I')
-- values ('LB5C-5K651-BC','LB5C-5K651-BF','G8')
-- values ('LB5C-5K652-BCH','LB5C-5K652-BF','G8')
-- values ('W10751752L','W10751752','E')
--values ('W10751752','W10751752','E')
-- values ('10099858','10099858','A')
-- values ('LC5C-5K651-CC','LC5C-5K651-CE','F6')
-- values ('LC5C-5K652-CC','LC5C-5K652-CE','F6')
-- values ('68480625AA','68480625AA','002B')
-- values ('7614013080','7614013080','E2')
-- values ('10099860',	'10099860','A')
values ('6654026981','6654026981','A')

-- delete from TL_Plex_PN_Map where TL_Part_No= '7614013080'
select * from TL_Plex_PN_Map order by TL_Part_No

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