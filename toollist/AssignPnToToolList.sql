select * from [ToolList Master] tm
left outer join [ToolList PartNumbers] pn 
on tm.processId= pn.processid
--where customer = 'FCA'
where tm.processid = '54614'

--insert into [ToolList PartNumbers] (ProcessId,PartNumbers)
values (54614,'68480625AA')
