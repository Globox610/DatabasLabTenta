###FUSKLAPP TRANSACTIONS

START TRANSACTION;

-- operation 1
UPDATE table ...

-- operation 2
INSERT INTO table ...

-- operation 3
DELETE FROM table ...

COMMIT;

## MED SAVEPOINT

START TRANSACTION;

UPDATE table ...

SAVEPOINT s1;

UPDATE table ...

ROLLBACK TO s1;

COMMIT;


###FUSKLAPP View

CREATE VIEW customerOrders AS
SELECT
c.name,
o.orderID,
o.total
FROM customers c
JOIN orders o
ON c.customerID = o.customerID;


## SCENARIO: När en order läggs till ska kundens totalsumma uppdateras.
DELIMITER //

CREATE TRIGGER updateCustomerTotal
AFTER INSERT ON orders
FOR EACH ROW
BEGIN

UPDATE customers
SET totalSpent = totalSpent + NEW.total
WHERE customerID = NEW.customerID;

END //

DELIMITER ;
# VIKTIGT!
# NEW.column används vid INSERT
#Triggern körs en gång per rad

## SENCARIO: Om kunden köper en produkt i kategorin Elektronik ska customers.hasElectronics sättas till 1.

DELIMITER //

CREATE TRIGGER electronicsFlag
AFTER INSERT ON orderitems
FOR EACH ROW
BEGIN

IF EXISTS (
  SELECT 1
  FROM products p
  WHERE p.productID = NEW.productID
  AND p.category = 'Elektronik'
)
THEN

UPDATE customers
SET hasElectronics = 1
WHERE customerID =
(
  SELECT o.customerID
  FROM orders o
  WHERE o.orderID = NEW.orderID
);

END IF;

END //

DELIMITER ;
#här används
#EXISTS
#IF
#subquery
#update av annan tabell


#SCENARIO: Om en order ändras måste kundens totalsumma justeras.

DELIMITER //

CREATE TRIGGER adjustCustomerTotal
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN

UPDATE customers
SET totalSpent = totalSpent - OLD.total + NEW.total
WHERE customerID = NEW.customerID;

END //

DELIMITER ;

#VIKTIGT 
#OLD = gamla värdet
#NEW = nya värdet


##SCENARIO: Om en order tas bort ska totalsumman minska.
DELIMITER //

CREATE TRIGGER decreaseCustomerTotal
AFTER DELETE ON orders
FOR EACH ROW
BEGIN

UPDATE customers
SET totalSpent = totalSpent - OLD.total
WHERE customerID = OLD.customerID;

END //

DELIMITER ;
#VIKTIGT Vid DELETE finns bara: OLD


##SCENARIO: Stoppa en order om lagret inte räcker.
DELIMITER //

CREATE TRIGGER checkStock
BEFORE INSERT ON orderitems
FOR EACH ROW
BEGIN

DECLARE currentStock INT;

SELECT stock
INTO currentStock
FROM products
WHERE productID = NEW.productID;

IF currentStock < NEW.quantity THEN

SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Not enough stock';

END IF;

UPDATE products
SET stock = stock - NEW.quantity
WHERE productID = NEW.productID;

END //

DELIMITER ;

#Här används: DECLARE, SELECT INTO, IF, SIGNAL, UPDATE

##SCENARIO: Sätt automatiskt orderstatus.

DELIMITER //

CREATE TRIGGER setOrderStatus
BEFORE INSERT ON orders
FOR EACH ROW
BEGIN

IF NEW.total > 1000 THEN
  SET NEW.status = 'Priority';
ELSE
  SET NEW.status = 'Normal';
END IF;

END //

DELIMITER ;


###FUSKLAPP TRIGGERS

DELIMITER //

CREATE TRIGGER name
BEFORE/AFTER INSERT/UPDATE/DELETE ON table
FOR EACH ROW
BEGIN

DECLARE var datatype;

SELECT column INTO var FROM table WHERE ...;

IF condition THEN
  UPDATE table SET ... WHERE ...;
END IF;

END //

DELIMITER ;

##VIKTIG INFO: INSERT: UPDATE other_table SET column = column + NEW.value
## UPDATE: SET column = column - OLD.value + NEW.value
## DELETE: SET column = column - OLD.value


###PROCEDURE GRUNDSTRUKTUR

DELIMITER //

CREATE PROCEDURE procedure_name(IN param datatype)
BEGIN

DECLARE var datatype;

SELECT column INTO var
FROM table
WHERE condition;

END //

DELIMITER ;


# KÖR PROCEDURE : CALL procedure_name(value);

###PROCEDURE MED IF

DELIMITER //

CREATE PROCEDURE checkCustomer(IN custID INT)
BEGIN

DECLARE total DECIMAL(10,2);

SELECT SUM(total)
INTO total
FROM orders
WHERE customerID = custID;

IF total > 5000 THEN
  UPDATE customers
  SET VIP = 1
  WHERE customerID = custID;
END IF;

END //

DELIMITER ;


###Functions grundstruktur, returnerar värde

DELIMITER //

CREATE FUNCTION function_name(param datatype)
RETURNS datatype
DETERMINISTIC
BEGIN

DECLARE result datatype;

-- logik

RETURN result;

END //

DELIMITER ;


###Function exempel

DELIMITER //

CREATE FUNCTION orderCount(custID INT)
RETURNS INT
DETERMINISTIC
BEGIN

DECLARE cnt INT;

SELECT COUNT(*)
INTO cnt
FROM orders
WHERE customerID = custID;

RETURN cnt;

END //

DELIMITER ;


### användning function SELECT orderCount(1);

### Transaktioner

START TRANSACTION;

UPDATE accounts
SET balance = balance - 100
WHERE id = 1;

UPDATE accounts
SET balance = balance + 100
WHERE id = 2;

COMMIT;

ROLLBACK;





CREATE TABLE Student(
stNum VARCHAR(50) PRIMARY KEY,
Fname VARCHAR(50),
Lname VARCHAR(50),
Age INT,
Telephone VARCHAR(20),
Email VARCHAR(100),
Address VARCHAR(100)
);

CREATE TABLE Book(
ISBN VARCHAR(50) PRIMARY KEY,
Title VARCHAR(50),
Author VARCHAR(50),
shelfNum VARCHAR(20),
numOfCopies INT
);

CREATE TABLE BookLease(
leaseNumber INT PRIMARY KEY,
ISBN VARCHAR (50),
stNum VARCHAR(50),
startDate DATE,
leaseInDays INT,
dateReturned date,
FOREIGN KEY(ISBN) REFERENCES BOOK(ISBN),
FOREIGN KEY(stNum) REFERENCES Student(stNum)
);

INSERT INTO Student (stNum, Fname, Lname, Age, Telephone, Email, Address) VALUES
('DA2G93D','Lars','Andersson',26,'07-71793336','kivaba3175@ineedsa.com','Stackekärr 121, Dyltabruk'),
('K88ZP8O','Anna','Nilsson',25,'07-79156016','veter22@aosdeag.com','Mogata Sjöhagen 60, Bullaren'),
('W6T5WZG','Anders','Johansson',29,'07-72240308','slabody@iaintel.com','Fuglie 80, Umeå'),
('PTQY0BQ','Maria','Karlsson',27,'07-77038419','anzhelagrechka@distraplo.com','Orrspelsv 130, Lycksele'),
('F62FDT84','Mikael','Mountain',26,'07-74215021','marusiam85@epubd.site','Sandviken 57, Dyltabruk');

INSERT INTO Book (ISBN,Title, Author, shelfNum, numOfCopies) VALUES
('F-0055-G', 'De kommer att drunkna i sina mödrars tårar', 'Johannes Anyuru','PER-5',4),
('A-0080-Z', 'Folk med ångest', 'Fredrik Backman','PER-5',4),
('H-0037-M','Välkommen till Amerika', 'Linda Boström Knausgård','SEM-1',4),
('A-0030-B','Silvervägen', 'Stina Jackson','PIN-4',5),
('C-0050-K','Drömfakulteten', 'Sara Stridsberg','PAS-3',4),
('H-0082-M','Inlandet', 'Elin Willows','NAM-8',5);
INSERT INTO BookLease(leaseNumber,ISBN,stNum,startDate,leaseInDays,dateReturned) VALUES
(1,'F-0055-G','PTQY0BQ','2020-06-10',10,'2020-06-20'),
(2,'C-0050-K','K88ZP8O','2020-06-10',8,'2020-06-18'),
(3,'A-0080-Z','DA2G93D','2020-11-10',25,'2020-12-10'),
(4,'F-0055-G','DA2G93D','2020-11-10',25,'2020-12-10'),
(5,'A-0030-B','K88ZP8O','2019-11-03',24,'2019-11-27'),
(6,'H-0037-M','W6T5WZG','2021-12-10',25,NULL),
(7,'C-0050-K','PTQY0BQ','2021-12-10',30, NULL),
(8,'H-0037-M','DA2G93D','2019-05-05',15,'2019-05-06'),
(9,'A-0080-Z','PTQY0BQ','2021-12-05',5, NULL),
(10,'F-0055-G','W6T5WZG','2021-12-03',10, NULL);




SELECT student.stNum, student.Fname, student.Lname, coalesce((SELECT COUNT(BookLease.leaseNumber) FROM BookLease WHERE Student.stNum = booklease.stNum), 0) AS leases
FROM student
WHERE NOT EXISTS(
SELECT 1
FROM BookLease
WHERE Student.stNum = BookLease.stNum
);



SELECT book.ISBN, book.Title, AVG(DATEDIFF(booklease.datereturned, booklease.startDate)) AS AverageBorrowTime
FROM book
LEFT JOIN booklease ON Book.ISBN = Booklease.ISBN
WHERE Booklease.dateReturned IS NOT NULL
GROUP BY Book.ISBN, Book.Title;



DELIMITER //

CREATE TRIGGER BookReturned
AFTER UPDATE ON booklease
FOR EACH ROW
BEGIN 
	IF OLD.returndate IS NULL AND NEW.datereturned IS NOT NULL 
    THEN 
    UPDATE book
    SET book.numOfCopies = book.numOfCopies + 1
    WHERE NEW.ISBN = book.ISBN;
    END IF;

END//
DELIMITER ;



SELECT student.stNum, CONCAT(student.fname, ' ', student.lname) AS Name_, booklease.leaseNumber, booklease.ISBN
FROM student
LEFT JOIN booklease ON student.stNum = booklease.stNum
ORDER BY booklease.leasenumber DESC;


SELECT CONCAT(student.fname, ' ', student.lname) AS Name_, Book.title, date_add(booklease.startdate, INTERVAL booklease.leaseindays DAY) AS ExpectedReturnDate #Adds numbers of days to startdate thats in leaseindays
From student
JOIN booklease ON student.stNum = booklease.stNum
JOIN book ON booklease.ISBN = book.isbn
WHERE booklease.dateReturned IS NULL;


DROP VIEW ExcpectedDate;
CREATE VIEW ExcpectedDate AS
SELECT b.ISBN, b.title, s.fname, s.lname, date_add(bl.startdate, INTERVAL bl.leaseindays DAY) AS expactedreturn
FROM student s
JOIN booklease bl ON s.stNum = bl.stNum
JOIN book b ON bl.ISBN = b.ISBN
WHERE bl.dateReturned IS NULL;

SELECT * FROM ExcpectedDate;



#### HÄR BÖRJAR MENTOR ADAMS TEMPLATE


-- ==========================================
-- NAME: ----
-- EXAM: ----
-- ==========================================

-- ------------------------------------------
-- UPPGIFT 1: Skapa tabeller och Insert
-- Reflektion: [Skriv kort hur du tänkte med PK/FK här] 
-- ------------------------------------------

-- Template for creating a table with Primary and Foreign Keys
CREATE TABLE TableName (
    idColumn INT PRIMARY KEY,
    nameColumn VARCHAR(255),
    fkColumn INT,
    FOREIGN KEY (fkColumn) REFERENCES OtherTable(idColumn)
);

-- (Insert statements provided in the exam)

-- ------------------------------------------
-- UPPGIFT 2: SELECT med JOIN
-- Reflektion: [Kort om hur du kopplade tabellerna] 
-- ------------------------------------------
-- Template for a basic INNER JOIN
SELECT A.column1, B.column2 
FROM TableA A
JOIN TableB B ON A.id = B.a_id;


-- ------------------------------------------
-- UPPGIFT 3: SELECT med Aggregation
-- Reflektion: [Kort om varför du valde GROUP BY] 
-- ------------------------------------------
-- Template for counting items
SELECT column_to_group_by, COUNT(column_to_count)
FROM TableName
GROUP BY column_to_group_by;


-- ------------------------------------------
-- UPPGIFT 4: VIEW
-- Reflektion: [Kort om hur du filtrerade på CURDATE()]
-- ------------------------------------------
-- Template for creating a View
CREATE OR REPLACE VIEW ViewName AS
SELECT column1, MAX(column2)
FROM TableName
WHERE dateColumn >= CURDATE() -- active check
GROUP BY column1;

-- Test the view
SELECT * FROM ViewName;


-- ------------------------------------------
-- UPPGIFT 5: TRIGGER
-- Reflektion: [Kort om hur triggern uppdaterar datumet] 
-- ------------------------------------------
-- Template for a Trigger (Kom ihåg DELIMITER!)
DELIMITER //
CREATE TRIGGER TriggerName
AFTER INSERT ON BidTable -- or BEFORE INSERT depending on logic
FOR EACH ROW
BEGIN
    -- Logic to check if NEW.bidDate = Item.lastBidDate
    -- UPDATE ItemTable SET lastBidDate = lastBidDate + INTERVAL 1 DAY WHERE ... 
END //
DELIMITER ;

-- Test with an insert
-- INSERT INTO ...


-- ------------------------------------------
-- UPPGIFT 6: FUNKTION 
-- Reflektion: [Kort om IF/ELSE logiken för 10% vs 20%]
-- ------------------------------------------
-- Template for a Function calculating revenue
DELIMITER //
CREATE FUNCTION CalculateRevenue(finalPrice DECIMAL) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE revenue DECIMAL(10,2);
    
    IF finalPrice < 1000 THEN [cite: 113]
        SET revenue = finalPrice * 0.20; [cite: 113]
    ELSE
        SET revenue = finalPrice * 0.10; [cite: 113]
    END IF;
    
    RETURN revenue;
END //
DELIMITER ;

-- Test the function
SELECT CalculateRevenue(800); 


-- ------------------------------------------
-- UPPGIFT 7: Avancerad SELECT (OUTER JOIN)
-- Reflektion: [Kort om varför du använde LEFT/RIGHT JOIN för att visa alla]
-- ------------------------------------------
-- Template to show ALL records from Table A, even if no match in Table B
SELECT A.name, B.data
FROM TableA A
LEFT JOIN TableB B ON A.id = B.a_id;
