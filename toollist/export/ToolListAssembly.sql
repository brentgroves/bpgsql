-- Busche Tool List

-- Assembly No,Tool Assembly Type,Description,Part No,Part Revision,Operation,Tool Assembly Status,Include in Analysis,Analysis Note,Note,Location
create table
(
Assembly_No	varchar (50), --Assembly No,
Tool_Assembly_Type	varchar (50), --Tool Assembly Type,
Description	varchar (100), --Description,
Part_No	varchar (100), --Part No,
Revision	varchar (8), --Part Revision,
Operation_Code	varchar (30), --Operation,
Tool_Assembly_Status	varchar (50),  --Tool Assembly Status
Include_In_Analysis smallint,  --Include in Analysis
Analysis_Note	varchar (500), --Analysis Note,
Note	varchar (500), -- Note,
Location varchar (5) --	I don't know what this is 
)
select 
tl.partNumber, -- This is old.  Map a part number,revision,and operation to each processID
case 
	when tt.ToolNumber < 10 then 'T0' + cast(tt.ToolNumber as varchar(3))
	else 'T' + cast(tt.ToolNumber as varchar(3)) 
end Assembly_No,
'Machining' Tool_Assembly_Type,
tt.OpDescription Description,
-- tl.partNumber,  -- This is the location for the import file.
'1' Part_Revision, -- This is old.  Map a Plex part number,revision,and operation to each processID; 
'Machine Complete' Operation,
'Active' Tool_Assembly_Status,
1 Include_In_Analysis,
'' Note,
'' Location
-- select * 
from dbo.bvToolListsInPlants tl  -- 30
--where tl.processid = 56730
left outer join [ToolList Tool] tt  -- 307
on tl.processid = tt.ProcessID
where tl.plant = '12'
order by tl.partNumber,tt.ToolNumber
-- FROM [Busche ToolList].dbo.[ToolList Tool] tt;

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
(
select 
tl.processid,
tl.descript,
tl.partNumber 
-- select count(*)  --
-- select tl.processid 
from dbo.bvToolListsInPlants tl  -- 30
--where tl.processid = 56730
left outer join [ToolList Tool] tt  -- 307
on tl.processid = tt.ProcessID
where tl.plant = '12'
-- and tt.processID is null  -- 0
)
i
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