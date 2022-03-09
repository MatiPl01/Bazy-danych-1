USE joindb;

SELECT c.buyer_name AS buyer1, p.prod_name, d.buyer_name AS buyer2
FROM Sales AS a
INNER JOIN Sales AS b
ON a.prod_id = b.prod_id
INNER JOIN Buyers AS c
ON c.buyer_id = a.buyer_id
INNER JOIN Buyers AS d
ON d.buyer_id = b.buyer_id
INNER JOIN Produce AS p
ON p.prod_id = a.prod_id;

USE Northwind;

SELECT (FirstName + ' ' + LastName) AS name, city, PostalCode, 'P'
FROM Employees
UNION SELECT CompanyName, City, PostalCode, 'K'
FROM Customers;

USE library;

SELECT a.member_no, firstname + ' ' + lastname AS name, COUNT(*) AS NumOfChildren
FROM juvenile AS j
INNER JOIN adult AS a
ON j.adult_member_no = a.member_no
INNER JOIN member AS m
ON m.member_no = a.member_no
WHERE a.state = 'AZ'
GROUP BY a.member_no, firstname + ' ' + lastname
HAVING COUNT(*) > 2;

SELECT a.member_no, firstname + ' ' + lastname AS name, COUNT(*) AS NumOfChildren
FROM juvenile AS j
INNER JOIN adult AS a
ON j.adult_member_no = a.member_no
INNER JOIN member AS m
ON m.member_no = a.member_no
WHERE a.state = 'AZ'
GROUP BY a.member_no, firstname + ' ' + lastname
HAVING COUNT(*) > 2
UNION SELECT  a.member_no, firstname + ' ' + lastname AS name, COUNT(*) AS NumOfChildren
FROM juvenile AS j
INNER JOIN adult AS a
ON j.adult_member_no = a.member_no
INNER JOIN member AS m
ON m.member_no = a.member_no
WHERE a.state = 'CA'
GROUP BY a.member_no, firstname + ' ' + lastname
HAVING COUNT(*) > 3;
