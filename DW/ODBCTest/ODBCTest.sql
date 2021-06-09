WITH RESULT SETS ((
    [high] tinyint NULL,
    [low] tinyint NULL,
    [number] smallint NULL,
    [timestamp] datetime2(0) NULL,
    [newid] uniqueidentifier NULL));

WITH RESULT SETS ((
    [number] smallint NULL,
    [high] tinyint NULL,
    [low] tinyint NULL));
   
       SELECT  CAST(number AS SMALLINT) AS number,
            CAST(high - 1 AS TINYINT) AS high,
            CAST(low - 1 AS TINYINT) AS low

IF OBJECT_ID(N'dbo.SomeDummyTable', N'U') IS NOT NULL
    DROP TABLE dbo.SomeDummyTable;
GO
IF OBJECT_ID(N'dbo.ProcedureWithDML', N'P') IS NOT NULL
    DROP PROCEDURE dbo.ProcedureWithDML;
IF OBJECT_ID(N'dbo.ProcedureDynamicSql', N'P') IS NOT NULL
    DROP PROCEDURE dbo.ProcedureDynamicSql;
GO
IF OBJECT_ID(N'dbo.ProcedureTempTable', N'P') IS NOT NULL
    DROP PROCEDURE dbo.ProcedureTempTable;
GO
IF OBJECT_ID(N'dbo.ProcedureMultipleResultSets', N'P') IS NOT NULL
    DROP PROCEDURE dbo.ProcedureMultipleResultSets;
GO
 select *   FROM    master.dbo.spt_values

Select * from
sys.dm_exec_describe_first_result_set_for_object
(object_id('[dbo].[ProcedureWithDM]'),0) 
 
CREATE TABLE dbo.SomeDummyTable( dummy INTEGER );
GO
dbo.ProcedureWithDML 0,10;
CREATE PROCEDURE dbo.ProcedureWithDML
    @StartIndex AS INTEGER,
    @BatchSize  AS SMALLINT
AS
BEGIN
    --SET NOCOUNT ON;    Commented deliberately to produce errors
    DELETE  dbo.SomeDummyTable
    WHERE   1 = 0;
    SELECT  CAST(number AS SMALLINT) AS number,
            CAST(high - 1 AS TINYINT) AS high,
            CAST(low - 1 AS TINYINT) AS low
    FROM    master.dbo.spt_values
    WHERE   [type] = 'P'
            AND number >= @StartIndex
            AND number < @StartIndex + @BatchSize;
END;
GO
CREATE PROCEDURE dbo.ProcedureDynamicSql
    @StartIndex AS INTEGER,
    @BatchSize  AS SMALLINT
AS
BEGIN
    --SET NOCOUNT ON;    Commented deliberately to produce errors
    DECLARE @SqlCmmd AS NVARCHAR(MAX) = N'
    SELECT  CAST(number AS SMALLINT) AS number,
            CAST(high - 1 AS TINYINT) AS high,
            CAST(low - 1 AS TINYINT) AS low
    FROM    master.dbo.spt_values
    WHERE   [type] = ''P''
            AND number >= @StartIndex
            AND number < @StartIndex + @BatchSize;';
    DECLARE @Params AS NVARCHAR(500) = N'@StartIndex AS INTEGER, @BatchSize AS SMALLINT';
    EXECUTE sp_executesql
        @statement     = @SqlCmmd,
        @params        = @Params,
        @StartIndex    = @StartIndex,
        @BatchSize     = @BatchSize;
END;
GO
dbo.ProcedureNoParamTempTable4
drop procedure ProcedureNoParamTempTable4
CREATE PROCEDURE dbo.ProcedureNoParamTempTable4
AS
BEGIN
    SELECT  CAST(number AS SMALLINT) AS number,
            CAST(high - 1 AS TINYINT) AS high,
            CAST(low - 1 AS TINYINT) AS low
--    INTO    #Result4
    FROM    master.dbo.spt_values
    WHERE   [type] = 'P'
            AND number >= 0
            AND number < 10;
 --   SELECT  *
 --   FROM    #Result4 rs4;
END;

CREATE PROCEDURE dbo.ProcedureNoParamTempTable5
AS
BEGIN
    SELECT  CAST(number AS SMALLINT) AS number,
            CAST(high - 1 AS TINYINT) AS high,
            CAST(low - 1 AS TINYINT) AS low
--    INTO    #Result4
    FROM    master.dbo.spt_values
    WHERE   [type] = 'P'
            AND number >= 0
            AND number < 10;
 --   SELECT  *
 --   FROM    #Result4 rs4;
END;


CREATE PROCEDURE dbo.ProcedureTempTable
    @StartIndex AS INTEGER,
    @BatchSize  AS SMALLINT
AS
BEGIN
    SELECT  CAST(number AS SMALLINT) AS number,
            CAST(high - 1 AS TINYINT) AS high,
            CAST(low - 1 AS TINYINT) AS low
    INTO    #Result
    FROM    master.dbo.spt_values
    WHERE   [type] = 'P'
            AND number >= @StartIndex
            AND number < @StartIndex + @BatchSize;
    SELECT  *
    FROM    #Result;
END;

WITH RESULT SETS ((
    [high] tinyint NULL,
    [low] tinyint NULL,
    [number] smallint NULL,
    [timestamp] datetime2(0) NULL,
    [newid] uniqueidentifier NULL));
GO
/*
    DELETE  dbo.SomeDummyTable
    WHERE   1 = 0;
    SELECT  CAST(number AS SMALLINT) AS number,
            CAST(high - 1 AS TINYINT) AS high,
            CAST(low - 1 AS TINYINT) AS low
    FROM    master.dbo.spt_values
    WHERE   [type] = 'P'
            AND number >= @StartIndex
            AND number < @StartIndex + @BatchSize;

 */

CREATE PROCEDURE dbo.ProcedureMultipleResultSets
    @StartIndex AS INTEGER,
    @BatchSize  AS SMALLINT,
    @Type       AS TINYINT = 0
AS
BEGIN
    IF @Type = 0
    BEGIN
        SELECT  CAST(number AS SMALLINT) AS number,
                CAST(high - 1 AS TINYINT) AS high,
                CAST(low - 1 AS TINYINT) AS low
        FROM    master.dbo.spt_values
        WHERE   [type] = 'P'
                AND number >= @StartIndex
                AND number < @StartIndex + @BatchSize;
    END
    ELSE
    BEGIN
        --New columns and different order.
        SELECT  CAST(high - 1 AS TINYINT) AS high,
                CAST(low - 1 AS TINYINT) AS low,    --> Just for fun change to SMALLINT and see what happens
                CAST(number AS SMALLINT) AS number,
                CAST(SYSUTCDATETIME() AS DATETIME2(0)) AS [timestamp],
                NEWID() AS [newid]
        FROM    master.dbo.spt_values
        WHERE   [type] = 'P'
                AND number >= @StartIndex
                AND number < @StartIndex + @BatchSize;
    END;
END;
GO