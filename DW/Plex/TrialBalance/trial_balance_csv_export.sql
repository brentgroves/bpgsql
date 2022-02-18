select
--f.pcn,
f.period_display,
f.category_type,
f.category_name, -- Albion has all blanks.
f.sub_category_name,
f.[no],
f.name,
f.current_debit_credit,
f.ytd_debit_credit
--'' subtotal_name -- Albion has all zeros.
--where f.[no] in ('10220-000-00000','10250-000-00000','11900-000-0000','11010-000-0000','41100-000-0000','50100-200-0000','51450-200-0000')
--from Plex.trial_balance_2020_03 f --
--from Plex.trial_balance_2020_02 f --
into Plex.trial_balance_2021_01_through_11 
from 
(
select f.period_display,f.category_type,f.category_name, f.sub_category_name,f.[no],f.name,f.current_debit_credit,f.ytd_debit_credit from Plex.trial_balance_2021_01 f
union
select f.period_display,f.category_type,f.category_name, f.sub_category_name,f.[no],f.name,f.current_debit_credit,f.ytd_debit_credit from Plex.trial_balance_2021_02 f
union
select f.period_display,f.category_type,f.category_name, f.sub_category_name,f.[no],f.name,f.current_debit_credit,f.ytd_debit_credit from Plex.trial_balance_2021_03 f
union
select f.period_display,f.category_type,f.category_name, f.sub_category_name,f.[no],f.name,f.current_debit_credit,f.ytd_debit_credit from Plex.trial_balance_2021_04 f
union
select f.period_display,f.category_type,f.category_name, f.sub_category_name,f.[no],f.name,f.current_debit_credit,f.ytd_debit_credit from Plex.trial_balance_2021_05 f
union
select f.period_display,f.category_type,f.category_name, f.sub_category_name,f.[no],f.name,f.current_debit_credit,f.ytd_debit_credit from Plex.trial_balance_2021_06 f
union
select f.period_display,f.category_type,f.category_name, f.sub_category_name,f.[no],f.name,f.current_debit_credit,f.ytd_debit_credit from Plex.trial_balance_2021_07 f
union
select f.period_display,f.category_type,f.category_name, f.sub_category_name,f.[no],f.name,f.current_debit_credit,f.ytd_debit_credit from Plex.trial_balance_2021_08 f
union
select f.period_display,f.category_type,f.category_name, f.sub_category_name,f.[no],f.name,f.current_debit_credit,f.ytd_debit_credit from Plex.trial_balance_2021_09 f
union
select f.period_display,f.category_type,f.category_name, f.sub_category_name,f.[no],f.name,f.current_debit_credit,f.ytd_debit_credit from Plex.trial_balance_2021_10 f
union
select f.period_display,f.category_type,f.category_name, f.sub_category_name,f.[no],f.name,f.current_debit_credit,f.ytd_debit_credit from Plex.trial_balance_2021_11 f
)f
--where f.[no] in ('10220-000-00000','10250-000-00000','11900-000-0000','11010-000-0000','41100-000-0000','50100-200-0000','51450-200-0000')
order by period_display,[no]

select *
--select count(*) 
from Plex.trial_balance_2021_01_through_11 -- 47982
order by period_display,[no]

