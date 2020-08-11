/*
 * PCN to PCN compare and upload
 * 1. From SDE download CSV from source PCN and upload
 * 2. From SDE download CSV from destination PCN
 * 3. Compare the 2 tables
 */
CREATE TABLE Cribmaster.dbo.PlxItemLocQtySrc0811 (
	item_no varchar(50),
	location varchar(50),
	quantity integer
)

-- Insert Plex item_location data into CM
Bulk insert PlxItemLocQtySrc0811
from 'c:\il0811LE2500.csv'
with
(
	fieldterminator = ',',
	rowterminator = '\n'
)



CREATE TABLE Cribmaster.dbo.PlxItemLocQtyDest0811 (
	item_no varchar(50),
	location varchar(50),
	quantity integer
)

-- Insert Plex item_location data into CM
Bulk insert PlxItemLocQtyDest0811
from 'c:\il0811LE2500.csv'
with
(
	fieldterminator = ',',
	rowterminator = '\n'
)

select s.item_no,d.item_no,
s.location,d.location,
s.quantity,d.quantity
from PlxItemLocQtySrc0811 s 
left outer join PlxItemLocQtyDest0811 d
on s.location =d.location
-- drop table PlxItemLocQtySrc0811
-- drop table PlxItemLocQtyDest0811