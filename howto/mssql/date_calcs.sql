	declare @prev_day_midnight datetime;
	set @prev_day_midnight = DATEADD(dd, DATEDIFF(dd, 0, GETDATE()) - 1, 0);
	select @prev_day_midnight; 

To get the current date and time:

SELECT getdate();
And we have a datetime value: 2018-09-01 11:50:05.627

From the datetime value above, you want to extract the date value only and hide the time value. There are several ways to do that:

1. Use CONVERT to VARCHAR:

CONVERT syntax:

CONVERT ( data_type [ ( length ) ] , expression [ , style ] )  
In this case, date only, you we are gonna run this query:
declare @prev_day_midnight datatime;
set @prev_day_midnight = cast(CONVERT(VARCHAR(10), getdate(), 111) as datetime);
select cast(CONVERT(VARCHAR(10), getdate(), 111) as datetime);

SELECT CONVERT(VARCHAR(10), getdate(), 111);
Style	How it’s displayed
101	mm/dd/yyyy
102	yyyy.mm.dd
103	dd/mm/yyyy
104	dd.mm.yyyy
105	dd-mm-yyyy
110	mm-dd-yyyy
111	yyyy/mm/dd
106	dd mon yyyy
107	Mon dd, yyyy

AB15406(L)	AB755678/01-13-2021/Open/qty:48, AB755765/01-13-2021/Open/qty:48, 
AB755767/01-13-2021/Open/qty:48, AB755850/01-13-2021/Open/qty:48, AB755856/01-13-2021/Open/qty:48, 
AB755874/01-13-2021/Open/qty:48, AB755908/01-13-2021/Open/qty:48, AB755973/01-13-2021/Open/qty:48, 
AB755979/01-13-2021/Open/qty:48, AB756147/01-13-2021/Open/qty:48, 

AB754838/01-12-2021/Shipped/qty:48, 

AB754860/01-12-2021/Shipped/qty:48, AB755216/01-12-2021/Shipped/qty:48, AB755397/01-12-2021/Shipped/qty:48, 
AB755415/01-12-2021/Shipped/qty:48, AB755499/01-12-2021/Shipped/qty:48, AB755509/01-12-2021/Shipped/qty:48, 
AB755576/01-12-2021/Shipped/qty:48, AB755596/01-12-2021/Shipped/qty:48, AB755667/01-12-2021/Shipped/qty:48, 
AB754047/01-12-2021/Shipped/qty:48, AB754272/01-12-2021/Shipped/qty:48, AB754319/01-12-2021/Shipped/qty:48, 
AB754434/01-12-2021/Shipped/qty:48, AB754465/01-12-2021/Shipped/qty:48, AB754517/01-12-2021/Shipped/qty:48, 
AB754573/01-12-2021/Shipped/qty:48, AB754590/01-12-2021/Shipped/qty:48, AB754778/01-12-2021/Shipped/qty:48, 
AB754796/01-12-2021/Shipped/qty:48, AB754915/01-11-2021/Shipped/qty:24, AB754921/01-11-2021/Shipped/qty:48, 

AB754927/01-11-2021/Shipped/qty:48, AB755277/01-11-2021/Shipped/qty:48	

Open
48 * 10 = 480 

Shipped
48 *  (7*3) + 3 = 48 * 24 = 960 + (4*48)  = 960 + 192 = 1152
1152
1128
24