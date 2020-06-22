-- drop table PlxAlbSupplyItem0619
-- truncate table PlxAlbSupplyItem0622
CREATE TABLE PlxAlbSupplyItem0622 (
	item_no varchar(50),
	brief_description varchar (80)
)

Bulk insert PlxAlbSupplyItem0622
from 'c:\il0622LE35000.csv'
with
(
	fieldterminator = ',',
	rowterminator = '\n'
)

select count(*) from PlxAlbSupplyItem0622;  -- Albion 06/22,31,425
select count(*) -- Albion 06/22,31,425
from 
(
select distinct item_no from PlxAlbSupplyItem0622 pasi 
)s1;
select top 100 * from PlxAlbSupplyItem0622 pasi 

  
-- DECODE CSV CHARACTER MAPPINGS
update PlxAlbSupplyItem0622 
set brief_description = REPLACE(REPLACE(REPLACE(REPLACE(brief_description, '###', ','), '##@', '"'),'#@#',CHAR(10)),'#@@',CHAR(13))

select count(*) notInPlex from (
	select 
	-- top 10 
	i.ItemNumber,
	i.Description1, 
	i.ItemClass,
	vn.VendorName
	-- p.item_no,
	-- p.brief_description
	from dbo.INVENTRY i 
	left outer join dbo.PlxAlbSupplyItem0622 p 
	on i.ItemNumber=p.item_no
	left outer join AltVendor av
	ON i.AltVendorNo = av.RecNumber
	left outer join VENDOR vn
	on av.VendorNumber = vn.VendorNumber
	where p.item_no is null
--	InCMButNotInPlex
)s1  -- 689
select 	
i.ItemNumber,
i.Description1, 
i.ItemClass
from inventry i 
where ItemNumber like '%000290%'
select top 10 * from inventry