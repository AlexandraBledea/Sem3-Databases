USE CakePractic


drop table orderCakes
drop table order_
drop table chefCakes
drop table cake
drop table cakeType
drop table chef


create table chef(
id int primary key,
name varchar(30),
gender varchar(2),
dob varchar(30)
);


create table cakeType(
id int primary key,
name varchar(30),
description varchar(50)
);

create table cake(
id int primary key,
tid int foreign key references cakeType(id),
name varchar(30) unique,
shape varchar(30),
weight int,
price int
);


create table chefCakes(
chid int foreign key references chef(id),
caid int foreign key references cake(id),
primary key(chid, caid)
);


create table order_(
id int primary key,
date_ varchar(30)
);


create table orderCakes(
oid int foreign key references order_(id),
cid int foreign key references cake(id),
pieces int,
primary key(oid,cid)
);


insert into chef values
(1,'c1','m','20/10/2021'),
(2,'c2','f','20/10/2021'),
(3,'c3','m','20/10/2021'),
(4,'c4','f','20/10/2021');


insert into cakeType values
(1,'t1',null),
(2,'t2',null),
(3,'t3',null),
(4,'t4',null);



insert into cake values
(1,1,'c1',null,10,10),
(2,2,'c2',null,10,10),
(3,3,'c3',null,10,10),
(4,4,'c4',null,10,10),
(5,1,'c5',null,10,10),
(6,1,'c6',null,10,10),
(7,2,'c7',null,10,10),
(8,2,'c8',null,10,10);


select count(C.shape)
from cake C


insert into chefCakes values
(1,1),
(1,2),
(1,3),
(1,4),
(1,5),
(1,6),
(1,7),
(2,1),
(2,2),
(2,3),
(3,1),
(3,2);



insert into order_ values
(1,'20/10/2021'),
(2,'20/10/2021'),
(3,'20/10/2021'),
(4,'20/10/2021');


-- 2. Implement a stored procedure that receives an order ID, a cake name, and a positive number P
--    representing the number of ordered pieces, and adds the cake to the order. If the cake
--    is already on the order, the number of ordered pieces is set to P



go
create or alter proc addORupdateCake(@oid int, @cname varchar(30), @p int)
as
begin
	
	IF NOT EXISTS (SELECT * FROM order_ O WHERE O.id = @oid)
	BEGIN
		RAISERROR('Invalid order!', 16, 1)
		RETURN
	END

	IF NOT EXISTS (SELECT * FROM cake C WHERE C.name = @cname)
	BEGIN
		RAISERROR('Invalid cake!', 16, 1)
		RETURN
	END

	DECLARE @cakeID INT = (SELECT C.id from cake C WHERE C.name = @cname)

	IF EXISTS (SELECT * FROM orderCakes OC WHERE OC.cid = @cakeID AND OC.oid = @oid)
		UPDATE orderCakes
		SET pieces = @p
		WHERE oid = @oid AND cid = @cakeID

	ELSE
		INSERT INTO orderCakes Values (@oid, @cakeID, @p)

end
go

select * from orderCakes

exec addORupdateCake 1, 'c1', 10

select * from orderCakes

exec addORupdateCake 1, 'c1', 100

select * from orderCakes


-- 3. Implement a function that lists the nams of the chefs who are specialized in
--    the preparation of all the cakes

go
create or alter function showChefs()
returns table
as
return

	select C.name as Name
	from chef C inner join chefCakes CC on C.id = CC.chid
	group by C.name
	HAVING count(CC.caid) = (SELECT count(C.name)
					   FROM cake C)
	
go

select * from showChefs()