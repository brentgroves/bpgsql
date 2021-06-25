/*
 drop table Plex.purchasing_item_inventory
truncate table Plex.purchasing_item_inventory
create table Plex.purchasing_item_inventory
(
  id int,
  pcn int,
  item_key int,
  item_no varchar(50),
  location varchar(50),
  quantity int
)

*/
-- https://www.youtube.com/watch?v=iiNDq2VrZPY more advanced way
-- select * from  Plex.purchasing_item_inventory

declare @PCN int
set @PCN = 300758
declare @RowFilter varchar(50)
set @RowFilter = '01-CUB2[3-68]%'
select * 
from  Plex.purchasing_item_inventory i 
where 
i.pcn = @PCN
and (i.location like @RowFilter)  
-- and (i.location like '01-CUB2[3-68]%')
-- https://www.c-sharpcorner.com/article/execute-sql-server-stored-procedure-with-user-parameter-in-power-bi/

declare @PCN int
set @PCN = 300758
declare @RowFilter varchar(50)
set @RowFilter = '01-CUB2[3-68]%'

exec Plex.InventoryPick @PCN,@RowFilter  

-- drop PROCEDURE Plex.inventoryPick
create PROCEDURE Plex.InventoryPick  
@PCN int = 300758,
@RowFilter varchar(50) = '%'
AS
BEGIN
	SET NOCOUNT ON
	select i.location, '"' + i.item_no + '"' item_no, quantity 
	from  Plex.purchasing_item_inventory i 
	where 
	i.pcn = @PCN
	and (i.location like @RowFilter)  
	order by location 

end;
/*
create PROCEDURE [dbo].[bpItemsPerPart] 
AS
BEGIN
	SET NOCOUNT ON
	IF
	OBJECT_ID('tempdb.dbo.#btToolOps') IS NOT NULL
		DROP TABLE #btToolOps
	IF
	OBJECT_ID('btItemsPerPart') IS NOT NULL
		DROP TABLE btItemsPerPart

	DECLARE
		  @allToolOps VARCHAR(max)

	select
		partNumber,
		itemNumber,
		itemsPerPart, 
		'<br>' +  tlDescription + ', ' + OpDescription + ', ' + tooldescription + 
		'<br>Quantity Per Tool:' + cast(Quantity as varchar(10)) +
		', Quantity Per Cutting Edge:' + cast(QuantityPerCuttingEdge as varchar(10)) +
		', Number Of Cutting Edges:' + cast(NumberOfCuttingEdges as varchar(10)) +
		'<br>Items Per Part:' + cast(cast(itemsPerPartPerTool as numeric(19,8)) as varchar(50)) as ToolOp
		, RowNum = ROW_NUMBER() OVER (PARTITION BY partNumber,itemNumber ORDER BY 1/0)
		, allToolOps = CAST(NULL AS VARCHAR(max))
	INTO #btToolOps
	from 
	(
		select tid.partNumber,tid.itemnumber,tid.itemsPerPart as itemsPerPartPerTool,
		tis.itemsPerPart,tlDescription,
		opDescription,tooldescription,monthlyUsage,
		itemType,Quantity,AnnualVolume,QuantityPerCuttingEdge,NumberOfCuttingEdges,
		tid.Consumable,PartSpecific,AdjustedVolume
		from 
		(
			select * from bvToolListItemsLv1
			where consumable = 1
			--8407
		)tid
		--32571
		inner join
		(
			--distinct partNumber,itemNumber
			select partNumber, itemNumber,consumable,
			sum(itemsPerPart) as itemsPerPart
			from bvToolListItemsLv1
			group by 
			partNumber, itemNumber,consumable
			having Consumable = 1 
			-- 7050
		) tis
		on
		tid.partNumber=tis.partNumber and
		tid.itemNumber=tis.itemNumber
		--8407
	) tops

	UPDATE #btToolOps
	SET 
		  @allToolOps = allToolOps =
			CASE WHEN RowNum = 1 
				THEN toolOp
				ELSE @allToolOps + '<br>' + toolOp 
			END

	select partNumber,itemNumber,itemsPerPart, 
		max(allToolOps) as toolOps
	into btItemsPerPart
	from #btToolOps
	group by partNumber,itemNumber,itemsPerPart
	-- 7050
end;
*/