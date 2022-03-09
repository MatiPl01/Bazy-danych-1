USE Northwind;

/* Exercise 1 */
-- Wyświetl wszytskich pracowników, którzy mają przynajniej 25 lat
SELECT * FROM Employees WHERE DATEDIFF(year, BirthDate, GETDATE()) >= 25;

/* Exercise 2 */
-- Dla każdego pracownika wyświetl liczbę zamówień, które obłsużył i podaj datę najstarszego obsłużonego
-- przez niego zamówienia
SELECT EmployeeID, COUNT(OrderID) AS ServedOrders, MIN(OrderDate) AS FirstOrderDate FROM Orders 
GROUP BY EmployeeID 
ORDER BY 2 DESC;

/* Exercise 3 */
-- Dla każdego klienta, któremu nie zrealizowano zamówienia w wyznaczonym czasie, podaj, ile
-- łącznie zapłacił za koszt przesyłek
SELECT CustomerID, SUM(Freight) FROM Orders WHERE ShippedDate > RequiredDate GROUP BY CustomerID;

/* Exercise 4 */
-- Wyświetl wszystkie zamówienia, w których na żaden z zakupionych produktów nie obowiązywała
-- zniżka
SELECT OrderID FROM [Order Details]
GROUP BY OrderID
HAVING SUM(Discount) = 0;

/* Exercise 5 */
-- Ile każdy z rodziców ma dzieci? Wyświetl tylko rodziców, którzy mają więcej niż dwójkę
-- dzieci. Dla każdego rodzica wyświetl datę urodzenia najstarszego z dzieci
USE library;

SELECT adult_member_no, COUNT(member_no), MIN(birth_date) FROM juvenile 
GROUP BY adult_member_no 
HAVING COUNT(member_no) > 2
ORDER BY 2 DESC;

/* Exercise 6 */
-- Wyświetl wszystkie pierwsze litery imion czytelników biblioteki i policz, ilu czytelników
-- ma imię, rozpoczynające się daną literą
SELECT SUBSTRING(firstname, 1, 1), COUNT(*) FROM member 
GROUP BY SUBSTRING(firstname, 1, 1)
ORDER BY 2 DESC;

/* Exercise 7 */
SELECT AVG(DATEDIFF(DAY, in_date, due_date)) FROM loanhist;

SELECT YEAR(due_date), AVG(DATEDIFF(DAY, in_date, due_date)) FROM loanhist GROUP BY YEAR(due_date);
