use Northwind;

-- 1


-- 2
select c.CompanyName, e.FirstName, e.LastName
from Customers c
inner join Orders o on o.CustomerID = c.CustomerID
left outer join Employees e on e.EmployeeID = o.EmployeeID and exists(
    select *
    from Employees e2
    where e2.ReportsTo = e.EmployeeID
)
where day(o.OrderDate) = 23 and month(o.OrderDate) = 5 and year(o.OrderDate) = 1997;

select c.CustomerID, isnull((
        select e.FirstName + ' ' + e.LastName
        from Employees e
        where e.EmployeeID = o.EmployeeID and exists(
            select *
            from Employees e2
            where e2.ReportsTo = e.EmployeeID
        )
    ), 'no subordinates') as EmployeeName
from Customers c
inner join Orders o on o.CustomerID = c.CustomerID
where day(o.OrderDate) = 23 and month(o.OrderDate) = 5 and year(o.OrderDate) = 1997;
