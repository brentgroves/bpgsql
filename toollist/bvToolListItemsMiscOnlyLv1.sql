--////////////////////////////////////////////////
-- Each toolid/item could have a different items
-- per part ratio, but the toolbosses dont currently
-- have an opsdescription in the restrictions2 table
-- so we have to choose the toolids items per part ratio
-- for costing purposes.
-- /////////////////////////////////////////////////
-- select * from bvToolListItemsMiscOnlyLv1
select * 
from PlexToolListAssemblyTemplate a
select * 
FROM [ToolList Misc] as m 
where processID in (62421,62422,62423)  -- 0 recods


create View [dbo].[bvToolListItemsMiscOnlyLv1] 
AS
select lv2.*,ti.itemClass,ti.UDFGLOBALTOOL,ti.cost
from
(
	select tl.partNumber,tl.Description as tlDescription, lv1.*
	from
	(

		SELECT tm.OriginalProcessID, tm.processid,CribToolID as itemNumber, 
		0 as ToolID, 0 as ttpid,222222 ToolNumber,'Misc' as OpDescription, 
		m.itemid,m.tooltype,m.tooldescription,  
		Quantity,AnnualVolume,0 as AdjustedVolume,QuantityPerCuttingEdge,NumberOfCuttingEdges,
		'misc' as itemType, 0 as partspecific,m.Consumable, 
		case 
			when toolbossStock is null then 0
			when toolbossStock = 0 then 0
			when toolbossStock = 1 then 1
			else 0
		end as toolbossStock,
		case
			when (Quantity=0) or (NumberofCuttingEdges =0) or (QuantityPerCuttingEdge=0) or
			(Quantity is null) or (NumberofCuttingEdges is null) or (QuantityPerCuttingEdge is null)
				then 0
			when (Consumable = 1)
				then 1/((QuantityPerCuttingEdge/cast( quantity as numeric(19,8)))*NumberofCuttingEdges)
			when Consumable = 0 then 0.0
		end itemsPerPart, 
		case 
			when m.Consumable = 1 then (m.Quantity * (tm.AnnualVolume/12.0)) / cast((QuantityPerCuttingEdge * NumberOfCuttingEdges) as numeric(19,8))
			else m.Quantity
		end MonthlyUsage,  
		case 
			when m.Consumable = 1 then (m.Quantity * (tm.AnnualVolume/365.0)) / cast((QuantityPerCuttingEdge * NumberOfCuttingEdges) as numeric(19,8)) 
			else m.Quantity/30
		end DailyUsage  
		FROM [ToolList Misc] as m 
		INNER JOIN 
		(
			-- these are the toollist which are added to the toolbosses
			select tm.* 
			from
			btDistinctToolLists tb
			inner join
			[ToolList Master] tm
			on tb.ProcessId=tm.ProcessID
			--731
		)  
		as tm 
		ON m.PROCESSID = tm.PROCESSID 
		--371
	--32571
	)lv1
	inner join 
	btDistinctToolLists tl
	on lv1.ProcessID=tl.processid
	--32571
)lv2
-- drop items that are not in the crib
inner join
toolitems ti
on lv2.itemNumber=ti.itemnumber
--32438;