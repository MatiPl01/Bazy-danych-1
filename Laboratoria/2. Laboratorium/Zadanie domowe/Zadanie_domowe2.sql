USE Northwind;

/*
 * Exercise 1
 */
-- 1
SELECT OrderID, CONVERT(MONEY, SUM(UnitPrice * Quantity * (1 - Discount)))
FROM [Order Details]
GROUP BY OrderID, OrderID
ORDER BY 2 DESC;

-- 2
SELECT TOP 10 OrderID, SUM(UnitPrice * Quantity * (1 - Discount)) 
FROM [Order Details] 
GROUP BY OrderID
ORDER BY 2 DESC;
-- 3

SELECT TOP 10 WITH TIES OrderID, SUM(UnitPrice * Quantity * (1 - Discount)) 
FROM [Order Details] 
GROUP BY OrderID
ORDER BY 2 DESC;



/*
 * Exercise 2
 */
-- 1
SELECT ProductID, SUM(Quantity) FROM [Order Details] WHERE ProductID < 3 GROUP BY ProductID;
-- or (this is not optimal)
SELECT ProductID, SUM(Quantity) FROM [Order Details] GROUP BY ProductID HAVING ProductID < 3;

-- 2
SELECT ProductID, SUM(Quantity) FROM [Order Details] GROUP BY ProductID;

-- 3
SELECT OrderID, CONVERT(MONEY, SUM(Quantity * UnitPrice * (1 - Discount)))
FROM [Order Details]
GROUP BY OrderID
HAVING SUM(Quantity) > 250;



/*
 * Exercise 3
 */
-- 1
SELECT ProductID, OrderID, SUM(Quantity) AS TotalQuantity
FROM [Order Details]
GROUP BY ProductID, OrderID WITH ROLLUP;
-- or
SELECT ProductID, OrderID, SUM(Quantity) AS TotalQuantity
FROM [Order Details]
GROUP BY ROLLUP(ProductID, OrderID);

-- 2
SELECT OrderID, SUM(Quantity) AS TotalQuantity
FROM [Order Details]
GROUP BY ProductID, OrderID WITH ROLLUP
HAVING ProductID = 50;
-- or
SELECT OrderID, SUM(Quantity) AS TotalQuantity
FROM [Order Details]
WHERE ProductID = 50
GROUP BY OrderID WITH ROLLUP;
-- or
SELECT OrderID, SUM(Quantity) AS TotalQuantity
FROM [Order Details]
GROUP BY ROLLUP(ProductID, OrderID)
HAVING ProductID = 50;
-- or
SELECT OrderID, SUM(Quantity) AS TotalQuantity
FROM [Order Details]
WHERE ProductID = 50
GROUP BY ROLLUP(OrderID);

-- 3
/*
W kolumnie OrderID:
    - oznacza, że jest to suma liczb (łączna liczba) wszystkich produktów
    o tym samym ID, które występuje wówczas w lewej kolumnie (tzn. liczba
    produktów o danym ProductID i dowolnym OrderID),
    - jeżeli w kolumnie ProductID znajduje się NULL, to również w kolumnie
    OrderID musi się znajdować NULL. Otrzymujemy wówczas rezultat dla
    przypadku, w którym ProductID oraz OrderID ma dowolną wartość (innymi
    słowy, otrzymujemy wtedy sumaryczną liczbę wszystkich produktów),
*/
SELECT SUM(Quantity) FROM [Order Details]; -- Dowód ostatniego zdania z pkt. 3

-- 4
SELECT ProductID, OrderID, GROUPING(ProductID), GROUPING(OrderID), SUM(Quantity) AS TotalQuantity
FROM [Order Details]
GROUP BY ProductID, OrderID WITH CUBE;

-- 5
/*
Podsumowaniami są wszystkie wiersze, które zwierają wartość NULL w miejscu
ProductID lub OrderID.


Według produktu:
    - Podsumowują te wiersze, które w kolumnie OrderID mają wartość NULL
    (wtedy dla produktu o danym ProductID, różnym od NULL, zliczana jest
    łączna liczba zamówień),

Według zamówienia:
    - Podsumowują te wiersze, które w kolumnie ProductID mają wartość NULL
    (wtedy dla zamówienia o danym OrderID, różnym od NULL, zliczana jest
    łączna liczba produktów),

Według produktu i zamówienia:
    - Obie kolumny (zarówno ProductID, jak i OrderID), mają wartość NULL
    (wtedy zliczana jest liczba wszystkich produktów w zamówieniach
    o dowolnej wartości OrderID, składających się z produktów o dowolnym ID)
    (W efekcie uzyskujemy łączną liczbę wszystkich sprzedanych produktów)
    (dowód niżej)
*/
SELECT SUM(Quantity) FROM [Order Details];
