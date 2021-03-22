/*
 * Create Tool List Plex Mapping
 */
-- truncate table TL_Plex_PN_Op_Map_Plant6 
CREATE TABLE [Busche ToolList].dbo.TL_Plex_PN_Op_Map_Plant6 (
	ProcessID int NULL,
	TL_Part_No nvarchar(50) NULL,
	Plex_Part_No varchar(8) NOT NULL,
	Revision varchar(1) NOT NULL,
	Operation_Code varchar(16) NOT NULL
);
insert into TL_Plex_PN_Op_Map_Plant6 
values
-- The following tool list has already been added to plex.
-- (61748,'10103355','10103355','A','Machine A - WIP')  -- 10103355H DANA P558 6K LH Horizontal  Done
-- (54479,'10103355','10103355','A','Final')  -- 10103355H DANA P558 6K LH - Vertical - Done, 02/10/21
-- (54536,'10103344','10103344','A','Final')  -- DANA - 10103344 P558 7K RH KNUCKLE - 2ND OP VERTICAL MILL
-- (62576,'10103344','10103344','A','Machine A - WIP')  -- 62576|DANA    |10103344H P558 7K RH KNUCKLE|10103344H |1ST OP HORIZONTAL MILL|
-- (61747,'10103353','10103353','A','Machine A - WIP')  -- 61747|DANA    |10103353H P558 6K RH    |10103353  |MILL COMPLETE  
-- (54480,'10103353','10103353','A','Final')  -- 54480|DANA    |10103353 DANA 6K RH VERT|10103353  |MILL COMPLETE   
-- (54480,'10103351','10103351','A','Final')  -- 28080|    54533|DANA    |10103351 P558 7K LH KNUCKLE |10103351  |2ND OP VERTICAL MILL  
-- which tool list, i asked Jason, and he wants the latest imported, which would be 61763
-- (54529,'10103351H','10103344','A','Machine A - WIP')  -- 62576|DANA    |10103344H P558 7K RH KNUCKLE|10103344H |1ST OP HORIZONTAL MILL|
-- (61763,'10103351H','10103344','A','Machine A - WIP')  -- 62576|DANA    |10103344H P558 7K RH KNUCKLE|10103344H |1ST OP HORIZONTAL MILL|
-- (50531,'2007669','2007669','C','Machine A - WIP')  -- 734|    50531|USM     |2007669 7K KING PIN YOKE|2007669   |1ST OP MILL
(50532,'2007669','2007669','C','Machine Complete')  -- 188|    50532|USM     |2007669 7K KING PIN YOKE|2007669   |2ND OP MILL         


select * from TL_Plex_PN_Op_Map_Plant6


select 
tl.originalProcessid,
tl.processid,
tl.customer,tl.partfamily,
tl.partNumber,tl.OperationDescription,
'PlexPartNumber' PlexPartNumber,
'PlexRevision' PlexRevision,
'PlexOperationCode' PlexOperationCode,
tl.plant 
-- select *
from bvToolListsInPlants tl
where plant = 6
and partnumber like '2007669%'
order by tl.customer,tl.partfamily,tl.partNumber 
-- R559432,R218919
select Originalprocessid,* from [ToolList Master] tm where processid in (54529,
61763)
select originalprocessid,* from [ToolList Master] 
-- where partFamily like '%R559432%'
where partFamily like '%R218919%'

select top 10 * from btDistinctToolLists

select * from bvToolListsAssignedPN

select * 
-- into PlexToolListAssemblyTemplatePlant6_6K_Knuckles_Wip
from PlexToolListAssemblyTemplatePlant6

-- drop table PlexToolListAssemblyTemplatePlant6
-- truncate table PlexToolListAssemblyTemplatePlant6
create table PlexToolListAssemblyTemplatePlant6
(
	ProcessID int NOT NULL,
	ToolID int NOT NULL,
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

insert into PlexToolListAssemblyTemplatePlant6 (ProcessID,ToolID,ToolNumber,Assembly_No,Tool_Assembly_Type,Description,Part_No,Part_Revision,Operation,Tool_Assembly_Status,Include_In_Analysis,Analysis_Note,Note,Location)
	select 
	tl.ProcessID,
	tl.ToolID,
	tl.ToolNumber,
	case 
	when ((tl.CellIndex <> 0) and (tl.ToolCount>1)) then substring(tl.Assembly_No + '-' + tl.Cell + '-' + tl.OperationDescription,1,50)
	else substring(tl.Assembly_No + '-' + tl.OperationDescription,1,50) 
	end Assembly_No,
	tl.Tool_Assembly_Type,
	tl.Description,tl.Part_No,tl.Part_Revision,tl.Operation,tl.Tool_Assembly_Status,tl.Include_In_Analysis,tl.Analysis_Note,tl.Note,tl.Location 
	from 
	(
		select
		tl.processid, 
		tt.ToolID,
		tt.ToolNumber,
		tc.ToolCount,
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
		-- select tl.*
		from bvToolListsInPlants tl
		inner join [ToolList Tool] tt  
		on tl.processid = tt.ProcessID
		inner join TL_Plex_PN_Op_Map_Plant6 m 
		on tl.processid = m.processid  
		-- order by tt.toolnumber
		left outer join 
		(
			select tl.processid,tt.ToolNumber, count(*) toolCount
			from bvToolListsInPlants tl
			inner join [ToolList Tool] tt  
			on tl.processid = tt.ProcessID
			inner join TL_Plex_PN_Op_Map_Plant6 m 
			on tl.processid = m.processid  
			group by tl.processid,tt.ToolNumber 
			having count(*) > 1	-- 0	
		) tc 
		on tl.processid = tc.processid 
		and tt.toolNumber = tc.ToolNumber
		-- ONLY FOR TOOLLISTS THAT ARE IN MULTIPLE PLANTS
		where tl.Plant = 6
	)tl  
	order by Assembly_No
	-- 15 rows 1 through 21 / 90 items
	-- where tl.Part_No = '28245973' 

	select count(*) from PlexToolListAssemblyTemplatePlant6 -- 1
	select * from PlexToolListAssemblyTemplatePlant6 -- 1
	/*
 * For each ToolList create a TF Assembly.
 */
insert into PlexToolListAssemblyTemplatePlant6 
(ProcessID,ToolID,ToolNumber,Assembly_No,Tool_Assembly_Type,Description,Part_No,Part_Revision,Operation,Tool_Assembly_Status,Include_In_Analysis,Analysis_Note,Note,Location)
select 
/*
m.Plex_Part_No,
m.revision,
m.Operation_Code,
'TF-' + tl.OperationDescription Assembly_No1,
m.Plex_Part_No,
*/
tl.processid,
111111 ToolID,
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
inner join TL_Plex_PN_Op_Map_Plant6 m  
on tl.processid = m.processid  -- 27
-- ONLY FOR TOOLLISTS THAT ARE IN MULTIPLE PLANTS
-- where tl.Plant = 6

select count(*) from PlexToolListAssemblyTemplatePlant6 -- 2
select * from PlexToolListAssemblyTemplatePlant6 -- 2


/*
 * For each ToolList create a TM Miscellaneous Assembly.
 */
insert into PlexToolListAssemblyTemplatePlant6 (ProcessID,ToolID,ToolNumber,Assembly_No,Tool_Assembly_Type,Description,Part_No,Part_Revision,Operation,Tool_Assembly_Status,Include_In_Analysis,Analysis_Note,Note,Location)
-- delete from PlexToolListAssemblyTemplateAvilla where ToolNumber = 222222	
select 
tl.processid,
222222 ToolID,
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
inner join TL_Plex_PN_Op_Map_Plant6 m 
on tl.processid = m.processid  -- 27
-- ONLY FOR TOOLLISTS THAT ARE IN MULTIPLE PLANTS
where tl.Plant = 6

select count(*) from PlexToolListAssemblyTemplatePlant6-- 3
select * from PlexToolListAssemblyTemplatePlant6-- 3
where Part_No = '28245973'


select * from TL_Plex_PN_Op_Map_Plant6

/*
 * Plex ToolAssembly Template
 */
select * from PlexToolListAssemblyTemplatePlant6
-- where Part_No != '28245973' 
order by Part_No,Operation,Assembly_No 

select Assembly_No,Tool_Assembly_Type,substring(Description,1,50) Description,Part_No,Part_Revision,Operation,
Tool_Assembly_Status,Include_In_Analysis,Analysis_Note,Note,Location
from PlexToolListAssemblyTemplatePlant6
-- where Part_No != '28245973' 
order by Part_No,Operation,Assembly_No 



/*
 *  Test
 * 
 */
select Assembly_No,Tool_Assembly_Type,Description,Part_No,Part_Revision,Operation,
Tool_Assembly_Status,Include_In_Analysis,Analysis_Note,Note,Location
from PlexToolListAssemblyTemplatePlant6
-- where Part_No = '28245973' 
-- and Assembly_No like '%1ST%'
-- and Assembly_No like '%2ND%'
-- and Assembly_No like '%3RD%'
order by Operation,Assembly_No 


select Assembly_No,Tool_Assembly_Type,Description,Part_No,Part_Revision,Operation,
Tool_Assembly_Status,Include_In_Analysis,Analysis_Note,Note,Location
from PlexToolListAssemblyTemplatePlant6
-- where Part_No = '28245973' 
-- and Assembly_No like '%1ST%'
-- and Assembly_No like '%2ND%'
-- and Assembly_No like '%3RD%'
order by Operation,Assembly_No 
/* 3rd
 * descript                                    |ToolNumber|OpDescription                
--------------------------------------------|----------|-----------------------------
DELPHI - 26090196 PITMAN SHAFT - 3RD OP MILL|         1|MILL OUTSIDE TEETH AND KEYWAY
DELPHI - 26090196 PITMAN SHAFT - 3RD OP MILL|         3|CUT INSIDE TEETH       

1st
DELPHI - 26090196L PITMAN SHAFT - 1ST OP LATHE|         1|FACE AND FINISH OD
DELPHI - 26090196L PITMAN SHAFT - 1ST OP LATHE|         3|ROUGH DRILL HOLE  
DELPHI - 26090196L PITMAN SHAFT - 1ST OP LATHE|        11|DRILL 1/2" HOLE   
DELPHI - 26090196L PITMAN SHAFT - 1ST OP LATHE|         7|BORE ID PROFILE   
DELPHI - 26090196L PITMAN SHAFT - 1ST OP LATHE|         9|THREAD ID         

2nd
DELPHI - 26090196L PITMAN SHAFT - 2ND OP LATHE|         3|THREAD OD              
DELPHI - 26090196L PITMAN SHAFT - 2ND OP LATHE|         4|CENTER DRILL           
DELPHI - 26090196L PITMAN SHAFT - 2ND OP LATHE|         1|TURN GEAR OD ROUGH FACE
DELPHI - 26090196L PITMAN SHAFT - 2ND OP LATHE|         2|FACE AND FINISH OD     
                  
 */

select * from TL_Plex_PN_Op_Map_Plant6
where Plex_Part_No = '26090196' 
--	where ProcessID = 56673  -- Final
--	where ProcessID = 62568 -- Machine B - WIP
-- where ProcessID = 56675 -- Machine B - WIP
-- where Plex_Part_No = '28245973'
--	where ProcessID = 56679  -- Machine Complete
--	where ProcessID = 61581 -- Machine B - WIP
-- where ProcessID = 62019 -- Machine B - WIP
-- select * from toolitems
select 
tl.descript,
tt.ToolNumber,
tt.OpDescription
-- tl.descript, tt.*
from bvToolListsInPlants tl
inner join [ToolList Tool] tt  -- 307
on tl.processid = tt.ProcessID
-- where Plex_Part_No = '26090196' 
-- where tl.ProcessID = 56673  -- Final  -- 3RD OP MILL
--	where tl.ProcessID = 62568 -- Machine B - WIP  -- 1st
 where tl.ProcessID = 56675 -- Machine B - WIP
-- where Plex_Part_No = '28245973'
-- where tl.ProcessID = 56679  -- Machine Complete
-- where tl.ProcessID = 62019 -- Machine B - WIP
-- where tl.ProcessID = 61581 -- Machine B - WIP
and tt.ToolNumber = 9
/*
 * where tl.ProcessID = 61581 -- Machine B - WIP
 * DELPHI - 28245973L PITMAN SHAFT - 1ST OP LATHE	11	THREAD I.D.-CELL 3
DELPHI - 28245973L PITMAN SHAFT - 1ST OP LATHE	9	ROUGH DRILL HOLE-CELL 3
DELPHI - 28245973L PITMAN SHAFT - 1ST OP LATHE	1	FACE AND FINISH OD
DELPHI - 28245973L PITMAN SHAFT - 1ST OP LATHE	7	BORE ID PROFILE-CELL 3
DELPHI - 28245973L PITMAN SHAFT - 1ST OP LATHE	5	DRILL 1/2" HOLE
DELPHI - 28245973L PITMAN SHAFT - 1ST OP LATHE	9	THREAD I.D.-CELL 2
DELPHI - 28245973L PITMAN SHAFT - 1ST OP LATHE	11	ROUGH DRILL HOLE-CELL 2
DELPHI - 28245973L PITMAN SHAFT - 1ST OP LATHE	3	BORE ID PROFILE-CELL 2
 */
/*
 * where tl.ProcessID = 62019 -- Machine B - WIP
 * DELPHI - 28245973L PITMAN SHAFT - 2ND OP LATHE	3	THREAD OD
 * DELPHI - 28245973L PITMAN SHAFT - 2ND OP LATHE	2	FACE AND FINISH OD
 * DELPHI - 28245973L PITMAN SHAFT - 2ND OP LATHE	4	CENTER DRILL
 * DELPHI - 28245973L PITMAN SHAFT - 2ND OP LATHE	6	FACE IDENTIFICATION GROOVE
 * DELPHI - 28245973L PITMAN SHAFT - 2ND OP LATHE	1	TURN GEAR OD ROUGH FACE/OD
 */
/*
 * where tl.ProcessID = 56679  -- Machine Complete
 * DELPHI - 28245973 PITMAN SHAFT - 3RD OP MILL	3	CUT INSIDE TEETH
 * DELPHI - 28245973 PITMAN SHAFT - 3RD OP MILL	1	MILL OUTSIDE TEETH AND KEYWAY
*/
