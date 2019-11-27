select 
/*
count(*)
*/
TransDate,Part_no,Serial_No,ProdServer,Quantity,Container_Status 
from DS13318
where TransDate > '2019-11-27'
/*where ProdServer = 1*/
order by TransDate,Part_no,Serial_no
/*
 * 40
 */
