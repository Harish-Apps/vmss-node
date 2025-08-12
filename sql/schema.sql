CREATE TABLE dbo.Customers (
    CustomerId INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL
);

CREATE TABLE dbo.Orders (
    OrderId INT IDENTITY PRIMARY KEY,
    CustomerId INT NOT NULL,
    OrderDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    Amount DECIMAL(10,2) NOT NULL,
    CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerId)
        REFERENCES dbo.Customers(CustomerId)
);

CREATE INDEX IX_Customers_Name ON dbo.Customers(Name);
CREATE INDEX IX_Orders_CustomerId ON dbo.Orders(CustomerId);
