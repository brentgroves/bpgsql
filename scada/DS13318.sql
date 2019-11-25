select 
/*
count(*)
*/
TransDate,Part_no,Serial_No,ProdServer,Quantity,Container_Status 
from DS13318
where TransDate >= "2019-11-25 16:00:00"
/*where ProdServer = 1*/
order by TransDate desc,Part_no,Serial_no

/*
delete from DS13318 where TransDate > "2019-11-21"
 */
*/

select * from DS13318 where TransDate >= "2019-11-25 16:00:00"