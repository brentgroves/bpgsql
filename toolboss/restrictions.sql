select * from [ToolList Users]

select * 
from [ToolList Plant] tp
inner join [ToolList Master] tm 
on tp.processid=tm.processid
where plant = 8
and tm.partfamily
like '%Diff%'

select * from [ToolList Master] tm
where tm.partfamily
like '%Diff%'


SELECT     tm.partfamily, Job, Machine, D_Consumer, item, D_Item, plant
FROM         dbo.bfToolBossItemsInPlant(11) AS p
inner join
[ToolList Master] tm
on p.job=tm.originalprocessid
where tm.customer like '%JOHN DEERE%'
