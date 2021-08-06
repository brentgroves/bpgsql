Declare @Todays_Date datetime 
set @Todays_Date = CAST(getdate() as DATE)
Declare @By_Due_Date datetime 
set @By_Due_Date = DATEADD (dd , @ForwardDayWindow + 1 , @Todays_Date ) 

Declare @From_Shipped_Date datetime 
set @From_Shipped_Date = DATEADD(month,-@BackwardMonthWindow,DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0)) 
select @From_Shipped_Date FromShippedDate

select
sh.shipper_no,
sl.part_key,
sh.ship_date,
c.quantity
--sh.*,
--c.*
-- select count(*)
from sales_v_release_e sr
inner join sales_v_Shipper_Line_Release slr
on sr.release_key= slr.release_key
inner join sales_v_shipper_line sl
on slr.shipper_line_key=sl.shipper_line_key
inner join sales_v_shipper_container c
on sl.shipper_line_key=c.shipper_line_key
inner join sales_v_shipper sh
on sl.shipper_key = sh.shipper_key
where sl.part_key = 2800320
and sh.ship_date > @From_Shipped_Date
order by sh.shipper_no
