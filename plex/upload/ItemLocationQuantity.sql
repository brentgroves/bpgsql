/*
 * PCN to PCN compare and upload
 * 1. From SDE download CSV from source PCN and upload
 * 2. From SDE download CSV from destination PCN
 * 3. Compare the 2 tables
 */
-- drop table PlxItemLocQtySrc0812
CREATE TABLE PlxItemLocQtySrc0812 (
	item_no varchar(50),
	location varchar(50),
    Quantity	decimal(18,2)
)

-- LOAD DATA INFILE '/prod0.csv' INTO TABLE PartProdRate FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA INFILE '/prod0.csv' INTO TABLE PartProdRate FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS (part_key,part_no,period,start_date,end_date,quantity,rate);

LOAD DATA INFILE '/il0812LE2500.csv'
INTO TABLE PlxItemLocQtySrc0812 
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS
(@item_no,location,quantity)
set item_no = NULLIF (@item_no,'');,
	quantity = NULLIF (@quantity,'');  -- NOT NEEDED IF LAST COLUMN
select * from PlxItemLocQtySrc0812 where item_no = '0003458'
select count(*) cnt from PlxItemLocQtySrc0812

/*
        (@col1, @col2) 
        SET email = nullif(@col1,''),
            phone = nullif(@col2,'')
        ;
*/


-- Insert Plex item_location data into CM
Bulk insert PlxItemLocQtySrc0811
from 'c:\il0811LE2500.csv'
with
(
	fieldterminator = ',',
	rowterminator = '\n'
)


-- drop table PlxItemLocQtyDest0812
CREATE TABLE PlxItemLocQtyDest0812 (
	item_no varchar(50),
	location varchar(50),
    Quantity	decimal(18,2)
)

-- Insert Plex item_location data into CM
Bulk insert PlxItemLocQtyDest0812
from 'c:\il0811LE2500.csv'
with
(
	fieldterminator = ',',
	rowterminator = '\n'
)
LOAD DATA INFILE '/il0812LE2500.csv'
INTO TABLE PlxItemLocQtyDest0812 
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS
(@item_no,location,quantity)
set item_no = NULLIF (@item_no,'');,
	quantity = NULLIF (@quantity,'');  -- NOT NEEDED IF LAST COLUMN
select * from PlxItemLocQtyDest0812 where item_no is null

/*
 * Are all the locations in Edon
 */

select count(*) from PlxItemLocQtySrc0812  -- 289
select count(*) cnt from (select distinct location from PlxItemLocQtySrc0812)s1  -- 286  there are dups
select count(*) cnt from (select distinct location from PlxItemLocQtySrc0812 where item_no is not null)s1  -- 275 some 12- don't have an item assigned
select 
al.location,
'Mobex Global Edon',
'Supply Crib' as location_type,  
'' as note,
'MRO Crib' as location_group
from 
(
select
src.location
from (
	select distinct location from PlxItemLocQtySrc0812 where item_no is not null -- we only want to import locations which have an assigned item_no
) src
left outer join 
(
	select distinct location from PlxItemLocQtyDest0812  -- 192
) dst
on src.location=dst.location
where dst.location is null  -- 91
) al 

/*
 * Are the item locations in Edon
 * Fill out the item_location_template.csv
 */


select 
al.item_no,
al.location,
al.quantity,
'N' as Building_Default,
'' Transaction_Type
-- select count(*)  -- 278
from 
(
	select
	src.item_no,
	dst.item_no dst_item_no,
	src.location,
	dst.location dst_location,
	src.quantity,
	dst.quantity dst_quantity
	-- select count(*)  -- 278
	from (
		select item_no, location,quantity from PlxItemLocQtySrc0812 where item_no is not null -- we only want to import locations which have an assigned item_no
		-- select item_no, location, quantity from PlxItemLocQtySrc0812 where item_no = '16288' -- 192
	) src
	left outer join 
	(
		select item_no, location, quantity from PlxItemLocQtyDest0812
	) dst
	on src.item_no=dst.item_no
	and src.location=dst.location
	order by src.location
	-- where dst.item_no is not null  -- they are all null
) al 


/*

select s.item_no,d.item_no,
s.location,d.location,
s.quantity,d.quantity
-- select count(*)  -- 289
from PlxItemLocQtySrc0812 s 
left outer join PlxItemLocQtyDest0812 d
on s.location =d.location
*/
-- select distinct location from PlxItemLocQtyDest0812 -- 192
-- select count(*) from PlxItemLocQtySrc0812 where location is null  -- 0
-- select count(*) from PlxItemLocQtyDest0812 where location is null  -- 0
-- drop table PlxItemLocQtySrc0811
-- drop table PlxItemLocQtyDest0811