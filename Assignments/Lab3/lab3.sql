USE LibraryManagement
GO


-- a. modify the type of column

CREATE OR ALTER PROC uspChangePersonAge
AS
BEGIN
	ALTER TABLE Person
	ALTER COLUMN Age VARCHAR(10)
	PRINT 'ALTER TABLE Person FROM INT TO VARCHAR'
END
GO

-- a. undo


CREATE OR ALTER PROC UNDOuspChangePersonAge
AS
BEGIN
	ALTER TABLE Person
	ALTER COLUMN Age INT
	PRINT 'ALTER TABLE Person FROM VARCHAR TO INT'
END
GO


-- b. add/remove a column

CREATE OR ALTER PROC uspRemoveLibraryCapacity
AS
BEGIN
	ALTER TABLE Library
	DROP COLUMN Capacity
	PRINT 'ALTER TABLE Library DROP COLUMN Capacity from Library'
END
GO

-- b. undo

CREATE OR ALTER PROC UNDOuspRemoveLibraryCapacity
AS
BEGIN
	ALTER TABLE Library
	ADD Capacity INT
	PRINT 'ALTER TABLE Library ADD COLUMN Capacity to Library'
END
GO

--c. add/remove a DEFAULT constraint

CREATE OR ALTER PROC uspAddDefaultConstraintLibraryNrOfBooks
AS
BEGIN
	ALTER TABLE Library
	ADD CONSTRAINT default_NrOfBooks DEFAULT 0 FOR Nr_Of_Books
	PRINT 'ALTER TABLE Library ADD CONSTRAINT DEFAULT 0 FOR Nr_Of_Books'
END
GO

-- c. undo

CREATE OR ALTER PROC UNDOuspAddDefaultConstraintLibraryNrOfBooks
AS
BEGIN
	ALTER TABLE Library
	DROP CONSTRAINT default_NrOfBooks
	PRINT 'ALTER TABLE Library DROP CONSTRAINT DEFAULT 0 FOR Nr_Of_Books'
END
GO


-- d. add/remove a primary key

CREATE OR ALTER PROC uspRemovePrimaryKeyBorrowedIDFinished
AS
BEGIN
	ALTER TABLE Finished
	DROP CONSTRAINT pk_finished
	PRINT 'ALTER TABLE Finished DROP CONSTRAINT pk_finished from Finished'
END
GO

-- d. undo

CREATE OR ALTER PROC UNDOuspRemovePrimaryKeyBorrowedIDFinished
AS
BEGIN
	ALTER TABLE FINISHED
	ADD CONSTRAINT pk_finished PRIMARY KEY (Borrowed_ID)
	PRINT 'ALTER TABLE Finished ADD CONSTRAINT pk_finished PRIMARY KEY (Borrowed_ID)'
END
GO

-- SELECT name
-- FROM sys.key_contraints
-- WHERE type = 'PK'

-- e. add/remove a candidate key

CREATE OR ALTER PROC uspAddCandidateKeyShelfIDLocation
AS
BEGIN
	ALTER TABLE LOCATION
	ADD CONSTRAINT UQ_Shelf_ID UNIQUE(Shelf_ID)
	PRINT 'ALTER TABLE Location ADD CONSTRAINT UQ_Shelf_ID UNIQUE(Shelf_ID)'
END
GO

-- e. undo

CREATE OR ALTER PROC UNDOuspAddCandidateKeyShelfIDLocation
AS
BEGIN
	ALTER TABLE LOCATION
	DROP CONSTRAINT UQ_Shelf_ID
	PRINT 'ALTER TABLE Location DROP CONSTRAINT UQ_Shelf_ID'
END
GO

-- f. add/remove a foreign key

CREATE OR ALTER PROC uspRemoveForeignKeyBook
AS
BEGIN 
	ALTER TABLE Borrowed
	DROP CONSTRAINT Book_ID
	PRINT 'ALTER TABLE Borrowed DROP CONSTRAINT Book_ID'
END 
GO

-- f. undo

CREATE OR ALTER PROC UNDOuspRemoveForeignKeyBook
AS
BEGIN
	ALTER TABLE Borrowed
	ADD CONSTRAINT Book_ID FOREIGN KEY (Book_ID) REFERENCES Book(ID)
	PRINT 'ALTER TABLE Borrowed ADD CONSTRAINT Book_ID FOREIGN KEY (Book_ID) REFERENCES Book(ID)'
END
GO

-- g. create/drop a table

CREATE OR ALTER PROC uspCreateTestTable
AS
BEGIN
	CREATE TABLE TestTable
	(testID int NOT NULL PRIMARY KEY,
	testMessage VARCHAR(50),
	testName CHAR(30),
	testResult BIT DEFAULT 1)
	PRINT 'CREATE TABLE TestTable'
END
GO

-- g. undo

CREATE OR ALTER PROC UNDOuspCreateTestTable
AS
BEGIN
	DROP TABLE IF EXISTS TestTable
	PRINT 'DROP TABLE IF EXISTS TesteTable'
END
GO

/*
exec uspAddCandidateKeyShelfIDLocation
exec UNDOuspAddCandidateKeyShelfIDLocation
exec uspAddDefaultConstraintLibraryNrOfBooks
exec UNDOuspAddDefaultConstraintLibraryNrOfBooks
exec uspChangePersonAge
exec UNDOuspChangePersonAge
exec uspCreateTestTable
exec UNDOuspCreateTestTable
exec uspRemoveForeignKeyBook
exec UNDOuspRemoveForeignKeyBook
exec uspRemoveLibraryCapacity
exec UNDOuspRemoveLibraryCapacity
exec uspRemovePrimaryKeyBorrowedIDFinished
exec UNDOuspRemovePrimaryKeyBorrowedIDFinished
*/

--Create a table that holds the versions of the database schema (the version is an integer number)


drop TABLE VersionChanged
CREATE TABLE VersionChanged
	(currentProcedure VARCHAR(100),
	backwardsProcedure VARCHAR(100),
	versionTO INT UNIQUE)
GO

INSERT INTO VersionChanged(currentProcedure,backwardsProcedure,versionTO)
VALUES ('uspChangePersonAge', 'UNDOuspChangePersonAge', 1),
('uspRemoveLibraryCapacity', 'UNDOuspRemoveLibraryCapacity', 2),
('uspAddDefaultConstraintLibraryNrOfBooks','UNDOuspAddDefaultConstraintLibraryNrOfBooks', 3),
('uspRemovePrimaryKeyBorrowedIDFinished','UNDOuspRemovePrimaryKeyBorrowedIDFinished', 4),
('uspAddCandidateKeyShelfIDLocation', 'UNDOuspAddCandidateKeyShelfIDLocation', 5),
('uspRemoveForeignKeyBook', 'UNDOuspRemoveForeignKeyBook', 6),
('uspCreateTestTable', 'UNDOuspCreateTestTable', 7)

--SELECT * FROM VersionChanged


-- create a table that keeps only the current version (the version is an integer number)

drop TABLE CurrentVersion
CREATE TABLE CurrentVersion
	(currentVersion INT DEFAULT 0)

INSERT INTO CurrentVersion VALUES(0)

--SELECT * FROM CurrentVersion

GO
CREATE OR ALTER PROCEDURE goToVersion(@version INT)
AS
BEGIN
	DECLARE @currentVersion INT
	IF @version < 0 OR @version > 7   -- check if the parameter is ok
		BEGIN
			RAISERROR('Version number must be smaller than 7 and greater or equal to 0!',17,1)
			RETURN
		END
	ELSE
		IF @version = @currentVersion -- check whether the version parameter is the current parameter
			BEGIN
				PRINT N'We are already on this version!'
				RETURN
			END
		ELSE
		DECLARE @currentProcedure NVARCHAR(50)
		SET @currentVersion = (SELECT currentVersion FROM CurrentVersion)  -- get the current version of the database
		IF @currentVersion < @version
			BEGIN
				WHILE @currentVersion < @version
					BEGIN
						PRINT N'We are at version ' + CAST(@currentVersion as NVARCHAR(10))

						SET @currentProcedure = (SELECT currentProcedure
												FROM VersionChanged
												WHERE versionTO = @currentVersion + 1)
						EXEC(@currentProcedure)
						SET @currentVersion = @currentVersion + 1
					END
			END
		ELSE 
		IF @currentVersion > @version
			BEGIN
				WHILE @currentVersion > @version
					BEGIN
						PRINT N'We are at version ' + CAST(@currentVersion as NVARCHAR(10))

						SET @currentProcedure = (SELECT backwardsProcedure
												FROM VersionChanged
												WHERE versionTO = @currentVersion)
						EXEC(@currentProcedure)
						SET @currentVersion = @currentVersion - 1

					END
			END
		UPDATE CurrentVersion
			SET currentVersion = @currentVersion
		PRINT N'Current version updated!'
		PRINT N'We reached the desired version: ' + CAST(@currentVersion as NVARCHAR(10))
END

Select * FROM VersionChanged

GO
EXEC goToVersion 3
EXEC goToVersion 7
EXEC goToVersion 5
EXEC goToVersion 2
EXEC goToVersion 0
EXEC goToVersion -1

						