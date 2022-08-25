USE MoviePractic

create table company(
id int primary key,
name varchar(30)
)

create table director(
id int primary key,
name varchar(30),
awards int
);

create table movie(
id int primary key,
did int foreign key references director(id),
cid int foreign key references company(id),
name varchar(30),
release date,
);

create table cinemaProduction(
id int primary key,
name varchar(30),
