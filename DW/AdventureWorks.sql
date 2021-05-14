SELECT CustomerID, NameStyle, Title, FirstName, MiddleName, LastName, Suffix, CompanyName, SalesPerson, EmailAddress, Phone, PasswordHash, PasswordSalt, rowguid, ModifiedDate
FROM myDW.SalesLT.Customer;

SELECT CustomerID, AddressID, AddressType, rowguid, ModifiedDate
FROM myDW.SalesLT.CustomerAddress;

