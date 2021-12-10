/*
 * If the category_type is 'Revenue' or 'Expense' NO reset of YTD credit/debit values will occur in the TB report.
 */
select * from Plex.accounting_account aa 
where pcn = 123681
and category_type NOT in ('Revenue','Expense')
and left(account_no,1) > '4'  -- 0


where pcn = 123681 
and category_type in ('Revenue','Expense')
and left(account_no,1) > '4'  -- 0

/*
 * If the category_type is not 'Revenue' or 'Expense' a reset of YTD credit/debit values will occur in the TB report.
 */
select * from Plex.accounting_account aa 
where category_type not in ('Revenue','Expense')
and left(account_no,1) > '3'  -- 0 records
where account_no like '27800-000%'  -- debit balance/old debit_balance diff 27800-000-9806
and pcn = 123681