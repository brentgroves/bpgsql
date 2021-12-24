/*
	PCN
	310507/Avilla
	300758/Albion
	295933/Franklin
	300757/Alabama
	306766/Edon
	312055/ BPG WorkHolding
	1	123681 / Southfield
2	295932 FruitPort
3	295933
4	300757
5	300758
6	306766
7	310507
8	312055
	*/
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

select 
a.plexus_customer_no pcn, 
a.account_no,
year(getdate()) year, 
a.category_type,
case
  when a.category_type in ('Revenue','Expense') then 1
  else 0
end revenue_or_expense
-- select count(*)
from accounting_v_account_e a 
where a.plexus_customer_no in 
(
  select tuple from #list
)  -- 4363
--and a.category_type in ('Revenue','Expense') and left(a.account_no,1) < 4  -- 22
/*
At the end of 2021 in Southfield all the low accounts and high accounts have the correct category type.
The only note is that 73100-000-0000 changed to a 'Revenue' or 'Expense' so PP_ytd_debit and PP_ytd_credit  at some point before the beginning of 2021 so the YTD balance got reset on 2021-01, 
but if we compare our YTD values to the TB before 2021 the values will be off.  
Going forward we have a DW.Plex.year_category_type table that will have an account category type value for each year that can be used to determine if we should reset 
the YTD values at the beginning of each year.  
*/
--and a.category_type not in ('Revenue','Expense') and left(a.account_no,1) > 3  -- 0

order by a.plexus_customer_no, a.account_no