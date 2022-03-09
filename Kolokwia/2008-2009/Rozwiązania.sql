-- 1
use Northwind;

select e.EmployeeID, e.Address, e.City, e.Region, e.PostalCode, e.Country
from Employees e
left outer join orders o on e.EmployeeID = o.EmployeeID and year(o.OrderDate) = 1997
group by e.EmployeeID, e.Address, e.City, e.Region, e.PostalCode, e.Country, o.OrderDate
having count(o.OrderID) = 0;

select e.EmployeeID, e.Address, e.City, e.Region, e.PostalCode, e.Country
from Employees e
where not exists(
    select *
    from Orders o
    where o.EmployeeID = e.EmployeeID and year(o.OrderDate) = 1997
)

select e.EmployeeID, e.Address, e.City, e.Region, e.PostalCode, e.Country
from Employees e
where EmployeeID not in (
    select EmployeeID
    from Orders
    where year(OrderDate) = 1997
)


-- 2
use library;

select m.firstname, m.lastname, a.street, a.city, a.state, a.zip, count(isbn), 'Adult'
from member m
inner join loan l on m.member_no = l.member_no
inner join adult a on m.member_no = a.member_no
group by m.member_no, m.firstname, m.lastname, a.street, a.city, a.state, a.zip
union select m.firstname, m.lastname, a.street, a.city, a.state, a.zip, count(isbn), 'Juvenile'
from member m
inner join loan l on m.member_no = l.member_no
inner join juvenile j on m.member_no = j.member_no
inner join adult a on j.adult_member_no = a.member_no
group by m.member_no, m.firstname, m.lastname, a.street, a.city, a.state, a.zip;


-- 3
use library;

select lh.member_no, count(*), max(lh.in_date)
from loanhist as lh
where lh.member_no between 1000 and 2000
group by lh.member_no
having sum(fine_assessed) > 12;


-- 4
use Northwind;

select p.ProductName, (
        select c.CategoryName
        from Categories c
        where c.CategoryID = p.CategoryID
    ),
       p.UnitPrice, (
        select avg(p2.UnitPrice)
        from Products p2
        where p2.CategoryID = p.CategoryID
    )
from Products p
where p.UnitPrice < (
    select avg(p2.UnitPrice)
    from Products p2
    where p2.CategoryID = p.CategoryID
)

select p1.ProductName, c.CategoryName, p1.UnitPrice, avg(p2.UnitPrice)
from Products p1
inner join Products p2 on p1.CategoryID = p2.CategoryID
inner join Categories c on c.CategoryID = p1.CategoryID
group by p1.ProductName, c.CategoryName, p1.UnitPrice
having p1.UnitPrice < avg(p2.UnitPrice)
order by 2;


-- 5 ?????? Jak to posortować bez dodawania liczb, zachowując kolejność grup
use Northwind;

select 1, 'Supplier' as Type, s.CompanyName, s.Address, s.City, s.Region, s.PostalCode, s.Country
from Suppliers s
union
select 2, 'Customer' as Type, c.CompanyName, c.Address, c.City, c.Region, c.PostalCode, c.Country
from Customers c
union
select 3, 'Employee' as Type, e.FirstName + ' ' + e.LastName, e.Address, e.City, e.Region, e.PostalCode, e.Country
from Employees e
order by 1, 3;


-- 6
use Northwind;

select e1.EmployeeID, e2.EmployeeID
from Employees e1
inner join Employees e2 on e2.City = e1.City and e2.Title = e1.Title
where e1.Title = 'Sales representative' and e1.EmployeeID < e2.EmployeeID;

select e1.EmployeeID, e2.EmployeeID
from Employees e1
inner join Employees e2 on e2.City = e1.City
where e1.Title = 'Sales representative' and e2.title = 'Sales representative' and e1.EmployeeID < e2.EmployeeID;


-- 7 (nie wiem, czy o to chodziło, czy miało to być w jednej tabeli (ale jak w jednej, to jak???))
use Northwind;

select top 1 'Largest number of orders', c.CompanyName, c.Phone
from Customers c
inner join Orders o on o.CustomerID = c.CustomerID
group by o.CustomerID, c.CompanyName, c.Phone
order by count(o.OrderID) desc;

select top 1 'Highest value orders', c.CompanyName, c.Phone
from Customers c
inner join Orders o on o.CustomerID = c.CustomerID
inner join [Order Details] od on od.orderID = o.OrderID
group by o.CustomerID, c.CompanyName, c.Phone
order by sum(od.Quantity * od.UnitPrice * (1 - od.Discount)) desc;


-- 8
select p.ProductName, p.UnitsInStock
from Products p
inner join Categories c on c.CategoryID = p.CategoryID
inner join Suppliers s on p.SupplierID = s.SupplierID
where s.CompanyName = 'Kowalski i spółka' and c.CategoryName like '[^M]c%z[^a]';

select p.ProductName, p.UnitsInStock
from Products p
where p.CategoryID in (
    select c.CategoryID
    from Categories c
    where c.CategoryName like '[^M]c%z[^a]'
) and p.SupplierID = (
    select s.SupplierID
    from Suppliers s
    where s.CompanyName = 'Kowalski i spółka'
);
