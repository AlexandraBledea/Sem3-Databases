USE LibraryManagement
GO

IF EXISTS (SELECT [name] FROM sys.objects 
            WHERE object_id = OBJECT_ID('RandIntBetween'))
BEGIN
   DROP FUNCTION RandIntBetween;
END
GO

CREATE FUNCTION RandIntBetween(@lower INT, @upper INT, @rand FLOAT)
RETURNS INT
AS
BEGIN
  DECLARE @result INT;
  DECLARE @range INT = @upper - @lower + 1;
  SET @result = FLOOR(@rand * @range + @lower);
  RETURN @result;
END
GO

IF EXISTS (SELECT [name] FROM sys.objects 
            WHERE object_id = OBJECT_ID('PickRandomChar'))
BEGIN
   DROP FUNCTION PickRandomChar;
END
GO


CREATE FUNCTION PickRandomChar(@chars VARCHAR(MAX), @rand  FLOAT)
RETURNS CHAR(1)
AS
BEGIN
  DECLARE @result CHAR(1) = NULL; -- First we initialize the result with NULL
  DECLARE @resultIndex INT = NULL; -- We initialize the result index with NULL 
  IF @chars IS NULL -- If the chars variable is NULL, the result is set to NULL as well
    SET @result = NULL;
  ELSE IF LEN(@chars) = 0 -- If the chars variable doesn't have any character, then the result is set to NULL
    SET @result = NULL
  ELSE
  BEGIN
    SET @resultIndex = [dbo].[RandIntBetween](1, LEN(@chars), @rand); -- Else we generate a random resultIndex, which will represent the position for the caracter we are
	                                                                  -- going to extract from the chars variable
    SET @result = SUBSTRING(@chars, @resultIndex, 1); -- We set the value of the result as being a character taken from chars variable from position resultIndex
  END

  RETURN @result;
END
GO


CREATE OR ALTER PROCEDURE CreateRandomString
  @minLength INT = 1,
  @maxLength INT = 30,
  @chars VARCHAR(200) = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ',
  @randomString VARCHAR(MAX) OUTPUT
AS
BEGIN
  SET NOCOUNT ON;

  -- Get the length of our string.
  DECLARE @stringLength INT = [dbo].[RandIntBetween](@minLength, @maxLength, RAND());

  -- Set our random string to an empty string.
  SET @randomString = '';

  -- If our string is not yet the appropriate length, add another character to the string.
  WHILE LEN(@randomString) < @stringLength
  BEGIN
    SET @randomString = @randomString + [dbo].[PickRandomChar](@chars, RAND());
  END

END
GO

/*
DECLARE @randomString VARCHAR(MAX) = NULL;

EXEC CreateRandomString @randomString = @randomString OUTPUT;
SELECT @randomString AS [Random String];
GO
*/



IF EXISTS (SELECT [name] FROM sys.objects 
            WHERE object_id = OBJECT_ID('GetTableColumns'))
BEGIN
   DROP FUNCTION GetTableColumns;
END
GO

/*
  GET all the columns from a table
*/

CREATE FUNCTION GetTableColumns(@table_name VARCHAR(50))
RETURNS TABLE
AS
	RETURN SELECT INFSchema.COLUMN_NAME as 'column'
	FROM INFORMATION_SCHEMA.COLUMNS INFSchema
	WHERE INFSchema.TABLE_NAME = @table_name
GO

/*
DECLARE @table_name VARCHAR(30) = 'Borrowed';
SELECT * FROM GetColumnsTable(@table_name)
*/


/*
	Get the type of a column in a table
*/
CREATE OR ALTER PROC GetColumnType
@table_name VARCHAR(50),
@column_name VARCHAR(50),
@type VARCHAR(50) OUT
AS
BEGIN
	SET @type = (SELECT DATA_TYPE 
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE 
     TABLE_NAME = @table_name AND 
     COLUMN_NAME = @column_name)
END
GO

/*
DECLARE @table_name VARCHAR(50) = 'Finished';
DECLARE @column_name VARCHAR(50) = 'Borrowed_ID';
DECLARE @type VARCHAR(50) = NULL;
DECLARE @Result VARCHAR(50) = NULL;
exec @Result = GetColumnType @table_name, @column_name, @type = @type OUT;
print(@type)
*/


IF EXISTS (SELECT [name] FROM sys.objects 
            WHERE object_id = OBJECT_ID('CheckIfColumnIsAForeignKey'))
BEGIN
   DROP FUNCTION CheckIfColumnIsAForeignKey;
END
GO


/* 
	Check if a column from a table is a foreign key
*/
CREATE FUNCTION CheckIfColumnIsAForeignKey (@table_name VARCHAR(50), @column_name VARCHAR(50))
RETURNS BIT
AS 
BEGIN
	IF( EXISTS(
		SELECT *
		FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS RC
			JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE KCU
			ON RC.CONSTRAINT_CATALOG = KCU.CONSTRAINT_CATALOG
				AND RC.CONSTRAINT_NAME = KCU.CONSTRAINT_NAME
		WHERE KCU.TABLE_NAME = @table_name AND KCU.COLUMN_NAME = @column_name
			)
		)
		RETURN 1
	RETURN 0
END
GO

--DROP FUNCTION CheckIfColumnIsAForeignKey
/*
DECLARE @table_name VARCHAR(50) = 'Subscription';
DECLARE @column_name VARCHAR(50) = 'CNP_Sub';
DECLARE @Result VARCHAR(50) = NULL;
set @Result = [dbo].[CheckIfColumnIsAForeignKey](@table_name, @column_name);
print(@Result)
*/

/*
	GET the name of a table which is referenced by a foreign key
*/

CREATE OR ALTER PROCEDURE getForeignKeyReferencedTableName
@tableName VARCHAR(50),
@columnName VARCHAR(50),
@referencedTable VARCHAR(50) OUT,
@referencedColumn VARCHAR(50) OUT
AS
BEGIN
	DECLARE @result TABLE([table] VARCHAR(50), [column] VARCHAR(50))

	INSERT INTO @result SELECT
		OBJECT_NAME (f.referenced_object_id) referenced_table_name
		, COL_NAME (fc.referenced_object_id, fc.referenced_column_id) referenced_column_name
			FROM sys.foreign_keys as f
				INNER JOIN sys.foreign_key_columns AS fc


/* 
Generate random data which will be inserted into a specific table
*/


CREATE OR ALTER PROC generateRandomData
@tableName VARCHAR(50),
@nrOfRows INT
AS
	-- I create a temporary table for the columns names
	DECLARE @columns TABLE (name VARCHAR(50))

	-- I populate that temporary table with the column names
	INSERT INTO @columns SELECT * FROM GetColumnsTable(@tableName)

	-- We declare a cursor for iterating through every column  in the given table
	DECLARE ColumnCursos CURSOR FOR
		SELECT * FROM @columns

	-- Declare a variable for the random generated string
	DECLARE @randomString VARCHAR(MAX) = NULL;

	-- Declare a counter for the number of rows
	DECLARE @counter INT = 0

	-- Declare an auxiliary result variable for true/false
	DECLARE @result BIT = 0

	-- Declare a column name in Cursor
	DECLARE @cName VARCHAR(50)

	WHILE @counter < @nrOfRows
	BEGIN
		-- We generate a value for each column of the given table
		OPEN ColumnCursor
		FETCH ColumnCursor INTO @cName
		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC @result = CheckIfColumnIsAForeignKey @tableName, @cName

			IF (@result = 1)
				BEGIN


				END
			ELSE
				BEGIN

	
go

DECLARE @columns TABLE (name VARCHAR(50))
INSERT INTO @columns SELECT * FROM GetColumnsTable('Finished')
SELECT * FROM @columns