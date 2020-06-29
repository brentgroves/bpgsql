-- drop table Kep13319
CREATE TABLE Kep13319 (
	kep13319Key int(11) NOT NULL AUTO_INCREMENT,
  	nodeId varchar(50) DEFAULT NULL,
  	name varchar(50) DEFAULT NULL,
  	plexus_Customer_No int(11) DEFAULT NULL,
	pcn varchar(50) DEFAULT NULL,
  	workcenter_Key int(11) DEFAULT NULL,
  	workcenter_Code varchar(50) DEFAULT NULL,
  	cnc varchar(6) DEFAULT NULL,
  	value int(11) DEFAULT NULL,
  	transDate datetime DEFAULT NULL,
  	PRIMARY KEY (Kep13319Key)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COMMENT='OPC Client historian';

set @transDate = '2020-06-25 00:00:00';
call InsKep13319('test','partCounter', 123,'Avilla',123, 'CNC103', '103', 5, @transDate); 
select * from Kep13319 k 
-- drop procedure InsKep13319
CREATE PROCEDURE InsKep13319
(
  	IN nodeId varchar(50),
  	IN name varchar(50),
  	IN plexus_Customer_No int(11),
	IN pcn varchar(50),
  	IN workcenter_Key int(11),
  	IN workcenter_Code varchar(50),
  	IN cnc varchar(6),
  	IN value int(11),
  	IN transDate datetime
)
BEGIN
   
INSERT INTO Kep13319 
(nodeId,name,plexus_Customer_No,pcn, workcenter_Key,workcenter_Code,cnc,value,transDate)
VALUES(nodeId,name,plexus_Customer_No,pcn, workcenter_Key,workcenter_Code,cnc,value,transDate);

-- Display the last inserted row.
select kep13319Key, workcenter_Key from Kep13319 k where Kep13319Key=(SELECT LAST_INSERT_ID());

END;

