-- truncate/drop truncate table PlxAlbSupplyItem0619
-- truncate table PlxAlbSupplyItem0619
CREATE TABLE PlxAlbSupplyItem0619 (
	item_no varchar(50),
	brief_description varchar (80)
)
/*
 * sudo docker cp AlbionLE5000.csv db:/AlbionLE5000.csv
 * Open terminal and open an interactive terminal to the running docker container. 
 * sudo sudo docker exec -it db /bin/bash
 * verify the file was copied to the container.
 */
/*
LOAD DATA INFILE '/var/lib/mysql-files/AlbionLE5000.csv' INTO TABLE PlxAlbSupplyItem0619 FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA INFILE '/var/lib/mysql-files/AlbionLE10000.csv' INTO TABLE PlxAlbSupplyItem0619 FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA INFILE '/var/lib/mysql-files/AlbionLE15000.csv' INTO TABLE PlxAlbSupplyItem0619 FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA INFILE '/var/lib/mysql-files/AlbionGT15000.csv' INTO TABLE PlxAlbSupplyItem0619 FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
-- If in docker container use the following
LOAD DATA INFILE '/AlbionLE5000.csv' INTO TABLE PlxAlbSupplyItem0619 FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA INFILE '/AlbionLE10000.csv' INTO TABLE PlxAlbSupplyItem0619 FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA INFILE '/AlbionLE15000.csv' INTO TABLE PlxAlbSupplyItem0619 FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA INFILE '/AlbionGT15000.csv' INTO TABLE PlxAlbSupplyItem0619 FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
*/

select count(*) from PlxAlbSupplyItem0619;  -- Albion 06/19,18595
select count(*) -- Albion 06/19,18595
from 
(
select distinct item_no from PlxAlbSupplyItem0619 pasi 
)s1;
select * from PlxAlbSupplyItem0619 pasi 

  
-- DECODE CSV CHARACTER MAPPINGS
update PlxAlbSupplyItem0619 
set brief_description = REPLACE(REPLACE(REPLACE(REPLACE(brief_description, '###', ','), '##@', '"'),'#@#',CHAR(10)),'#@@',CHAR(13)),


select
-- count(*)
*
from PlxAlbSupplyItem0619 limit 100 offset 0


-- drop table PlxEdonSupplyItem0615
-- truncate table PlxEdonSupplyItem0620
CREATE TABLE PlxEdonSupplyItem0620 (
	item_no varchar(50),
	brief_description varchar (80)
)

/*
LOAD DATA INFILE '/var/lib/mysql-files/EdonLE5000.csv' INTO TABLE PlxEdonSupplyItem0615 FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA INFILE '/var/lib/mysql-files/EdonLE10000.csv' INTO TABLE PlxEdonSupplyItem0615 FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA INFILE '/var/lib/mysql-files/EdonLE15000.csv' INTO TABLE PlxEdonSupplyItem0615 FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA INFILE '/var/lib/mysql-files/EdonLE20000.csv' INTO TABLE PlxEdonSupplyItem0615 FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA INFILE '/var/lib/mysql-files/EdonLE25000.csv' INTO TABLE PlxEdonSupplyItem0615 FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA INFILE '/var/lib/mysql-files/EdonGT25000.csv' INTO TABLE PlxEdonSupplyItem0615 FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
-- If importing into MySQL db container use the following
LOAD DATA INFILE '/EdonLE5000.csv' INTO TABLE PlxEdonSupplyItem0620 FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA INFILE '/EdonLE10000.csv' INTO TABLE PlxEdonSupplyItem0620 FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA INFILE '/EdonLE15000.csv' INTO TABLE PlxEdonSupplyItem0620 FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA INFILE '/EdonLE20000.csv' INTO TABLE PlxEdonSupplyItem0620 FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA INFILE '/EdonLE25000.csv' INTO TABLE PlxEdonSupplyItem0620 FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA INFILE '/EdonGT25000.csv' INTO TABLE PlxEdonSupplyItem0620 FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
*/
select count(*) from PlxEdonSupplyItem0620;  -- Edon 06/20=28,276,  06/19=25,995 ADDED Inactive items
select * from PlxEdonSupplyItem0620 pasi limit 100 


select
count(*)
from 
(
select distinct item_no from PlxEdonSupplyItem0620
)s1  -- Edon 06/20, 28,276

-- DECODE CSV CHARACTER MAPPINGS
update PlxEdonSupplyItem0620 
set brief_description = REPLACE(REPLACE(brief_description, '###', ','), '##@', '"')


select
-- count(*)
*
from PlxEdonSupplyItem0620 limit 100 offset 0


/*
 * These are all the active Albion supply items that are not in Edon's PCN.
 */
select
-- alb.item_no 
-- edon.item_no
 count(*)
from PlxAlbSupplyItem0619 alb
left outer join PlxEdonSupplyItem0620 edon
on alb.item_no=edon.item_no -- 18602
where edon.item_no is null  -- 06/20=1461 
-- and left(alb.item_no,1) <> '0'  -- 06/20=9
and left(alb.item_no,1) = '0'  -- 06/20=1452
-- where edon.item_no is null  -- 06/19=3742 Added Edon's inactive items and reduced this from 3766
-- and left(alb.item_no,1) <> '0'  -- 06/19=217
-- and left(alb.item_no,1) = '0'  -- 06/19=3525
-- limit 100 offset 0
-- order by alb.item_no

/*  
Verify the 3742 missing items are in Edon’s supply list with leading zeros stripped. 
How to trim leading zeros and spaces
*/


/* 
 * I accidentally deleted the NotInEdon from 06/19 recordset that had all the supply items
 * that needed to be imported into Edon's supply item PCN before the 06/19 import.
 */
-- DROP TABLE IF EXISTS NotInEdon;
TRUNCATE TABLE NotInEdon0620;
CREATE TABLE NotInEdon0620 (
	row_no int,
	item_no varchar(50),
	trmItemNo varchar (60),
  	brief_description varchar (80)
);

INSERT into NotInEdon0620 (row_no,item_no,trmItemNo,brief_description)
(
select
row_number() OVER(ORDER BY alb.item_no ASC) AS row_no,
alb.item_no,
TRIM(LEADING '0' FROM alb.item_no) AS trmItemNo,
alb.brief_description
-- substring(alb.item_no,patindex('%[^0]%',alb.item_no),len(alb.item_no)) trmItemNo  --MSSQL
-- drop table #NotItEdon
from PlxAlbSupplyItem0619 alb
left outer join PlxEdonSupplyItem0620 edon
on alb.item_no=edon.item_no 
where edon.item_no is null  -- 06/20=1461
-- where edon.item_no is null  -- 06/190=3742
-- order by alb.item_no
)


select count(*) NotInEdon from NotInEdon0620  -- 06/20=1461,06/19=3742
select * from NotInEdon0620 limit 100 offset 0

/*
 * Are these supply items in Edon with the leading zeros removed? 
 * DID NOT TOUCH THIS ON 06/20.  It contains the recordset from just before the 06/19 Edon Supply Item import
 */
-- drop TABLE MakeInactive;
-- truncate TABLE MakeInactive;
CREATE TABLE MakeInactive (
	item_no varchar(50),
  	brief_description varchar (80)
);
select * from MakeInactive mi;
INSERT into MakeInactive (item_no,brief_description)
(
select 
ed.item_no,
ned.brief_description
from NotInEdon ned
left outer join PlxEdonSupplyItem0620 ed
on ned.trmItemNo=ed.item_no
and ned.brief_description=ed.brief_description 
where ed.item_no is not null  -- 3489 
)

-- select count(*) MakeInactive from MakeInactive  -- 3489
-- select * from MakeInactive limit 100 offset 0

select 
i.item_no,
-- i.brief_description 
REPLACE(i.brief_description, CHAR(13), '') as brief_description
from MakeInactive i limit 100 offset 3400


/*
 * There are some Albion supply items to import into Edon that do not
 * need to be made inactive. 
 * DID NOT TOUCH THIS ON 06/20.  It contains the recordset from just before the 06/19 Edon Supply Item import
 * 
 */
-- truncate table DoNotMakeInactive 
DROP TABLE IF EXISTS DoNotMakeInactive;
CREATE TABLE DoNotMakeInactive (
	item_no varchar(50),
  	brief_description varchar (80)
);

INSERT into DoNotMakeInactive (item_no,brief_description)
(
select 
ned.item_no,
ned.brief_description
from NotInEdon ned
left outer join PlxEdonSupplyItem0615 ed
on ned.trmItemNo=ed.item_no
and ned.brief_description=ed.brief_description 
where ed.item_no is null  -- 248
)


-- select count(*) DoNotMakeInactive from DoNotMakeInactive  --255
-- select * from DoNotMakeInactive



/*
 * 
 * Find ranges of item_no to export from Albion's PCN so
 * that we don't have to export all 18,000 records.
 * Pay close attention to the character coalation sequence
 * because it may be different between MSSQL and MySQL 
 * databases.
 * MYSQL supply items needing imported sequence ranges.
 * 007*
 * 008*
 * BE207*
 * BE450*
 * BE851*
 * MSSQL sequence
 * 
 * The trick is to pull block of supply items from the source PCN
 * that will encompass a block of the subset of supply items that need to
 * be imported into the destination PCN.  Only export 250 supply items at a time
 * although it may be tempting to do more.  I believe you could 
 * export a huge recordset from Plex but I don't trust it not to corrupt the data.
 * Limit yourself to the length that will show fully when you execute the query
 * from the SDE.
 * 
 * 
 * 
 */

select 
-- count(*) cnt
 nie.row_no,nie.item_no,nie.trmItemNo, nie.brief_description
from NotInEdon0620 nie 
-- where row_no <= 200 
-- NotInEdon0620 range: {1=0003040, 200=0003523}, record count: 200
-- where item_no >= '0003524' and item_no <='0004057'
-- WHERE item_no > '0004057' and item_no <= '0004578'  
-- WHERE item_no > '0004578' and item_no <= '0005239'  
-- WHERE item_no > '007085' and item_no <= '0005239'  
-- WHERE item_no > '007592' and item_no <= '0005239'  
-- WHERE item_no > '008093' and item_no <= '0005239'  
-- WHERE item_no > '008094' and item_no <= '0008399'  
-- WHERE item_no > '008399' and item_no <= '008624'  
-- WHERE item_no >= 'BE207212' and item_no <= 'BE450133' 
WHERE item_no >= 'BE450713' and item_no <= 'BE851453' 

-- where item_no > '011815'  -- row 3507  '01814441','17207'
-- and item_no <= '17207'


/*
 * Drop tables
 * 
 */

-- drop table PlxAlbSupplyItem0612
-- drop table PlxEdonSupplyItem0612