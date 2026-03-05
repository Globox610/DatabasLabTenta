-- IN

-- SELECT * FROM cars WHERE PricePerDay IN (700,800,850);
-- SELECT * FROM customers WHERE YEAR(BirthDate) IN ('1990', '1995', '2000');
-- SELECT * FROM bookings WHERE StartDate IN ('2018-01-03', '2018-02-22','2018-03-18');

-- BETWEEN

-- SELECT * FROM cars WHERE PricePerDay BETWEEN 600 AND 1000;
-- SELECT * FROM customers WHERE YEAR(BirthDate) Between '1960' AND '1980';
-- SELECT * FROM bookings WHERE EndDate - StartDate BETWEEN 2 AND 4;

-- VOODOO BACKSHOT MAGIC STUFF

-- SELECT * FROM cars LEFT JOIN bookings On cars.CarNumber = bookings.CarNumber AND bookings.StartDate <= '2018-01-20' AND EndDate >= '2018-01-10' WHERE bookings.CarNumber IS NULL;
-- SELECT c.CarNumber, c.Brand, c.Model, c.Color, c.PricePerDay, COUNT(b.CarNumber) AS booking_COUNT FROM cars c JOIN bookings b ON c.CarNumber = b.CarNumber GROUP BY c.CarNumber ORDER BY booking_COUNT DESC LIMIT 1;
-- SELECT Distinct Name FROM customers INNER JOIN bookings ON customers.CustomerNumber = bookings.CustomerNumber WHERE MONTH(customers.BirthDate) IN ('01','02'); 

-- DELETE, UPPDATE, ALTER & INSERT
-- SET SQL_SAFE_UPDATES = 0;
-- DELETE FROM customers WHERE YEAR(BirthDate) < '1900';
-- SELECT * FROM customers;
-- UPDATE cars SET PricePerDay = PricePerDay + 200 WHERE Brand = 'Tesla' AND Model = 'X';
-- SELECT * FROM cars;
-- UPDATE cars SET PricePerDay = PricePerDay * 1.2 WHERE Brand = 'Peugeot';
-- ALTER TABLE cars MODIFY COLUMN PricePerDay FLOAT;
-- UPDATE cars SET PricePerDay = PricePerDay / 10;

-- VIEWS

-- CREATE VIEW black_cars AS SELECT * FROM cars WHERE Color='Black'; 
-- CREATE VIEW black_cars_week AS SELECT CarNumber, Brand, Model, Color, PricePerDay, PricePerDay*7 AS Week_Price FROM cars WHERE Color='Black'; 
-- INSERT INTO black_cars (Brand, Model, Color, PricePerDay)VALUES ('Ferrari', 'F500', 'Black', 200);

-- SELECT * FROM cars;
-- CREATE VIEW available_cars_now AS SELECT * FROM cars WHERE CarNumber NOT IN (SELECT CarNumber FROM bookings b WHERE CURRENT_DATE BETWEEN StartDate AND EndDate);
 
/*ALTER VIEW available_cars AS
SELECT CarNumber, Brand, Model, Color, PricePerDay
FROM cars
WHERE CarNumber NOT IN (
    SELECT CarNumber 
    FROM bookings
    WHERE StartDate <= CURRENT_DATE + 2
    AND EndDate >= CURRENT_DATE
);
*/
