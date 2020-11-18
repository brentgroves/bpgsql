-- drop table Part_v_Container_Piece
Create table Part_v_Container_Piece
(
	Container_Piece_Key bigint NOT NULL IDENTITY(1,1) PRIMARY KEY,
	Workcenter_Code varchar(50) NOT NULL,
	Job_No	varchar (20) NOT NULL,
	Part_No	varchar (100) NOT NULL,
	Piece_Serial_No  varchar(50) NOT NULL UNIQUE, -- The piece serial being used currently is a 19 character number.  
	-- Gave a length of 50 to allow for future change and/or variation.  Please note, when sent to Plex this is the container serial number (suspect parts)
	Piece_Status varchar(20) NOT NULL, -- This is the Container_Status
	Reject_Code varchar(60) NOT NULL,  -- The reject code is being added to the Container_Note when applicable (suspect parts)
	Container_No varchar(50) NOT NULL, -- This is the Recorded_Serial_No returned from Plex. Container.Serial_No	varchar (25)
	Plex_Instance_No varchar(50) NOT NULL, -- BELOW
	-- the data source returns the web instance number (PlexInstanceNo). 
	-- Think this is in the Web_Services.Instance table but not sure which column.
	Quantity int NOT NULL,  -- Not sure of this. I think this is always going to be 1.
	Record_Date datetime NOT NULL,  -- Passed as param.
)

/*
Stored procedure needed to record Grob Line pieces, please note the piece serial number will be provided as a comma separated CSV string.  
The quantity will be for the number of serial numbers in the CSV string.  
Each serial should be recorded as an individual record with a quantity of one and include the workcenter, job number, part number, etc. parameters. 
*/

DECLARE @ReturnCode INT

-- Execute the stored procedure and specify which variables
-- are to receive the output parameter and return code values.
EXEC @ReturnCode = InsertContainerPiece
	@Workcenter_Code = 'Workcenter_Code',
   	@Job_No  = 'Job_No',
	@Part_No = 'Part_No',
   	@Piece_Serial_No = '5,6,7,8',
	@Piece_Status = 'Piece_Status',
	@Reject_Code ='Reject_Code', 
	@Container_No ='Container_No',
	@Plex_Instance_No ='Plex_Instance_No',
	@Quantity = 4,
	@Record_Date = '2020-01-16 12:32:00'
   	
	-- truncate table Kors.dbo.Part_v_Container_Piece
select * from Kors.dbo.Part_v_Container_Piece
-- drop procedure InsertContainerPiece;
CREATE PROCEDURE InsertContainerPiece
	@Workcenter_Code varchar(50),
	@Job_No varchar(20),
	@Part_No varchar(100),
	@Piece_Serial_No varchar(50),
	@Piece_Status varchar(20),
	@Reject_Code varchar(60), 
	@Container_No varchar(50),
	@Plex_Instance_No varchar(50),
	@Quantity int,
	@Record_Date datetime
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
   -- Table variable   
	DECLARE @MyTableVar table( Container_Piece_Key int, Piece_Serial_No varchar(25));

   INSERT INTO Kors.dbo.Part_v_Container_Piece
	OUTPUT INSERTED.Container_Piece_Key,INSERTED.Piece_Serial_No
	into @MyTableVar
   Select 
   Workcenter_Code,Job_No,Part_No,items as Piece_Serial_No,Piece_Status,Reject_Code,Container_No,Plex_Instance_No,Quantity,Record_Date 
   From dbo.Split(@Piece_Serial_No,',') 
   cross join (
   	select @Workcenter_Code Workcenter_Code, @Job_No Job_No,
   	@Part_No Part_No,@Piece_Status Piece_Status,@Reject_Code Reject_Code,@Container_No Container_No,
   	@Plex_Instance_No Plex_Instance_No,1 Quantity,@Record_Date Record_Date 
   	-- ,@Job_No,@Part_No,@Piece_Serial_No,@Reject_Code,@Container_No,@Plex_Instance_No,1,@Record_Date
   )s  

   --Display the result set of the table variable.
	SELECT Container_Piece_Key,Piece_Serial_No FROM @MyTableVar;


End;
-- Table variable   
DECLARE @MyTableVar table( Container_Piece_Key int, Piece_Serial_No varchar(25));

INSERT INTO Kors.dbo.Part_v_Container_Piece
(Workcenter_Code,Job_No,Part_No,Piece_Serial_No,Piece_Status,Reject_Code,Container_No,Plex_Instance_No,Quantity,Record_Date)
OUTPUT INSERTED.Container_Piece_Key,INSERTED.Piece_Serial_No
into @MyTableVar
VALUES(@Workcenter_Code,@Job_No,@Part_No,@Piece_Serial_No,@Piece_Status,@Reject_Code,@Container_No,@Plex_Instance_No,1,@Record_Date);
-- VALUES(@Workcenter_Code,@Job_No,@Part_No,@Ind_Piece_Serial_No,@Reject_Code,@Container_No,@Plex_Instance_No,1,@Record_Date);

--Display the result set of the table variable.
SELECT Container_Piece_Key,Piece_Serial_No FROM @MyTableVar;
--Display the result set of the table.
select * from Part_v_Container_Piece;

END;


/*
Stored procedure needed to query the local database if a piece has been previously recorded 
*/
DECLARE @ReturnCode INT
DECLARE @Piece_Serial_No varchar(50)
DECLARE @Record_Found varchar(5)
DECLARE @Workcenter_Code varchar(50)
DECLARE @Job_No varchar(20)
DECLARE @Part_No varchar(100)
DECLARE @Piece_Status varchar(20)
DECLARE @Reject_Code varchar(60) 
DECLARE @Container_No varchar(50)
DECLARE @Plex_Instance_No varchar(50)
DECLARE @Quantity int
DECLARE @Record_Date datetime


--	select * FROM Part_v_Container_Piece
--	WHERE Piece_Serial_No = '1,2,3,4'
-- Execute the stored procedure and specify which variables
-- are to receive the output parameter and return code values.
EXEC @ReturnCode = GetContainerPiece 
   	@Piece_Serial_No = '1,2,3,4',
   	@Record_Found = @Record_Found OUTPUT,
	@Workcenter_Code = @Workcenter_Code OUTPUT,
   	@Job_No = @Job_No OUTPUT,
	@Part_No = @Part_No OUTPUT,
	@Piece_Status = @Piece_Status OUTPUT,
	@Reject_Code = @Reject_Code OUTPUT, 
	@Container_No = @Container_No OUTPUT,
	@Plex_Instance_No = @Plex_Instance_No OUTPUT,
	@Quantity = @Quantity OUTPUT,
	@Record_Date = @Record_Date OUTPUT
select @ReturnCode,@Record_Found,
@Workcenter_Code,
@Job_No,
@Part_No,
@Piece_Serial_No,
@Piece_Status,
@Reject_Code,
@Container_No,
@Plex_Instance_No,
@Quantity,
@Record_Date

-- Show the values returned.
PRINT ' '
PRINT 'Return code = ' + CAST(@ReturnCode AS CHAR(10))
PRINT 'Maximum Quantity = ' + CAST(@MaxTotalVariable AS CHAR(10))

-- Create a procedure that takes one input parameter and returns one output parameter and a return code.
-- drop PROCEDURE GetContainerPiece 
CREATE PROCEDURE GetContainerPiece 
	@Piece_Serial_No varchar(50),
    @Record_Found varchar(5) OUTPUT,
	@Workcenter_Code varchar(50) OUTPUT,
	@Job_No varchar(20) OUTPUT,
	@Part_No varchar(100) OUTPUT,
	@Piece_Status varchar(20) OUTPUT,
	@Reject_Code varchar(60) OUTPUT, 
	@Container_No varchar(50) OUTPUT,
	@Plex_Instance_No varchar(50) OUTPUT,
	@Quantity int OUTPUT,
	@Record_Date datetime  OUTPUT
AS
BEGIN 
	-- Declare and initialize a variable to hold @@ERROR.
	DECLARE @ErrorSave INT
	SET @ErrorSave = 0
	
	-- Do a SELECT using the input parameter.
	SELECT @Workcenter_Code = Workcenter_Code,
	@Job_No=Job_No,
	@Part_No=Part_No,
	@Piece_Serial_No=Piece_Serial_No,
	@Piece_Status=Piece_Status,
	@Reject_Code=Reject_Code,
	@Container_No=Container_No,
	@Plex_Instance_No=Plex_Instance_No,
	@Quantity=Quantity,
	@Record_Date=Record_Date
	FROM Part_v_Container_Piece
	WHERE Piece_Serial_No = @Piece_Serial_No
	
	-- Save any nonzero @@ERROR value.
	IF (@@ERROR <> 0)
	   SET @ErrorSave = @@ERROR

	IF @Workcenter_Code is NULL   	
	   SET @Record_Found = 'false'
	ELSE 
	   SET @Record_Found = 'true'
		
	-- Returns 0 if neither SELECT statement had an error; otherwise, returns the last error.
	RETURN @ErrorSave
END;

