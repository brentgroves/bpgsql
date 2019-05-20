--[ { Value: '60910', Name: 'Workcenter_Key' },
--  { Value: 'BE 549', Name: 'Workcenter_Code' },
--  { Value: '18190-RNO-A012-S10 Rev02', Name: 'Part_No' },
--drop table btProductionStatusSummary
--Part.dbo.Workcenter
create table btProductionStatusSummary
(
	Workcenter_Key int,
	Workcenter_Code varchar(50),
	Part_No varchar (100)
);
  
select Workcenter_Key + 1 as isNumber from btProductionStatusSummary
