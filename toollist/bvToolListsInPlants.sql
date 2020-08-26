/*
 * Map Plex part_number,revision, operation to (Multiple Tool lists)
 * Each workcenter is assigned a part and operation number.
 * Turbos
 * T01-60 - Lathe 1, Plex operation 1 
 * T01-70 - Lathe 2, Plex operation 1
 * T01-80 - Mill, Plex operation 2
 * 
 * BMW
 * 6788776L BMW-FRNT TOPMNT FLANGE
 * 1ST OP LATHE
 * 2ND OP LATHE
 * 3RD OP DRILL/C'BORE
 * 
 * W11033021 WHIRLPOOL
 * 1ST OP LATHE
 * 2ND OP LATHE
 * 3RD OP MILL
 */
select tl.processid,tl.customer,tl.partfamily,tl.OperationDescription,
m.Plex_Part_No,m.Revision
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

create VIEW [dbo].[bvToolListsInPlants]
AS
	select lv1.Originalprocessid,lv1.processid, 
		lv1.customer,lv1.partfamily,lv1.OperationDescription,
		lv1.descript,lv1.descr,	
		lv1.subDescript,lv1.subDescr,
		lv1.partNumber,tp.Plant 

	from
	( 
		select * from bvToolListsAssignedPN
		--732
	) lv1
	INNER JOIN
	[ToolList Plant] AS tp 
	ON lv1.ProcessID = tp.ProcessID;