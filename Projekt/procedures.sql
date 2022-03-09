USE u_lopacins;

-- Procedure:
CREATE PROCEDURE AddIndividualCustomer
  @FirstName varchar(20),
  @LastName varchar(20),
  @Email varchar(40),
  @Phone varchar(15)
AS
BEGIN
  BEGIN TRY
    INSERT INTO People (FirstName, LastName) VALUES (@FirstName, @LastName);
    DECLARE @PersonID int;
    SELECT @PersonID = SCOPE_IDENTITY();

    INSERT INTO Customers (Email, Phone) VALUES (@Email, @Phone);
    DECLARE @CustomerID int;
    SELECT @CustomerID = SCOPE_IDENTITY();

    INSERT INTO IndividualCustomers(CustomerID, PersonID) VALUES (@CustomerID, @PersonID);
  END TRY
  BEGIN CATCH
    DELETE FROM Customers WHERE CustomerID = @CustomerID
    DELETE FROM People WHERE PersonID = @PersonID
    DELETE FROM IndividualCustomers WHERE CustomerID = @CustomerID
    DECLARE @errorMsg nvarchar(1024) = 'Error while inserting Individual Customer: '
    + ERROR_MESSAGE();
    THROW 52000, @errorMsg, 1;
  END CATCH;
END;

-- Procedure:
CREATE PROCEDURE AddCompany
  @CompanyName varchar(30),
  @NIP varchar(15),
  @Email varchar(40),
  @Phone varchar(15)
AS
BEGIN
  BEGIN TRY
    INSERT INTO Customers (Email, Phone) VALUES (@Email, @Phone);
    DECLARE @CustomerID int;
    SELECT @CustomerID = SCOPE_IDENTITY();

    INSERT INTO Companies(CustomerID, CompanyName, NIP) VALUES (@CustomerID, @CompanyName, @NIP);
  END TRY
  BEGIN CATCH
    DELETE FROM Customers WHERE CustomerID = @CustomerID
    DELETE FROM Companies WHERE CustomerID = @CustomerID
    DECLARE @errorMsg nvarchar(1024) = 'Error while inserting Company: '
    + ERROR_MESSAGE();
    THROW 52000, @errorMsg, 1;
  END CATCH;
END;

 -- Procedure:
CREATE PROCEDURE AddCompanyEmployee
  @FirstName varchar(20),
  @LastName varchar(20),
  @Email varchar(40),
  @Phone varchar(15),
  @CompanyID int
AS
BEGIN
  IF NOT EXISTS(
    SELECT *
    FROM Companies
    WHERE CustomerID = @CompanyID
  )
  BEGIN
    DECLARE @errorMsg1 nvarchar(1024) = 'Company does not exist';
    THROW 52000, @errorMsg1, 1;
  END;
  BEGIN TRY
    INSERT INTO People (FirstName, LastName) VALUES (@FirstName, @LastName);
    DECLARE @PersonID int;
    SELECT @PersonID = SCOPE_IDENTITY();

    INSERT INTO Customers (Email, Phone) VALUES (@Email, @Phone);
    DECLARE @CustomerID int;
    SELECT @CustomerID = SCOPE_IDENTITY();

    INSERT INTO CompanyEmployees(CustomerID, CompanyID, PersonID) VALUES (@CustomerID, @CompanyID, @PersonID);
  END TRY
  BEGIN CATCH
    DELETE FROM Customers WHERE CustomerID = @CustomerID
    DELETE FROM People WHERE PersonID = @PersonID
    DELETE FROM CompanyEmployees WHERE CustomerID = @CustomerID
    DECLARE @errorMsg2 nvarchar(1024) = 'Error while inserting Company Employee: '
    + ERROR_MESSAGE();
    THROW 52000, @errorMsg2, 1;
  END CATCH;
END;

-- Procedure:
CREATE PROCEDURE AddRestaurantEmployee
  @FirstName varchar(20),
  @LastName varchar(20),
  @ReportsTo int,
  @Title varchar(20)
AS
BEGIN
  IF NOT EXISTS(
    SELECT *
    FROM RestaurantEmployees
    WHERE EmployeeID = @ReportsTo
  )
  BEGIN
    DECLARE @errorMsg1 nvarchar(1024) = 'Employee does not exist';
    THROW 52000, @errorMsg1, 1;
  END;
  BEGIN TRY
    INSERT INTO People (FirstName, LastName) VALUES (@FirstName, @LastName);
    DECLARE @PersonID int;
    SELECT @PersonID = SCOPE_IDENTITY();

    INSERT INTO RestaurantEmployees (PersonID, ReportsTo, Title) VALUES (@PersonID, @ReportsTo, @Title)
    DECLARE @EmployeeID int;
    SELECT @EmployeeID = SCOPE_IDENTITY();
  END TRY
  BEGIN CATCH
    DELETE FROM RestaurantEmployees WHERE EmployeeID = @EmployeeID
    DELETE FROM People WHERE PersonID = @PersonID
    DECLARE @errorMsg2 nvarchar(1024) = 'Error while inserting Restaurant Employee: '
    + ERROR_MESSAGE();
    THROW 52000, @errorMsg2, 1;
  END CATCH;
END;

-- Procedure:
CREATE PROCEDURE AddCategory
  @CategoryName varchar(20),
  @Description varchar(100)
AS
BEGIN
  BEGIN TRY
    INSERT INTO Categories (CategoryName, Description) VALUES (@CategoryName, @Description);
  END TRY
  BEGIN CATCH
    DECLARE @errorMsg nvarchar(1024) = 'Error while inserting Category: '
    + ERROR_MESSAGE();
    THROW 52000, @errorMsg, 1;
  END CATCH;
END;

-- Procedure:
CREATE PROCEDURE AddDish
  @CategoryID int,
  @DishName varchar(40),
  @Description varchar(100)
AS
BEGIN
  IF NOT EXISTS(
    SELECT *
    FROM Categories
    WHERE CategoryID = @CategoryID
  )
  BEGIN
    DECLARE @errorMsg1 nvarchar(1024) = 'Category does not exist';
    THROW 52000, @errorMsg1, 1;
  END;

  BEGIN TRY
    INSERT INTO Dishes (CategoryID, DishName, Description) VALUES (@CategoryID, @DishName, @Description);
  END TRY
  BEGIN CATCH
    DECLARE @errorMsg2 nvarchar(1024) = 'Error while inserting Dish: '
    + ERROR_MESSAGE();
    THROW 52000, @errorMsg2, 1;
  END CATCH
END;

-- Procedure:
CREATE PROCEDURE AddMenuItem
  @DishID int,
  @UnitPrice money,
  @UnitsOnOrder int,
  @AvailableFrom datetime,
  @AvailableTo datetime
AS
BEGIN
  IF NOT EXISTS(
    SELECT *
    FROM Dishes
    WHERE DishID = @DishID
  )
  BEGIN
    DECLARE @errorMsg1 nvarchar(1024) = 'Dish with ID' + @DishID + 'does not exist';
    THROW 52000, @errorMsg1, 1;
  END;

  BEGIN TRY
    INSERT INTO MenuItems (DishID, UnitPrice, UnitsOnOrder, AvailableFrom, AvailableTo) VALUES (@DishID, @UnitPrice, @UnitsOnOrder, @AvailableFrom, @AvailableTo);
  END TRY
  BEGIN CATCH
    DECLARE @errorMsg2 nvarchar(1024) = 'Error while inserting Menu Item: '
    + ERROR_MESSAGE();
    THROW 52000, @errorMsg2, 1;
  END CATCH
END;

--Procedure:
CREATE PROCEDURE DeleteItemFromCurrentMenu
  @ItemID int
AS
BEGIN
  IF NOT EXISTS(
    SELECT *
    FROM MenuItems
    WHERE ItemID = @ItemID
  )
    BEGIN
      DECLARE @errorMsg nvarchar(1024) = 'Dish does not exist in menu';
      THROW 52000, @errorMsg, 1;
    END;

  IF (
    SELECT AvailableTo
    FROM MenuItems
    WHERE ItemID = @ItemID
  ) IS NOT NULL
    BEGIN
      DECLARE @errorMsg1 nvarchar(1024) = 'Dish already not in current menu';
      THROW 52000, @errorMsg1, 1;
    END;
  BEGIN TRY
    UPDATE MenuItems SET AvailableTo = GETDATE() WHERE ItemID = @ItemID
  END TRY
  BEGIN CATCH
    DECLARE @errorMsg2 nvarchar(1024) = 'Error while deleting dish from current menu';
    THROW 52000, @errorMsg2, 1;
  END CATCH;
END;

-- Procedure:
CREATE PROCEDURE UpdateDiscountParam
  @ParamName varchar(2),
  @Value int
AS
BEGIN
  IF NOT EXISTS(
    SELECT *
    FROM DiscountParamsDict
    WHERE ParamName = @ParamName
  )
  BEGIN
    DECLARE @errorMsg1 nvarchar(1024) = 'Discount Param does not exist';
    THROW 52000, @errorMsg1, 1;
  END;

  DECLARE @ParamID int;
  SELECT @ParamID = (
    SELECT ParamID
    FROM DiscountParamsDict
    WHERE ParamName = @ParamName
  );
  BEGIN TRY
    UPDATE DiscountParams SET AvailableTo = GETDATE() WHERE (AvailableTo IS NULL) AND ParamID = @ParamID;
    INSERT INTO DiscountParams(ParamID, Value) VALUES (@ParamID, @Value);
  END TRY
  BEGIN CATCH
    DECLARE @ConstID int;
    SELECT @ConstID = (
      SELECT TOP 1 ConstID
      FROM DiscountParams
      WHERE ParamID = @ParamID
      ORDER BY AvailableFrom DESC
    );
    UPDATE DiscountParams SET AvailableTo = NULL WHERE ConstID = @ConstID;
    DECLARE @errorMsg2 nvarchar(1024) = 'Error while inserting Discount Param: '
    + ERROR_MESSAGE();
    THROW 52000, @errorMsg2, 1;
  END CATCH
END;

-- Procedure:
CREATE PROCEDURE GrantOneTimeDiscount
  @CustomerID int
AS
BEGIN
  -- Check if the specified Customer is allowed to be granted a discount
  IF dbo.CanCustomerGetOneTimeDiscount(@CustomerID) = 1
  BEGIN
    BEGIN TRY
      -- Get discount parameters
      DECLARE @DiscountValue int = dbo.GetDiscountParamValue('R2');
      DECLARE @DiscountPeriod int = dbo.GetDiscountParamValue('D1')
      DECLARE @AvailableFrom datetime = GETDATE();
      DECLARE @AvailableTo datetime = DATEADD(DAY, @DiscountPeriod, @AvailableFrom);

      INSERT INTO OneTimeDiscount(CustomerID, DiscountValue, AvailableFrom, AvailableTo)
      VALUES (@CustomerID, @DiscountValue, @AvailableFrom, @AvailableTo);
    END TRY
    BEGIN CATCH
      DECLARE @errorMsg1 nvarchar(1024) = 'Error while inserting to OneTimeDiscount: '
      + ERROR_MESSAGE();
      THROW 52000, @errorMsg1, 1;
    END CATCH
  END
  ELSE
  BEGIN
    DECLARE @errorMsg2 nvarchar(1024) = CONCAT('Customer ', @CustomerID, ' is not eligible for One Time Discount');
    THROW 52000, @errorMsg2, 1;
  END
END;

-- Procedure:
CREATE PROCEDURE GrantPermanentDiscount
  @CustomerID int
AS
BEGIN
  -- Check if the specified Customer already has been granted a Permanent Discount
  IF EXISTS(
    SELECT *
    FROM PermanentDiscount
    WHERE CustomerID = @CustomerID
  )
  BEGIN
    DECLARE @errorMsg1 nvarchar(1024) = CONCAT('Customer ', @CustomerID, ' has already been granted a Permanent Discount');
    THROW 52000, @errorMsg1, 1;
  END
  -- Check if the specified Customer is allowed to be granted a discount
  IF dbo.CanCustomerGetPermanentDiscount(@CustomerID) = 1
  BEGIN
   BEGIN TRY
      -- Get discount parameters
      DECLARE @DiscountValue int = dbo.GetDiscountParamValue('R1');
      DECLARE @AvailableFrom datetime = GETDATE();

      INSERT INTO PermanentDiscount(CustomerID, DiscountValue, AvailableFrom)
      VALUES (@CustomerID, @DiscountValue, @AvailableFrom);
    END TRY
    BEGIN CATCH
      DECLARE @errorMsg2 nvarchar(1024) = 'Error while inserting to PermanentDiscount: '
      + ERROR_MESSAGE();
      THROW 52000, @errorMsg2, 1;
    END CATCH;
  END;
  ELSE
  BEGIN
    DECLARE @errorMsg3 nvarchar(1024) = CONCAT('Customer ', @CustomerID, ' is not eligible for Permanent Discount');
    THROW 52000, @errorMsg3, 1;
  END
END;

-- Procedure:
CREATE PROCEDURE PlaceOrder
  @CustomerID int,
  @EmployeeID int,
  @PaymentTypeID int,
  @IsTakeout bit,
  @OutDate datetime
AS
BEGIN
  IF NOT EXISTS(
    SELECT *
    FROM RestaurantEmployees
    WHERE EmployeeID = @EmployeeID
  )
    BEGIN
      DECLARE @errorMsg1 nvarchar(1024) = 'Employee does not exist';
      THROW 52000, @errorMsg1, 1;
    END;

  IF @CustomerID IS NOT NULL
  BEGIN
    IF NOT EXISTS(
      SELECT *
      FROM Customers
      WHERE CustomerID = @CustomerID
    )
    BEGIN
      DECLARE @errorMsg2 nvarchar(1024) = 'Customer does not exist';
      THROW 52000, @errorMsg2, 1;
    END;
  END;

  IF @PaymentTypeID IS NOT NULL
  BEGIN
    IF NOT EXISTS(
      SELECT *
      FROM Payment
      WHERE PaymentTypeID = @PaymentTypeID
    )
    BEGIN
      DECLARE @errorMsg3 nvarchar(1024) = 'Payment Method does not exist';
      THROW 52000, @errorMsg3, 1;
    END;
  END;
  BEGIN TRY
    INSERT INTO Orders(CustomerID, EmployeeID, PaymentTypeID, OutDate) VALUES (@CustomerID, @EmployeeID, @PaymentTypeID, @OutDate)
    DECLARE @OrderID int;
    SELECT @OrderID = SCOPE_IDENTITY();
    IF @IsTakeout=1
    BEGIN
      INSERT INTO TakeoutOrders(OrderID) VALUES (@OrderID);
    END;
  END TRY
  BEGIN CATCH
    DECLARE @errorMsg4 nvarchar(1024) = 'Error while adding Order: '
    + ERROR_MESSAGE();
    THROW 52000, @errorMsg4, 1;
  END CATCH
END;

-- Procedure:
CREATE PROCEDURE AddItemToOrder
  @OrderID int,
  @ItemID int,
  @Quantity int
AS
BEGIN
  IF NOT EXISTS(SELECT * FROM CurrentMenuView WHERE ItemID = @ItemID)
    BEGIN
      DECLARE @errorMsg1 nvarchar(1024) = 'Menu Item does not exist';
      THROW 52000, @errorMsg1, 1;
    END;

  IF NOT EXISTS(SELECT * FROM Orders WHERE OrderID = @OrderID)
    BEGIN
      DECLARE @errorMsg2 nvarchar(1024) = 'Order does not exist';
      THROW 52000, @errorMsg2, 1;
    END;

  IF (SELECT CategoryName
      FROM MenuItems as mi
      INNER JOIN Dishes as d ON mi.DishID=d.DishID
      INNER JOIN Categories as c ON c.CategoryID=d.CategoryID
      WHERE mi.ItemID=@ItemID)='Seafood'
    BEGIN
      DECLARE @OutDate datetime;
      SELECT @OutDate = (SELECT OutDate FROM Orders WHERE OrderID=@OrderID);
      DECLARE @MondayDate datetime;
      SELECT @MondayDate = DATEADD(DAY, -DATEPART(WEEKDAY, @OutDate)+2, @OutDate);
      IF DATEPART(WEEKDAY,@OutDate) < 5 OR DATEPART(WEEKDAY,@OutDate) > 7
      BEGIN
        DECLARE @errorMsg3 nvarchar(1024) = 'Seafood can only be ordered for a day between Thursday and Saturday';
        THROW 52000, @errorMsg3, 1;
      END;
      IF (SELECT OrderDate FROM Orders WHERE OrderID=@OrderID)>@MondayDate
      BEGIN
        DECLARE @errorMsg4 nvarchar(1024) = 'Seafood can only be ordered before Monday preceding order date';
        THROW 52000, @errorMsg4, 1;
      END;
    END;

    BEGIN TRY
      INSERT INTO OrderDetails(OrderID,ItemID,Quantity) VALUES (@OrderID,@ItemID,@Quantity)
    END TRY
    BEGIN CATCH
      DECLARE @errorMsg nvarchar(1024) = 'Error while adding order item: '
      + ERROR_MESSAGE();
      THROW 52000, @errorMsg, 1;
    END CATCH;
END;

-- Procedure:
CREATE PROCEDURE PayOrder
  @OrderID int,
  @PaymentTypeID int
AS
BEGIN
  IF NOT EXISTS(SELECT * FROM Payment WHERE PaymentTypeID=@PaymentTypeID)
  BEGIN
    DECLARE @errorMsg1 nvarchar(1024) = 'Payment Type does not exist';
    THROW 52000, @errorMsg1, 1;
  END;

  IF NOT EXISTS(SELECT * FROM Orders WHERE OrderID=@OrderID)
  BEGIN
    DECLARE @errorMsg2 nvarchar(1024) = 'Order does not exist';
    THROW 52000, @errorMsg2, 1;
  END;

  IF (SELECT PaymentTypeID FROM Orders WHERE OrderID=@OrderID) IS NOT NULL
  BEGIN
    DECLARE @errorMsg3 nvarchar(1024) = 'Order is already paid';
    THROW 52000, @errorMsg3, 1;
  END;

  BEGIN TRY
    UPDATE Orders SET PaymentTypeID=@PaymentTypeID WHERE OrderID=@OrderID
  END TRY
  BEGIN CATCH
    DECLARE @errorMsg nvarchar(1024) = 'Error while setting payment type: '
    + ERROR_MESSAGE();
    THROW 52000, @errorMsg, 1;
  END CATCH
END;

-- Procedure:
CREATE PROCEDURE ReceiveOrder
  @OrderID int,
  @OutDate datetime
AS
BEGIN
  IF NOT EXISTS (SELECT OrderID FROM Orders WHERE OrderID = @OrderID)
    BEGIN
      DECLARE @errorMsg nvarchar(1024) = 'Order does not exist' + ERROR_MESSAGE();
      THROW 52000, @errorMsg, 1;
    END;

  IF (SELECT OutDate FROM Orders WHERE OrderID = @OrderID) IS NOT NULL
    BEGIN
      DECLARE @errorMsg1 nvarchar(1024) = 'Order already received' + ERROR_MESSAGE();
      THROW 52000, @errorMsg1, 1;
    END;

    BEGIN TRY
      UPDATE Orders SET OutDate=@OutDate WHERE OrderID=@OrderID;
    END TRY
    BEGIN CATCH
      DECLARE @errorMsg2 nvarchar(1024) = 'Error while receiving order: ' + ERROR_MESSAGE();
      THROW 52000, @errorMsg2, 1;
    END CATCH;
END;

-- Procedure:
CREATE PROCEDURE UpdateReservationConditions
@MinValue int,
@MinOrdersNum int,
@MinPeopleNum int
AS
BEGIN
  BEGIN TRY
    UPDATE ReservationConditions SET MinValue = @MinValue, MinOrdersNum = @MinOrdersNum, MinPeopleNum = @MinPeopleNum WHERE 1 = 1;
  END TRY
  BEGIN CATCH
    DECLARE @errorMsg nvarchar(1024) = 'Error while updating reservation conditions: '
    + ERROR_MESSAGE();
    THROW 52000, @errorMsg, 1;
  END CATCH
END;

-- Procedure:
CREATE PROCEDURE AddReservation
@CustomerID int,
@PeopleCount int,
@FromDate datetime
AS
BEGIN
  IF NOT EXISTS(SELECT * FROM Customers WHERE CustomerID=@CustomerID)
    BEGIN
      DECLARE @errorMsg1 nvarchar(1024) = 'Customer does not exist';
      THROW 52000, @errorMsg1, 1;
    END;

  IF @CustomerID in (SELECT CustomerID FROM IndividualCustomers)
  BEGIN
    IF (SELECT COUNT(*) FROM Orders WHERE CustomerID=@CustomerID)<(SELECT MinOrdersNum FROM ReservationConditions)
      OR @PeopleCount<(SELECT MinPeopleNum FROM ReservationConditions)
    BEGIN
      DECLARE @errorMsg2 nvarchar(1024) = 'Customer does not meet the requirements';
      THROW 52000, @errorMsg2, 2;
    END;

    IF NOT EXISTS (SELECT * FROM Orders WHERE CustomerID=@CustomerID AND DATEDIFF(DAY,OutDate,@FromDate)=0)
    BEGIN
      DECLARE @errorMsg3 nvarchar(1024) = 'Individual Customer must place an order with the reservation';
      THROW 52000, @errorMsg3, 2;
    END;

    IF (
      SELECT TotalPrice
      FROM IndividualCustomersOrdersView
      WHERE CustomerID = @CustomerID AND
        DATEDIFF(DAY, OutDate, @FromDate) = 0) < (SELECT MinValue FROM ReservationConditions)
    BEGIN
      DECLARE @errorMsg4 nvarchar(1024) = 'Order does not meet the requirements';
      THROW 52000, @errorMsg4, 2;
    END;
  END
  BEGIN TRY
    INSERT INTO Reservations(CustomerID, PeopleCount, ReservationDate, FromDate) VALUES (@CustomerID, @PeopleCount, GETDATE(), @FromDate);
  END TRY
    BEGIN CATCH
    DECLARE @errorMsg nvarchar(1024) = 'Error while adding reservation: '
    + ERROR_MESSAGE();
    THROW 52000, @errorMsg, 1;
  END CATCH
END;

-- Procedure:
CREATE PROCEDURE ConfirmIndividualReservation
@ReservationID int,
@TableID int
AS
BEGIN
  IF NOT EXISTS(SELECT * FROM Tables WHERE TableID=@TableID)
    BEGIN
      DECLARE @errorMsg1 nvarchar(1024) = 'Table does not exist';
      THROW 52000, @errorMsg1, 1;
    END;

  IF NOT EXISTS(SELECT * FROM Reservations WHERE ReservationID=@ReservationID)
    BEGIN
      DECLARE @errorMsg2 nvarchar(1024) = 'Reservation does not exist';
      THROW 52000, @errorMsg2, 1;
    END;

  IF (SELECT CustomerID FROM Reservations WHERE ReservationID=@ReservationID) NOT IN (SELECT CustomerID FROM IndividualCustomers)
    BEGIN
      DECLARE @errorMsg3 nvarchar(1024) = 'Not Individual Customer';
      THROW 52000, @errorMsg3, 1;
    END;

  IF (SELECT SeatsNum FROM Tables WHERE TableID = @TableID) != (SELECT PeopleCount FROM Reservations WHERE ReservationID = @ReservationID)
    BEGIN
      DECLARE @errorMsg4 nvarchar(1024) = CONCAT('Table ', @TableID, ' does not have enough seats');
      THROW 52000, @errorMsg4, 1;
    END;

  DECLARE @FromDate datetime= (SELECT FromDate FROM Reservations where ReservationID=@ReservationID )
  IF EXISTS(SELECT * FROM ReservedTablesView WHERE TableID=@TableID AND DATEDIFF(DAY,FromDate,@FromDate)=0)
    BEGIN
      DECLARE @errorMsg5 nvarchar(1024) = CONCAT('Table ', @TableID, ' is already reserved this day');
      THROW 52000, @errorMsg5, 1;
    END;

  BEGIN TRY
    INSERT INTO ReservationIndividuals(ReservationID,TableID) VALUES (@ReservationID,@TableID)
    UPDATE Reservations SET ConfirmationDate=GETDATE() WHERE ReservationID=@ReservationID
  END TRY
  BEGIN CATCH
    DELETE FROM ReservationIndividuals WHERE ReservationID=@ReservationID
    UPDATE Reservations SET ConfirmationDate=NULL WHERE ReservationID=@ReservationID
    DECLARE @errorMsg nvarchar(1024) = 'Error while confirming reservation: '
    + ERROR_MESSAGE();
    THROW 52000, @errorMsg, 1;
  END CATCH
END;

-- Procedure:
CREATE PROCEDURE AddCompanyReservationEmployee
@ReservationID int,
@GroupID int,
@CustomerID int
AS
BEGIN
  IF NOT EXISTS(
    SELECT *
    FROM Reservations
    WHERE ReservationID = @ReservationID
  )
    BEGIN
      DECLARE @errorMsg1 nvarchar(1024) = 'Reservation does not exist';
      THROW 52000, @errorMsg1, 1;
    END;

  IF NOT EXISTS(
    SELECT *
    FROM CompanyEmployees
    WHERE CustomerID = @CustomerID
  )
    BEGIN
      DECLARE @errorMsg2 nvarchar(1024) = CONCAT('Customer ', @CustomerID, ' is not employed in the company of ID ', (
        SELECT CustomerID FROM Reservations WHERE ReservationID = @ReservationID
      ));
      THROW 52000, @errorMsg2, 1;
    END;

  DECLARE @AddedPeopleCount int = (
    SELECT COUNT(CustomerID)
    FROM ReservationGroups
    WHERE ReservationID = @ReservationID
  );
  DECLARE @ExpectedPeopleCount int = (
    SELECT PeopleCount
    FROM Reservations
    WHERE ReservationID = @ReservationID
  );
  IF @AddedPeopleCount = @ExpectedPeopleCount
    BEGIN
      DECLARE @errorMsg3 nvarchar(1024) = 'Cannot add more people to the reservation ' + STR(@ReservationID);
      THROW 52000, @errorMsg3, 1;
    END;

  IF EXISTS(
    SELECT *
    FROM ReservationGroups
    WHERE ReservationID = @ReservationID
      AND CustomerID = @CustomerID
  )
    BEGIN
      DECLARE @errorMsg4 nvarchar(1024) = CONCAT('Employee ', @CustomerID, ' is already added to another group');
      THROW 52000, @errorMsg4, 1;
    END;

  BEGIN TRY
    INSERT INTO ReservationGroups(ReservationID,GroupID,CustomerID) VALUES (@ReservationID,@GroupID,@CustomerID)
  END TRY
  BEGIN CATCH
    DECLARE @errorMsg nvarchar(1024) = 'Error while adding employee to reservation: '
    + ERROR_MESSAGE();
    THROW 52000, @errorMsg, 1;
  END CATCH
END;

-- Procedure:
CREATE PROCEDURE AssignTableToCompanyNamedGroup
@ReservationID int,
@GroupID int,
@TableID int
AS
BEGIN
  IF NOT EXISTS(SELECT * FROM Reservations WHERE ReservationID=@ReservationID)
    BEGIN
      DECLARE @errorMsg1 nvarchar(1024) = 'Reservation does not exist';
      THROW 52000, @errorMsg1, 1;
    END;

  IF NOT EXISTS(SELECT * FROM ReservationGroups WHERE ReservationID=@ReservationID AND GroupID=@GroupID)
    BEGIN
      DECLARE @errorMsg2 nvarchar(1024) = 'Group does not exist';
      THROW 52000, @errorMsg2, 12;
    END;

  IF NOT EXISTS(SELECT * FROM Tables WHERE TableID=@TableID)
    BEGIN
      DECLARE @errorMsg3 nvarchar(1024) = 'Table does not exist';
      THROW 52000, @errorMsg3, 1;
    END;

  DECLARE @SeatsNum int = (
    SELECT SeatsNum
    FROM Tables
    WHERE TableID = @TableID
  );
  DECLARE @GroupPeopleCount int = (
    SELECT COUNT(*)
    FROM ReservationGroups
    WHERE GroupID = @GroupID
      AND ReservationID = @ReservationID
  );
  IF @SeatsNum < @GroupPeopleCount
    BEGIN
      DECLARE @errorMsg4 nvarchar(1024) = CONCAT('Table ', @TableID, ' does not have enough seats');
      THROW 52000, @errorMsg4, 1;
    END;

  IF EXISTS(
    SELECT *
    FROM ReservationCompanies
    WHERE ReservationID = @ReservationID
      AND GroupID = @GroupID
  )
    BEGIN
      DECLARE @errorMsg5 nvarchar(1024) = 'Group is already assigned to a table';
      THROW 52000, @errorMsg5, 1;
    END;

  DECLARE @FromDate datetime = (
    SELECT FromDate
    FROM Reservations
    WHERE ReservationID = @ReservationID
  );
  IF EXISTS(
    SELECT *
    FROM ReservedTablesView
    WHERE TableID = @TableID
      AND DATEDIFF(DAY, FromDate, @FromDate) = 0
  )
    BEGIN
      DECLARE @errorMsg6 nvarchar(1024) = CONCAT('Table ', @TableID, ' is already reserved this day');
      THROW 52000, @errorMsg6, 1;
    END;

  BEGIN TRY
    INSERT INTO ReservationCompanies(ReservationID, GroupID, TableID, GroupPeopleCount) VALUES (@ReservationID, @GroupID, @TableID, @GroupPeopleCount)
  END TRY
  BEGIN CATCH
    DECLARE @errorMsg nvarchar(1024) = 'Error while assigning a table to the named group: '
    + ERROR_MESSAGE();
    THROW 52000, @errorMsg, 1;
  END CATCH;
END;

-- Procedure:
CREATE PROCEDURE AssignTableToCompanyUnnamedGroup
@ReservationID int,
@GroupPeopleCount int,
@TableID int
AS
BEGIN
  IF NOT EXISTS(SELECT * FROM Reservations WHERE ReservationID=@ReservationID)
    BEGIN
      DECLARE @errorMsg1 nvarchar(1024) = 'Reservation does not exist';
      THROW 52000, @errorMsg1, 1;
    END;

  IF NOT EXISTS(SELECT * FROM Tables WHERE TableID=@TableID)
    BEGIN
      DECLARE @errorMsg2 nvarchar(1024) = 'Table does not exist';
      THROW 52000, @errorMsg2, 1;
    END;

  DECLARE @SeatsNum int = (
    SELECT SeatsNum
    FROM Tables
    WHERE TableID = @TableID
  );
  IF @SeatsNum < @GroupPeopleCount
    BEGIN
      DECLARE @errorMsg3 nvarchar(1024) = CONCAT('Table ', @TableID, ' does not have enough seats');
      THROW 52000, @errorMsg3, 1;
    END;

  DECLARE @FromDate datetime = (
    SELECT FromDate
    FROM Reservations
    WHERE ReservationID = @ReservationID
  );
  IF EXISTS(
    SELECT *
    FROM ReservedTablesView
    WHERE TableID = @TableID
      AND DATEDIFF(DAY, FromDate, @FromDate) = 0
  )
    BEGIN
      DECLARE @errorMsg4 nvarchar(1024) = CONCAT('Table ', @TableID, ' is already reserved this day');
      THROW 52000, @errorMsg4, 1;
    END;

  DECLARE @GroupID int = (
    SELECT COUNT(GroupID) + 1
    FROM ReservationCompanies
    WHERE ReservationID = @ReservationID
  );
  BEGIN TRY
    INSERT INTO ReservationCompanies(ReservationID, GroupID, TableID, GroupPeopleCount) VALUES (@ReservationID, @GroupID, @TableID, @GroupPeopleCount)
  END TRY
  BEGIN CATCH
    DECLARE @errorMsg nvarchar(1024) = 'Error while assigning a table to the unnamed group: '
    + ERROR_MESSAGE();
    THROW 52000, @errorMsg, 1;
  END CATCH;
END;
