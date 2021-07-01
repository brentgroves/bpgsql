-- drop table Plex.purchasing_item_inv_cube
create table Plex.purchasing_item_inv_cube
(
  id int,
  pcn int,
  run_date datetime,
  str_run_date varchar(10),
  loc_prefix varchar(3),
  item_types int,
  total_items int,
  total_cost decimal(19,2),
  move bit,
  maintenance bit
  
)

--select * from ssis.ScriptComplete