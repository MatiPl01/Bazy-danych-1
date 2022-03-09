/*
 * Plik mi wyczyściło, nwm czemu.
 */

-- 1 ze wszystkimi pracownikami
with table1 as(select C.CompanyName, E.FirstName+' '+E.LastName as imie, count(O.OrderID) as result from Customers C
inner join Orders O on C.CustomerID = O.CustomerID
inner join Employees E on E.EmployeeID = O.EmployeeID
where year(OrderDate) = 1997
group by E.FirstName+' '+E.LastName,C.CompanyName)

select t1.CompanyName, t1.imie, t1.result from table1 as t1
left join table1 t2 on t1.CompanyName = t2.CompanyName and t1.result < t2.result
where t2.imie is null