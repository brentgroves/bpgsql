select top 10 fbuyer,fpono,fvendno,* from dbo.pomast
--where fbuyer ='KT'
where fpono in
('140170','141717','141787')
--where fchangeby like '%Kris%' 

select fcomments,fdescript,* from poitem
where 
fpono = '140170'

select fvendno,*
FROM
 dbo.apvend av
where fcompany like '%Wright Repair%'
AMERA/002676

-- Drop table

-- DROP TABLE ExpressMaintenance.dbo.btM2mVendor GO

CREATE TABLE btM2mVendorAskKara2 (
	fvendno char(6),
	pomCompany varchar(35),
	avCompany varchar(35),
	addToPlex bit,
	EMVendor varchar(50)
)
-- Drop table

-- DROP TABLE ExpressMaintenance.dbo.btm2mvendorAskKara2 GO


select --top 100
'Supplier_Code' Supplier_Code,pomCompany,fcompany avCompany,fmstreet Street,fcity City,fstate State,fzip Zip,fphone Phone,ffax Fax,'#' + pv.fvendno M2mVN#
from 
dbo.btM2mVendor pv
--dbo.btM2mVendorAskKara2 pv
left outer join dbo.apvend av
on pv.fvendno=av.fvendno
where pomCompany like '%Universal%'
--where pomCompany not like '%Action Equipment%'

select --top 100
'Supplier_Code' Supplier_Code,fcompany avCompany,fmstreet Street,fcity City,fstate State,fzip Zip,fphone Phone,ffax Fax,'#' + fvendno M2mVN#
FROM
dbo.apvend
--where fcompany like '%ROBO%HAND%'
where fcompany in ('UNIVERSAL SEPARATORS, INC.') 
from 
(
select 
fvendno,pomCompany,avCompany
--count(*) 
from 
dbo.btM2mVendor
where pomCompany not in
('OHIO TRANSMISSION & PUMP COMPANY','Action Equipment')
UNION
select 
fvendno,pomCompany,avCompany
--count(*) 
from 
dbo.btM2mVendorAskKara2 pv
)pv
left outer join dbo.apvend av
on pv.fvendno=av.fvendno
ORDER by pomCompany


dbo.btM2mVendor
('MATERIALS HANDLING EQUIPMENT',
'MonTech . INC.',
'UNIVERSAL SEPARATORS, INC.')

--Already being added to plex
--After Kara adds to Plex Map original em vendors and also 
--add the following from Kristen's answer
--Banner -TO- C & E SALES
--Brothers - Mills -TO- YAMAZEN

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

select * from btM2mVendorAskKara2
--Bulk insert btM2mVendorAskKara2
from 'C:\Vendors0603.csv'
with
(
fieldterminator = '|',
rowterminator = '\n'
)


select * from dbo.btM2mVendor

DECLARE @dateStart datetime;
set @dateStart = '20130101';
DECLARE @dateEnd datetime;
set @dateEnd = getdate();
--set @dateEnd = DATEADD(DAY, 364, @dateVar);
select 
--fvendno,
count(*) --85
from
(
declare @ven varchar(50)
set @ven = 'Univers'
select DISTINCT pom.fvendno,pom.fcompany,av.fcompany vCompany
	from dbo.pomast pom
	left outer join dbo.apvend av
	on pom.fvendno=av.fvendno
--	order by pom.fcompany
where pom.fcompany like '%' + @ven +'%'
or av.fcompany like '%' + @ven +'%'


or 
	where pom.fbuyer ='KT'
	and pom.fvendno='002458'
--	and pom.fcompany <> av.fcompany
--	and fcreate >= @dateStart and fcreate <= @dateEnd
--	and po
)set1

group by fvendno
having count(*) > 1  --3
--

--give enough information to add supplier to plex
select 
top 10
fvendno,fcompany,fcontact, fcity,fcountry,fphone
from 
dbo.apvend av
where av.fvendno='001980'

DECLARE @dateVar datetime;
set @dateVar = '20130101';
DECLARE @dateEnd datetime;
set @dateEnd = getdate();

select pom.fbuyer,fpono,pom.fcreate,pom.fvendno,pom.
fcompany,av.fcompany,
av.fcontact, fcity,fstate,fcountry,fzip,fphone
from dbo.pomast pom
left outer join dbo.apvend av
on pom.fvendno=av.fvendno
where pom.fbuyer ='KT'
and fcreate >= @dateVar and fcreate <= @dateEnd


--('140170','141717','141787')

