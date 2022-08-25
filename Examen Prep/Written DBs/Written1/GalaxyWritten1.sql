USE GalaxyWritten1

drop table naturalSatellite
drop table planet
drop table planetarySystem
drop table star
drop table galaxy
drop table clusterGalaxies
drop table groupGalaxies
drop table category



create table category(
id int primary key,
name varchar(30) check (name = 'elliptical' or name = 'spiral' or name = 'irregular')
);

create table groupGalaxies(
id int primary key,
name varchar(30),
diameter int,
mass int
);

create table clusterGalaxies(
id int primary key,
name varchar(30),
mass int,
type int check(type = 1 or type = 2 or type = 3)
);

create table galaxy(
id int primary key,
name varchar(30),
cid int foreign key references category(id),
diameter int,
mass int,
ggid int foreign key references groupGalaxies(id),
cgid int foreign key references clusterGalaxies(id),
constraint fk_check check ((ggid is null and cgid is not null) or (ggid is not null and cgid is null))

);


create table star(
id int primary key,
gid int foreign key references galaxy(id),
name varchar(30),
age int,
metallicity float
);

create table planetarySystem(
id int primary key,
sid int foreign key references star(id) unique,
name varchar(30)
);

create table planet(
id int primary key,
psid int foreign key references planetarySystem(id),
name varchar(30)
);

create table naturalSatellite(
name varchar(30),
pid int foreign key references planet(id)
);



-- 2. Write a query for each of the tasks below, using the specified language: (2p)
-- a. Find the name and age of every star in the Milky Way galaxy with a planetary system that has:
--    at least 5 planets OR
--    at least one natural satellite (as stated above, such a satellite belongs to a planet in the planetary system).
--    in SQL, without views (StarName, StarAge).


SELECT S.name, S.age
FROM star S inner join galaxy G ON S.gid = G.id inner join planetarySystem PS ON PS.sid = S.id 
WHERE G.name = 'Milky Way'  and (5 <= (SELECT count(*) 
									  FROM planet PP
									  WHERE PS.id = PP.id)
															 OR PS.id IN (SELECT  P.psid
																			FROM naturalSatellite NS inner join planet P
																				ON P.id = NS.pid))



-- b. Find all galaxies in clusters of type 2 – in the relational algebra (cluster name, galaxy name).