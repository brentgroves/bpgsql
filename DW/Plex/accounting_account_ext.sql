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

select * from Plex.accounting_account_ext where account_no like '27800-000%'
/*
asset/equity/expense/liability/revenue
Assets naturally have debit balances, so they should normally appear as positive numbers
Liabilities and Equity naturally have credit balances, so would normally appear as negative numbers
Revenue accounts naturally have credit balances, so normally these would be negative
Expense accounts naturally have debit balances, so normally would be positive numbers
there are exceptions in every category for a variety of reasons (of course)
*/
/*
 * The Trial Balance account is not using the account's [in] column to determine if this is an asset / liability type account.
 * see account_no 27800-000-9806 which is an asset category type account but in the Trial Balance report
 * it is shown to be a liability account by it's debit/credit values.  
 * The other 27800-000-% accounts all our liability type accounts at the account_level.
 * Maybe the Trial Balance report 
*/