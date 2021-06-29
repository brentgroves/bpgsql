-- drop table Plex.purchasing_item_inv_cube
create table Plex.purchasing_item_inv_cube
(
  id int,
  pcn int,
  date datetime,
  fmtDate varchar(10),
  prefix varchar(3),
  item_types int,
  total_items int,
  total_cost decimal(19,6),
  move smallint
  
)