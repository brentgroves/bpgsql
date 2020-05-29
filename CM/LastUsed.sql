-- DROP TABLE master.dbo.CommandLog GO

create table PlxLastUsed
(
item_no varchar (50),
Description varchar (800),
Last_Used datetime,
Last_Purchased datetime,
Active smallint, 
Quantity decimal (18,2), 
Cost decimal (19,4), 
CM smallint
);

CREATE TABLE CMLastUsed (
	ID int IDENTITY (1,1) NOT NULL,
	itemNumber varchar(12),
	Description1 varchar(50),
	
	
create table #results
(
item_no varchar (50),
Description varchar (800),
Last_Used datetime,
Last_Purchased datetime,
Active smallint, 
Quantity decimal (18,2), 
Cost decimal (19,4), 
CM smallint
);
create table #last_used
(
item_no varchar (50),
Description varchar (800),
Last_Used datetime,
Active smallint
);
insert into #last_used (item_no, description,last_used,active)
(
select 
pi.item_no,
substring(pi.description,1,25) description,
max(iu.usage_date) last_used,
pi.active
from purchasing_v_item pi
left outer join purchasing_v_item_usage iu
on pi.item_key=iu.item_key
left outer join Purchasing_v_Item_Usage_Transaction_Type tt
on iu.transaction_type_key = tt.transaction_type_key
group by pi.item_no,pi.active,pi.description,tt.transaction_type
having tt.transaction_type='Checkout'
)

create table #last_purchased
(
item_no varchar (50),
Last_Purchased datetime,
unit_cost decimal (19,4) 

);

insert into #last_purchased (item_no, last_purchased, unit_cost)
(

select 
lp.item_no,
lp.last_purchased,
uc.unit_cost
from
(
select 
--top 10
pi.item_no,
max(iu.usage_date) last_purchased
from purchasing_v_item pi
left outer join purchasing_v_item_usage iu
on pi.item_key=iu.item_key
left outer join Purchasing_v_Item_Usage_Transaction_Type tt
on iu.transaction_type_key = tt.transaction_type_key
group by pi.item_no,tt.transaction_type
having tt.transaction_type='PO Receipt'
) lp
left outer join 
(
select 
--top 10
pi.item_no,
iu.usage_date,
round(iu.cost / iu.quantity, 2, 1) unit_cost
from purchasing_v_item pi
left outer join purchasing_v_item_usage iu
on pi.item_key=iu.item_key
left outer join Purchasing_v_Item_Usage_Transaction_Type tt
on iu.transaction_type_key = tt.transaction_type_key
where tt.transaction_type='PO Receipt'
) uc
on lp.item_no=uc.item_no
and lp.last_purchased=uc.usage_date
)

create table #on_hand
(
item_no varchar (50),
on_hand decimal (18,2)
);

insert into #on_hand (item_no, on_hand)
(
select 
--top 10
pi.item_no,
case
when sum(quantity) is null then 0.0
else sum(quantity)
end on_hand 
from purchasing_v_item pi
left outer join purchasing_v_item_location il
on pi.item_key=il.item_key
group by pi.item_no

)

select
--count(*)
item_no,description,last_used,last_purchased,on_hand,unit_cost
from
(
select 
ROW_NUMBER() over(order by lu.item_no asc) as row#,
lu.item_no,lu.description,lu.last_used,lp.last_purchased,oh.on_hand,lp.unit_cost
from 
#last_used lu
left outer join #last_purchased lp
on lu.item_no=lp.item_no
left outer join #on_hand oh
on lu.item_no=oh.item_no
)lv1
--where row# > 1500 and row# <= 3000 
where row# <= 1500 
--count is 
