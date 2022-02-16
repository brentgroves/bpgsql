create table Plex.gross_profit_get 
(
 	invoice_no varchar(50) null,
 	serial_no varchar(100) null,
 	invoice_date datetime null,
 	line_item_no int null,
 	part_no varchar(100) null,
 	quantity_shipped int null,
 	unit_price numeric(18,5) null,
 	gross_material int null,
 	material_cost numeric(18,5) null,
 	labor_cost numeric(18,5) null,
 	overhead_cost numeric(18,5) null
)
--truncate table Plex.gross_profit_get
select * 
from Plex.gross_profit_get
where material_cost != 0 or labor_cost != 0 or overhead_cost != 0