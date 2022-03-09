-- 1
use Northwind;

select CompanyName, Phone
from Customers
where CustomerID not in (
    select CustomerID
    from Orders
    where OrderID in (
        select orderid
        from [Order Details] od
        where ProductID in (
            select ProductID
            from Products
            where CategoryID = (
                select CategoryID
                from Categories
                where CategoryName = 'Confections'
            )
        )
    )
);

select c.CompanyName, c.Phone
from Customers c
where not exists(
    select *
    from Orders o
    where o.CustomerID = c.CustomerID and exists(
        select *
        from [Order Details] od
        where od.OrderID = o.OrderID and exists(
            select *
            from Products p
            where p.ProductID = od.ProductID and exists(
                select *
                from Categories c
                where c.CategoryID = p.CategoryID and c.CategoryName = 'Confections'
            )
        )
    )
);

select distinct cu.CompanyName, cu.Phone
from Customers cu
left outer join orders o on o.CustomerID = cu.CustomerID
left outer join [Order Details] od on od.OrderID = o.OrderID
left outer join products p on p.ProductID = od.ProductID
left outer join Categories c on c.CategoryID = p.CategoryID and c.CategoryName = 'Confections'
group by cu.CustomerID, cu.CompanyName, cu.Phone
having count(c.CategoryName) = 0;


-- 2
use Northwind;

select p.ProductID, c.CategoryName, p.ProductName, p.UnitPrice, (
        select avg(p2.UnitPrice)
        from Products p2
        where p2.CategoryID = p.CategoryID
    ),
    p.UnitPrice - (
        select avg(p2.UnitPrice)
        from Products p2
        where p2.CategoryID = p.CategoryID
    )
from Products p
inner join Categories c on c.CategoryID = p.CategoryID;

select p1.ProductID, c.CategoryName, p1.ProductName, p1.UnitPrice, avg(p2.UnitPrice), p1.UnitPrice - avg(p2.UnitPrice)
from Products p1
inner join Products p2 on p1.CategoryID = p2.CategoryID
inner join Categories c on c.CategoryID = p1.CategoryID
group by p1.ProductID, c.CategoryName, p1.ProductName, p1.UnitPrice;


-- 3
use Northwind;

select o.EmployeeID, count(o.OrderID), max(o.OrderDate)
from Orders o
where year(o.OrderDate) = 1997
group by o.EmployeeID
having count(o.OrderID) > 6;

select id, oCount, oDate
    from (
         select e.EmployeeID as id, (
            select count(*)
            from orders o
            where o.EmployeeID = e.EmployeeID and year(o.OrderDate) = 1997
        ) as oCount, (
            select max(o.OrderDate)
            from orders o
            where o.EmployeeID = e.EmployeeID and year(o.OrderDate) = 1997
        ) as oDate
        from Employees e
    ) as t1
where oCount > 6;


-- 4
use Northwind;

select s.ShipperID, s.CompanyName, year(o.ShippedDate), sum(o.Freight)
from Orders o
inner join Shippers s on s.ShipperID = o.ShipVia
where o.ShippedDate is not null
group by s.ShipperID, s.CompanyName, year(o.ShippedDate)
order by 1, 3;

select t1.ShipVia, (
        select s.CompanyName
        from Shippers s
        where s.ShipperID = t1.ShipVia
    ),
       sy, (
        select sum(o.Freight)
        from Orders o
        where o.ShipVia = t1.ShipVia and year(o.ShippedDate) = sy
   )
from (
     select distinct o.ShipVia, year(o.ShippedDate) as sy
     from orders o
     where o.ShippedDate is not null
 ) as t1
order by 1, 3;
