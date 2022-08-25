Use OlympicGames
go

drop table Result
drop table Participant
drop table Trial
drop table Sport
drop table Country


create table Country
(
Cid int primary key,
CName varchar(255) UNIQUE,
)

create table Sport
(
Spid int primary key,
SName varchar(255) UNIQUE,
)

create table Trial
(
Tid int primary key,
TDesc varchar(255),
TypeTeam varchar(255),
Spid int foreign key references Sport(Spid)
)


create table Participant
(
Pid int primary key,
PName varchar(255),
PBirth varchar(255),
Cid int foreign key references Country(Cid)
)

create table Result
(
Pid int foreign key references Participant(Pid),
Tid int foreign key references Trial(Tid),
RDate varchar(255),
RPlace int,
PRIMARY KEY(Pid,TID)
)


insert into Country values
(1,'Romania'),
(2,'Austria'),
(3,'Germania'),
(4,'Olanda'),
(5,'Franta'),
(6,'Malta'),
(7,'Rusia'),
(8,'Japonia'),
(9,'Italia');

select * from Country

insert into Sport values
(1,'Fotbal'),
(2,'Archery'),
(3,'Swimming');


select * from Sport

insert into Trial values
(1,'45 minute games','Team',1),
(2,'90 minute games','Team',1),
(3,'100M','Individual',2),
(4,'150M','Individual',2),
(5,'50M','Individual',3),
(6,'100M','Individual',3),
(7,'200M','Individual',3),
(8,'400M','Individual',3);


select * from Trial

insert into Participant values
(1,'Vinero','2001-02-22',1),
(2,'Latiero','2004-12-23',1),
(3,'Marviero','2003-10-12',1),
(4,'Cinciero','2002-08-22',2),
(5,'Carlos','2004-01-24',2),
(6,'Marius','1999-01-25',2),
(7,'Alehandro','2003-5-22',2),
(8,'Cristiano','2002-06-30',3),
(9,'Robert','2005-05-31',4),
(10,'Marian','2006-03-11',5);

select * from Participant


insert into Result values
(1,1,'2024-20-01',1),
(1,2,'2024-20-01',4),
(2,3,'2024-20-01',3),
(3,4,'2024-20-01',4),
(4,5,'2024-20-01',1),
(5,6,'2024-20-01',2),
(6,7,'2024-20-01',3),
(7,8,'2024-20-01',3),
(8,4,'2024-20-01',4),
(9,1,'2024-20-01',2),
(10,2,'2024-20-01',1);

select * from Result

go
create or alter proc AddOrUpdateResult(@pid int, @tid int, @place int, @date varchar(255))
AS
BEGIN

	IF NOT EXISTS (SELECT * FROM Participant P WHERE P.Pid = @pid)
	BEGIN
		RAISERROR('Invalid participan id', 16, 1)
		RETURN
	END

	IF NOT EXISTS (SELECT * FROM Trial T where T.Tid = @tid)
	BEGIN
		RAISERROR('Invalid trial id', 16, 1)
		RETURN
	END

	IF EXISTS (SELECT * 
				FROM Participant P inner join Result R
				ON P.Pid = R.Pid 
					inner join Trial T
					ON R.Tid = T.Tid
					WHERE R.Pid = @pid and R.Tid = @tid)
				
			UPDATE Result
			Set RPlace = @place, RDate = @date
			WHERE Pid = @pid and Tid = @tid
		
		ELSE
			INSERT INTO Result values (@pid, @tid, @date, @place)

END
GO


-- With this one we update
EXEC AddOrUpdateResult 1, 1, 2, '2030-10-10'

-- With this one we raise the first error
EXEC AddOrUpdateResult 12, 1, 2, '2030-10-10'

-- With this one we raise the second error
EXEC AddOrUpdateResult 1, 20, 2, '2030-10-10'

-- With this one we add
EXEC AddOrUpdateResult 1,7,7,'2050-11-11'


select * from Result



/* Implement a function that shows the names of the participants 
that participated in all the trials that belong to a sport.
The sport name is received as a parameter */



DROP FUNCTION filterParticipantsByTrials

GO
CREATE FUNCTION filterParticipantsByTrials(@SName varchar(255))	
RETURNS @participants TABLE(ParticipantName varchar(255))
BEGIN

	DECLARE @Trials TABLE (tid int)

	INSERT INTO @Trials 
	Select T.Tid
		FROM Sport S inner join Trial T
		ON S.Spid = T.Spid
		WHERE S.SName = @SName


	DECLARE @nrOfTrials int = (SELECT count(*)
								FROM Sport S inner join Trial T
								ON S.Spid = T.Spid
								WHERE S.SName = @SName)

	INSERT INTO @participants
		SELECT P.PName
		FROM Participant P inner join Result R
		ON P.Pid = R.Pid
			inner join Trial T
			ON T.Tid = R.Tid
				inner join Sport S
				ON S.Spid = T.Spid
					inner join @Trials TT
					ON T.Tid = TT.tid
		WHERE S.SName = @SName and R.Tid = TT.tid
		GROUP BY P.PName
		HAVING count(P.Pid) = @nrOfTrials

	RETURN
END
GO

SELECT *
FROM filterParticipantsByTrials('Fotbal')











/*

/*

SELECT P.PName, count(P.Pid)
FROM Participant P ,Result R
WHERE R.Pid = P.Pid and (R.Tid = 1 or R.Tid = 2)
GROUP BY P.Pid, P.PName
HAVING count(P.PName) <> 0



	INSERT INTO @participants
		SELECT P.PName
		FROM Participant P inner join Result R 
		ON P.Pid = R.Pid
		WHERE R.Tid IN
			(SELECT T.Tid
			FROM @Trials T
			)
	*/


/*
	SELECT P.PName
	FROM Participant P inner join Result R
	ON P.Pid = R.Pid
	WHERE R.Tid = ALL
		(SELECT T.Tid
		FROM Trial T inner join Sport S
		ON T.Tid = S.Spid
		WHERE S.SName = @SName
		)
*/		

SELECT P.PName, count(P.Pid)
FROM Participant P ,Result R
WHERE R.Pid = P.Pid and (R.Tid = 1 or R.Tid = 2)
GROUP BY P.Pid, P.PName
HAVING count(P.PName) <> 0

Select COUNT(*)
		FROM Sport S inner join Trial T
		ON S.Spid = T.Spid
		WHERE S.SName = 'Fotbal'



/* 	DECLARE @spid int = (SELECT S.spid
						FROM Sport S
						WHERE S.SName = @SName)


							INSERT INTO @table (SELECT T.tid
						FROM Sport S inner join Trial T
						ON S.Spid = T.Tid
						WHERE S.SName = @SName)
							DECLARE @table TABLE (tid int)*/


							*/