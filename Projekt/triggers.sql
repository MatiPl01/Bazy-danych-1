CREATE TRIGGER AddEmployeeToConfirmedReservation
ON ReservationGroups
AFTER INSERT
AS
BEGIN
  IF EXISTS(
    SELECT *
    FROM ReservationCompanies
    WHERE ReservationID = (SELECT ReservationID FROM INSERTED)
      AND GroupID = (SELECT GroupID FROM INSERTED)
    )
    BEGIN
      RAISERROR('People cannot be added to confirmed reservation', 1, 1)
      ROLLBACK TRANSACTION
    END;
END;

CREATE TRIGGER MultipleReservationsInOneDay
ON Reservations
AFTER INSERT
AS
BEGIN
  IF EXISTS(
    SELECT *
    FROM Reservations
    WHERE CustomerID = (SELECT CustomerID FROM INSERTED)
      AND CustomerID IN (SELECT CustomerID FROM IndividualCustomers)
      AND DATEDIFF(DAY, FromDate, (SELECT FromDate FROM INSERTED)) = 0
      AND ReservationID != (SELECT ReservationID FROM INSERTED)
    )
    BEGIN
      RAISERROR('Customer already has made a reservation on this date', 1, 1)
      ROLLBACK TRANSACTION
    END
END;

CREATE TRIGGER UpdateReservationConfirmationDate
ON ReservationCompanies
AFTER INSERT
AS
BEGIN
  DECLARE @ReservationID int = (
    SELECT ReservationID FROM INSERTED
  );
  DECLARE @AllGroupsCount int = (
    SELECT COUNT(DISTINCT GroupID)
    FROM ReservationGroups
    WHERE ReservationID = @ReservationID
  );
  DECLARE @AssignedTableGroupsCount int = (
    SELECT COUNT(DISTINCT GroupID)
    FROM ReservationCompanies
    WHERE ReservationID = @ReservationID
  );

  IF @AllGroupsCount = @AssignedTableGroupsCount
  BEGIN
    UPDATE Reservations SET ConfirmationDate = GETDATE() WHERE ReservationID = @ReservationID
  END
END;

CREATE TRIGGER GrantDiscount
ON Orders
AFTER INSERT
AS
BEGIN
  DECLARE @CustomerID int=(SELECT CustomerID FROM INSERTED);
  IF dbo.CanCustomerGetOneTimeDiscount(@CustomerID) = 1
  BEGIN
    EXEC GrantOneTimeDiscount @CustomerID = @CustomerID
  END;
  IF dbo.CanCustomerGetPermanentDiscount(@CustomerID) = 1
  BEGIN
    EXEC GrantPermanentDiscount @CustomerID = @CustomerID
  END;
END;

CREATE TRIGGER CheckIfItemAvailable
ON OrderDetails
AFTER INSERT
AS
BEGIN
  DECLARE @ItemID int = (SELECT ItemID FROM INSERTED);
  DECLARE @UnitsOnOrder int = (
    SELECT UnitsOnOrder
    FROM MenuItems
    WHERE ItemID = @ItemID
  );
  DECLARE @UnitsSold int = (
    SELECT SUM(Quantity)
    FROM OrderDetails AS od
    INNER JOIN Orders AS o
    ON o.OrderID = od.OrderID
    WHERE od.ItemID = @ItemID
    AND DATEDIFF(DAY, o.OrderDate, GETDATE()) = 0
  );
  IF @UnitsSold > @UnitsOnOrder
  BEGIN
    DECLARE @ErrorMsg nvarchar(100) = CONCAT('Daily order limit was exceeded for an item with ID: ', @ItemID);
    RAISERROR(@ErrorMsg, 1, 1);
    ROLLBACK TRANSACTION
  END;
END;

CREATE TRIGGER DeleteOrder
ON Orders
INSTEAD OF DELETE
AS
BEGIN
  DECLARE @OrderID int = (SELECT OrderID FROM DELETED)
  DELETE FROM OrderDetails WHERE OrderID = @OrderID
  DELETE FROM TakeoutOrders WHERE OrderID = @OrderID
  DELETE FROM Orders WHERE OrderID = @OrderID
END;
