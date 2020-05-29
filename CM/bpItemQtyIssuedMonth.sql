--///////////////////////////////////////////////////////////////////////////////////
-- Determines item quantities issued within the last month
--///////////////////////////////////////////////////////////////////////////////////
create PROCEDURE [dbo].[bpItemQtyIssuedMonth] 
AS
BEGIN
	SET NOCOUNT ON
	Declare @startDateParam DATETIME
	Declare @endDateParam DATETIME
	set @startDateParam = DATEADD (month ,-1, GETDATE())
	set @endDateParam = GETDATE()
	IF
	OBJECT_ID('btItemQtyIssuedMonth') IS NOT NULL
		DROP TABLE btItemQtyIssuedMonth

	select * 
	into btItemQtyIssuedMonth 
	from 
	bfItemQtyIssued(@startDateParam,@endDateParam)
end;
