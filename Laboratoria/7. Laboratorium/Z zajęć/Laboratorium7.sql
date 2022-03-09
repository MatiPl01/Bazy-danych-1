USE library;

-- 1
-- Dla każdego użytkownika podaj imię, nazwisko oraz karę, jaką zapłacił w 2001 roku (bez tych, co kary nie płącili)
SELECT firstname, lastname, (
    SELECT SUM(fine_paid)
    FROM loanhist AS l
    WHERE l.member_no = m.member_no AND YEAR(l.in_date) = 2001
)
FROM member AS m
WHERE (
    SELECT SUM(fine_paid)
    FROM loanhist AS l
    WHERE l.member_no = m.member_no AND YEAR(l.in_date) = 2001
) IS NOT NULL
ORDER BY 3 DESC;

-- 2
-- TODO

-- 3
SELECT firstname,
       lastname, (
            SELECT COUNT(*)
            FROM loanhist AS l
            WHERE l.member_no = m.member_no AND YEAR(in_date) = 2001
        ),
        ISNULL((
            SELECT 'Adult'
            FROM adult AS a
            WHERE a.member_no = m.member_no
        ), 'Child')
FROM member AS m
ORDER BY 4, 3 DESC;

-- 4
SELECT member_no, firstname, lastname
FROM member AS m
WHERE member_no NOT IN (
    SELECT member_no
    FROM loan
    WHERE YEAR(out_date) = 2001
) AND member_no NOT IN (
    SELECT member_no
    FROM loanhist
    WHERE YEAR(in_date) = 2001
);

SELECT m.member_no, firstname, lastname
FROM member AS m
LEFT OUTER JOIN loanhist AS lh
ON m.member_no = lh.member_no AND YEAR(lh.in_date) = 2001
LEFT OUTER JOIN loan AS l
ON lh.member_no = l.member_no AND YEAR(l.out_date) = 2001
WHERE l.member_no IS NULL AND lh.member_no IS NULL;

-- 5
USE Northwind;

SELECT OrderID
FROM Orders AS o
WHERE Freight > (
    SELECT AVG(Freight)
    FROM Orders AS o2
    WHERE YEAR(o2.OrderDate) = YEAR(o.OrderDate)
)

-- 6
-- ,
--                 Quantity * UnitPrice * (1 - Discount),
--                 (
--     SELECT AVG(Quantity * UnitPrice * (1 - Discount))
--     FROM [Order Details] AS od2
--     WHERE od.OrderID = od2.OrderID
-- )
SELECT DISTINCT OrderID, ProductID
FROM [Order Details] AS od
WHERE (Quantity * UnitPrice * (1 - Discount)) < (
    SELECT AVG(Quantity * UnitPrice * (1 - Discount))
    FROM [Order Details] AS od2
    WHERE od.OrderID = od2.OrderID
)
ORDER BY 1;

---, od.Quantity * od.UnitPrice * (1 - od.Discount), AVG(od2.Quantity * od2.UnitPrice * (1 - od2.Discount))
SELECT DISTINCT od.OrderId, od.ProductID
FROM [Order Details] AS od
INNER JOIN [Order Details] AS od2
ON od.OrderID = od2.OrderID
GROUP BY od.OrderID, od.Quantity, od.UnitPrice, od.Discount, od.ProductID
HAVING (od.Quantity * od.UnitPrice * (1 - od.Discount)) < AVG(od2.Quantity * od2.UnitPrice * (1 - od2.Discount))
ORDER BY 1;
