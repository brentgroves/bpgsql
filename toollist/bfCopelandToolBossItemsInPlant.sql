-- select count(*) from [dbo].[bfCopelandToolBossItemsInPlant](11) -- 2104
SELECT     [User], Job, Machine, D_Consumer, item, D_Item, plant
FROM         [dbo].[bfCopelandToolBossItemsInPlant](11) 

create function [dbo].[bfCopelandToolBossItemsInPlant]
(  
 @plant int
)
RETURNS TABLE 
AS
RETURN
select * from bvCopelandToolBossItemsInPlants
where plant = @plant;

-- select count(*) cnt from bvCopelandToolBossItemsInPlants  -- 2104 = 1939 + 165
-- dbo.bvToolBossItemsInPlants source
-- drop view view [dbo].[bvCopelandToolBossItemsInPlants] 
create view [dbo].[bvCopelandToolBossItemsInPlants] 
as
-- toollists items that have a category that is to be stocked in the toolbosses
-- or are marked 

	select '$ALL$' AS [User], originalprocessid AS Job, 'DEFAULT' AS Machine, '133' AS D_Consumer, itemNumber AS item, '3' AS D_Item, plant 
	from
	(		-- Copeland Items with item classes that are stocked in the ToolBoss
			-- SELECT COUNT(*) CNT FROM ( --1939
			select originalprocessid,processid,descript,partNumber,plant,
			itemNumber,lv1.itemClass,UDFGLOBALTOOL,toolbossStock  
			from
			(
				select * from bvCopelandToolListItemsInPlants
				where toolbossstock=0 and UDFGLOBALTOOL <> 'YES'
				--27791
			) lv1
			inner join
			[ToolList Toolboss Stock Items] tbs
			on lv1.itemClass=tbs.ItemClass
			-- ) V1 -- FOR VALIDATION
			--14347
		union
			-- stocked in toolboss no matter the item
			-- class
			SELECT *  -- 0 RECORDS
			from
			bvCopelandToolListItemsInPlants
			where toolbossstock=1 
		
		union
			-- add these global items to all tool lists 
			select *  -- 165
			from
			bvCopelandToolListItemsInPlants tl
			where UDFGLOBALTOOL = 'YES'
	) S1

-- dbo.bvToolListItemsInPlants source
select count(*) cnt from bvCopelandToolListItemsInPlants  -- 4148

--///////////////////////////////////////////////////////////////////////////////
-- This view does not take into consideration the [ToolList Toolboss Stock Items]
-- table which lists the item classes to be stocked in the toolbosses. 
--///////////////////////////////////////////////////////////////////////////////
-- drop view [dbo].[bvCopelandToolListItems]
create view [dbo].[bvCopelandToolListItemsInPlants]
as
-- SELECT COUNT(*) CNT FROM ( -- 3983 
select distinct tl.originalprocessid,tl.processid,tl.descript,tl.partNumber,tl.Plant, 
lv1.itemNumber,lv1.itemClass,lv1.UDFGLOBALTOOL,lv1.toolbossStock  
from bvToolListsInPlants tl
inner join
bvToolListItemsLv1 lv1
ON tl.processid = lv1.ProcessID
where lv1.UDFGLOBALTOOL <> 'YES'
and tl.descr like '%COPELAND%'
-- )V1
union
	-- select count(*) from (  -- 55 * 3 = 165
	select tl.originalprocessid,tl.processid,tl.descript,tl.partNumber,tl.Plant, 
	ti.itemNumber, ti.itemclass, ti.UDFGLOBALTOOL, 0 as toolbossStock 
	FROM  toolitems ti
	CROSS JOIN
	bvToolListsInPlants tl
	WHERE (ti.UDFGLOBALTOOL = 'YES')
	and tl.descr like '%COPELAND%'
	-- ) V1
-- 3983 + 165 = 4148
	
/*
	What if we remove the global check and union?
	The Global item are not included.
*/
--	select count(*) cnt from bvCopelandToolListItems  -- 4148
-- SELECT COUNT(*) CNT FROM ( -- 3983 
select distinct tl.originalprocessid,tl.processid,tl.descript,tl.partNumber,
lv1.itemNumber,lv1.itemClass,lv1.UDFGLOBALTOOL,lv1.toolbossStock  
from bvToolListsInPlants tl
inner join
bvToolListItemsLv1 lv1
ON tl.processid = lv1.ProcessID
where tl.descr like '%COPELAND%'
)V1
	