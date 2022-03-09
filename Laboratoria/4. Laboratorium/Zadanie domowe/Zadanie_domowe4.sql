/*
 * Exercise 1
 */
USE Northwind;

-- 1
SELECT o.OrderID, SUM(Quantity) AS TotalQuantity, CompanyName
FROM Orders AS o
INNER JOIN [Order Details] AS od
ON o.OrderID = od.OrderID
INNER JOIN Customers AS c
ON c.CustomerID = o.CustomerID
GROUP BY o.OrderID, CompanyName;

-- 2
SELECT o.OrderID, SUM(Quantity) AS TotalQuantity, CompanyName
FROM Orders AS o
INNER JOIN [Order Details] AS od
ON o.OrderID = od.OrderID
INNER JOIN Customers AS c
ON c.CustomerID = o.CustomerID
GROUP BY o.OrderID, CompanyName
HAVING SUM(Quantity) > 250;

-- 3
SELECT o.OrderID,
       CAST(CEILING(SUM(UnitPrice * Quantity * (1 - Discount)) * 100) / 100 AS DECIMAL(10, 2)) AS TotalAmount,
       CompanyName
FROM Orders AS o
INNER JOIN [Order Details] AS od
ON o.OrderID = od.OrderID
INNER JOIN Customers AS c
ON c.CustomerID = o.CustomerID
GROUP BY o.OrderID, CompanyName;
-- or (different amount formatting)
SELECT o.OrderID, CONVERT(MONEY, SUM(UnitPrice * Quantity * (1 - Discount))) AS TotalAmount, CompanyName
FROM Orders AS o
INNER JOIN [Order Details] AS od
ON o.OrderID = od.OrderID
INNER JOIN Customers AS c
ON c.CustomerID = o.CustomerID
GROUP BY o.OrderID, CompanyName;

-- 4
SELECT o.OrderID,
       CAST(CEILING(SUM(UnitPrice * Quantity * (1 - Discount)) * 100) / 100 AS DECIMAL(10, 2)) AS TotalAmount,
       CompanyName
FROM Orders AS o
INNER JOIN [Order Details] AS od
ON o.OrderID = od.OrderID
INNER JOIN Customers AS c
ON c.CustomerID = o.CustomerID
GROUP BY o.OrderID, CompanyName
HAVING SUM(Quantity) > 250;
-- or (different amount formatting)
SELECT o.OrderID, CONVERT(MONEY, SUM(UnitPrice * Quantity * (1 - Discount))) AS TotalAmount, CompanyName
FROM Orders AS o
INNER JOIN [Order Details] AS od
ON o.OrderID = od.OrderID
INNER JOIN Customers AS c
ON c.CustomerID = o.CustomerID
GROUP BY o.OrderID, CompanyName
HAVING SUM(Quantity) > 250;

-- 5
SELECT o.OrderID,
       CAST(CEILING(SUM(UnitPrice * Quantity * (1 - Discount)) * 100) / 100 AS DECIMAL(10, 2)) AS TotalAmount,
       CompanyName,
       firstName + ' ' + lastname AS EmployeeName
FROM Orders AS o
INNER JOIN [Order Details] AS od
ON o.OrderID = od.OrderID
INNER JOIN Customers AS c
ON c.CustomerID = o.CustomerID
INNER JOIN Employees AS e
ON e.EmployeeID = o.EmployeeID
GROUP BY o.OrderID, CompanyName, firstName, lastname, e.EmployeeID
HAVING SUM(Quantity) > 250;
-- or (different amount formatting)
SELECT o.OrderID,
       CONVERT(MONEY, SUM(UnitPrice * Quantity * (1 - Discount))) AS TotalAmount,
       CompanyName,
       firstName + ' ' + lastname AS EmployeeName
FROM Orders AS o
INNER JOIN [Order Details] AS od
ON o.OrderID = od.OrderID
INNER JOIN Customers AS c
ON c.CustomerID = o.CustomerID
INNER JOIN Employees AS e
ON e.EmployeeID = o.EmployeeID
GROUP BY o.OrderID, CompanyName, firstName, lastname, e.EmployeeID
HAVING SUM(Quantity) > 250;


/*
 * Exercise 2
 */
-- 1
SELECT CategoryName, SUM(Quantity)
FROM Products AS p
INNER JOIN Categories AS c
ON c.CategoryID = p.CategoryID
INNER JOIN [Order Details] AS od
ON od.ProductID = p.ProductID
GROUP BY c.CategoryID, CategoryName
ORDER BY 2 DESC;

-- 2
SELECT CategoryName,
       CAST(CEILING(SUM(od.UnitPrice * Quantity * (1 - Discount)) * 100) / 100 AS DECIMAL(10, 2)) AS TotalAmount
FROM Products AS p
INNER JOIN Categories AS c
ON c.CategoryID = p.CategoryID
INNER JOIN [Order Details] AS od
ON od.ProductID = p.ProductID
GROUP BY c.CategoryID, CategoryName;
-- or (different amount formatting)
SELECT CategoryName, CONVERT(MONEY, SUM(od.UnitPrice * Quantity * (1 - Discount))) AS TotalAmount
FROM Products AS p
INNER JOIN Categories AS c
ON c.CategoryID = p.CategoryID
INNER JOIN [Order Details] AS od
ON od.ProductID = p.ProductID
GROUP BY c.CategoryID, CategoryName;

-- 3 a)
SELECT CategoryName,
       CAST(CEILING(SUM(od.UnitPrice * Quantity * (1 - Discount)) * 100) / 100 AS DECIMAL(10, 2)) AS TotalAmount
FROM Products AS p
INNER JOIN Categories AS c
ON c.CategoryID = p.CategoryID
INNER JOIN [Order Details] AS od
ON od.ProductID = p.ProductID
GROUP BY c.CategoryID, CategoryName
ORDER BY 2 DESC;
-- or (different amount formatting)
SELECT CategoryName, CONVERT(MONEY, SUM(od.UnitPrice * Quantity * (1 - Discount))) AS TotalAmount
FROM Products AS p
INNER JOIN Categories AS c
ON c.CategoryID = p.CategoryID
INNER JOIN [Order Details] AS od
ON od.ProductID = p.ProductID
GROUP BY c.CategoryID, CategoryName
ORDER BY 2 DESC;

-- 3 b)
SELECT CategoryName,
       CAST(CEILING(SUM(od.UnitPrice * Quantity * (1 - Discount)) * 100) / 100 AS DECIMAL(10, 2)) AS TotalAmount
FROM Products AS p
INNER JOIN Categories AS c
ON c.CategoryID = p.CategoryID
INNER JOIN [Order Details] AS od
ON od.ProductID = p.ProductID
GROUP BY c.CategoryID, CategoryName
ORDER BY SUM(Quantity) DESC;
-- or (different amount formatting)
SELECT CategoryName, CONVERT(MONEY, SUM(od.UnitPrice * Quantity * (1 - Discount))) AS TotalAmount
FROM Products AS p
INNER JOIN Categories AS c
ON c.CategoryID = p.CategoryID
INNER JOIN [Order Details] AS od
ON od.ProductID = p.ProductID
GROUP BY c.CategoryID, CategoryName
ORDER BY SUM(Quantity) DESC;

-- 4
SELECT o.OrderID,
       CAST(CEILING((SUM(od.UnitPrice * Quantity * (1 - Discount)) + Freight) * 100) / 100 AS DECIMAL(10, 2)) AS TotalAmount
FROM Orders AS o
INNER JOIN [Order Details] AS od
ON o.OrderID = od.OrderID
GROUP BY o.OrderID, Freight;
-- or (different amount formatting)
SELECT o.OrderID,
       CONVERT(MONEY, SUM(od.UnitPrice * Quantity * (1 - Discount)) + Freight)  AS TotalAmount
FROM Orders AS o
INNER JOIN [Order Details] AS od
ON o.OrderID = od.OrderID
GROUP BY o.OrderID, Freight;


/*
 * Exercise 3
 */
-- 1
SELECT CompanyName, COUNT(OrderID)
FROM Shippers AS s
INNER JOIN Orders AS o
ON s.ShipperID = o.ShipVia
WHERE YEAR(ShippedDate) = 1997
GROUP BY s.ShipperID, CompanyName;

-- 2
SELECT TOP 1 CompanyName
FROM Shippers AS s
INNER JOIN Orders AS o
ON s.ShipperID = o.ShipVia
WHERE YEAR(ShippedDate) = 1997
GROUP BY s.ShipperID, CompanyName
ORDER BY COUNT(OrderID) DESC;

-- 3
SELECT FirstName + ' ' + LastName AS name,
       CAST(CEILING(SUM(od.UnitPrice * Quantity * (1 - Discount)) * 100) / 100 AS DECIMAL(10, 2)) AS TotalAmount
FROM Employees AS e
INNER JOIN Orders AS o
ON e.EmployeeID = o.EmployeeID
INNER JOIN [Order Details] AS od
ON od.OrderID = o.OrderID
GROUP BY e.EmployeeID, FirstName, LastName;
-- or (different amount formatting)
SELECT FirstName + ' ' + LastName AS name,
       CONVERT(MONEY, SUM(od.UnitPrice * Quantity * (1 - Discount))) AS TotalAmount
FROM Employees AS e
INNER JOIN Orders AS o
ON e.EmployeeID = o.EmployeeID
INNER JOIN [Order Details] AS od
ON od.OrderID = o.OrderID
GROUP BY e.EmployeeID, FirstName, LastName;

-- 4
SELECT TOP 1 FirstName + ' ' + LastName AS name
FROM Employees AS e
INNER JOIN Orders AS o
ON o.EmployeeID = e.EmployeeID
WHERE YEAR(OrderDate) = 1997
GROUP BY e.EmployeeID, FirstName, LastName
ORDER BY COUNT(OrderID) DESC;

-- 5
SELECT TOP 1 FirstName + ' ' + LastName AS name
FROM Employees AS e
INNER JOIN Orders AS o
ON o.EmployeeID = e.EmployeeID
INNER JOIN [Order Details] AS od
ON od.OrderID = o.OrderID
WHERE YEAR(OrderDate) = 1997
GROUP BY e.EmployeeID, FirstName, LastName
ORDER BY SUM(UnitPrice * Quantity * (1 - Discount)) DESC;


/*
 * Exercise 4
 */
-- 1
SELECT e.EmployeeID,
       FirstName + ' ' + LastName,
       CAST(CEILING(SUM(od.UnitPrice * Quantity * (1 - Discount)) * 100) / 100 AS DECIMAL(10, 2)) AS TotalAmount
FROM Orders AS o
INNER JOIN [Order Details] AS od
ON od.OrderID = o.OrderID
INNER JOIN Employees AS e
ON e.EmployeeID = o.EmployeeID
GROUP BY e.EmployeeID, FirstName, LastName;
-- or (different amount formatting)
SELECT e.EmployeeID,
       FirstName + ' ' + LastName,
       CONVERT(MONEY, SUM(UnitPrice * Quantity * (1 - Discount))) AS TotalAmount
FROM Orders AS o
INNER JOIN [Order Details] AS od
ON od.OrderID = o.OrderID
INNER JOIN Employees AS e
ON e.EmployeeID = o.EmployeeID
GROUP BY e.EmployeeID, FirstName, LastName;

-- 1 a) !!! (grouping by 2 employees)
SELECT e1.EmployeeID,
       e1.FirstName + ' ' + e1.LastName,
       CAST(CEILING(SUM(od.UnitPrice * Quantity * (1 - Discount)) * 100) / 100 AS DECIMAL(10, 2)) AS TotalAmount
FROM Orders AS o
INNER JOIN [Order Details] AS od
ON od.OrderID = o.OrderID
INNER JOIN Employees AS e1
ON e1.EmployeeID = o.EmployeeID
INNER JOIN Employees AS e2       -- Adding INNER JOIN is enough because we will get only rows of data for which
ON e2.ReportsTo = e1.EmployeeID  -- e2 reports to e1, so e1 must have subordinates (JOIN excludes nulls - employees
GROUP BY e1.EmployeeID, e1.FirstName, e1.LastName, e2.EmployeeID;   -- with no subordinates)
-- or (different amount formatting)
SELECT e1.EmployeeID,
       e1.FirstName + ' ' + e1.LastName,
       CONVERT(MONEY, SUM(UnitPrice * Quantity * (1 - Discount))) AS TotalAmount
FROM Orders AS o
INNER JOIN [Order Details] AS od
ON od.OrderID = o.OrderID
INNER JOIN Employees AS e1
ON e1.EmployeeID = o.EmployeeID
INNER JOIN Employees AS e2       -- Adding INNER JOIN is enough because we will get only rows of data for which
ON e2.ReportsTo = e1.EmployeeID  -- e2 reports to e1, so e1 must have subordinates (JOIN excludes nulls - employees
GROUP BY e1.EmployeeID, e1.FirstName, e1.LastName;   -- with no subordinates)

-- 1 b)
SELECT e1.EmployeeID,
       e1.FirstName + ' ' + e1.LastName,
       CAST(CEILING(SUM(od.UnitPrice * Quantity * (1 - Discount)) * 100) / 100 AS DECIMAL(10, 2)) AS TotalAmount
FROM Orders AS o
INNER JOIN [Order Details] AS od
ON od.OrderID = o.OrderID
INNER JOIN Employees AS e1
ON e1.EmployeeID = o.EmployeeID
LEFT OUTER JOIN Employees AS e2
ON e2.ReportsTo = e1.EmployeeID
WHERE e2.EmployeeID IS NULL
GROUP BY e1.EmployeeID, e1.FirstName, e1.LastName;
-- or (different amount formatting)
SELECT e1.EmployeeID,
       e1.FirstName + ' ' + e1.LastName,
       CONVERT(MONEY, SUM(UnitPrice * Quantity * (1 - Discount))) AS TotalAmount
FROM Orders AS o
INNER JOIN [Order Details] AS od
ON od.OrderID = o.OrderID
INNER JOIN Employees AS e1
ON e1.EmployeeID = o.EmployeeID
LEFT OUTER JOIN Employees AS e2
ON e2.ReportsTo = e1.EmployeeID
WHERE e2.EmployeeID IS NULL
GROUP BY e1.EmployeeID, e1.FirstName, e1.LastName;
