select
--f.pcn,
f.period,
f.category_type,
f.category_name, -- Albion has all blanks.
f.sub_category_name,
f.[no],
f.name,
f.current_debit_credit,
f.ytd_debit_credit
--'' subtotal_name -- Albion has all zeros.
from Plex.trial_balance_2020_01 f