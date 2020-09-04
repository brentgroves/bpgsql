-- TL_Plex_PN_Op_Map

select processid,count(*) cnt from TL_Plex_PN_Op_Map group by processid 
CREATE TABLE [Busche ToolList].dbo.TL_Plex_PN_Op_Map (
	ProcessID int NOT NULL,
	Plex_Part_No varchar(100) NOT NULL,
	Revision varchar(8) NOT NULL,
	Operation_Code	varchar (30) NOT NULL
);
select * 
--update dbo.TL_Plex_PN_Op_Map 
set Revision = '02'
from dbo.TL_Plex_PN_Op_Map m where Plex_Part_No = '6788776'
processid	Plex_Part_No	Plex_Revision	Plex_Operation  -- 50542
insert into TL_Plex_PN_Op_Map (ProcessID,Plex_Part_No,Revision,Operation_Code)
-- values (62516,'10024895-JT','I','Machine B-WIP')
-- values (62517,'10024896-JT','I','Machine B-WIP')
-- values (61785,'10041563','H','Machine Complete')
-- values (61786,'10041881','H','Machine Complete')
-- values (62520,'10047275','D','Machine Complete')
-- values (62521,'10049132','D','Machine Complete') 
-- values (50676,'10066950','A','Machine Complete')
-- values (50018,'10099858','A','Machine Complete')
-- values (62428,'10099858','A','Machine A-WIP')
-- values (51919,'10099860','A','Machine Complete')
-- values (62432,'10099860','A','Machine A-WIP')
-- values (56692,'6654026981','A','Machine Complete')
-- values (56693,'6674013781','A','Machine A-WIP')
-- values (56694,'6674013781','A','Machine Complete')
-- values (62421,'6788776','02','Machine A-WIP')
-- values (62422,'6788776','02','Machine A-WIP')
-- values (62423,'6788776','02','Machine Complete')
-- values (54614,'68480625AA','002B','Machine Complete')
-- values (58931,'7614013080','E2','Machine Complete')
-- values (58930,'7614013080','E2','Machine Complete')
-- values (61290,'LB5C-5K651-BF','G8','Machine Complete')
-- values (61291,'LB5C-5K652-BF','G8','Machine Complete')
-- values (61258,'LC5C-5K651-CE','F6','Machine Complete')
-- values (61257,'LC5C-5K652-CE','F6','Machine Complete')
-- values (61254,'W10751752','E','Machine Complete')
-- values (61255,'W10751752','E','Machine Complete')
-- values (55977,'W10751752','E','Machine Complete')
-- values (61673,'W11033021','E','Machine Complete')
-- values (56546,'W11033021','E','Machine Complete')
-- values (55927,'W11033021','E','Machine Complete')

select * from dbo.TL_Plex_PN_Op_Map 

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