-- mgdw.Plex.accounting_balance definition

-- Drop table

-- DROP TABLE mgdw.Plex.accounting_balance;

CREATE TABLE mgdw.Plex.accounting_balance (
	pcn int NOT NULL,
	account_key int NOT NULL,
	account_no varchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	period int NOT NULL,
	debit decimal(19,5) NULL,
	credit decimal(19,5) NULL,
	balance decimal(19,5) NULL,
	--CONSTRAINT PK__accounti__34E7554F34C584AF PRIMARY KEY (pcn,account_key,period)
	-- etl script fails with this constraint 
	-- maybe because there is large delete command first.
);
ALTER TABLE Plex.accounting_balance
ADD CONSTRAINT PK__accounti__34E7554F34C584AF PRIMARY KEY (pcn,account_key,period);

CREATE TABLE mgdw.Archive.accounting_balance (
	pcn int NOT NULL,
	account_key int NOT NULL,
	account_no varchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	period int NOT NULL,
	debit decimal(19,5) NULL,
	credit decimal(19,5) NULL,
	balance decimal(19,5) NULL
);
select pcn,account_key,period,count(*)
from 
(
select distinct pcn,account_key,period from Archive.accounting_balance  --order by pcn,period-- 2963
) b 
group by pcn,account_key,period
having count(*) > 1
/*
 * Create a procedure to record pcn,account_no, year, category, and revenue_or_expense value.
 * What category do we use?  
 */

/*
select 
@current_period current_period,
(@current_period - 3) period_min_3,
(((@current_period/100)-1) * 100) + 12, 
(((@current_period/100)-1) * 100) + 11, 
(((@current_period/100)-1) * 100) + 10 
*/
/*
 * Max fiscal period previous year
 */

declare @prev_year_max_fiscal_period int
select @prev_year_max_fiscal_period=(max_fiscal_period%100) 
from Plex.max_fiscal_period m
where m.pcn = 123681
--and m.[year] = 2010
and m.[year] =  ((@current_period/100)-1);

--select @prev_year_max_fiscal_period
/*
 * 3 periods ago?
 */
/*
select 
case 
when ((@current_period%100) - 3) >= 1 then (@current_period - 3) 
when ((@current_period%100) - 3) = 0 then (((@current_period/100)-1) * 100) + @prev_year_max_fiscal_period
when ((@current_period%100) - 3) = -1 then (((@current_period/100)-1) * 100) + (@prev_year_max_fiscal_period-1)
when ((@current_period%100) - 3) = -2 then (((@current_period/100)-1) * 100) + (@prev_year_max_fiscal_period-2)
end start_period,
case 
when ((@current_period%100) - 2) >= 1 then (@current_period - 2) 
when ((@current_period%100) - 2) = 0 then (((@current_period/100)-1) * 100) + @prev_year_max_fiscal_period
when ((@current_period%100) - 2) = -1 then (((@current_period/100)-1) * 100) + (@prev_year_max_fiscal_period-1)
when ((@current_period%100) - 2) = -2 then (((@current_period/100)-1) * 100) + (@prev_year_max_fiscal_period-2)
end next_period,
p.*
from Plex.accounting_period p
where pcn = 123681  -- 200601 to > 204103
*/
declare @start_period int 
set @start_period = 
	case 
	when ((@current_period%100) - 3) >= 1 then (@current_period - 3) 
	when ((@current_period%100) - 3) = 0 then (((@current_period/100)-1) * 100) + @prev_year_max_fiscal_period
	when ((@current_period%100) - 3) = -1 then (((@current_period/100)-1) * 100) + (@prev_year_max_fiscal_period-1)
	when ((@current_period%100) - 3) = -2 then (((@current_period/100)-1) * 100) + (@prev_year_max_fiscal_period-2)
	end;
declare @next_period int 
set @next_period =
	case 
	when ((@current_period%100) - 2) >= 1 then (@current_period - 2) 
	when ((@current_period%100) - 2) = 0 then (((@current_period/100)-1) * 100) + @prev_year_max_fiscal_period
	when ((@current_period%100) - 2) = -1 then (((@current_period/100)-1) * 100) + (@prev_year_max_fiscal_period-1)
	when ((@current_period%100) - 2) = -2 then (((@current_period/100)-1) * 100) + (@prev_year_max_fiscal_period-2)
	end;
--select @start_period,@next_period
