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
 
from Plex.trial_balance_2021_11 f -- 
where f.[no] in ('10220-000-00000','10250-000-00000','11900-000-0000','11010-000-0000','41100-000-0000','50100-200-0000','51450-200-0000')
