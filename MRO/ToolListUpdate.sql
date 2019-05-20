
use [Busche ToolList]
-- Drop table

-- DROP TABLE [Busche ToolList].dbo.ToolBoss GO

CREATE TABLE [Busche ToolList].dbo.PlxPartNumber (
	Part_No varchar (100)
) 

select * from PlxPartNumber
Bulk insert PlxPartNumber
from 'c:\PlexPartNumbers.csv'
with
(
fieldterminator = ',',
rowterminator = '\n'
)


select PartNumbers,pp.part_no 
from
[ToolList PartNumbers] tlp
left outer join PlxPartNumber pp
on tlp.PartNumbers= pp.Part_no

--How many part numbers are not in plex? --622
select 
count(*)
--PartNumbers,pp.part_no 
from
[ToolList PartNumbers] tlp
left outer join PlxPartNumber pp
on tlp.PartNumbers= pp.Part_no
where pp.Part_no is NULL
--How many partnumbers are not in toollist
select 
count(*)
--PartNumbers,pp.part_no 
from
PlxPartNumber pp
left outer join [ToolList PartNumbers] tlp
on tlp.PartNumbers= pp.Part_no
where tlp.PartNumbers is NULL
--517

--How many partnumbers are both plex and the toollist
select 
--count(*)
PartNumbers,pp.part_no 
from
PlxPartNumber pp
inner join [ToolList PartNumbers] tlp
on tlp.PartNumbers= pp.Part_no
