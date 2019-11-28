

CALL DS13318('2019-11-27 13:30');

select 
TransDate,Part_no,Serial_No,ProdServer,Quantity,Container_Status 
from DS13318
where TransDate >= '2019-11-27 13:01:00' 
order by TransDate,Part_no,Serial_no;

select 
count(*)
from DS13318
where TransDate >= '2019-11-27 13:01:00' 
order by TransDate,Part_no,Serial_no;
