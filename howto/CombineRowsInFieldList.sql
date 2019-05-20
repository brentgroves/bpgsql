--https://stackoverflow.com/questions/194852/how-to-concatenate-text-from-multiple-rows-into-a-single-text-string-in-sql-serv
--https://stackoverflow.com/questions/6899/how-to-create-a-sql-server-function-to-join-multiple-rows-from-a-subquery-into
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