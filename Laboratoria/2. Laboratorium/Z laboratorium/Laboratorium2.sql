USE Northwind;


/* Examples 1 */

SELECT TOP 5 orderid, productid, quantity FROM [Order Details] ORDER BY quantity DESC;

SELECT TOP 5 WITH TIES orderid, productid, quantity FROM [order details] ORDER BY quantity DESC;

SELECT COUNT(*) FROM employees; --9

SELECT COUNT(reportsto) FROM employees; --8



/* Exercise 1 */

-- 1
SELECT COUNT(ProductID) FROM Products WHERE UnitPrice BETWEEN 10 AND 20;
-- 2
SELECT MAX(UnitPrice) AS "Max unit price" FROM Products WHERE UnitPrice < 20;
-- 3
SELECT MAX(UnitPrice) AS "Max unit price", MIN(UnitPrice) AS "Min unit price", AVG(UnitPrice) AS "Average unit price" 
FROM Products 
WHERE QuantityPerUnit LIKE '%bottle%';
-- 4
SELECT * FROM Products WHERE UnitPrice > (SELECT AVG(UnitPrice) FROM Products);
-- 5
-- (see also: https://stackoverflow.com/questions/582797/should-you-choose-the-money-or-decimalx-y-datatypes-in-sql-server)
-- CONVERT() function is useful if we want to remove too large floating point
-- which might be a result of precision loss while adding numbers (e.g. 0.1 + 0.1)
SELECT SUM(CONVERT(MONEY, UnitPrice * Quantity * (1 - Discount))) AS Total
FROM [Order Details]
WHERE OrderID = 10250;



/* Examples 2 */

SELECT productid, orderid ,quantity FROM orderhist;

SELECT productid, SUM(quantity) AS total_quantity FROM orderhist GROUP BY productid;

SELECT productid, SUM(quantity) AS total_quantity FROM orderhist WHERE productid = 2 GROUP BY productid;

SELECT productid, SUM(quantity) AS total_quantity FROM [order details] GROUP BY productid;



/* Exercise 2 */

-- 1
SELECT OrderID, MAX(UnitPrice) AS MaxPrice FROM [Order Details] GROUP BY OrderID ORDER BY MAX(UnitPrice);
-- 2
SELECT OrderID, MAX(UnitPrice) AS MaxPrice, MIN(UnitPrice) AS MinPrice FROM [Order Details] GROUP BY OrderID;
-- 3
SELECT ShipVia, COUNT(*) AS ShippedCount FROM Orders GROUP BY ShipVia;
-- 4
SELECT TOP 1 ShipVia, COUNT(*) AS ShippedIn1997
FROM Orders
WHERE YEAR(OrderDate) = 1997
GROUP BY ShipVia
ORDER BY COUNT(*) DESC;
-- or (worse)
SELECT TOP 1 ShipVia, COUNT(*) AS ShippedIn1997
FROM Orders
WHERE OrderDate LIKE '%1997%'
GROUP BY ShipVia
ORDER BY COUNT(*) DESC;
-- or (the worst)
SELECT TOP 1 ShipVia, COUNT(*) AS ShippedIn1997
FROM Orders
WHERE OrderDate >= '1997-01-01' AND OrderDate <= '1997-12-31'
GROUP BY ShipVia 
ORDER BY COUNT(*) DESC;



/* Examples 3 */

SELECT productid, orderid, quantity FROM orderhist;

SELECT productid, SUM(quantity) AS total_quantity
FROM orderhist 
GROUP BY productid 
HAVING SUM(quantity) >= 30;  -- HAVING works almost the same as WHERE but can be used on grouped elements (WHERE CAN'T)

SELECT productid, SUM(quantity) AS total_quantity FROM [order details] GROUP BY productid HAVING SUM(quantity) > 1200;



/* Exercise 3 */

-- 1
SELECT OrderID, COUNT(*) AS "Number of unique products" FROM [Order Details] GROUP BY OrderID HAVING COUNT(*) > 5;
-- 2
SELECT CustomerID, COUNT(*) AS "Number of orders in 1998", SUM(Freight) as "Total delivery cost" FROM Orders 
WHERE YEAR(ShippedDate) = 1998 
GROUP BY CustomerID 
HAVING COUNT(OrderID) > 8 
ORDER BY SUM(Freight) DESC;



/* Examples 4 */
-- Useful website for following examples: 
-- https://www.sqlpedia.pl/wielokrotne-grupowanie-grouping-sets-rollup-cube/
-- https://youtu.be/q2_VrlZcepM

SELECT productid, orderid, SUM(quantity) AS total_quantity FROM orderhist 
GROUP BY productid, orderid WITH ROLLUP
ORDER BY productid, orderid;

-- instead of using ROLLUP we can obtain similar result in 3 separate queries as follows
SELECT null, null, SUM(quantity) AS total_quantity FROM orderhist
UNION SELECT productid, null, SUM(quantity) FROM orderhist GROUP BY productid
UNION SELECT productid, orderid, quantity FROM orderhist

-- the following example works the same but we wrote ROLLUP similarly to how we write functions
SELECT productid, orderid, SUM(quantity) AS total_quantity FROM orderhist 
GROUP BY ROLLUP(productid, orderid)
ORDER BY productid, orderid;

-- important explanation in this video: https://www.youtube.com/watch?v=q2_VrlZcepM (for 2 following queries)
SELECT orderid, productid, SUM(quantity) AS total_quantity FROM [order details] 
WHERE orderid < 10250
GROUP BY ROLLUP(orderid, productid) 
ORDER BY orderid, productid;

-- more information about using CUBE with GROUP BY: https://youtu.be/bbkybT9qnTg?t=101
SELECT productid, orderid, SUM(quantity) AS total_quantity 
FROM orderhist 
GROUP BY productid, orderid WITH CUBE 
ORDER BY productid, orderid;

SELECT productid, GROUPING(productid), orderid, GROUPING(orderid), SUM(quantity) AS total_quantity
FROM orderhist
GROUP BY productid, orderid WITH CUBE
ORDER BY productid, orderid;

SELECT orderid, GROUPING(orderid), productid, GROUPING(productid), SUM(quantity) AS total_quantity
FROM [order details]
WHERE orderid < 10250
GROUP BY orderid, productid WITH CUBE
ORDER BY orderid, productid;
