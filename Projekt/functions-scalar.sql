USE u_lopacins;

CREATE FUNCTION GetDiscountParamValue (@ParamName varchar(2))
RETURNS int
AS
BEGIN
  RETURN (
    SELECT Value
    FROM DiscountParamsTableView
    WHERE ParamName = @ParamName
      AND (AvailableTo IS NULL OR AvailableTo >= GETDATE())
  )
END;

CREATE FUNCTION GetOrderTotalAmount (@OrderID int)
RETURNS money
AS
BEGIN
  RETURN (
    SELECT SUM(od.Quantity * mi.UnitPrice * (1 - odtv.DiscountValue / 100)) AS TotalAmount
    FROM OrdersDiscountsTableView AS odtv
    INNER JOIN OrderDetails AS od
    ON odtv.OrderID = od.OrderID
    INNER JOIN MenuItems AS mi
    ON od.ItemID = mi.ItemID
    WHERE odtv.OrderID = @OrderID
  )
END;

-- Pass null to get sum of all orders amounts
CREATE FUNCTION GetAmountSpentByCustomer (@CustomerID int, @StartDate datetime NULL)
RETURNS money
AS
BEGIN
  RETURN (
    SELECT ISNULL(SUM(dbo.GetOrderTotalAmount(OrderID)), 0) AS TotalAmount
    FROM Orders
    WHERE CustomerID = @CustomerID AND
      (DATEDIFF(DAY, ISNULL(@StartDate, GETDATE()), OrderDate) >= 0
      OR @StartDate IS NULL)
  )
END;

CREATE FUNCTION GetLastOneTimeDiscountStartDate(@CustomerID int)
RETURNS datetime
AS
BEGIN
  RETURN (
    SELECT MAX(AvailableFrom)
    FROM CustomerOneTimeDiscountsView
    WHERE CustomerID = @CustomerID
  )
END;

CREATE FUNCTION CanCustomerGetOneTimeDiscount(@CustomerID int)
RETURNS bit
AS
BEGIN
  DECLARE @RequiredTotalAmount int = dbo.GetDiscountParamValue('K2');
  DECLARE @LastOneTimeDiscountStartDate datetime = dbo.GetLastOneTimeDiscountStartDate(@CustomerID)
  DECLARE @TotalAmountSpent money = dbo.GetAmountSpentByCustomer(@CustomerID, @LastOneTimeDiscountStartDate);
  IF @TotalAmountSpent >= @RequiredTotalAmount AND @CustomerID IN (
    SELECT CustomerID FROM IndividualCustomers
  )
  BEGIN
    RETURN 1;
  END
  RETURN 0;
END;

select CustomerID, dbo.CanCustomerGetPermanentDiscount(CustomerID)
from Customers;

CREATE FUNCTION CanCustomerGetPermanentDiscount(@CustomerID int)
RETURNS bit
AS
BEGIN
  DECLARE @RequiredOrdersNumber int = dbo.GetDiscountParamValue('Z1');
  DECLARE @MinOrderAmount int = dbo.GetDiscountParamValue('K1');
  IF @CustomerID IN (
      SELECT CustomerID FROM IndividualCustomers
    ) AND (SELECT COUNT(OrderID)
      FROM Orders
      WHERE CustomerID = @CustomerID AND
      dbo.GetOrderTotalAmount(OrderID) >= @MinOrderAmount) > @RequiredOrdersNumber
  BEGIN
    RETURN 1;
  END
  RETURN 0;
END;

CREATE FUNCTION IsHalfMenuItemsOlderThanTwoWeeks()
RETURNS bit
AS
BEGIN
  DECLARE @MenuLen int = (
    SELECT COUNT(*)
    FROM CurrentMenuView
    WHERE DATEDIFF(DAY, AvailableFrom, GETDATE()) >= 14
      AND DishID NOT IN (SELECT DishID FROM SeafoodMenuView)
  );
  DECLARE @DishesOlderThanTwoWeeksCount int = (
    SELECT COUNT(*)
    FROM DishesOlderThanTwoWeeksView
  );
  IF @DishesOlderThanTwoWeeksCount > CAST(@MenuLen AS FLOAT) / 2
  BEGIN
    RETURN 1;
  END
  RETURN 0;
END;

CREATE FUNCTION CheckMenuItemsReplacementStatus()
RETURNS varchar(55)
AS
BEGIN
  IF dbo.IsHalfMenuItemsOlderThanTwoWeeks() = 1
    BEGIN
      RETURN 'More than half of the menu items is at least 2 weeks old'
    END
  RETURN 'It is not necessary to replace menu items now'
END;
