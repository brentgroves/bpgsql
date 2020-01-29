/********************************************************
 * Find all Maintenance PO within the last 2 years
 */

select top 10 * from pomast where fbuyer = 'CM' --KT
select DISTINCT fbuyer from pomast

DECLARE @datetime datetime
Set @datetime = '2018-01-01 00:00:00'
  
--SELECT @datetime AS '@datetime'; 

select 
count(*) cnt
from dbo.pomast
where forddate >= @datetime --10689
and fbuyer <> 'CM' --7706
and fbuyer = 'KT'  --3947

/*********************************************************
* When Kristen purchased items what column did she put the 
* part number
*/

select top 10 * 
from pomast 
where fbuyer = 'KT' --KT

DECLARE @dateStart datetime;
set @dateStart = '20180101';
DECLARE @dateEnd datetime;
set @dateEnd = getdate();

select pom.fbuyer,fpono,pom.fcreate,pom.fvendno,pom.
fcompany,av.fcompany,
av.fcontact, fcity,fstate,fcountry,fzip,fphone
from dbo.pomast pom
left outer join dbo.apvend av
on pom.fvendno=av.fvendno
where pom.fbuyer ='KT'
and fcreate >= @dateStart and fcreate <= @dateEnd



/****************************************************************
 * What column contains the manufacturer part number, order quantity, unit cost
 */

DECLARE @dateStart datetime;
set @dateStart = '20180101';
DECLARE @dateEnd datetime;
set @dateEnd = getdate();

select 
top 100
--po.fbuyer,
--po.fpono,
po.fcreate,
po.fcompany,
poi.fpartno,
poi.fordqty, --How many we orderd
--poi.fvordqty, --How many did we order / same as fordqty
--poi.flstcost, --How much did it cost last / often zero
poi.fucost,  --Unit cost
--poi.fvucost,  --Same as unit cost
poi.fcomments --This is in a standard format that Kristen use BE# XXXXXX
--poi.fdescript --No part number or BE# info
--av.fcontact, fcity,fstate,fcountry,fzip,fphone
from dbo.pomast po
left outer join dbo.apvend av  --1 to 1
on po.fvendno=av.fvendno
left outer join poitem poi  --1 to many
on po.fpono=poi.fpono
where po.fbuyer ='KT'
and po.fcreate >= @dateStart and po.fcreate <= @dateEnd
and poi.fcomments like '%BE#%'


/**********************************************************************
 * Pull only BE# items
 */

DECLARE @dateStart datetime;
set @dateStart = '20190101';
DECLARE @dateEnd datetime;
set @dateEnd = '20190331'
--set @dateEnd = getdate();
--drop table bePoItems2
select 
--top 100
--po.fbuyer,
po.fcreate,
po.fcompany,
po.fpono,
poi.fpartno,
poi.fordqty, --How many we orderd
--poi.fvordqty, --How many did we order / same as fordqty
--poi.flstcost, --How much did it cost last / often zero
poi.fucost,  --Unit cost
poi.fordqty * poi.fucost as totalCost,
--poi.fvucost,  --Same as unit cost
poi.fcomments --This is in a standard format that Kristen use BE# XXXXXX
--poi.fdescript --No part number or BE# info
--av.fcontact, fcity,fstate,fcountry,fzip,fphone
into bePoItems2
from dbo.pomast po
left outer join dbo.apvend av  --1 to 1
on po.fvendno=av.fvendno
left outer join poitem poi  --1 to many
on po.fpono=poi.fpono
where po.fbuyer ='KT'
and po.fcreate >= @dateStart and po.fcreate <= @dateEnd
and poi.fcomments like '%BE#%'

select 
count(*) cnt 
from dbo.bePoItems2  --340,2125,

--drop table beStockedOrders2
select 
CASE
	when endBENumber = 0 then SUBSTRING(fcomments,startBENumber,datalength(fcomments)-startBENumber+1)
	--RIGHT(fcomments,datalength(fcomments)-startBENumber)
	else SUBSTRING(fcomments,startBENumber,endBENumber-startBENumber)
end as BENumber,
fpono,
fpartno,
fordqty,
fucost,
totalCost,
fcreate

--fcreate,fcompany,fpartno,
--*

into beStockedOrders2
from
(
select 
--top 100
*,
--
--ASCII(SUBSTRING(fcomments, 10, 5)),   
--      CHAR(ASCII(SUBSTRING(@string, @position, 1)))  
CHARINDEX('BE#', fcomments) startBENumber,
--    CHARINDEX('is','This is a my sister',5) start_at_fifth,
CHARINDEX(CHAR(10),fcomments,CHARINDEX('BE#', fcomments)) endBENumber
--CHARINDEX(CHAR(ASCII(10)),fcomments,CHARINDEX('BE#', fcomments)) endBENumber
--SUBSTRING(fcomments,CHARINDEX('BE#', fcomments),5)
--COLLATE Latin1_General_CS_AS --case insensitive search
from dbo.bePoItems2  --2125
--where fpartno = 'H1082-1006-14'
) set1
--where endBENumber = 0
select
*
--count(*) 
--top 100 *
from dbo.beStockedOrders2  --2125,340
order by benumber,fcreate


/*************************************************************************
 * Put BE Number into Plex format
 * 
 */

/**************************************************************************
 * Are these numbers in Plex?
 */

/********************************
 * Transform Numbers
 *///////////////
