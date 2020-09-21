select * from [ToolList Master] tm
left outer join [ToolList PartNumbers] pn 
on tm.processId= pn.processid
--where customer = 'FCA'
where tm.processid = '54614'

--insert into [ToolList PartNumbers] (ProcessId,PartNumbers)
values (54614,'68480625AA')


/*
select * from [ToolList Plant] 
select * from [ToolList partnumbers] 
-- where processid = 49188 
where partnumbers like '%5K651%'
select count(*) from [ToolList Master] tm  -- 1180

select * from [ToolList Master] tm  -- 1180
where partfamily like '%84821439%'

select * from [ToolList partnumbers] 
where processid = 63062


insert into [ToolList PartNumbers] (ProcessId,PartNumbers)
values (63062,'84821440')


where customer = 'Ford'
Ford:
ML3V-5793-AC, OPERATION: 60, PART FAMILY: ST-TRLR SPG
ML3V-5793-BC, OPERATION: 60, PART FAMILY: ST-TRLR SPG

ML3V-5793-CA, OPERATION: 60, PART FAMILY: ST-TRLR SPG

ML3V-5794-AC, OPERATION: 60, PART FAMILY: ST RR SPG LH

ML3V-5794-BC, OPERATION: 60, PART FAMILY: ST RR SPG LH

ML3V-5794-CA, OPERATION: 60, PART FAMILY: ST RR SPG LH

 

Multimatic:

13998-0001, OPERATION: 60, PART FAMILY: LH FLCA

13998-0002, OPERATION: 60, PART FAMILY: RH FLCA

 

General Motors:

84821437, OPERATION: 60, PART FAMILY: LH BT1xx Front Knuckle

84821438, OPERATION: 60, PART FAMILY: RH BT1xx Front Knuckle

84821439, OPERATION: 60, PART FAMILY: LH BT1xx Rear Knuckle

84821440, OPERATION: 60, PART FAMILY: RH BT1xx Rear Knuckle

 
*/