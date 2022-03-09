/*
 * Mateusz Łopaciński
 */

-- Zad. 1.
use Northwind;

select top 1 p.ProductName
from [Order Details] od
inner join Orders o on o.OrderID = od.OrderID
inner join Products P on od.ProductID = P.ProductID
where year(o.OrderDate) = 1996
group by od.ProductID, p.ProductName
having sum(od.Quantity * od.UnitPrice * (1 - od.Discount)) > 0
order by sum(od.Quantity * od.UnitPrice * (1 - od.Discount));

-- Zad. 2.
use library;

select m.member_no, m.firstname, m.lastname, a.street, a.city, a.state, a.zip, 'Adult', (
    select count(*)
    from juvenile j
    inner join adult a3 on j.adult_member_no = a3.member_no
    where a3.member_no = m.member_no
)
from member m
inner join adult a on m.member_no = a.member_no
where m.member_no not in (
    select member_no from loan
) and m.member_no not in (
    select member_no from loanhist
)
union select m2.member_no, m2.firstname, m2.lastname, a2.street, a2.city, a2.state, a2.zip, 'Juvenile', 0 as childrenCount
from juvenile j
inner join member m2 on j.member_no = m2.member_no
inner join adult a2 on j.adult_member_no = a2.member_no
where m2.member_no not in (
    select member_no from loan
) and m2.member_no not in (
    select member_no from loanhist
)
order by 1;


-- Zad. 3.
use Northwind;

select (
    select e.FirstName + ' ' + e.LastName
    from Employees e2
    where e2.EmployeeID = e.EmployeeID
) as EmployeeName, (
    select count(o.OrderID)
    from Orders o
    where o.EmployeeID = e.EmployeeID and year(o.OrderDate) = 1997 and month(o.OrderDate) = 2
) as OrdersCount, round(isnull((
    select sum(od.Quantity * od.UnitPrice * (1 - od.Discount))
    from Orders o
    inner join [Order Details] od on od.OrderID = o.OrderID
    where o.EmployeeID = e.EmployeeID and year(o.OrderDate) = 1997 and month(o.OrderDate) = 2
) + (
    select sum(o.Freight)
    from Orders o
    where o.EmployeeID = e.EmployeeID and year(o.OrderDate) = 1997 and month(o.OrderDate) = 2
), 0), 2) as TotalAmount
from Employees e
order by 1;
