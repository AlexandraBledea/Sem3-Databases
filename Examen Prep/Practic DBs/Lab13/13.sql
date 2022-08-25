
drop table R

create table R(
rid int primary key,
a1 varchar(10),
k2 int unique,
a2 int,
a3 int,
a4 int,
a5 varchar(10),
a6 int
)



insert into R values
(2, 'a', 100,1,3,3,'M1',22),
(3, 'b', 200,1,3,3,'M1',22),
(4, 'c', 150,2,3,4,'M1',23),
(5, 'd', 700,2,4,4,'M2', 29),
(6, 'e', 300,3,4,5,'M2', 29),
(7, 'f', 350,3,4,5,'M5', 23),
(8, 'g', 400,3,5,7,'M5', 29),
(9, 'h', 500,4,5,7,'M2',30),
(10,'j', 450,4,5,7,'M7',30),
(11,'k',250,4,6,7,'M7',30),
(12,'l',800,5,6,7,'M6',22),
(13,'m',750,5,6,7,'M6',23);

SELECT *
FROM R r1 INNER JOIN R r2 ON r1.A2 = r2.A3
INNER JOIN R r3 ON r2.A3 = r3.A4
ORDER BY r1.rid


/*

SELECT r1.RID, r1.K2, COUNT(*) NumRows
FROM R r1 INNER JOIN R r2 ON r1.A2 = r2.A3
INNER JOIN R r3 ON r2.A3 = r3.A4
WHERE r1.A1 LIKE '_%'
GROUP BY r1.RID, r1.K2
HAVING COUNT(*) >= 6

*/

SELECT r1.A6, MAX(r1.A2) MaxA2
FROM R r1
WHERE r1.A5 IN ('M1', 'M2')
GROUP BY r1.A6
EXCEPT
SELECT DISTINCT r2.A6, r2.A2
FROM R r2