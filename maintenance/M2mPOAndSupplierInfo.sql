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
where fcompany like '%amera%'
AMERA/002676

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
	select DISTINCT pom.fvendno,pom.fcompany,av.fcompany vCompany
	from dbo.pomast pom
	left outer join dbo.apvend av
	on pom.fvendno=av.fvendno
	order by pom.fcompany
--	where pom.fbuyer ='KT'
--	and pom.fvendno='001980'
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

