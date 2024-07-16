-- TASK 1 CREATE FUNCTION
DELIMITER //

CREATE FUNCTION FindCost(id INT) 
RETURNS DECIMAL(5,2) DETERMINISTIC
BEGIN
    DECLARE price DECIMAL(5,2);
    SELECT cost INTO price FROM orders WHERE OrderID = id;
    RETURN price;
END //

DELIMITER ;

-- TASK 2 CREATE PROCEDURE
DELIMITER //
CREATE PROCEDURE GetDiscount(IN order_id INT, OUT new_cost DECIMAL(10,2))
BEGIN
    DECLARE order_quantity INT;
    DECLARE original_cost DECIMAL(10, 2);
    DECLARE discount DECIMAL(10, 2);

    SELECT Quantity, Cost INTO order_quantity, original_cost
    FROM orders
    WHERE OrderID = order_id;

    -- Calculate the discount
    IF order_quantity >= 20 THEN
        SET discount = 0.20;
    ELSEIF order_quantity >= 10 THEN
        SET discount = 0.10;
    ELSE 
        SET discount = 0.00;
    END IF;

    SET new_cost =  original_cost - (original_cost * discount);
END //
DELIMITER ;

-- Declare a variable to hold the output
SET @newCost = 0;

-- Call the procedure with the OrderID
CALL GetDiscount(5, @newCost);

-- Select the new cost to see the result
SELECT @newCost;

-- TASK 3 CREATE TRIGGER
DELIMITER //
CREATE TRIGGER OrderQtyCheck
BEFORE INSERT
ON Orders FOR EACH ROW
BEGIN
    IF NEW.Quantity < 0 THEN
    SET NEW.Quantity = 0;
    END IF;
END //
DELIMITER ;


CREATE TRIGGER LogNewOrderInsert
AFTER INSERT
ON Orders FOR EACH ROW
INSERT INTO Audits VALUES ('AFTER', 'A new order was inserted', 'INSERT');

CREATE TRIGGER AfterDeleteOrder
AFTER DELETE
ON Orders FOR EACH ROW
INSERT INTO Audits
VALUES('AFTER', CONCAT('Order', OLD.OrderID, 'was deleted at', CURRENT_TIME(), 
'on', CURRENT_DATE()), 'DELETE');

-- TASK 4 CREATE SCHEDULED EVENTS
DELIMITER //
CREATE EVENT GenerateRevenueReport
ON SCHEDULE AT CURRENT_TIMESTAMP + INTERVAL 12 HOUR
DO
BEGIN
    INSERT INTO ReportData (OrderID, ClientID, ProductID, Quantity, Cost, Date)
    SELECT *
    FROM Orders 
    WHERE Date
    BETWEEN '2022-08-01' AND '2022-08-31';
END //
DELIMITER ;

DELIMITER //
CREATE EVENT DailyRestock
ON SCHEDULE
EVERY 1 DAY
DO 
BEGIN 
    IF Products.NumberOfItems < 50 THEN
    UPDATE Products SET NumberOfItems = 50;
    END IF;
END //
DELIMITER ;

-- DELETE DROP EVENT 
DROP EVENT [IF EXISTS] event_name;