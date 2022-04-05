--https://stackoverflow.com/questions/194852/how-to-concatenate-text-from-multiple-rows-into-a-single-text-string-in-sql-serv
--https://stackoverflow.com/questions/6899/how-to-create-a-sql-server-function-to-join-multiple-rows-from-a-subquery-into
--https://docs.microsoft.com/en-us/sql/relational-databases/xml/for-xml-sql-server?view=sql-server-2017
select dep.goal_key,
      LEFT(dep.depend_list,Len(dep.depend_list)-1) As "depend_list"
from 
(
  select g.goal_key,
  ( 
  	select g2.name + ',' as [text()]
  	from Goals.goal_dependancy gd
  	join Goals.goal g2
  	on gd.goal_dependancy_key=g2.goal_key
  	where g.goal_key = gd.goal_key
  	for xml path (''),TYPE 
  ).value('text()[1]','nvarchar(max)') [depend_list]
  from Goals.goal g
--  where g.goal_key in (6,7)
) dep  


If there is a table called STUDENTS

SubjectID       StudentName
----------      -------------
1               Mary
1               John
1               Sam
2               Alaina
2               Edward
Result I expected was:

SubjectID       StudentName
----------      -------------
1               Mary, John, Sam
2               Alaina, Edward
I used the following T-SQL:

SELECT Main.SubjectID,
       LEFT(Main.Students,Len(Main.Students)-1) As "Students"
FROM
    (
        SELECT DISTINCT ST2.SubjectID, 
            (
                SELECT ST1.StudentName + ',' AS [text()]
                FROM dbo.Students ST1
                WHERE ST1.SubjectID = ST2.SubjectID
                ORDER BY ST1.SubjectID
                FOR XML PATH (''), TYPE
            ).value('text()[1]','nvarchar(max)') [Students]
        FROM dbo.Students ST2
    ) [Main]
You can do the same thing in a more compact way if you can concat the commas at the beginning and use substring to skip the first one so you don't need to do a sub-query:

SELECT DISTINCT ST2.SubjectID, 
    SUBSTRING(
        (
            SELECT ','+ST1.StudentName  AS [text()]
            FROM dbo.Students ST1
            WHERE ST1.SubjectID = ST2.SubjectID
            ORDER BY ST1.SubjectID
            FOR XML PATH (''), TYPE
        ).value('text()[1]','nvarchar(max)'), 2, 1000) [Students]
FROM dbo.Students ST2

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
