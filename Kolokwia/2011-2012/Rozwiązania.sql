-- 1
use Northwind;

select o.OrderID
from orders o
where o.Freight > (
    select avg(o2.Freight)
    from Orders o2
    where year(o2.ShippedDate) = year(o.ShippedDate)
)

select o1.OrderID
from orders o1
inner join orders o2 on year(o1.ShippedDate) = year(o2.ShippedDate)
group by o1.OrderID, o1.Freight
having o1.Freight > avg(o2.Freight);


-- 2
use library;

select m.member_no
from member m
left outer join loan l on l.member_no = m.member_no and year(l.out_date) = 1996
left outer join loanhist lh on lh.member_no = m.member_no and (year(lh.out_date) = 1996 or year(lh.in_date) = 1996)
where l.member_no is null and lh.member_no is null;

select m.member_no
from member m
where not exists(
    select *
    from loan l
    where l.member_no = m.member_no and year(l.out_date) = 1996
) and not exists(
    select *
    from loanhist lh
    where lh.member_no = m.member_no and (year(lh.out_date) = 1996 or year(lh.in_date) = 1996)
);

select m.member_no
from member m
where member_no not in (
    select member_no
    from loan l
    where l.member_no = m.member_no and year(l.out_date) = 1996
) and member_no not in (
    select member_no
    from loanhist lh
    where lh.member_no = m.member_no and (year(lh.out_date) = 1996 or year(lh.in_date) = 1996)
);

select m.member_no
from member m
where member_no not in (
    select member_no
    from loan l
    where l.member_no = m.member_no and year(l.out_date) = 1996
    union select member_no
    from loanhist lh
    where lh.member_no = m.member_no and (year(lh.out_date) = 1996 or year(lh.in_date) = 1996)
);

-- 3
use Northwind;

select s.CompanyName, year(o.ShippedDate), month(o.ShippedDate), sum(o.Freight)
from Shippers s
inner join orders o on o.ShipVia = s.ShipperID
where o.ShippedDate is not null
group by s.ShipperID, s.CompanyName, year(o.ShippedDate), month(o.ShippedDate);

select (
        select s.CompanyName
        from shippers s
        where s.ShipperID = t1.ShipVia
       ),
       t1.sYear,
       t1.sMonth, (
           select sum(o.Freight)
           from orders as o
           where o.ShipVia = t1.ShipVia and year(o.ShippedDate) = t1.sYear and month(o.ShippedDate) = t1.sMonth
       )
from (
    select distinct o.ShipVia, year(o.ShippedDate) as sYear, month(o.ShippedDate) as sMonth
    from orders o
    where o.ShippedDate is not null
) as t1;

-- 4
use Northwind;

select c.CompanyName, round(isnull((
        select sum(od.Quantity * od.UnitPrice * (1 - od.Discount))
        from orders o
        inner join [Order Details] od on od.OrderID = o.OrderID
        where o.CustomerID = c.CustomerID
    ) + (
        select sum(o.Freight)
        from orders as o
        where o.CustomerID = c.CustomerID
    ), 0), 2)
from Customers c;

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
