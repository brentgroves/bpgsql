/* All non-global Copeland item 
		select distinct tl.originalprocessid,tl.processid,tl.descript,tl.partNumber,tl.plant,
		lv1.itemNumber,lv1.itemClass,lv1.UDFGLOBALTOOL,lv1.toolbossStock  
		from bvToolListsInPlants tl
		inner join
		bvToolListItemsLv1 lv1
		ON tl.processid = lv1.ProcessID
		where lv1.UDFGLOBALTOOL <> 'YES'
		and tl.descr like '%COPELAND%'

 */
SELECT     [User], Job, Machine, D_Consumer, item, D_Item, plant
FROM         dbo.bfToolBossItemsInPlant(8) 

create function [dbo].[bfToolListItemsInPlant]
(  
 @plant int
)
RETURNS TABLE 
AS
RETURN
select *
from
bvToolListItemsInPlants
where plant = @plant;

select count(*) cnt from toolitems  -- 16,816
select * from bvToolListsInPlants
where descr like '%COPELAND%'
-- dbo.bvToolListItemsInPlants source

select count(*) from (  -- 3983
select distinct tl.originalprocessid,tl.processid,tl.descript,tl.partNumber,
lv1.itemNumber,lv1.itemClass,lv1.UDFGLOBALTOOL,lv1.toolbossStock  
from bvToolListsInPlants tl
inner join
bvToolListItemsLv1 lv1
ON tl.processid = lv1.ProcessID
where lv1.UDFGLOBALTOOL <> 'YES'
and tl.descr like '%COPELAND%'
) s1

select count(*) from (  -- 3983
	select DISTINCT originalprocessid,processid from --55
--	select DISTINCT processid from --55
	(
		select distinct tl.originalprocessid,tl.processid,tl.descript,tl.partNumber,tl.plant,
		lv1.itemNumber,lv1.itemClass,lv1.UDFGLOBALTOOL,lv1.toolbossStock  
		from bvToolListsInPlants tl
		inner join
		bvToolListItemsLv1 lv1
		ON tl.processid = lv1.ProcessID
		where lv1.UDFGLOBALTOOL <> 'YES'
		and tl.descr like '%COPELAND%'
	) s1
)s2
--///////////////////////////////////////////////////////////////////////////////
-- This view does not take into consideration the [ToolList Toolboss Stock Items]
-- table which lists the item classes to be stocked in the toolbosses. See
-- bvToolBossItemsInPlants to determine items to be stocked in the ToolBosses.
-- This list would be appropriate to list restrictions for the Cribmaster if you
-- grouped the recordset on all fields except plant.
--///////////////////////////////////////////////////////////////////////////////
create view [dbo].[bvToolListItemsInPlants]
as
select distinct tl.originalprocessid,tl.processid,tl.descript,tl.partNumber,tl.plant,
lv1.itemNumber,lv1.itemClass,lv1.UDFGLOBALTOOL,lv1.toolbossStock  
from bvToolListsInPlants tl
inner join
bvToolListItemsLv1 lv1
ON tl.processid = lv1.ProcessID
where lv1.UDFGLOBALTOOL <> 'YES'
and tl.descr like '%COPELAND%'
--27838
union
	-- 796 select count(*) from bvToolListsInPlants
	select tl.originalprocessid,tl.processid,tl.descript,tl.partNumber,tl.plant
	,ti.itemNumber, ti.itemclass, ti.UDFGLOBALTOOL, 0 as toolbossStock 
	FROM  toolitems ti
	CROSS JOIN
	bvToolListsInPlants tl
	WHERE (ti.UDFGLOBALTOOL = 'YES')
	and tl.descr like '%COPELAND%'