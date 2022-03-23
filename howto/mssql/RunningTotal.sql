
CREATE TABLE #Students
(
	Id INT PRIMARY KEY IDENTITY,
	Class int,
	StudentName VARCHAR (50),
	StudentGender VARCHAR (50),
	StudentAge INT
)

INSERT INTO #Students 
VALUES 
(1,'Sally', 'Female', 14 ),
(1,'Edward', 'Male', 12 ),
(1,'Jon', 'Male', 13 ),
(2,'Liana', 'Female', 10 ),
(2,'Ben', 'Male', 11 ),
(2,'Elice', 'Female', 12 ),
(3,'Nick', 'Male', 9 ),
(3,'Josh', 'Male', 12 ),
(3,'Liza', 'Female', 10 ),
(3,'Wick', 'Male', 15 )
-- select * from #Students

SELECT Id, StudentName, StudentGender, StudentAge,
SUM (StudentAge) OVER (ORDER BY Id) AS RunningAgeTotal
FROM Students

SELECT 
Class,StudentName, StudentGender, StudentAge,
sum(StudentAge) OVER (PARTITION BY Class ORDER BY StudentName) As TotalAge
FROM #Students