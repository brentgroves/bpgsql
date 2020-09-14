-- TL_Plex_PN_Op_Map

select * from TL_Plex_PN_Op_Map 
-- truncate table TL_Plex_PN_Op_Map
CREATE TABLE [Busche ToolList].dbo.TL_Plex_PN_Op_Map (
	ProcessID int NOT NULL,
	Plex_Part_No varchar(100) NOT NULL,
	Revision varchar(8) NOT NULL,
	Operation_Code	varchar (30) NOT NULL
);
select * 
--update dbo.TL_Plex_PN_Op_Map 
-- set Revision = '02'  -- 	Machine B - WIP
 set Operation_Code = 'Machine B - WIP'
-- select * 
from dbo.TL_Plex_PN_Op_Map m  
-- where Plex_Part_No = '10024896-JT'
where Plex_Part_No like '%5K651%'
where Plex_Part_No = '6788776'
and Operation_Code = 'Machine A-WIP'
processid	Plex_Part_No	Plex_Revision	Plex_Operation  -- 50542 --7614013080
insert into TL_Plex_PN_Op_Map (ProcessID,Plex_Part_No,Revision,Operation_Code)
-- values (62516,'10024895-JT','I','Machine B - WIP')
-- values (62517,'10024896-JT','I','Machine B - WIP')
-- values (61785,'10041563','H','Final')
-- values (61786,'10041881','H','Final')
-- values (62520,'10047275','D','Final')
-- values (62521,'10049132','D','Final') 
-- values (50676,'10066950','A','Final')
-- values (50018,'10099858','A','Final')
-- values (62428,'10099858','A','Final')

-- values (51919,'10099860','A','Final')
-- values (62432,'10099860','A','Final')
-- values (56692,'6654026981','A','Final')
-- values (56693,'6674013781','A','Final')
-- values (56694,'6674013781','A','Final')
-- values (62421,'6788776','02','Machine A-WIP')
-- values (62422,'6788776','02','Machine A-WIP')
-- values (62423,'6788776','02','Final')
-- values (54614,'68480625AA','002B','Final')

-- values (58931,'7614013080','E2','Final')
-- values (58930,'7614013080','E2','Final')
-- values (61290,'LB5C-5K651-BF','G8','Machine Complete')
-- values (61291,'LB5C-5K652-BF','G8','Machine Complete')
-- values (61258,'LC5C 5K651 CE','F6','Final')  -- LC5C-5K651-CE DOES NOT EXIST IN PLEX  = LC5C 5K651 CE
-- values (61257,'LC5C-5K652-CE','F6','Final')
-- values (61254,'W10751752','E','Final')
-- values (61255,'W10751752','E','Final')
-- values (55977,'W10751752','E','Final')
-- values (61673,'W11033021','E','Final')
-- values (56546,'W11033021','E','Final')
-- values (55927,'W11033021','E','Final')

-- 12|    55976|68480624AA JL RH ENGINE BRACKET|             60|MILL COMPLETE -- is not released

56546|W11033021L Y 1st op lathe
55927|W11033021L Y 2nd op lathe
61673|W11033021 Y 3rd op mill

54192|W11033021  N 3rd & 4th op Horizontal Mill  --obolete, not on list  -- Plant 7
62099|W11033021L N 4th cell, 1st op lathe  -- obsolete,not on list  -- Plant 12
62108|W11033021L N 4th cell, 2nd op lathe  -- obsolete not on list  -- Plant 12

select 
-- p.plant,
tm.* 
FROM [ToolList Master] tm 
inner join [ToolList PartNumbers] n 
on tm.processid=n.processid
where partNumbers like 'SAT39685%'

inner join [ToolList Plant] p 
on tm.processid=p.processid

select * from dbo.TL_Plex_PN_Op_Map where Plex_Part_No = 'LC5C-5K652-CE'
-- update dbo.TL_Plex_PN_Op_Map 
set Operation_Code = 'Final'
where Plex_Part_No = 'LC5C-5K652-CE'

select tl.processid,tl.customer,tl.partfamily,tl.OperationDescription,
tl.partNumber TL_Part_No,m.Plex_Part_No,m.Revision
from dbo.bvToolListsInPlants tl 
left outer join TL_Plex_PN_Map m 
on tl.partNumber = m.TL_Part_No
where plant = '12'
order by m.Plex_Part_No,m.Revision 

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