/*
 * use string_split to generate table from delimited string
 
 */


/*
 * Use substring to make 2 columns from 1 delimited column.
 * Does not work for more than 2 fields in the string
 */
Field1, Field2, Field3
Field1 is a column of type string with '|' as a separator.

It has the following form:

Part1|Part2
--I'd like to write a SQL query which returns the following columns:
Part1, Part2, Field2, Field3
What is the best way to do that?

SELECT SUBSTRING(Field1, 1, CHARINDEX('|', Field1)-1) AS Part1,
       SUBSTRING(Field1, CHARINDEX('|', Field1)+1, LEN(Field1)) AS Part2,
       Field2,
       Field3
FROM yourTable


/*
 * This works for as many columns you need to separate a string into.
 * PARSENAME is meant to split dot separated values 
 * if you have dots in string you must first replace them.
 */
https://www.mssqltips.com/sqlservertip/6321/split-delimited-string-into-columns-in-sql-server-with-parsename/
truncate table Scratch.custAddress
CREATE TABLE Scratch.custAddress(
     colID INT IDENTITY PRIMARY KEY
   , myAddress VARCHAR(200)
   );
/*   
  INSERT INTO Scratch.custAddress(myAddress)
VALUES('7890 – 20th Ave E Apt 2A, Seattle, VA')
    , ('9012 W Capital Way, Tacoma, CA')
    , ('5678 Old Redmond Rd, Fletcher, OK')
    , ('3456 Coventry House Miner Rd, Richmond, TX')
SELECT 
     REVERSE(PARSENAME(REPLACE(REVERSE(myAddress), ',', '.'), 1)) AS [Street]
   , REVERSE(PARSENAME(REPLACE(REVERSE(myAddress), ',', '.'), 2)) AS [City]
   , REVERSE(PARSENAME(REPLACE(REVERSE(myAddress), ',', '.'), 3)) AS [State]
FROM Scratch.custAddress;    
*/
  INSERT INTO Scratch.custAddress(myAddress)
VALUES('7890 – 20th Ave E Apt 2A| Seattle| VA')
    , ('9012 W Capital Way| Tacoma| CA')
    , ('5678 Old Redmond Rd| Fletcher| OK')
    , ('3456 Coventry House Miner Rd| Richmond| TX')
SELECT *
FROM Scratch.custAddress;

SELECT 
     REVERSE(PARSENAME(REPLACE(REVERSE(myAddress), '|', '.'), 1)) AS [Street]
   , REVERSE(PARSENAME(REPLACE(REVERSE(myAddress), '|', '.'), 2)) AS [City]
   , REVERSE(PARSENAME(REPLACE(REVERSE(myAddress), '|', '.'), 3)) AS [State]
FROM Scratch.custAddress;
    
declare @myAddress VARCHAR(200)
--set @myAddress  = '7890 – 20th Ave E Apt 2A| Seattle| VA'
set @myAddress = '300758|H224079R|H.4'
select @myAddress 
select replace(@myAddress,'.','+')
select REVERSE(replace(@myAddress,'.','+'))
select REPLACE(REVERSE(replace(@myAddress,'.','+')),'|','.')
select REVERSE(PARSENAME(REPLACE(REVERSE(replace(@myAddress,'.','+')),'|','.'),3))
select REPLACE(REVERSE(PARSENAME(REPLACE(REVERSE(replace(@myAddress,'.','+')),'|','.'),3)),'+','.')

    