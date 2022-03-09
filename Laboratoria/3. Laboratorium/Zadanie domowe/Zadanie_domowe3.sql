USE Northwind;

/*
 * Exercise 1
 */
-- 1 (I don't use now CONVERT function with MONEY parameter, because it is not precise and leaves 4 floating
-- point digits)
SELECT OrderID, CAST(CEILING(SUM(UnitPrice * Quantity * (1 - Discount)) * 100) / 100 AS DECIMAL(10, 2)) AS Total
FROM [Order Details]
GROUP BY OrderID
ORDER BY 2 DESC;

-- 2
SELECT TOP 10 OrderID, CAST(CEILING(SUM(UnitPrice * Quantity * (1 - Discount)) * 100) / 100 AS DECIMAL(10, 2)) AS Total
FROM [Order Details]
GROUP BY OrderID
ORDER BY 2 DESC;

/*
 * Exercise 2
 */
-- 1
SELECT ProductID, SUM(Quantity) AS TotalQuantity
FROM [Order Details]
WHERE ProductID < 3
GROUP BY ProductID;

-- 2
SELECT ProductID, SUM(Quantity) AS TotalQuantity
FROM [Order Details]
GROUP BY ProductID;

-- 3
SELECT OrderID, CAST(CEILING(SUM(UnitPrice * Quantity * (1 - Discount)) * 100) / 100 AS DECIMAL(10, 2)) AS Total
FROM [Order Details]
GROUP BY OrderID
HAVING SUM(Quantity) > 250;

/*
 * Exercise 3
 */
-- 1
SELECT EmployeeID, COUNT(OrderID) AS OrdersCount
FROM ORDERS
GROUP BY EmployeeID;

-- 2 (I don't understand if I should show an average freight or a sum of freight or something else so I picked an average)
SELECT ShipVia, CAST(CEILING(AVG(Freight) * 100) / 100 AS DECIMAL(10, 2)) AS AverageFreight
FROM Orders
GROUP BY ShipVia
ORDER BY ShipVia;

-- 3 (I don't understand if I should show an average freight or a sum of freight or something else so I picked an average)
SELECT ShipVia, CAST(CEILING(AVG(Freight) * 100) / 100 AS DECIMAL(10, 2)) AS "Average Freight in 1996-1997"
FROM Orders
WHERE YEAR(ShippedDate) IN (1996, 1997)
GROUP BY ShipVia
ORDER BY ShipVia;

/*
 * Exercise 4
 */
-- 1
SELECT EmployeeID, YEAR(OrderDate) AS Year, MONTH(OrderDate) AS Month, COUNT(*) AS OrdersCount
FROM Orders
GROUP BY EmployeeID, YEAR(OrderDate), MONTH(OrderDate)
ORDER BY 1, 2, 3;

-- 2
SELECT CategoryID, MIN(UnitPrice), MAX(UnitPrice)
FROM Products
GROUP BY CategoryID;
