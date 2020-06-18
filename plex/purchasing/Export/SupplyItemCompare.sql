-- truncate/drop table PlxAlbSupplyItem0615
-- truncate table PlxAlbSupplyItem0615
CREATE TABLE PlxAlbSupplyItem0615 (
	item_no varchar(50),
	brief_description varchar (60)
)
/*
 * sudo docker cp AlbionLE5000.csv db:/AlbionLE5000.csv
 * Open terminal and open an interactive terminal to the running docker container. 
 * sudo sudo docker exec -it db /bin/bash
 * verify the file was copied to the container.
 */
LOAD DATA INFILE '/var/lib/mysql-files/AlbionLE5000.csv' INTO TABLE PlxAlbSupplyItem0615 FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA INFILE '/var/lib/mysql-files/AlbionLE10000.csv' INTO TABLE PlxAlbSupplyItem0615 FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA INFILE '/var/lib/mysql-files/AlbionLE15000.csv' INTO TABLE PlxAlbSupplyItem0615 FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA INFILE '/var/lib/mysql-files/AlbionGT15000.csv' INTO TABLE PlxAlbSupplyItem0615 FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

select count(*) from PlxAlbSupplyItem0615;  -- Albion 06/15,18,602
select * from PlxAlbSupplyItem0615 pasi 
LOAD DATA 
  INFILE '/home/brent/CSV/AlbionLE5000.csv' 
  INTO TABLE PlxAlbSupplyItem0615 
  FIELDS 
    TERMINATED BY ',' 
  LINES 
    TERMINATED BY '\n' 
  IGNORE 1 ROWS;
-- (item_no,@brief_description)     
-- SET brief_description = REPLACE(REPLACE(brief_description, '###', ','), '##@', '"');  --CAN'T GET THIS TO WORK YET.
-- SET brief_description = REPLACE(@brief_description,'@','"'); 

select count(*) from PlxAlbSupplyItem0615;  -- Albion 06/15,18,602
  
-- DECODE CSV CHARACTER MAPPINGS
update PlxAlbSupplyItem0615 
set brief_description = REPLACE(REPLACE(brief_description, '###', ','), '##@', '"')


select
-- count(*)
*
from PlxAlbSupplyItem0615 limit 100 offset 0


-- drop table PlxEdonSupplyItem0615
-- truncate table PlxEdonSupplyItem0615
CREATE TABLE PlxEdonSupplyItem0615 (
	item_no varchar(50),
	brief_description varchar (80)
)

-- Insert Plex item_location data into CM
LOAD DATA INFILE '/var/lib/mysql-files/EdonLE5000.csv' INTO TABLE PlxEdonSupplyItem0615 FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA INFILE '/var/lib/mysql-files/EdonLE10000.csv' INTO TABLE PlxEdonSupplyItem0615 FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA INFILE '/var/lib/mysql-files/EdonLE15000.csv' INTO TABLE PlxEdonSupplyItem0615 FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA INFILE '/var/lib/mysql-files/EdonLE20000.csv' INTO TABLE PlxEdonSupplyItem0615 FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA INFILE '/var/lib/mysql-files/EdonLE25000.csv' INTO TABLE PlxEdonSupplyItem0615 FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA INFILE '/var/lib/mysql-files/EdonGT25000.csv' INTO TABLE PlxEdonSupplyItem0615 FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

select count(*) from PlxEdonSupplyItem0615;  -- Edon 06/17,25,986 ADDED Inactive items
select * from PlxEdonSupplyItem0615 pasi 

LOAD DATA 
  INFILE '/EdonGT15000.csv' 
  INTO TABLE PlxEdonSupplyItem0615 
  FIELDS 
    TERMINATED BY ',' 
  LINES 
    TERMINATED BY '\n' 
  IGNORE 1 ROWS;


select
count(*)
from 
(
select distinct item_no from PlxEdonSupplyItem0615
)s1  -- Edon 06/17, 25986

-- DECODE CSV CHARACTER MAPPINGS
update PlxEdonSupplyItem0615 
set brief_description = REPLACE(REPLACE(brief_description, '###', ','), '##@', '"')


select
-- count(*)
*
from PlxEdonSupplyItem0615 limit 100 offset 0


/*
 * These are all the active Albion supply items that are not in Edon's PCN.
 */
select
-- alb.item_no 
-- edon.item_no
 count(*)
from PlxAlbSupplyItem0615 alb
left outer join PlxEdonSupplyItem0615 edon
on alb.item_no=edon.item_no -- 18602
where edon.item_no is null  -- 3744  --06/17 Added Edon's inactive items and reduced this from 3766
-- and left(alb.item_no,1) <> '0'  -- 212
-- and left(alb.item_no,1) = '0'  -- 3533
-- limit 100 offset 0
-- order by alb.item_no

select
count(*)
from PlxAlbSupplyItem0615 alb
left outer join PlxEdonSupplyItem0615 edon
on alb.item_no=edon.item_no 
where edon.item_no is null  -- 3744
limit 100 offset 0


select
count(*)
--top 1000 * 
from PlxAlbSupplyItem0610 alb
inner join PlxEdonSupplyItem0610 edon
on alb.item_no=edon.item_no  --14876

/*  
Verify the 3767 missing items are in Edon’s supply list with leading zeros stripped. 
How to trim leading zeros and spaces

Return the position of a pattern in a string:
select  Patindex('%[^0 ]%', '0078956'); --3

SELECT Substring('0078956', Patindex('%[^0]%', '0078956'), Len('0078956') ) AS Trimmed_Leading_0;
SELECT Substring('0078956', Patindex('%[^0 ]%', '0078956'), Len('0078956') ) AS Trimmed_Leading_0_and_space;
SELECT Substring('0078956', Patindex('%[^0 ]%', '0078956' + ' '), Len('0078956') ) AS Trimmed_Leading_0_and_space;
0000010
0000011
0000030
0000057
0000066
0000070
**/

-- MSSQL SYNTAX???
IF OBJECT_ID(N'tempdb..#NotInEdon') IS NOT NULL
BEGIN
DROP TABLE #NotInEdon
END

DROP TABLE IF EXISTS NotInEdon;
CREATE TABLE NotInEdon (
	item_no varchar(50),
	trmItemNo varchar (60),
  	brief_description varchar (80)
);

INSERT into NotInEdon (item_no,trmItemNo,brief_description)
(
select
alb.item_no,
TRIM(LEADING '0' FROM alb.item_no) AS trmItemNo,
alb.brief_description
-- substring(alb.item_no,patindex('%[^0]%',alb.item_no),len(alb.item_no)) trmItemNo  --MSSQL
-- drop table #NotItEdon
from PlxAlbSupplyItem0615 alb
left outer join PlxEdonSupplyItem0615 edon
on alb.item_no=edon.item_no 
where edon.item_no is null  -- 3744
order by alb.item_no
)


select count(*) NotInEdon from NotInEdon  --3744
select * from NotInEdon limit 100 offset 0

/*
 * Are these supply items in Edon with the leading zeros removed? 
 */
TRUNCATE TABLE MakeInactive;
DROP TABLE IF EXISTS MakeInactive;
CREATE TABLE MakeInactive (
	item_no varchar(50)
);

INSERT into MakeInactive (item_no)
(
select 
ned.item_no
from NotInEdon ned
left outer join PlxEdonSupplyItem0615 ed
on ned.trmItemNo=ed.item_no
and ned.brief_description=ed.brief_description 
where ed.item_no is not null  -- 3496 
)

-- select count(*) MakeInactive from MakeInactive
-- select * from MakeInactive limit 100 offset 0

select 
i.item_no,
ned.trmItemNo,
ned.brief_description 
from MakeInactive i 
inner join NotInEdon ned
on i.item_no=ned.item_no 


/*
 * There are some Albion supply items to import into Edon that do not
 * need to be made inactive. 
 */
-- truncate table DoNotMakeInactive 
DROP TABLE IF EXISTS DoNotMakeInactive;
CREATE TABLE DoNotMakeInactive (
	item_no varchar(50)
);

INSERT into DoNotMakeInactive (item_no)
(
select 
ned.item_no
from NotInEdon ned
left outer join PlxEdonSupplyItem0615 ed
on ned.trmItemNo=ed.item_no
and ned.brief_description=ed.brief_description 
where ed.item_no is null  -- 248
)


-- select count(*) DoNotMakeInactive from DoNotMakeInactive  --254
-- select * from DoNotMakeInactive

select 
ned.*
from MakeInactive i 
inner join NotInEdon ned 
on i.item_no = ned.item_no 

select 
ned.* 
from DoNotMakeInactive i
inner join NotInEdon ned 
on i.item_no = ned.item_no 

--export all the active items with descriptions from plex
select
s1.item_no,
brief_description
from
(
select 
row_number() OVER(ORDER BY i.item_no ASC) AS row_no,
item_no,
brief_description
from purchasing_v_item i
where i.active = 1
)s1
--where s1.row_no <= 5000
--where s1.row_no > 5000 and s1.row_no <= 10000
--where s1.row_no > 10000 and s1.row_no <= 15000
where s1.row_no > 15000


/*
 * Drop tables
 * 
 */

-- drop table PlxAlbSupplyItem0612
-- drop table PlxEdonSupplyItem0612