-- Busche Tool List

-- Assembly No,Tool Assembly Type,Description,Part No,Part Revision,Operation,Tool Assembly Status,Include in Analysis,Analysis Note,Note,Location

select  
Assembly_No,Tool_Assembly_Type,Description,Part_No,Part_Revision,Operation,Tool_Assembly_Status,Include_In_Analysis,Analysis_Note,Note,Location
-- select * 
-- update PlexToolListAssemblyTemplate
-- set Operation = 'Machine A - WIP'
from PlexToolListAssemblyTemplate tl  -- 367
-- where Part_No = '6788776' and Operation = 'Machine A-WIP'
-- where Part_No = '10024895-JT' and Operation = 'Machine B-WIP'
-- 61258|FORD - LC5C-5K651-CC CD6 CONTROL ARM - MILL COMPLETE  -- CAN'T FIND THIS IN PLEX
where processid <> 61748  -- 353
order by tl.Part_No,tl.Part_Revision,tl.Operation,tl.Assembly_No


select processid,partNumber 
-- descript,partNumber 
from bvToolListsInPlants tl
where Plant = 11  -- 39
order by descript


where processid = 61258  -- 353
where partnumber like 'LC5C%'
-- 	Machine B - WIP
/* All item numbers for tool list make sure they are in plex */
select 
distinct '(''' + itemNumber + '''),'
from dbo.bvToolListItemsLv1 
where processid = 62615

select tl.processid,tt.ToolNumber, count(*) toolCnt
from bvToolListsInPlants tl
inner join [ToolList Tool] tt  -- 307
on tl.processid = tt.ProcessID
inner join TL_Plex_PN_Op_Map_Avilla m 
on tl.processid = m.processid  -- 307
group by tl.processid,tt.ToolNumber 
having count(*) > 1
/*
-- truncate table PlexToolListAssemblyTemplate
-- drop table PlexToolListAssemblyTemplate
create table PlexToolListAssemblyTemplateAvilla
(
	ProcessID int NOT NULL,
	ToolNumber int NOT NULL,
	Assembly_No	varchar (50), --Assembly No,
	Tool_Assembly_Type	varchar (50), --Tool Assembly Type,
	Description	varchar (100), --Description,
	Part_No	varchar (100), --Part No,
	Part_Revision varchar (8), --Part Revision,
	Operation	varchar (30), --Operation_Code in Plex,
	Tool_Assembly_Status	varchar (50),  --Tool Assembly Status
	Include_In_Analysis smallint,  --Include in Analysis
	Analysis_Note	varchar (500), --Analysis Note,
	Note	varchar (500), -- Note,
	Location varchar (5) --	I don't know what this is 
)
select * from PlexToolListAssemblyTemplate  -- 15
*/
-- Assembly No,Tool Assembly Type,Description,Part No,Part Revision,Operation,Tool Assembly Status,Include in Analysis,Analysis Note,Note,Location
-- truncate table PlexToolListAssemblyTemplateAvilla
insert into PlexToolListAssemblyTemplateAvilla (ProcessID,ToolNumber,Assembly_No,Tool_Assembly_Type,Description,Part_No,Part_Revision,Operation,Tool_Assembly_Status,Include_In_Analysis,Analysis_Note,Note,Location)
	select 
	-- ag.Count_PN_Rev_Assembly_No, tl.OperationDescription, 
	-- tl.Part_No,tl.Part_Revision,tl.Operation,
	/*
	case 
		when ag.Count_PN_Rev_Assembly_No > 1 then tl.Assembly_No + '-' + tl.OperationDescription 
		else tl.Assembly_No
	end Assembly_No,
	*/
	tl.ProcessID,
	tl.ToolNumber,
	case 
	when ((tl.CellIndex <> 0) and (tl.ToolCount>1)) then substring(tl.Assembly_No + '-' + tl.Cell + '-' + tl.OperationDescription,1,50)
	else substring(tl.Assembly_No + '-' + tl.OperationDescription,1,50) 
	end Assembly_No,
	-- tl.Assembly_No + '-' + tl.OperationDescription Assembly_No,
	tl.Tool_Assembly_Type,
	tl.Description,tl.Part_No,tl.Part_Revision,tl.Operation,tl.Tool_Assembly_Status,tl.Include_In_Analysis,tl.Analysis_Note,tl.Note,tl.Location 
	-- select count(*) cnt  -- 307
	from 
	(
		select
		tl.processid, 
		tt.ToolNumber,
		tc.ToolCount,
/*
 * ADD TO CASE STATEMENT
 * T09-CELL2-1ST OP LATHE
	T09-CELL3-1ST OP LATHE
	T11-CELL2 1ST OP LATHE
	T11-CELL3 1ST OP LATHE
case 
when tl.Part_No
 */
		
		case 
			when (tt.ToolNumber < 10) then 'T0' + cast(tt.ToolNumber as varchar(3)) 
			when (tt.ToolNumber >= 10) then 'T' + cast(tt.ToolNumber as varchar(3))
		end Assembly_No,
		tl.OperationDescription,
		'Machining' Tool_Assembly_Type,
		tt.OpDescription Description,
		-- tl.PartNumber,
		CHARINDEX('CELL', tt.OpDescription) CellIndex,
		substring(tt.OpDescription,CHARINDEX('CELL', tt.OpDescription),6) Cell,

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
		inner join TL_Plex_PN_Op_Map_Avilla m 
		on tl.processid = m.processid  -- 307
		left outer join 
		(
			select tl.processid,tt.ToolNumber, count(*) toolCount
			from bvToolListsInPlants tl
			inner join [ToolList Tool] tt  -- 307
			on tl.processid = tt.ProcessID
			inner join TL_Plex_PN_Op_Map_Avilla m 
			on tl.processid = m.processid  -- 307
			group by tl.processid,tt.ToolNumber 
			having count(*) > 1		
		) tc 
		on tl.processid = tc.processid 
		and tt.toolNumber = tc.ToolNumber
	)tl  -- 305

	where tl.Part_No = '28245973' 
--	and operation = 'Machine Complete' -- 4, OK
and tl.OperationDescription like '%1ST OP%' 
order by tl.Assembly_No

 and operation = 'Machine B - WIP'
--	and Assembly_No like '%2ND OP%' -- 5
	and Assembly_No like '%1ST OP%' -- 5
	order by Operation, Assembly_No

	select * from TL_Plex_PN_Op_Map_Avilla
	where Plex_Part_No = '28245973'
--	where ProcessID = 56679  -- Machine Complete
--	where ProcessID = 61581 -- Machine B - WIP
	where ProcessID = 62019 -- Machine B - WIP
	-- where Plex_Part_No = '26090196'
	-- where ProcessID = 56673  -- Machine Complete
	-- where ProcessID = 62568 -- Machine B - WIP
	-- where ProcessID = 56675 -- Machine B - WIP
	-- where tl.Part_No = '6788776'
	select tl.descript, tt.*
	from bvToolListsInPlants tl
	inner join [ToolList Tool] tt  -- 307
	on tl.processid = tt.ProcessID
--	where tl.ProcessID = 62019 -- Machine B - WIP
	--	where tl.ProcessID = 56679  -- Machine Complete
	where tl.ProcessID = 61581 -- Machine B - WIP
	and tt.ToolNumber = 9
/*
 2nd op lathe
	where ProcessID = 62019 -- Machine B - WIP
3	THREAD OD
2	FACE AND FINISH OD
4	CENTER DRILL
6	FACE IDENTIFICATION GROOVE
1	TURN GEAR OD ROUGH FACE/OD
 */
	select 
	-- part_no,part_revision,operation,assembly_no, count(*)
	--  Part_No,Part_Revision,Operation, Assembly_No,Description 
	-- count(*) cnt
	from PlexToolListAssemblyTemplateAvilla tl  -- 305
	group by part_no,part_revision,operation,assembly_no
	having count(*) > 1
	where 
	where Part_No = '28245973' 
--	and operation = 'Machine Complete' -- 4, OK
 and operation = 'Machine B - WIP'
	and Assembly_No like '%2ND OP%' -- 5
--	and Assembly_No like '%1ST OP%' -- 5
	order by Operation, Assembly_No

	/*
	 * 	varchar (50)
1st op lathe
	where tl.ProcessID = 61581 -- Machine B - WIP
11	THREAD I.D.-CELL 3
9	ROUGH DRILL HOLE-CELL 3
1	FACE AND FINISH OD
7	BORE ID PROFILE-CELL 3
5	DRILL 1/2" HOLE
9	THREAD I.D.-CELL 2
11	ROUGH DRILL HOLE-CELL 2
3	BORE ID PROFILE-CELL 2
 */	
	select 
	Part_No,Part_Revision,Operation, Assembly_No,Description 
	-- count(*) cnt
	from PlexToolListAssemblyTemplateAvilla tl  -- 331
	where Part_No = '28245973' 
	order by Operation, Assembly_No

--	and operation = 'Machine Complete' -- 4, OK
 and operation = 'Machine B - WIP'
--	and Assembly_No like '%2ND OP%' -- 5
	and Assembly_No like '%1ST OP%' -- 5
	order by Operation, Assembly_No

		/*
3rd op mill
 * 	where ProcessID = 56679  -- Machine Complete
3	CUT INSIDE TEETH
1	MILL OUTSIDE TEETH AND KEYWAY
 */	
	select 
	Part_No,Part_Revision,Operation, Assembly_No,Description 
	-- count(*) cnt
	from PlexToolListAssemblyTemplateAvilla tl  -- 331
	where Part_No = '28245973' 
	and operation = 'Machine Complete' -- 4, OK
 and operation = 'Machine B - WIP'
--	and Assembly_No like '%2ND OP%' -- 5
	and Assembly_No like '%1ST OP%' -- 5
	order by Operation, Assembly_No

	select Assembly_No,Tool_Assembly_Type,
  	SUBSTRING(REPLACE(rtrim(Description), CHAR(216),''),1,50) Description,
	-- Description,
	Part_No,Part_Revision,Operation,Tool_Assembly_Status,Include_In_Analysis,Analysis_Note,Note,Location
	from PlexToolListAssemblyTemplateAvilla tl  -- 367
	where Part_No = '28245973' 
	order by Assembly_No
/*
 * 
 */
--	where tl.ProcessID = 61581 -- Machine B - WIP
--	where tl.ProcessID = 62019 -- Machine B - WIP

	-- where tl.ProcessID = 56673 -- Machine Complete
	-- where tl.ProcessID = 62568 -- Machine B - WIP
	-- where tl.ProcessID = 56675 -- Machine B - WIP
/*	
where tl.ProcessID = 56673 
3rd op mill / Machine Complete
1 MILL OUTSIDE TEETH AND KEYWAY
3 CUT INSIDE TEETH
*/
/*
1st op lathe / Machine B - WIP
1	FACE AND FINISH OD
3	ROUGH DRILL HOLE
11	DRILL 1/2" HOLE
7	BORE ID PROFILE
9	THREAD ID
*/
/*
 * 2nd op lathe / Machine B - WIP
3	THREAD OD
4	CENTER DRILL
1	TURN GEAR OD ROUGH FACE
2	FACE AND FINISH OD 
 * 
 */
	select Assembly_No,Tool_Assembly_Type,Description,Part_No,Part_Revision,Operation,
Tool_Assembly_Status,Include_In_Analysis,Analysis_Note,Note,Location
from PlexToolListAssemblyTemplateAvilla
where Part_No = '28245973' 
and Assembly_No like '%1ST%'
order by Operation,Assembly_No 

	select 
	Part_No,Part_Revision,Operation, Assembly_No,Description 
	-- count(*) cnt
	from PlexToolListAssemblyTemplateAvilla tl  -- 331
	-- where Part_No = '68285992AF'

	where Part_No = '26090196' 
--	and operation = 'Machine Complete' -- 4, OK
 and operation = 'Machine B - WIP'
--	and Assembly_No like '%2ND OP%' -- 5
	and Assembly_No like '%1ST OP%' -- 5
	order by Operation, Assembly_No
	
	
	
	order by Part_No,Part_Revision,Operation,Assembly_No

	select Part_No,Part_Revision, Assembly_No, Operation from PlexToolListAssemblyTemplate tl
	-- where tl.Part_No = '6788776'
	order by tl.Part_No,tl.Part_Revision,tl.Assembly_No,tl.Operation
SELECT * FROM TL_Plex_PN_Op_Map_Avilla
	select * from PlexToolListAssemblyTemplate
/*
 * For each ToolList create a TF Assembly.
 */
insert into PlexToolListAssemblyTemplate (ProcessID,ToolNumber,Assembly_No,Tool_Assembly_Type,Description,Part_No,Part_Revision,Operation,Tool_Assembly_Status,Include_In_Analysis,Analysis_Note,Note,Location)
	
select 
/*
m.Plex_Part_No,
m.revision,
m.Operation_Code,
'TF-' + tl.OperationDescription Assembly_No1,
*/

tl.processid,
111111 ToolNumber,
'TF-' + tl.OperationDescription Assembly_No,
'Machining' Tool_Assembly_Type,
'Fixture' Description,
m.Plex_Part_No Part_No,
m.Revision Part_Revision,
m.Operation_Code Operation,
'Active' Tool_Assembly_Status,
1 Include_In_Analysis,
'' Analysis_Note,
'' Note,
'' Location
-- m.Plex_Part_No Part_No,m.Revision Part_Revision,m.Operation_Code Operation,tl.OperationDescription 
from bvToolListsInPlants tl
inner join TL_Plex_PN_Op_Map m 
on tl.processid = m.processid  -- 30
order by part_no,part_revision,assembly_no
where m.Plex_Part_No = '6788776'

/*
 * For each ToolList create a TM Miscellaneous Assembly.
 */
select * from PlexToolListAssemblyTemplate
select distinct part_no,Part_Revision from PlexToolListAssemblyTemplate  -- 20
insert into PlexToolListAssemblyTemplate (ProcessID,ToolNumber,Assembly_No,Tool_Assembly_Type,Description,Part_No,Part_Revision,Operation,Tool_Assembly_Status,Include_In_Analysis,Analysis_Note,Note,Location)
	
select 
tl.processid,
222222 ToolNumber,
'TM-' + tl.OperationDescription Assembly_No,
'Machining' Tool_Assembly_Type,
'Miscellaneous' Description,
m.Plex_Part_No Part_No,
m.Revision Part_Revision,
m.Operation_Code Operation,
'Active' Tool_Assembly_Status,
1 Include_In_Analysis,
'' Analysis_Note,
'' Note,
'' Location
-- m.Plex_Part_No Part_No,m.Revision Part_Revision,m.Operation_Code Operation,tl.OperationDescription 
from bvToolListsInPlants tl
inner join TL_Plex_PN_Op_Map m 
on tl.processid = m.processid  -- 307
where m.Plex_Part_No = '6788776'

-- select count(*) cnt from PlexToolListAssemblyTemplate tl  -- 367
-- delete from PlexToolListAssemblyTemplate where Assembly_No like 'TM%'
	select Assembly_No,Tool_Assembly_Type,
  	SUBSTRING(REPLACE(rtrim(Description), CHAR(216),''),1,50) Description,
	-- Description,
	Part_No,Part_Revision,Operation,Tool_Assembly_Status,Include_In_Analysis,Analysis_Note,Note,Location
	from PlexToolListAssemblyTemplateAvilla tl  -- 367
	where Part_No = '28245973' 

	-- where Part_No like 'LC5C%'
	order by tl.Part_No,tl.Part_Revision,tl.Operation,tl.Assembly_No
	
	select * from PlexToolListAssemblyTemplate tl  
	-- where tl.Part_No like 'LC5C%'
	where tl.Part_No like '%ML3V%' -- waiting for JOSH to release these
-- FROM [Busche ToolList].dbo.[ToolList Tool] tt;
-- select * FROM [Busche ToolList].dbo.[ToolList Master] 
-- select * from [ToolList PartNumbers] n where partNumbers like 'W11033021%'
select tm.* 
FROM [ToolList Master] tm 

inner join [ToolList PartNumbers] n 
on tm.processid=n.processid

where partNumbers like 'W11033021%'
/*
 * select * 
 * update TL_Plex_PN_Op_Map
 set Operation_Code = 'Machine A - WIP'
 from TL_Plex_PN_Op_Map m where m.plex_part_no = '6788776' and m.Operation_Code = 'Machine A-WIP'
 * order by PLex_Part_No,Revision
 * Machine A - WIP
 * select * from [ToolList Tool] tt where processID in (62421,62422,62423)
 * ProcessID|ToolNumber|OpDescription     
---------|----------|------------------
    62421|         1|CORE DRILL        
    62421|         2|ID BORE AND FACE  
    62421|         3|OD CHAMFER        
    62421|         4|ROUGH BORE AND FAC
    62422|         2|FINISH FACE       
    62422|         3|ROUGH OD AND FACE 
    62422|         4|FINISH OD         
    62423|         1|STEP DRILL        
    62423|         2|BEBURR AND CHAMFER
    
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
/*
	
create table TL_Plex_PN_Map
(
TL_Part_No	varchar (100), --Part No,
Plex_Part_No	varchar (100), --Part No,
Revision	varchar (8) --Part Revision
)

insert into TL_Plex_PN_Map (TL_Part_No,Plex_Part_No,Revision)r SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near '= '2020-09-14 00:00:00'
*/
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
-- values ('6654026981','6654026981','A')

-- delete from TL_Plex_PN_Map where TL_Part_No= '7614013080'
-- select * from TL_Plex_PN_Map order by TL_Part_No
-- FORD - LB5C-5K651- CD6 CONTROL ARM  - CD6 CONTROL

/*
 * All Assemblies for Edon ToolLists
 */
-- select distinct processid,partNumber from dbo.bvToolListsInPlants where plant = '12'  -- 30


/*
SELECT ToolID, ProcessID, ToolNumber, OpDescription, Alternate, PartSpecific, AdjustedVolume, ToolOrder, Turret, ToolLength, OffsetNumber
FROM [Busche ToolList].dbo.[ToolList Tool];
(
-- Make sure to update ToolLists with current part numbers 
select ToolID,max(PartNumber) Part_No from [ToolList ToolPartNumber] group by ToolID
-- select count(*) from [ToolList ToolPartNumber]  -- 46,986
)

SELECT ItemID, ProcessID, Manufacturer, ToolType, ToolDescription, AdditionalNotes, Quantity, CribToolID, DetailNumber, ToolbossStock
FROM [Busche ToolList].dbo.[ToolList Fixture];
*/
/*
	assembly_no	Tool_Assembly_Type	Description	Part_No	Revision	Operation	Tool_Assembly_Status	Include_In_Analysis	Analysis_Note	Location	update_date
1	T01	Machining	Renishaw Probe	10024895-JT	I	Machine Complete	Active	1			7/31/2020 1:51:00 PM
2	T02	Machining	4" Face Mill	10024895-JT	I	Machine Complete	Active	1			7/31/2020 2:03:00 PM
3	T03	Machining	1.25" Face Mill Cap Seats	10024895-JT	I	Machine Complete	Active	1			7/31/2020 2:07:00 PM
4	T04	Machining	M12 Tap Drill 35MM DOC	10024895-JT	I	Machine Complete	Active	1			7/31/2020 2:10:00 PM
5	T05	Machining	M12 TAP DRILL 38.5MM DOC
*/