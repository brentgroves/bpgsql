/*
What info to track:

Good afternoon, Kevin

I think an IS goals schema could be used to manage and report on 
goals that may not be practical by using the ADP software alone. 

If individuals help to maintain their own goal list we could all be 
more aware of an involved in the goal setting process.

In addition to what is required by Mobex we could be collecting additional 
data such as how long it takes us to complete each step in the reporting 
process.

Maintaining and updating a simple goal schema is not hard and 
it could be updated as much as needed so that we are collecting the 
data we want to report on.

I think an added benefit is that, if we are more aware of our goals 
maybe we could be discussing updates to them throughout the year.

If we get this going maybe next April the goal setting process 
would become so natural to us that it would be trivial to 
meet any Mobex deadlines.
 



If it is ok with you we could list the goals we know
about now and continue to update this list throughout the year.

Jeff was saying we can update this list through out the year.

 */
create schema Goals


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

-- drop table Goals.goal_type 
create table Goals.goal_type 
(  
	goal_type_key int not null,
	name varchar(100),
	CONSTRAINT PK_goal_type_key PRIMARY KEY (goal_type_key)
)
insert into Goals.goal_type 
values
(1,'report'),
(2,'data collection')

-- drop table Goals.step 
create table Goals.step 
(  
	step_key int not null,
	order_no int,
	name varchar(100),
	hours int,
	step_status_key int,
	CONSTRAINT PK_step_key PRIMARY KEY (step_key)
)
insert into Goals.step 
values
(1,1,'get requirements',1,1),
(2,2,'find data sources',1,1),
(3,3,'create ETL scripts',1,1),
(4,4,'identify issues with data sources',1,1),
(5,5,'transform data in data sources to get desired values',1,1),
(6,6,'join the values to get result set',1,1),
(7,7,'customer review of the result set',1,1)
select * from Goals.step
-- drop table Goals.step_status 
create table Goals.step_status 
(  
	step_status_key int not null,
	name varchar(100),
	abbreviation varchar(50),
	CONSTRAINT PK_step_status PRIMARY KEY (step_status_key)
)
insert into Goals.step_status 
values
(1,'not started','NS'),
(2,'in progress','IP'),
(3,'done','DN')
select * from Goals.step_status 

-- drop table Goals.goal_step
create table Goals.goal_step 
(  
	goal_step_key int not null,
	goal_key int not null,
	step_key int not null,
	CONSTRAINT PK_goal_step_key PRIMARY KEY (goal_step_key)
)
insert into Goals.goal_step 
values
(1,2,1),
(2,2,2),
(3,2,3),
(4,2,4),
(5,2,5),
(6,2,6),
(7,2,7)


-- drop table Goals.goal_type_step
create table Goals.goal_type_step 
(  
	goal_type_step_key int not null,
	goal_type_key int not null,
	goal_step_key int not null,
	CONSTRAINT PK_goal_type_step_key PRIMARY KEY (goal_type_step_key)
)
insert into Goals.goal_type_step 
values
(1,1,1),
(2,1,2)

-- drop table Goals.goal 
create table Goals.goal 
(
	goal_key int not null,
	goal_type_key int not null,
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
,1
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
,3
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
,3
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
,3
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
,3
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
,3
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
,3
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
,(7 
,3
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
,3
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
,3
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
,3
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
,3
,'Trial Balance report'
,1 
,'The Plex Trial Balance report no longer works correctly for our older PCN, Southfield. ' +
'It does not include all accounts. Make a new report that includes all accounts.'
,'Greg Philips'
,1
,15
,10
,1
)
,(2
,1
,'Daily Metrics report'
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
,3
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

select * from Goals.goal_view	
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
	st.order_no,
	st.name step,
	st.hours, 
	ss.name step_status,
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
	left outer join Goals.goal_step gs 
	on g.goal_key=gs.goal_key
	left outer join Goals.step st 
	on gs.step_key = st.step_key 
	left outer join Goals.step_status ss 
	on st.step_status_key = ss.step_status_key 
	
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
	step,
	order_no,
	hours,
	step_status,
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
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

