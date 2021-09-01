/*
 * drop table Plex.purchasing_item_summary
truncate table Plex.purchasing_item_summary
create table Plex.purchasing_item_summary
(
  id int,
  pcn int,
  item_key int,
  tool_key int,
  item_no varchar(50),
  trim varchar(50),
  tool_type_code varchar(20),
  description varchar(50),
  unit_price decimal(19,6),
  storage_location varchar(50),
  active smallint
)
-- myDW.Plex.purchasing_item_summary definition

-- Drop table

-- DROP TABLE myDW.Plex.purchasing_item_summary;

*/

select count(distinct item_no) 
select count(*) from
(
select distinct item_no
from Plex.purchasing_item_summary  -- 975
where storage_location = 'Tool Boss'  -- 496
)s 496