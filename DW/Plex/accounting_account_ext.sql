create view Plex.accounting_account_ext
as
WITH account_balance_start (pcn,account_key,account_no,start_period)
as
(
	select pcn,account_key,account_no,min(period) start_period
	from Plex.accounting_balance b
	group by b.pcn,b.account_key,b.account_no 	
),
accounting_account(pcn,account_key,account_no,account_name,active,category_type,debit_main,first_digit_123,start_period)
as
(
	select a.*,
	case 
	when b.pcn is null then 0
	else b.start_period
	end start_period
	from Plex.accounting_account a 
	left outer join account_balance_start b 
	on a.pcn =b.pcn 
	and a.account_key = b.account_key 

)
--select count(*) from accounting_account where pcn = 123681  -- 4,362
select * from accounting_account 

select * from Plex.accounting_account_ext