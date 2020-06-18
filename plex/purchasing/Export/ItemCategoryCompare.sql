create table plxItemCategoryAlbion
(
	ItemCategory varchar(50)
);

--drop table PlxItemGroupAlbion
Bulk insert PlxItemCategoryAlbion
from 'c:\icAlbion.csv'
with
(
	fieldterminator = ',',
	rowterminator = '\n'
)
--drop table plxItemGroupEdon
create table plxItemCategoryEdon
(
	ItemCategory varchar(50)
);

Bulk insert PlxItemCategoryEdon
from 'c:\icEdon.csv'
with
(
	fieldterminator = ',',
	rowterminator = '\n'
)



create table plxInventoryUnitAlbion
(
	InventoryUnit varchar(50)
);

Bulk insert PlxInventoryUnitAlbion
from 'c:\iuAlbion.csv'
with
(
	fieldterminator = ',',
	rowterminator = '\n'
)
--drop table plxInventoryUnitEdon
create table plxInventoryUnitEdon
(
	InventoryUnit varchar(50)
);

Bulk insert PlxInventoryUnitEdon
from 'c:\iuEdon.csv'
with
(
	fieldterminator = ',',
	rowterminator = '\n'
)


select a.inventoryunit alb,e.inventoryunit edon
from dbo.plxInventoryUnitAlbion a 
left outer join dbo.plxInventoryUnitEdon e 
on a.inventoryunit=e.inventoryunit
where e.inventoryunit is NULL 

