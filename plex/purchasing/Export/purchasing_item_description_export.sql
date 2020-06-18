-- EXPORT ALL THE ACTIVE ITEMS
/*
select
s1.item_no
from
(
select 
row_number() OVER(ORDER BY i.item_no ASC) AS row_no,
item_no
from purchasing_v_item i
where i.active = 1
)s1
where s1.row_no < 10000
--where s1.row_no >= 10000

select 
top 5
item_no,
brief_description
from purchasing_v_item i
where i.active = 1
and i.brief_description like '%,%'

*/
--export all the active items with descriptions

  select
--  count(*) cnt
  s1.item_no,
  -- Binary Key to replace characters which cause issues in CSV files: # = 0, @ = 1
  REPLACE(REPLACE(brief_description, ',', '###'), '"', '##@') brief_description
  --ESCAPE COMMAS AND NO DOUBLE QUOTES
  -- s1.brief_description
--  brief_description as original
  from
  (
    select 
    row_number() OVER(ORDER BY i.item_no ASC) AS row_no,
    item_no,
    brief_description
    from purchasing_v_item i
    where i.active = 1
    and i.item_no not like '%[-" ]%'
    and brief_description <> ''

  )s1
  where row_no > 15000 
--  where row_no > 10000 and row_no <= 15000 
-- where row_no > 5000 and row_no <= 10000 
-- where row_no <= 5000 
--  where item_no = '006696'  -- comma
--where row_no > 5040 and row_no <= 5050 

/*
select
--top 100 *
count(*) cnt
from
(
  select
  item_no
  from purchasing_v_item i
  -- where i.item_no not like '%[R]' 
  -- and i.item_no not like 'BE%'  
  where i.active = 1  --18643
  --where i.item_no like '0%[R]' --2679 
  --where i.item_no like '%[R]' --3600 
  --where i.item_no like '[^0]%[R]' --921
  --and i.active = 0  
)s1
*/
--select count(*) #SupplyItem from  #SupplyItem  --18643