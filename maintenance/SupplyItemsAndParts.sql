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
	top 10
	row_number() OVER(ORDER BY NSItemNumber ASC) AS Row#,
	p.Numbered,  -- Not in final set
	'BE' + RTRIM(LTRIM(NSItemNumber)) as "Item_No",
	SUBSTRING(p.Description,1,50) as "Brief_Description",
	CASE
		WHEN ((p.VendorNumber is null) or (p.VendorNumber = ''))
		and ((p.Manufacturer is null) or (p.Manufacturer = ''))
		and ((p.ManufacturerNumber is NULL) or (p.ManufacturerNumber = '')) 
		THEN p.Description --000
		WHEN ((p.VendorNumber is null) or (p.VendorNumber = ''))
		and ((p.Manufacturer is null) or (p.Manufacturer = ''))
		and ((p.ManufacturerNumber is not NULL) and (p.ManufacturerNumber <> '')) 
		THEN p.Description + ', ' + 'Mfg#' + p.ManufacturerNumber --001
		WHEN ((p.VendorNumber is null) or (p.VendorNumber = ''))
		and ((p.Manufacturer is not null) and (p.Manufacturer <> ''))
		and ((p.ManufacturerNumber is NULL) or (p.ManufacturerNumber = '')) 
		THEN p.Description + ', ' + 'Mfg: ' + p.Manufacturer --010
		WHEN ((p.VendorNumber is null) or (p.VendorNumber = ''))
		and ((p.Manufacturer is not null) and (p.Manufacturer <> ''))
		and ((p.ManufacturerNumber is not NULL) and (p.ManufacturerNumber <> '')) 
		THEN p.Description + ', ' + 'Mfg: ' + p.Manufacturer +', #' + p.ManufacturerNumber --011
		WHEN ((p.VendorNumber is not null) and (p.VendorNumber <> ''))
		and ((p.Manufacturer is null) or (p.Manufacturer = ''))
		and ((p.ManufacturerNumber is NULL) or (p.ManufacturerNumber = '')) 
		then '#' + p.VendorNumber + ', ' + p.Description -- 100
		WHEN ((p.VendorNumber is not null) and (p.VendorNumber <> ''))
		and ((p.Manufacturer is null) or (p.Manufacturer = ''))
		and ((p.ManufacturerNumber is not NULL) and (p.ManufacturerNumber <> '')) 
		THEN '#' + p.VendorNumber + ', ' + p.Description + ', ' + 'Mfg#' + p.ManufacturerNumber --101
		WHEN ((p.VendorNumber is not null) and (p.VendorNumber <> ''))
		and ((p.Manufacturer is not null) and (p.Manufacturer <> ''))
		and ((p.ManufacturerNumber is NULL) or (p.ManufacturerNumber = '')) 
		THEN '#' + p.VendorNumber + ', ' + p.Description + ', ' + 'Mfg: ' + p.Manufacturer  --110
		WHEN ((p.VendorNumber is not null) and (p.VendorNumber <> ''))
		and ((p.Manufacturer is not null) and (p.Manufacturer <> ''))
		and ((p.ManufacturerNumber is not NULL) and (p.ManufacturerNumber <> '')) 
		THEN '#' + p.VendorNumber + ', ' + p.Description + ', ' + 'Mfg: ' + p.Manufacturer +', #' + p.ManufacturerNumber --111
	end as Description,
	-- used xxd on plex csv file and dbeaver binary viewer on em and both seem to use 0D0A combo for \n so replace 
	-- should not be necessary.  DBeaver exports NotesText unicode field as ascii so you don't need to convert it at
	-- all to upload it into varchar field.
	--REPLACE(REPLACE(REPLACE(convert(varchar(max),p.NotesText), CHAR(13), '13'), CHAR(10), '10'),'1310',CHAR(10)) as Note, --
	-- BUT to make sure CHECK NOTES WITH NEWLINES BEFORE MASS UPLOAD
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
		when (minimumOnHand is not null) and (MaxOnHand is not null) and (minimumOnHand > MaxOnHand) and (MaxOnHand <> 0) then 0
		else MaxOnHand
	end as Max_Quantity,
	-- purchasing_v_tax_code / did not put this is for MRO supply items
	-- but befor you update the item in plex it has to be filled with something
	-- and accountant said I could use tax exempt.
	-- Found that EM Parts are already marked as taxable 'Y' or 'N'
	-- where taxable = 'N' --2044
	-- where taxable = 'Y'--10619
	'Tax Exempt - Labor / Industrial Processing' as Tax_Code,
	-- I worked hard to fill the account_no with an account that could be used to catagorize items as electrical, pumps, and something
	-- else I cant remember so that Pat could use the account field to keep track of the information he needs.  But was told to quit.
	'' as Account_No,
	'' as Manufacturer,
	p.ManufacturerNumber as Manf_Item_No,
	'' as Drawing_No,
	'' as Item_Quantity,
	'' as Location,
	sc.Supplier_Code,
from #set7
left join dbo.Parts p
	on #set7.minRecordNumber=p.RecordNumber	
left outer join btSupplyCode sc
	on p.Vendor=sc.VendorName

where NSItemNumber = '600005'

-- Drop table

-- DROP TABLE Cribmaster.dbo.btSupplyCode GO

CREATE TABLE ExpressMaintenance.dbo.btSupplyCode2 (
	Supplier_Code varchar(25),
	Supplier_Status varchar(50), 
	VendorName varchar(50) 
) GO;

--truncate table btSupplyCode
Bulk insert btSupplyCode
from 'C:\supply_codes.csv'
with
(
fieldterminator = '|',
rowterminator = '\n'
)

select COUNT(*)
from dbo.Parts p
left outer join btSupplyCode sc
	on p.Vendor=sc.VendorName
where (vendor is null) or (Vendor = '')	--501

select COUNT(*)
from
(
select DISTINCT vendor,vendorid,VendorNumber
from 
dbo.Parts
where (vendor is not null) and (Vendor <> '')	
--order by vendor
)set1 --327

select *
from
(
	select row#,vendor
	FROM
	(
		select 
			row_number() OVER(ORDER BY vendor ASC) AS Row#,
			vendor
		from
		(
			select DISTINCT vendor
			from 
			dbo.Parts
			where (vendor is not null) and (Vendor <> '')	
		)set1
	)set2
	where row# <= 184
)

--1. Check Plex for vendor
select * 
from btSupplyCode
where supplier_code like '%MARSHALL%'

UPDATE dbo.btSupplyCode
set vendorname = 'MARSHALL SAFETY'
where Supplier_Code = ''

--1.5  go through the items I did yesterday
			row_number() OVER(ORDER BY vendor ASC) AS Row#,
--vendors that are not in plex
--of items that were ordered recently
SELECT
Row#,vendor,Supplier_Code
from
(
	select 
	row_number() OVER(ORDER BY vendor ASC) AS Row#,
	vendor,sc.Supplier_Code
	from
	(
		select row#,vendor
		FROM
		(
			select 
				row_number() OVER(ORDER BY vendor ASC) AS Row#,
				vendor
			from
			(
				select DISTINCT vendor
				from 
				dbo.Parts
				where (vendor is not null) and (Vendor <> '')	
			)set1
		)set2
		where row# <= 184
		--Marshall safety
	)set1
	left outer JOIN
	dbo.btSupplyCode sc
	on set1.vendor=sc.VendorName
	where
	--Supplier_Code is not null --69
	Supplier_Code is null --115
)set1
where row# = 6


DECLARE @company as varchar(35)
set @company = '%ALPHA%'
--2. Check M2m to see if was ordered since 2013.
select *
from btm2mvendor
where pomcompany like @company or avcompany like @company

--3. If vendor needs added to Plex set addToPlex = 1
update btm2mvendor
set addToPlex = 1
where fvendno = '000846'

select * from dbo.btM2mVendor 
WHERE addtoplex =1
order by fvendno

--3.a  If cant find then ask kristin
insert into dbo.btAskKristin
--VALUES (Vendor, Numbered,Description)
select Vendor, Numbered,Description
from 
dbo.Parts
where Vendor like 'ALPHA%'	

select * from dbo.btAskKristin

CREATE TABLE btAskKristin (
	Vendor varchar(50),
	numbered varchar(50), 
	Description varchar(60)
)




--4. transfer btM2mVendor back to plex and link to apvend
-- write report to pull vendor info so they can be added to plex.

CREATE TABLE btAskKristin (
	Vendor varchar(50),
	numbered varchar(50), 
	Description varchar(60)
)


-- drop TABLE btM2mVendor GO
CREATE TABLE btM2mVendor (
	fvendno char(6),
	pomCompany varchar(35), 
	avCompany varchar(35)
--	addToPlex bit
)
alter table ExpressMaintenance.dbo.btM2mVendor
add addToPlex bit

select * from btm2mvendor

--truncate table btSupplyCode
Bulk insert btM2mVendor
from 'C:\M2mVendors0524b.csv'
with
(
fieldterminator = '|',
rowterminator = '\n'
)

--vendors that are not in plex
--of items that were ordered recently
select vendor,sc.Supplier_Code
from
(
	select row#,vendor
	FROM
	(
		select 
			row_number() OVER(ORDER BY vendor ASC) AS Row#,
			vendor
		from
		(
			select DISTINCT vendor
			from 
			dbo.Parts
			where (vendor is not null) and (Vendor <> '')	
		)set1
	)set2
	where row# <= 184
)set1
left outer JOIN
dbo.btSupplyCode sc
on set1.vendor=sc.VendorName
where
--Supplier_Code is not null --69
Supplier_Code is null --115


--set2 when was the last time the part was ordered
--select top 100 po.numbered,dateordered, vendorname 
select po.Numbered,max(dateordered) 
from dbo.Porders po
left outer join dbo.Parts p
on po.Numbered= po.Numbered
group by po.Numbered

select addressline1,city,state from companyaddress
where vendor like '%Fluid Systems%'

select max(dateordered)
from 
dbo.Porders2
group by DateOrdered

--insert INTO
--dbo.btSupplyCode2
--select * from dbo.btSupplyCode

select * 
from btSupplyCode
where Supplier_Code = 'Doc''s Hardware'
where VendorName is not null and VendorName <> ''
order by vendor

select count(*) 
from dbo.Parts
where taxable = 'N' --2044
where taxable = 'Y'--10619



where vendorname is null

update btSupplyCode
set VendorName = 'BUSCHE ENTERPRISES'
where Supplier_Code = 'Busche Albion'


select COUNT(*)
from
(
select DISTINCT vendor from dbo.Parts
)set1
--329

SELECT * from dbo.btSupplyCode
where supplier_code like '%@%'
varchar (25)	
	
select 
top 100
numbered, 
p.Manufacturer,
p.ManufacturerNumber,
p.VendorNumber,
CASE
	WHEN ((p.VendorNumber is null) or (p.VendorNumber = ''))
	and ((p.Manufacturer is null) or (p.Manufacturer = ''))
	and ((p.ManufacturerNumber is NULL) or (p.ManufacturerNumber = '')) 
	THEN p.Description --000
	WHEN ((p.VendorNumber is null) or (p.VendorNumber = ''))
	and ((p.Manufacturer is null) or (p.Manufacturer = ''))
	and ((p.ManufacturerNumber is not NULL) and (p.ManufacturerNumber <> '')) 
	THEN p.Description + ', ' + 'Mfg#' + p.ManufacturerNumber --001
	WHEN ((p.VendorNumber is null) or (p.VendorNumber = ''))
	and ((p.Manufacturer is not null) and (p.Manufacturer <> ''))
	and ((p.ManufacturerNumber is NULL) or (p.ManufacturerNumber = '')) 
	THEN p.Description + ', ' + 'Mfg: ' + p.Manufacturer --010
	WHEN ((p.VendorNumber is null) or (p.VendorNumber = ''))
	and ((p.Manufacturer is not null) and (p.Manufacturer <> ''))
	and ((p.ManufacturerNumber is not NULL) and (p.ManufacturerNumber <> '')) 
	THEN p.Description + ', ' + 'Mfg: ' + p.Manufacturer +', #' + p.ManufacturerNumber --011
	WHEN ((p.VendorNumber is not null) and (p.VendorNumber <> ''))
	and ((p.Manufacturer is null) or (p.Manufacturer = ''))
	and ((p.ManufacturerNumber is NULL) or (p.ManufacturerNumber = '')) 
	then '#' + p.VendorNumber + ', ' + p.Description -- 100
	WHEN ((p.VendorNumber is not null) and (p.VendorNumber <> ''))
	and ((p.Manufacturer is null) or (p.Manufacturer = ''))
	and ((p.ManufacturerNumber is not NULL) and (p.ManufacturerNumber <> '')) 
	THEN '#' + p.VendorNumber + ', ' + p.Description + ', ' + 'Mfg#' + p.ManufacturerNumber --101
	WHEN ((p.VendorNumber is not null) and (p.VendorNumber <> ''))
	and ((p.Manufacturer is not null) and (p.Manufacturer <> ''))
	and ((p.ManufacturerNumber is NULL) or (p.ManufacturerNumber = '')) 
	THEN '#' + p.VendorNumber + ', ' + p.Description + ', ' + 'Mfg: ' + p.Manufacturer  --110
	WHEN ((p.VendorNumber is not null) and (p.VendorNumber <> ''))
	and ((p.Manufacturer is not null) and (p.Manufacturer <> ''))
	and ((p.ManufacturerNumber is not NULL) and (p.ManufacturerNumber <> '')) 
	THEN '#' + p.VendorNumber + ', ' + p.Description + ', ' + 'Mfg: ' + p.Manufacturer +', #' + p.ManufacturerNumber --111
end as Description
from dbo.Parts p 
where numbered = '200703'
where numbered = '000008' --200703



select
CASE
	when ManufacturerNumber is null then '2'
	when ManufacturerNumber = '' then '1'
end as mfg_no,
CASE
	when VendorNumber is null then '4'
	when VendorNumber = '' then '3'
end as Vendor_no
from dbo.Parts p 
where numbered = '000008'


-- Drop table

-- DROP TABLE Cribmaster.dbo.btSupplyCode GO

CREATE TABLE Cribmaster.dbo.btSupplyCode (
	Supplier_Code varchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	VendorName varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) GO;

select vendor, vendorNumber,vendorid from dbo.Parts

Bulk insert btSupplyCode
from 'C:\supplier_code.csv'
with
(
fieldterminator = ',',
rowterminator = '\n'
)



select * 
from btSupplyCode
where vendorname = 'BUSCHE ENTERPRISES'
update btSupplyCode
set VendorName = 'BUSCHE ENTERPRISES'
where Supplier_Code = 'Busche Albion'


-- Do you purchase the item from the vendor contain the supplier you buy the item from?
select distinct vendor from dbo.Parts

select distinct manufacturer from dbo.Parts

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

select DISTINCT numbered,shelves
from
(
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
)set1
order by numbered

select * 
from #dups
where numbered = '701063'
order by numbered

select DISTINCT numbered,shelves
from
(
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
)set1
order by numbered

select numbered, categoryid, shelf
from dbo.Parts
where 
Numbered = '701063'




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
