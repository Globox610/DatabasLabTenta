USE dv1703;
CREATE TABLE IF NOT EXISTS cars(
CarNumber INT auto_increment PRIMARY KEY,
Brand VARCHAR (20),
Model VARCHAR (20),
Color VARCHAR(20),
PricePerDay INT
);

CREATE TABLE IF NOT EXISTS customers(
CustomerNumber INT auto_increment PRIMARY KEY,
Name VARCHAR(20),
BirthDate DATE
);

CREATE TABLE IF NOT EXISTS Bookings(
CustomerNumber INT,
CarNumber INT,
StartDate DATE,
EndDate DATE,
FOREIGN KEY (CustomerNumber) references customers(CustomerNumber),
FOREIGN KEY (CarNumber) references cars(CarNumber)
);

