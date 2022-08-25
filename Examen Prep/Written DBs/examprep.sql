drop table s
drop table s1
drop table s2

create table s(
id varchar(20) primary key,
a varchar(20), 
b varchar(20),
c varchar(50),
d int,
e int,
f int
);


create table s1(
id varchar(20) primary key,
a varchar(20),
b varchar(20),
c varchar(50) not null
);

select *
from s1
where c = null


create table s2(
d int,
e int,
f int
);

insert into s values
('t1','a1','b2','si abia pleca batranul...',1,1,0),
('t2','a1','b2','codrul clocoti de zgomot',1,2,1),
('t3','a1','b3','iar la poala lui cea verde',1,3,0),
('t4','a1','b3','mii de coifuri lucitoare',1,123,-1),
('t5','a1','b3','calaretii umplu campul',-1,4,-1);


select avg(e)
from s
group by d
having avg(e) > 0

insert into s1 values
('t1','a1','b2','si abia pleca batranul...'),
('t2','a1','b2','codrul clocoti de zgomot'),
('t3','a1','b3','iar la poala lui cea verde'),
('t4','a1','b3','mii de coifuri lucitoare'),
('t5','a1','b3','calaretii umplu campul');


insert into s2 values
(0,1,0),
(1,2,1),
(0,3,0),
(2,123,-1),
(-1,4,-1);

--1
--a
select distinct a,b
from s

--b
select *
from s
where b = 'b2' and b = 'b3'

-- c
select * from s where b = 'b3'
union
select * from s where b = 'b3'

-- d
select * 
from s 
where d >= 0
except
select *
from s
where e <> 4


-- 2
/*
select *
from s1 natural join s2

-- answer e?
*/

-- 3
SELECT B, C, COUNT(*)
FROM S
GROUP BY B, C
HAVING max(D) <= 1

-- answer e

-- 4

SELECT *
FROM S
WHERE C LIKE 'de%'

-- ans b

