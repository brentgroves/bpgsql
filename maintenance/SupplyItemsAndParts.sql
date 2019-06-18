-- Combine Part Numbers 
-- 850325AV - Avilla
-- 850325E - Edon
-- 850325A - PH8
-- 850325 - Albion
-- Process
-- Set 1 = {ActNumber, NoSuffixNumber}.

--truncate table btSupplyCode
--Manufacturers that Kristen asked me to upload, some dups 
--and some that are already in plex
--use btEMManufacturers to upload into plex.  Dups and 
--Manufacturers already in plex have been removed.
Bulk insert btManufacturer
from 'C:\manufacturers.csv'
with
(
fieldterminator = '|',
rowterminator = '\n'
)
CREATE TABLE btManufacturer (
	Vendor varchar(50)
)

--manufacturers in plex before uploading EM manufacturers
CREATE TABLE btPlexManufacturer (
	Vendor varchar(50)
)

Bulk insert btPlexManufacturer
from 'C:\plexmanufacturers.csv'
with
(
fieldterminator = '|',
rowterminator = '\n'
)

CREATE TABLE btMfgMap (
	emVendor varchar(50),
	plexVendor varchar(50)
)

/*
 * 
insert into dbo.btMfgMap(emVendor,plexvendor)
select vendor emVendor, vendor plexvendor from dbo.btManufacturer
use btManufacturer for mapping
use btEMManufacturer for uploading into plex 
-- because dup vendors are deleted and vendors already in plex are removed

*
* pending/questions out
*ARROW PNEUMATICS         
ARROW/HART-COOPER WIRING 
GEM  
GEMCO
gems
HONEYWELL                         
Honeywell International, Inc.     
Honeywell Safety Products USA, Inc
***/


select * from dbo.btMfgMap
select *
from
(
	select 
	row_number() OVER(ORDER BY vendor ASC) AS Row#,
	*
	from
	(
	select 'em' as orig,* from dbo.btManufacturer
	UNION
	select 'plex' as orig,* from dbo.btPlexManufacturer
	)set1
)set1
where Row# >= 281
and Row# <= 290

update dbo.btMfgMap
set plexVendor = ''
where emvendor = ''

select * from dbo.btMfgMap

--Since there were no dups in EM and Plex
-- I will use this table for the plex uploads

	select *
	into dbo.btMfgMap
	from dbo.btMfgMap0506
select * from dbo.btMfgMap


--select Manufacturer_Code,Manufacturer_Name,Note
select
emVendor as emMfg,
plexVendor as plexMfg
--into btMfgMap0605
from
(
	select
	row_number() OVER(ORDER BY emVendor ASC) AS Row#,
	emVendor as Manufacturer_Code,
	plexVendor as Manufacturer_Name,
	'' Note 
	from dbo.btMfgMap
)set1

where Row# >= 6
and Row# <= 5
--use btEMManufacturers to upload into plex.  Dups and 
--Manufacturers already in plex have been removed.
/*
select *
into btEMManufacturer
from btManufacturer
*/
/*
delete from dbo.btEMManufacturer
where vendor = ''
*/
select * from dbo.btEMManufacturer

--There are appox 21 parts with multiple records and some have different locations.
select *
FROM
(
	select min(RecordNumber) minRecordNumber, ltrim(rtrim(Numbered)) ItemNumber, COUNT(*) partCount
	from dbo.Parts
	group by ltrim(rtrim(Numbered))
)set1
where partCount > 1

-- drop table #set8

create table #set7
(
	minRecordNumber numeric(18,0),
	NSItemNumber varchar(50)
);

--drop table plxAllPartsSet
create table plxAllPartsSet
(
	minRecordNumber numeric(18,0),
	ItemNumber varchar(50),
	NSItemNumber varchar(50),
	suffix varchar(2)
);
select * from plxAllPartsSet





--Set 1: {ItemNumber,minRecordNumber} => group by ItemNumber to delete duplicates, 
--Duplicates are for items which have multiple location?
--remove KendallVille records, and trim ItemNumbers. Store in temp table.

insert into plxAllPartsSet (minRecordNumber,ItemNumber,NSItemNumber,suffix)
(
	--select COUNT(*) cntParts
	--from (
	select 
	min(RecordNumber) minRecordNumber,
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
	from 
	(
		--select COUNT(*) cntParts
		--from (
		select 
		ltrim(rtrim(Numbered)) ItemNumber, 
		recordnumber
		from dbo.Parts p
		left outer join dbo.btSiteMap sm
		on p.Site=sm.emSite
		left outer join dbo.btSiteBuildingMap bm
		on sm.plxSite=bm.plxSite
		where (RIGHT(LTRIM(RTRIM(Numbered)),1) <> 'K'  and sm.plxSite <> 'MO') 
		--)tst --11158
	)set1 -- no kendallville parts
	group by ItemNumber
	--)tst --11145

) --11145

				from dbo.Parts p  
				left outer join 
				plxAllPartsSet ap  -- No Kendallville parts
				on ap.ItemNumber=ltrim(RTRIM(p.Numbered))
				left outer join dbo.btSiteMap sm
				on p.Site=sm.emSite
				left outer join dbo.btSiteBuildingMap bm
				on sm.plxSite=bm.plxSite
				where ap.ItemNumber is not null

select count(*) from dbo.plxAllPartsSet
--11096
--11157
--11163
--11169
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
		select set7.NSItemNumber,plxAllPartsSet.minRecordNumber
		FROM
		(
			--select COUNT(*) from ( --are there any dups
			--select DISTINCT NSItemNumber -- TEST form dups nsitemnumber record
			select DISTINCT ItemNumber,NSItemNumber --dups for multiple columns eliminated, distinct is not necessary 
													--should not be any but do above TEST to be sure
													--This set should not have any changes from previous set 
													--except for the reduction of columns
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
					--select count(*) cnt from (
					select MIN(NSItemNumberPriority) NSItemNumberPriority,NSItemNumber 
					from
					(
						--select count(*)
						--from
						--(
						select 
						ItemNumber, --for testing suffix
						NSItemNumber,
						case 
							when suffix = 'N' then NSItemNumber + '-1'
							when suffix = 'AV' then NSItemNumber + '-2'
							when suffix = 'E' then NSItemNumber + '-3'
							when suffix = 'A' then NSItemNumber + '-4'
						end as NSItemNumberPriority
						from
						dbo.plxAllPartsSet 
						--)tst --11145
						/*
						where 
						itemnumber like '000003%'
						or itemnumber like '000054%'
						or itemnumber like '000091%'
						or itemnumber like '000547%'
						or itemnumber like '200382%'
						order by nsitemnumber
						--000003A -- 450  
						--000054 (AV) --9145 
						--000091 (E) --839  
						--000547AV --13043  
						--200382E  --14322
						--	when suffix = 'N' then NSItemNumber + '-1'
						--	when suffix = 'AV' then NSItemNumber + '-2'
						--	when suffix = 'E' then NSItemNumber + '-3'
						--	when suffix = 'A' then NSItemNumber + '-4'
						*/
					)set4 
					group by NSItemNumber
					--)tst  --10273
					/*
					having 
					nsitemnumber like '000003%'
					or nsitemnumber like '000054%'
					or nsitemnumber like '000091%'
					or nsitemnumber like '000547%'
					or nsitemnumber like '200382%'
					order by nsitemnumber
					*/
					--000003A -- 450  
					--000054 (AV) --9145 
					--000091 (E) --839  
					--000547AV --13043  
					--200382E  --14322
					--	when suffix = 'N' then NSItemNumber + '-1'
					--	when suffix = 'AV' then NSItemNumber + '-2'
					--	when suffix = 'E' then NSItemNumber + '-3'
					--	when suffix = 'A' then NSItemNumber + '-4'
					
				)set5 
				/*
				where 
				nsitemnumber like '000003%'
				or nsitemnumber like '000054%'
				or nsitemnumber like '000091%'
				or nsitemnumber like '000547%'
				or nsitemnumber like '200382%'
				order by nsitemnumber
				--000003A -- 450  
				--000054 (AV) --9145 
				--000091 (E) --839  
				--000547AV --13043  
				--200382E  --14322
				--	when suffix = 'N' then NSItemNumber + '-1'
				--	when suffix = 'AV' then NSItemNumber + '-2'
				--	when suffix = 'E' then NSItemNumber + '-3'
				--	when suffix = 'A' then NSItemNumber + '-4'
				*/
				--where right(NSItemNumberPriority,1) = '4'
			)set6 --
			--)tst1 --10273 check for multiple copies of same nsitemnumber
		)set7 --
		left join dbo.plxAllPartsSet -- If an itemnumber has more than 1 record dbo.plxAllPartsSet records the one
		-- with the minimum record number.  There are only a few of these records;
		-- possibly if the part is stored in multiple locations.
		on set7.ItemNumber=plxAllPartsSet.ItemNumber
		/*
		where 
		set7.nsitemnumber like '000003%'
		or set7.nsitemnumber like '000054%'
		or set7.nsitemnumber like '000091%'
		or set7.nsitemnumber like '000547%'
		or set7.nsitemnumber like '200382%'
		order by set7.nsitemnumber
		--000003A -- 450  
		--000054 (AV) --9145 
		--000091 (E) --839  
		--000547AV --13043  
		--200382E  --14322
		--	when suffix = 'N' then NSItemNumber + '-1'
		--	when suffix = 'AV' then NSItemNumber + '-2'
		--	when suffix = 'E' then NSItemNumber + '-3'
		--	when suffix = 'A' then NSItemNumber + '-4'
		*/
	) -- #set7
	--10273
	--Check for dups
	select COUNT(*)
	from
	(
		select 
		--*
		--COUNT(*)
		nsitemnumber 
		from #set7
		group by nsitemnumber
	)tst	

-- finally create set8 from #set7
--CHECK NOTES WITH NEWLINES BEFORE MASS UPLOAD
select count(*) cnt from (
--select top 100 * from (
select 
	top 100
	row_number() OVER(ORDER BY NSItemNumber ASC) AS Row#,
	p.Numbered,  -- Not in final set
	'BE' + RTRIM(LTRIM(NSItemNumber)) as "Item_No",
	SUBSTRING(p.Description,1,50) as "Brief_Description",  -- Description field is varchar(60) so there could be some data loss
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
		THEN '#' + p.VendorNumber + ', ' + p.Description + ', Mfg#' + p.ManufacturerNumber --101
		WHEN ((p.VendorNumber is not null) and (p.VendorNumber <> ''))
		and ((p.Manufacturer is not null) and (p.Manufacturer <> ''))
		and ((p.ManufacturerNumber is NULL) or (p.ManufacturerNumber = '')) 
		THEN '#' + p.VendorNumber + ', ' + p.Description + ', Mfg: ' + p.Manufacturer  --110
		WHEN ((p.VendorNumber is not null) and (p.VendorNumber <> ''))
		and ((p.Manufacturer is not null) and (p.Manufacturer <> ''))
		and ((p.ManufacturerNumber is not NULL) and (p.ManufacturerNumber <> '')) 
		THEN '#' + p.VendorNumber + ', ' + p.Description + ', Mfg: ' + p.Manufacturer +', #' + p.ManufacturerNumber --111
	end as Description,  -- Description field is on the ordering screen so make sure it has all the information needed to order the part.
	-- used xxd on plex csv file and dbeaver binary viewer on em and both seem to use 0D0A combo for \n so replace 
	-- should not be necessary.  DBeaver exports NotesText unicode field as ascii so you don't need to convert it at
	-- all to upload it into varchar field.
	--REPLACE(REPLACE(REPLACE(convert(varchar(max),p.NotesText), CHAR(13), '13'), CHAR(10), '10'),'1310',CHAR(10)) as Note, --
	-- BUT to make sure CHECK NOTES WITH NEWLINES BEFORE MASS UPLOAD
	NotesText as Note, 
	'Maintenance' as item_type,
	CASE
		when ((p.CategoryID is null) or (ltrim(rtrim(p.CategoryID))) = '') then 'General'
		when p.CategoryID = '-PLATE' then 'PLATE'  -- Kristen did not change this in EM 06-04 
		else LTRIM(RTRIM(CategoryID))
	end as Item_Group,
	--select categoryid from dbo.Parts where CategoryID LIKE '%PLATE%'
	--select distinct categoryid from parts order by categoryid	--192  looks like there are extra in plex such as welding
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
 	MinimumOnHand as Min_Quantity, -- if there are multiple parts,21 at last count, this will contain the value of the one chosen.
 	/*
 	select numbered,description,minimumonhand,maxonhand from dbo.Parts
 	where (minimumOnHand is not null) and (MaxOnHand is not null) and (minimumOnHand > MaxOnHand) and (MaxOnHand <> 0)
 	-- only 2 items where min > max
 	select count(*) notZero
 	from
 	(
 	select numbered,description,minimumonhand,maxonhand from dbo.Parts
 	where (minimumOnHand is not null) and (MaxOnHand is not null)
	and (minimumOnHand <> 0) and (MaxOnHand <> 0) 
	)tst --7875
 	*/
	CASE
		when (minimumOnHand is not null) and (MaxOnHand is not null) and (minimumOnHand > MaxOnHand) and (MaxOnHand <> 0) then 0
		else MaxOnHand
	end as Max_Quantity,
	-- purchasing_v_tax_code / did not put this in for MRO supply items
	-- but before you update the item in plex it has to be filled with something
	-- and accountant said I could use tax exempt.
	-- Found that EM Parts are already marked as taxable 'Y' or 'N'
	-- where taxable = 'N' --2044
	-- where taxable = 'Y'--10619
	-- Talked with Kristen about taxable = 'Y' and she said that is wrong and the 
	-- accountant also said this so I'm going to mark them all as Tax Exempt
	'Tax Exempt - Labor / Industrial Processing' as Tax_Code,
	-- I worked hard to fill the account_no with an account that could be used to catagorize items as electrical, pumps, and something
	-- else I cant remember so that Pat could use the account field to keep track of the information he needs.  But was told to quit by Casey.
	-- and leave it blank.
	'' as Account_No,
	/* Not sure if this is the manufacturer_key, manufacturer_code, or Manufacturer_Name 
	 * If not configured to use Suppliers as Supply Item manufacturers, then this field,manufacturer_text varchar(25), contains the name of the Manufacturer.
	 * All the Manufacturer fields are greater than varchar(25) so don't know what is going on?
	 * */
	--select distinct plexVendor from dbo.btMfgMap order by plexvendor --173
	/*
	case 
		when mm.plexVendor is null then 'null' --many
		when mm.plexVendor = '' then 'Empty'  --0
		when LTRIM(RTRIM(mm.plexVendor)) = '' then 'WhiteSpace' --0
		else mm.plexVendor
	end as ManufacturerTest,
	*/
	case 
		when mm.plexMfg is null then ''
		else mm.plexMfg
	end as Manufacturer,
	--mm.plexVendor as Manufacturer,  
	p.ManufacturerNumber as Manf_Item_No,
	/* do manufacturer and vendor numbers look ok -- all varchar(50) so no truncation
	select top 100 numbered, manufacturerNumber,vendornumber, description from dbo.Parts
	*/
	'' as Drawing_No,
	'' as Item_Quantity,
	'' as Location,
	sc.Supplier_Code,
	/* item_supplier.Supplier_Item_No is varchar(50) and so is vendorNumber so there should be no truncation */
	VendorNumber Supplier_Part_No, 
	'' as Supplier_Std_Purch_Qty,
	'USD' as Currency,
	CASE
		when p.BillingPrice is NOT null AND BillingPrice > 0 then BillingPrice
		else p.CurrentCost
	end as Supplier_Std_Unit_Price,
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
	end as Supplier_Purchase_Unit,
	1 as Supplier_Unit_Conversion,
	'' as Supplier_Lead_Time,
	'Y' as Update_When_Received,
	'' as Manufacturer_Item_Revision,
	'' as Country_Of_Origin,
	'' as Commodity_Code_Key,
	'' as Harmonized_Tariff_Code,
	'' as Cube_Length,
	'' as Cube_Width,
	'' as Cube_Height,
	'' as Cube_Unit
from #set7
left join dbo.Parts p
	on #set7.minRecordNumber=p.RecordNumber	
left outer join (
	select * from btSupplyCode sc
	where VendorName <> ''
) sc
on p.Vendor=sc.VendorName
left outer join btMfgMap mm
	on p.Manufacturer=mm.plexMfg
)tst
--where manufacturer = ''  --8132
--where manufacturer is null  --0
where manufacturer <> '' --2156
)tst2  --10288

--manufacturer is null  --0
select count(*) from (
select top 100 nsitemnumber,
case 
when p.Vendor is null then 'Null'
when p.Vendor = '' then 'Empty'
when LTRIM(RTRIM(p.Vendor)) = '' then 'Whitespace'
else p.Vendor
end as ven,
--p.Vendor,
case 
when sc.VendorName is null then 'Null'
when sc.VendorName = '' then 'Empty'
when LTRIM(RTRIM(sc.VendorName)) = '' then 'Whitespace'
else sc.VendorName
end as venName
from #set7
left join dbo.Parts p
	on #set7.minRecordNumber=p.RecordNumber	
--)tst --10288
left outer join (
	select * from btSupplyCode sc
	where VendorName <> ''
) sc
on p.Vendor=sc.VendorName
)tst --10288

select *
from 
parts p
left outer join dbo.btSupplyCode sc
p.Vendor=sc.VendorName

select * from dbo.btSupplyCode
where VendorName <> ''
order by 
VendorName

	left outer join btMfgMap mm
	on p.Manufacturer=mm.plexVendor


select top 10  * from  dbo.btSupplyCode
/*
nsitemnumber like '000003%'
or nsitemnumber like '000054%'
or nsitemnumber like '000091%'
or nsitemnumber like '000547%'
or nsitemnumber like '200382%'
order by nsitemnumber
--000003A -- 450  
--000054 (AV) --9145 
--000091 (E) --839  
--000547AV --13043  
--200382E  --14322
--	when suffix = 'N' then NSItemNumber + '-1'
--	when suffix = 'AV' then NSItemNumber + '-2'
--	when suffix = 'E' then NSItemNumber + '-3'
--	when suffix = 'A' then NSItemNumber + '-4'
*/
	
select * from btMfgMap
select DISTINCT Manufacturer
--,vendor, numbered, description,categoryid  
from parts
order by Manufacturer
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


--1. go through each vendor in em
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
--		where row# <= 184
		--Marshall safety
	)set1
	left outer JOIN
	dbo.btSupplyCode sc
	on set1.vendor=sc.VendorName
--	where
	--Supplier_Code is not null --69
--	Supplier_Code is null --115
)set1
where row# = 326 --done
--where row# >= 252
--and row# <= 262
--//do 196 next 195 on.
/*
select count(*)
from
(
						select DISTINCT vendor
			from 
			dbo.Parts
			where (vendor is not null) and (Vendor <> '')	
)set1

select *
from 
dbo.Parts
where vendor like 'Wes-Tech'

*/
-- Is the vendor in plex?
/*
--backup btsupplycode
SELECT *
INTO newtable [IN externaldb]
FROM oldtable
WHERE condition;
select * from btsupplycode3
select *
into dbo.btSupplyCode0607
from btsupplycode;



--drop table btm2mVendorAskKara
select * from btm2mvendor
select *
into btm2mvendorAskKara2
from btm2mvendor
**/
--Wastewater Engineers
--
select Numbered,Description,CategoryID,vendor
from 
dbo.Parts
where vendor like '%OHIO%'

select Numbered,Description,CategoryID,vendor
from 
dbo.Parts
where vendor = 'Wayne Electric'

select * 
from btSupplyCode
--where supplier_code like '%UNKNOWN%'
where supplier_code like '%A&A MANUFACTURING CO%'

--MOTION INDUSTRIES
--Okuma America Corporation
--insert into dbo.btSupplyCode VALUES ('McMaster-Carr','Active','B & C Industrial')
Motion Ind          
DIXON   --            
                    
FESTO    --           
GEMCO     --          
GENERAL BEARING CORP --
NORGREN      --       
Sentenel     --   

--What is the next supplier Code?
select *
FROM
(
select 
ROW_NUMBER() OVER(ORDER BY pomCompany ASC) AS Row#,
*
from dbo.btM2mVendor
where addToPlex = 1
)set1
where Row# = 54
--STOPPED AT 53
--STARTED AT 93
/*
--QUESTIONS: Can't find not in spreadsheet
YAMAZEN INC.
***/
--What is the New plex supplier Code?


--UNIVERSAL SEPARATORS, INC						
--1234567891234567891234567
-- Looks like 2 identical suppliers were added  so I used OTP Industrial Solutions
--OHIO TRANSMISSION & PUMP COMPANY   
--OTP Industrial Solutions

--Check Supply Code for previous mapping
--The supply code should not be in this table because it was not added to plex yet
select top 10 * from dbo.btSupplyCode
where VendorName like '%UNIVERSAL%' 
or Supplier_Code like '%UNIVERSA%'

--What is the EM vendor name it should map to?
select top 200 numbered,description,Vendor 
from dbo.Parts
where Vendor like '%Universal%'


--Create a new btSupplyCode record 
insert into dbo.btSupplyCode VALUES ('UNIVERSAL SEPARATORS, INC','Active','UNIVERSAL SEPERATORS, INC.')

--Make sure btSupplyCode was inserted
select top 10 * from dbo.btSupplyCode
where VendorName like '%UNIVERSAL SEPERATORS, INC.%' 
--delete from btsupplycode where supplier_code = 'IFM Efector'
--The number of parts not mapped to suppliers should be decreasing
select count(*) VendorsNotMapped
from
(
	select 
	ROW_NUMBER() OVER(ORDER BY vendor ASC) AS Row#,
	vendor
	from
	(
		select 
		numbered,description,Vendor,Supplier_Code 
		from dbo.Parts p
		left outer join btSupplyCode sc
		on p.Vendor=sc.VendorName
		where sc.VendorName is null
		and p.Vendor <> ''
	)set1
	group by Vendor
)set2

select count(*) VendorsNotMapped
from
(
	select 
--	top 100
	numbered,description,Vendor 
--	numbered,description,Vendor,Supplier_Code 
	from dbo.Parts p
--	where p.Vendor is null or vendor = ''
	left outer join btSupplyCode sc
	on p.Vendor=sc.VendorName
--	where sc.Supplier_Code is not null
--	and p.Vendor <> ''
--	where p.Vendor = ''
	where sc.VendorName is null
	and p.Vendor <> ''
)set1
-- Parts have Vendors but no suppliers in Plex: 15
-- Parts that have no vendors in EM: 497
-- Parts in EM that are mapped to Plex suppliers: 11817
-- Total Parts in EM: 12,329
--49
select COUNT(*) VendorNameCnt
from
(
select 
VendorName 
--VendorName 
from dbo.btSupplyCode
where VendorName=''
--group by VendorName --254
--having VendorName <> ''

/*
select 
distinct VendorName --254
--VendorName 
from dbo.btSupplyCode
where VendorName <> ''
*/
)tst
/*
select *
into dbo.btSupplyCode060709
FROM
dbo.btSupplyCode
*/

--Sanity check for Vendors
select *
FROM
(
select 
ROW_NUMBER() OVER(ORDER BY pomCompany ASC) AS Row#,
*
from dbo.btM2mVendor
where addToPlex = 1
)set1
where Row# = 1
--insert into dbo.btSupplyCode VALUES ('UNKNOWN','Active','UNITRONICS')
	--YES 
	WAUKESHA MACHINE & TOOL
	--delete from dbo.btSupplyCode where supplier_code like '%COMPLETE DRIVES%' 
		UPDATE dbo.btSupplyCode
		set vendorname = ''
		where Supplier_Code = 'Motion Ind., Inc'
		
		6 rows updated
		J.O. Mory
		-- vendor = Gosiger Indiana
		-- sup code = Gosiger Indiana
		-- insert into dbo.btSupplyCode VALUES ('Roberts Ballscrew','Active','DONGAN')
		
	--NO
		--Is this vendor in M2M?
		DECLARE @company as varchar(35)
		set @company = '%UNIVERSAL SEPARATORS%'
		--2. Check M2m to see if vendor is there.
		select 
		*
		--count(*) --2066
		--top 100 *
		from btm2mvendorAskKara1
		--WHERE addtoplex =1
		where pomcompany like @company or avcompany like @company
--MATERIALS HANDLING EQUIPMENT

update btM2mVendorAskKara2
set emvendor = 'UNIVERSAL SEPERATORS, INC.',
addToPlex=1
where pomCompany = 'UNIVERSAL SEPARATORS, INC.'
and fvendno ='003509'

--Already being added to plex
--After Kara adds to Plex Map original em vendors and also 
--add the following from Kristen's answer
--Banner -TO- C & E SALES
--Brothers - Mills -TO- YAMAZEN
--TECH SALES & MARKETING -TO- DEPATIE FLUID POWER

--Screw Ups
-- Told Kara to add 'Action Equipment' but I found it in plex
-- later spelled as 'Action Eqp.' and then mapped all the vendors from EM in btSupplyCode
-- Same with OHIO TRANSMISSION & PUMP COMPANY found it in Plex as OTP Industrial Solutions

--UNKNOWN
--Some vendors mapped to supplier UNKNOWN
--Don't know what to do with them yet

--Need more info from the internet to add to plex because not in M2m
--Fryer
--OVERTON'S (WE USUALLY BUY ONLINE)
--DESTACO

--Verify table updated correctly
		select 
		*
		--count(*) --2066
		--top 100 *
		from btm2mvendorAskKara2
		WHERE addtoplex =1
		where fvendno ='003565'


		/*
		 select * from parts where vendor like 'DIXON'
		 */
--YAMAZAN
		--YES
			update btm2mvendorAskKara2
			set addToPlex = 1
			where fvendno = '002527'
			
			
--	DR. Lubricants	
			/*
			select * from btm2mvendor where fvendno = '002582'
			update btm2mvendor set addtoplex = '' where pomcompany = 'ABRASIVE FINISHING INC.' and fvendno = '002274' 
			delete from btm2mvendor where pomcompany = 'MORI SEIKI' and fvendno = '001648'
			select * from dbo.btM2mVendor 
			WHERE addtoplex =1
			and fvendno <= 'AMETA SOLUTIONS'
			order by fvendno
			*/
		--NO
--164|KITAGAWA 
--000647 |NORTHTECH WORKHOLDING              |KITAGAWA-NOTHTECH INC.
		
			--If cant find then ask kristin
			insert into dbo.btAskKristin
			--VALUES (Vendor, Numbered,Description)
			select Vendor, Numbered,Description
			from 
			dbo.Parts
			where Vendor = 'Wes-Tech'	
			--delete from dbo.btAskKristin where Vendor = 'Wes-Tech'	
			select * from dbo.btAskKristin			
			where Vendor = 'UNI SOURCE'	
	
select top 100 * 
from btSupplyCode
--where supplier_code like '%UNKNOWN%'
where supplier_code like '%WAYNE%'
			

-- Check counts
--total vendors
select count(*)
from
(
	select DISTINCT vendor
	from 
	dbo.Parts
	where (vendor is not null) and (Vendor <> '')	
)set1 --326


NACHI             
--164|KITAGAWA 
--000647 |NORTHTECH WORKHOLDING              |KITAGAWA-NOTHTECH INC.

select 
COUNT(*) 
--*
from dbo.btM2mVendor 
WHERE addtoplex =1
--and pomCompany like '%KITAGAWA%' or avCompany like '%KITAGAWA%'
and pomCompany <= 'YUKIWA SEIKO USA INC'
-- I used Randals as a carquest substitue since it had the work - carquest at end of pomCompany field
-- I also use randals for Randalls Auto Value
--for pomCompany RANDALS AUTO STORE, INC - CARQUEST and EM vendors 'CARQUEST' and 'Randalls Auto Value'
--   Add + 2 but number of records is only 1
--+1 because carquest and randalls auto value are both mapped to Randals auto store
--+1 BOSCH-REXROTH and REXROTH both are mapped to btm2mvendors pomCompany BOSCH REXROTH CORPORATION
--+1 TPI Tork -- mapped to TPI TORK PRODUCTS INC both em vendors mapped to 1 m2m vendor
--   TORK PRODUCTS, INC. -- mapped to TPI TORK PRODUCTS INC
--100
--UPDATE dbo.btM2mVendor set addtoplex='' where fvendno = '000647' and pomcompany = 'NORTHTECH WORKHOLDING'
/*
select fvendno
from
(
	select 
	--COUNT(*) 
	*
	from dbo.btM2mVendor 
	WHERE addtoplex =1
	and pomCompany <= 'Hosez'
)set1
group by fvendno
HAVING COUNT(*) > 1
select 
*
from dbo.btM2mVendor 
WHERE fvendno = '001607'
delete from btm2mvendor where pomcompany = 'ATS SYSTEMS' and fvendno = '001607'
select 
*
from 
dbo.btSupplyCode
where VendorName = 'US SHOP TOOLS'
where VendorName <= 'X-Y TOOL'

*/
--164|KITAGAWA 
--000647 |NORTHTECH WORKHOLDING              |KITAGAWA-NOTHTECH INC.
select * from dbo.btAskKristin

	select 
	--COUNT(*) 
	*
	from dbo.btM2mVendor 
	WHERE addtoplex =1

	
select *
from btM2mVendor4
	
alter TABLE btM2mVendor
add EMVendor varchar(50)

select 
count(*)
--*
from 
dbo.btSupplyCode
--where VendorName = 'US SHOP TOOLS'
where VendorName <= 'X-Y TOOL'
and VendorName <> ''
order by VendorName
--134
select
--*
count(*)
from
(
	select 
	distinct Vendor
	from dbo.btAskKristin
	where Vendor <= 'z'	
)set1
--89
/*
REXROTH           
SHAMROCK          
*/


---5/28  This was the first query I mailed to Kristen
	select 
	*
	from dbo.btAskKristin
	where Vendor <= 'DR. Lubricants'	
-----------------------------------------
--5/29 next query mailed to kristin
	select 
	*
	from dbo.btAskKristin
	where Vendor > 'DR. Lubricants'	
and Vendor <= 'MEREDITH MACHINERY'

	select 
	*
	from dbo.btAskKristin
	where Vendor = 'Toshiba Machinery'
	order by numbered
	and numbered like '%05833A'

select 
numbered,description,manufacturer,shelf
FROM
dbo.Parts
where numbered in (
'405750A',
'705395A',
'705666A',
'705667A',
'705668A'
)

405750A |PUMP, LOADER                |            |         |
705395A |Plunger Shaft For Rebuild   |ALEMITE     |CAB M-1-1|
705666A |Retaining Clip For Enerpac  |ALEMITE     |CAB E-2-5|
705667A |REBUILD KIT FOR SLLD201&SLRD|ALEMITE     |CAB E-1-4|
705668A |REBUILD KIT FOR SLLD201&SLRD|ALEMITE     |CAB E-1-4|
/* Supplier Status */
-- How many vendors are there 326
-- How many vendors are mapped to suppliers or Unknown
select 
count(*)
FROM
(
select * 
from dbo.btSupplyCode
where VendorName <> ''
and Supplier_Status = 'Active' --214
--and Supplier_Status = 'Inactive' --0
)set1 
order by Supplier_Code
select * from 
dbo.Parts
where Vendor = 'Applied Industrial'
or Vendor = 'B & C Industrial'

/*--
 * Process to map New Supplier_Code from Kara to btSupplyCode table
*/		
select *
from
(
	select 
	row_number() OVER(ORDER BY pomCompany ASC) AS Row#,
	*
	from dbo.btM2mVendor 
	WHERE addtoplex =1
)set1 
where Row# = 2

select DISTINCT vendor
from parts
where 
vendor like '%ACTION EQUIPMENT%'


select 
Vendor,
(
	stuff(
			(
				select top 5  
				CASE
				when p.Shelf = '' then cast(CHAR(10) + LTRIM(RTRIM(ak.numbered)) + ' Descr: ' + ak.Description as varchar(max))
				else cast(CHAR(10) + LTRIM(RTRIM(ak.numbered)) + ' Descr: ' + ak.Description + ', Shelf# ' + p.Shelf as varchar(max))
				end 
				from dbo.btAskKristin ak
				left outer join dbo.Parts p
				on ak.numbered = p.Numbered
				where (ak.vendor = set1.vendor)
				order by ak.numbered
				FOR XML PATH ('')
			), 1, 1, ''
		)
) as Parts 
from 
(
	select 
	DISTINCT Vendor
	from dbo.btAskKristin 
	
)set1
	select 
	Vendor,*
	from dbo.btAskKristin 


select 
Vendor,
(
	stuff(
			(
				select top 5  
				CASE
				when p.Shelf = '' then cast(CHAR(10) + LTRIM(RTRIM(p.numbered)) + ' Descr: ' + p.Description as varchar(max))
				else cast(CHAR(10) + LTRIM(RTRIM(p.numbered)) + ' Descr: ' + p.Description + ', Shelf# ' + p.Shelf as varchar(max))
				end 
				from dbo.Parts p
				where (p.vendor = set1.vendor)
				order by p.numbered
				FOR XML PATH ('')
			), 1, 1, ''
		)
) as Parts 
from 
(
	select DISTINCT Vendor
	from dbo.Parts
	where Vendor = 'Applied Industrial'
	or Vendor = 'B & C Industrial'
	
)set1


/*
 * Duplicate part numbers
 * 
 */


select itemNumber,
(
	stuff(
			(
				select top 5  
				CASE
				when p.Shelf = '' then cast(CHAR(10) + LTRIM(RTRIM(p.numbered)) + ' Descr: ' + p.Description as varchar(max))
				else cast(CHAR(10) + LTRIM(RTRIM(p.numbered)) + ' Descr: ' + p.Description + ', Shelf# ' + p.Shelf as varchar(max))
				end 
				from dbo.Parts p
				where (p.Numbered = set1.ItemNumber)
				order by p.numbered
				FOR XML PATH ('')
			), 1, 1, ''
		)
) as Parts 

FROM
(
	select min(RecordNumber) minRecordNumber, ltrim(rtrim(Numbered)) ItemNumber, COUNT(*) partCount
	from dbo.Parts
	group by ltrim(rtrim(Numbered))
)set1
where partCount > 1


select *
FROM
(
	select min(RecordNumber) minRecordNumber, ltrim(rtrim(Numbered)) ItemNumber, COUNT(*) partCount
	from dbo.Parts
	group by ltrim(rtrim(Numbered))
)set1
where partCount > 1


450448 Descr: OIL SEAL, Shelf# NO LOCATION YET
450521 Descr: INDUSTRIAL FILTER LIGHT CURTAIN, Shelf# SHELF C
700793K Descr: Hydraulic Oil Filter For B.E. 32, Shelf# D-10
706127 Descr: HYDRAULIC CYLINDER, Shelf# B-FLOOR

select numbered,description,shelf
from dbo.Parts
	where Vendor = 'Applied Industrial'
order by numbered
				', Mfr#' + p.Manufacturer + ', ' + shelf  as varchar(max)) 

dbo.btAskKristin ak1 
select 
Vendor,
(
	stuff(
			(
				select top 5 cast(CHAR(10) + LTRIM(RTRIM(ak.numbered)) + ' Descr: ' + ak.Description + 
				CASE
				when p.Manufacturer = '' then ''
				else ', Mfr#' + p.Manufacturer
				end as mfg
				as varchar(max)) 
				from dbo.btAskKristin ak
				left outer join dbo.Parts p
				on ak.numbered = p.Numbered
				where (ak.vendor = set1.vendor)
				order by ak.numbered
				FOR XML PATH ('')
			), 1, 1, ''
		)
) as Parts 
from 
(
	select 
	DISTINCT Vendor
	from dbo.btAskKristin 
	
)set1


	

select 
Vendor,
(
	stuff(
			(
				select cast(', ' + numbered + ' Descr: ' + Description as varchar(max)) 
				from dbo.btAskKristin ak2 
				where (ak2.vendor = ak1.vendor)
				FOR XML PATH ('')
			), 1, 2, ''
		)
) as Parts 
from dbo.btAskKristin ak1 


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
	
select *
from
(
select 
row_number() OVER(ORDER BY VendorName ASC) AS Row#,
*
from dbo.btSupplyCode
where VendorName <> ''
)set1
where row# <=8



--
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

--4. transfer btM2mVendor back to plex and link to apvend
-- write report to pull vendor info so they can be added to plex.

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
	where row# <= 6 --added some of these to plex already
	--where row# <= 184 --added some of these to plex already
)set1
left outer JOIN
dbo.btSupplyCode sc
on set1.vendor=sc.VendorName
where
--Supplier_Code is not null --69
Supplier_Code is null --115

--truncate table btSupplyCode
Bulk insert btM2mVendor
from 'C:\M2mVendors0524b.csv'
with
(
fieldterminator = '|',
rowterminator = '\n'
)
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
