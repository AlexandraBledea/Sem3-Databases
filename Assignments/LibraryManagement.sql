USE LibraryManagement;
drop table Location;
drop table Review;
drop table Critic;
drop table Subscription;
drop table Staff_Member;
drop table Finished;
drop table Borrowed;
drop table Subscriber;
drop table Person;
drop table Book;
drop table Library;


CREATE TABLE Library (
	ID integer not null primary key,
	Address varchar(30) not null,
	Nr_Of_Books integer,
	Capacity integer
);

CREATE TABLE Book (
	ID integer not null primary key,
	Title varchar(100) not null,
	Author varchar(30) not null,
	Edition varchar(15),
	Publisher varchar(30),
	Category varchar(50),
	Description varchar(100),
	Popularity integer default 0
);

CREATE TABLE Person (
	CNP integer not null primary key,
	Name varchar(30) not null,
	Age integer
);

CREATE TABLE Subscriber (
	CNP integer not null,
	foreign key (CNP) references Person(CNP) on delete cascade on update cascade,
	constraint pk_subscriber primary key (CNP),
	Nr_Of_Rented_Books integer,
	Favorite_Book varchar(100),
	Favorite_Author varchar(30)
);

CREATE TABLE Borrowed (
	ID integer primary key,
	Issued_Date date,
	Due_Date date,
	Book_ID integer not null,
	Library_ID integer not null,
	CNP_Sub integer not null,
	foreign key (Book_ID) references Book(ID) on delete cascade on update cascade,
	foreign key (Library_ID) references Library(ID) on delete cascade on update cascade,
	foreign key(CNP_Sub) references Subscriber(CNP) on delete cascade on update cascade,
	--constraint pk_borrowed primary key (Book_ID, Library_ID, CNP_Sub)
);

CREATE TABLE Finished(
	Borrowed_ID integer unique not null,
	Date_Finished Date default NULL,
	foreign key(Borrowed_ID) references Borrowed(ID) on delete cascade on update cascade,
	constraint pk_finished primary key(Borrowed_ID)
)

/*	foreign key (CNP_Sub) references Subscriber(CNP) on delete cascade on update cascade,
	foreign key (Book_ID) references Book(ID) on delete cascade on update cascade,
	constraint pk_finished primary key(Book_ID, CNP_Sub, Library_ID)*/


CREATE TABLE Staff_Member (
	CNP integer not null,
	Telephone integer,
	Library_ID integer not null,
	Salary integer,
	foreign key (Library_ID) references Library(ID) on delete cascade on update cascade,
	foreign key (CNP) references Person(CNP) on delete cascade on update cascade,
	constraint pk_staff_member primary key (CNP)
);

CREATE TABLE Subscription (
	Library_ID integer not null,
	CNP_Sub integer not null,
	Price integer,
	Availability BIT,
	foreign key (Library_ID) references Library(ID) on delete cascade on update cascade,
	foreign key (CNP_Sub) references Subscriber(CNP) on delete cascade on update cascade,
	constraint pk_subscription primary key (Library_ID, CNP_Sub)
);

CREATE TABLE Critic (
	CNP integer not null unique,
	Nr_Of_Age_Working integer,
	foreign key (CNP) references Person(CNP) on delete cascade on update cascade,
	constraint pk_critic primary key (CNP)
);

CREATE TABLE Review (
	Book_ID integer not null,
	CNP integer not null,
	Book_Title varchar(100) not null,
	Book_Author varchar(30) not null,
	Ideea varchar(100),
	Grade integer,
	foreign key (Book_ID) references Book(ID) on delete cascade on update cascade,
	foreign key (CNP) references Critic(CNP) on delete cascade on update cascade,
	constraint pk_review primary key (Book_ID, CNP)
);

CREATE TABLE Location (
	ID integer not null primary key,
	Shelf_ID integer,
	Section_ID integer,
	Book_ID integer not null unique,
	foreign key (Book_ID) references Book(ID) on delete cascade on update cascade
);
