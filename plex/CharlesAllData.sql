create table #results
(
  report_date datetime,
  report_shift varchar(38),
  workcenter_code varchar(38),
  part_no varchar(38),
  qty_prod numeric(10,2),
  scrap_reason varchar(50),
  qty_scrap numeric(15,2),
  plexus_customer_no INT,
  name varchar(100),
  cavity varchar(50),
  add_date datetime
   );

DECLARE @EndDate DATETIME = GETDATE()
DECLARE @StartDate DATETIME = DATEADD(MM,-6,@EndDate)

--Get Production Records when produced on workcenter type = Caster for parts with part_source_key = ???.
insert into #results (report_date, report_shift,workcenter_code,part_no,qty_prod, plexus_customer_no, name, cavity)
( 
  select
--  count(*)
    pr.report_date,
    s.shift,
    wc.workcenter_code,
    p.part_no,
    sum(pr.quantity),
    p.plexus_customer_no,
    p.name,
    pr.cavity_no
  from part_v_production as pr
  join common_v_shift as s
    on pr.report_shift = s.shift_key
  join part_v_workcenter as wc
    on pr.workcenter_key = wc.workcenter_key
    and 'Caster' = wc.workcenter_type
  join part_v_part as p
    on pr.part_key = p.part_Key
    and 373 = p.part_source_key
 --where pr.report_date between @from and @to
  group by pr.report_date,s.shift,wc.workcenter_code,p.part_no, p.plexus_customer_no, p.name, pr.cavity_no
  having pr.report_date between @StartDate and @EndDate
  );
  

--Get Scrap Records part_source_key = 
--select top 1 * from part_v_scrap 
insert into #results (report_date, report_shift, workcenter_code, part_no, scrap_reason, qty_scrap, plexus_customer_no,
name, cavity, add_date)
(
  select
    sr.report_date,
    s.shift,
    wc.workcenter_code,
    p.part_no,
    sr.scrap_reason,
    sum(sr.quantity),
    p.plexus_customer_no,
    p.name,
    sr.cavity_code,
    sr.add_date
  from part_v_scrap as sr
  join common_v_shift as s
    on sr.shift = s.shift_key
  join part_v_workcenter as wc
    on sr.workcenter_key = wc.workcenter_key
    --and 'Caster' = wc.workcenter_type
  join part_v_part as p
    on sr.part_key = p.part_key
    and 373 = p.part_source_key
 -- where sr.report_date between @from and @to

  group by sr.report_date, s.shift, wc.workcenter_code, p.part_no, sr.scrap_reason, p.plexus_customer_no, 
  p.name, sr.cavity_code, sr.add_date
  having sr.report_date between @StartDate and @EndDate
  );

--select top 10 * from part_v_part



select
  r.report_date, r.report_shift, r.workcenter_code, r.part_no, sum(r.qty_prod) as 'qty_prod', r.scrap_reason, sum(r.qty_scrap) as 'qty_scrap',
  r.plexus_customer_no, r.name, r.cavity, r.add_date
from #results as r
group by r.report_date, r.report_shift, r.workcenter_code, r.part_no, scrap_reason, r.plexus_customer_no, 
r.name, r.cavity, r.add_date
order by r.report_date desc