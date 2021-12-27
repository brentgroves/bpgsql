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
--select @Period_Min period_min,@Period_Max period_max


declare @year_start int
declare @month_start int
declare @date datetime
declare @start_date datetime
declare @end_date datetime

declare @period_start int 
declare @period_end int


set @year_start = year(dateadd("Month",-12,getdate()))
set @month_start = month(dateadd("Month",-12,getdate()))
set @date = dateadd("Month",-12,getdate())
set @start_date = DATEADD(mm, DATEDIFF(mm, 0, @date), 0)
set @end_date = EOMONTH(@date); 



/*
There can be multiple periods in a month so
this should ensure we have the correct period that
was in affect 6 months ago
*/
with pcn_period(pcn,period)
as
(
  select plexus_customer_no pcn,period  -- the period number that we are going to start from.
  from accounting_v_period_e p 
  where p.plexus_customer_no in
  (
   select tuple from #list
  )
  and p.begin_date between @start_date and @end_date
),
start_period(pcn,period)
as
(
select pp.pcn, max(period) period_start  -- the period number that we are going to start from.
from pcn_period pp
group by pp.pcn
),
--select * from start_period
balance_pcn_period(pcn,period)
as
(
  select b.plexus_customer_no pcn,b.period -- each pcn can have a different max value.
  from accounting_v_balance_e b
--group by b.plexus_customer_no
--order by b.plexus_customer_no
  where b.plexus_customer_no in
  (
   select tuple from #list
  )
),
end_period(pcn,period)
as
(
  select b.pcn,max(b.period) period -- the last period that has balance records.
  from balance_pcn_period b
  group by b.pcn  
)
--select * from end_period
select s.pcn,s.period start_period,e.period end_period
from start_period s 
inner join end_period e 
on s.pcn=e.pcn

--select @date prior_date,@start_date start_date,@end_date end_date;
--select @period_start period_start,@period_end period_end;