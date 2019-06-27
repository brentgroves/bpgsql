
/*
Test: 10 
Verify that there are no spaces in the item number field. 
*/

select  
--count(*) 
--top 10 
item_no
from purchasing_v_item i  
left outer join purchasing_v_item_type it
on i.item_type_key=it.item_type_key
WHERE LTRIM(RTRIM(item_no)) like '%' + ' ' + '%'  --are there any spaces
and item_type = 'Maintenance'


/*
Test: 15 
Verify that the description field is being formatted correctly 
*/
select 
item_no,Description 
from purchasing_v_item  
where item_no in
(
'BE800300','BE999997','BE139987','BE000668','BE600005','BE999000','BE200703','BE650002AV' 
)

--VendorNumber,Manufacturer,ManufactuerNumber 
--000 800300 
--001 999997  |            |            |02120             | 
--010 139987  |            |MORI SEIKI  |                  | 
--011 000668  |            |SIEMENS     |1FT6044-4AF71-4AA6| 
--100 600005  |6408M-22MM  |            |                  | 
--101 999000  |945         |            |945               | 
--110 200703  |800EPMJ3    |Allen Bradley|                  | 
--111 650002AV|54041462    |Kendall Electric|SUPER33+          | 

/*
Test: 20 
Verify that items with a newline in the notes field display correctly on the Supply Item detail screen. 
*/
select  
--count(*) 
--top 10 
item_no,
note
from purchasing_v_item i  
left outer join purchasing_v_item_type it
on i.item_type_key=it.item_type_key
where item_no
in
(
'BE100988','BE708991','BE200800','BE100012','BE100011'
)
and item_type = 'Maintenance'
--where notestext like '%'+CHAR(10)+'%' --2503 
--where notestext like '%'+char(13)+'%' --2503 
--where notestext like '%'+char(13)+CHAR(10)+'%' -- 2503 --THESE ARE THE ASCII VALUES THAT GET STORED IN THE DATABASE (0x0D 0x0A) 
--where notestext like '%'+char(13)+'%'  
--and notestext not like '%'+CHAR(10)+'%' --0 
--where notestext like '%'+char(10)+'%'  
--and notestext not like '%'+CHAR(13)+'%' --0 
  

/*
Test: 25 
Verify that item_type field contains ‘Maintenance’. 
*/
Item No	Description	Supplier Code	Item Type	Supplier Item No	Unit Price(s)
select  
count(*) 
--top 10 
--item_no,
--note
from purchasing_v_item i  
left outer join purchasing_v_item_type it
on i.item_type_key=it.item_type_key
where item_type = 'Maintenance'


/*
Test: 30 
Verify that Item_Group field is identical to EM categoryId.  Check for nulls 
*/

select  
--count(*) 
--top 10 
item_no,
ig.item_group
from purchasing_v_item i  
left outer join purchasing_v_item_type it
on i.item_type_key=it.item_type_key
left outer join purchasing_v_item_group ig
on i.item_group_key=ig.item_group_key
where 
item_group is null or item_group = ''
/*
item_no
in
(
'BE100988','BE708991','BE200800','BE100012','BE100011'
)
*/
and item_type = 'Maintenance'

/*
item_no |item_group     
--------|---------------
BE100011|B Axis         
BE100012|B Axis         
BE100988|OEM Okuma parts
BE200800|Switch, General
BE708991|Pumps          
*/

/*
Test: 33 
Verify that the Item_Category contains only ‘Electronics’,’Pumps’,’Covers’ or ‘General’. 
Verify the count of parts with the categories of ‘Electronics’,’Pumps’,’Covers’ or ‘General’
Verify that all parts with a categoryid of ‘pump kits’,’Pump Parts’, and ‘Pumps’ have all been mapped to a category of Pumps.  
Verify that all parts with a categoryid of ‘Cover’ has been mapped to item_category of ‘Covers’. 
Verify that all parts with a categoryid of ‘Electronics’ has been mapped to item_category of ‘Electronics’. 
*/

select  
--count(*) 
--top 10 
item_no,
ic.item_category
from purchasing_v_item i  
left outer join purchasing_v_item_type it
on i.item_type_key=it.item_type_key
left outer join purchasing_v_item_category ic
on i.item_category_key=ic.item_category_key
where 
item_type = 'Maintenance'
and item_category NOT in
(
'Electronics','Pumps','Covers','General'
)
and item_category =  'Electronics'
--and item_category =  'Pumps'
--and item_category =  'Covers'
--and item_category =  'General'
/*
numbered|categoryid
--------|----------
700869  |Pump Kits 
000154  |Pump Parts
708991  |Pumps     
*/
and item_no in
(
'BE700869','BE000154','BE708991'
)
/*
numbered|categoryid
--------|----------
100033  |Cover      
*/
and item_no = 'BE100033'
/*
numbered|categoryid 
--------|-----------
200713  |Electronics
 */
and item_no = 'BE200713'


/*
Test: 35 
Verify that Item_Priority is low for all. 
*/
select  
--count(*) 
--top 10 
item_no,
item_priority
from purchasing_v_item i  
left outer join purchasing_v_item_type it
on i.item_type_key=it.item_type_key
left outer join purchasing_v_item_priority ip
on i.item_priority_key=ip.item_priority_key
where 
item_type = 'Maintenance'
and item_priority <> 'Low'

/*
Test: 40 
Verify that Customer_Unit_Price contains the same amounts as in EM. 
*/

select  
--count(*) 
--top 10 
item_no,
Customer_Unit_Price
from purchasing_v_item i  
left outer join purchasing_v_item_type it
on i.item_type_key=it.item_type_key
where 
item_type = 'Maintenance'
and item_no
in
(
'BE100988','BE708991','BE200800','BE100012','BE100011'
)
/*
item_no |Customer_Unit_Price|
--------|-------------------|
BE100011|            9.96300|
BE100012|           23.74200|
BE100988|         2517.79000|
BE200800|           80.96000|
BE708991|          636.00000|
*/

/*
Test: 45 
Verify that Average_Cost is 0. 
*/

select  
--count(*) 
--top 10 
item_no,
Average_Cost
from purchasing_v_item i  
left outer join purchasing_v_item_type it
on i.item_type_key=it.item_type_key
where 
item_type = 'Maintenance'
and Average_Cost <> 0

/*
Test: 50 
Verify that there are no blank units.
Verify blank parts.units map to Ea
Verify that Each maps to Ea
Verify that Electrical maps to Ea
Verify EA count is correct
Verify that Box maps to Box and count is correct
Verify that Case maps to case and count is correct
Verify that Dozen maps to dozen and count is correct
Verify that Feet maps to Feet and count is correct
Verify that Gallons maps to Gallons and count is correct
Verify that INCHES maps to inches and count is correct
Verify that Meters maps to meters and count is correct
Verify that Per 100 maps to hundred and count is correct
Verify that Per Package maps to Package 
Verify that Package maps to Package 
Verify count of Package correct
Verify that Pounds maps to lbs and count is correct
Verify that Quart maps to quart and count is correct
Verify that Roll maps to Roll and count is correct
Verify that Set maps to set and count is correct
*/
select 
item_no,
inventory_unit
from purchasing_v_item i  
left outer join purchasing_v_item_type it
on i.item_type_key=it.item_type_key
where item_type = 'Maintenance'
and inventory_unit = '' or inventory_unit is null
and inventory_unit = 'Box'  --Count
and inventory_unit = 'case'
and inventory_unit = 'dozen'
and inventory_unit = 'Ea'
and inventory_unit = 'Feet'
and inventory_unit = 'Gallons'
and inventory_unit = 'inches'
and inventory_unit = 'meters'
and inventory_unit = 'hundred'
and inventory_unit = 'Package'
and inventory_unit = 'lbs'
and inventory_unit = 'quart'
and inventory_unit = 'Roll'
and inventory_unit = 'set'
and item_no in 
(
--Plex/EM unit
'BE000030',--set / Set
'BE110000',--Ea / blank
'BE200000',--hundred / Per 100
'BE200020',--Ea / Electrical
'BE200539', --meters / Meters
'BE200570',--Feet / Feet
'BE200603',--case / Case
'BE450820',--Box / Box
'BE500008',--Package / Per Package
'BE500025',--Package / Package
'BE650006', --Roll / Roll
'BE700984',--dozen / Dozen
'BE705529', --inches /Inches
'BE800300',--quart / Quart
'BE990003',--lbs / Pounds
'BE999000',--Ea / Each
'BE999002'--Gallons / Gallons
)
order by item_no

/*
Test: 55 
Verify that Min_Quantity contains EM.MinimumOnHand. 
*/

select 
item_no,
Min_Quantity
from purchasing_v_item i  
left outer join purchasing_v_item_type it
on i.item_type_key=it.item_type_key
where item_type = 'Maintenance'
and item_no
in
(
'BE100988','BE708991','BE200800','BE100012','BE100011'
)
order by item_no
/*
numbered|MinimumOnHand
--------|-------------
100011  |      4.00000
100012  |      8.00000
100988  |      0.00000
200800  |      1.00000
708991  |      1.00000
*/

/*
Test: 60 
Verify that when EM.minimumOnHand > EM.maxOnHand then plex Max_Quantity gets set to 0
Verify that in other cases that Max_Quantity gets set to EM.MaxOnHand
CASE
	when (minimumOnHand is not null) and (MaxOnHand is not null) and (minimumOnHand > MaxOnHand) and (MaxOnHand <> 0) then 0
	else MaxOnHand
end as Max_Quantity,

numbered|RecordNumber|MinimumOnHand|MaxOnHand
--------|------------|-------------|---------
100988  |        9901|      0.00000|  1.00000
705286A |        6223|     10.00000|  1.00000
705334A |        6274|      2.00000|  1.00000

*/

select 
item_no,
Min_Quantity,Max_Quantity
from purchasing_v_item i  
left outer join purchasing_v_item_type it
on i.item_type_key=it.item_type_key
where item_type = 'Maintenance'
and item_no
in
(
'BE705334','BE705286','BE100988'
)
order by item_no

/*
Test: 65 
Verify the tax code on the Supply Item detail screen the tax code says 'Tax Exempt - Labor / Industrial Processing' 
'Tax Exempt - Labor / Industrial Processing' as Tax_Code,
*/

select 
item_no,i.tax_code_no,tax_code
from purchasing_v_item i  
left outer join purchasing_v_item_type it
on i.item_type_key=it.item_type_key
left outer join purchasing_v_tax_code tc
on i.tax_code_no=tc.tax_code_no
where item_type = 'Maintenance'
and tc.tax_code <> 'Tax Exempt - Labor / Industrial Processing' 



select 
top 100
item_no,
Account_No

from purchasing_v_item i  
left outer join purchasing_v_item_type it
on i.item_type_key=it.item_type_key
where item_type = 'Tooling'

--where item_type = 'Maintenance'
and item_no
in
(
'BE705334','BE705286','BE100988'
)
order by item_no






























