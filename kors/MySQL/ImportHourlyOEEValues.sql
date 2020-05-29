/*  MSSQL DDL
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

MYSQL DDL
-- Kors.HourlyOEEValues definition
CREATE TABLE `HourlyOEEValues` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `Workcenter_Code` varchar(50) DEFAULT NULL,
  `Job_number` varchar(20) DEFAULT NULL,
  `Part_number` varchar(60) DEFAULT NULL,
  `Data_hour` int DEFAULT NULL,
  `Hourly_planned_production_count` int DEFAULT NULL,
  `Hourly_actual_production_count` int DEFAULT NULL,
  `Cumulative_planned_production_count` int DEFAULT NULL,
  `Cumulative_actual_production_count` int DEFAULT NULL,
  `scrap_count` int DEFAULT NULL,
  `Downtime_minutes` float DEFAULT NULL,
  `Date_time_stamp` datetime DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=673 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
*/
-- TRUNCATE TABLE HourlyOEEValues 
LOAD DATA INFILE '/Kors.csv'  
INTO TABLE HourlyOEEValues 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(	Workcenter_Code,
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
)
-- ENCLOSED BY '"' not needed if there are no special characters in the dataset.
-- SET expired_date = STR_TO_DATE(@expired_date, '%Y-%m-%d %h-%i-%s');
-- STR_TO_DATE not needed if your in an acceptable MySQL datetime format.
select count(*) from HourlyOEEValues;  -- 48278
-- select * from HourlyOEEValues LIMIT 100;


-- %Y	Year as a numeric, 4-digit value
-- %m	Month name as a numeric value (00 to 12)
-- %d	Day of the month as a numeric value (01 to 31)
-- %k	Hour (0 to 23)
-- %i	Minutes (00 to 59)
-- %s	Seconds (00 to 59)

-- /home/brent/srcsql/bpgsql/kors/MySQL/Import.csv
-- https://www.mysqltutorial.org/import-csv-file-mysql-table/
CREATE TABLE discounts (
    id INT NOT NULL AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    expired_date DATE NOT NULL,
    amount DECIMAL(10 , 2 ) NULL,
    PRIMARY KEY (id)
);
/*
id.title,expired_date,amount
1,"Spring Break 2014",01/04/2014,20
2,"Back to School 2014",01/09/2014,25
3,"Summer 2014",06/25/2014,10
*/

/*
 * PATH IS LOCAL TO THE DATABASE SERVER IN THIS CASE
 * would have to move import file to docker container.
 */
LOAD DATA INFILE '/Import.csv'  
INTO TABLE discounts
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(title,@expired_date,amount)
SET expired_date = STR_TO_DATE(@expired_date, '"%Y-%m-%d %h-%i-%s"');
select * from discounts;
/*
 * PATH IS LOCAL TO THE DATABASE CLIENT IN THIS CASE
 * THIS IS SLOWER
 */
LOAD DATA LOCAL INFILE  '/home/brent/srcsql/bpgsql/kors/MySQL/Import.csv'
INTO TABLE discounts
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(title,@expired_date,amount)
SET expired_date = STR_TO_DATE(@expired_date, '%m/%d/%Y');

select * from discounts d 



