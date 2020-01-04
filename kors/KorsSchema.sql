-- Drop table

-- drop TABLE Kors.dbo.HourlyOEEValues
CREATE TABLE Kors.dbo.HourlyOEEValues (
	ID int IDENTITY (1,1) NOT NULL,
	Workcenter_Code varchar(50),
	Job_number varchar(20),
	Part_number varchar(60),
	Data_hour INT,
	Hourly_planned_production_count INT,
	Hourly_actual_production_count INT,
	Cumulative_planned_production_count INT,
	Cumulative_actual_production_count INT,
	scrap_count INT,
	Downtime_minutes float,
	Date_time_stamp DATETIME
) 

select * from hourlyoeevalues
declare @dt datetime;
set @dt = '2014-07-02 14:29';
INSERT INTO Kors.dbo.HourlyOEEValues
(Workcenter_Code, Job_number, Part_number, Workcenter_status, Data_hour, Hourly_planned_production_count, Hourly_actual_production_count, Cumulative_planned_production_count, Cumulative_actual_production_count, scrap_count, Downtime_minutes, Date_time_stamp, Transaction_number)
VALUES(' VSC_4', '1210', '4140', 'Production', 10, 41, 38, 834,582, 0, 0,'2014-07-02 14:29', 0);
drop procedure InsertHourlyOEEValues
CREATE PROCEDURE InsertHourlyOEEValues
	@Workcenter_Code varchar(50),
	@Job_number varchar(20),
	@Part_number varchar(60),
	@Data_hour INT,
	@Hourly_planned_production_count INT,
	@Hourly_actual_production_count INT,
	@Cumulative_planned_production_count INT,
	@Cumulative_actual_production_count INT,
	@scrap_count INT,
	@Downtime_minutes float,
	@Date_time_stamp DATETIME
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
   
-- Table variable   
DECLARE @MyTableVar table( ID int,
                           Workcenter_Code varchar(50));
   
INSERT INTO Kors.dbo.HourlyOEEValues
(Workcenter_Code, Job_number, Part_number, Data_hour, Hourly_planned_production_count, Hourly_actual_production_count, Cumulative_planned_production_count, Cumulative_actual_production_count, scrap_count, Downtime_minutes, Date_time_stamp)
OUTPUT INSERTED.ID, INSERTED.Workcenter_Code
into @MyTableVar
VALUES(@Workcenter_Code, @Job_number, @Part_number, @Data_hour, @Hourly_planned_production_count, @Hourly_actual_production_count, @Cumulative_planned_production_count, @Cumulative_actual_production_count, @scrap_count, @Downtime_minutes, @Date_time_stamp);
--values (' VSC_5', '1210', '4140', 'Production', 10, 41, 38, 834,582, 0, 0,'2014-07-02 14:29', 0)

--Display the result set of the table variable.
SELECT ID, Workcenter_Code FROM @MyTableVar;
--Display the result set of the table.
--select * from HourlyOEEValues h

END;

exec InsertHourlyOEEValues ' VSC_5', '1210', '4140', 10, 41, 38, 834,582, 0, 0,'2014-07-02 14:29'
select * from HourlyOEEValues h
--1011
delete from HourlyOEEValu
select * from users
select * from messages
--delete from messages
--drop table messages
--drop table users


-- Drop table

-- DROP TABLE Kors.dbo.messages GO

/*

-- Drop table

-- DROP TABLE Kors.dbo.users GO

CREATE TABLE Kors.dbo.users (
	id int IDENTITY(1,1) NOT NULL,
	email nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	password nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	createdAt datetime2(7) NULL,
	updatedAt datetime2(7) NULL,
	CONSTRAINT PK__users__3213E83F75DF73F6 PRIMARY KEY (id)
) GO
 CREATE  UNIQUE NONCLUSTERED INDEX users_email_unique ON dbo.users (  email ASC  )  
	 WHERE  ([email] IS NOT NULL)
	 WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  )
	 ON [PRIMARY ]  GO
declare @dt datetime;
set @dt = '2014-07-02 14:29';

INSERT INTO Kors.dbo.users
(email, password, createdAt, updatedAt)
VALUES('', '', '', '');
select * from users

 */


