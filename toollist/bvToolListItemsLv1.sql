select * from bvToolListItemsInPlants where originalprocessid = 50542


select * from [ToolList Master] tm 
where
tm.ProcessId = 	62521  -- there are 2 tool lists for the same part and operation so I will pick the newest one.
--tm.ProcessId = 	62521 -- OPID=50542,10049132 JT REAR CARRIER-NON ELD,Released


DECLARE	@return_value int

EXEC	@return_value = [dbo].[bpDistinctToolLists]
call bpDistinctToolLists bpDistinctToolLists
select i.* 
from dbo.bfToolBossItemsInPlant(11) i
inner join 
(
select  * from dbo.bfToolListsInPlant(11) 
where customer = 'JOHN DEERE'
) jd 
on i.job=jd.originalprocessid


-- dbo.bvToolListItemsLv1 source

--////////////////////////////////////////////////
-- Each toolid/item could have a different items
-- per part ratio, but the toolbosses dont currently
-- have an opsdescription in the restrictions2 table
-- so we have to choose the toolids items per part ratio
-- for costing purposes.
-- /////////////////////////////////////////////////
create View [dbo].[bvToolListItemsLv1] 
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
	union
		SELECT tm.originalprocessid, tm.processid,CribToolID as itemNumber, 
		0 as ToolID, 0 as ttpid, 0 as toolNumber,'Fixture' as OpDescription, 
		tf.itemid,tf.tooltype,tf.tooldescription,  
		Quantity,AnnualVolume,0 as AdjustedVolume,0 as QuantityPerCuttingEdge,0 as NumberOfCuttingEdges,
		'fixture' as itemType,0 as partspecific, 0 as Consumable, 
		case 
			when toolbossStock is null then 0
			when toolbossStock = 0 then 0
			when toolbossStock = 1 then 1
			else 0
		end as toolbossStock,
		cast(0.0 as numeric(19,8)) itemsPerPart, 
		0 as MonthlyUsage, 0 as DailyUsage
		FROM [TOOLLIST Fixture] as tf 
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
		ON tf.PROCESSID = tm.PROCESSID 
		--1648
	union
		SELECT tm.OriginalProcessID, tm.processid,CribToolID as itemNumber, 
		0 as ToolID, 0 as ttpid, 0 as toolNumber,'Misc' as OpDescription, 
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