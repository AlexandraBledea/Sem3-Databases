USE ZooPractic


drop table visit
drop table visitor
drop table animalFood
drop table food
drop table animal
drop table zoo


create table zoo(
id int primary key,
administrator varchar(30),
name varchar(30)
);

create table animal(
id int primary key,
zid int foreign key references zoo(id),
name varchar(30),
dob date
);

create table food(
id int primary key,
name varchar(30)
);

create table animalFood(
aid int foreign key references animal(id),
fid int foreign key references food(id)
primary key (aid, fid),
quota int
);

create table visitor(
id int primary key,
name varchar(30),
age int
);

create table visit(
id int primary key,
vid int foreign key references visitor(id),
zid int foreign key references zoo(id),
day_ date,
price int
);


insert into zoo values
(1,'A1','N1'),
(2,'A2','N2'),
(3,'A3','N3'),
(4,'A4','N4');


insert into visitor values
(1,'v1',10),
(2,'v2',20),
(3,'v3',15),
(4,'v4',17),
(5,'v5',30),
(6,'v6',40);


insert into visit values
(1,1,1,'11.12.2021', 10),
(2,2,1,'11.12.2021',20),
(3,3,2,'11.12.2021',30),
(4,4,4,'11.12.2021',40),
(6,6,3,'11.12.2021',20),
(7,5,4,'11.12.2021',30),
(8,6,4,'11.12.2021',40),
(9,4,2,'11.12.2021',50);


insert into animal values
(1,1,'a1','11.12.2021'),
(2,2,'a2','11.12.2021'),
(3,3,'a3','11.12.2021'),
(4,1,'a4','11.12.2021'),
(5,1,'a5','11.12.2021'),
(6,2,'a6','11.12.2021');

insert into food values
(1,'f1'),
(2,'f2'),
(3,'f3'),
(4,'f4');

insert into animalFood values
(1,1,10),
(1,2,15),
(1,3,20),
(2,1,10),
(2,2,20),
(2,3,4),
(2,4,2),
(3,1,10),
(4,1,20),
(4,4,30);

-- 2. Implement a stored procedure that receives an animal and deletes all the data about the food quotas for the animal

go
create or alter proc deleteFood(@id int)
as
begin

	if not exists (SELECT * FROM animal A where A.id = @id)
	BEGIN
		RAISERROR('Invalid animal id!', 16, 1)
	END


	DELETE
	FROM animalFood
	WHERE animalFood.aid = @id

end
go


select * from animalFood 

exec deleteFood 1

select * from animalFood


-- 3. Create a view that shows the ids of the zoos with the smallest number of visits


go
create or alter view showZoos
as
	SELECT Z.id as ZooID
	FROM zoo Z left join visit V on Z.id = V.zid
	GROUP BY Z.id
	HAVING count(V.zid) <= ALL (SELECT COUNT(V2.zid) as nrOfVisitors
								FROM zoo Z2 left join visit V2 on Z2.id = V2.zid
								GROUP BY Z2.id
								)
							
go

select * from showZoos


-- 4. Implement a function that lists the ids of the visitors who went to zoos that have at least N animals, where N>=1 is a function parameter


go
create or alter function showVisitors(@nr int)
returns table
as
return

	SELECT DISTINCT VV.id
	FROM visitor VV inner join visit V ON VV.id = V.vid
	GROUP BY VV.id, V.zid
	HAVING	@nr <= (SELECT count(A.zid) as nrOfAnimals
					FROM animal A inner join visit V2 ON V2.zid = A.zid inner join visitor VV2 ON V2.vid = VV2.id
					WHERE A.zid = V.zid and V2.zid = V.zid AND V2.vid = VV.id and VV2.id = VV.id
					GROUP BY V2.zid)

go

-- 1 - 3 animale (1,2)
-- 2 - 2 animale (3,4)
-- 3 - 1 animal (6)
-- 4 - 0 animale (4,5,6)


select *
from showVisitors(1)


/*
SELECT Z.ID, count(A.zid) AS nrOfAnimals
FROM zoo Z left join animal A ON Z.id = A.zid
GROUP BY Z.id
*/
