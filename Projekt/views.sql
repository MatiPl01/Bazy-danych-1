USE u_lopacins;

-- Helper view: DiscountParamsTableView
CREATE VIEW DiscountParamsTableView
AS SELECT ParamName, Value, AvailableFrom, AvailableTo
FROM DiscountParams AS dp
INNER JOIN DiscountParamsDict AS dpd
ON dpd.ParamID = dp.ParamID;

-- Helper view: OrdersDiscountsTableView
CREATE VIEW OrdersDiscountsTableView AS
    SELECT o.OrderID, o.CustomerID, o.OrderDate, o.OutDate, ISNULL(
      (SELECT TOP 1 otd.DiscountValue
      FROM OneTimeDiscount AS otd
      WHERE otd.CustomerID = o.CustomerID AND o.OrderDate >= otd.AvailableFrom
      AND o.OrderDate <= ISNULL(otd.AvailableTo, GETDATE()))
    , ISNULL(
      (SELECT TOP 1 pd.DiscountValue
      FROM PermanentDiscount AS pd
      WHERE pd.CustomerID = o.CustomerID AND o.OrderDate >= pd.AvailableFrom)
	,0)) AS DiscountValue
  FROM Orders AS o;

-- View: CurrentMenuView
CREATE VIEW CurrentMenuView
AS SELECT * FROM MenuItems
WHERE AvailableTo IS NULL OR AvailableTo > GETDATE();

-- View: DishesOlderThanTwoWeeksView
CREATE VIEW DishesOlderThanTwoWeeksView
AS SELECT * FROM CurrentMenuView
WHERE DATEDIFF(DAY, AvailableFrom, GETDATE()) > 14 
AND DishID NOT IN (SELECT DishID FROM SeafoodMenuView)

-- View: PendingReservationsView
CREATE VIEW PendingReservationsView
AS SELECT * FROM Reservations
WHERE ConfirmationDate IS NULL;

-- View: IndividualsReservationsView
CREATE VIEW IndividualsReservationsView
AS SELECT r.ReservationID, r.CustomerID, ri.TableID, r.PeopleCount, r.ReservationDate, r.FromDate FROM Reservations AS r
INNER JOIN ReservationIndividuals AS ri
ON ri.ReservationID = r.ReservationID;

-- View: CurrentIndividualsReservationsView
CREATE VIEW CurrentIndividualsReservationsView
AS SELECT * FROM IndividualsReservationsView AS r
WHERE DATEDIFF(DAY, r.ReservationDate, GETDATE()) = 0;

-- View: IndividualReservationsMonthlyReportView
CREATE VIEW IndividualReservationsMonthlyReportView
AS SELECT * FROM IndividualsReservationsView AS r
WHERE DATEDIFF(DAY, r.ReservationDate, GETDATE()) <= 30;

-- View: IndividualReservationsWeeklyReportView
CREATE VIEW IndividualReservationsWeeklyReportView
AS SELECT * FROM IndividualsReservationsView AS r
WHERE DATEDIFF(DAY, r.ReservationDate, GETDATE()) <= 7;

-- View: CompaniesReservationsView
CREATE VIEW CompaniesReservationsView
AS SELECT r.ReservationID, r.CustomerID AS CompanyID, rg.CustomerID AS CompanyEmployeeID, rc.TableID, r.ReservationDate, r.FromDate
FROM Reservations AS r
INNER JOIN ReservationGroups AS rg
ON rg.ReservationID = r.ReservationID
INNER JOIN ReservationCompanies AS rc
ON rc.GroupID = rg.GroupID AND rc.ReservationID = r.ReservationID;

-- View: CompaniesMonthlyReservationsReportView
CREATE VIEW CompaniesMonthlyReservationsReportView
AS SELECT * FROM CompaniesReservationsView
WHERE DATEDIFF(DAY, ReservationDate, GETDATE()) <= 30;

-- View: CompaniesWeeklyReservationsReportView
CREATE VIEW CompaniesWeeklyReservationsReportView
AS SELECT * FROM CompaniesReservationsView
WHERE DATEDIFF(DAY, ReservationDate, GETDATE()) <= 7;

-- View: CurrentCompaniesReservationsView
CREATE VIEW CurrentCompaniesReservationsView
AS SELECT *
FROM CompaniesReservationsView
WHERE DATEDIFF(DAY, ReservationDate, GETDATE()) = 0;

-- View: DishPopularityView
CREATE VIEW DishPopularityView
AS SELECT d.DishID, d.DishName, SUM(od.Quantity) AS TotalQuantity
FROM Dishes AS d
INNER JOIN MenuItems AS mi
ON d.DishID = mi.DishID
INNER JOIN OrderDetails AS od
ON mi.ItemID = od.ItemID
GROUP BY d.DishID, d.DishName;

-- View: DishIncomeView
CREATE VIEW DishIncomeView
AS SELECT mi.DishID, SUM(od.Quantity * mi.UnitPrice * (1 - odtv.DiscountValue / 100)) AS TotalIncome
FROM MenuItems AS mi
INNER JOIN OrderDetails AS od
ON od.ItemID = mi.ItemID
INNER JOIN OrdersDiscountsTableView AS odtv
ON odtv.OrderID = od.OrderID
GROUP BY mi.DishID;

-- View: SeafoodMenuView
CREATE VIEW SeafoodMenuView
AS SELECT mi.ItemID, d.DishID, d.DishName
FROM MenuItems AS mi
INNER JOIN Dishes AS d
ON d.DishID=mi.DishID
INNER JOIN Categories AS c
ON d.CategoryID=c.CategoryID
WHERE c.CategoryName = 'Seafood';

-- View: SeafoodWeekOrdersView
CREATE VIEW SeafoodWeekOrdersView
AS SELECT o.OrderID, od.ItemID, od.Quantity, o.OrderDate, o.OutDate
FROM SeafoodMenuView AS smv
INNER JOIN OrderDetails AS od
ON od.ItemID = smv.ItemID
INNER JOIN Orders AS o
ON o.OrderID = od.OrderID
WHERE DATEDIFF(DAY, o.OrderDate, GETDATE()) <= 7;

-- View: PendingOrdersView
CREATE VIEW PendingOrdersView
AS SELECT *
FROM Orders
WHERE OutDate IS NULL OR OutDate > GETDATE();

-- View: IndividualCustomersView
CREATE VIEW IndividualCustomersView
AS SELECT c.CustomerID, p.FirstName, p.LAStName, c.Email, c.Phone
FROM IndividualCustomers AS ic
INNER JOIN People AS p
ON ic.PersonID = p.PersonID
INNER JOIN Customers AS c
ON c.CustomerID = ic.CustomerID;

-- View: CompanyEmployeesView
CREATE VIEW CompanyEmployeesView
AS SELECT cu.CustomerID, p.FirstName, p.LAStName, cu.Email, cu.Phone, co.CustomerID AS CompanyID, co.CompanyName
FROM CompanyEmployees AS ce
INNER JOIN Companies AS co
ON co.CustomerID = ce.CompanyID
INNER JOIN Customers AS cu
ON cu.CustomerID = ce.CustomerID
INNER JOIN People AS p
ON p.PersonID = ce.PersonID;

-- View: TakeoutOrdersView
CREATE VIEW TakeoutOrdersView
AS SELECT *
FROM Orders
WHERE OrderID IN (
  SELECT OrderID FROM TakeoutOrders
);
  
-- View: VacantTablesView
CREATE VIEW VacantTablesView
AS SELECT *
FROM Tables
WHERE TableID NOT IN (
  SELECT TableID
  FROM CurrentCompaniesReservationsView
  UNION 
  SELECT TableID
  FROM CurrentIndividualsReservationsView
);

-- View: CustomerOneTimeDiscountsView
CREATE VIEW CustomerOneTimeDiscountsView
AS SELECT c.CustomerID, otd.DiscountValue, otd.AvailableFrom, otd.AvailableTo
FROM Customers AS c
INNER JOIN IndividualCustomers AS ic
ON c.CustomerID = ic.CustomerID
INNER JOIN OneTimeDiscount AS otd
ON otd.CustomerID = ic.CustomerID;

-- View: CustomerPermanentDiscountsView
CREATE VIEW CustomerPermanentDiscountsView
AS SELECT ic.CustomerID, pd.DiscountValue, pd.AvailableFrom
FROM IndividualCustomers AS ic
INNER JOIN PermanentDiscount AS pd
ON pd.CustomerID = ic.CustomerID;

-- View: UnpaidOrdersView
CREATE VIEW UnpaidOrdersView
AS SELECT OrderID, CustomerID, OrderDate
FROM Orders
WHERE PaymentTypeID IS NULL;

-- View: CurrentOneTimeDiscountParamsView
CREATE VIEW CurrentOneTimeDiscountParamsView
AS SELECT ParamName, Value, AvailableFrom
FROM DiscountParamsTableView
WHERE ParamName IN ('K2', 'R2', 'D1')
  AND (AvailableTo IS NULL
  OR AvailableTo > GETDATE());

-- View: CurrentPermanentDiscountParamsView
CREATE VIEW CurrentPermanentDiscountParamsView
AS SELECT ParamName, Value, AvailableFrom
FROM DiscountParamsTableView
WHERE ParamName IN ('Z1', 'K1', 'R1')
  AND (AvailableTo IS NULL
  OR AvailableTo > GETDATE());

-- View: IndividualCustomersOrdersView
CREATE VIEW IndividualCustomersOrdersView
AS SELECT
  o.CustomerID,
  SUM(od.Quantity * mi.UnitPrice * (1 - odtv.DiscountValue / 100)) AS TotalPrice,
  o.OrderDate,
  o.OutDate
FROM IndividualCustomers AS ic
INNER JOIN Orders AS o
ON o.CustomerID = ic.CustomerID
INNER JOIN OrderDetails AS od
ON od.OrderID = o.OrderID
INNER JOIN MenuItems AS mi
ON mi.ItemID = od.ItemID
INNER JOIN OrdersDiscountsTableView AS odtv
ON odtv.OrderID = o.OrderID
GROUP BY o.OrderID, o.OrderDate, o.OutDate, o.CustomerID;

-- View: IndividualCustomersMonthlyOrderReportView
CREATE VIEW IndividualCustomersMonthlyOrderReportView
AS SELECT * FROM IndividualCustomersOrdersView
WHERE DATEDIFF(DAY, OrderDate, GETDATE()) <= 30;

-- View: IndividualCustomersWeeklyOrderReportView
CREATE VIEW IndividualCustomersWeeklyOrderReportView
AS SELECT * FROM IndividualCustomersOrdersView
WHERE DATEDIFF(DAY, OrderDate, GETDATE()) <= 7;

-- View: CompanyCustomersOrdersView
CREATE VIEW CompanyCustomersOrdersView
AS SELECT
  o.OrderID,
  o.CustomerID,
  SUM(od.Quantity * mi.UnitPrice) AS TotalPrice,
  o.OrderDate,
  o.OutDate
FROM Companies AS c
INNER JOIN Orders AS o
ON o.CustomerID = c.CustomerID
INNER JOIN OrderDetails AS od
ON od.OrderID = o.OrderID
INNER JOIN MenuItems AS mi
ON mi.ItemID = od.ItemID
GROUP BY o.OrderID, o.OrderDate, o.OutDate, o.CustomerID;

-- View: CompanyCustomersMonthlyOrderReportView
CREATE VIEW CompanyCustomersMonthlyOrderReportView
AS SELECT * FROM CompanyCustomersOrdersView
WHERE DATEDIFF(DAY, OrderDate, GETDATE()) <= 30 ;

-- View: CompanyCustomersWeeklyOrderReportView
CREATE VIEW CompanyCustomersWeeklyOrderReportView
AS SELECT * FROM CompanyCustomersOrdersView
WHERE DATEDIFF(DAY, OrderDate, GETDATE()) <= 7;

-- View: CompanyEmployeesOrdersView
CREATE VIEW CompanyEmployeesOrdersView
AS SELECT
  o.OrderID,
  o.CustomerID,
  SUM(od.Quantity * mi.UnitPrice) AS TotalPrice,
  o.OrderDate,
  o.OutDate
FROM CompanyEmployees AS ce
INNER JOIN Orders AS o
ON o.CustomerID = ce.CustomerID
INNER JOIN OrderDetails AS od
ON od.OrderID = o.OrderID
INNER JOIN MenuItems AS mi
ON mi.ItemID = od.ItemID
GROUP BY o.OrderID, o.OrderDate, o.OutDate, o.CustomerID;

-- View: CompanyEmployeesMonthlyOrderReportView
CREATE VIEW CompanyEmployeesMonthlyOrderReportView
AS SELECT * FROM CompanyEmployeesOrdersView
WHERE DATEDIFF(DAY, OrderDate, GETDATE()) <= 30;

-- View: CompanyEmployeesWeeklyOrderReportView
CREATE VIEW CompanyEmployeesWeeklyOrderReportView
AS SELECT * FROM CompanyEmployeesOrdersView
WHERE DATEDIFF(DAY, OrderDate, GETDATE()) <= 7;

-- View: UsedDiscountsView
CREATE VIEW UsedDiscountsView
AS SELECT odtv.CustomerID, odtv.DiscountValue, (
  SELECT IIF(EXISTS(
     SELECT *
     FROM CustomerOneTimeDiscountsView AS cotdv
     WHERE cotdv.CustomerID = odtv.CustomerID
       AND cotdv.AvailableFrom <= odtv.OrderDate
       AND odtv.OrderDate <= cotdv.AvailableTo
 ), 'OTD', 'PD')) AS DiscountType
, odtv.OrderID, odtv.OrderDate, odtv.OutDate
FROM OrdersDiscountsTableView AS odtv
INNER JOIN IndividualCustomers AS ic
ON ic.CustomerID = odtv.CustomerID
INNER JOIN Customers AS c
ON c.CustomerID = odtv.CustomerID
WHERE odtv.DiscountValue > 0;

-- View: DiscountsMonthlyNumberView
CREATE VIEW DiscountsMonthlyNumberView
AS SELECT YEAR(OrderDate) AS UsedYear, MONTH(OrderDate) AS UsedMonth, DiscountType, COUNT(*) AS DiscountsNumber
FROM UsedDiscountsView
GROUP BY YEAR(OrderDate),MONTH(OrderDate),DiscountType;

-- View: OneTimeDiscountsMonthlyNumberView
CREATE VIEW OneTimeDiscountsMonthlyNumberView
AS SELECT UsedYear, UsedMonth, DiscountsNumber
FROM DiscountsMonthlyNumberView
WHERE DiscountType = 'OTD';

-- View: PermanentDiscountsMonthlyNumberView
CREATE VIEW PermanentDiscountsMonthlyNumberView
AS SELECT UsedYear, UsedMonth, DiscountsNumber
FROM DiscountsMonthlyNumberView
WHERE DiscountType = 'PD';

-- View: IndividualTableStatsView
CREATE VIEW IndividualTableStatsView
AS SELECT YEAR(r.ReservationDate) AS Year, MONTH(r.ReservationDate) AS Month, ri.TableID,COUNT(*) AS IndividualReservations
FROM Reservations AS r
INNER JOIN ReservationIndividuals AS ri
ON r.ReservationID = ri.ReservationID
GROUP BY YEAR(r.ReservationDate), MONTH(r.ReservationDate), ri.TableID;

-- View: CompanyTableStatsView
CREATE VIEW CompanyTableStatsView
AS SELECT YEAR(r.ReservationDate) AS Year, MONTH(r.ReservationDate) AS Month, rc.TableID,COUNT(DISTINCT r.ReservationID) AS CompanyReservations
FROM Reservations AS r
INNER JOIN ReservationCompanies AS rc
ON r.ReservationID=rc.ReservationID
GROUP BY YEAR(r.ReservationDate), MONTH(r.ReservationDate), rc.TableID;

--View: ReservedTablesView
CREATE VIEW ReservedTablesView
AS SELECT ri.TableID,r.FromDate
FROM ReservationIndividuals AS ri
INNER JOIN Reservations AS r
ON ri.ReservationID = r.ReservationID
UNION
SELECT rc.TableID,r.FromDate
FROM ReservationCompanies AS rc
INNER JOIN Reservations AS r
ON rc.ReservationID = r.ReservationID;

-- View: TimeOfDayOrdersNumView
CREATE VIEW TimeOfDayOrdersNumView
AS SELECT TOP 1
(SELECT TOP 1 COUNT(OrderID)
FROM Orders
WHERE DATEPART(HOUR, OrderDate) BETWEEN 7 AND 12
GROUP BY DATEPART(HOUR, OrderDate) WITH ROLLUP ORDER BY 1 DESC) AS 'Morning',
(SELECT TOP 1 COUNT(OrderID)
FROM Orders
WHERE DATEPART(HOUR, OrderDate) BETWEEN 13 AND 18
GROUP BY DATEPART(HOUR, OrderDate) WITH ROLLUP ORDER BY 1 DESC) AS 'Afternoon',
(SELECT TOP 1 COUNT(OrderID)
FROM Orders
WHERE DATEPART(HOUR, OrderDate) BETWEEN 19 AND 24
GROUP BY DATEPART(HOUR, OrderDate) WITH ROLLUP ORDER BY 1 DESC) AS 'Evening',
(SELECT TOP 1 COUNT(OrderID)
FROM Orders
WHERE DATEPART(HOUR, OrderDate) BETWEEN 0 AND 6
GROUP BY DATEPART(HOUR, OrderDate) WITH ROLLUP ORDER BY 1 DESC) AS 'Night'
FROM Orders;

-- View: SeASonsOrdersNumView
CREATE VIEW SeASonsOrdersNumView
AS SELECT TOP 1 
(SELECT TOP 1 COUNT(OrderID)
FROM Orders
WHERE MONTH(OrderDate) IN (12, 1, 2)
GROUP BY MONTH(OrderDate) WITH ROLLUP ORDER BY 1 DESC) AS 'Winter',
(SELECT TOP 1 COUNT(OrderID)
FROM Orders
WHERE MONTH(OrderDate) IN (3, 4, 5)
GROUP BY MONTH(OrderDate) WITH ROLLUP ORDER BY 1 DESC) AS 'Spring',
(SELECT TOP 1 COUNT(OrderID)
FROM Orders
WHERE MONTH(OrderDate) IN (6, 7, 8)
GROUP BY MONTH(OrderDate) WITH ROLLUP ORDER BY 1 DESC) AS 'Summer',
(SELECT TOP 1 COUNT(OrderID)
FROM Orders
WHERE MONTH(OrderDate) IN (9, 10, 11)
GROUP BY MONTH(OrderDate) WITH ROLLUP ORDER BY 1 DESC) AS 'Autumn'
FROM Orders;

-- View: ReservedTablesView
CREATE VIEW ReservedTablesView
AS SELECT ri.TableID,r.FromDate
FROM ReservationIndividuals AS ri
INNER JOIN Reservations AS r
ON ri.ReservationID=r.ReservationID
UNION
SELECT rc.TableID,r.FromDate
FROM ReservationCompanies AS rc
INNER JOIN Reservations AS r
ON rc.ReservationID = r.ReservationID;

-- View: DishesOlderThanTwoWeeksView
CREATE VIEW DishesOlderThanTwoWeeksView
AS SELECT * FROM CurrentMenuView
WHERE DATEDIFF(DAY, AvailableFrom, GETDATE()) > 14 
AND DishID NOT IN (SELECT ItemID FROM SeafoodMenuView);
