DROP PROCEDURE IF EXISTS spSumAccount;

-- Adam 
DELIMITER $$
CREATE PROCEDURE spSumAccount()
BEGIN
SELECT SUM(balanceAccount) AS SumAccount,
(SELECT IFNULL(SUM(amountAccountLog), 0) FROM AccountLog) AS SumAccountLog
FROM account;
END $$
DELIMITER ;

-- Johan 1.0
DELIMITER $$
CREATE PROCEDURE spSumAccount()
BEGIN
    DECLARE totalAccount INT;
    DECLARE totalAccountLog INT;

    SELECT SUM(balanceAccount) INTO totalAccount FROM account;
    SELECT SUM(amountAccountLog) INTO totalAccountLog FROM accountlog;

    SELECT totalAccount AS TotalAccount,
           IFNULL(totalAccountLog, 0) AS TotalAccountLog;
END $$
DELIMITER ;

-- Johan 2.0
DELIMITER $$
CREATE PROCEDURE spSumAccount()
BEGIN
    SELECT 
        IFNULL((SELECT SUM(balanceAccount) FROM Account), 0) AS TotalAccount,
        IFNULL((SELECT SUM(amountAccountLog) FROM accountlog), 0) AS TotalAccountLog;
END $$
DELIMITER ;


-- Explicit transactions
SET autocommit = 0; -- must have to be able to ROLLBACK
START TRANSACTION;
SELECT * FROM account;
SELECT * FROM accountLog;

UPDATE account
SET balanceAccount = balanceAccount - 300
WHERE nrAccount = 1;

INSERT INTO accountLog(AccountLog_nrAccount, timeAccountLog, amountAccountLog)
VALUES(1, NOW(), -300);

SELECT * FROM account;
SELECT * FROM accountLog;

ROLLBACK;
SELECT * FROM account;
SELECT * FROM accountLog;

-- Without rollback and commit
START TRANSACTION;
UPDATE Account
SET balanceAccount = balanceAccount - 300
WHERE nrAccount = 1;

INSERT INTO AccountLog(AccountLog_nrAccount, timeAccountLog, amountAccountLog)
VALUES(1, NOW(), -300);

COMMIT;
SELECT * FROM Account;
SELECT * FROM AccountLog;

ROLLBACK;