--https://stackoverflow.com/questions/194852/how-to-concatenate-text-from-multiple-rows-into-a-single-text-string-in-sql-serv
--https://stackoverflow.com/questions/6899/how-to-create-a-sql-server-function-to-join-multiple-rows-from-a-subquery-into


	select 
	Vendor,
	(
		stuff(
				(
					select top 5 cast(CHAR(10) + LTRIM(RTRIM(numbered)) + ' Descr: ' + Description  as varchar(max)) 
					from dbo.btAskKristin ak 
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






	parts p1

	SELECT 
	[VehicleID], [Name],
   	(
     	STUFF(
     			(
     				SELECT CAST(', ' + [City] AS VARCHAR(MAX)) 
         			FROM [Location] 
         			WHERE (VehicleID = Vehicle.VehicleID) 
         			FOR XML PATH ('')
     			), 1, 2, ''
 			)
 	) AS Locations
	FROM [Vehicle]


	-- Express Maintenance Example

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
