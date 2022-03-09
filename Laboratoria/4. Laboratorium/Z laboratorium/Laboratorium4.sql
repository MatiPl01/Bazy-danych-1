USE Northwind;

-- keywords INNER and OUTER in JOINS are used only to make query cleaner and have no effect (can be omitted)

/*
 * Examples 1 (INNER JOIN / JOIN - keyword INNER can be omitted as it works the same as INNER JOIN)
 */
-- 1
SELECT ProductName, CompanyName
FROM Products
INNER JOIN Suppliers
ON Products.SupplierID = Suppliers.SupplierID;

-- 2
SELECT DISTINCT CompanyName, OrderDate
FROM Orders
INNER JOIN Customers
ON Orders.CustomerID = Customers.CustomerID
WHERE OrderDate > '1998-03-01';

/*
 * Examples 2 (LEFT OUTER JOIN / LEFT JOIN - keyword OUTER can be omitted)
 */
-- 1
SELECT CompanyName, OrderDate
FROM Customers
LEFT OUTER JOIN Orders
ON Customers.CustomerID = Orders.CustomerID;


/*
 * Exercise 1
 */
-- 1
SELECT ProductName, UnitPrice, Address
FROM Products AS p                      -- AS is not required while using aliases (also when renaming columns)
INNER JOIN Suppliers As s               -- (it can be omitted but is better to be kept as it improves readability)
ON p.SupplierID = s.SupplierID
WHERE UnitPrice BETWEEN 20 AND 30;
-- or
SELECT ProductName, UnitPrice, Address
FROM Products AS p
INNER JOIN Suppliers As s
ON p.SupplierID = s.SupplierID
WHERE UnitPrice BETWEEN 20 AND 30;

-- 2
SELECT ProductName, UnitsInStock
FROM Products AS p
INNER JOIN Suppliers AS s
ON p.SupplierID = s.SupplierID
WHERE CompanyName = 'Tokyo Traders';

-- 3
/*
This one exercise is a little bit more complicated and requires some explanation.
Firstly, we cannot use INNER JOIN (or simply JOIN which works tke same as INNER JOIN) because it displays rows
of data from joined tables only if all of them have a row with the same KEY as specified after ON keyword
(I mean only if the same value of a column specified in the join condition is apparent in both tables. If in one
of the tables has a value which doesn't show up in other tables or there is a NULL value, such rows will be rejected)

We can easily see that we should join both tables using this condition: c.CustomerID = o.CustomerID. But it isn't
enough because we are interested only in orders from 1997, so we add AND YEAR(OrderDate)=1997 to select only
orders and customers which placed orders in 1997. But we want the opposite, only customers without orders in 1997,
how we get that? We can notice that after adding AND YEAR(OrderDate)=1997 to joining condition, all our results
will be from 1997, so customers which placed no order on 1997 year won't show up. The easiest solution is to
force SQL to show all customers an the filter out only customers which have no order in 1997. To obtain this, we
must use LEFT JOIN (or LEFT OUTER JOIN - it is the same) and then, check which rows have NULL in OrderDate column.
NULL will appear in this column only if a person hasn't shown up in the table before, because had no order from
1997 but LEFT JOIN ensures that all records (rows) from the left table (a table after FROM keyword) will be showed.
*/
SELECT c.CustomerID, Address, OrderDate
FROM Customers AS c
LEFT OUTER JOIN Orders AS o
ON c.CustomerID = o.CustomerID AND YEAR(OrderDate)=1997
WHERE OrderID IS NULL;

-- 4
SELECT CompanyName, Phone
FROM Suppliers AS s
INNER JOIN Products AS p
ON s.SupplierID = p.SupplierID
WHERE ISNULL(UnitsInStock, 0) = 0;


/*
 * Exercise 2
 */
-- 1
USE library;

SELECT firstname, lastname,  birth_date
FROM member AS m
INNER JOIN juvenile AS j
ON m.member_no = j.member_no;

-- 2
SELECT DISTINCT title
FROM loan AS l
INNER JOIN title AS t
ON l.title_no = t.title_no;

-- 3
SELECT member_no, in_date, DATEDIFF(DAY, in_date, due_date), fine_paid
FROM loanhist AS l
INNER JOIN title AS t
ON l.title_no = t.title_no
WHERE title='Tao Teh King' AND fine_paid > 0 AND in_date > due_date;

-- 4
SELECT isbn
FROM reservation AS r
INNER JOIN member AS m
ON r.member_no = m.member_no
WHERE firstname + ' ' + middleinitial + '. ' + lastname = 'Stephen A. Graff';


/*
 * Examples 3 (CROSS JOIN)
 */
-- 1
USE Northwind;

SELECT Suppliers.CompanyName, Shippers.CompanyName
FROM Suppliers
CROSS JOIN Shippers
ORDER BY 1;


/*
 * Examples 4 (Joining multiple tables)
 */
-- 1
SELECT ProductName, OrderDate
FROM Orders AS o
INNER JOIN [Order Details] AS od
ON o.OrderID = od.OrderID
INNER JOIN Products p
ON p.ProductID = od.ProductID
WHERE OrderDate = '1996-07-08';


/*
 * Exercise 3
 */
-- 1
SELECT ProductName, UnitPrice, Address
FROM Products AS p
INNER JOIN Suppliers AS s
ON p.SupplierID = s.SupplierID
INNER JOIN Categories c
ON c.CategoryID = p.CategoryID
WHERE CategoryName='Meat/Poultry' AND UnitPrice BETWEEN 20 AND 30;
-- or (we can move conditions from WHERE to ON)
SELECT ProductName, UnitPrice, Address
FROM Products AS p
INNER JOIN Suppliers AS s
ON p.SupplierID = s.SupplierID
INNER JOIN Categories c
ON c.CategoryID = p.CategoryID AND CategoryName='Meat/Poultry' AND UnitPrice BETWEEN 20 AND 30;

-- 2
SELECT ProductName, UnitPrice, CompanyName
FROM Products AS p
INNER JOIN Categories AS c
ON p.CategoryID = c.CategoryID
INNER JOIN Suppliers AS s
ON s.SupplierID = p.SupplierID
WHERE CategoryName='Confections';

-- 3
SELECT DISTINCT c.CompanyName, c.Phone
FROM Customers AS c
INNER JOIN Orders AS o
ON c.CustomerID = o.CustomerID
INNER JOIN Shippers AS s
ON o.ShipVia = s.ShipperID
WHERE s.CompanyName = 'United Package' AND YEAR(ShippedDate) = 1997;

-- 4
SELECT DISTINCT cu.CompanyName, cu.Phone
FROM Customers AS cu
INNER JOIN Orders AS o
ON cu.CustomerID = o.CustomerID
INNER JOIN [Order Details] AS od
ON od.OrderID = o.OrderID
INNER JOIN Products AS p
ON od.ProductID = p.ProductID
INNER JOIN Categories AS ca
ON ca.CategoryID = p.CategoryID
WHERE CategoryName = 'Confections'
ORDER BY cu.CompanyName;


/*
 * Exercise 4
 */
USE library;

-- 1
SELECT firstname, lastname, birth_date, CONCAT(street , ', ', TRIM(zip), ' ', city, ', ', state) AS Address
FROM juvenile AS j
INNER JOIN member AS m
ON m.member_no = j.member_no
INNER JOIN adult AS a
ON a.member_no = j.adult_member_no;

-- 2
SELECT jm.firstname, jm.lastname, birth_date, CONCAT(street , ', ', TRIM(zip), ' ', city, ', ', state) AS Address,
       am.firstname, am.lastname
FROM juvenile AS j
INNER JOIN member AS jm -- jm - juvenile member
ON jm.member_no = j.member_no
INNER JOIN adult AS a
ON a.member_no = j.adult_member_no
INNER JOIN member AS am -- am - adult member
ON am.member_no = a.member_no;
-- We have to select an adult again because 'INNER JOIN adult AS a' allowed us to get parent's info only from
-- the 'adult' table but this table doesn't have parent's name stored. To select a parent member, we have to
-- connect the 'member' table using parent's member number to get parent's info.
-- We can either use 'ON am.member_no = j.adult_member_no' or 'ON am.member_no = a.member_no' because
-- 'j.adult_member_no' is the same number as 'a.member_no'.


/*
 * Examples 5 (Joining a table with itself)
 */
USE joindb;

-- 1
/*
Joining a table with itself is useful when we have records with repeated values which are used as JOIN condition.
For example, in the example below, w a table based on product id. In a table there is one product of id 2 which is
repeated 2 times (for example might have been bought by two different customers (see buyer_id)). Using JOIN based
on ids of products and displaying the same column (e.g. buyer_id) using 2 different aliases, will give as a Cartesian
product (all possible pairs of buyers ids which have in row product id of 2; to see this, remove the last line of
a query below). We can make use of this behaviour and compare some values of two different records which have
the same product_id (or other specified value).
*/
SELECT a.buyer_id AS buyer1, a.prod_id, b.buyer_id AS buyer2
FROM sales AS a
INNER JOIN sales AS b
ON a.prod_id = b.prod_id
WHERE a.buyer_id > b.buyer_id;

-- 2
SELECT a.buyer_id AS buyer1, a.prod_id, b.buyer_id AS buyer2
FROM sales AS a
INNER JOIN sales AS b
ON a.prod_id = b.prod_id;

-- 3
SELECT a.buyer_id AS buyer1, a.prod_id, b.buyer_id AS buyer2
FROM sales AS a
INNER JOIN sales AS b
ON a.prod_id = b.prod_id
WHERE a.buyer_id < b.buyer_id;

-- 4
USE Northwind;
-- LEFT functions cuts a specified number of beginning characters of a string.
SELECT e1.EmployeeID, LEFT(e1.LastName, 10) AS name, LEFT(e1.Title, 10) AS title,
       e2.EmployeeID, LEFT(e2.LastName, 10) AS name, LEFT(e2.Title, 10) AS title
FROM Employees AS e1
INNER JOIN Employees AS e2
ON e1.Title = e2.Title
WHERE e1.EmployeeID < e2.EmployeeID;


/*
 * Exercise 5
 */
USE Northwind;

-- 1
SELECT e1.EmployeeID AS Supervisor, e2.EmployeeID AS Subordinate
FROM Employees AS e1
INNER JOIN Employees AS e2
ON e1.EmployeeID = e2.ReportsTo
ORDER BY 1, 2;
-- or (without JOIN)
SELECT ReportsTo AS Supervisor, EmployeeID AS Subordinate
FROM Employees
WHERE ReportsTo IS NOT NULL
ORDER BY 1, 2;

-- 2 (this example shows how important is a correct usage of LEFT/RIGHT JOINS)
SELECT e1.EmployeeID AS Employee
FROM Employees AS e1
LEFT OUTER JOIN Employees as e2
ON e2.ReportsTo = e1.EmployeeID -- We link a table in such a way that e2 should be a subordinate of e1
WHERE e2.EmployeeID IS NULL;    -- If e1 has no subordinates, then e2.EmployeeID will be NULL
-- or
SELECT e2.EmployeeID AS Employee, COUNT(e1.EmployeeID)
FROM Employees AS e1
RIGHT OUTER JOIN Employees as e2
ON e1.ReportsTo = e2.EmployeeID
GROUP BY e2.EmployeeID
HAVING COUNT(e1.EmployeeID) = 0;

-- 3
USE library;

SELECT DISTINCT a.member_no, CONCAT(street , ', ', TRIM(zip), ' ', city, ', ', state) AS Address
FROM juvenile AS j
INNER JOIN adult AS a
ON a.member_no = j.adult_member_no
INNER JOIN member as am
ON am.member_no = a.member_no
WHERE YEAR(j.birth_date) < 1996;

-- 4
SELECT DISTINCT a.member_no, CONCAT(street , ', ', TRIM(zip), ' ', city, ', ', state) AS Address
FROM juvenile AS j
INNER JOIN adult AS a
ON a.member_no = j.adult_member_no
INNER JOIN member as am
ON am.member_no = a.member_no
LEFT OUTER JOIN loan AS l
ON l.member_no = a.member_no
WHERE YEAR(j.birth_date) < 1996 AND l.member_no IS NULL;  -- select members which currently have no book borrowed


/*
 * Examples 6 (Using UNION)
 *
 * (Used to merge two tables into one. Both tables must have the same number of columns and the same data
 * types in corresponding columns)
 */
USE Northwind;

SELECT FirstName + ' ' + LastName AS Name, City, PostalCode
FROM Employees
UNION SELECT CompanyName, City, PostalCode
FROM Customers;


/*
 * Exercise 6
 */
USE library;

-- 1
SELECT firstname + ' ' + lastname AS name, CONCAT(street, ' ', city, ' ', zip) AS Address
FROM member AS m
INNER JOIN adult AS a
ON m.member_no = a.member_no
UNION SELECT firstname + ' ' + lastname AS name, CONCAT(street, ' ', city, ' ', zip) AS Address
FROM juvenile AS j
INNER JOIN adult AS a2
ON a2.member_no = j.adult_member_no
INNER JOIN member AS m2
ON m2.member_no = j.member_no;

-- 2
SELECT i.isbn, copy_no, on_loan, title, translation, cover
FROM item AS i
INNER JOIN copy AS c
ON c.isbn = i.isbn
INNER JOIN title AS t
ON t.title_no = i.title_no
WHERE i.isbn IN (1, 500, 1000)
ORDER BY i.isbn;

-- 3
SELECT m.member_no, firstname, lastname, isbn, log_date
FROM member AS m
LEFT OUTER JOIN reservation AS r -- LEFT JOIN because we must display information for every user
ON m.member_no = r.member_no
WHERE m.member_no IN (250, 342, 1675);

-- 4
SELECT a.member_no, firstname + ' ' + lastname AS name
FROM juvenile AS j
INNER JOIN adult AS a
ON j.adult_member_no = a.member_no
INNER JOIN member AS m
ON m.member_no = a.member_no
WHERE a.state = 'AZ'
GROUP BY a.member_no, firstname + ' ' + lastname
HAVING COUNT(*) > 2;


/*
 * Exercise 7
 */
-- 1
SELECT a.member_no, firstname + ' ' + lastname AS name
FROM juvenile AS j
INNER JOIN adult AS a
ON j.adult_member_no = a.member_no
INNER JOIN member AS m
ON m.member_no = a.member_no
WHERE a.state = 'AZ'
GROUP BY a.member_no, firstname + ' ' + lastname
HAVING COUNT(*) > 2
UNION SELECT  a.member_no, firstname + ' ' + lastname AS name
FROM juvenile AS j
INNER JOIN adult AS a
ON j.adult_member_no = a.member_no
INNER JOIN member AS m
ON m.member_no = a.member_no
WHERE a.state = 'CA'
GROUP BY a.member_no, firstname + ' ' + lastname
HAVING COUNT(*) > 3;
