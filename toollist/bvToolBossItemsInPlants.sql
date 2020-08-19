-- dbo.bvToolBossItemsInPlants source
select * from dbo.bvToolBossItemsInPlants where plant = '12'
create view [dbo].[bvToolBossItemsInPlants] 
as
-- toollists items that have a category that is to be stocked in the toolbosses
-- or are marked 

	select '$ALL$' AS [User], originalprocessid AS Job, 'DEFAULT' AS Machine, '133' AS D_Consumer, itemNumber AS item, '3' AS D_Item, plant 
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