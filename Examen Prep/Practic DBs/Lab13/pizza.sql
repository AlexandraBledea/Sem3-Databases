USE Pizza


drop table delivery
drop table customer
drop table pizzaShop
drop table drone
drop table droneModel
drop table droneManufacturer


create table droneManufacturer(
id int primary key,
name varchar(30)
);


create table droneModel(
id int primary key,
mid int foreign key references droneManufacturer(id) not null,
name varchar(30),
battery int,
maxSpeed int
);

create table drone(
id int primary key,
model int foreign key references droneModel(id),
nr int
);

create table pizzaShop(
id int primary key,
name varchar(30) unique,
address varchar(30)
);

create table customer(
id int primary key,
name varchar(30) unique,
score int
);

create table delivery(
pid int foreign key references pizzaShop(id),
cid int foreign key references customer(id),
did int foreign key references drone(id),
date_ date,
time_ time
primary key(pid, cid, did, date_, time_)
);


insert into droneManufacturer values
(1,'MF1'),
(2,'MF2'),
(3,'MF3');

insert into droneModel values
(1,1,'M1',10,10),
(2,2,'M2',10,10),
(3,3,'M3',20,30),
(4,1,'M4',50,50);

insert into drone values
(1,1,1),
(2,2,2),
(3,3,3),
(4,4,4),
(5,1,10),
(6,1,20),
(7,2,30),
(8,2,15);

insert into pizzaShop values
(1,'a','a'),
(2,'b','b'),
(3,'c','c');

insert into customer values
(1,'a',1),
(2,'b',2),
(3,'c',3);

insert into delivery values
(1,1,1,'01.01.2022','10:10'),
(1,1,2,'01.01.2022','10:10'),
(2,2,2,'04.02.2022','13:10');

GO
create or alter proc addDelivery(@cid int, @pid int, @did int, @date date, @time time)
AS
BEGIN
	IF NOT EXISTS (SELECT * FROM customer C where C.id = @cid)
		BEGIN
			RAISERROR('Invalid customer!',16,1)
		END
	
	IF NOT EXISTS (SELECT * FROM pizzaShop P where P.id = @pid)
		BEGIN
			RAISERROR('Invalid pizza shop!',16,1)
		END

	IF NOT EXISTS (SELECT * FROM drone D where D.id = @did)
		BEGIN
			RAISERROR('Invalid dron!', 16, 1)
		END

	
	IF EXISTS (SELECT * 
				FROM delivery D
				WHERE D.cid =  @cid and D.did = @did aND D.pid = @pid )

			UPDATE delivery
			SET time_ = @time, date_ = @date
			WHERE did = @did and cid = @cid and pid = @pid

	ELSE
			INSERT INTO delivery values (@pid, @cid, @did, @date, @time)
				
END
GO

exec addDelivery 3, 3,3, '10.10.2020', '10:20'
select * from delivery


-- 3. Create a view that shows the names of the startup’s favorite drone manufacturers, i.e.,
--  those with the largest number of drones used by the startup.
--  Example: suppose the startup has partnerships with 3 manufacturers: M1, M2, M3; it has 10 drones from M1, 10 drones from M2, and 8 drones from M3.
--  M1 and M2 are the manufacturers with the largest number of drones.


GO

create or alter view displayManufacturers
AS
	SELECT MF.name
	FROM droneManufacturer MF inner join droneModel M ON MF.id = M.mid inner join drone D ON D.model = M.id
	GROUP BY MF.name
	HAVING count(*) >= ALL (SELECT count(*) as nrOfDrones
							FROM droneManufacturer MF2 inner join droneModel M2 ON MF2.id = M2.mid inner join drone D2 ON D2.model = M2.id
							GROUP BY MF2.name
							)
	
GO


-- 4. Implement a function that lists the names of the customers who received at least D deliveries, where D is a function parameter.

GO
create or alter function displayCustomers(@nr int)
RETURNS TABLE
AS
RETURN
	SELECT C.name, count(C.name) as nrOfDeliveries
	FROM delivery D inner join customer C
		ON D.cid = C.id
	GROUP BY C.name
	HAVING count(C.name) > @nr
GO


select *
from displayCustomers(1)
