--Nov 1 2021
--dddnnnnddddnnn

-- populate table with 1 1000 numbers
declare @TNumbers table (Number int)
insert into @TNumbers (Number)
select top (10000) row_number() over (order by s1.[object_id])
from sys.all_objects as s1 cross join sys.all_objects as s2 
option (maxdop 1);

--select * from @TNumbers

declare @VarStartDate date = '2021-11-1';
declare @VarEndDate date = '2023-01-09';
declare @VarShiftLength int = 14;

declare @VarA1 date = '2021-11-1';
declare @VarA2 date = '2021-11-2';
declare @VarA3 date = '2021-11-3';
declare @VarC1 date = '2021-11-4';
declare @VarC2 date = '2021-11-5';
declare @VarC3 date = '2021-11-6';
declare @VarC4 date = '2021-11-7';
declare @VarA4 date = '2021-11-8';
declare @VarA5 date = '2021-11-9';
declare @VarA6 date = '2021-11-10';
declare @VarA7 date = '2021-11-11';
declare @VarC5 date = '2021-11-12';
declare @VarC6 date = '2021-11-13';
declare @VarC7 date = '2021-11-14';

declare @TDates table (two_week_period int, A1 date,A2 date,A3 date,C1 date,C2 date,C3 date,C4 date,A4 date,A5 date,A6 date,A7 date,C5 date,C6 date,C7 date)
insert into @TDates

select 
n.number as two_week_period 
,dateadd(day,(n.number-1) * @VarShiftLength,@VarA1) as A1
,dateadd(day,(n.number-1) * @VarShiftLength,@VarA2) as A2
,dateadd(day,(n.number-1) * @VarShiftLength,@VarA3) as A3
,dateadd(day,(n.number-1) * @VarShiftLength,@VarC1) as C1
,dateadd(day,(n.number-1) * @VarShiftLength,@VarC2) as C2
,dateadd(day,(n.number-1) * @VarShiftLength,@VarC3) as C3
,dateadd(day,(n.number-1) * @VarShiftLength,@VarC4) as C4
,dateadd(day,(n.number-1) * @VarShiftLength,@VarA4) as A4
,dateadd(day,(n.number-1) * @VarShiftLength,@VarA5) as A5
,dateadd(day,(n.number-1) * @VarShiftLength,@VarA6) as A6
,dateadd(day,(n.number-1) * @VarShiftLength,@VarA7) as A7
,dateadd(day,(n.number-1) * @VarShiftLength,@VarC5) as C5
,dateadd(day,(n.number-1) * @VarShiftLength,@VarC6) as C6
,dateadd(day,(n.number-1) * @VarShiftLength,@VarC7) as C7
from
@TNumbers as n
where 
DATEADD(day,n.number*@VarShiftLength-1,@VarStartDate) < @VarEndDate
--where n.number < 32
order by two_week_period

--select DATEADD(day,two_week_period*@VarShiftLength-1,@VarStartDate) , * from @Tdates
declare @TAShift table (ADate date)
insert into @TAShift (ADate)
select A1 from @TDates
union
select A2 from @TDates
union
select A3 from @TDates
union
select A4 from @TDates
union
select A5 from @TDates
union
select A6 from @TDates
union
select A7 from @TDates

/*
select ADate 
from @TAShift
order by ADate
*/

--select * from @Tdates
declare @TCShift table (CDate date)
insert into @TCShift (CDate)
select C1 from @TDates
union
select C2 from @TDates
union
select C3 from @TDates
union
select C4 from @TDates
union
select C5 from @TDates
union
select C6 from @TDates
union
select C7 from @TDates

/*
select CDate 
from @TCShift
order by CDate
*/

--select * from @Tdates
declare @TheShift table (TheDate date,AShift tinyint)
insert into @TheShift (TheDate,AShift)
select ADate,1 
from @TAShift

insert into @TheShift (TheDate,AShift)
select CDate,0 
from @TCShift


insert into Report.Shift2022
select TheDate,AShift 
from
@TheShift
--order by TheDate

select * 
from Report.Shift2022 
order by TheDate

-- truncate table Report.Shift2022
Create table Report.Shift2022
( 
	TheDate date,
	AShift tinyint
)






