-- Select all Books which received reviews from a critic with more than 5 years experience
SELECT * FROM Book
SELECT * FROM Critic
SELECT * FROM Review
SELECT B.Title, B.Edition
FROM Book B inner join
	(SELECT R.Book_ID
	FROM Review R inner join
		(SELECT C.CNP
		FROM Critic C
		WHERE C.Nr_Of_Age_Working > 5 ) CW
	ON CW.CNP = R.CNP
	) RW
	ON RW.Book_ID = B.ID
