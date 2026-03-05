-- SELECT * FROM cars WHERE PricePerDay > (SELECT AVG(PricePerDay) FROM cars);
-- SELECT * FROM cars WHERE Color = 'Black' AND PricePerDay = (SELECT MIN(PricePerDay) FROM cars WHERE Color = 'Black');
-- SELECT * FROM cars WHERE PricePerDay = (SELECT MIN(PricePerDay) FROM cars);
-- SELECT * FROM cars WHERE Color='Black' AND CarNumber IN (SELECT CarNumber FROM bookings);

