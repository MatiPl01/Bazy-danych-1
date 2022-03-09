/*
 * kolos2
 */
-- 1
use Northwind;

select (
    select c.CompanyName
    from Customers c
    where c.CustomerID = t1.cID
) as CustomerName, (
    select e.FirstName + ' ' + e.LastName
    from Employees e
    where e.EmployeeID = eID
) as EmployeeName, (
    select count(*)
    from Orders o
    where o.EmployeeID = eID and o.CustomerID = cID and year(o.OrderDate) = 1997
) as OrdersCount
from (
    select c.customerID as cID, (
        select e.EmployeeID
        from Employees e
        where e.EmployeeID = (
           select top 1 e.EmployeeID
           from Employees e
           inner join Orders o on o.EmployeeID = e.EmployeeID
           where o.CustomerID = c.CustomerID and year(o.OrderDate) = 1997
           group by e.EmployeeID
           order by count(o.OrderID) desc
        )
    ) as eID
    from Customers c
) as t1
order by 1;

select c.CompanyName, (
        select top 1 e.FirstName + ' ' + e.LastName
        from Employees e
        inner join Orders o on o.EmployeeID = e.EmployeeID
        where o.CustomerID = c.CustomerID and year(o.OrderDate) = 1997
        group by e.EmployeeID, e.FirstName + ' ' + e.LastName
        order by count(o.OrderID) desc
    ) as EmployeeName, (
        select top 1 count(o.OrderID)
        from Orders o
        where o.CustomerID = c.CustomerID and year(o.OrderDate) = 1997
        group by o.EmployeeID
        order by count(o.OrderID) desc
    )
from Customers c;

-- 2
use Northwind;

select e.FirstName, e.LastName, (
        select count(o.OrderID)
        from Orders o
        where o.EmployeeID = e.EmployeeID and year(o.OrderDate) = 1997
    ) as OrdersCount, round((
        select sum(od.Quantity * od.UnitPrice * (1 - od.Discount))
        from [Order Details] od
        inner join Orders o on o.OrderID = od.OrderID
        where o.EmployeeID = e.EmployeeID and year(o.OrderDate) = 1997
    ) + (
        select sum(o.Freight)
        from Orders o
        where o.EmployeeID = e.EmployeeID and year(o.OrderDate) = 1997
    ), 2)
from Employees e;


-- 3
use library;

select m.firstname, m.lastname, a.street, a.city, a.state, a.zip
from juvenile as j
inner join member m on m.member_no = j.member_no
inner join adult a on j.adult_member_no = a.member_no
inner join loanhist lh on j.member_no = lh.member_no
inner join title t on lh.title_no = t.title_no
where datediff(day, '2001-12-14', lh.in_date) = 0 and t.title = 'Walking';

-- or using subqueries
select (
        select m.firstname + ' ' + m.lastname
        from member m
        where m.member_no = j.member_no
    ) as name, (
        select a.street + ', ' + a.city + ', ' + a.state + ' ' + a.zip
        from adult a
        where a.member_no = j.adult_member_no
    ) as Address
from juvenile as j
where j.member_no in (
    select lh.member_no
    from loanhist lh
    where datediff(day, '2001-12-14', lh.in_date) = 0 and lh.title_no = (
        select t.title_no
        from title t
        where t.title = 'Walking'
    )
);
