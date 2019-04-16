-- Is all the needed item classes in plex?
select DISTINCT ItemClass
from
(
	select inv.ItemClass, cat.itemclass class 
	from INVENTRY inv 
	left outer join btItemClassCatKey cat 
	on upper(cat.itemclass) = inv.ItemClass
	where cat.ItemClass is null
)lv1

-- Is all the needed item classes in plex?
select DISTINCT ItemClass
from
(
	select inv.ItemClass, cat.itemclass class 
	from INVENTRY inv 
	left outer join btItemClassCatKey cat 
	on upper(cat.itemclass) = inv.ItemClass
	where cat.ItemClass is null
)lv1
-- Pivot Pin is in plex so insert in table
-- Hydraulic Valve is spelled wrong in Cribmaster so insert with misspelling but correct cat key.
INSERT INTO Cribmaster.dbo.btItemClassCatKey
(ItemClass, ItemCategoryKey)
VALUES('HYDRUALIC VALVE', '18201');
--VALUES('Pivot Pin', '14734');

select * from btItemClassCatKey cat where cat.ItemClass like '%Pivot%'

--Are there any item classes in Plex we don't need?
select distinct rm.itemclass
from 
(
select cat.itemclass, inv.ItemClass class 
from btItemClassCatKey cat
left outer join INVENTRY inv 
on upper(cat.itemclass) = inv.ItemClass
where inv.ItemClass is null
) rm
