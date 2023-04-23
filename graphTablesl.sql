USE master;
DROP DATABASE IF EXISTS CompanyNetwork;
CREATE DATABASE CompanyNetwork;
USE CompanyNetwork;

CREATE TABLE Company
(
id INT NOT NULL PRIMARY KEY,
name NVARCHAR(50) NOT NULL
) AS NODE;

INSERT INTO Company (id, name)
VALUES (1, N'Google'),
(2, N'Moodle'),
(3, N'Innowise'),
(4, N'Akila'),
(5, N'Beheader'),
(6, N'Xiaomi'),
(7, N'Samsung'),
(8, N'Realme'),
(9, N'Fujitsu'),
(10, N'Intel');

SELECT *
FROM Company

CREATE TABLE Project
(
id INT NOT NULL PRIMARY KEY,
name NVARCHAR(50) NOT NULL
) AS NODE;

INSERT INTO Project (id, name)
VALUES (1, N'Angry Pigs'),
(2, N'Shots'),
(3, N'Rip'),
(4, N'Anihilate humanity'),
(5, N'Behead'),
(6, N'Opponent'),
(7, N'Suffer'),
(8, N'Diary'),
(9, N'Cemetry'),
(10, N'Shot');
                 
SELECT *
FROM Project

CREATE TABLE Employee
(
id INT NOT NULL PRIMARY KEY,
name NVARCHAR(50) NOT NULL
) AS NODE;

INSERT INTO Employee (id, name)
VALUES (1, N'Иван'),
(2, N'Вера'),
(3, N'Анна'),
(4, N'Олег'),
(5, N'Нина'),
(6, N'Глеб'),
(7, N'Пётр'),
(8, N'Яна'),
(9, N'Николай'),
(10, N'Инна');

SELECT *
FROM Employee

-------------------------------------------------------

CREATE TABLE CooperateWith AS EDGE; --компании сотрудничают

ALTER TABLE CooperateWith
ADD CONSTRAINT EC_CooperateWith CONNECTION (Company TO Company);

INSERT INTO CooperateWith ($from_id, $to_id)
VALUES ((SELECT $node_id FROM Company WHERE ID = 1),
(SELECT $node_id FROM Company WHERE ID = 4)), 
((SELECT $node_id FROM Company WHERE ID = 1),
(SELECT $node_id FROM Company WHERE ID = 6)),
((SELECT $node_id FROM Company WHERE ID = 3),
(SELECT $node_id FROM Company WHERE ID = 7)), 
((SELECT $node_id FROM Company WHERE ID = 2),
(SELECT $node_id FROM Company WHERE ID = 9)),
((SELECT $node_id FROM Company WHERE ID = 5),
(SELECT $node_id FROM Company WHERE ID = 10)),
((SELECT $node_id FROM Company WHERE ID = 3),
(SELECT $node_id FROM Company WHERE ID = 5)),
((SELECT $node_id FROM Company WHERE ID = 4),
(SELECT $node_id FROM Company WHERE ID = 8)),
((SELECT $node_id FROM Company WHERE ID = 8),
(SELECT $node_id FROM Company WHERE ID = 9));

SELECT *
FROM CooperateWith

CREATE TABLE WorkOn AS EDGE; --сотрудник работает над проектом

ALTER TABLE WorkOn
ADD CONSTRAINT EC_WorkOn CONNECTION (Employee TO Project);

INSERT INTO WorkOn ($from_id, $to_id)
VALUES ((SELECT $node_id FROM Employee WHERE ID = 1),  
(SELECT $node_id FROM Project WHERE ID = 7)),  
((SELECT $node_id FROM Employee WHERE ID = 2),
(SELECT $node_id FROM Project WHERE ID = 9)),
((SELECT $node_id FROM Employee WHERE ID = 3),
(SELECT $node_id FROM Project WHERE ID = 8)),
((SELECT $node_id FROM Employee WHERE ID = 4),
(SELECT $node_id FROM Project WHERE ID = 2)),
((SELECT $node_id FROM Employee WHERE ID = 5),
(SELECT $node_id FROM Project WHERE ID = 1)),
((SELECT $node_id FROM Employee WHERE ID = 6),
(SELECT $node_id FROM Project WHERE ID = 4)),
((SELECT $node_id FROM Employee WHERE ID = 7),
(SELECT $node_id FROM Project WHERE ID = 3)),
((SELECT $node_id FROM Employee WHERE ID = 8),
(SELECT $node_id FROM Project WHERE ID = 5)),
((SELECT $node_id FROM Employee WHERE ID = 9),
(SELECT $node_id FROM Project WHERE ID = 10)),
((SELECT $node_id FROM Employee WHERE ID = 10),
(SELECT $node_id FROM Project WHERE ID = 6));


SELECT *
FROM WorkOn

CREATE TABLE ResponsibleFor AS EDGE; --ответсвенна за проект

ALTER TABLE ResponsibleFor
ADD CONSTRAINT EC_ResponsibleFor CONNECTION (Company TO Project);


INSERT INTO ResponsibleFor ($from_id, $to_id)
VALUES ((SELECT $node_id FROM Company WHERE ID = 9),
(SELECT $node_id FROM Project WHERE ID = 1)),
((SELECT $node_id FROM Company WHERE ID = 4),
(SELECT $node_id FROM Project WHERE ID = 2)),
((SELECT $node_id FROM Company WHERE ID = 1),
(SELECT $node_id FROM Project WHERE ID = 3)),
((SELECT $node_id FROM Company WHERE ID = 3),
(SELECT $node_id FROM Project WHERE ID = 4)),
((SELECT $node_id FROM Company WHERE ID = 6),
(SELECT $node_id FROM Project WHERE ID = 5)),
((SELECT $node_id FROM Company WHERE ID = 8),
(SELECT $node_id FROM Project WHERE ID = 6)),
((SELECT $node_id FROM Company WHERE ID = 2),
(SELECT $node_id FROM Project WHERE ID = 7)),
((SELECT $node_id FROM Company WHERE ID = 7),
(SELECT $node_id FROM Project WHERE ID = 8)),
((SELECT $node_id FROM Company WHERE ID = 9),
(SELECT $node_id FROM Project WHERE ID = 5)),
((SELECT $node_id FROM Company WHERE ID = 10),
(SELECT $node_id FROM Project WHERE ID = 10));


SELECT *
FROM ResponsibleFor

SELECT Employee.name
, Project.name
FROM Employee
, WorkOn
, Project
WHERE MATCH(Employee-(WorkOn)->Project)
AND Employee.name = N'Вера';

SELECT Employee.name
, Project.name
FROM Employee
, WorkOn
, Project
WHERE MATCH(Employee-(WorkOn)->Project)

SELECT Company1.name
, Company2.name AS [Company name]
FROM Company AS Company1
, CooperateWith
, Company AS Company2
WHERE MATCH(Company1-(CooperateWith)->Company2)
AND Company1.name = N'Google';

SELECT Company1.name
, Company2.name AS [Company name]
FROM Company AS Company1
, CooperateWith
, Company AS Company2
WHERE MATCH(Company1-(CooperateWith)->Company2)

SELECT Project.name
, Company.name
FROM Project
, ResponsibleFor
, Company
WHERE MATCH(Company-(ResponsibleFor)->Project)

SELECT Company1.name AS CompanyName
, STRING_AGG(Company2.name, '->') WITHIN GROUP (GRAPH PATH) AS
Companies
FROM Company AS Company1
, CooperateWith FOR PATH
, Company FOR PATH AS Company2
WHERE MATCH(SHORTEST_PATH(Company1(-(CooperateWith)->Company2)+))
AND Company1.name = N'Google';

SELECT Company1.name AS CompanyName
, STRING_AGG(Company2.name, '->') WITHIN GROUP (GRAPH PATH) AS
Companies
FROM Company AS Company1
, CooperateWith FOR PATH
, Company FOR PATH AS Company2
WHERE MATCH(SHORTEST_PATH(Company1(-(CooperateWith)->Company2){1,2}))
AND Company1.name = N'Google';


SELECT @@SERVERNAME
SELECT P1.ID IdFirst
 , P1.name AS First
 , CONCAT(N'Cooperates',P1.id) AS [First image name]
 , P2.ID AS IdSecond
 , P2.name AS Second
 , CONCAT(N'Cooperates',P2.id) AS [Second image name]
FROM dbo.Company AS P1
 , dbo.CooperateWith AS F
 , dbo.Company AS P2
WHERE MATCH (P1-(F)->P2)
SELECT P.ID IdEmployee
 , P.name AS Employee
 , CONCAT(N'Employee',P.id) AS [Employee image name]
 , R.ID AS IdProject
 , R.name AS Project
 , CONCAT(N'Project',R.id) AS [Project image name]
FROM dbo.Employee AS P
 , dbo.WorkOn AS L
 , dbo.Project AS R
WHERE MATCH (P-(L)->R) 


SELECT C.ID IdCompany
 , C.name AS Company
 , CONCAT(N'Company',C.id) AS [Company image name]
 , P.ID AS IdProject
 , P.name AS Project
 , CONCAT(N'Project',P.id) AS [Project image name]
FROM dbo.Company AS C
 , dbo.ResponsibleFor AS R
 , dbo.Project AS P
WHERE MATCH (C-(R)->P) 