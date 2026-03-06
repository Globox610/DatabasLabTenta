-- create database LiBoLS;
USE libols;
CREATE TABLE IF NOT EXISTS Student(
stNum VARCHAR(20) PRIMARY KEY,
Fname VARCHAR(20),
Lname VARCHAR(20),
Age INT,
Telephone VARCHAR(20),
Email VARCHAR(255),
Address VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS Book(
ISBN VARCHAR(20) PRIMARY KEY,
Title VARCHAR(255),
Author VARCHAR(255),
shelfNum VARCHAR(100),
numOfCopies INT
);

CREATE TABLE IF NOT EXISTS BookLease(
leaseNumber INT AUTO_INCREMENT PRIMARY KEY,
ISBN VARCHAR(20),
stNum VARCHAR(20),
startDate DATE,
leaseInDays INT,
dateReturned DATE,
FOREIGN KEY (ISBN) references Book(ISBN),
FOREIGN KEY (stNum) references Student(stNum)
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

/* 2. Write an SQL statement that shows info about students who have not borrowed any books. 
Table should have the following columns: stNum | Fname | Lname | numOfLeases.*/
SELECT s.stNum, s.Fname, s.Lname, count(bl.stNum) 
as numOfLeases 
FROM student s 
LEFT JOIN booklease bl ON s.stNum = bl.stNum 
WHERE bl.stNum IS NULL 
GROUP BY s.stNum;

/* 3. Write an SQL statement that shows each Book and its average lease time 
(the actual days, not the planned ones), 
only count leases that are completed (dateReturned is available). 
The result table should show the following columns: 
the ISBN, Title, and the average rental days as “AverageBorrowTime”.*/

SELECT book.ISBN, book.Title, AVG(DATEDIFF(booklease.dateReturned, booklease.startDate))
AS AverageBorrowTime
FROM book
JOIN booklease ON Book.ISBN = Booklease.ISBN
WHERE Booklease.dateReturned IS NOT NULL
GROUP BY Book.ISBN
ORDER BY AverageBorrowTime;

/* 4. Create a view that shows which Books are currently rented (dateReturned is null), 
with the columns ISBN, Title, Fname, Lname, and expected return date 
(e.g., startDate plus leaseInDays) as “ExpectedDate”.*/

CREATE OR REPLACE VIEW BooksRented AS
SELECT b.ISBN, b.title, s.fname, s.lname, date_add(bl.startDate, INTERVAL bl.leaseindays DAY)
FROM Student s
JOIN booklease bl ON s.stNum = bl.stNum
JOIN book b ON bl.ISBN = b.ISBN
WHERE bl.dateReturned IS NULL; -- active check

SELECT * FROM BooksRented;

/* 5. Create a trigger on the BookLease table which, when a lease is returned 
(when null is changed to date in returnDate),
increases the respective Book's number of copies by 1.*/

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

--- Procedure 
/*6. Create a procedure that handles a lease of a book. Checks must be made so that the book’s number of copies is not equal to zero. 
If no copy is available of the book (numOfCopies = 0) the lease must not go through (aborted). 
The procedure must check if the book is still available and do the following actions:
if available, it inserts the new row into the BookLease table, it decrements the numOfCopies in the Book table, and it displays the message “Row inserted”.
Else, nothing will happen except getting the message: “Row NOT inserted! No copies available.”
*/

DELIMITER $$
CREATE PROCEDURE LeaseBook(IN p_leaseNumber INT, IN p_ISBN VARCHAR(20), IN p_stNum VARCHAR(20), IN p_startDate DATE, IN p_leaseInDays INT, OUT p_message VARCHAR(255))
BEGIN
    IF (SELECT numOfCopies FROM Book WHERE ISBN = p_ISBN) > 0 THEN
        INSERT INTO BookLease (ISBN, stNum, startDate, leaseInDays, dateReturned)
        VALUES (p_ISBN, p_stNum, p_startDate, p_leaseInDays, NULL);

        UPDATE Book
        SET numOfCopies = numOfCopies - 1
        WHERE ISBN = p_ISBN;
        
        SET p_message = 'Row inserted';
    ELSE
        SET p_message = 'Row NOT inserted! No copies available.';
    END IF;
END $$
DELIMITER ;

-- Testar procedure

CALL LeaseBook(11, 'F-0055-G', 'W6T5WZG', '2021-11-03', 10, @str);
SELECT @str;
CALL LeaseBook(12, 'F-0055-G', 'W6T5WZG', '2021-11-03', 10, @str);
SELECT @str;
CALL LeaseBook(13, 'F-0055-G', 'W6T5WZG', '2021-11-03', 10, @str);
SELECT @str;
CALL LeaseBook(14, 'F-0055-G', 'W6T5WZG', '2021-11-03', 10, @str);
SELECT @str;
CALL LeaseBook(15, 'F-0055-G', 'W6T5WZG', '2021-11-03', 10, @str);
SELECT @str;

/*Write an SQL statement that shows all students, each lease the student has made, and which books they have borrowed. 
If a student has not made any lease, s/he must still appear in the results. 
The result table should show the following columns:
 stNum | combine FName and LName as name_ | leaseNumber | ISBN. 
Display leaseNumber in descending order.*/

SELECT student.stNum, CONCAT(student.fname, ' ', student.lname) AS Name_, booklease.leaseNumber, booklease.ISBN
FROM student
LEFT JOIN booklease ON student.stNum = booklease.stNum
ORDER BY booklease.leasenumber DESC;

/* 8. Write an SQL statement that displays the students who are still borrowing a book. 
The result table should show the following columns: 
studentName (concatenate with a space: Fname and Lname), Title and ExpectedReturnDate.*/

SELECT CONCAT(s.Fname, ' ', s.Lname) 
AS name_, b.Title, date_add(bl.startDate, INTERVAL bl.leaseInDays DAY) 
AS expectedReturn 
FROM student s 
JOIN booklease bl
ON s.stNum = bl.stNum 
JOIN book b ON b.ISBN = bl.ISBN 
WHERE bl.dateReturned IS NULL;


/* 10. Create a function that accepts as an input 
the book ISBN and outputs the number of times this book has been borrowed 
(from table BookLease). 
Plug this function into a SELECT statement to display the books in descending order by numOfTimes, 
if a book has never been borrowed (i.e, H-0082-M), it still must be shown. 
The table should have the following columns: 
ISBN | Title | numOfTimes */

DELIMITER //
CREATE FUNCTION	 timesLeased(p_ISBN VARCHAR(20))
RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE count INT;
	SELECT COUNT(*) INTO count
	FROM BookLease
	WHERE ISBN = p_ISBN;
	RETURN count;
END //
DELIMITER ;

-- to show full list
SELECT ISBN, Title, timesLeased(ISBN) 
AS numOfTimes
FROM Book
ORDER BY numOfTimes DESC;

/*
  9. Let’s say that the library imposes a fine of 12.5 SEK for each day a book is overdue. 
  Write a SQL statement that shows each rented book, the student’s name, number of overdue days, and the overdue amount. 
  The result table should show the following columns: the leaseNumber, ISBN, Fname, Lname, numOfOverdueDays, and totalAmount 
  (OBS! Only show the students who have overdue amount). 
  Use a function that accepts an input (i.e., leaseNumber) and returns numOfOverdueDays.*/

DELIMITER //
CREATE FUNCTION getOverdueDays(p_leaseNumber INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_overdue INT;
    SELECT 
        GREATEST(0, DATEDIFF(
            dateReturned,
            DATE_ADD(startDate, INTERVAL leaseInDays DAY)
        ))
    INTO v_overdue
    FROM BookLease
    WHERE leaseNumber = p_leaseNumber;
    RETURN v_overdue;
END //
DELIMITER ;

-- v2
DELIMITER //

CREATE FUNCTION getOverdueDays(p_leaseNumber INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_overdue INT;
    
    SELECT DATEDIFF(dateReturned, DATE_ADD(startDate, INTERVAL leaseInDays DAY))
    INTO v_overdue
    FROM BookLease
    WHERE leaseNumber = p_leaseNumber;
    
    IF v_overdue < 0 THEN SET v_overdue = 0; END IF;
    
    RETURN v_overdue;
END //

DELIMITER ;
-- to show full list
SELECT 
    bl.leaseNumber,
    bl.ISBN,
    s.Fname,
    s.Lname,
    getOverdueDays(bl.leaseNumber) AS numOfOverdueDays,
    getOverdueDays(bl.leaseNumber) * 12.5 AS totalAmount
FROM BookLease bl
JOIN Student s ON bl.stNum = s.stNum
WHERE bl.dateReturned IS NOT NULL
HAVING numOfOverdueDays > 0;


SELECT getOverdueDays(6);
DROP FUNCTION IF EXISTS getOverdueDays;
SHOW FUNCTION STATUS WHERE Name = 'getOverdueDays';

SELECT leaseNumber, dateReturned FROM BookLease WHERE leaseNumber = 6;
UPDATE BookLease SET dateReturned = NULL WHERE leaseNumber = 6;