-- Drop table

-- DROP TABLE master.dbo.CommandLog GO

CREATE TABLE Kors.dbo.HourlyOEEValues (
	ID int IDENTITY(1,1) NOT NULL,
	Workcenter_Code varchar(50),
	Job_No varchar(20),
	Part_No varchar(100),
	Description varchar(50),
	
	DatabaseName sysname COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	SchemaName sysname COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	ObjectName sysname COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	ObjectType char(2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	IndexName sysname COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	IndexType tinyint NULL,
	StatisticsName sysname COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	PartitionNumber int NULL,
	ExtendedInfo xml NULL,
	Command nvarchar COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	CommandType nvarchar(60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	StartTime datetime NOT NULL,
	EndTime datetime NULL,
	ErrorNumber int NULL,
	ErrorMessage nvarchar COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	CONSTRAINT PK_CommandLog PRIMARY KEY (ID)
) GO
  
/*
 * Workcenter_Status is in part_v_workcenter_status.description
 */




Data hour 

INT 

4 

Hourly planned production count 

INT 

4 

Hourly actual production count 

INT 

4 

Cumulative planned production count 

INT 

4 

Cumulative actual production count 

INT 

4 

Scrap count 

INT 

4 

Downtime minutes 

INT 

4 

Date/time stamp 

DATETIME 

  

Transaction number 

BIGINT 

8 

  