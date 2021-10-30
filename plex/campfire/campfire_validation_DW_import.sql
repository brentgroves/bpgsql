/*
Does campfire extract procedure give the same results as the Revenue Analysis by Part report?
Taken from AR_Invoice_Dist_Get and GL_Account_Activity_Summary_Period customer data source
*/
/*
Params
@PCNList varchar(max) = '123681,300758,300757,310507,306766,295932',
@Start_Date DATETIME = '10/1/2021'
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
end
-- select tuple from #list


/*
Taken from AR_Invoice_Dist_Get customer data source

*/
--/*
--select 'The following was taken from AR_Invoice_Dist_Get customer data source'
select 
I.Plexus_Customer_No pcn,
I.Invoice_Link,
I.Invoice_No,
--       ID.Description,
D.part_Key,
p.part_no,
I.Invoice_Date,

d.quantity,
d.line_item_no,
d.account_no,
d.description,
d.debit,
d.credit,
d.offset
into #invoice_dist_offset_0
--select count(*)
FROM accounting_v_AR_Invoice_e AS I 
JOIN accounting_v_AR_Invoice_Dist_e AS D 
  ON D.Plexus_Customer_No = I.Plexus_Customer_No
  AND D.Invoice_Link = I.Invoice_Link
  AND D.Offset = 0  -- see note below, 
join part_v_part_e p
on d.plexus_customer_no=p.plexus_customer_no
and d.part_key=p.part_key
--where d.part_key = 2796137
where I.plexus_customer_no in
(
 select tuple from #list
)
AND I.Period BETWEEN @Period AND @Period -- faster than =
--and I.Invoice_Date >= @Current_Month_Begin
--and I.Invoice_Date < @Month_1_Begin
order by d.part_key

/*
-- Don't include offset 1 unless we find a good reason.
*/

select
i.pcn,
i.part_key,
0 offset,
--i.part_no,
sum(i.quantity) quantity
--select count(*)
into #invoice_dist_offset_0_sum
FROM #invoice_dist_offset_0 AS i 
group by i.pcn,i.part_key
-- select count(*) invoice_dist_offset_0_sum from #invoice_dist_offset_0_sum
select 
s.pcn,
@Period period,
s.part_key,
p.part_no,
p.name,
s.quantity
--select count(*)
from #invoice_dist_offset_0_sum s 
inner join part_v_part_e p
on s.pcn=p.plexus_customer_no
and s.part_key=p.part_key
--where p.part_no = 'L1MW 4A028 GA'
/*
Validate:
Are these quantities the same as that seen on the 
Plex Revenue Analysis by part report
Tested:
F81Z 3105 BA - pass
L1MW 4A028 GA 
P131 Front RH
*/





















/*
Offset 0 Notes 
I don't believe any part_no are tied to ar_invoice_dist records.
In the pcn i checked only the the accounts receivable 10220-000-00000
account with no part key has any acctivity for this offset.
select d.part_key,*
from accounting_v_AR_Invoice_Dist_e AS D 
where d.offset=1
and d.part_key is not null  

*/
/*
-- Offset 1 is limited to Southfield invoices for the 10220-000-00000 Accounts Recievable account.
-- Don't include offset 1 for now at least for campfire queries which are tied to part number totals.
select
i.pcn,
i.part_key,
1 offset,
--i.part_no,
sum(i.quantity) quantity
--select count(*)
into #invoice_dist_offset_1_sum
FROM #invoice_dist_offset_1 AS i 
group by i.pcn,i.part_key

--select count(*) invoice_dist_offset_1_sum from #invoice_dist_offset_1_sum  -- 0

*/

