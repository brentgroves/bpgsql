/*
 * Do we have a workcenter record for all the workcenters in the dsr? 
 * Does each workcenter on the Daily Shift Report have its own director labor rate?
 */
create view Plex.workcenter_view 
as 
select 
pcn,
Plexus_Customer_Code,
Workcenter_Key,
Workcenter_Code,
Name,
Workcenter_Type,
Material_Key,
Part_Key,
Part_Operation_Key,
Heat_Key,
Note,
Part_No,
Revision,
Operation_Key,
Operation_Code,
Heat_Code,
Building_Code,
Workcenter_Group,
Workcenter_Size,
Finite_Percent,
Building_Key,
Overhead_Cost,
Variable_Cost,
Setup_Cost,
Account_No,
Cost_Unit,
Department_code,
Shift_Cycle,
Direct_Labor_Cost,
Documents,
Lifetime,
Maintenance_Cost,
Fair_Market_Value,
PLC_Name,
IPAddress,
Sort_Order,
Other_Burden_Cost,
Shift_Cycle_Key,
Active,
case 
when Direct_Labor_Cost = 0 then 50
else 0
end valid
from 
Plex.Workcenter w 

select * 
--select count(*)
from Plex.Workcenter_view 
where valid != 0 -- 50
where valid = 0 -- 650

select * 
-- select distinct pcn
--into archive.workcenter_03_17
from Plex.Workcenter w 
where pcn = 295932	
and Direct_Labor_Cost is not null
where Direct_Labor_Cost is null -- 0

select * from Plex.Daily_Shift_Report_view dsr 
-- join on Workcenter_Key,Part_Key,Part_Operation_Key 
Create view Plex.workcenter_no_labor_rate
as 
with workcenter 
as 
(
	select w.valid,w.Direct_Labor_Cost,ds.* 
--	select count(*)
	from Plex.Daily_Shift_Report_view ds -- 13,616
	left outer join Plex.Workcenter_view w 
	on ds.pcn = w.PCN 
	and ds.workcenter_key = w.Workcenter_Key 
	--where w.PCN is null  -- 0
),
no_labor_rate
as 
(
	select *
	from workcenter  
	where valid = 50
)
select * 
--select count(*)
from no_labor_rate -- 220

-- mgdw.Plex.Workcenter definition

-- Drop table

-- DROP TABLE mgdw.Plex.Workcenter;

CREATE TABLE mgdw.Plex.Workcenter (
	PCN int NOT NULL,
	Plexus_Customer_Code varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Workcenter_Key int NOT NULL,
	Workcenter_Code nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	Name nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	Workcenter_Type nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	Material_Key int NULL,
	Part_Key int NULL,
	Part_Operation_Key int NULL,
	Heat_Key int NULL,
	Note nvarchar(1500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	Part_No nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	Revision nvarchar(8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	Operation_Key int NULL,
	Operation_Code nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	Heat_Code nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	Building_Code nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	Workcenter_Group nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	Workcenter_Size decimal(19,5) NULL,
	Finite_Percent decimal(19,5) NULL,
	Building_Key int NOT NULL,
	Overhead_Cost decimal(19,5) NOT NULL,
	Variable_Cost decimal(19,5) NOT NULL,
	Setup_Cost decimal(19,5) NOT NULL,
	Account_No nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Cost_Unit nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	Department_code nvarchar(60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Shift_Cycle nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	Direct_Labor_Cost decimal(19,5) NOT NULL,
	Documents int NOT NULL,
	Lifetime decimal(19,5) NOT NULL,
	Maintenance_Cost decimal(19,5) NOT NULL,
	Fair_Market_Value decimal(19,5) NOT NULL,
	PLC_Name nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	IPAddress nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	Sort_Order int NOT NULL,
	Other_Burden_Cost decimal(19,5) NOT NULL,
	Shift_Cycle_Key int NOT NULL,
	Active int NOT NULL
);
 CREATE CLUSTERED INDEX IX_Plex_Workcenter ON Plex.Workcenter (  PCN ASC  , Workcenter_Key ASC  )  
	 WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  )
	 ON [PRIMARY ] ;