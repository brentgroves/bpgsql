--truncate table PlxAlbSupplyItem0612
CREATE TABLE Cribmaster.dbo.PlxAlbSupplyItem0612 (
	item_no varchar(50),
	brief_description varchar (50)
)

-- Insert Plex item_location data into CM
Bulk insert PlxAlbSupplyItem0612
from 'c:\AlbionLE10000.csv'
with
(
	fieldterminator = ',',
	rowterminator = '\n'
)


select
--count(*)
top 1000 * 
from PlxAlbSupplyItem0612--18643

--drop table PlxEdonSupplyItem0612
CREATE TABLE Cribmaster.dbo.PlxEdonSupplyItem0612 (
	item_no varchar(50),
	brief_description varchar (75)
)

-- Insert Plex item_location data into CM

Bulk insert PlxEdonSupplyItem0612
from 'c:\EdonGT15000.csv'
with
(
	fieldterminator = ',',
	rowterminator = '\n'
)


select
count(*)
--top 1000 * 
from 
(
select distinct item_no from dbo.PlxEdonSupplyItem0612
)s1
--from PlxEdonSupplyItem0612--18790





select
--alb.item_no
--count(*)
top 1000 * 
from PlxAlbSupplyItem0610 alb
left outer join PlxEdonSupplyItem0610 edon
on alb.item_no=edon.item_no 
where edon.item_no is null  --3767
order by alb.item_no

select
count(*)
from PlxAlbSupplyItem0610 alb
left outer join PlxEdonSupplyItem0610 edon
on alb.item_no=edon.item_no 
where edon.item_no is null  --3767


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


IF OBJECT_ID(N'tempdb..#NotInEdon') IS NOT NULL
BEGIN
DROP TABLE #NotInEdon
END

select
alb.item_no,
substring(alb.item_no,patindex('%[^0]%',alb.item_no),len(alb.item_no)) trmItemNo
into #NotInEdon
--drop table #NotItEdon
from PlxAlbSupplyItem0610 alb
left outer join PlxEdonSupplyItem0610 edon
on alb.item_no=edon.item_no 
where edon.item_no is null  --3767
order by alb.item_no

select count(*) #NotInEdon from #NotInEdon  --3767
select top 100 * from #NotInEdon

/*
 * Are these supply items in Edon with the leading zeros removed? 
 */
IF OBJECT_ID(N'tempdb..#MakeInactive') IS NOT NULL
BEGIN
DROP TABLE #MakeInactive
END

select 
--top 1000
--count(*) cnt
ed.item_no
into #MakeInactive
from #NotInEdon ned
left outer join PlxEdonSupplyItem0610 ed
on ned.trmItemNo=ed.item_no
where ed.item_no is not null  --3513


--select count(*) #MakeInactive from #MakeInactive
--select top 1000 * from #MakeInactive

/*
 * There are some Albion supply items to import into Edon that do not
 * need to be made inactive. 
 */
IF OBJECT_ID(N'tempdb..#DoNotMakeInactive') IS NOT NULL
BEGIN
DROP TABLE #DoNotMakeInactive
END

select 
--top 1000
--count(*) cnt
ned.item_no
into #DoNotMakeInactive
from #NotInEdon ned
left outer join PlxEdonSupplyItem0610 ed
on ned.trmItemNo=ed.item_no
where ed.item_no is null  --3513


--select count(*) #DoNotMakeInactive from #DoNotMakeInactive  --254
--select top 1000 * from #DoNotMakeInactive

select * from #MakeInactive
select * from #DoNotMakeInactive


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

