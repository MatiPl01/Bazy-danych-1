USE u_lopacins;

CREATE NONCLUSTERED INDEX OrdersCustomerIDIndex ON Orders(CustomerID);

CREATE CLUSTERED INDEX OneTimeDiscountCustomerIDIndex ON
OneTimeDiscount(CustomerID);

CREATE NONCLUSTERED INDEX OneTimeDiscountIndex ON OneTimeDiscount(AvailableFrom, AvailableTo);

CREATE CLUSTERED INDEX PermanentDiscountCustomerIDIndex ON
PermanentDiscount(CustomerID);

CREATE NONCLUSTERED INDEX PermanentDiscountIndex ON PermanentDiscount(AvailableFrom);

CREATE NONCLUSTERED INDEX ReservationsIndex ON Reservations(CustomerID, FromDate);

CREATE NONCLUSTERED INDEX MenuItemsIndex ON MenuItems(DishID, AvailableFrom, AvailableTo);

CREATE NONCLUSTERED INDEX DiscountParamsDictIndex ON DiscountParamsDict(ParamName);

CREATE CLUSTERED INDEX DiscountParamsParamIDIndex ON
DiscountParams(ParamID);

CREATE NONCLUSTERED INDEX DiscountParamsIndex ON DiscountParams(AvailableFrom, AvailableTo);

CREATE NONCLUSTERED INDEX CategoriesIndex ON Categories(CategoryName);

CREATE NONCLUSTERED INDEX OrderDetailsIndex ON OrderDetails(ItemID);

CREATE NONCLUSTERED INDEX RestaurantEmployeesIndex ON RestaurantEmployees(PersonID);

CREATE NONCLUSTERED INDEX IndividualCustomersIndex ON IndividualCustomers(PersonID);

CREATE NONCLUSTERED INDEX CompanyEmployeesIndex ON CompanyEmployees(CompanyID, PersonID);

CREATE NONCLUSTERED INDEX ReservationIndividualsIndex ON ReservationIndividuals(TableID);
