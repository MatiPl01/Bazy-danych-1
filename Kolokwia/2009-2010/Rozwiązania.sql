-- 1
use Northwind;

select o.OrderID, round(sum(od.Quantity * od.UnitPrice * (1 - od.Discount)) + o.Freight, 2)
from Orders o
inner join [Order Details] od on od.OrderID = o.OrderID
group by o.OrderID, o.Freight;

select o.OrderID, round((
        select sum(od.Quantity * od.UnitPrice * (1 - od.Discount))
        from [Order Details] od
        where od.OrderID = o.OrderID
    ) + o.Freight, 2)
from Orders o;


-- 2
use library;

select m.member_no
from member m
left outer join loan l on m.member_no = l.member_no and year(l.out_date) = 1996
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
where not exists(
    select l.member_no
    from loan l
    where l.member_no = m.member_no and year(l.out_date) = 1996
    union select lh.member_no
    from loanhist lh
    where lh.member_no = m.member_no and (year(lh.out_date) = 1996 or year(lh.in_date) = 1996)
);

select m.member_no
from member m
where m.member_no not in (
    select l.member_no
    from loan l
    where year(l.out_date) = 1996
) and m.member_no not in (
    select lh.member_no
    from loanhist lh
    where year(lh.out_date) = 1996 or year(lh.in_date) = 1996
);


-- 3
use Northwind;

select o.OrderID
from orders o
where o.Freight > (
    select avg(o2.Freight)
    from Orders o2
    where year(o2.OrderDate) = year(o.OrderDate)
);

select o1.OrderID
from orders o1
inner join orders o2 on year(o1.OrderDate) = year(o2.OrderDate)
group by o1.OrderID, o1.Freight
having o1.Freight > avg(o2.Freight);


-- 4
use Northwind;

select e.EmployeeID, e.FirstName, e.LastName, year(o.OrderDate), datepart(quarter, o.OrderDate), month(o.OrderDate),
       count(o.OrderID)
from Employees e
inner join Orders o on o.EmployeeID = e.EmployeeID
group by e.EmployeeID, e.FirstName, e.LastName, year(o.OrderDate), datepart(quarter, o.OrderDate), month(o.OrderDate);

select t1.EmployeeID, (
        select FirstName
        from Employees e
        where t1.EmployeeID = e.EmployeeID
    ), (
        select LastName
        from Employees e
        where t1.EmployeeID = e.EmployeeID
    ),
       t1.y,
       t1.q,
       t1.m, (
        select count(OrderID)
        from orders o
        where o.EmployeeID = t1.EmployeeID
          and year(o.OrderDate) = t1.y
          and datepart(quarter, o.OrderDate) = t1.q
          and month(o.OrderDate) = t1.m
   )
from (
     select distinct EmployeeID, year(OrderDate) as y, datepart(quarter, OrderDate) as q, month(OrderDate) as m
     from Orders
) as t1;
