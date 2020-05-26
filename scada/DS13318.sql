

delete from DS13318 d
CALL DS13318('2019-12-15 09:00');
show databases
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

CREATE DEFINER=`brent`@`%` PROCEDURE `mach2`.`DS13318`(
    IN  p_TransDate VARCHAR(25)
)
BEGIN
	
/* set @p_TransDate = '2019-12-15 09:00'; */
drop temporary table if exists ProdServer;
create temporary table ProdServer engine=memory	
select 
TransDate,Workcenter,CNC,Name,Part_no,Serial_No,ProdServer,Quantity,Container_Status 
from DS13318 
where TransDate = p_TransDate and ProdServer = 1; 

drop temporary table if exists TestServer;
create temporary table TestServer engine=memory	
select 
TransDate tst_TransDate,Workcenter tst_Workcenter,CNC tst_CNC,Name tst_Name, Part_no tst_Part_No,Serial_No tst_Serial_No,ProdServer tst_ProdServer,Quantity tst_Quantity,Container_Status tst_Container_Status
from DS13318 
where TransDate = p_TransDate and ProdServer = 0; 

select 
TransDate,Workcenter,CNC,Name,Part_no,Serial_No,tst_Serial_No, Quantity,tst_Quantity, Container_Status,
case 
when Serial_No <> tst_Serial_No then 'Red'
when ((Serial_No = tst_Serial_No) and (Quantity <> tst_Quantity)) then 'Yellow'
when ((Serial_No = tst_Serial_No) and (Quantity = tst_Quantity)) then 'Green'
when ((Serial_No = tst_Serial_No) and (Quantity is Null) and (tst_Quantity is Null)) then 'Green'
end Status
from ProdServer ps
left outer join TestServer ts
on ps.TransDate = ts.tst_TransDate
and ps.Workcenter = ts.tst_Workcenter
and ps.Part_No = ts.tst_Part_No
and ps.Container_Status = ts.tst_Container_Status
order by ps.TransDate,ps.Part_no,ps.Serial_no,ps.Container_Status;

END;
