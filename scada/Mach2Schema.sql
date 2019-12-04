DROP TABLE IF EXISTS DS13318
CREATE TABLE DS13318(
  DS13318_Key INT NOT NULL AUTO_INCREMENT,
  TransDate datetime DEFAULT NULL,
  PCN varchar(50) NULL,
  ProdServer bool NULL,
  Workcenter varchar(50) NULL,
  CNC varchar(25) NULL,
  Part_No varchar(50) NULL,
  Name varchar(50) NULL,
  Multiple bool NULL,
  Container_Note varchar(50) NULL,
  Cavity_Status_Key INT NULL,
  Container_Status varchar(50) NULL,
  Defect_Type varchar(50) NULL,
  Serial_No varchar(50) NULL,
  Setup_Container_Key INT NULL,
  Count MEDIUMINT NULL,
  Part_Count MEDIUMINT NULL,
  Part_Key INT NULL,
  Part_Operation_Key INT NULL,
  Standard_Container_Type varchar(50) NULL,
  Container_Type_Key INT NULL,
  Parent_Part varchar(50) NULL,
  Parent varchar(50) NULL,
  Cavity_No varchar(50) NULL,
  Master_Unit_Key INT NULL DEFAULT 0,
  Workcenter_Printer_Key INT NULL,
  Master_Unit_No varchar(50) NULL,
  Physical_Printer_Name varchar(50) NULL,
  Container_Count MEDIUMINT NULL,
  Container_Quantity MEDIUMINT NULL,
  Default_Printer varchar(50) NULL,
  Default_Printer_Key INT NULL,
  Class_Key INT NULL,
  Quantity INT NULL,
  Companion bool NULL,
  Container_Type varchar(50) NULL,
  Container_Type_Description varchar(100) NULL,
  Sort_Order MEDIUMINT NULL,
  PRIMARY KEY (DS13318_Key)
)  ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Control_Panel_Setup_Containers_Get_Key historian';

DROP PROCEDURE DS13318;

CREATE PROCEDURE DS13318 (
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


CALL DS13318('2019-12-15 09:00');
drop PROCEDURE test1
CREATE PROCEDURE test1 ()
BEGIN
	select * from DS13318;
END;
call test1
SELECT CONVERT_TZ('2004-01-01 12:00:00','+00:00','+10:00');
