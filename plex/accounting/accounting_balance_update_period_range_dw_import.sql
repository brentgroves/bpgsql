/*
create PCN table from param
*/
create table #list
(
 tuple int
)
declare @delimiter varchar(1)
set @delimiter = ','
declare @in_string varchar(max)
set @in_string = @PCNList
WHILE LEN(@in_string) > 0
BEGIN
    INSERT INTO #list
    SELECT cast(left(@in_string, charindex(@delimiter, @in_string+',') -1) as int) as tuple

    SET @in_string = stuff(@in_string, 1, charindex(@delimiter, @in_string + @delimiter), '')
end
--select tuple from #list

--declare @today datetime
--select @today=getdate()
declare @prev_year datetime
SELECT @prev_year = DATEADD(year,-1,GETDATE())
declare @start_period int;
declare @end_period int;
--select @start_period = 202102;
	
--/*
--	select @start_period =min(period) from accounting_v_period_e ap 
--*/

declare @last_day_prev_month datetime;
declare @first_day_prev_month datetime;
--SELECT @last_day_prev_month = EOMONTH (GETDATE(), -1);   

declare @t datetime
select @t=DATEADD(day, 1,EOMONTH (GETDATE(), -1)); 
SELECT @last_day_prev_month = DATEADD(ss, -1, @t);
SELECT @first_day_prev_month = DATEADD(day, 1,EOMONTH (GETDATE(), -2));   



--select @prev_year prev_year,@start_period start_period,@first_day_prev_month first_day_prev_month,@last_day_prev_month last_day_prev_month;

with start_period
as 
(
  select plexus_customer_no pcn,period start_period from accounting_v_period_e ap 
--	where @prev_year between ap.begin_date and ap.end_date 
  where ap.plexus_customer_no in 
  (
    select tuple from #list
  )	
  and @prev_year between ap.begin_date and ap.end_date
),
--select * from start_period
balance
as 
(
  select distinct plexus_customer_no pcn, period  from accounting_v_balance_e b
  where b.plexus_customer_no in 
  (
    select tuple from #list
  )
),
add_dates
as 
(
select b.pcn,b.period,p.begin_date,p.end_date
from accounting_v_period_e p 
inner join balance b
on p.plexus_customer_no=b.pcn 
and p.period=b.period
where p.end_date between @first_day_prev_month and @last_day_prev_month

),
--select * from add_dates;
last_full_period
as
(
  select pcn,max(period) last_full_period from add_dates group by pcn
)
--select * from last_full_period;
-- After 202202 use this code
--select s.pcn,s.start_period,l.last_full_period end_period
select s.pcn,202102 start_period,l.last_full_period end_period
from start_period s
inner join last_full_period l
on s.pcn=l.pcn;

