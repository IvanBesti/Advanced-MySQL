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
