/*
 * CHANGE FROM COPELAND TO TRX
 */
-- select count(*) from [dbo].[bfCopelandToolBossItemsInPlant](11) -- 48
SELECT     [User], Job, Machine, D_Consumer, item, D_Item, plant
FROM         [dbo].[bfTRXToolBossItemsInPlant](112) 

create function [dbo].[bfTRXToolBossItemsInPlant]
(  
 @plant int
)
RETURNS TABLE 
AS
RETURN
select * from bvTRXToolBossItemsInPlants
where plant = @plant;

-- select count(*) cnt from bvCopelandToolBossItemsInPlants  -- 2104 = 1939 + 165
-- dbo.bvToolBossItemsInPlants source
-- drop view view [dbo].[bvTRXToolBossItemsInPlants] 
create view [dbo].[bvTRXToolBossItemsInPlants] 
as
-- toollists items that have a category that is to be stocked in the toolbosses
-- or are marked 

	select '$ALL$' AS [User], originalprocessid AS Job, 'DEFAULT' AS Machine, '133' AS D_Consumer, itemNumber AS item, '3' AS D_Item, plant 
	from
	(		-- Copeland Items with item classes that are stocked in the ToolBoss
			-- SELECT COUNT(*) CNT FROM ( --42
			select originalprocessid,processid,descript,partNumber,plant,
			itemNumber,lv1.itemClass,UDFGLOBALTOOL,toolbossStock  
			from
			(
				select * from bvTRXToolListItemsInPlants
				where toolbossstock=0 and UDFGLOBALTOOL <> 'YES'
				--90
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
			bvTRXToolListItemsInPlants
			where toolbossstock=1 
		
		union
			-- add these global items to all tool lists 
			select *  -- 6
			from
			bvTRXToolListItemsInPlants tl
			where UDFGLOBALTOOL = 'YES'
	) S1

-- dbo.bvToolListItemsInPlants source
select count(*) cnt from bvTRXToolListItemsInPlants  -- 96

--///////////////////////////////////////////////////////////////////////////////
-- This view does not take into consideration the [ToolList Toolboss Stock Items]
-- table which lists the item classes to be stocked in the toolbosses. 
--///////////////////////////////////////////////////////////////////////////////
-- drop view [dbo].[bvTRXToolListItems]
create view [dbo].[bvTRXToolListItemsInPlants]
as
-- SELECT COUNT(*) CNT FROM ( -- 3983 
select distinct tl.originalprocessid,tl.processid,tl.descript,tl.partNumber,tl.Plant, 
lv1.itemNumber,lv1.itemClass,lv1.UDFGLOBALTOOL,lv1.toolbossStock  
from bvToolListsInPlants tl
inner join
bvToolListItemsLv1 lv1
ON tl.processid = lv1.ProcessID
where lv1.UDFGLOBALTOOL <> 'YES'
and tl.descr like '%TRX%'
-- )V1
union
	-- select count(*) from (  -- 55 * 3 = 165
	select tl.originalprocessid,tl.processid,tl.descript,tl.partNumber,tl.Plant, 
	ti.itemNumber, ti.itemclass, ti.UDFGLOBALTOOL, 0 as toolbossStock 
	FROM  toolitems ti
	CROSS JOIN
	bvToolListsInPlants tl
	WHERE (ti.UDFGLOBALTOOL = 'YES')
	and tl.descr like '%TRX%'
	-- ) V1
-- 3983 + 165 = 4148
	
