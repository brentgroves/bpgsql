-- dbo.bvToolBossItemsWithProcessId source
-- bvToolBossItemsInPlant6 not an actual view.
select rs.item
-- select count(*)  -- 340
from 
(
	select 
	ROW_NUMBER() OVER(ORDER BY tb6.item ASC) AS Row#,
	'(' + CHAR(39) + tb6.item + CHAR(39) + '),'  item 
	from 
	(
		select distinct item from bvToolBossItemsInPlants where plant=6 
	)tb6 
)rs 
where Row# between 0 and 400  -- 340

SELECT count(*) FROM bvToolBossItemsInPlants where plant=6 -- 1560
create view dbo.bvToolBossItemsInPlant6
as
-- toollists items that have a category that is to be stocked in the toolbosses
-- or are marked 

	select processid,'$ALL$' AS [User], originalprocessid AS Job, 'DEFAULT' AS Machine, '133' AS D_Consumer, itemNumber AS item, '3' AS D_Item, plant 
	from
	(
			select originalprocessid,processid,descript,partNumber,plant,
			itemNumber,lv1.itemClass,UDFGLOBALTOOL,toolbossStock  
			from
			(
				select * from bvToolListItemsInPlants
				where toolbossstock=0 and UDFGLOBALTOOL <> 'YES'
				--27791
			) lv1
			inner join
			[ToolList Toolboss Stock Items] tbs
			on lv1.itemClass=tbs.ItemClass
			--14347
		union
			-- stocked in toolboss no matter the item
			-- class
			SELECT *
			from
			bvToolListItemsInPlants
			where toolbossstock=1 and UDFGLOBALTOOL <> 'YES'
			--17
		union
			-- add these global items to all tool lists 
			select *
			from
			bvToolListItemsInPlants
			where UDFGLOBALTOOL = 'YES'
			--2388
	--16752
	--16752
) lv2;