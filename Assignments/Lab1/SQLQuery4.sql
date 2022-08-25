USE LibraryManagement;
drop table Location;
drop table Borrowed;
drop table Review;
drop table Connection_Library_Book;
drop table Subscription;
drop table Connection_Library_Subscriber;
drop table Staff_Member;
drop table Book;
drop table Subscriber;
drop table Library;


CREATE TABLE Library (
	ID integer not null primary key,
	Address varchar(30) not null,
	Nr_Of_Books integer,
	Capacity integer
);

CREATE TABLE Subscriber (
	CNP char(13) not null primary key,
	Name varchar(30) not null,
	Age integer,
	Nr_Of_Rented_Books integer
);

CREATE TABLE Book (
	ID integer not null primary key,
	Title varchar(100) not null,
	Author varchar(30) not null,
	Edition varchar(15),
	Publisher varchar(30),
	Description varchar(100)
);

CREATE TABLE Staff_Member (
	CNP char(13) not null primary key,
	Name varchar(30) not null,
	Age integer,
	Telephone integer,
	Library_ID integer not null,
	foreign key (Library_ID) references Library(ID) on delete cascade on update cascade
);

CREATE TABLE Connection_Library_Subscriber (
	Library_ID integer not null,
	CNP_Sub char(13) not null,
	foreign key (Library_ID) references Library(ID) on delete cascade on update cascade,
	foreign key (CNP_Sub) references Subscriber(CNP) on delete cascade on update cascade,
	constraint pk_connection_library_subscriber primary key (Library_ID, CNP_Sub)
);

CREATE TABLE Subscription (
	ID integer not null primary key,
	Price integer,
	Availability BIT,
	CNP_Sub char(13) not null unique,
	foreign key (CNP_Sub) references Subscriber(CNP) on delete cascade on update cascade
);

CREATE TABLE Connection_Library_Book (
	Book_ID integer not null,
	Library_ID integer not null,
	foreign key (Book_ID) references Book(ID) on delete cascade on update cascade,
	foreign key (Library_ID) references Library(ID) on delete cascade on update cascade,
	constraint pk_connection_library_book primary key (Book_ID, Library_ID)
);

CREATE TABLE Review (
	ID integer not null primary key,
	Book_Title varchar(30) not null,
	Book_Author varchar(30) not null,
	Book_Edition varchar(15),
	Ideea varchar(100),
	Book_ID integer not null,
	foreign key (Book_ID) references Book(ID) on delete cascade on update cascade
);

CREATE TABLE Borrowed (
	ID integer not null primary key,
	Issued_Date date,
	Due_Date date,
	Book_ID integer not null,
	foreign key (Book_ID) references Book(ID) on delete cascade on update cascade
);

CREATE TABLE Location (
	ID integer not null primary key,
	Shelf_ID integer,
	Row_Number integer,
	Section_ID integer,
	Book_ID integer not null unique,
	foreign key (Book_ID) references Book(ID) on delete cascade on update cascade
);


insert into Library VALUES('1', 'Decembrie 1' , '3000', '320')
insert into Library VALUES('112', 'Decembrie 345' , '303400', '3120')
insert into Library VALUES('1321', 'Decembrie 50' , '3000', '320')
insert into Library VALUES('3211', 'Kogalniceanu 217' , '33000', '332')
insert into Library VALUES('31241', 'Iuliu Maniu 126' , '53000', '3430')
insert into Library VALUES('4351', 'Alexandri 12' , '200', '35630')

SELECT * from Library
SELECT * from Library
Where Nr_Of_Books = '3000'

SELECT * from Library
Where Address = 'Decembrie 1' AND Nr_Of_Books = '4000'