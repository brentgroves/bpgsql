
select * from [ToolList Master] 
where processid = 61748  -- P558 Knuckles, plant 6



/* START HERE */
select toolNumber,OpDescription,itemNumber,Consumable,tooltype,tooldescription,
Quantity,QuantityPerCuttingEdge,NumberOfCuttingEdges
-- * 
-- select toolNumber tn,itemNumber item,Quantity,QuantityPerCuttingEdge qtyPerCuttingEdge
 select lv1.toolNumber tn,lv1.itemNumber item
 ,ti.ToolDescription,ti.Quantity,ti.QuantityPerCuttingEdge qtyPerCuttingEdge,ti.Regrindable,ti.QtyPerRegrind,ti.NumOfRegrinds,
 ti.AdditionalNotes
 
 select * from [ToolList Item] ti where ti.processid = 63647
 select * from [TOOLLIST TOOL] as tt where tt.processid = 63647

select ti.*
FROM [TOOLLIST ITEM] as ti 
-- when a tool gets deleted the toollist item remains?
inner join [TOOLLIST TOOL] as tt on ti.toolid=tt.toolid
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
) as tm 
ON tt.PROCESSID = tm.PROCESSID 
where tt.processid = 63647

select * from btDistinctToolLists where processid = 63647


	select * 
	into btDistinctToolLists
	from bvDistinctToollists
	where processid = 63647



 -- Quantity,NumberOfCuttingEdges,QuantityPerCuttingEdge qty
-- ,*
-- select *
from bvToolListItemsOnlyLv1 lv1
inner join [ToolList Tool] tt
on lv1.toolNumber=tt.toolNumber
and lv1.processid = tt.processid
inner join [ToolList Item] ti
on tt.processid = ti.processid 
and tt.ToolID = ti.ToolID
and lv1.itemNumber = ti.CribToolId
-- where lv1.processid = 61442  -- RDX RH Bracket, plant 11
-- where lv1.processid = 61748  -- P558 Knuckles, plant 6
where lv1.processid = 63647
-- where lv1.processid  = 62615
and lv1.toolNumber = 9
 and lv1.Consumable = 1
-- and NumberOfCuttingEdges <>1
order by lv1.toolNumber,lv1.toolType

select * from [ToolList Master] where processid = 61748

select tt.ToolNumber TN,ti.CribToolID CribId,ti.Quantity QtyReq,ti.NumberOfCuttingEdges Edges,ti.QuantityPerCuttingEdge TLife
-- ti.AdditionalNotes,
-- ,ti.*
-- tt.OpDescription,tt.Alternate,ti.CribToolID,ti.QuantityPerCuttingEdge,ti.AdditionalNotes
-- ti.*
from [ToolList Tool] tt
inner join [ToolList Item] ti
on tt.processid = ti.processid 
and tt.ToolID = ti.ToolID
-- and ti.Consumable = 1
-- and tt.ToolNumber = 6
-- where tt.processid = 61748 -- P558 Knuckles
where tt.processid = 62615 -- RDX 51393TJB A040M1

-- where tt.processid = 61442 -- RDX 51393TJB A040M1
-- where ti.CribToolID = '15843'
-- 15843,14855
order by tt.ToolNumber

61748|10103355 
61744|10037973H
58951|10037973 

select
itemNumber,tooltype,tooldescription 
-- processid,toolNumber,OpDescription,itemNumber,Consumable,tooltype,tooldescription,
-- Quantity,QuantityPerCuttingEdge,NumberOfCuttingEdges 
--* 
from bvToolListItemsOnlyLv1
where processid = 61442
and Consumable =1 
and toolNumber = 6
order by toolNumber,toolType

--order by toolid
-- dbo.bvToolListItemsLv1 source

--////////////////////////////////////////////////
-- Each toolid/item could have a different items
-- per part ratio, but the toolbosses dont currently
-- have an opsdescription in the restrictions2 table
-- so we have to choose the toolids items per part ratio
-- for costing purposes.
-- /////////////////////////////////////////////////
-- dbo.bvToolListItemsOnlyLv1 source

-- dbo.bvToolListItemsOnlyLv1 source

create View [dbo].[bvToolListItemsOnlyLv1] 
AS
select lv2.*,ti.itemClass,ti.UDFGLOBALTOOL,ti.cost
from
(
	select tl.partNumber,tl.Description as tlDescription, lv1.*
	from
	(
		SELECT tm.OriginalProcessID, tm.processid,CribToolID as itemNumber,
		tt.ToolID, tt.processid as ttpid, tt.toolNumber,tt.OpDescription, 
		ti.itemid,ti.tooltype,ti.tooldescription,
		Quantity,
		AnnualVolume,
		AdjustedVolume,
		QuantityPerCuttingEdge,
		NumberOfCuttingEdges,
		'item' as itemType,partspecific,
		Consumable, 
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
				then 1/((QuantityPerCuttingEdge/cast( ti.quantity as numeric(19,8)))*NumberofCuttingEdges)
			when Consumable = 0 then 0.0
		end itemsPerPart, 
		case 
			when tt.PartSpecific = 0 and ti.Consumable = 1 then (Quantity * (AnnualVolume/12.0)) / cast((QuantityPerCuttingEdge * NumberOfCuttingEdges) as numeric(19,8)) 
			when tt.PartSpecific = 1 and ti.Consumable = 1  then (ti.Quantity * (tt.AdjustedVolume/12)) / cast((QuantityPerCuttingEdge * NumberOfCuttingEdges) as numeric(19,8)) 
			when ti.Consumable = 0 then ti.Quantity
		end MonthlyUsage,  
		case 
			when tt.PartSpecific = 0 and ti.Consumable = 1 then (ti.Quantity * (tm.AnnualVolume/365.0)) / cast((QuantityPerCuttingEdge * NumberOfCuttingEdges) as numeric(19,8)) 
			when tt.PartSpecific = 1 and ti.Consumable = 1  then (ti.Quantity * (tt.AdjustedVolume/365)) / cast((QuantityPerCuttingEdge * NumberOfCuttingEdges) as numeric(19,8))
			when ti.Consumable = 0 then ti.Quantity/30
		end DailyUsage  
		FROM [TOOLLIST ITEM] as ti 
		-- when a tool gets deleted the toollist item remains?
		inner join [TOOLLIST TOOL] as tt on ti.toolid=tt.toolid
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
		) as tm 
		ON tt.PROCESSID = tm.PROCESSID 
		--30432
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