-- Kors.dbo.HourlyOEEValues definition

-- Drop table

-- DROP TABLE Kors.dbo.HourlyOEEValues GO
/*
CREATE TABLE Kors.dbo.HourlyOEEValues (
	ID int IDENTITY(1,1) NOT NULL,
	Workcenter_Code varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Job_number varchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Part_number varchar(60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Data_hour int NULL,
	Hourly_planned_production_count int NULL,
	Hourly_actual_production_count int NULL,
	Cumulative_planned_production_count int NULL,
	Cumulative_actual_production_count int NULL,
	scrap_count int NULL,
	Downtime_minutes float NULL,
	Date_time_stamp datetime NULL
) GO;
*/

/*
1. RUN QUERY
select 
	Workcenter_Code,
	Job_number,
	Part_number,
	Data_hour,
	Hourly_planned_production_count,
	Hourly_actual_production_count,
	Cumulative_planned_production_count,
	Cumulative_actual_production_count,
	scrap_count,
	Downtime_minutes,
	Date_time_stamp
from HourlyOEEValues ho 
2 choose export from result window from context menu.
choose quote always false, and select quote never.
3 copy csv to docker container
start docker conainer
sudo docker cp Kors.csv db:/Kors.csv

Open ImportHourlyOEEValues.sql and connect to docker containers database
LOAD DATA INFILE '/Kors.csv'  
INTO TABLE discounts
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(title,@expired_date,amount)
SET expired_date = STR_TO_DATE(@date_time_stamp, '%m/%d/%Y');

*/
