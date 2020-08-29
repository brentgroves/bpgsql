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