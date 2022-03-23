
/*

https://www.sqlshack.com/converting-commas-or-other-delimiters-to-a-table-or-list-in-sql-server-using-t-sql/
there are many ways to do this.  Plex supports the while loop and stuff functions.

*/
/*
CREATE FUNCTION split_string
(
    @in_string VARCHAR(MAX),
    @delimeter VARCHAR(1)
)
RETURNS @list TABLE(tuple VARCHAR(100))
AS
BEGIN
        WHILE LEN(@in_string) > 0
        BEGIN
            INSERT INTO @list(tuple)
            SELECT left(@in_string, charindex(@delimiter, @in_string+',') -1) as tuple
    
            SET @in_string = stuff(@in_string, 1, charindex(@delimiter, @in_string + @delimiter), '')
        end
    RETURN 
END

*/
/*
The STUFF() function deletes a part of a string and then inserts another part into the string, starting at a specified position.

Tip: Also look at the REPLACE() function.

Syntax
STUFF(string, start, length, new_string)
*/

create table #list
(
 value varchar(6)
)
declare @delimiter varchar(1)
set @delimiter = ','
declare @in_string varchar(max)
set @in_string = '300758,310507,306766'

select stuff(@in_string, 1, charindex(@delimiter, @in_string + @delimiter), '')

        WHILE LEN(@in_string) > 0
        BEGIN
            INSERT INTO #list
            SELECT left(@in_string, charindex(@delimiter, @in_string+',') -1) as tuple
    
            SET @in_string = stuff(@in_string, 1, charindex(@delimiter, @in_string + @delimiter), '')
        end
        
select top 10 part_no from part_v_part_e
where plexus_customer_no in 
(
select * from #list
)