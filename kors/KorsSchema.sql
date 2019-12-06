-- Drop table

-- DROP TABLE master.dbo.CommandLog GO

CREATE TABLE Kors.dbo.HourlyOEEValues (
	ID int IDENTITY (1,1) NOT NULL,
	Workcenter_Code varchar(50),
	Job_number varchar(20),
	Part_number varchar(60),
	Workcenter_status varchar(50),
	Data_hour INT,
	Hourly_planned_production_count INT,
	Hourly_actual_production_count INT,
	Cumulative_planned_production_count INT,
	Cumulative_actual_production_count INT,
	scrap_count INT,
	Downtime_minutes INT,
	Date_time_stamp DATETIME,
	Transaction_number BIGINT
) GO
  

declare @dt datetime; 
set @dt = '2014-07-02 14:29';
INSERT INTO Kors.dbo.HourlyOEEValues 
(Workcenter_Code, Job_number, Part_number, Workcenter_status, Data_hour, Hourly_planned_production_count, Hourly_actual_production_count, Cumulative_planned_production_count, Cumulative_actual_production_count, scrap_count, Downtime_minutes, Date_time_stamp, Transaction_number) 
VALUES(' VSC_4', '1210', '4140', 'Production', 10, 41, 38, 834,582, 0, 0,'2014-07-02 14:29', 0); 

  