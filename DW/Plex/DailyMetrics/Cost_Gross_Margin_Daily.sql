-- mgdw.Plex.Cost_Gross_Margin_Get definition

-- Drop table
-- mgdw.Plex.Cost_Gross_Margin_Daily definition

-- Drop table

-- DROP TABLE mgdw.Plex.Cost_Gross_Margin_Daily;

-- use our part numbers 
price from shipper. 

CREATE TABLE mgdw.Plex.Cost_Gross_Margin_Daily (
	PCN int NOT NULL,
	Plexus_Customer_Code varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Report_Date datetime NULL,
	Customer_Code varchar(35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Salesperson varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Order_No varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	PO_No varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Part_No varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Product_Type varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Part_Description varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Sales_Qty decimal(19,5) NULL,
	Sales_Unit varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Quantity decimal(19,5) NULL,
	Quantity_Unit varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Unit_Price decimal(19,7) NULL,
	Revenue decimal(19,7) NULL,
	Invoice_No varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Part_Type varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Part_Group varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	PO_Type varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Net_Weight decimal(19,5) NULL,
	Total decimal(19,7) NULL,
	Customer_Abbreviated_Name varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Customer_Currency_Code varchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Gross_Margin_Key int NULL,
	Customer_Category varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Customer_Type varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Part_Source varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Production_Qty decimal(19,5) NULL,
	Part_Revision varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Customer_Part_No varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Customer_Part_Revision varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Sequence_No varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Master_No varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Cost_Model_Key int NULL
);
 CREATE CLUSTERED INDEX IX_Plex_Cost_Gross_Margin_Daily ON Plex.Cost_Gross_Margin_Daily (  PCN ASC  , Report_Date ASC  , Gross_Margin_Key ASC  )  
	 WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  )
	 ON [PRIMARY ] ;

select distinct pcn,Report_Date  from Plex.Cost_Gross_Margin_Daily order by pcn,Report_Date 
select * from Plex.Cost_Gross_Margin_Daily order by Part_No 
select * from Plex.Cost_Gross_Margin_Daily_View  order by pcn,Report_Date 
select * from Plex.Cost_Gross_Margin_Get

select * from Plex.Cost_Gross_Margin_View
where valid != 0

-- drop view Plex.Cost_Gross_Margin_View
create view Plex.Cost_Gross_Margin_View
as
	select 
		PCN,
		Plexus_Customer_Code,
		DATEADD(dd, 0, DATEDIFF(dd, 0, report_date)) report_date,
		Customer_Code,
		Salesperson,
		Order_No,
		PO_No,
		Part_No,
		Product_Type,
		Part_Description,
		Sales_Qty,
		Sales_Unit,
		Quantity,
		Quantity_Unit,
		Unit_Price,
		Revenue,
		Invoice_No,
		Part_Type,
		Part_Group,
		PO_Type,
		Net_Weight,
		Total,
		Customer_Abbreviated_Name,
		Customer_Currency_Code,
		Gross_Margin_Key,
		Customer_Category,
		Customer_Type,
		Part_Source,
		Production_Qty,
		case 
		when part_revision is null then ''
		else part_revision 
		end revision,
		Customer_Part_No,
		Customer_Part_Revision,
		Sequence_No,
		Master_No,
		Cost_Model_Key,
		case 
		when Part_No = '' then 11
		when PO_No = '' then 13
		when Unit_Price is null then 14
		when Sales_Qty <= 0 then 15 
		else 0
		end valid
		select *
		--select count(*)
		from Plex.Cost_Gross_Margin_Daily 
		where Sales_Qty 		
-- drop view Plex.Cost_Gross_Margin_Daily_View
--select * from Plex.Cost_Gross_Margin_Daily_View
create view Plex.Cost_Gross_Margin_Daily_View
as
with all_po
as 
(
	select gm.*
	--select count(*)
	from Plex.Cost_Gross_Margin_View gm 
),
--select * from all_po 
--where valid !=0
part_aggregate  
as 
( 
	select ap.pcn,ap.Plexus_Customer_Code,ap.report_date,ap.Part_No,ap.revision,
	sum(ap.sales_qty) shipped,
	sum(ap.sales_qty*ap.unit_price) total_sales,  -- see validation tab of daily_metrics validation spreadsheet.
	sum(ap.sales_qty*ap.unit_price) --total_sales,  -- see validation tab of daily_metrics validation spreadsheet.
	/
	sum(ap.sales_qty) -- shipped,
	sell_price,		
	count(distinct Unit_Price) price_count,
	count(*) po_count,
	min(Unit_Price) min_price,
	max(Unit_Price) max_price,
	max(ap.valid) max_valid -- most important issue.
	from all_po ap 
	group by ap.pcn,ap.Plexus_Customer_Code,ap.report_date,ap.Part_No,ap.revision

),
--select * from part_aggregate 
price_diff 
as 
( 
	select *
	--select count(*) 
	from part_aggregate  
	where max_price - min_price > .01
),
--select * from price_diff 
--select count(*) 
--from price_diff 
po_price_diff 
as 
(
	select 
	ap.* 
	from all_po ap 
	inner join price_diff pd
	on ap.pcn = pd.pcn 
	and ap.report_date = pd.report_date 
	and ap.part_no = pd.part_no 
	and ap.revision = pd.revision 
	
),
--select * from po_price_diff 
price_list
as 
(
	select main.pcn,main.Plexus_Customer_Code,main.report_date,main.part_no,main.revision,
	left(main.price_list,len(main.price_list)-1) as price_list 
	from 
	(
	
		select distinct pd2.pcn,pd2.Plexus_Customer_Code,pd2.report_date,pd2.part_no,pd2.revision, 
			(
				select 
				case 
				when pd1.po_no = '' and pd1.unit_price is null then 'no-po/no-price;'
				when pd1.po_no = '' and pd1.unit_price is not null then 'no-po/' + cast(pd1.unit_price as varchar) + ';'
				when pd1.po_no != '' and pd1.unit_price is null then pd1.po_no + '/no-price;'
				else pd1.po_no + '/' + cast(pd1.unit_price as varchar) + ';'
				end as [text()]
				from po_price_diff pd1 
				where pd1.pcn = pd2.pcn 
				and pd1.report_date = pd2.report_date 
				and pd1.part_no = pd2.part_no 
				and pd1.revision = pd2.revision 
				order by pd1.pcn,pd1.report_date,pd1.part_no,pd1.revision 
				for xml path (''), type 
			).value('text()[1]','varchar(max)') [price_list]
		from po_price_diff pd2 
	) [main]	
)
--select * from price_list 
select pa.pcn,pa.plexus_customer_code,pa.report_date,pa.part_no,pa.revision,
shipped,
sell_price,
total_sales, 
case 
when pl.price_list is null then ''
else pl.price_list 
end price_list,
pa.max_valid valid_13916
from part_aggregate pa  
left outer join price_list pl 
on pa.pcn = pl.pcn 
and pa.report_date = pl.report_date 
and pa.part_no = pl.part_no 
and pa.revision = pl.revision 


select * from Plex.Cost_Gross_Margin_Daily_View gm
order by valid_13916 desc 
order by gm.pcn,gm.report_date,gm.part_no,gm.revision 

--	where Sales_Qty  < 0
	where Unit_Price is null -- 74
--	where Part_No != '' -- 67 in 2 weeks we have data 
	where Part_No = ''  -- 71 
--	where Part_No is null  -- 0 
--	and Unit_Price is not null 
	--where Part_No = '' -- 67 in 2 weeks we have data 
	
	select * 
	--select count(*)
	from Plex.Cost_Gross_Margin_Daily_View
	order by PO_No desc 
	order by PO_No 
	where PO_No = '5500058760'  -- 20
	and Part_No = ''  -- 

