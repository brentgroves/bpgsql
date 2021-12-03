/*
	PCN
	310507/Avilla
	300758/Albion
	295933/Franklin
	300757/Alabama
	306766/Edon
	312055/ BPG WorkHolding
	1	123681 / Southfield
2	295932 FruitPort
3	295933
4	300757
5	300758
6	306766
7	310507
8	312055
	*/
/*
create PCN table from param
*/
create table #list
(
 tuple int
)
declare @delimiter varchar(1)
set @delimiter = ','
declare @in_string varchar(max)
set @in_string = @PCNList
WHILE LEN(@in_string) > 0
BEGIN
    INSERT INTO #list
    SELECT cast(left(@in_string, charindex(@delimiter, @in_string+',') -1) as int) as tuple

    SET @in_string = stuff(@in_string, 1, charindex(@delimiter, @in_string + @delimiter), '')
end;
--select tuple from #list


SELECT
plexus_customer_no,period,fiscal_order,begin_date,end_date,period_display,quarter_group
FROM accounting_v_Period_e AS P
where p.plexus_customer_no in
(
 select tuple from #list
)

