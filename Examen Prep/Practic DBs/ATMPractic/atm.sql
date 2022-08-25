USE ATMPractic

drop table transaction_
drop table atm
drop table card_
drop table bankAccount
drop table customer

create table customer(
id int primary key,
name varchar(30),
dob varchar(30)
);


create table bankAccount(
iban int primary key,
cid int foreign key references customer(id),
currBalance int
);

create table card_(
number int primary key,
baid int foreign key references bankAccount(iban),
cvv int
);

create table atm(
id int primary key,
address varchar(30)
);

create table transaction_(
id int primary key,
aid int foreign key references atm(id),
cid int foreign key references card_(number),
money int,
time_ time
);


insert into customer values
(1,'c1','11.12.2021'),
(2,'c2','11.12.2021'),
(3,'c3','11.12.2021'),
(4,'c4','11.12.2021');


insert into bankAccount values
(1,1,100),
(2,2,200),
(3,3,300),
(4,4,1000);

insert into card_ values
(1,1,1),
(2,2,2),
(3,3,3),
(4,4,4);

insert into atm values
(1,'a1'),
(2,'a2'),
(3,'a3'),
(4,'a4');

insert into transaction_ values
(1,1,1,500,'10:10'),
(2,2,1,500,'10:10'),
(3,3,1,500,'10:10'),
(4,4,1,500,'10:10'),
(5,1,2,10000,'10:10'),
(6,2,3,100,'10:10'),
(7,1,1,100,'17:10');


-- 2. Implement a stored procedure that receives a card and deletes all the transactions
--    associated with that card


go
create or alter proc deleteTrans(@number int)
as
begin

	IF NOT EXISTS (SELECT * FROM card_ C WHERE C.number = @number)
	BEGIN
		RAISERROR('Invalid card!', 16, 1)
	END

	DELETE 
	FROM transaction_ 
	WHERE transaction_.cid = @number

end
go


-- 3. Create a view that shows all the card numbers which were used in transactions at all the ATM's


GO
create or alter view showCards
AS

	SELECT C.number as Number
	FROM card_ C
	WHERE (SELECT count(*) from atm) = (SELECT count(DISTINCT T.aid)
										FROM transaction_ T inner join atm A ON T.aid = A.id
										WHERE T.cid = C.number)
GO

select *
from showCards



SELECT count(DISTINCT T.aid)
FROM transaction_ T inner join atm A ON T.aid = A.id
WHERE T.cid = 1


/* 	SELECT C.number, T.aid
	FROM card_ C inner join transaction_ T
	ON C.number = T.cid
	GROUP BY C.number, T.aid
	HAVING count(*) = (SELECT count(A.id) as nrOfAtms
							  FROM atm A)

*/

-- 4. Implement a function that lists a cards(number and CVV code) that have the total transactions sum greater than 2000 lei.


go
create or alter function listCards()
returns table
as
return
	SELECT C.number, C.cvv
	FROM card_ C inner join transaction_ T ON C.number = T.cid
	GROUP BY C.number, C.cvv
	HAVING sum(T.money) > 2000

go

select *
from listCards()