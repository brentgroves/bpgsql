

delete from DS13318 d
CALL DS13318('2019-12-15 09:00');

select TransDate,Part_no,Serial_No,ProdServer,Quantity,Container_Status from DS13318 where TransDate = '2019-12-15 09:00'
delete from DS13318 where TransDate = '2019-12-15 09:00'
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

select CONVERT_TZ(TransDate,'+00:00','-5:00')TransDate2,
DATE_FORMAT(TransDate, "%W %M %e %Y"),
TransDate,Part_no,Workcenter,Serial_No,ProdServer,Quantity,Container_Status 
from DS13318