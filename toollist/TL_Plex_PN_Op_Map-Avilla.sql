-- TL_Plex_PN_Op_Map
--select * into Plex_PN_Op_Map_Edon from TL_Plex_PN_Op_Map 
-- truncate table TL_Plex_PN_Op_Map_Avilla
-- drop table TL_Plex_PN_Op_Map_Avilla
CREATE TABLE [Busche ToolList].dbo.TL_Plex_PN_Op_Map_Avilla (
	ProcessID int NOT NULL,
	TL_Part_No	varchar (100), 
	Plex_Part_No varchar(100) NOT NULL,
	Revision varchar(8) NOT NULL,
	Operation_Code	varchar (30) NOT NULL
);
select * from TL_Plex_PN_Op_Map_Avilla

select * from TL_Plex_PN_Op_Map_Albion

-- '10103355','A'
select * 
from dbo.TL_Plex_PN_Op_Map_Avilla  
where Plex_Part_No = ''

truncate table TL_Plex_PN_Op_Map_Avilla
insert into TL_Plex_PN_Op_Map_Avilla (ProcessID,TL_Part_No,Plex_Part_No,Revision,Operation_Code)
values
(56673,'26090196','26090196','04E','Final'),
(62568,'26090196L','26090196','04E','Machine B - WIP'),
(56675,'26090196L','26090196','04E','Machine B - WIP'),
(56676,'26090199','26090199','04E','Final'),
(62569,'26090199L','26090199','04E','Machine B - WIP'),
(61768,'26090199L','26090199','04E','Machine B - WIP'),
(56679,'28245973','28245973','03D','Final'),  -- CHANGED THIS 
-- (56679,'28245973','28245973','03D','Machine Complete'),  -- CHANGED THIS '28245973'
(61581,'28245973L','28245973','03D','Machine B - WIP'),
(62019,'28245973L','28245973','03D','Machine B - WIP'),
(62543,'68328258AE','68328258AE','001A','Final'),
(62544,'68328259AE','68328259AE','001A','Final'),
-- (61444,'68284688AC','68285992AF','03b','Final'), -- WILL BE GONE BY JANUARY	NO PROCESS ROUTING
-- (61952,'68284689AC','68285991AF','03b','Final'), -- WILL BE GONE BY JANUARY	NO PROCESS ROUTING
(55909,'68284726AB','68285996AC','004','Final'),
(55910,'68284727AB','68285995AC','004','Final'),
-- (61446,'68288580AB','68288578AF','B5','Final'),  -- DO NOT MAKE ANYMORE
-- (61447,'68288581AB','68288579AF','B5','Final'),  -- DO NOT MAKE ANYMORE
(55913,'68302930AB','68302928AC','02B','Final'),
(55914,'68303171AB','68303171AC','01A','Final'),
(55915,'68305299AB','68305297AC','AC','Final'),
(55916,'68305300AB','68305298AC','AC','Final'),
(62917,'51211-TBA-A030-M1H','51211-TBA-A030-M1','30-M1','Machine Complete'),
(62040,'51211-TBA-A030-M1V','51211-TBA-A030-M1','30-M1','Machine Complete'),
(62918,'51216-TBA-A030-M1H','51216-TBA-A030-M1','30-M1','Machine Complete'),
(62041,'51216-TBA-A030-M1V','51216-TBA-A030-M1','30-M1','Machine Complete'),
(56858,'51211-TBC-A012-M1H','51211-TBC-A012-M1','02','Machine Complete'),
(63175,'51211-TBC-A012-M1V','51211-TBC-A012-M1','02','Machine Complete'),
(56859,'51216-TBC-A012-M1H','51216-TBC-A012-M1','02','Machine Complete'),
(63176,'51216-TBC-A012-M1V','51216-TBC-A012-M1','02','Machine Complete'),
(61442,'51393-TJB-A040-M1','51393TJB A040M1','40-M1-','Final'),
(61443,'51394-TJB-A040-M1','51394TJB A040M1','40-M1-','Final')
select * from dbo.TL_Plex_PN_Op_Map_Avilla m where m.Plex_Part_No like '28245973' 
select * from dbo.TL_Plex_PN_Op_Map_Albion
	GA - 68284688AC RH KL MCA FLCA ON-ROAD - MILL	61444	68284688AC	68285992AF	03b	Final	WILL BE GONE BY JANUARY				
	GA - 68284689AC LH KL MCA FLCA ON-ROAD - MILL	61952	68284689AC	68285991AF	03b	Final	WILL BE GONE BY JANUARY	
	GA - 68288580AC RH KL MCA FLCA LIFTED - MILL	61446	68288580AB	68288578AF	B5	Final	DO NOT MAKE ANYMORE			
	GA - 68288581AC LH KL MCA FLCA LIFTED - MILL	61447	68288581AB	68288579AF	B5	Final	DO NOT MAKE ANYMORE		
select * from dbo.TL_Plex_PN_Map where Plex_Part_No like '%10024895%'
/*
TL_Part_No|Plex_Part_No|Revision
----------|------------|--------
10024898  |10024895-JT |I       
 */

select 
-- p.plant,
n.*,tm.* 
FROM [ToolList Master] tm 
left outer join [ToolList PartNumbers] n  -- 1 to 1 
on tm.processid=n.processid
-- where tm.PartFamily like '%558%6K%LH%'  --TL = THERE ARE 3 OPERATIONS IN THE TOOL LIST
-- where tm.PartFamily like '%RDX%'  --TL = 51393-TJB-A040-M1 RH RDX COMPLIANCE BRACKET, G-Code,
where tm.processid = 56673
-- where tm.processid = 62517
-- where partNumbers like '10024895%'

inner join [ToolList Plant] p 
on tm.processid=p.processid  -- 1 to many
where p.Plant = 11
select * from dbo.TL_Plex_PN_Op_Map_Avilla tppoma

-- update dbo.TL_Plex_PN_Op_Map 
set Operation_Code = 'Final'
where Plex_Part_No = 'LC5C-5K652-CE'

select tl.processid,tl.customer,tl.partfamily,tl.OperationDescription,
tl.partNumber TL_Part_No,m.Plex_Part_No,m.Revision
from dbo.bvToolListsInPlants tl 
left outer join TL_Plex_PN_Map m 
on tl.partNumber = m.TL_Part_No
where plant = '11'
order by m.Plex_Part_No,m.Revision 

select * from TL_Plex_PN_Map m

select 
tl.*,
-- processid,descript,partNumber,
m.Plex_Part_No,m.Revision
--processid,partNumber,m.Plex_Part_No,m.Revision
from dbo.bvToolListsInPlants tl 
left outer join TL_Plex_PN_Map m 
on tl.partNumber = m.TL_Part_No
where plant = '12' and partNumber in ('10099858','10099860','6674013781','6788776L','7614013080','W10751752','W11033021L')
order by partNumber
select 
-- tl.*
processid,descript,partNumber,
m.Plex_Part_No,m.Revision
from dbo.bvToolListsInPlants tl 
left outer join TL_Plex_PN_Map m 
on tl.partNumber = m.TL_Part_No
where plant = '12' and partNumber in ('10099858','10099860','6674013781','6788776L','7614013080','W10751752','W11033021L')
order by partNumber
-- and TL_Part_No is null
-- dbo.bvToolListsInPlants source