-- Carl Everman

-- 1

CREATE TABLE Student (
stNum VARCHAR(50) NOT NULL, 
Fname VARCHAR(50),
Lname VARCHAR(50),
Age INT,
Telephone VARCHAR(20),
Email VARCHAR(50),
Address VARCHAR(50),
PRIMARY KEY (stNum)
);
DROP TABLE Student;
CREATE TABLE Book (
ISBN VARCHAR(50) NOT NULL,
Title VARCHAR(50),
Author VARCHAR(50),
shelfNum VARCHAR(10),
numOfCopies INT,
PRIMARY KEY (ISBN)
);
SELECT * FROM Book;
DROP TABLE BOOK;
CREATE TABLE BookLease (
leaseNumber INT AUTO_INCREMENT NOT NULL,
ISBN VARCHAR(50) NOT NULL,
stNum VARCHAR(50) NOT NULL,
startDate DATE,
leaseInDays INT,
dateReturned DATE,
PRIMARY KEY (leaseNumber),
FOREIGN KEY (ISBN) REFERENCES Book(ISBN),
FOREIGN KEY (stNum) REFERENCES Student(stNum)
);
SELECT * FROM BookLease;
DROP TABLE BookLease;
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

-- 2
SELECT
	s.stNum,
    s.Fname,
    s.Lname,
    0 AS numOfLeases
FROM Student s
WHERE s.stNum NOT IN (
	SELECT stNum FROM BookLease
);

SELECT s.stNum, s.Fname, s.Lname, 0 AS numOfLeases
FROM student s
LEFT JOIN BookLease b ON s.stNum = b.stNum
WHERE b.stNum IS NULL
GROUP BY s.stnum;
-- 3
SELECT
	b.ISBN,
    b.Title,
    AVG(DATEDIFF(l.dateReturned, l.startDate)) AS AverageBorrowTime
FROM Book b
JOIN BookLease l ON b.ISBN = l.ISBN
WHERE l.dateReturned IS NOT NULL
GROUP BY b.ISBN, b.Title;

SELECT b.ISBN, b.Title, AVG(DATEDIFF(bl.dateReturned, bl.startDate)) AS averageRental
FROM book b
JOIN BookLease bl ON b.ISBN = bl.ISBN
WHERE bl.dateReturned IS NOT NULL
GROUP BY b.ISBN;
-- 4 

CREATE OR REPLACE VIEW currentlyRented AS
SELECT b.ISBN, b.Title, s.Fname, s.Lname, DATE_ADD(bl.startDate, INTERVAL bl.leaseInDays DAY) AS expectedReturn
FROM Book b
JOIN BookLease bl ON b.ISBN = bl.ISBN
JOIN Student s ON bl.stNum = s.stNum
WHERE bl.dateReturned IS NOT NULL;

SELECT * FROM currentlyRented;
-- 5
DELIMITER //

CREATE TRIGGER increase_book_amount 
AFTER UPDATE ON BookLease
FOR EACH ROW
BEGIN
	IF OLD.dateReturned IS NULL AND NEW.dateReturned IS NOT NULL THEN
		UPDATE Book
		SET numOfCopies = numOfCopies + 1
		WHERE ISBN = NEW.ISBN;
	END IF;
END //

DELIMITER ;

DELIMITER //
CREATE TRIGGER increase_book_amount
AFTER UPDATE ON BookLease
FOR EACH ROW
	BEGIN
    IF OLD.dateReturned IS NULL AND NEW.dateReturned IS NOT NULL
    THEN
    UPDATE Book SET Book.numOfCopies = Book.numOfCopies +1
    WHERE Book.ISBN = NEW.ISBN;
	END IF;
END //

DELIMITER;


UPDATE booklease SET dateReturned = CURRENT_DATE WHERE leaseNumber = 6;
DROP TRIGGER increase_book_amount;
-- 6
DELIMITER //

CREATE PROCEDURE leaseBook(
	IN p_ISBN	VARCHAR(50),
    IN p_stNum	VARCHAR(50),
    IN p_startDate DATE
)
BEGIN
	DECLARE copiesAvailable INT;
    
    -- Check how many copies are available
    SELECT numOfCopies INTO copiesAvailable
    FROM Book
    WHERE ISBN = p_ISBN;
    
    IF copiesAvailable > 0 THEN
		-- Insert the new lease
        INSERT INTO BookLease (ISBN, stNum, startDate, dateReturned)
        VALUES (p_ISBN, p_stNum, p_startDate, NULL);
        
        UPDATE Book
        SET numOfCopies = numOfCopies - 1
        WHERE ISBN = p_ISBN;
        
        SELECT 'Row inserted' AS Message;
	ELSE
		SELECT 'Row NOT inserted! No copy available.' AS Message;
	END IF;
END //

DELIMITER ;

DELIMITER //
CREATE PROCEDURE LeaseBook(
	IN p_leaseNumber INT,
	IN p_ISBN VARCHAR(50),
    IN p_stNum VARCHAR(50),
    IN P_startDate DATE,
    IN p_leaseInDays INT,
    IN p_dateReturned DATE,
    OUT message VARCHAR(50)
    )
BEGIN
DECLARE nrOfCopies INT;
SELECT numOfCopies INTO nrOfCopies FROM Book
WHERE ISBN = p_ISBN;

IF nrOfCopies = 0 THEN
SELECT "Row not inserted!" AS MESSAGE;
ELSE
INSERT INTO bookLease(leaseNumber, ISBN, stNum, startDate, leaseInDays, dateReturned)
VALUES (p_leaseNumber, p_ISBN, p_stNum, p_startDate, p_leaseInDays, p_dateReturned);
UPDATE Book b
SET b.numOfCopies = b.numOfCopies - 1
WHERE b.ISBN = p_ISBN;
SELECT "Row inserted" AS Message;
END IF;
END //
DELIMITER ;
DROP PROCEDURE LeaseBook;
CALL LeaseBook(18, "F-0055-G", "W6T5WZG", "2021-11-03", 10, NULL, @str);

-- 7

SELECT
	s.stNum,
    CONCAT(s.fName, ' ', s.lName) AS name_,
    bl.leaseNumber,
    bl.ISBN
FROM Student s
LEFT JOIN BookLease bl ON s.stNum = bl.stNum
ORDER BY bl.leaseNumber DESC;

SELECT 
	s.stNum,
	CONCAT(s.fName, ' ', s.lName) AS name_,
    bl.leaseNumber,
    bl.ISBN
FROM Student s
LEFT JOIN BookLease bl ON s.stNum = bl.stNum
ORDER BY bl.leaseNumber DESC;
    

-- 8 
SELECT
    s.stNum,
    CONCAT(s.Fname, ' ', s.Lname) AS name_,
    b.Title,
    DATE_ADD(bl.startDate, INTERVAL bl.leaseInDays DAY) AS ExpectedReturnDate
FROM Student s
JOIN BookLease bl ON s.stNum = bl.stNum
JOIN Book b ON bl.ISBN = b.ISBN
WHERE bl.dateReturned IS NULL;

SELECT 
	s.stNum,
	CONCAT(s.fName, ' ', s.lName) AS name_,
    b.Title,
    DATE_ADD(bl.startDate, INTERVAL bl.leaseInDays DAY) AS expectedReturnDate
FROM Student s
JOIN BookLease bl ON s.stNum = bl.stNum
JOIN Book b ON bl.ISBN = b.ISBN
WHERE bl.dateREturned IS NULL
ORDER BY bl.leaseNumber DESC;

-- 9 FAKE VERSION
SELECT
	leaseNumber,
    ISBN,
    Fname,
    Lname,
    DaysOverdue,
    DaysOverdue * 12.5 AS totalAmount
FROM (
	SELECT
    bl.leaseNumber,
    bl.ISBN,
    s.Fname,
    s.Lname,
    bl.leaseInDays,
    DATEDIFF(bl.dateReturned, bl.startDate)-bl.leaseInDays AS DaysOverdue
FROM BookLease bl
JOIN Student s ON s.stNum = bl.stNum
) AS sub
WHERE DaysOverdue > 0;

-- 9
DELIMITER //
CREATE FUNCTION getOoerdueDays(p_leaseNUmber INT)
RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE overdueDays INT;
    
    SELECT DATEDIFF(dateReturned, startDate) - leaseInDays
    INTO overdueDays
    FROM BookLease
    WHERE leaseNumber = p_leaseNumber;
    
    RETURN overdueDays;
END //

DELIMITER ;

SELECT
    bl.leaseNumber,
    bl.ISBN,
    s.Fname,
    s.Lname,
    getOverdueDays(bl.leaseNumber) AS numOfOverdueDays,
    getOverdueDays(bl.leaseNumber) * 12.5 AS totalAmount
FROM BookLease bl
JOIN Student s ON s.stNum = bl.stNum
WHERE getOverdueDays(bl.leaseNumber) > 0;

-- VERSION TWO
DELIMITER // 
CREATE FUNCTION getOverdueDays(p_leaseNumber INT)
RETURNS INT 
DETERMINISTIC
BEGIN
	DECLARE v_overdue INT;
    SELECT 
		GREATEST(0, DATEDIFF(dateReturned, DATE_ADD(startDate, INTERVAL leaseInDays DAY)))
        INTO v_overdue
        FROM BookLease
        WHERE leaseNumber = p_leaseNumber;
        RETURN v_overdue;
	END //
DELIMITER ;

SELECT bl.leaseNumber, bl.ISBN, s.Fname, s.Lname, getOverdueDays(bl
