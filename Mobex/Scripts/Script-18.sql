/*
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
*/