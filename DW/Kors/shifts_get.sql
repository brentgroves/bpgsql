-- select * from Kors.shift s 
declare @PCN integer;
set @PCN = 295932;
DECLARE @R INT, @P VARCHAR(1000);
EXEC @R=Kors.shifts_get @PCN,@Destinations=@P OUT --OUT is short for OUTPUT, you can use either one
SELECT @R, @P

--drop procedure Kors.shifts_get;
create procedure Kors.shifts_get(
 @PCN int,
 @Destinations varchar(200) OUTPUT
)
as
begin
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
	--select len(@Destinations)
   	RETURN 0;
end