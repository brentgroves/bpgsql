-- TL_Plex_PN_Op_Map
--select * into Plex_PN_Op_Map_Edon from TL_Plex_PN_Op_Map 
-- truncate table TL_Plex_PN_Op_Map_Albion
-- drop table TL_Plex_PN_Op_Map_Albion
CREATE TABLE [Busche ToolList].dbo.TL_Plex_PN_Op_Map_Avilla (
	ProcessID int NOT NULL,
	TL_Part_No	varchar (100), 
	Plex_Part_No varchar(100) NOT NULL,
	Revision varchar(8) NOT NULL,
	Operation_Code	varchar (30) NOT NULL
);
select * from TL_Plex_PN_Op_Map_Avilla

-- '10103355','A'
select * 
from dbo.TL_Plex_PN_Op_Map_Avilla  
where Plex_Part_No = ''

insert into TL_Plex_PN_Op_Map_Avilla (ProcessID,TL_Part_No,Plex_Part_No,Revision,Operation_Code)
values(61442,'51393-TJB-A040-M1','51393TJB A040M1','40-M1-','Final')


select * from dbo.TL_Plex_PN_Op_Map_Avilla m where m.Plex_Part_No like '%100248%' 
select * from dbo.TL_Plex_PN_Op_Map_Albion

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
left outer join [ToolList PartNumbers] n 
on tm.processid=n.processid
where tm.PartFamily like '%558%6K%LH%'  --TL = THERE ARE 3 OPERATIONS IN THE TOOL LIST
-- where tm.PartFamily like '%RDX%'  --TL = 51393-TJB-A040-M1 RH RDX COMPLIANCE BRACKET, G-Code,
where tm.processid = 62517
where partNumbers like '10024895%'

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