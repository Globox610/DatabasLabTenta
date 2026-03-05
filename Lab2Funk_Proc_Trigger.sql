-- LAB 2

-- INSTRUCTION
/*Create a function that checks if a car is available for renting between two dates. 
The input to the function should be the starting and ending dates of the rental, 
the cars number, and it should return 0 if it is not available and 1 if it is available between the two dates.*/

/* DELIMITER $$
CREATE FUNCTION carAvailable(carID INT, StartDate DATE, EndDate DATE) RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE carCount INT DEFAULT 0;
    SELECT COUNT(*) INTO carCount 
    FROM bookings 
    WHERE bookings.CarNumber = carID 
    AND StartDate <= bookings.EndDate 
    AND EndDate >= bookings.StartDate;
    
    IF carCount > 0 THEN RETURN 0;
    ELSE RETURN 1;
    END IF;
END $$;
DELIMITER ;
*/

-- INSTRUCTION
/*Create a function that sums the total amount of days cars have been booked and returns the sum.*/

/*DELIMITER $$
CREATE FUNCTION  totalDaysRented() RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE totalDays INT DEFAULT 0;
    SELECT SUM(DATEDIFF(EndDate, StartDate) + 1)
    INTO totalDays
    FROM bookings;
    RETURN IFNULL(totalDays, 0);
END$$
DELIMITER ;
*/


-- INSTRUCTION
/*Extend the previous function so that if there is an input parameter that matches a cars unique number, 
then it should only return the sum of that car. 
If the number doesn't match or it is -1, it returns the total sum as before.*/

/*DELIMITER $$
CREATE FUNCTION  totalDaysRentedUnique(thisCarNumber INT) RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE totalDays INT DEFAULT 0;

IF thisCarNumber = -1 OR NOT EXISTS (SELECT 1 FROM bookings WHERE CarNumber = thisCarNumber) THEN
    SELECT SUM(DATEDIFF(EndDate, StartDate) + 1)
    INTO totalDays
    FROM bookings;
    
ELSE
	SELECT SUM(DATEDIFF(EndDate, StartDate) + 1)
    INTO totalDays
    FROM bookings
    WHERE CarNumber = thisCarNumber;
END IF;
RETURN IFNULL(totalDays, 0);
END $$
DELIMITER ;
*/

-- STORED PROCEDURES
/*Create a stored procedure that collects all the cars that are available between two dates.
The inputs to the procedure is starting and ending dates,
and prints all the car numbers that are available to be booked between the two dates.*/

DELIMITER $$
CREATE PROCEDURE carsForRentByDate (IN start_date DATE, IN end_date DATE)
BEGIN
SELECT CarNumber
FROM cars
WHERE CarNumber NOT IN(
	SELECT CarNumber
	FROM bookings
	WHERE StartDate <=end_date AND EndDate >=start_date
);
END $$
DELIMITER ;

/*Create a stored procedure that handles the booking of renting a car. 
The input to the procedure is the starting and ending dates, the cars number,  and the customer number. 
If it is successful it should return 0, if it is unsuccessful in booking it should return 1.*/

DELIMITER $$
CREATE PROCEDURE rentACar (IN start_date DATE, IN end_date DATE, IN car_number INT, IN customer_number INT, OUT result INT)
BEGIN
IF NOT EXISTS(
	SELECT *
	FROM bookings
	WHERE CarNumber = car_number
	AND StartDate <= end_date
	AND EndDate >= start_date
) THEN
	INSERT INTO bookings(CustomerNumber, CarNumber, StartDate, EndDate)
	VALUES (customer_number, car_number, start_date, end_date);
	SET result = 0;
ELSE
	SET result = 1;
END IF;
END $$
DELIMITER ;

-- ALTER TABLE customers
-- ADD COLUMN BookingCount INT DEFAULT 0;

DELIMITER $$
CREATE TRIGGER BookingCount
AFTER INSERT ON bookings
FOR EACH ROW
BEGIN
	UPDATE customers
    SET BookingCount = BookingCount + 1
    WHERE CustomerNumber = NEW.CustomerNumber;
END $$
DELIMITER ;



















