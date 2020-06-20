
-- SELECT * from PlxSupplyItemTemplate
-- drop table PlxSupplyItemTemplate
-- truncate table PlxSupplyItemTemplate
create table PlxSupplyItemTemplate
(
  row_no int,
  item_no varchar (50),
  brief_description varchar (80),  
  description varchar (800),
  note varchar(200),
  item_type varchar(25),
  item_group varchar(50),
  item_category varchar (50),
  item_priority varchar (50),
  customer_unit_price decimal(19,4),
  average_cost decimal(23,9),
  inventory_unit varchar (20),
  min_quantity decimal(18,2),
  max_quantity decimal(18,2),
  tax_code varchar(100),
  account_no varchar(20),
  manufacturer int,
  manf_Item_no 	varchar(50),
  drawing_no varchar(50),
  item_quantity decimal(18,2), -- we don't use this so want it to be null
  location varchar(50), -- from the item location table but we will not use it.
  supplier_code varchar (25),
  supplier_part_no varchar (50),  -- Supplier_Item_No
  supplier_std_purch_qty decimal(19,2),  -- Purchase_Quantity
  currency char(3),
  supplier_std_unit_price decimal(19,6),
  supplier_purchase_unit varchar(20),
  supplier_unit_conversion decimal(18,6),
  supplier_lead_time decimal(9,2),
  update_when_received char(1), -- this is a smallint in plex, but needs to be 'Y' for the upload.
  manufacturer_item_revision varchar (8),
  country_of_origin int,
  commodity_code varchar(10),
  harmonized_tariff_code 	varchar(20),
  cube_length decimal(9,4),
  cube_width decimal(9,4),
  cube_height decimal(9,4),
  cube_unit varchar (20)
)
-- truncate table PlxSupplyItemTemplate
-- LOAD DATA INFILE '/var/lib/mysql-files/AlbSupplyItemLE250.csv' INTO TABLE PlxSupplyItemTemplate FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS
LOAD DATA INFILE '/AlbSupplyItemSet10.csv' INTO TABLE PlxSupplyItemTemplate FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS
(
  row_no,
  item_no,
  brief_description,  
  description,
  note,
  item_type,
  item_group,
  item_category,
  item_priority,
  customer_unit_price,
  average_cost,
  inventory_unit,
  @min_quantity, 
  @max_quantity,
  tax_code,
  account_no,
  @manufacturer,
  manf_Item_no,
  drawing_no,
  @item_quantity,
  location,
  supplier_code,
  supplier_part_no,
  @supplier_std_purch_qty,
  currency,
  @supplier_std_unit_price,
  supplier_purchase_unit,
  @supplier_unit_conversion,
  @supplier_lead_time,
  update_when_received,
  manufacturer_item_revision,
  @country_of_origin,
  commodity_code,
  harmonized_tariff_code,
  cube_length,
  cube_width,
  cube_height,
  cube_unit 
)
SET
manufacturer = NULLIF(@manufacturer,''),
item_quantity = NULLIF(@item_quantity,''),
min_quantity = NULLIF(@min_quantity,''),
max_quantity = NULLIF(@max_quantity,''),
supplier_std_purch_qty = NULLIF(@supplier_std_purch_qty,''),
supplier_std_unit_price = NULLIF(@supplier_std_unit_price,''),
supplier_unit_conversion = NULLIF(@supplier_unit_conversion,''),
supplier_lead_time = NULLIF(@supplier_lead_time,''),
country_of_origin = NULLIF(@country_of_origin,''),
cube_unit = NULLIF(@cube_unit,'');

select count(*) from PlxSupplyItemTemplate;  -- Don't import more than ~ 264 of these records in Plex at a time or data corruption may occur.
select * from PlxSupplyItemTemplate pasi order by row_no desc

-- DECODE CSV CHARACTER MAPPINGS
-- update PlxSupplyItemTemplate 
set brief_description = REPLACE(REPLACE(REPLACE(REPLACE(brief_description, '###', ','), '##@', '"'),'#@#',CHAR(10)),'#@@',CHAR(13)),
description = REPLACE(REPLACE(REPLACE(REPLACE(description, '###', ','), '##@', '"'),'#@#',CHAR(10)),'#@@',CHAR(13)),
note = REPLACE(REPLACE(REPLACE(REPLACE(note, '###', ','), '##@', '"'),'#@#',CHAR(10)),'#@@',CHAR(13))

select 
  -- 'T0000766' item_no,
  i.item_no,
  /*
   * anywhere there is a \n, ie. 0D0A combo we need to replace it.  
   * If we don't the Plex upload process will interpret this as a 
   * completely new record to be uploaded. So replace the \n (0x0D 0x0A) combo with 0x0D.  
   * I tested with replacing the combo with 0x0A and the upload failed.
   */
  -- brief_description,  
  REPLACE(REPLACE(REPLACE(i.brief_description , CHAR(13), '13'), CHAR(10), '10'),'1310',CHAR(13)) as brief_description,
  -- description,
  REPLACE(REPLACE(REPLACE(description , CHAR(13), '13'), CHAR(10), '10'),'1310',CHAR(13)) as description,
  -- note,
  REPLACE(REPLACE(REPLACE(note , CHAR(13), '13'), CHAR(10), '10'),'1310',CHAR(13)) as note,  -- THIS HAD A SPACE
  item_type,
  item_group,
  item_category,
  item_priority,
  customer_unit_price,
  average_cost,
  inventory_unit,
  min_quantity, 
  max_quantity,
  	-- purchasing_v_tax_code / did not put this in for MRO supply items
	-- but before you update the item in plex it has to be filled with something
	-- and accountant said I could use tax exempt.
	-- Found that EM Parts are already marked as taxable 'Y' or 'N'
	-- where taxable = 'N' --2044
	-- where taxable = 'Y'--10619
	-- Talked with Kristen about taxable = 'Y' and she said that is wrong and the 
	-- accountant also said this so I'm going to mark them all as Tax Exempt
	-- 70	Tax Exempt - Labor / Industrial Processing
	-- WHEN THE ITEM IS UPLOADED WITHOUT ONE IT LOOKS LIKE IT PICKS ONE FOR YOU
	-- SO I WENT WITH THE TAX EXEMPT ONE.
  'Tax Exempt - Labor / Industrial Processing' as tax_code,
  account_no,
  null as manufacturer,
  manf_Item_no, 
  drawing_no, 
  item_quantity,
  location, 
  supplier_code,
  supplier_part_no,
  supplier_std_purch_qty,
  case 
  	when currency = '' then 'USD'
  	else currency
  end currency,
  supplier_std_unit_price,
  supplier_purchase_unit,
  supplier_unit_conversion,
  supplier_lead_time,
  update_when_received,
  manufacturer_item_revision,
  country_of_origin,
  commodity_code,
  harmonized_tariff_code,
  cube_length,
  cube_width,
  cube_height,
  cube_unit 
from PlxSupplyItemTemplate i 
inner join NotInEdon0620 ned 
on i.item_no = ned.item_no 
order by ned.row_no 
-- NotInEdon0620 range: {1=0003040, 200=0003523}, record count: 200

-- and i.row_no > 4405
-- 0004884
-- 009848
-- where item_no = '0000011'

select 
count(*)
-- i.item_no,supplier_code 
from PlxSupplyItemTemplate i 
where i.row_no > 4405  -- 103
where i.item_no >= '009849' and i.item_no <= '011815'
where i.item_no in ('BE851728','009483')

select item_no,supplier_code from PlxSupplyItemTemplate where supplier_code like '%Kend%' limit 5

inner join NotInEdon ned 
on i.item_no = ned.item_no 
-- where i.item_no in ('0000766','0000011')
select * from NotInEdon nie where item_no > '009848'
-- worked
-- 0000766
