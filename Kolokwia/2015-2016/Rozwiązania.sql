-- 1 a)
use library;

select m.firstname, m.lastname, a.street, a.city, a.state, a.zip, (
    select count(title_no)
    from loan as l
    where l.member_no = m.member_no
) + (
    select count(title_no)
    from loanhist as lh
    where lh.member_no = m.member_no
)
from member as m
inner join adult as a on m.member_no = a.member_no
union select jm.firstname, jm.lastname, am.street, am.city, am.state, am.zip, (
    select count(title_no)
    from loan as l
    where l.member_no = jm.member_no
) + (
    select count(title_no)
    from loanhist as lh
    where lh.member_no = jm.member_no
)
from member as jm
inner join juvenile as j
on j.member_no = jm.member_no
inner join adult as am on am.member_no = j.adult_member_no;

-- 1 b)
select m.firstname, m.lastname, a.street, a.city, a.state, a.zip, (
    select count(title_no)
    from loan as l
    where l.member_no = m.member_no
) + (
    select count(title_no)
    from loanhist as lh
    where lh.member_no = m.member_no
), 'Adult'
from member as m
inner join adult as a on m.member_no = a.member_no
union select jm.firstname, jm.lastname, am.street, am.city, am.state, am.zip, (
    select count(title_no)
    from loan as l
    where l.member_no = jm.member_no
) + (
    select count(title_no)
    from loanhist as lh
    where lh.member_no = jm.member_no
), 'Juvenile'
from member as jm
inner join juvenile as j
on j.member_no = jm.member_no
inner join adult as am on am.member_no = j.adult_member_no;


-- 2 a)
select m.firstname, m.lastname
from member as m
left outer join loan as l on m.member_no = l.member_no
left outer join loanhist lh on lh.member_no = m.member_no
where lh.member_no is null and l.member_no is null;

-- 2 b)
select m.firstname, m.lastname
from member as m
where member_no not in (
    select member_no
    from loanhist
    union select member_no
    from loan
)

-- or
select m.firstname, m.lastname
from member as m
left outer join (
     select member_no
     from loanhist
     union select member_no
     from loan
) as ml on ml.member_no = m.member_no
where ml.member_no is null
order by 1;


-- 3 a)
use Northwind;

select distinct o1.OrderID
from orders as o1
cross join orders as o2
where year(o1.OrderDate) = year(o2.OrderDate)
group by o1.OrderID, o1.Freight
having o1.Freight > avg(o2.Freight);

-- 3 b)
select o.OrderID
from orders as o
where o.Freight > (
    select avg(freight)
    from orders as o2
    where year(o2.OrderDate) = year(o.OrderDate)
)


-- 4 a)
select s.ShipperID, s.CompanyName, YEAR(o.ShippedDate), MONTH(o.ShippedDate), sum(Freight)
from orders as o
inner join Shippers as s on s.ShipperID = o.ShipVia
where o.ShippedDate is not null
group by s.ShipperID, s.CompanyName, YEAR(o.ShippedDate), MONTH(o.ShippedDate)
order by 1, 3, 4;

-- 4 b)
select ShipVia,
       shipYear,
       shipMonth, (
           select sum(o.Freight)
           from orders as o
           where o.ShipVia = t1.ShipVia
             and year(o.ShippedDate) = t1.shipYear
             and month(o.ShippedDate) = t1.shipMonth
      )
from (
    select distinct o.ShipVia,
    YEAR(ShippedDate) as shipYear,
    MONTH(ShippedDate) as shipMonth
    from Orders as o
    where ShippedDate is not null
) as t1
