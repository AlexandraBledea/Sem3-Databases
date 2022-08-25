USE LibraryManagement;
SET NOCOUNT ON;

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

/* 
Delete data from a table
*/

GO
CREATE OR ALTER PROC deleteData
@table_id INT
AS
BEGIN
	-- we get the table name
	DECLARE @table_name NVARCHAR(50) = (
		SELECT [Name] FROM [Tables] WHERE TableID = @table_id
	)

	-- we declare the function we are about to execute
	DECLARE @function NVARCHAR(MAX)
	-- we set the function
	SET @function = N'DELETE FROM ' + @table_name
	PRINT @function
	-- we execute the function
	EXEC sp_executesql @function
END
GO

/*
Delete data from all tables
*/


CREATE OR ALTER PROC deleteDataFromAllTables
@test_id INT
AS
BEGIN
	DECLARE @tableID INT
	DECLARE cursorForDelete cursor local for
		SELECT TT.TableID
		FROM TestTables TT
			INNER JOIN Tests T ON TT.TestID = T.TestID
		WHERE T.TestID = @test_id
		ORDER BY TT.Position DESC

	OPEN cursorForDelete
	FETCH cursorforDelete INTO @tableID
	WHILE @@FETCH_STATUS = 0
	BEGIN
		exec deleteData @tableID

		FETCH NEXT FROM cursorForDelete INTO @tableID
	END
	CLOSE cursorForDelete
END
GO


/*
	Insert data in Person Table
*/
CREATE OR ALTER PROC insertDataIntoPerson
@nrOfRows INT,
@tableName VARCHAR(50)
AS
BEGIN
	DECLARE @newPersonCNP INT
	DECLARE @Age integer
	DECLARE @Name VARCHAR(30)
	SET @newPersonCNP = (SELECT MAX(CNP)+1 FROM Person)
	if @newPersonCNP is NULL
		SET @newPersonCNP = 1
	WHILE @nrOfRows > 0
	BEGIN
		SET @Name = (SELECT CHOOSE( CAST(RAND()*(10)+1 AS INT),'Djokovic','Tsitsipas','Thiem','Fognini', 'Medvevev','Kyrgios','Murray','Bautista-Agut','Nadal','Federer'))
		WHILE @Name is NULL
		BEGIN
			SET @Name = (SELECT CHOOSE( CAST(RAND()*(10)+1 AS INT),'Djokovic','Tsitsipas','Thiem','Fognini', 'Medvevev','Kyrgios','Murray','Bautista-Agut','Nadal','Federer'))
		END
		SET @Age = [dbo].[RandIntBetween](1, 100, RAND())
	INSERT INTO Person(CNP, Age, Name) VALUES (@newPersonCNP, @Age, @Name)
	SET @nrOfRows = @nrOfRows - 1
	SET @newPersonCNP = @newPersonCNP + 1
	END
END
GO

/*
	Insert data in Critic Table
*/

CREATE OR ALTER PROC insertDataIntoCritic
@nrOfRows INT,
@tableName VARCHAR(50)
AS
BEGIN
	DECLARE @CNP INT
	DECLARE @newCriticID INT
	DECLARE @nrOfAgeWorking INT
	SET @newCriticID = (SELECT MAX(CNP) + 1 FROM Critic)
	if @newCriticID is NULL
		SET @newCriticID = 1
	WHILE @nrOfRows > 0
	BEGIN
		SET @CNP = (SELECT TOP 1 P.CNP
						FROM Person P TABLESAMPLE (1000 ROWS)
							ORDER BY NEWID())
		WHILE @CNP is NULL
		BEGIN
			SET @CNP = (SELECT TOP 1 P.CNP
				FROM Person P TABLESAMPLE (1000 ROWS)
					ORDER BY NEWID())
		END
		SET @nrOfAgeWorking = [dbo].[RandIntBetween](1, 100, RAND())
		INSERT INTO Critic(ID, CNP, Nr_Of_Age_Working) VALUES(@newCriticID, @CNP, @nrOfAgeWorking)
		SET @nrOfRows = @nrOfRows - 1
		SET @newCriticID = @newCriticID + 1
	END
END
GO


CREATE OR ALTER PROC insertDataIntoLibrary
@nrOfRows INT,
@tableName VARCHAR(50)
AS
BEGIN
	DECLARE @newLibraryID INT
	DECLARE @address VARCHAR(30)
	DECLARE @nrOfBooks INT
	DECLARE @capacity INT
	SET @newLibraryID = (SELECT MAX(ID) + 1 FROM Library)
	if @newLibraryID is NULL
		SET @newLibraryID = 1
	WHILE @nrOfRows > 0
	BEGIN
		SET @address = (SELECT CHOOSE( CAST (RAND()*(10)+1 AS INT), '1 Decembrie', '32 Mihai Viteazu', '3 Caragiale', '123 Hotarului', '134 Susani', '1325 Titulescu', '123 Grigorescu', '6784 Lazu Baciu', '913 Stefan', '812 Eminescu'))
		WHILE @address is NULL
		BEGIN
			SET @address = (SELECT CHOOSE( CAST (RAND()*(10)+1 AS INT), '1 Decembrie', '32 Mihai Viteazu', '3 Caragiale', '123 Hotarului', '134 Susani', '1325 Titulescu', '123 Grigorescu', '6784 Lazu Baciu', '913 Stefan', '812 Eminescu'))
		END
		SET @nrOfBooks = [dbo].[RandIntBetween](1, 100000, RAND())
		SET @capacity = [dbo].[RandIntBetween](1, 5000, RAND())
		INSERT INTO Library(ID, Address, Nr_Of_Books, Capacity) VALUES (@newLibraryID, @address, @nrOfBooks, @capacity)
		SET @nrOfRows = @nrOfRows - 1
		SET @newLibraryID = @newLibraryID + 1
	END
END
GO

CREATE OR ALTER PROC insertDataIntoStaffMember
@nrOfRows INT,
@tableName VARCHAR(50)
AS
BEGIN
	DECLARE @newStaffMemberID INT
	DECLARE @CNP INT
	DECLARE @Tel INT
	DECLARE @LibraryID INT
	DECLARE @Salary INT
	SET @newStaffMemberID = (SELECT MAX(ID) + 1 FROM Staff_Member)
	if @newStaffMemberID is NULL
		SET @newStaffMemberID = 1
	WHILE @nrOfRows > 0
	BEGIN
		SET @CNP = (SELECT TOP 1 P.CNP
				FROM Person P TABLESAMPLE (1000 ROWS)
					ORDER BY NEWID())
		WHILE @CNP is NULL
		BEGIN
			SET @CNP = (SELECT TOP 1 P.CNP
				FROM Person P TABLESAMPLE (1000 ROWS)
					ORDER BY NEWID())
		END

		SET @LibraryID = (SELECT TOP 1 L.ID
					FROM Library L TABLESAMPLE (1000 ROWS)
						ORDER BY NEWID())
		WHILE @LibraryID is NULL
		BEGIN
			SET @LibraryID = (SELECT TOP 1 L.ID
				FROM Library L TABLESAMPLE (1000 ROWS)
					ORDER BY NEWID())
		END

		SET @Tel = [dbo].[RandIntBetween](10000, 99999, RAND())
		SET @Salary = [dbo].[RandIntBetween](1000, 3000, RAND())
		INSERT INTO Staff_Member(ID, CNP, Telephone, Library_ID, Salary) VALUES (@newStaffMemberID, @CNP, @Tel, @LibraryID, @Salary)
		SET @nrOfRows = @nrOfRows - 1
		SET @newStaffMemberID = @newStaffMemberID + 1
	END
END
GO

CREATE OR ALTER PROC insertDataIntoBook
@nrOfRows INT,
@tableName VARCHAR(50)
AS
BEGIN
	DECLARE @newIDBook INT
	DECLARE @Title VARCHAR(100)
	DECLARE @Author VARCHAR(30)
	DECLARE @Edition VARCHAR(30)
	DECLARE @Publisher VARCHAR(30)
	DECLARE @Category VARCHAR(50)
	DECLARE @Description VARCHAR(100)
	SET @newIDBook = (SELECT MAX(ID) FROM Book)
	if @newIDBook is NULL
		SET @newIDBook = 1
	WHILE @nrOfRows > 0
	BEGIN

		SET @Title = (SELECT CHOOSE( CAST (RAND()*(10)+1 AS INT), 'Harry Potter', 'Capsuni', 'Portocale', 'Anabella', 'Cristi si animalele', 'Avioane', 'Constructii', 'Motoare', 'Calendar', 'Papusi'))
		WHILE @Title is NULL
		BEGIN
			SET @Title = (SELECT CHOOSE( CAST (RAND()*(10)+1 AS INT), 'Harry Potter', 'Capsuni', 'Portocale', 'Anabella', 'Cristi si animalele', 'Avioane', 'Constructii', 'Motoare', 'Calendar', 'Papusi'))
		END
		
		SET @Author = (SELECT CHOOSE( CAST (RAND()*(10)+1 AS INT), 'Ana', 'Carina', 'Bia', 'Mia', 'Cosmina', 'Cezar', 'Cosmin', 'Andrei', 'Ema', 'Mede'))
		WHILE @Author is NULL
		BEGIN	
			SET @Author = (SELECT CHOOSE( CAST (RAND()*(10)+1 AS INT), 'Ana', 'Carina', 'Bia', 'Mia', 'Cosmina', 'Cezar', 'Cosmin', 'Andrei', 'Ema', 'Mede'))
		END

		SET @Edition = (SELECT CHOOSE( CAST (RAND()*(10)+1 AS INT), '1', '2', '3', '4', '5', '6', '7', '8', '9', '10'))
		SET @Publisher = (SELECT CHOOSE( CAST (RAND()*(5) + 1 AS INT), 'Art', 'Corint', 'Libris', 'Joe', 'Carturesti'))
		SET @Category = (SELECT CHOOSE( CAST (RAND()*(4) + 1 AS INT), 'Drama', 'Fiction', 'Fantasy', 'Horror'))
		SET @Description = (SELECT CHOOSE( CAST (RAND()*(4) + 1 AS INT), 'Dramaaaaaa sada', 'Ficti saedon', 'Fant awdaasy', 'Hor asd asdror'))
		INSERT INTO Book(ID, Title, Author, Edition, Publisher, Category, Description) VALUES (@newIDBook, @Title, @Author, @Edition, @Publisher, @Category, @Description)
		SET @nrOfRows = @nrOfRows - 1
		SET @newIDBook = @newIDBook + 1
	END
END
GO

CREATE OR ALTER PROC insertDataIntoReview
@nrOfRows INT,
@tableName VARCHAR(50)
AS
BEGIN
	DECLARE @BookID INT
	DECLARE @ID INT
	DECLARE @Ideea VARCHAR(100)
	DECLARE @Grade INT
	WHILE @nrOfRows > 0
	BEGIN
		SET @Ideea = (SELECT CHOOSE( CAST (RAND()*(5)+ 1 AS INT), 'Dramaaaaaa sada', 'Ficti saedon', 'Fant awdaasy', 'Hor asd asdror', 'agdhs sfghsa sgah gsahj'))
		SET @Grade = [dbo].[RandIntBetween](0, 10, RAND())
		SET @ID = (SELECT TOP 1 C.ID
			FROM Critic C TABLESAMPLE (1000 ROWS)
				ORDER BY NEWID())
		WHILE @ID is NULL
		BEGIN
		SET @ID = (SELECT TOP 1 C.ID
			FROM Critic C TABLESAMPLE (1000 ROWS)
				ORDER BY NEWID())
		END

		SET @BookID = (SELECT TOP 1 B.ID
					FROM Book B TABLESAMPLE (1000 ROWS)
						ORDER BY NEWID())
		WHILE @BookID is NULL
		BEGIN
			SET @BookID = (SELECT TOP 1 L.ID
				FROM Library L TABLESAMPLE (1000 ROWS)
					ORDER BY NEWID())
		END
		BEGIN TRY
		INSERT INTO Review(Book_ID, CriticID, Ideea, Grade) VALUES(@BookID, @ID, @Ideea, @Grade)
		END TRY
		BEGIN CATCH
		END CATCH
		SET @nrOfRows = @nrOfRows - 1
	END
END
GO


/*
Insert data in a specific table
*/

CREATE OR ALTER PROC insertData
@testRunID INT,
@testID INT,
@tableID INT
AS
BEGIN
	--starting time before test runs
	DECLARE @startTime DATETIME = SYSDATETIME()

	-- we get the name of the table based on the tableID
	DECLARE @tableName VARCHAR(50) = (
		SELECT [Name] FROM [Tables] WHERE TableID = @tableID
	)

	PRINT 'Insert data into table ' + @tableName

	-- we get the number of rows we have to insert based on the tableID and on the testID
	DECLARE @nrOfRows INT = (
		SELECT [NoOfRows] FROM TestTables  
			WHERE TestID = @testID AND TableID = @tableID
	)
	if @tableName = 'Person'
		EXEC insertDataIntoPerson @nrOfRows, @tableName

	else if @tableName = 'Staff_Member'
		EXEC insertDataIntoStaffMember @nrOfRows, @tableName

	else if @tableName = 'Library'
		EXEC insertDataIntoLibrary @nrOfRows, @tableName
	
	else if @tableName = 'Book'
		EXEC insertDataIntoBook @nrOfRows, @tableName
	
	else if @tableName = 'Review'
		EXEC insertDataIntoReview @nrOfRows, @tableName
	
	else if @tableName = 'Critic'
		EXEC insertDataIntoCritic @nrOfRows, @tableName
		
	-- we get the end time of the test
	DECLARE @endTime DATETIME = SYSDATETIME()

	-- we insert the performance
	INSERT INTO TestRunTables(TestRunID, TableID, StartAt, EndAt)
		VALUES (@testRunID, @tableID, @startTime, @endTime)

END
GO

/*
Insert data into all tables
*/

CREATE OR ALTER PROCEDURE insertDataIntoAllTables
@testRunID INT,
@testID INT
AS
BEGIN
	DECLARE @tableID INT
	DECLARE cursorForInsert CURSOR LOCAL FOR
		SELECT TableID
		FROM TestTables TT
			INNER JOIN Tests T on TT.TestID = T.TestID
		WHERE T.TestID = @testID
		ORDER BY TT.Position ASC
	
	OPEN cursorForInsert
	FETCH cursorForInsert INTO @tableID
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC insertData @testRunID, @testID, @tableID

		FETCH NEXT FROM cursorForInsert INTO @tableID
	END
	CLOSE cursorForInsert
END
GO

/*
	Create some views
*/

-- a view with a SELECT statement operating on one table
CREATE OR ALTER VIEW allLibraries
AS
	SELECT *
	FROM Library
GO

-- a view with a SELECT statement operating on at least 2 tables
-- Selects all Book Titles and the Authors, each Critic reviewd
CREATE OR ALTER VIEW titlesAndAuthorsWhichCriticsReviewd
AS
	SELECT C.ID, B.Title, B.Author
	FROM Critic C INNER JOIN Review R
		ON C.ID = R.CriticID INNER JOIN Book B
			ON R.Book_ID = B.ID
GO

-- a view with a SELECT statement that has a GROUP BY clause and operates on at least 2 tables
-- Gets the average salary for each library which have more than one Staff Member
CREATE OR ALTER VIEW averageSalaryForEachLibrary
AS
	SELECT L.ID, AVG(S.Salary) as AverageSalary
	FROM Library L INNER JOIN Staff_Member S
		ON L.ID = S.Library_ID
	GROUP BY L.ID
	HAVING 1 < count(S.CNP)
GO

/*
	Select data from a specific view
*/
CREATE OR ALTER PROC selectDataView
@viewID INT,
@testRunID INT
AS
BEGIN
	-- starting time before test runs
	DECLARE @startTime DATETIME = SYSDATETIME()

	DECLARE @viewName VARCHAR(100) = (
		SELECT [Name] FROM [Views]
			WHERE ViewID = @viewID
	)

	PRINT 'Selecting from view ' + @viewName

	DECLARE @query NVARCHAR(200) = N'SELECT * FROM '  + @viewName
	EXEC sp_executesql @query

	-- ending time after test
	DECLARE @endTime DATETIME = SYSDATETIME()

	INSERT INTO TestRunViews(TestRunID, ViewID, StartAt, EndAt)
		VALUES(@testRunID, @viewID, @startTime, @endTime)

END
GO

/*
	SELECT data from all views
*/
CREATE OR ALTER PROC selectDataFromAllViews
@testRunID INT,
@testID INT
AS
BEGIN
	PRINT 'Select all view for test = ' + convert(VARCHAR, @testID)

	DECLARE @viewID INT

	DECLARE cursorForViews CURSOR LOCAL FOR
		SELECT TV.ViewID FROM TestViews TV
			INNER JOIN Tests T on T.TestID = TV.TestID
		WHERE TV.TestID = @testID

	OPEN cursorForViews
	FETCH cursorForViews INTO @viewID
	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- We select the view
		EXEC selectDataView @viewID, @testRunID
		FETCH NEXT FROM cursorForViews INTO @viewID
	END
	CLOSE cursorForViews
END
GO


/*
	Run a test
*/

CREATE OR ALTER PROC runTest
@testID INT,
@description VARCHAR(5000)
AS
BEGIN
	PRINT 'Running test with id: ' + CONVERT(VARCHAR, @testID) + ' with description: ' + @description

	-- We create a test run
	INSERT INTO TestRuns([Description]) values (@description)

	-- Get the current testRunID
	DECLARE @testRunID INT = (SELECT MAX(TestRunID) FROM TestRuns)

	-- Get the starting time before the test runs
	DECLARE @startTime DATETIME = SYSDATETIME()

	/*
		Run all the inserts
	*/

	EXEC insertDataIntoAllTables @testRunID, @testID


	/*
		Run all the views
	*/

	EXEC selectDataFromAllViews @testRunID, @testID

	-- Get the ending time after the test runs
	DECLARE @endTIME DATETIME = SYSDATETIME()

	/*
		Delete all the data
	*/
	EXEC deleteDataFromAllTables @testID


	-- Now we update the start time and the end time for the entire RUN
	UPDATE [TestRuns] SET StartAt = @startTime, EndAt = @endTIME

	-- Compute the total number of seconds the test took
	DECLARE @totalTime INT = DATEDIFF(SECOND, @startTime, @endTime)

	PRINT 'Test with id = ' + CONVERT(VARCHAR, @testID) + ' took ' + CONVERT(VARCHAR, @totalTime) + ' seconds to execute !'

END
GO

/*
	Run all tests
*/

CREATE OR ALTER PROC runAllTests
AS
BEGIN
	DECLARE @testName VARCHAR(50)
	DECLARE @testID INT

	DECLARE cursorForTests CURSOR LOCAL FOR
		SELECT * FROM Tests

	OPEN cursorForTests
	FETCH cursorForTests INTO @testID, @testName
	WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT 'Running ' + @testName + ' with id: ' + CONVERT(VARCHAR, @testID)

		-- Now we run the test
		EXEC runTest @testID, ' perfect ;P'

		FETCH NEXT FROM cursorForTests INTO @testID, @testName
	END
	CLOSE cursorForTests
END
GO

INSERT INTO [Tables]([Name])
VALUES ('Library'), ('Book'), ('Person'), ('Critic'), ('Staff_Member'), ('Review')

INSERT INTO [Tests]([Name])
VALUES ('Test 1'), ('Test 2')


INSERT INTO [TestTables]([TestID], [TableID], [NoOfRows], [Position])
VALUES
	(1,1,400,1),
	(1,2,400,2),
	(1,3,300,3),
	(1,4,200,4),
	(1,5,100,5),
	(2,2,300,1),
	(2,3,800,2),
	(2,1,600,3),
	(2,5,200,4),
	(2,4,500,5),
	(2,6,600,6)

INSERT INTO [Views]([Name])
VALUES
	('allLibraries'),
	('titlesAndAuthorsWhichCriticsReviewd'),
	('averageSalaryForEachLibrary')

INSERT INTO [TestViews]([TestID], [ViewID])
VALUES
	(1,1),
	(2,1),
	(2,2),
	(2,3)
GO

EXEC runTest 2, 'something'

--EXEC runAllTests

SELECT * FROM TestRunTables
SELECT * FROM TestRuns
SELECT * FROM TestRunViews














/*
CREATE OR ALTER PROC insertData
@testRunID INT,
@testID INT,
@tableID INT
AS
BEGIN
	--starting time before test runs
	DECLARE @startTime DATETIME = SYSDATETIME()

	-- we get the name of the table based on the tableID
	DECLARE @tableName VARCHAR(50) = (
		SELECT [Name] FROM [Tables] WHERE TableID = @tableID
	)

	PRINT 'Insert data into table ' + @tableName

	-- we get the number of rows we have to insert based on the tableID and on the testID
	DECLARE @nrOfRows INT = (
		SELECT [NoOfRows] FROM TestTables  
			WHERE TestID = @testID AND TableID = @tableID
	)

	-- we execute the insertion of the data
	EXEC generateRandomData @tableName, @nrOfRows

	-- we get the end time of the test
	DECLARE @endTime DATETIME = SYSDATETIME()

	-- we insert the performance
	INSERT INTO TestRunTables(TestRunID, TableID, StartAt, EndAt)
		VALUES (@testRunID, @tableID, @startTime, @endTime)
END
GO
*/