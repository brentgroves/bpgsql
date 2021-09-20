-- select * from Kors.shift s 
declare @PCN integer;
set @PCN = 295932;
DECLARE @R INT, @P VARCHAR(1000);
EXEC @R=Kors.shifts_get_rs @PCN
--,@Destinations=@P OUT --OUT is short for OUTPUT, you can use either one
SELECT @R

SELECT 
sc.name AS 'ParameterName' , 
st.name AS 'Type' , 
sc.colid AS 'Column ID' , 
sc.isoutparam AS 'IsOutput' 
FROM syscolumns sc 
INNER JOIN systypes st 
ON sc.xtype = st.xtype 
WHERE 
id = object_id('Kors.test1') 
AND st.name <> 'sysname' 
ORDER BY colid

--drop procedure Kors.shifts_get_rs;
create procedure Kors.shifts_get_rs(
--create procedure Kors.shifts_get_rs(
 @PCN int = 295932
)
as
begin
	declare @Destinations varchar(1000);
	declare @x xml;
	-- declare @Destinations varchar(200);
	
	select @x=(
		select 
		'Shift:' + cast(s.shift as varchar(1)) + 
		' - Start:' + cast(s.shift_start as varchar(8)) +
		' - End:' + cast(s.shift_end as varchar(8)) +  CHAR(13) + CHAR(10)
		from Kors.shift s
		where s.pcn = @PCN
		for xml path(''),type);
	
	select @Destinations=(@x.value('(./text())[1]','nvarchar(max)'));
	select @Destinations;
   	RETURN 0;
end

exec Kors.test
create procedure Kors.test
as
begin
	select 'test';
end
--drop procedure Kors.shifts_get_op;
create procedure Kors.shifts_get_op(
 @PCN int= 295932,
 @Destinations varchar(200)='Success' OUTPUT
)
as
begin
	declare @x xml;
	
	select @x=(
		select 
		'Shift:' + cast(s.shift as varchar(1)) + 
		' - Start:' + cast(s.shift_start as varchar(8)) +
		' - End:' + cast(s.shift_end as varchar(8)) +  CHAR(13) + CHAR(10)
		from Kors.shift s
		where s.pcn = @PCN
		for xml path(''),type);
	
	select @Destinations=(@x.value('(./text())[1]','nvarchar(max)'));
   	RETURN 0;
end


declare @PCN integer;
set @PCN = 295932;
DECLARE @R INT, @P VARCHAR(1000);
--EXEC @R=Kors.shifts_get_op @PCN
--SELECT @R
EXEC @R=Kors.shifts_get_op @PCN,@Destinations=@P OUT --OUT is short for OUTPUT, you can use either one
SELECT @R,@P

SELECT 
sc.name AS 'ParameterName' , 
st.name AS 'Type' , 
sc.colid AS 'Column ID' , 
sc.isoutparam AS 'IsOutput' 
FROM syscolumns sc 
INNER JOIN systypes st 
ON sc.xtype = st.xtype 
WHERE 
id = object_id('Kors.shifts_get_op') 
AND st.name <> 'sysname' 
ORDER BY colid

