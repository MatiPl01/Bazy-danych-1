USE Northwind;

-- DO DOMU CAŁY ZESTAW

-- 1
SELECT DISTINCT c.CompanyName, c.Phone
FROM Customers AS c
WHERE c.CustomerID IN (SELECT o.CustomerID
    FROM Orders AS o
    WHERE YEAR(o.ShippedDate) = 1997 and o.ShipVia = (SELECT s.ShipperID
        FROM Shippers AS s
        WHERE s.CompanyName = 'United Package'));

-- 2
SELECT DISTINCT cu.CompanyName, cu.Phone
FROM Customers AS cu
WHERE cu.CustomerID IN (SELECT o.CustomerID
    FROM Orders AS o
    WHERE o.OrderID IN (SELECT od.OrderID
        FROM [Order Details] AS od
        WHERE od.ProductID IN (SELECT p.ProductID
            FROM Products AS p
            WHERE p.CategoryID = (SELECT c.CategoryID
                FROM Categories AS c
                WHERE c.CategoryName = 'Confections'))));

-- 3

-- EX 2
-- 1
SELECT DISTINCT ProductID, Quantity
FROM [Order Details] AS od1
WHERE Quantity = (SELECT MAX(Quantity)
    FROM [Order Details] AS od2
    WHERE od2.ProductID = od1.ProductID);

-- 2
SELECT DISTINCT ProductID
FROM Products
WHERE UnitPrice < (SELECT AVG(UnitPrice)
    FROM Products);

-- 3
SELECT DISTINCT ProductID
FROM Products AS p1
WHERE UnitPrice < (SELECT AVG(UnitPrice)
    FROM Products AS p2
    WHERE p2.CategoryID = p1.CategoryID);

-- Ex 3
-- (do domu bez podzapytania - iloczyn kartezjański w 1. przykładzie)
-- Jak sięuda bez iloczynu kartezjańskiego, to można pokazać na +
-- 1
SELECT ProductName,
       UnitPrice,
       (SELECT AVG(UnitPrice) FROM Products) AS AveragePrice,
       UnitPrice - (SELECT AVG(UnitPrice) FROM Products)  AS PriceDifference
FROM Products;

-- 2
SELECT (SELECT CategoryName FROM Categories AS c WHERE c.CategoryID = p1.CategoryID) AS CategoryName,
       p1.ProductName,
       p1.UnitPrice,
       (SELECT AVG(UnitPrice) FROM Products AS p2 WHERE p2.CategoryID = p1.categoryID) as AverageCategoryPrice,
        p1.UnitPrice - (SELECT AVG(UnitPrice) FROM Products AS p2 WHERE p2.CategoryID = p1.categoryID) AS PriceDifference
FROM Products AS p1;

-- Ex 4
-- 1 (??? NIE MA TEKIEGO ZAMÓWIENIA)
SELECT SUM(UnitPrice * Quantity * (1 - Discount))
FROM [Order Details]
WHERE OrderID = 1025;

SELECT * FROM Orders WHERE OrderID = 1025;

-- 2
SELECT o.OrderID,
       (SELECT SUM(UnitPrice * Quantity * (1 - Discount)) + o.Freight
        FROM [Order Details]
        WHERE OrderID = o.OrderID) AS TotalPrice
FROM Orders AS o;


-- 3
SELECT
