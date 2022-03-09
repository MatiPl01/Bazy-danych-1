USE u_lopacins;

CREATE FUNCTION GenerateOrderInvoice (@OrderID int)
RETURNS @Invoice TABLE (ParamName varchar(150), ParamValue varchar(50))
AS
BEGIN
  -- General information
  DECLARE @CompanyName varchar(30);
  DECLARE @NIP varchar(15);
  DECLARE @Phone varchar(15);
  DECLARE @Email varchar(40);
  DECLARE @isTakeout bit;
  DECLARE @OrderDate datetime;
  DECLARE @OutDate datetime;

  SELECT
    @CompanyName = co.CompanyName,
    @NIP = co.NIP,
    @Phone = cu.Phone,
    @Email = cu.Email,
    @isTakeout = (
      SELECT CAST(
        IIF(tk.OrderID IS NULL, 1, 0)
      AS BIT)
    ),
    @OrderDate = o.OrderDate,
    @OutDate = o.OutDate
  FROM Customers AS cu
  INNER JOIN Companies AS co
  ON cu.CustomerID = co.CustomerID
  INNER JOIN Orders AS o
  ON o.CustomerID = co.CustomerID
  LEFT OUTER JOIN TakeoutOrders AS tk
  ON tk.OrderID = o.OrderID
  WHERE o.OrderID = @OrderID;

  INSERT INTO @Invoice VALUES ('Company name:', CAST(@CompanyName AS varchar(50)));
  INSERT INTO @Invoice VALUES ('NIP:', CAST(@NIP AS varchar(50)));
  INSERT INTO @Invoice VALUES ('E-mail:', CAST(@Email AS varchar(50)));
  INSERT INTO @Invoice VALUES ('Phone:', CAST(@Phone AS varchar(50)));
  INSERT INTO @Invoice VALUES ('Order date:', CAST(@OrderDate AS varchar(50)));
  INSERT INTO @Invoice VALUES ('Out date:', CAST(@OutDate AS varchar(50)));

  -- Detailed list of ordered dishes
  DECLARE @ItemID int;
  DECLARE @DishName varchar(40);
  DECLARE @UnitPrice money;
  DECLARE @Quantity int;
  DECLARE @TotalItemAmount money;

  DECLARE CUR CURSOR FOR SELECT ItemID, Quantity FROM OrderDetails WHERE OrderID = @OrderID
  OPEN CUR
  FETCH NEXT FROM CUR INTO @ItemID, @Quantity
  WHILE @@FETCH_STATUS=0
  BEGIN
    SELECT
      @DishName = d.DishName,
      @UnitPrice = mi.UnitPrice,
      @TotalItemAmount = @Quantity * mi.UnitPrice
    FROM MenuItems AS mi
    INNER JOIN Dishes AS d
    ON d.DishID = mi.DishID
    WHERE mi.ItemID = @ItemID;

    INSERT @Invoice VALUES (CONCAT('Dish name: ', @DishName,
                                 ', Quantity: ', @Quantity,
                                 ', Unit price: ', @UnitPrice,
                                 ', Total dish price: '), @Quantity * @UnitPrice);

    FETCH NEXT FROM CUR INTO @ItemID, @Quantity
  END
  CLOSE CUR
  DEALLOCATE CUR

 -- Order summary
  DECLARE @TotalAmount money = dbo.GetOrderTotalAmount(@OrderID);
    INSERT INTO @Invoice VALUES ('Total order amount: ', @TotalAmount);
  RETURN;
END;


CREATE FUNCTION GenerateMonthlyInvoice (@CompanyID int)
  RETURNS @Invoice TABLE (OrderID varchar(40), OrderValue money)
  AS
  BEGIN
    DECLARE @CompanyName varchar(30) = (
        SELECT CompanyName FROM Companies WHERE CustomerID = @CompanyID);
    DECLARE @NIP varchar(30) = (
        SELECT NIP FROM Companies WHERE CustomerID = @CompanyID);
    DECLARE @Phone varchar(30) = (
        SELECT Phone FROM Customers WHERE CustomerID = @CompanyID);
    DECLARE @Email varchar(30) = (
        SELECT Email FROM Customers WHERE CustomerID = @CompanyID);
    INSERT INTO @Invoice VALUES (CONCAT('Company name: ', @CompanyName), NULL)
    INSERT INTO @Invoice VALUES (CONCAT('NIP: ', @NIP), NULL)
    INSERT INTO @Invoice VALUES (CONCAT('Phone: ', @Phone), NULL)
    INSERT INTO @Invoice VALUES (CONCAT('E-mail: ', @Email), NULL)
    INSERT INTO @Invoice VALUES ('Orders:', NULL)

    DECLARE @OrderID int
    DECLARE @OrderValue money
    DECLARE CUR CURSOR FOR SELECT OrderID,TotalPrice FROM CompanyCustomersMonthlyOrderReportView WHERE CustomerID=@CompanyID
    OPEN CUR
    FETCH NEXT FROM CUR INTO @OrderID, @OrderValue
    WHILE @@FETCH_STATUS=0
    BEGIN
      INSERT @Invoice VALUES (@OrderID, @OrderValue)
      FETCH NEXT FROM CUR INTO @OrderID, @OrderValue
    END
    CLOSE CUR
    DEALLOCATE CUR
    DECLARE @TotalValue money
    SELECT @TotalValue=(SELECT SUM(TotalPrice) FROM CompanyCustomersMonthlyOrderReportView WHERE CustomerID=@CompanyID)
    INSERT INTO @Invoice VALUES ('Total value:',@TotalValue)
  RETURN
END;


CREATE FUNCTION GetIndividualTablesReservationsStatistics (@DaysNum int NULL)
RETURNS TABLE
AS
RETURN (
  SELECT ri.TableID, COUNT(*) AS IndividualReservations
  FROM Reservations AS r
  INNER JOIN ReservationIndividuals AS ri
  ON r.ReservationID = ri.ReservationID
  WHERE (@DaysNum IS NULL
    OR DATEDIFF(DAY, r.ReservationDate, GETDATE()) <= @DaysNum)
  GROUP BY ri.TableID
);

CREATE FUNCTION GetCompanyTablesReservationsStatistics (@DaysNum int NULL)
RETURNS TABLE
AS
RETURN (
  SELECT rc.TableID, COUNT(*) as CompanyReservations
  FROM Reservations as r
  INNER JOIN ReservationCompanies as rc on r.ReservationID=rc.ReservationID
  WHERE (@DaysNum IS NULL OR DATEDIFF(DAY, r.ReservationDate, GETDATE()) <= @DaysNum)
  GROUP BY rc.TableID
);

CREATE FUNCTION GetCustomerDiscountsStatistics (@CustomerID int, @DaysNum int NULL)
RETURNS TABLE
AS
RETURN (
  SELECT DiscountType, DiscountValue, COUNT(*) AS NumOfUses
  FROM UsedDiscountsView
  WHERE CustomerID = @CustomerID AND
    (@DaysNum IS NULL OR DATEDIFF(DAY, OrderDate, GETDATE()) <= @DaysNum)
  GROUP BY DiscountType, DiscountValue
);

CREATE FUNCTION GetMenuStatistics (@DaysNum int NULL)
RETURNS TABLE
AS
RETURN (
  SELECT mi.ItemID, d.DishName, COUNT(*) AS Quantity, SUM(od.Quantity * mi.UnitPrice * (1 - odtv.DiscountValue / 100)) AS TotalAMount
  FROM MenuItems AS mi
  INNER JOIN Dishes AS d
  ON d.DishID = mi.DishID
  INNER JOIN OrderDetails AS od
  ON od.ItemID = d.DishID
  INNER JOIN OrdersDiscountsTableView AS odtv
  ON odtv.OrderID = od.OrderID
  WHERE (@DaysNum IS NULL OR DATEDIFF(DAY, odtv.OrderDate, GETDATE()) <= @DaysNum)
  GROUP BY mi.ItemID, d.DishName, mi.AvailableTo
);

CREATE FUNCTION GetOrdersStatistics (@CustomerID int, @DaysNum int NULL)
RETURNS TABLE
AS
RETURN (
  SELECT
    o.OrderID,
    SUM(od.Quantity * mi.UnitPrice * (1 - odtv.DiscountValue / 100)) AS TotalAmount,
    o.OrderDate
  FROM OrdersDiscountsTableView AS odtv
  INNER JOIN OrderDetails AS od
  ON od.OrderID = odtv.OrderID
  INNER JOIN MenuItems AS mi
  ON mi.ItemID = od.ItemID
  INNER JOIN Orders AS o
  ON o.OrderID = od.OrderID
  WHERE o.CustomerID = @CustomerID
    AND (@DaysNum IS NULL OR DATEDIFF(DAY, odtv.OrderDate, GETDATE()) <= @DaysNum)
  GROUP BY o.OrderID, o.OrderDate
);
