/*
 * Grupa I
 */
-- 1
use Northwind;

select o.OrderID
from Orders as o
where o.Freight > (
    select avg(freight)
    from Orders as o2
    where year(o2.ShippedDate) = year(o.ShippedDate)
);

select o1.OrderID
from orders as o1
inner join orders o2
on year(o1.ShippedDate) = year(o2.ShippedDate)
group by o1.orderID, o1.Freight
having o1.Freight > avg(o2.Freight);


-- 2
use library;

select member_no
from member as m
where member_no not in (
    select member_no
    from loanhist
    where year(out_date) = 1996 or year(in_date) = 1996
) and member_no not in (
    select member_no
    from loan
    where year(out_date) = 1996
);

select member_no
from member as m
where not exists(
    select *
    from loanhist
    where loanhist.member_no = m.member_no and (year(loanhist.out_date) = 1996 or year(loanhist.in_date) = 1996)
) and not exists(
    select *
    from loan
    where loan.member_no = m.member_no and year(loan.out_date) = 1996
);

select m.member_no
from member as m
left outer join loan l on m.member_no = l.member_no and year(l.out_date) = 1996
left outer join loanhist lh on lh.member_no = m.member_no and (year(lh.out_date) = 1996 or year(lh.in_date) = 1996)
where l.member_no is null and lh.member_no is null;


-- 3
use Northwind;

select s.CompanyName, year(o.ShippedDate), month(o.ShippedDate), sum(Freight)
from Shippers as s
inner join orders as o on o.ShipVia = s.ShipperID
where o.ShippedDate is not null
group by s.ShipperID, s.CompanyName, year(o.ShippedDate), month(o.ShippedDate);


select (
        select s.CompanyName
        from Shippers as s
        where s.ShipperID = t1.ShipVia
    ),
    shipYear,
    shipMonth, (
        select sum(o.Freight)
        from Orders as o
        where o.ShipVia = t1.ShipVia and year(o.ShippedDate) = t1.shipYear and month(o.ShippedDate) = t1.shipMonth
   )
from (
    select distinct o.ShipVia, year(o.ShippedDate) as shipYear, month(o.ShippedDate) as shipMonth
    from Orders as o
    where o.ShippedDate is not null
) as t1;


-- 4
select c.CompanyName, isnull(round((
        select sum(o.Freight)
        from Orders o
        where o.CustomerID = c.CustomerID
    ) + (
        select sum(od.UnitPrice * od.Quantity * (1 - od.Discount))
        from [Order Details] as od
        where od.OrderID in (
            select o.OrderID
            from Orders as o
            where c.CustomerID = o.CustomerID
        )
    ), 2), 0)
from Customers c
order by 1;

select c.CompanyName,
       isnull(round(sum(od.Quantity * od.UnitPrice * (1 - od.Discount)) + (
           select sum(o2.Freight)
           from Orders as o2
           where o2.CustomerID = c.CustomerID
        ), 2), 0)
from Customers as c
left outer join orders as o on o.CustomerID = c.CustomerID
left outer join [Order Details] as od on od.OrderID = o.OrderID
group by c.CustomerID, c.CompanyName
order by 1;



/*
 * Grupa II
 */
-- 1
use Northwind;

select s.CompanyName, year(o.ShippedDate), month(o.ShippedDate), sum(Freight)
from shippers s
inner join orders o on o.ShipVia = s.ShipperID
where o.ShippedDate is not null
group by s.ShipperID, s.CompanyName, year(o.ShippedDate), month(o.ShippedDate);

select (
        select s.CompanyName
        from Shippers s
        where s.ShipperID = t1.ShipVia
    ),
    sYear,
    sMonth, (
        select sum(o.Freight)
        from Orders o
        where o.ShipVia = t1.ShipVia and year(o.ShippedDate) = sYear and month(o.ShippedDate) = sMonth
   )
from (
     select distinct ShipVia, year(ShippedDate) as sYear, month(ShippedDate) as sMonth
     from Orders
     where ShippedDate is not null
) as t1;


-- 2
select p.ProductID, p.ProductName, p.UnitPrice
from Products p
where p.UnitPrice >= (
    select avg(p2.UnitPrice)
    from Products p2
    where p2.CategoryID = p.CategoryID
)
order by 1;

select p1.ProductID, p1.ProductName, p1.UnitPrice
from Products p1
inner join Products p2 on p1.CategoryID = p2.CategoryID
inner join Categories as c on c.CategoryID = p1.CategoryID
group by p1.ProductID, p1.ProductName, p1.UnitPrice
having p1.UnitPrice >= avg(p2.UnitPrice);


-- 3
select e.EmployeeID, e.FirstName, e.LastName
from Employees e
where e.EmployeeID = (
    select top 1 o.EmployeeID
    from Orders o
    inner join [Order Details] as od on od.OrderID = o.OrderID
    where year(o.OrderDate) = 1997
    group by o.EmployeeID
    order by sum(od.Quantity * od.UnitPrice * (1 - od.Discount)) desc
)

select top 1 e.EmployeeID, e.FirstName, e.LastName
from Employees e
inner join orders o on e.EmployeeID = o.EmployeeID
inner join [Order Details] od on od.OrderID = o.OrderID
where year(o.OrderDate) = 1997
group by e.EmployeeID, e.FirstName, e.LastName
order by sum(od.Quantity * od.UnitPrice * (1 - od.Discount)) desc;


-- 4
select od.OrderID, od.ProductID
from [Order Details] od
where od.UnitPrice * od.Quantity * (1 - od.Discount) < (
    select avg(od2.UnitPrice * od2.Quantity * (1 - od2.Discount))
    from [Order Details] od2
    where od2.OrderID = od.OrderID
);

select od1.OrderID, od1.ProductID
from [Order Details] od1
inner join [Order Details] od2 on od1.OrderID = od2.OrderID
group by od1.ProductID, od1.OrderID, od1.UnitPrice, od1.Quantity, od1.Discount
having od1.UnitPrice * od1.Quantity * (1 - od1.Discount) < avg(od2.UnitPrice * od2.Quantity * (1 - od2.Discount));
