select 'Grinding' area,l.location,'"' + i.item_no + '"' item_no,cast(il.quantity as int) quantity 
from common_v_location_e l
left outer join purchasing_v_item_location_e il
on l.plexus_customer_no = il.plexus_customer_no
and l.location = il.location
left outer join purchasing_v_item_e i 
on il.plexus_customer_no = i.plexus_customer_no
and il.item_key= i.item_key
where 
l.plexus_customer_no = '300758'
and 
(
(l.location like 'GR-B1%') or
(l.location like 'GR-C1%') or
(l.location like 'GR-C') or
(l.location like 'GR-E'))
and i.item_key is not null
union
select 'Plant 8' area,l.location,'"' + i.item_no + '"',cast(il.quantity as int) quantity 
from common_v_location_e l
left outer join purchasing_v_item_location_e il
on l.plexus_customer_no = il.plexus_customer_no
and l.location = il.location
left outer join purchasing_v_item_e i 
on il.plexus_customer_no = i.plexus_customer_no
and il.item_key= i.item_key
where 
l.plexus_customer_no = '300758'
and
((l.location like '01-CUB2[A-Z]%') or 
(l.location like '01-CUB4[A-Z]%') or
(l.location like '01-CUB[247][A-Z]%') or
(l.location like '01-CUB27[A-Z]%') or
(l.location like '01-AA%') or
(l.location like '01-A02%') or
(l.location like '01-N01%') or
(l.location like '01-A01%') or
-- (l.location like '01-H%') or
(l.location like '01-L01%') or
(l.location like '01-N02%')) 
-- (l.location like '01-A') or
--(l.location like '01-J%'))
and i.item_key is not null


/*
Do you mean all of the 01-A,H,J row locations.
That is a big list especially since you specified specific
rows such as A2,A1,L1 and N2.
*/