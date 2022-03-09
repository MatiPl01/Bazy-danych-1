-- 1 a)
use Northwind;

select pID, (
        select p.ProductName
        from Products p
        where p.ProductID = pID
    ),
       pCount
from (
    select p.ProductID as pID, (
        select count(*) from (
            select distinct o.CustomerID as cid
            from Orders o
            where o.OrderID in (
                select od.OrderID
                from [Order Details] od
                where od.ProductID = p.productID
            )
        ) as t1) as pCount
    from Products p
) as t2
where pCount > 15
order by 1;


-- 1 b)
use Northwind;

select p.ProductID, p.ProductName, count(distinct c.CustomerID)
from Products p
inner join [Order Details] od on od.ProductID = p.ProductID
inner join orders o on o.OrderID = od.OrderID
inner join Customers c on o.CustomerID = c.CustomerID
group by p.ProductID, p.ProductName
having count(distinct c.CustomerID) > 15
order by 1;


-- 2
use Northwind;

select top 1 p.ProductID, round(sum(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2)
from Products p
inner join [Order Details] od on od.ProductID = p.ProductID
inner join orders o on o.OrderID = od.OrderID
where year(o.OrderDate) = 1996
group by p.ProductID
order by sum(od.UnitPrice * od.Quantity * (1 - od.Discount));

select top 1 od.ProductID, sum(od.Quantity * od.UnitPrice * (1 - od.Discount))
from [Order Details] od
where od.OrderID in (
    select o.OrderID
    from Orders o
    where year(o.OrderDate) = 1996
)
group by od.ProductID
order by 2;
