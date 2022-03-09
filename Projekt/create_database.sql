-- Table: Categories
CREATE TABLE Categories (
    CategoryID int  NOT NULL IDENTITY(1, 1),
    CategoryName varchar(20)  NOT NULL,
    Description varchar(100)  NULL,
    CONSTRAINT Categories_pk PRIMARY KEY (CategoryID),
    CONSTRAINT CategoryName_ak UNIQUE(CategoryName)
);

-- Table: Companies
CREATE TABLE Companies (
    CustomerID int  NOT NULL,
    CompanyName varchar(30)  NOT NULL,
    NIP varchar(11)  NOT NULL,
    CONSTRAINT Companies_pk PRIMARY KEY (CustomerID),
    CONSTRAINT CHK_NIP CHECK (NIP LIKE  REPLICATE('[0-9]', 10) OR NIP LIKE REPLICATE('[0-9]', 11))
);

-- Table: CompanyEmployees
CREATE TABLE CompanyEmployees (
    CustomerID int  NOT NULL,
    CompanyID int  NOT NULL,
    PersonID int  NOT NULL,
    CONSTRAINT CompanyEmployees_pk PRIMARY KEY (CustomerID)
);

-- Table: Customers
CREATE TABLE Customers (
    CustomerID int  NOT NULL IDENTITY(1, 1),
    Email varchar(40)  NOT NULL,
    Phone varchar(12)  NOT NULL,
    CONSTRAINT Customers_pk PRIMARY KEY (CustomerID),
    CONSTRAINT Email_ak UNIQUE (Email),
    CONSTRAINT Phone_ak UNIQUE (Phone),
    CONSTRAINT CHK_Phone CHECK (Phone LIKE '+' + REPLICATE('[0-9]', 11) OR Phone LIKE REPLICATE('[0-9]', 9)),
    CONSTRAINT CHK_Email CHECK (Email LIKE '%_@_%._%')
);


-- Table: DiscountParams
CREATE TABLE DiscountParams (
    ConstID int  NOT NULL IDENTITY(1, 1),
    ParamID int  NOT NULL,
    Value int  NOT NULL,
    AvailableFrom datetime  NOT NULL DEFAULT GETDATE(),
    AvailableTo datetime  NULL,
    CONSTRAINT DiscountParams_pk PRIMARY KEY NONCLUSTERED (ConstID),
    CONSTRAINT CHK_ParamValue CHECK (Value > 0),
    CONSTRAINT CHK_ParamDate CHECK (AvailableFrom <= ISNULL(AvailableTo, GETDATE()))
);

-- Table: DiscountParamsDict
CREATE TABLE DiscountParamsDict (
    ParamID int  NOT NULL IDENTITY(1, 1),
    ParamName varchar(2)  NOT NULL,
    CONSTRAINT DiscountParamsDict_pk PRIMARY KEY  (ParamID),
    CONSTRAINT ParamName_ak UNIQUE (ParamName)
);

-- Reference: DiscountParams_DiscountParamsDict (table: DiscountParams)
ALTER TABLE DiscountParams ADD CONSTRAINT DiscountParams_DiscountParamsDict
    FOREIGN KEY (ParamID)
    REFERENCES DiscountParamsDict (ParamID);


-- Table: Dishes
CREATE TABLE Dishes (
    DishID int  NOT NULL IDENTITY(1, 1),
    CategoryID int  NOT NULL,
    DishName varchar(40)  NOT NULL,
    Description varchar(100)  NULL,
    CONSTRAINT Dishes_pk PRIMARY KEY (DishID),
    CONSTRAINT DishName_ak UNIQUE(DishName)
);

-- Table: IndividualCustomers
CREATE TABLE IndividualCustomers (
    CustomerID int  NOT NULL,
    PersonID int  NOT NULL,
    CONSTRAINT IndividualCustomers_pk PRIMARY KEY (CustomerID)
);

-- Table: MenuItems
CREATE TABLE MenuItems (
    ItemID int  NOT NULL IDENTITY(1, 1),
    DishID int  NOT NULL,
    UnitPrice money  NOT NULL,
    UnitsOnOrder int  NOT NULL,
    AvailableFrom datetime  NOT NULL DEFAULT GETDATE(),
    AvailableTo datetime  NULL,
    CONSTRAINT MenuItems_pk PRIMARY KEY (ItemID),
    CONSTRAINT CHK_UnitsOnOrder CHECK (UnitsOnOrder >= 0),
    CONSTRAINT CHK_AvailableMenuItems CHECK (AvailableFrom < ISNULL(AvailableTo, GETDATE()))
);

-- Table: OneTimeDiscount
CREATE TABLE OneTimeDiscount (
    DiscountID int  NOT NULL IDENTITY(1, 1),
    CustomerID int  NOT NULL,
    DiscountValue int  NOT NULL,
    AvailableFrom datetime  NOT NULL DEFAULT GETDATE(),
    AvailableTo datetime  NULL,
    CONSTRAINT OneTimeDiscount_pk PRIMARY KEY NONCLUSTERED (DiscountID),
    CONSTRAINT CHK_DiscountValueOneTimeDiscount CHECK (DiscountValue >= 0 AND DiscountValue <= 100),
    CONSTRAINT CHK_AvailableOneTimeDiscount CHECK (AvailableFrom < ISNULL(AvailableTo, GETDATE()))
);

-- Table: OrderDetails
CREATE TABLE OrderDetails (
    OrderID int  NOT NULL,
    ItemID int  NOT NULL,
    Quantity int  NOT NULL,
    CONSTRAINT OrderDetails_pk PRIMARY KEY (OrderID,ItemID),
    CONSTRAINT CHK_Quantity CHECK (Quantity > 0)
);

-- Table: Orders
CREATE TABLE Orders (
    OrderID int  NOT NULL IDENTITY(1, 1),
    CustomerID int  NULL,
    EmployeeID int  NOT NULL,
    PaymentTypeID int  NULL,
    OrderDate datetime  NOT NULL DEFAULT GETDATE(),
    OutDate datetime  NULL,
    CONSTRAINT Orders_pk PRIMARY KEY (OrderID),
    CONSTRAINT CHK_Date CHECK (OrderDate <= ISNULL(OutDate, GETDATE()))
);

-- Table: Payment
CREATE TABLE Payment (
    PaymentTypeID int  NOT NULL IDENTITY(1, 1),
    PaymentMethod varchar(20)  NOT NULL,
    CONSTRAINT Payment_pk PRIMARY KEY (PaymentTypeID),
    CONSTRAINT PaymentMethod_ak UNIQUE (PaymentMethod)
);

-- Table: People
CREATE TABLE People (
    PersonID int  NOT NULL IDENTITY(1, 1),
    FirstName varchar(20)  NOT NULL,
    LastName varchar(20)  NOT NULL,
    CONSTRAINT People_pk PRIMARY KEY (PersonID),
    CONSTRAINT CHK_FirstName CHECK (SUBSTRING(FirstName, 1, 1) = UPPER(SUBSTRING(FirstName, 1, 1))),
    CONSTRAINT CHK_LastName CHECK (SUBSTRING(LastName, 1, 1) = UPPER(SUBSTRING(LastName, 1, 1)))
);

-- Table: PermanentDiscount
CREATE TABLE PermanentDiscount (
    DiscountID int  NOT NULL IDENTITY(1, 1),
    CustomerID int  NOT NULL,
    DiscountValue int  NOT NULL,
    AvailableFrom datetime  NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PermanentDiscount_pk PRIMARY KEY NONCLUSTERED (CustomerID,DiscountID),
    CONSTRAINT CHK_DiscountValuePermanentDiscount CHECK (DiscountValue >= 0 AND DiscountValue <= 100)
);

-- Table: ReservationCompanies
CREATE TABLE ReservationCompanies (
    ReservationID int  NOT NULL,
    GroupID int  NOT NULL,
    TableID int  NOT NULL,
    GroupPeopleCount int NOT NULL,
    CONSTRAINT ReservationCompanies_pk PRIMARY KEY (ReservationID,GroupID)
);

-- Table: ReservationConditions
CREATE TABLE ReservationConditions (
    MinValue money  NOT NULL,
    MinOrdersNum int  NOT NULL,
    MinPeopleNum int  NOT NULL,
    CONSTRAINT ReservationConditions_pk PRIMARY KEY (MinValue,MinOrdersNum,MinPeopleNum),
    CONSTRAINT CHK_MinOrdersNum CHECK (MinOrdersNum > 0),
    CONSTRAINT CHK_MinPeopleNum CHECK (MinPeopleNum > 0)
);

-- Table: ReservationGroups
CREATE TABLE ReservationGroups (
    ReservationID int  NOT NULL,
    GroupID int  NOT NULL,
    CustomerID int  NOT NULL,
    CONSTRAINT ReservationGroups_pk PRIMARY KEY (ReservationID,GroupID,CustomerID)
);

-- Table: ReservationIndividuals
CREATE TABLE ReservationIndividuals (
    ReservationID int  NOT NULL,
    TableID int  NOT NULL,
    CONSTRAINT ReservationIndividuals_pk PRIMARY KEY (ReservationID)
);

-- Table: Reservations
CREATE TABLE Reservations (
    ReservationID int  NOT NULL IDENTITY(1, 1),
    CustomerID int  NOT NULL,
    PeopleCount int  NOT NULL,
    ReservationDate datetime  NOT NULL DEFAULT GETDATE(),
    FromDate datetime  NOT NULL,
    ConfirmationDate datetime  NULL,
    CONSTRAINT Reservations_pk PRIMARY KEY (ReservationID),
    CONSTRAINT CHK_ReservationDate CHECK (ReservationDate <= FromDate),
    CONSTRAINT CHK_FromDate CHECK (FromDate >= ISNULL(ConfirmationDate, GETDATE()))
);

-- Table: RestaurantEmployees
CREATE TABLE RestaurantEmployees (
    EmployeeID int  NOT NULL IDENTITY(1, 1),
    PersonID int  NOT NULL,
    ReportsTo int  NULL,
    Title varchar(20)  NOT NULL,
    CONSTRAINT RestaurantEmployees_pk PRIMARY KEY (EmployeeID)
);

-- Table: Tables
CREATE TABLE Tables (
    TableID int  NOT NULL IDENTITY(1, 1),
    SeatsNum int  NOT NULL,
    CONSTRAINT Tables_pk PRIMARY KEY (TableID),
    CONSTRAINT CHK_SeatsNum CHECK (SeatsNum > 0)
);

-- Table: TakeoutOrders
CREATE TABLE TakeoutOrders (
    OrderID int  NOT NULL,
    CONSTRAINT TakeoutOrders_pk PRIMARY KEY (OrderID)
);

-- foreign keys
-- Reference: CompanyEmployees_Companies (table: CompanyEmployees)
ALTER TABLE CompanyEmployees ADD CONSTRAINT CompanyEmployees_Companies
    FOREIGN KEY (CompanyID)
    REFERENCES Companies (CustomerID);

-- Reference: CompanyEmployees_People (table: CompanyEmployees)
ALTER TABLE CompanyEmployees ADD CONSTRAINT CompanyEmployees_People
    FOREIGN KEY (PersonID)
    REFERENCES People (PersonID);

-- Reference: Customers_Companies (table: Companies)
ALTER TABLE Companies ADD CONSTRAINT Customers_Companies
    FOREIGN KEY (CustomerID)
    REFERENCES Customers (CustomerID);

-- Reference: Customers_CompanyEmployees (table: CompanyEmployees)
ALTER TABLE CompanyEmployees ADD CONSTRAINT Customers_CompanyEmployees
    FOREIGN KEY (CustomerID)
    REFERENCES Customers (CustomerID);

-- Reference: Dishes_Categories (table: Dishes)
ALTER TABLE Dishes ADD CONSTRAINT Dishes_Categories
    FOREIGN KEY (CategoryID)
    REFERENCES Categories (CategoryID);

-- Reference: Dishes_Menu (table: MenuItems)
ALTER TABLE MenuItems ADD CONSTRAINT Dishes_Menu
    FOREIGN KEY (DishID)
    REFERENCES Dishes (DishID);

-- Reference: IndividualCustomers_Customers (table: IndividualCustomers)
ALTER TABLE IndividualCustomers ADD CONSTRAINT IndividualCustomers_Customers
    FOREIGN KEY (CustomerID)
    REFERENCES Customers (CustomerID);

-- Reference: IndividualCustomers_People (table: IndividualCustomers)
ALTER TABLE IndividualCustomers ADD CONSTRAINT IndividualCustomers_People
    FOREIGN KEY (PersonID)
    REFERENCES People (PersonID);

-- Reference: MenuItems_OrderDetails (table: OrderDetails)
ALTER TABLE OrderDetails ADD CONSTRAINT MenuItems_OrderDetails
    FOREIGN KEY (ItemID)
    REFERENCES MenuItems (ItemID);

-- Reference: OneTimeDiscount_IndividualCustomers (table: OneTimeDiscount)
ALTER TABLE OneTimeDiscount ADD CONSTRAINT OneTimeDiscount_IndividualCustomers
    FOREIGN KEY (CustomerID)
    REFERENCES IndividualCustomers (CustomerID);

-- Reference: OrderDetails_Orders (table: OrderDetails)
ALTER TABLE OrderDetails ADD CONSTRAINT OrderDetails_Orders
    FOREIGN KEY (OrderID)
    REFERENCES Orders (OrderID);

-- Reference: Orders_Customers (table: Orders)
ALTER TABLE Orders ADD CONSTRAINT Orders_Customers
    FOREIGN KEY (CustomerID)
    REFERENCES Customers (CustomerID);

-- Reference: Orders_Payment (table: Orders)
ALTER TABLE Orders ADD CONSTRAINT Orders_Payment
    FOREIGN KEY (PaymentTypeID)
    REFERENCES Payment (PaymentTypeID);

-- Reference: Orders_RestaurantEmployees (table: Orders)
ALTER TABLE Orders ADD CONSTRAINT Orders_RestaurantEmployees
    FOREIGN KEY (EmployeeID)
    REFERENCES RestaurantEmployees (EmployeeID);

-- Reference: People_RestaurantEmployees (table: RestaurantEmployees)
ALTER TABLE RestaurantEmployees ADD CONSTRAINT People_RestaurantEmployees
    FOREIGN KEY (PersonID)
    REFERENCES People (PersonID);

-- Reference: PermanentDiscount_IndividualCustomers (table: PermanentDiscount)
ALTER TABLE PermanentDiscount ADD CONSTRAINT PermanentDiscount_IndividualCustomers
    FOREIGN KEY (CustomerID)
    REFERENCES IndividualCustomers (CustomerID);

-- Reference: ReservationCompanies_Tables (table: ReservationCompanies)
ALTER TABLE ReservationCompanies ADD CONSTRAINT ReservationCompanies_Tables
    FOREIGN KEY (TableID)
    REFERENCES Tables (TableID);

-- Reference: Reservations_Customers (table: Reservations)
ALTER TABLE Reservations ADD CONSTRAINT Reservations_Customers
    FOREIGN KEY (CustomerID)
    REFERENCES Customers (CustomerID);

-- Reference: Reservations_ReservationCompanies (table: ReservationCompanies)
ALTER TABLE ReservationCompanies ADD CONSTRAINT Reservations_ReservationCompanies
    FOREIGN KEY (ReservationID)
    REFERENCES Reservations (ReservationID);

-- Reference: Reservations_ReservationGroups (table: ReservationGroups)
ALTER TABLE ReservationGroups ADD CONSTRAINT Reservations_ReservationGroups
    FOREIGN KEY (ReservationID)
    REFERENCES Reservations (ReservationID);

-- Reference: Tables_ReservationIndividuals (table: ReservationIndividuals)
ALTER TABLE ReservationIndividuals ADD CONSTRAINT Tables_ReservationIndividuals
    FOREIGN KEY (TableID)
    REFERENCES Tables (TableID);

-- Reference: TakeoutOrders_Orders (table: TakeoutOrders)
ALTER TABLE TakeoutOrders ADD CONSTRAINT TakeoutOrders_Orders
    FOREIGN KEY (OrderID)
    REFERENCES Orders (OrderID);

-- Reference: ReservationGroups_CompanyEmployees (table: ReservationGroups)
ALTER TABLE ReservationGroups ADD CONSTRAINT ReservationGroups_CompanyEmployees
    FOREIGN KEY (CustomerID)
    REFERENCES CompanyEmployees (CustomerID);

-- Reference: ReservationIndividuals_Reservations (table: ReservationIndividuals)
ALTER TABLE ReservationIndividuals ADD CONSTRAINT Reservations_ReservationIndividuals
   FOREIGN KEY (ReservationID)
   REFERENCES Reservations (ReservationID);
