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
end;
--select tuple from #list



with balance_add_date
as 
( 
--  select *
  select distinct plexus_customer_no pcn, period,add_date  
  from accounting_v_balance_e b
  --	where @prev_year between ap.begin_date and ap.end_date 
  where b.plexus_customer_no in 
  (
    select tuple from #list
  )	
  AND b.Period BETWEEN @PeriodStart AND @PeriodEnd
),
max_balance_add_date 
as 
(
  select pcn,period,max(add_date) add_date
  from balance_add_date
  group by pcn,period
),
--select * from max_balance_add_date
period_update
as 
(
  select p.plexus_customer_no pcn, 
  p.period_key,
  p.period,
  p.period_display,
  p.fiscal_order,
  p.quarter_group,
  p.begin_date,
  p.end_date,
  p.period_status,
  p.updated_date
 -- select *
  FROM accounting_v_Period_e AS P  
--	where @prev_year between ap.begin_date and ap.end_date 
  where p.plexus_customer_no in 
  (
    select tuple from #list
  )	  
  AND P.Period BETWEEN @PeriodStart AND @PeriodEnd
)
--select * from period_update
-- plexus_customer_no pcn,period_key,period,fiscal_order,begin_date,end_date,period_display,quarter_group

select 
pu.pcn
,pu.period_key
,pu.period
,pu.period_display
,pu.fiscal_order
,pu.quarter_group
,pu.begin_date
,pu.end_date
,pu.period_status  -- add this to dw
,ad.add_date add_date -- add this to dw
,pu.updated_date updated_date -- add this to dw

from period_update pu 
left outer join max_balance_add_date ad 
on pu.pcn=ad.pcn
and pu.period=ad.period
order by pcn,period

/*
When was the add date for the balance records for period 202203? 4/8/2022 2:09:33 
*/
/*
select *
--select distinct plexus_customer_no pcn, period  
  from accounting_v_balance_e b
  where b.plexus_customer_no = 123681 
  and b.period = 202203
*/  
/*
When did the last period update occur for 202203? 4/8/2022 2:10 pm
*/
/*
SELECT period,fiscal_order,begin_date,end_date,period_display,quarter_group,*
FROM accounting_v_Period_e AS P  
where p.plexus_customer_no = 123681 
and p.period between 202203 and 202203;
*/
/*
When did last account activity occur for each period?
call this Plex.period_status
*/



