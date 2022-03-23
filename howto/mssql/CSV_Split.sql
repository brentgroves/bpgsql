-- https://stackoverflow.com/questions/3660734/create-a-table-from-csv-columns-in-sql-server-without-using-a-cursor/3660785#3660785
CREATE FUNCTION dbo.Split(@origString varchar(max), @Delimiter char(1))     
returns @temptable TABLE (items varchar(max))     
as     
begin     
    declare @idx int     
    declare @split varchar(max)     

    select @idx = 1     
        if len(@origString )<1 or @origString is null  return     

    while @idx!= 0     
    begin     
        set @idx = charindex(@Delimiter,@origString)     
        if @idx!=0     
            set @split= left(@origString,@idx - 1)     
        else     
            set @split= @origString

        if(len(@split)>0)
            insert into @temptable(Items) values(@split)     

        set @origString= right(@origString,len(@origString) - @idx)     
        if len(@origString) = 0 break     
    end 
return     
end

Select * From dbo.Split('1,2,3,4',',')

CREATE FUNCTION dbo.SplitStrings_XML
(
   @List       NVARCHAR(MAX),
   @Delimiter  NVARCHAR(255)
)
RETURNS TABLE
WITH SCHEMABINDING
AS
   RETURN 
   (  
      SELECT Item = y.i.value('(./text())[1]', 'nvarchar(4000)')
      FROM 
      ( 
        SELECT x = CONVERT(XML, '<i>' 
          + REPLACE(@List, @Delimiter, '</i><i>') 
          + '</i>').query('.')
      ) AS a CROSS APPLY x.nodes('i') AS y(i)
   );
GO
compatibility level 130 or >
SELECT * FROM string_split('Pub,RegUser,ServiceAdmin',',')