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
