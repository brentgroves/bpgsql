-- dbo.bvToolBossRestrictions2 source
SELECT     [User], Job, Machine, D_Consumer, item, D_Item, plant
FROM         dbo.bfToolBossItemsInPlant(112) AS bfToolBossItemsInPlant_1

select char(39) + item + char(39) + ',' from 
(
SELECT DISTINCT item
FROM         bvToolBossRestrictions2
WHERE     (processid IN (63269,63270))
)s1
where item not in 
(
'0002021',
'0000138',
'0003144',
'0003262',
'0003491',
'0003600',
'0005187',
'0005188',
'0005203',
'007157',
'007808',
'007809',
'007811',
'007864',
'009445',
'009624',
'010560',
'14217',
'15653',
'16186',
'16520'
)

create view dbo.bvToolBossRestrictions2
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