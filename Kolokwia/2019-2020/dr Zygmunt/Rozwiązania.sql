/*
 * Poniedziałek grupa 9:35
 */

-- 1
USE library;

SELECT m.member_no,
       CONCAT(a.street, ', ', a.city, ' ', a.state, ' ', a.zip) AS Address,
       'Adult',
       YEAR(l.out_date) AS Year,
       MONTH(l.out_date) AS Month,
       COUNT(title_no) AS BorrowedCount
FROM member AS m
INNER JOIN adult AS a
ON m.member_no = a.member_no
INNER JOIN (
    SELECT member_no, out_date, title_no
    FROM loanhist
    UNION SELECT member_no, out_date, title_no
    FROM loan
) AS l
ON l.member_no = m.member_no
GROUP BY m.member_no, YEAR(l.out_date), MONTH(l.out_date), a.street, a.city, a.state, a.zip,title_no
UNION SELECT m.member_no,
       CONCAT(a.street, ', ', a.city, ' ', a.state, ' ', a.zip) AS Address,
       'Juvenile',
       YEAR(l.out_date) AS Year,
       MONTH(l.out_date) AS Month,
       COUNT(title_no) AS BorrowedCount
FROM member AS m
INNER JOIN juvenile AS j
ON j.member_no = m.member_no
INNER JOIN adult AS a
ON j.adult_member_no = a.member_no
INNER JOIN (
    SELECT member_no, out_date, title_no
    FROM loanhist
    UNION SELECT member_no, out_date, title_no
    FROM loan
) AS l
ON l.member_no = m.member_no
GROUP BY m.member_no, YEAR(l.out_date), MONTH(l.out_date), a.street, a.city, a.state, a.zip,title_no
ORDER BY 1, 4, 5;


-- 2
USE Northwind;

SELECT OrderID
FROM ORDERS AS o
WHERE Freight > (
    SELECT AVG(Freight)
    FROM Orders
    WHERE YEAR(ShippedDate) = YEAR(o.ShippedDate)
);

-- or
select o.OrderID
from Orders o
inner join Orders o2 on year(o.ShippedDate) = year(o2.ShippedDate)
group by o.OrderID
having avg(o.Freight) > avg(o2.Freight);

-- 3
USE Northwind;

SELECT CustomerID
FROM Customers
WHERE CustomerID NOT IN (
    SELECT CustomerID
    FROM Orders
    WHERE OrderID IN (
        SELECT OrderID
        FROM [Order Details]
        WHERE ProductID IN (
            SELECT ProductID
            FROM Products
            WHERE CategoryID = (
                SELECT CategoryID
                FROM Categories
                WHERE CategoryName = 'Seafood'
            )
        )
    )
)
ORDER BY 1;

SELECT CustomerID
FROM Customers AS c
WHERE NOT EXISTS(
    SELECT *
    FROM Orders AS o
    WHERE c.CustomerID = o.CustomerID AND EXISTS(
        SELECT *
        FROM [Order Details] AS [O D]
        WHERE [O D].OrderID = o.OrderID AND EXISTS(
            SELECT *
            FROM Products AS p
            WHERE p.ProductID = [O D].ProductID AND EXISTS(
                SELECT *
                FROM Categories AS c
                WHERE c.CategoryID = p.CategoryID AND c.CategoryName = 'Seafood'
            )
        )
    )
)
ORDER BY 1;

SELECT Customers.CustomerID
FROM Customers
LEFT OUTER JOIN Orders O on Customers.CustomerID = O.CustomerID
LEFT OUTER JOIN [Order Details] [O D] on O.OrderID = [O D].OrderID
LEFT OUTER JOIN Products P on [O D].ProductID = P.ProductID
LEFT OUTER JOIN Categories C on P.CategoryID = C.CategoryID AND C.CategoryName = 'Seafood'
GROUP BY Customers.CustomerID
HAVING COUNT(C.CategoryID) = 0
ORDER BY 1;


-- 4
USE Northwind;

-- SELECT CU.CustomerID, C.CategoryID, COUNT(O.OrderID) AS Count
-- FROM Customers AS CU
-- INNER JOIN Orders O on CU.CustomerID = O.CustomerID
-- INNER JOIN [Order Details] [O D] on O.OrderID = [O D].OrderID
-- INNER JOIN Products P on [O D].ProductID = P.ProductID
-- INNER JOIN Categories C on P.CategoryID = C.CategoryID
-- WHERE CU.CustomerID = 'BLAUS'
-- GROUP BY CU.CustomerID, C.CategoryID
-- ORDER BY 3 DESC

-- TODO (DRUGA WERSJA) !!!
SELECT CustomerID, (
    SELECT TOP 1 C.CategoryID
    FROM Customers AS CU
    INNER JOIN Orders O on CU.CustomerID = O.CustomerID
    INNER JOIN [Order Details] [O D] on O.OrderID = [O D].OrderID
    INNER JOIN Products P on [O D].ProductID = P.ProductID
    INNER JOIN Categories C on P.CategoryID = C.CategoryID
    WHERE CUS.CustomerID = CU.CustomerID
    GROUP BY C.CategoryID
    ORDER BY COUNT(*) DESC
) AS MostPopularCategory
FROM Customers AS CUS;


/*
 * Poniedziałek grupa 12:50
 */
-- 1
USE Northwind;

SELECT CompanyName, YEAR(O.OrderDate) AS Year, MONTH(O.OrderDate) AS Month, SUM(Freight) AS FreightSum
FROM Customers AS C
INNER JOIN Orders O on C.CustomerID = O.CustomerID
GROUP BY C.CustomerID, C.CompanyName, YEAR(O.OrderDate), MONTH(O.OrderDate)
ORDER BY 1, 2, 3;

-- 2
USE library;

SELECT m.member_no,
       CONCAT(a.street, ', ', a.city, ' ', a.state, ' ', a.zip) AS Address,
       'Adult'
FROM member AS m
INNER JOIN adult AS a
ON a.member_no = m.member_no
WHERE m.member_no NOT IN (
    SELECT member_no
    FROM loan
    UNION SELECT member_no
    FROM loanhist
) UNION SELECT
       m.member_no,
       CONCAT(a.street, ', ', a.city, ' ', a.state, ' ', a.zip) AS Address,
       'Juvenile'
FROM member AS m
INNER JOIN juvenile AS j
ON m.member_no = j.member_no
INNER JOIN adult AS a
ON a.member_no = j.adult_member_no
WHERE m.member_no NOT IN (
    SELECT member_no
    FROM loan
    UNION SELECT member_no
    FROM loanhist
);

-- 3
USE Northwind;

SELECT CustomerID, (
    SELECT TOP 1 C.CategoryID
    FROM Customers AS CU
    INNER JOIN Orders O on CU.CustomerID = O.CustomerID
    INNER JOIN [Order Details] [O D] on O.OrderID = [O D].OrderID
    INNER JOIN Products P on [O D].ProductID = P.ProductID
    INNER JOIN Categories C on P.CategoryID = C.CategoryID
    WHERE CUS.CustomerID = CU.CustomerID AND YEAR(O.OrderDate) = 1997
    GROUP BY C.CategoryID
    ORDER BY COUNT(*) DESC
) AS MostPopularCategory
FROM Customers AS CUS;


-- 4
USE library;

SELECT firstname,
       lastname, (
            SELECT COUNT(title_no)
            FROM loan AS l
            WHERE l.member_no = p.member_no
        ) + (
            SELECT COUNT(title_no)
            FROM loanhist AS lh
            WHERE lh.member_no = p.member_no
        )  + (
            SELECT COUNT(title_no)
            FROM loan AS l
            INNER JOIN juvenile AS j
            ON j.member_no = l.member_no
            INNER JOIN adult AS a2
            ON a2.member_no = j.adult_member_no
            WHERE a2.member_no = p.member_no
        ) + (
            SELECT COUNT(title_no)
            FROM loanhist AS lh
            INNER JOIN juvenile AS j
            ON j.member_no = lh.member_no
            INNER JOIN adult AS a2
            ON a2.member_no = j.adult_member_no
            WHERE a2.member_no = p.member_no
        ) AS TotalBorrowed,
       state
FROM (
    SELECT DISTINCT firstname, lastname, state, a.member_no
    FROM juvenile AS j
    INNER JOIN adult AS a
    ON j.adult_member_no = a.member_no
    INNER JOIN member AS m
    ON m.member_no = a.member_no
    WHERE a.state = 'AZ'
    GROUP BY a.member_no, lastname, state, firstname
    HAVING COUNT(*) > 2
    UNION SELECT DISTINCT firstname, lastname, state, a.member_no
    FROM juvenile AS j
    INNER JOIN adult AS a
    ON j.adult_member_no = a.member_no
    INNER JOIN member AS m
    ON m.member_no = a.member_no
    WHERE a.state = 'CA'
    GROUP BY a.member_no, lastname, state, firstname
    HAVING COUNT(*) > 3
 ) AS p


/*
 * Czwartek 11:15
 */
-- 1
USE library;

select top 1 author, count(*)
from title as t
inner join loanhist l on t.title_no = l.title_no
inner join member m on l.member_no = m.member_no
inner join juvenile j on m.member_no = j.member_no
where YEAR(l.out_date) = 2001
group by author
order by count(*) desc;

-- 2
select jm.firstname, jm.lastname, a.street, a.city, a.street, a.zip, am.firstname, am.lastname, (
    select count(*)
    from loanhist as lh
    where year(in_date) = 2001 and lh.member_no in (am.member_no, jm.member_no)
)
from juvenile as j
inner join member jm on jm.member_no = j.member_no
inner join adult a on j.adult_member_no = a.member_no
inner join member am on am.member_no = a.member_no

-- 3
use Northwind;

select distinct ca.CategoryID, ca.CategoryName
from categories as ca
inner join Products as p
on p.CategoryID = p.CategoryID
inner join [Order Details] as [O D]
on [O D].ProductID = p.ProductID
inner join Orders as o
on o.OrderID = [O D].OrderID
inner join Shippers as s
on s.ShipperID = o.ShipVia
where year(o.ShippedDate) = 1997 and month(o.ShippedDate) = 12 and s.CompanyName = 'United Package'


-- 4
use Northwind;

select cu.CustomerID, c.CategoryName
from Customers as cu
inner join Orders as o
on o.CustomerID = cu.CustomerID
inner join [Order Details] [O D] on o.OrderID = [O D].OrderID
inner join Products P on P.ProductID = [O D].ProductID
inner join Categories as c on c.CategoryID = p.CategoryID
where year(o.OrderDate) = 1997 and month(o.OrderDate) = 3
group by cu.CustomerID, c.CategoryID, c.CategoryName
having count(c.CategoryID) = 1


/*
 * Czwartek 12:50
 */
-- 1
use library;

select jm.member_no, jm.firstname, jm.lastname, a.street, a.city, a.state, a.zip
from juvenile as j
inner join member as jm on jm.member_no = j.member_no
inner join adult a on j.adult_member_no = a.member_no
left outer join loanhist lh on jm.member_no = lh.member_no and year(lh.out_date) = 2001 and month(lh.out_date) = 7 and title_no in (
    select title_no from title where author = 'Jane Austen'
)
where lh.member_no is null;

-- select month(out_date) from loanhist where title_no in (
--     select title_no from title where author = 'Jane Austen'
-- ) and year(out_date) = 2001 order by 1;


-- 2
use Northwind;

select c.CategoryID, month(o.OrderDate), round(sum(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2)
from [Order Details] as od
inner join Orders O on od.OrderID = O.OrderID
inner join Products P on P.ProductID = od.ProductID
inner join Categories C on C.CategoryID = P.CategoryID
where year(o.OrderDate) = 1997
group by c.CategoryID, month(o.OrderDate)
order by sum(od.UnitPrice*od.Quantity*(1-od.discount)) desc;


-- 3
use Northwind;

select e.EmployeeID,
       e.FirstName,
       e.LastName, (
            select top 1 s.SupplierID
            from Employees as e1
            inner join orders as o
            on o.EmployeeID = e1.EmployeeID
            inner join [Order Details] as od
            on od.OrderID = o.OrderID
            inner join products as p
            on p.ProductID = od.ProductID
            inner join suppliers as s
            on s.SupplierID = p.SupplierID
            where e1.EmployeeID = e.employeeID
            group by s.SupplierID
            order by count(s.SupplierID) desc
        )
from Employees as e
where not exists(
    select *
    from Employees as e2
    where e2.ReportsTo = e.EmployeeID
)


-- 4 (Ponieważ baza danych jest niezbyt dobrze zrobiona, każdy tytuł został sumarycznie wypożyczony tyle samo razy,
-- więc nie istnieje książka, która byłaby wypożyczona więcej razy od pozostałych)
use library;

select title_no, title
from title as t
where (
    select count(title_no)
    from loan as l
    where l.title_no = t.title_no
) + (
    select count(title_no)
    from loanhist as lh
    where lh.title_no = t.title_no
) > ((
    select count(l.title_no)
    from loan as l
    inner join title as t2
    on t2.title_no = l.title_no
    where t2.author = t.author
) + (
    select count(lh.title_no)
    from loanhist as lh
    inner join title as t2
    on t2.title_no = lh.title_no
    where t2.author = t.author
)) / (
    select count(title_no)
    from title as t2
    where t2.author = t.author
)
