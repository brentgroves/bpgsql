--decimal (19,4)
/*

truncate table Plex.purchasing_item_usage
create table Plex.purchasing_item_usage
(
  id int,
  pcn int,
  item_key int,
  item_no varchar(50),
  trim varchar(50),
  accounting_job_key int,
  accounting_no varchar(20),
  location varchar(50),
  quantity int,
  usage_date datetime,
  total_cost decimal(19,4),
  transaction_type_key int,
  transaction_type varchar(50)	  
)
*/
select * from Plex.purchasing_item_usage