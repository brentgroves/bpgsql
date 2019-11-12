DROP TABLE IF EXISTS DS13318
CREATE TABLE DS13318(
  DS13318_Key INT NOT NULL AUTO_INCREMENT,
  TransDate datetime DEFAULT NULL,
  PCN varchar(50) NULL,
  ProdServer bool NULL,
  Cycle_Counter_Shift_SL int NULL,
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
