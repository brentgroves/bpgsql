create procedure ETL.script_start 
(
	@script_key int
)
as 
begin 
	--declare @script_key int; 
	--set @script_key = 4;
	insert into ETL.script_history
	select @script_key,getdate(),null,0,null,null
	
end;

select * from ETL.Script_History sh 
where Script_Key = 1
order by Script_History_Key desc

create procedure ETL.script_end 
(
	@script_key int,
	@error_bit bit
)
as 
begin 
	--declare @script_key int;
	--set @script_key = 4;
	--declare @error_bit bit; 
	--set @error_bit = 0;
	declare @script_history_key int;
	declare @cur_time datetime;
	declare @start_time datetime; 
	set @cur_time = getdate();
	select top 1 @script_history_key=script_history_key,@start_time=start_time  
	from ETL.script_history
	where script_key = @script_key 
	and done = 0
	order by start_time desc 
  --  select @script_history_key,@start_time,DATEDIFF(ss, @start_time,@cur_time); 	
	update ETL.script_history  
	set end_time = @cur_time,
	done = 1,
	error = @error_bit,
	time = DATEDIFF(ss, @start_time,@cur_time)
	where script_history_key = @script_history_key 
end;


