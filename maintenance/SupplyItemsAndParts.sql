--select top 10 Numbered, Description,VendorNumber,ManufacturerNumber,* from parts
select top 10
--p.numbered,
	row_number() OVER(ORDER BY p.Numbered ASC) AS Row#,
--	convert(nvarchar(max),p.Notes) as Note,
--	convert(varchar(max),p.NotesText) as NoteText, --Special characters displayed in plex
--  p.NotesText, -- Special characters displayed in plex
--	REPLACE(convert(varchar(max),p.NotesText), CHAR(10), ', ') as NotesText,  -- Ok but we loose newlines

--	REPLACE(REPLACE(convert(varchar(max),p.NotesText), CHAR(13), '--13--'), CHAR(10), '--10--') as NotesText, -- Ok but we loose newlines
	'BE' + RTRIM(LTRIM(p.Numbered)) as "Item_No",
	SUBSTRING(p.Description,1,50) as "Brief_Description",
	CASE
		WHEN (p.ManufacturerNumber is NULL) or (p.ManufacturerNumber = '') then '#' + p.VendorNumber + ', ' + p.Description
		ELSE '#' + p.VendorNumber + ', ' + p.Description + ', ' + 'Mfg#' + p.ManufacturerNumber
	end as Description,
	REPLACE(REPLACE(REPLACE(convert(varchar(max),p.NotesText), CHAR(13), '13'), CHAR(10), '10'),'1310',CHAR(10)) as NotesText -- Perfect

--	convert(nvarchar(max),p.Notes) as Note
FROM
Parts as p
--where p.Numbered = '000001'
order by p.Numbered



select Notes,units from parts

-- Supply Items in CM
CREATE TABLE btCMInventry (
	itemnumber varchar(50) NOT NULL
)

-- Drop table 

-- DROP TABLE btCMInventry


--Bulk insert btCMInventry
from 'C:\cmInv0430.csv'
with
(
fieldterminator = ',',
rowterminator = '\n'
)

select top 10 * from dbo.btCMInventry
select top 100 * from dbo.Parts order by numbered
-- Same item number in Maintenance Express and Cribmaster.
select 
--count(*)
p.Numbered,
inv.itemnumber
from Parts p
left outer join dbo.btCMInventry inv
on p.Numbered=inv.ItemNumber
where inv.ItemNumber is not null
