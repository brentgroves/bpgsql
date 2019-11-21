select 
count(*)
/*
TransDate,Part_no,Serial_No,ProdServer,Cycle_Counter_Shift_SL,Quantity,Container_Status 
*/
from DS13318
/*where ProdServer = 1*/
order by TransDate,Part_no,Serial_no
/*
 * 40
 */
