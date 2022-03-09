USE Northwind;


/* Exercise 1 */
-- 1
SELECT ContactName, Address FROM Customers;
-- 2
SELECT LastName, HomePhone FROM Employees;
-- 3
SELECT ProductName, UnitPrice FROM Products;
-- 4
SELECT CategoryName, Description FROM Categories;
-- 5
SELECT CompanyName, HomePage FROM Suppliers;



/* Exercise 2 */
-- 1
SELECT CompanyName, Address FROM Customers WHERE City='London';
-- 2
SELECT CompanyName, Address FROM Customers WHERE Country='France' OR Country='Spain';
-- 3
SELECT ProductName, UnitPrice FROM Products WHERE UnitPrice <= 30 AND UnitPrice >= 20;
-- 4
SELECT ProductName, UnitPrice FROM Products
WHERE CategoryID=(SELECT CategoryID FROM Categories WHERE CategoryName LIKE '%meat%');
-- 5
SELECT ProductName, UnitsInStock FROM Products
WHERE SupplierID=(SELECT SupplierID FROM Suppliers WHERE CompanyName='Tokyo Traders');
-- 6
SELECT ProductName FROM Products WHERE UnitsInStock=0;



/* Exercise 3 */
-- 1
SELECT * FROM Products WHERE QuantityPerUnit LIKE '%bottle%';
-- 2
SELECT title FROM Employees WHERE LastName LIKE '[B-L]%';
-- 3
SELECT title FROM Employees WHERE LastName LIKE '[BL]%';
-- 4
SELECT CategoryName FROM Categories WHERE Description LIKE '%,%';
-- 5
SELECT * FROM Customers WHERE CompanyName LIKE '%Store%';



/* Exercise 4 */
SELECT OrderID, OrderDate, CustomerID
FROM Orders
WHERE (ShippedDate IS NULL OR ShippedDate > GETDATE()) AND ShipCountry='Argentina';



/* Exercise 5 */
-- 1
SELECT CompanyName, Country FROM Customers ORDER BY Country, CompanyName;
-- 2
SELECT CategoryID, ProductName, UnitPrice FROM Products ORDER BY CategoryID, UnitPrice DESC;
-- 3
SELECT CompanyName, Country FROM Customers
WHERE Country IN ('UK', 'Italy') ORDER BY Country, CompanyName;



/* Examples */
SELECT OrderID, CustomerID FROM Orders WHERE OrderDate < '1996-08-01';

SELECT * FROM Employees WHERE Country='USA';

SELECT ProductName, UnitPrice FROM Products WHERE UnitPrice BETWEEN 10 AND 20;

SELECT ProductName, UnitPrice FROM Products WHERE UnitPrice NOT BETWEEN 10 AND 20;

SELECT COUNT(*) FROM Suppliers WHERE Fax IS NULL; --16

SELECT COUNT(*) FROM Suppliers WHERE Fax IS NOT NULL; --13

SELECT ProductID, ProductName, UnitPrice
FROM Products
ORDER BY UnitPrice;

SELECT ProductID, ProductName, CategoryID, UnitPrice
FROM Products
ORDER BY CategoryID, UnitPrice DESC;

-- SELECT <STH> AS <STH> - można pominąć AS, ale jest wtedy mniej czytelnie

SELECT firstName + ' ' + lastName as "Imię i nazwisko" FROM Employees;
