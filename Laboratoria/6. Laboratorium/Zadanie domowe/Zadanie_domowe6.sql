/*
 * Exercise 1
 */
USE Northwind;


-- 1
SELECT DISTINCT CompanyName, Phone
FROM Customers
WHERE CustomerID IN (
    SELECT CustomerID
    FROM Orders
    WHERE YEAR(ShippedDate) = 1997 AND ShipVia = (
        SELECT ShipperID
        FROM Shippers as s
        WHERE s.CompanyName = 'United Package'
    )
);

-- or without subquery
SELECT DISTINCT c.CompanyName, c.Phone
FROM Customers AS c
INNER JOIN Orders AS o
ON o.CustomerID = c.CustomerID
INNER JOIN Shippers AS s
ON s.ShipperID = o.ShipVia
WHERE YEAR(o.ShippedDate) = 1997 AND s.CompanyName = 'United Package';


--2
SELECT DISTINCT CompanyName, Phone
FROM Customers
WHERE CustomerID IN (
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
                WHERE CategoryName = 'Confections'
            )
        )
    )
)
ORDER BY 1;

-- or without subquery
SELECT DISTINCT c.CompanyName, c.Phone
FROM Customers AS c
INNER JOIN Orders AS o
ON o.CustomerID = c.CustomerID
INNER JOIN [Order Details] AS od
ON od.OrderID = o.OrderID
INNER JOIN Products AS p
ON p.ProductID = od.ProductID
INNER JOIN Categories AS cat
ON cat.CategoryID = p.CategoryID
WHERE cat.CategoryName = 'Confections';


-- 3
SELECT DISTINCT CompanyName, Phone
FROM Customers AS c
WHERE c.CustomerID NOT IN (
    SELECT o.CustomerID
    FROM Orders AS o
    WHERE o.CustomerID = c.CustomerID AND OrderID IN (
        SELECT OrderID
        FROM [Order Details]
        WHERE ProductID IN (
            SELECT ProductID
            FROM Products
            WHERE CategoryID IN (
                SELECT CategoryID
                FROM Categories
                WHERE CategoryName = 'Confections'
            )
        )
    )
);

-- or
SELECT DISTINCT CompanyName, Phone
FROM Customers AS c
WHERE NOT EXISTS(
    SELECT *
    FROM Orders AS o
    WHERE o.CustomerID = c.CustomerID AND OrderID IN (
        SELECT OrderID
        FROM [Order Details]
        WHERE ProductID IN (
            SELECT ProductID
            FROM Products
            WHERE CategoryID IN (
                SELECT CategoryID
                FROM Categories
                WHERE CategoryName = 'Confections'
            )
        )
    )
);

-- or (worse)
SELECT DISTINCT CompanyName, Phone
FROM Customers AS c
WHERE NOT EXISTS(
    SELECT *
    FROM Orders AS o
    WHERE o.CustomerID = c.CustomerID AND EXISTS(
        SELECT *
        FROM [Order Details] AS od
        WHERE od.OrderID = o.OrderID AND EXISTS(
            SELECT *
            FROM Products AS p
            WHERE p.ProductID = od.ProductID AND EXISTS(
                SELECT *
                FROM Categories AS cat
                WHERE p.CategoryID = cat.CategoryID AND cat.CategoryName = 'Confections'
            )
        )
    )
);

-- or without subquery !!!
SELECT DISTINCT c.CompanyName, c.Phone
FROM Customers AS c
LEFT OUTER JOIN Orders AS o
ON o.CustomerID = c.CustomerID
LEFT OUTER JOIN [Order Details] AS od
ON od.OrderID = o.OrderID
LEFT OUTER JOIN Products AS p
ON p.ProductID = od.ProductID
LEFT OUTER JOIN Categories AS cat
ON cat.CategoryID = p.CategoryID AND cat.CategoryName = 'Confections' -- !!! We have to add this condition to join statement
GROUP BY c.CustomerID, c.CompanyName, c.Phone
HAVING COUNT(cat.CategoryID) = 0;



/*
 * Exercise 2
 */
-- 1
SELECT ProductID, (
    SELECT MAX(Quantity)
    FROM [Order Details] AS od
    WHERE p.ProductID = od.ProductID
)
FROM Products AS p;

-- or without subquery
SELECT p.ProductID, MAX(Quantity) AS MaxQuantity
FROM Products p
INNER JOIN [Order Details] AS od
ON od.ProductID = p.ProductID
GROUP BY p.ProductID
ORDER BY 1;


-- 2
SELECT ProductID
FROM Products
WHERE UnitPrice < (
    SELECT AVG(UnitPrice)
    FROM Products
)

-- or without subquery !!!
-- CROSS JOIN on the same table with grouping by ProductID will produce groups containing all products. That means,
-- for every ProductID by which we group, we will have separate group consisting of all products in the table. This
-- allows us to calculate the average UnitPrice for every row (every ProductID that we group by).
SELECT p1.ProductID
FROM Products AS p1
CROSS JOIN Products AS p2
GROUP BY p1.ProductID, p1.UnitPrice
HAVING p1.UnitPrice < AVG(p2.UnitPrice);


-- 3
SELECT ProductID
FROM Products AS p1
WHERE p1.UnitPrice < (
    SELECT AVG(UnitPrice)
    FROM Products AS p2
    WHERE p1.CategoryID = p2.CategoryID
);

-- or without subquery !!!
-- In this example we use INNER JOIN on the same table joining all products from the same categories.
-- The specified condition after ON keyword will join p1 product with all p2 products from the same category.
-- In the next step, we must group products by p1's ProductID in order to use an aggregate function in the
-- HAVING clause.
SELECT p1.ProductID
FROM Products AS p1
INNER JOIN Products AS p2
ON p1.CategoryID = p2.CategoryID
GROUP BY p1.ProductID, p1.UnitPrice
HAVING p1.UnitPrice < AVG(p2.UnitPrice);



/*
 * Exercise 3
 */
-- 1
SELECT ProductName,
       UnitPrice,
       (SELECT AVG(UnitPrice) FROM Products) AS AvragePrice,
       UnitPrice - (SELECT AVG(UnitPrice) FROM Products) AS PriceDifference
FROM Products

-- or without subquery
SELECT p1.ProductName, p1.UnitPrice, AVG(p2.UnitPrice), p1.UnitPrice - AVG(p2.UnitPrice)
FROM Products AS p1
CROSS JOIN Products as p2
GROUP BY p1.productID, p1.ProductName, p1.UnitPrice;

-- or without CROSS JOIN
DECLARE @avg FLOAT;
SELECT @avg = AVG(UnitPrice) FROM Products;
SELECT ProductName, UnitPrice, @avg AS AveragePrice, ROUND(UnitPrice - @avg, 4) AS PriceDifference
FROM Products;


-- 2
SELECT (
    SELECT CategoryName
    FROM Categories
    WHERE CategoryID = p.CategoryID
) AS CategoryName,
ProductName,
UnitPrice, (
    SELECT AVG(UnitPrice)
    FROM Products
    WHERE CategoryID = p.CategoryID
) AS AverageCategoryPrice,
UnitPrice - (
    SELECT AVG(p3.UnitPrice)
    FROM Products AS p3
    WHERE CategoryID = p.CategoryID
) AS PriceDifference
FROM Products AS p;

-- or without subquery
SELECT c.CategoryName,
       p1.ProductName,
       p1.UnitPrice,
       AVG(p2.UnitPrice) AS AverageCategoryPrice,
       p1.UnitPrice - AVG(p2.UnitPrice) AS PriceDifference
FROM Products AS p1
INNER JOIN Categories AS c
ON c.CategoryID = p1.CategoryID
INNER JOIN Products AS p2
ON p1.CategoryID = p2.CategoryID
GROUP BY p1.CategoryID, p1.ProductName, c.CategoryName, p1.UnitPrice;



/*
 * Exercise 4
 */
 -- 1
SELECT CAST(CEILING((SUM(UnitPrice * Quantity * (1 - Discount)) + (
    SELECT Freight
    FROM Orders
    WHERE OrderID = 10250
)) * 100) / 100 AS DECIMAL(10, 2)) AS Total
FROM [Order Details]
WHERE OrderID = 10250;

-- or without subquery
SELECT CAST(CEILING((SUM(UnitPrice * Quantity * (1 - Discount)) + Freight) * 100) / 100 AS DECIMAL(10, 2)) AS Total
FROM [Order Details] AS od
INNER JOIN Orders AS o
ON o.OrderID = od.OrderID
WHERE od.OrderID = 10250
GROUP BY od.OrderID, o.Freight;


-- 2
SELECT OrderID, (
    SELECT CAST(CEILING((SUM(UnitPrice * Quantity * (1 - Discount)) + Freight) * 100) / 100 AS DECIMAL(10, 2))
    FROM [Order Details]
    WHERE OrderID = o.OrderID
)  AS Total
FROM Orders AS o;

-- or
SELECT OrderID, CAST(CEILING((SUM(UnitPrice * Quantity * (1 - Discount)) + (
    SELECT Freight
    FROM Orders AS o
    WHERE o.OrderID = od.OrderID
)) * 100) / 100 AS DECIMAL(10, 2)) AS Total
FROM [Order Details] AS od
GROUP BY od.OrderID;

-- or without subquery
SELECT o.OrderID,
       CAST(CEILING((SUM(UnitPrice * Quantity * (1 - Discount)) + Freight) * 100) / 100 AS DECIMAL(10, 2)) AS Total
FROM Orders AS o
INNER JOIN [Order Details] AS od
ON o.OrderID = od.OrderID
GROUP BY o.OrderID, Freight;


-- 3
SELECT CompanyName, Address, City, Region, PostalCode, Country
FROM Customers
WHERE CustomerID NOT IN (
    SELECT CustomerID
    FROM Orders
    WHERE YEAR(OrderDate) = 1997
);

-- or
SELECT CompanyName, Address, City, Region, PostalCode, Country
FROM Customers AS c
WHERE NOT EXISTS(
    SELECT *
    FROM Orders AS o
    WHERE YEAR(OrderDate) = 1997 AND o.CustomerID = c.CustomerID
);

-- or without subquery
SELECT CompanyName, Address, City, Region, PostalCode, Country
FROM Customers AS c
LEFT OUTER JOIN Orders AS o
ON o.CustomerID = c.CustomerID AND YEAR(OrderDate) = 1997
WHERE OrderID IS NULL;

-- or (worse)
SELECT CompanyName, Address, City, Region, PostalCode, Country
FROM Customers AS c
LEFT OUTER JOIN Orders AS o
ON o.CustomerID = c.CustomerID AND YEAR(OrderDate) = 1997
GROUP BY c.CustomerID, CompanyName, Address, City, Region, PostalCode, Country
HAVING COUNT(o.OrderID) = 0;


-- 4
SELECT ProductID
FROM Products AS p
WHERE (
    SELECT COUNT(DISTINCT CustomerID)
    FROM Orders AS o
    WHERE OrderID IN (
        SELECT OrderID
        FROM [Order Details] AS od
        WHERE p.ProductID = od.ProductID
    )
) > 1
ORDER BY 1;

-- or without subquery
SELECT ProductID
FROM [Order Details] AS od
INNER JOIN Orders AS o
ON o.OrderID = od.OrderID
GROUP BY od.ProductID
HAVING COUNT(DISTINCT CustomerID) > 1;



/*
 * Exercise 5
 */
-- 1
SELECT FirstName,
       LastName, ROUND((
           SELECT SUM(UnitPrice * Quantity * (1 - Discount))
           FROM [Order Details]
           WHERE OrderID IN (
               SELECT OrderID
               FROM Orders AS o
               WHERE o.EmployeeID = e.EmployeeID
           )
       ) + (
            SELECT SUM(Freight)
            FROM Orders AS o
            WHERE e.EmployeeID = o.EmployeeID
       ), 2)
FROM Employees AS e;


-- 2
SELECT TOP 1 FirstName, LastName
FROM Employees AS e
ORDER BY (
    SELECT SUM(UnitPrice * Quantity * (1 - Discount))
    FROM [Order Details]
    WHERE OrderID IN (
        SELECT OrderID
        FROM Orders AS o
        WHERE e.EmployeeID = o.EmployeeID AND YEAR(ShippedDate) = 1997
    )
) + (
    SELECT SUM(Freight)
    FROM Orders AS o
    WHERE o.EmployeeID = e.EmployeeID AND YEAR(ShippedDate) = 1997
) DESC;


-- 3 a)
SELECT FirstName,
       LastName, (
           SELECT SUM(UnitPrice * Quantity * (1 - Discount))
           FROM [Order Details]
           WHERE OrderID IN (
               SELECT OrderID
               FROM Orders AS o
               WHERE o.EmployeeID = e.EmployeeID
           )
       ) + (
            SELECT SUM(Freight)
            FROM Orders AS o
            WHERE e.EmployeeID = o.EmployeeID
       )
FROM Employees AS e
WHERE EXISTS(
    SELECT *
    FROM Employees AS e2
    WHERE e2.ReportsTo = e.EmployeeID
);


-- 3 b)
SELECT FirstName,
       LastName, (
           SELECT SUM(UnitPrice * Quantity * (1 - Discount))
           FROM [Order Details]
           WHERE OrderID IN (
               SELECT OrderID
               FROM Orders AS o
               WHERE o.EmployeeID = e.EmployeeID
           )
       ) + (
            SELECT SUM(Freight)
            FROM Orders AS o
            WHERE e.EmployeeID = o.EmployeeID
       )
FROM Employees AS e
WHERE NOT EXISTS(
    SELECT *
    FROM Employees AS e2
    WHERE e2.ReportsTo = e.EmployeeID
);


-- 4 a)
SELECT FirstName,
       LastName, (
           SELECT SUM(UnitPrice * Quantity * (1 - Discount))
           FROM [Order Details]
           WHERE OrderID IN (
               SELECT OrderID
               FROM Orders AS o
               WHERE o.EmployeeID = e.EmployeeID
           )
       ) + (
            SELECT SUM(Freight)
            FROM Orders AS o
            WHERE e.EmployeeID = o.EmployeeID
       ) AS TotalValue,
       (
            SELECT MAX(ShippedDate)
            FROM Orders AS o
            WHERE o.EmployeeID = e.EmployeeID
       ) AS LastOrderDate
FROM Employees AS e
WHERE EXISTS(
    SELECT *
    FROM Employees AS e2
    WHERE e2.ReportsTo = e.EmployeeID
);

-- 4 b)
SELECT FirstName,
       LastName, (
           SELECT SUM(UnitPrice * Quantity * (1 - Discount))
           FROM [Order Details]
           WHERE OrderID IN (
               SELECT OrderID
               FROM Orders AS o
               WHERE o.EmployeeID = e.EmployeeID
           )
       ) + (
            SELECT SUM(Freight)
            FROM Orders AS o
            WHERE e.EmployeeID = o.EmployeeID
       ) AS TotalValue,
       (
            SELECT MAX(ShippedDate)
            FROM Orders AS o
            WHERE o.EmployeeID = e.EmployeeID
       ) AS LastOrderDate
FROM Employees AS e
WHERE NOT EXISTS(
    SELECT *
    FROM Employees AS e2
    WHERE e2.ReportsTo = e.EmployeeID
);
