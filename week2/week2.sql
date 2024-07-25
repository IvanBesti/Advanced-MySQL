-- TRANSACTION EXAMPLE
SELECT * FROM Products;
--- MAKE NEW TRANSACTION STATEMENT
START TRANSACTION;
--- INSERT NEW DATA TO ORDERS TABLE
INSERT INTO Orders(OrderID, ClientID, ProductID, Quantity, Cost, Date)
VALUES (30, "C11", "P1", 10, 500, "2022-09-30");

--- UPDATE NEW FIELD
UPDATE Products SET NumberOfItems = (NumberOfItems -10) WHERE ProductID = "P1";

--- TO CHECK THE DATA YOU INSERTED IS CORRECT
SELECT Orders.OrderID, Orders.ClientID, Orders.Quantity, Products.ProductID, Products.NumberOfItems 
FROM Orders INNER JOIN Products ON (Orders.ProductID = Products.ProductID) 
WHERE Orders.OrderID = 30;

--- UNFORTUNATELY THERE IS A MISTAKE. YOU NEED ROLLBACK THE DATA
ROLLBACK;

--- START THE TRANSACTION ONCE AGAIN
START TRANSACTION;
INSERT INTO Orders(OrderID, ClientID, ProductID, Quantity, Cost, Date)
VALUES (30, "Cl1", "P1", 10, 500, "2022-09-30"); -- change c11 to cl1

UPDATE Products SET NumberOfItems = (NumberOfItems -10) WHERE ProductID = "P1";

--- CHECK THE DATA IF IT'S CORRECT
SELECT Orders.OrderID, Orders.ClientID, Orders.Quantity, Products.ProductID, Products.NumberOfItems 
FROM Orders INNER JOIN Products ON (Orders.ProductID = Products.ProductID) 
WHERE Orders.OrderID = 30;

-- MySQL CTE (Common Table Expression)
SELECT Concat(AVG(Cost), " (2020)") AS "Average Sale" FROM Orders WHERE YEAR(Date) = 2020
UNION SELECT Concat(AVG(Cost), "(2021)" FROM Orders WHERE YEAR(Date) = 2021 UNION SELECT Concat(AVG
(Cost), "(2022)") FROM Orders WHERE YEAR(Date) = 2022); -- It's lil bit complicated

--- We can use CTE with WHERE statement
WITH 
Average_Sales_2020 AS (SELECT CONCAT(AVG(Cost), "(2020)" AS "Average Sale" FROM Orders
WHERE YEAR(Date) = 2020)),
Average_Sales_2021 AS (SELECT CONCAT(AVG(Cost), "(2021)" AS "Average Sale" FROM Orders
WHERE YEAR(Date) = 2021)),
Average_Sales_2022 AS (SELECT CONCAT(AVG(Cost), "(2022)" AS "Average Sale" FROM Orders
WHERE YEAR(Date) = 2022))
SELECT * FROM Average_Sales_2020
UNION
SELECT * FROM Average_Sales_2021
UNION
SELECT * FROM Average_Sales_2022; -- More optimal in one block code

-- TASK 1
WITH 
cl1_orders AS (
    SELECT CONCAT("Cl1: ", COUNT(OrderID), " orders") AS "Total number of orders"
    FROM Orders
    WHERE YEAR(Date) = 2022 AND ClientID = 'Cl1'
),
cl2_orders AS (
    SELECT CONCAT("Cl2: ", COUNT(OrderID), " orders") AS "Total number of orders"
    FROM Orders
    WHERE YEAR(Date) = 2022 AND ClientID = 'Cl2'
),
cl3_orders AS (
    SELECT CONCAT("Cl3: ", COUNT(OrderID), " orders") AS "Total number of orders"
    FROM Orders
    WHERE YEAR(Date) = 2022 AND ClientID = 'Cl3'
)
SELECT * FROM cl1_orders
UNION
SELECT * FROM cl2_orders
UNION
SELECT * FROM cl3_orders;



-- MySQL Prepared Statement
PREPARE GetOrderStatement FROM 'SELECT ClientID, ProductID, Quantity, Cost FROM Orders WHERE
OrderID = ?';

--- Assign the variable
SET @order_id = 10;

EXECUTE GetOrderStatement USING @Order_id;

--- task 1
PREPARE GetOrderDetail FROM 'SELECT OrderID, Quantity, Cost, Date FROM orders WHERE ClientID = ? AND YEAR(Date) = ?';
SET @ID = 'Cl1';
SET @Year = '2020';
EXECUTE GetOrderDetail USING @ID, @Year;

-- MySQL JSON
--- INSERT JSON DATA 
INSERT INTO Activity(ActivityID, Properties) VALUES
(1, '{"ClientID" : "Cl1", "ProductID": "P1", "Order": "True"}'),
(1, '{"ClientID" : "Cl2", "ProductID": "P4", "Order": "False"}'),
(1, '{"ClientID" : "Cl5", "ProductID": "P5", "Order": "True"}');
--- To retrieve JSON Data
SELECT 
    ActivityID, 
    JSON_EXTRACT(Properties, '$.ClientID') AS ClientID, 
    JSON_EXTRACT(Properties, '$.ProductID') AS ProductID, 
    JSON_EXTRACT(Properties, '$.Order') AS OrderDetails
FROM 
    Activity;
--- TASK 1
SELECT 
    JSON_UNQUOTE(JSON_EXTRACT(Activity.Properties, '$.ProductID')) AS ProductID, 
    Products.ProductName, 
    Products.BuyPrice, 
    Products.SellPrice 
FROM 
    Products 
INNER JOIN 
    Activity 
ON 
    Products.ProductID = JSON_UNQUOTE(JSON_EXTRACT(Activity.Properties, '$.ProductID')) 
WHERE 
    JSON_UNQUOTE(JSON_EXTRACT(Activity.Properties, '$.Order')) = 'True';

