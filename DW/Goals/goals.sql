create schema Goals
Name 
Parent 
Description  
Reason 
Plan 
Due 

create table Goals.goal_dependancy 
( 
	goal_key int not null,
	goal_dependancy_key int not null,
	CONSTRAINT PK_goal_dependancy PRIMARY KEY (goal_key,goal_dependancy_key)
)
-- truncate table Goals.goal_dependancy 
insert into Goals.goal_dependancy 
values 
(6,8 ) -- Plex tooling module dependancy
,(7,8) -- Plex tooling module dependancy
,(12,11) -- 'Setup a two VM Ubuntu 20.04 Kubernetes Cluster'
-- drop table Goals.status 
create table Goals.status 
(  
	status_key int not null,
	name varchar(100),
	abbreviation varchar(50),
	CONSTRAINT PK_status PRIMARY KEY (status_key)
)
insert into Goals.status 
values
(1,'not started','NS'),
(2,'in progress','IP'),
(3,'done','DN')

-- drop table Goals.goal 
create table Goals.goal 
(
	goal_key int not null,
	name varchar(100) not null,
	parent_goal_key int null,
	reason varchar(max) null,
	team varchar(250) null,
	work_week_start int null,
	work_week_end int null,
	priority int null,
	status_key int null,
	CONSTRAINT PK_goal PRIMARY KEY (goal_key)
)
-- truncate table Goals.goal
insert into Goals.goal 
values
(14
,'Fastest cycle time'
,4
,'Needed for production count estimates and locating any CNC that are running slower.'
,'Jason Conwell,Cliff Burkhart'
,1
,52
,60
,1
)
,(13
,'Update MSC Vending Machine with Plex Tooling module data.'
,8
,'In oder to link Plex job information to tooling cost.'
,'MSC employee'
,1
,52
,58
,1
)
,(12
,'Setup JupyterHub'
,11
,'These notebooks will combine text and dynamic output of SQL procedures to' +
'summarize datasource validation.'
,'IS Team'
,1
,52
,50
,1
)

,(11
,'Setup a two VM Ubuntu 20.04 Kubernetes Cluster'
,10
,'This will be used for the tooling data collection app and the Jupyter Notebook server.'
,'IS and IT Team'
,1
,52
,40
,1
)
,(10
,'IS VM Setup'
,null
,'Several VM will be needed to perform IS computing tasks.'
,'IT team'
,1
,52
,1
,1
)
,(9  
,'Initial Plex module setup'
,null
,'Work needs to be done to add additional functionality to Plex.'
,'Kevin Young'
,1
,52
,5
,1
)
,(8
,'Plex Tooling module'
,9 
,'Before collecting CNC information pertaining to tooling it is desirable to ' + 
' relate that data to existing Plex data for unified reporting.' 
,'Nancy Swank, Jason Conwell'
,1
,52
,52
,1
)
,(14 
,'Fastest cycle time'
,4
,'Needed for production count estimates and locating any CNC that are running slower.'
,'Jason Conwell,Cliff Burkhart'
,1
,52
,60
)

,(7 
,'Tool and pallet change time data collection'
,4
,'Need to collect tool and pallet change times to report CNC maintenance issues.'
,'Jason Conwell, Bob Jones'
,1
,52
,80
,1
)
,(6 
,'Tooling cut time data collection'
,4
,'Need to collect tooling cut time data to report which tools are taking the most amount of time.'
,'Jason Conwell,Cliff Burkhart,Bob Jones'
,1
,52
,70
,1
)
,(5 
,'Tool life data collection'
,4
,'Need to collect tool life data to report CNC or operator tooling issues.'
,'Jason Conwell,Cliff Burkhart'
,1
,52
,60
,1
)
,(4
,'Create IIOT data collection applications for Mobex reporting.'
,null 
,'Some information is more easily gathered directly from the CNC as opposed concerning In addition to It is desirable to '
,'Jason Conwell,Cliff Burkhart'
,1
,52
,1
,1
)
,(3
,'Validate Trial Balance report data sources'
,1 
,'The Plex ERP system contains a huge amount of information and data can get entered wrong. ' +
'So it is recommended that checks are made to ensure the information we are reporting is accurate.'
,'Greg Philips'
,1
,15
,10
,1
)
,(2
,'Validate Daily Metrics report data sources'
,1 
,'The Plex ERP system contains a huge amount of information and data can get entered wrong.' + 
'So it is recommended that checks are made to ensure the information we are reporting is accurate.'
,'Greg Philips,'
,1
,16
,20
,1
)
,(1 
,'Examine Plex data sources for issues.'
,null
,'The Plex ERP system contains a huge amount of information and data can get entered wrong. ' +
'So it is recommended that checks are made to ensure the information we are reporting is accurate.'
,'Brad Cook'
,1
,52
,1
,1
)

	goal_key int not null,
	name varchar(100) not null,
	parent_goal_key int null,
	reason varchar(max) null,
	team varchar(250) null,
	work_week_start int null,

--drop view Goals.goal_view
create view Goals.goal_view
as 
with goal_dependancy 
as
(
	select dep.goal_key,
	      LEFT(dep.depend_list,Len(dep.depend_list)-1) As "depend_list"
	from 
	(
	  select g.goal_key,
	  ( 
	  	select g2.name + ',' as [text()]
	  	from Goals.goal_dependancy gd
	  	join Goals.goal g2
	  	on gd.goal_dependancy_key=g2.goal_key
	  	where g.goal_key = gd.goal_key
	  	for xml path (''),TYPE 
	  ).value('text()[1]','nvarchar(max)') [depend_list]
	  from Goals.goal g
	--  where g.goal_key in (6,7)
	) dep  
),
--select * from dep 
goal 
as 
(
	select 
	g.goal_key, 
	g.priority, 
	g.name, 
	gp.goal_key parent_goal_key,
	case 
	when gp.goal_key is null then ''
	else gp.name
	end parent_goal, 
	gd.depend_list, 
	g.reason, 
	g.team,
	g.work_week_start,
	g.work_week_end,
	s.name status,
	s.abbreviation 
	from Goals.goal g
	left outer join Goals.goal gp 
	on g.parent_goal_key = gp.goal_key 
	left outer join goal_dependancy gd 
	on g.goal_key = gd.goal_key 
	left outer join Goals.status s 
	on g.status_key = s.status_key 
)
select * from goal 	
	
exec Goals.goal_by_name 
-- drop procedure Goals.goal_by_name 
create procedure Goals.goal_by_name 
as 
begin 
	select 
	priority, 
	name goal,
	parent_goal parent_goal,
	v.depend_list,
	reason,
	team,
	work_week_start, 
	work_week_end,
	status,
	abbreviation 
	from 
	Goals.goal_view v
	where v.parent_goal_key is not null
	order by priority 
end
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

