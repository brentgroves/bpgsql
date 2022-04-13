create schema Wiki
create table Wiki.topic
( 
	topic_key int not null,
	name varchar(100) not null,
	CONSTRAINT PK_topic PRIMARY KEY (topic_key)
)
-- truncate table Wiki.topic
insert into Wiki.topic 
values 
(2,'managing')
,(1,'administration')

-- drop table Wiki.tag
create table Wiki.tag
( 
	tag_key int not null,
	name varchar(100) not null,
	CONSTRAINT PK_tag PRIMARY KEY (tag_key)
)
-- truncate table Wiki.tag
insert into Wiki.tag 
values 
(1,'goals')
,(2,'objectives')
,(3,'JupyterHub')
,(4,'Kubernetes')
,(5,'K8s')
,(6,'projects')
-- drop table Wiki.wiki_tag
create table Wiki.wiki_tag
( 
	wiki_tag_key int not null,
	wiki_key int not null,
	tag_key int not null,
	CONSTRAINT PK_wiki_tag PRIMARY KEY (wiki_tag_key)
)
-- truncate table Wiki.wiki_tag 
insert into Wiki.wiki_tag 
values 
(1,1,3)
,(2,1,4)
,(3,1,5)
,(4,2,1)
,(5,2,2)
,(6,2,6)
-- drop table Wiki.wiki
create table Wiki.wiki
( 
	wiki_key int not null,
	topic_key int not null,
	name varchar(100) not null,
	note varchar(max) not null,
	CONSTRAINT PK_wiki PRIMARY KEY (wiki_key)
)
-- How do you restart a JupyterHub container
-- docker start -a 221331c047c4
-- select * from Wiki.wiki
-- truncate table Wiki.wiki
insert into Wiki.wiki
values 
(2
,2
,'Goals'
,'I think an IS goals schema could be used to manage and report on goals that may not be practical by using the ADP software alone.'
+ CHAR(10) + CHAR(13)
+'If individuals help to maintain their own goal list we could all be more aware of an involved in the goal setting process.'
+ CHAR(10) + CHAR(13)
+ 'In addition to what is required by Mobex we could be collecting additional data such as how long it takes us to complete each step in the reporting process.'
+ CHAR(10) + CHAR(13)
+ 'Maintaining and updating a simple goal schema is not hard and it could be updated as much as needed so that we are collecting the data we want to report on.'
+ CHAR(10) + CHAR(13)
+ 'I think an added benefit is that, if we are more aware of our goals maybe we could be discussing updates to them throughout the year.'
+ CHAR(10) + CHAR(13)
+ 'If we get this going maybe next April the goal setting process would become so natural to us that it would be trivial to meet any Mobex deadlines.'
)
,(1
,1
,'JupyterHub'
,'How to restart a container: ' 
+ 'docker start -a 221331c047c4' + CHAR(10) + CHAR(13)
+ 'The number after the -a is the container id'
+ ' that you can find by running the following command:'  
+ ' docker container ls -a'
)

select * from Wiki.wiki_view 
create view Wiki.wiki_view 
as 
with tag_list 
as  
(  
	select tl.wiki_key,
	      LEFT(tl.tag_list,Len(tl.tag_list)-1) As "tag_list"
	from 
	(
		select w.wiki_key,
		(
		  	select t.name + ',' as [text()]
		  	from Wiki.wiki_tag wt 
		  	join Wiki.tag t
		  	on wt.tag_key=t.tag_key
		  	where wt.wiki_key=w.wiki_key
		  	for xml path (''),TYPE 
		).value('text()[1]','nvarchar(max)') [tag_list]
		from Wiki.wiki w	
	) tl 
)
select 
w.name wiki 
,t.name topic
,tl.tag_list tags
,w.note note 
from Wiki.wiki w 
join Wiki.topic t 
on w.topic_key=t.topic_key 
join tag_list tl 
on w.wiki_key = tl.wiki_key 

