-- Combine Part Numbers 
-- 850325AV - Avilla
-- 850325E - Edon
-- 850325A - PH8
-- 850325 - Albion
-- Process
-- Set 1 = {ActNumber, NoSuffixNumber}.

--There are appox 45 parts with multiple records and some have different locations.
select COUNT(*)
FROM
(
	select min(RecordNumber) minRecordNumber, ltrim(rtrim(Numbered)) ItemNumber
	from dbo.Parts
	group by ltrim(rtrim(Numbered))
)lv1
--12619
select COUNT(*)
from dbo.Parts
--12665
-- drop table #set8
create table #set7
(
	minRecordNumber numeric(18,0),
	NSItemNumber varchar(50)
);

--drop table #set1
create table #set1
(
	minRecordNumber numeric(18,0),
	ItemNumber varchar(50)
);
   
--Set 1: {ItemNumber,minRecordNumber} => group by ItemNumber to delete duplicates, 
--remove KendallVille records, and trim ItemNumbers. Store in temp table.

insert into #set1 (minRecordNumber,ItemNumber)
(
	select min(RecordNumber) minRecordNumber, ltrim(rtrim(Numbered)) ItemNumber
	from dbo.Parts
	group by ltrim(rtrim(Numbered))
	-- do not include Kendallville numbers.
	having RIGHT(LTRIM(RTRIM(Numbered)),1) <> 'K'
)
select count(*) from #set1
--11096
select count(*) from #set7
--10266
select COUNT(*)
--10266 total
--+ 608 -- 608 items have 2-locations
--+ 186 = (93 * 2) -- 93 have 3 locations 
--+  36 = (12 * 3) -- 12 have 4 locations
--11096 
from
(
select #set7.NSItemNumber item_no,p.Numbered,p.CategoryID,p.Description
from #set7
left join dbo.Parts p
on #set7.minRecordNumber=p.RecordNumber
) testCounts --10266
-- test after creating #set7 below
--order by set8.NSitemnumber

-- Create #set 7 first then create set8 
	insert into #set7 (NSItemNumber,minRecordNumber)
	(
		select set7.NSItemNumber,#set1.minRecordNumber
		FROM
		(
			select DISTINCT ItemNumber,NSItemNumber
			from
			(
				select 
				CASE
					when right(NSItemNumberPriority,1) = '1' then NSItemNumber
					when right(NSItemNumberPriority,1) = '2' then NSItemNumber + 'AV'
					when right(NSItemNumberPriority,1) = '3' then NSItemNumber + 'E'
					when right(NSItemNumberPriority,1) = '4' then NSItemNumber + 'A'
				end as ItemNumber,
				NSItemNumber
				from
				(
					select MIN(NSItemNumberPriority) NSItemNumberPriority,NSItemNumber 
					from
					(
						select 
						NSItemNumber,
						case 
							when suffix = 'N' then NSItemNumber + '-1'
							when suffix = 'AV' then NSItemNumber + '-2'
							when suffix = 'E' then NSItemNumber + '-3'
							when suffix = 'A' then NSItemNumber + '-4'
						end as NSItemNumberPriority
						from
						(
							select 
								ItemNumber, 
								case 
									when ItemNumber like '%[A-Z][A-Z]' then LEFT(ItemNumber, len(ItemNumber) -2) 
									when ItemNumber like '%[^A-Z][A-Z]' then LEFT(ItemNumber, len(ItemNumber) -1) 
									else ItemNumber
								end as NSItemNumber,
								case 
									when ItemNumber like '%[A-Z][A-Z]' then right(ItemNumber,2) 
									when ItemNumber like '%[^A-Z][A-Z]' then right(ItemNumber,1) 
									else 'N' --none
								end as suffix
							from #set1 
							--order by itemnumber
							-- set2
							
						)set3
					)set4 --10266
					group by NSItemNumber
					--order by NSitemnumber
				)set5 --10266
				--where right(NSItemNumberPriority,1) = '4' 
			)set6 --10266 no dups
		)set7 --10266
		left join #set1
		on set7.ItemNumber=#set1.ItemNumber
	) -- #set7 

-- finally create set8 from #set7
--CHECK NOTES WITH NEWLINES BEFORE MASS UPLOAD
select 
	--top 10
	row_number() OVER(ORDER BY NSItemNumber ASC) AS Row#,
	p.Numbered,  -- Not in final set
	'BE' + RTRIM(LTRIM(NSItemNumber)) as "Item_No",
	SUBSTRING(p.Description,1,50) as "Brief_Description",
	CASE
		WHEN ((p.ManufacturerNumber is NULL) or (p.ManufacturerNumber = '')) 
		and ((p.VendorNumber is not null) and (p.VendorNumber <> ''))
		then '#' + p.VendorNumber + ', ' + p.Description
		WHEN ((p.ManufacturerNumber is not NULL) and (p.ManufacturerNumber <> '')) 
		and ((p.VendorNumber is null) OR (p.VendorNumber = ''))
		THEN p.Description + ', ' + 'Mfg#' + p.ManufacturerNumber
		ELSE '#' + p.VendorNumber + ', ' + p.Description + ', ' + 'Mfg#' + p.ManufacturerNumber
	end as Description,
	-- used xxd on plex csv file and dbeaver binary viewer on em and both seem to use 0D0A combo for \n so replace 
	-- should not be necessary.  DBeaver exports NotesText unicode field as ascii so you don't need to convert it at
	-- all to upload it into varchar field.
	--REPLACE(REPLACE(REPLACE(convert(varchar(max),p.NotesText), CHAR(13), '13'), CHAR(10), '10'),'1310',CHAR(10)) as Note, --
	NotesText as Note, 
	'Maintenance' as item_type,
	CASE
		when ((p.CategoryID is null) or (ltrim(rtrim(p.CategoryID))) = '') then 'General'
		when p.CategoryID = '-PLATE' then 'PLATE'
		else LTRIM(RTRIM(CategoryID))
	end as Item_Group,
	'General' as Item_Category,
	'Low' as Item_Priority,
	CASE
		when p.BillingPrice is NOT null AND BillingPrice > 0 then BillingPrice
		else p.CurrentCost
	end as Customer_Unit_Price,
	'' as Average_Cost,
-- Standardize on units found in common_v_unit
-- Add units as needed and assign default
	CASE 
		when LTRIM(RTRIM(Units)) is null or LTRIM(RTRIM(Units)) = '' then 'Ea'
		when LTRIM(RTRIM(Units)) = 'Box' then 'Box'
		when LTRIM(RTRIM(Units)) = 'Case' then 'case'
		when LTRIM(RTRIM(Units)) = 'Dozen' then 'dozen'
		when LTRIM(RTRIM(Units)) = 'Each' then 'Ea'
		when LTRIM(RTRIM(Units)) = 'Electrical' then 'Ea'
		when LTRIM(RTRIM(Units)) = 'Feet' then 'Feet'
		when LTRIM(RTRIM(Units)) = 'Gallons' then 'Gallons'
		when LTRIM(RTRIM(Units)) = 'INCHES' then 'inches'
		when LTRIM(RTRIM(Units)) = 'Meters' then 'meters'
		when LTRIM(RTRIM(Units)) = 'Per 100' then 'hundred'
		when LTRIM(RTRIM(Units)) = 'Per Package' then 'Package'
		when LTRIM(RTRIM(Units)) = 'Package' then 'Package'
		when LTRIM(RTRIM(Units)) = 'Pounds' then 'lbs'
		when LTRIM(RTRIM(Units)) = 'Quart' then 'quart'
		when LTRIM(RTRIM(Units)) = 'Roll' then 'Roll'
		when LTRIM(RTRIM(Units)) = 'Set' then 'set'
		else 'Ea'
	end as Inventory_Unit,
	-- check 0000007 and other items
 	MinimumOnHand as Min_Quantity,
	CASE
		when (minimumOnHand is not null) and (MaxOnHand is not null) and (minimumOnHand > MaxOnHand) and (MaxOnHand <> 0) then MaxOnHand = 0
		else MaxOnHand
	end as Max_Quantity
from #set7
left join dbo.Parts p
on #set7.minRecordNumber=p.RecordNumber	
where NSItemNumber = '600005'

-- Electronics, Pumps, Covers
-- How to group 

select numbered,notestext from parts
where notestext like '%' + char(10) + '%'

-- Min_Quantity 
-- check item with null values it test data set

select 
--COUNT(*)
	minimumOnhand,MaxOnHand,Numbered,CategoryID 
from dbo.Parts
where (minimumOnHand is not null) and (MaxOnHand is not null) and (minimumOnHand > MaxOnHand) and (MaxOnHand <> 0) 
where MaxOnHand < MinimumOnHand --319
and MaxOnHand <> 0
--where MaxOnHand is null --1414
WHERE MinimumOnHand = 0 --3324

--where MinimumOnHand is null -- 0


-- Inventory_Unit make sure all EM units have a mapping to common_v_unit types.
select 
--COUNT(*)
Numbered, CategoryID, Description, QuantityOnHand, Units 
--select distinct LTRIM(RTRIM(Units)) 
--select COUNT(*) 
from parts 
--where LTRIM(RTRIM(Units)) is null
--	or LTRIM(RTRIM(Units)) = '' 

	where LTRIM(RTRIM(Units)) is not null
	and LTRIM(RTRIM(Units)) <> '' 
	and LTRIM(RTRIM(Units)) = 'Box'
order by LTRIM(RTRIM(Units))	

-- EM / Plex unit mapping
None / Ea / 606
Box  / Box / 9     
Case / Ea / 3     
Dozen / dozen / 5    
Each  / Ea / 11521    
Electrical / Ea / 27
Feet / Feet / 287      
Gallons / Gallon  / 9   
INCHES / inches / 3    
Meters / meters / 5    
Per 100 / hundred / 10    
Per Package / Package / 3
Package / Package / 11
Pounds / lbs / 2    
Quart / quart / 1     
Roll / Roll / 12       
Set / set / 143       


-- Customer_Unit_Price
-- Ok to have cost is null 
--check 200712 which has null values for both costs
select Numbered, BillingPrice, CategoryID,Description from parts p
where p.BillingPrice is null and CurrentCost is null 
--where CurrentCost is null
where p.BillingPrice is NOT null AND BillingPrice > 0 and CurrentCost is null 


--Notes 
--!!!!!! test to make sure Plex displays char(10) as a newline BEFORE IMPORTING ITEMS
select count(*) 
FROM
(
	SELECT Numbered,
	NotesText,
	REPLACE(REPLACE(REPLACE(convert(varchar(max),p.NotesText), CHAR(13), '13'), CHAR(10), '10'),'1310',CHAR(10)) as Note,
	ManufacturerNumber,VendorNumber FROM PARTS p
--	where NotesText like '%' + char(13) + '%' --2550
	where NotesText like '%' + char(13) + char(10) +'%' --2550
)set1

-- Vendor,MFG test // passed
SELECT Numbered,ManufacturerNumber,VendorNumber FROM PARTS p
Where ((p.ManufacturerNumber is not NULL) and (p.ManufacturerNumber <> '')) 
and (p.VendorNumber is not null OR p.VendorNumber <> '')
 -- 200240 / LPS-RK-30SP/LPSRK30SP
Where ((p.ManufacturerNumber is not NULL) and (p.ManufacturerNumber <> '')) 
and (p.VendorNumber is null OR p.VendorNumber = '')
-- 000227 / 37E510X651M
WHERE ((p.ManufacturerNumber is NULL) or (p.ManufacturerNumber = '')) 
and (p.VendorNumber is not null and p.VendorNumber <> '')
-- 200715 / 800F-MX11

	
--Test
select #set7.NSItemNumber item_no,p.Numbered,p.CategoryID,p.Description
from #set7
left join dbo.Parts p
on #set7.minRecordNumber=p.RecordNumber
--where RIGHT(LTRIM(RTRIM(p.Numbered)),1) = 'E' --184 



select numbered, categoryid,description from parts p 
where p.Numbered like '000547%'
on 

-- How many parts are in multiple locations --713
select COUNT(*)
from 
(
select MAX(NSItemNumberPriority) NSItemNumberPriority,NSItemNumber,COUNT(*) cnt
from
(
	select 
	NSItemNumber,
	case 
		when suffix = 'N' then NSItemNumber + '-1'
		when suffix = 'AV' then NSItemNumber + '-2'
		when suffix = 'E' then NSItemNumber + '-3'
		when suffix = 'A' then NSItemNumber + '-4'
	end as NSItemNumberPriority
	from
	(
		select 
			ItemNumber, 
			case 
				when ItemNumber like '%[A-Z][A-Z]' then LEFT(ItemNumber, len(ItemNumber) -2) 
				when ItemNumber like '%[^A-Z][A-Z]' then LEFT(ItemNumber, len(ItemNumber) -1) 
				else ItemNumber
			end as NSItemNumber,
			case 
				when ItemNumber like '%[A-Z][A-Z]' then right(ItemNumber,2) 
				when ItemNumber like '%[^A-Z][A-Z]' then right(ItemNumber,1) 
				else 'N' --none
			end as suffix
		from #set1 
		-- set2
	)set3
)set4 --10266
group by NSItemNumber
having COUNT(*) = 4
--order by nsitemnumber
)fin

--There are appox 80 parts with multiple records and some have different locations.
--drop table #dups
CREATE TABLE #dups (
	Numbered varchar(50),
	Shelf varchar(25)
)

insert into #dups (Numbered,shelf)
(
	select Numbered,shelf
	from dbo.Parts
	where Numbered in (
		select Numbered 
		from parts 
		group by Numbered
		HAVING COUNT(*) > 1
	)
)

select * 
from #dups
where numbered = '701063'
order by numbered

select 
Numbered,
(
	stuff(
			(
				select cast(', ' + shelf as varchar(max)) 
				from #dups d 
				where (numbered = p.numbered)
				FOR XML PATH ('')
			), 1, 2, ''
		)
) as shelves 
from #dups p 

select numbered, categoryid, shelf
from dbo.Parts
where 
Numbered = '701063'

select p.RecordNumber, p.Numbered,shelf,QuantityOnHand,CategoryID,Description
from
(
	select max(RecordNumber) maxRecordNumber, Numbered
	from dbo.Parts
	where Numbered in (
		select Numbered 
		from parts 
		group by Numbered
		HAVING COUNT(*) > 1
	)
	group by Numbered

)lv1
left join dbo.Parts p
on lv1.maxRecordNumber = p.RecordNumber

order by Numbered

select *
FROM
(
	select 
		--top 10
		row_number() OVER(ORDER BY p.Numbered ASC) AS Row#,
		'BE' + RTRIM(LTRIM(p.Numbered)) as "Item_No",
		SUBSTRING(p.Description,1,50) as "Brief_Description",
		CASE
			WHEN (p.ManufacturerNumber is NULL) or (p.ManufacturerNumber = '') then '#' + p.VendorNumber + ', ' + p.Description
			ELSE '#' + p.VendorNumber + ', ' + p.Description + ', ' + 'Mfg#' + p.ManufacturerNumber
		end as Description,
		REPLACE(REPLACE(REPLACE(convert(varchar(max),p.NotesText), CHAR(13), '13'), CHAR(10), '10'),'1310',CHAR(10)) as Note, -- Thank you
		'Maintenance' as item_type,
		CASE
			when ((p.CategoryID is null) or (ltrim(rtrim(p.CategoryID))) = '') then 'General'
			when p.CategoryID = '-PLATE' then 'PLATE'
			else LTRIM(RTRIM(CategoryID))
		end as Item_Group,
		'General' as Item_Category,
		'Low' as Item_Priority,
		CASE
			when p.BillingPrice is NOT null AND BillingPrice > 0 then BillingPrice
			else p.CurrentCost
		end as Customer_Unit_Price
		
	FROM
	Parts as p
)lv1
where Item_Group = 'PLATE'
--where Item_Group = 'General'
order by Item_No


select Numbered from parts 
where right(ltrim(rtrim(numbered)),1)='B'


--How many shelves are there? 3538
select count(*)
from (
select distinct shelf from parts
)lv1
-- How many items have a quantity > 0 but no shelf location = 146
 select Numbered,Description,site,location,shelf,QuantityOnHand as quantity 
 from parts
where QuantityOnHand > 0
and (shelf is null or shelf = '') 

 select Numbered,Description,shelf,QuantityOnHand from dbo.Parts
where QuantityOnHand > 0
and (shelf is null or shelf = '') 

select * from sources
select * from locations
select * from dbo.Inventory
SELECT * from dbo.CostCenters
select * from dbo.Resources
select * from units
where unit = 'CNC143'
select top 100 * from dbo.WoDetail

select 
--count(*)
BillingPrice
	--	CurrentCost,BillingPrice 
from parts --12664
--where CurrentCost is NOT NULL --4651
WHERE BillingPrice is NOT null AND BillingPrice > 0 --1846	
--where CurrentCost is NOT NULL --1801
--and BillingPrice is NOT null --1801	
	where CurrentCost<>BillingPrice
select type, count(*) from parts
group by type
select LTRIM(RTRIM(CategoryID))
from
(
	select distinct CategoryID from parts
)lv1
order by CategoryID


select
CategoryID
--count(*) 
from dbo.Parts
where CategoryID = 'Gauge, Pressure'

where CategoryID is null
--136

select count(*) from Parts
where ltrim(RTRIM(CategoryID)) = ''
-- 3
select count(*) from Parts p
where p.CategoryID = 'General'
where ((p.CategoryID is null) or (ltrim(rtrim(p.CategoryID))) = '')
--139

	select count(*) from parts
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
