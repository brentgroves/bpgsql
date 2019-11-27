select 
/*
count(*)
*/
TransDate,Part_no,Serial_No,ProdServer,Quantity,Container_Status 
from DS13318
where TransDate > '2019-11-27'
/*where ProdServer = 1*/
order by TransDate,Part_no,Serial_no

CREATE PROCEDURE DS13318()
BEGIN
select 
TransDate,Part_no,Serial_No,ProdServer,Quantity,Container_Status 
from DS13318
where TransDate > '2019-11-27'
order by TransDate,Part_no,Serial_no;
END;
 
DROP PROCEDURE DS13318;
 
CREATE PROCEDURE DS13318 (
    IN  transDate VARCHAR(25)
)
BEGIN
select 
TransDate,Part_no,Serial_No,ProdServer,Quantity,Container_Status 
from DS13318
where TransDate = transDate 
order by TransDate,Part_no,Serial_no;
END;

CALL DS13318('2019-11-27 13:30');

select 
TransDate,Part_no,Serial_No,ProdServer,Quantity,Container_Status 
from DS13318
where TransDate >= '2019-11-27 13:01:00' 
order by TransDate,Part_no,Serial_no;

where TransDate >= '2019-11-27 13:01' and TransDate <= endDate
