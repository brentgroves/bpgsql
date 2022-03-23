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

    
declare @myAddress VARCHAR(200)
--set @myAddress  = '7890 – 20th Ave E Apt 2A| Seattle| VA'
--set @myAddress = '300758|H224079R|H.4'
select @myAddress 
set @myAddress  = 'one|two| three|four&five'
select replace(@myAddress,'.','+')  -- ONLY needede IF dots ARE IN original data
select REVERSE(replace(@myAddress,'.','+'))
select REPLACE(REVERSE(replace(@myAddress,'.','+')),'|','.')
select PARSENAME(REPLACE(REVERSE(replace(@myAddress,'.','+')),'|','.'),4)
select replace(PARSENAME(REPLACE(REVERSE(replace(@myAddress,'.','+')),'|','.'),4),'&','.')
select parsename(replace(PARSENAME(REPLACE(REVERSE(replace(@myAddress,'.','+')),'|','.'),4),'&','.'),1)
select parsename(replace(PARSENAME(REPLACE(REVERSE(replace(@myAddress,'.','+')),'|','.'),4),'&','.'),2)
select REVERSE(PARSENAME(REPLACE(REVERSE(replace(@myAddress,'.','+')),'|','.'),3))
select REPLACE(REVERSE(PARSENAME(REPLACE(REVERSE(replace(@myAddress,'.','+')),'|','.'),3)),'+','.')



    