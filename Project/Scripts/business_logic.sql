-- business_logic.sql
-- Author: Mazen Zwin
-- 90%+ implemented by Mazen Zwin | Database Analyst/Developer
-- Contains advanced triggers, functions, procedures, events, and test scripts for MultimediaContentDB
-- Features: error logging, watchlist enforcement, transaction validation, genre ranking, subscription validation

-- 1. Error Log Table
-- Centralized table for capturing system errors and business rule violations
CREATE TABLE IF NOT EXISTS Error_Log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    error_message TEXT,
    error_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Drop all triggers first to avoid 'already exists' errors
DROP TRIGGER IF EXISTS trg_watchlist_limit;
DROP TRIGGER IF EXISTS trg_log_transaction_error;

-- 2. Trigger: Enforce Watchlist Size Limit (max 100 items per user)
DELIMITER $$
CREATE TRIGGER trg_watchlist_limit
BEFORE INSERT ON Watchlist
FOR EACH ROW
BEGIN
    IF (SELECT COUNT(*) FROM Watchlist WHERE user_id = NEW.user_id) >= 100 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Watchlist limit reached';
    END IF;
END$$
DELIMITER ;

-- 3. Trigger: Log Negative Transaction Amounts
DELIMITER $$
CREATE TRIGGER trg_log_transaction_error
AFTER INSERT ON Transaction
FOR EACH ROW
BEGIN
    IF NEW.amount < 0 THEN
        INSERT INTO Error_Log (error_message) VALUES ('Negative transaction amount');
    END IF;
END$$
DELIMITER ;

-- 4. Function: Rank Genres by Popularity
DELIMITER $$
CREATE FUNCTION get_genre_rank(gid INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE rank INT;
    SELECT COUNT(*) INTO rank FROM Content_Genre WHERE genre_id = gid;
    RETURN rank;
END$$
DELIMITER ;

-- 5. Function: Validate Active Subscription
DELIMITER $$
CREATE FUNCTION is_subscription_active(uid INT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE active INT;
    SELECT COUNT(*) INTO active FROM User_Subscription WHERE user_id = uid AND end_date > NOW();
    RETURN active > 0;
END$$
DELIMITER ;

-- 6. Procedure: Generate Content Usage Report
DELIMITER $$
CREATE PROCEDURE generate_content_report()
BEGIN
    SELECT c.title, COUNT(w.history_id) AS views
    FROM Content c
    LEFT JOIN Content_WatchHistory w ON c.content_id = w.content_id
    GROUP BY c.content_id;
END$$
DELIMITER ;

-- 7. Procedure: Handle Failed Payment
DELIMITER $$
CREATE PROCEDURE handle_failed_payment(uid INT)
BEGIN
    UPDATE User_Subscription
    SET end_date = NOW()
    WHERE user_id = uid AND end_date > NOW();
END$$
DELIMITER ;

-- 8. Scheduled Event: Expire Subscriptions Daily
CREATE EVENT IF NOT EXISTS expire_subscriptions
ON SCHEDULE EVERY 1 DAY
DO
    UPDATE User_Subscription
    SET end_date = NOW()
    WHERE end_date < NOW() AND end_date IS NOT NULL;

-- 9. Test Scripts
-- Test watchlist trigger
-- (Assume user_id 1 exists and has 100 items)
-- INSERT INTO Watchlist (user_id, content_id) VALUES (1, 101);
-- Should fail if user already has 100 items

-- Test genre ranking function
-- SELECT get_genre_rank(1);

-- Test subscription validation
-- SELECT is_subscription_active(1);

-- Test content report
-- CALL generate_content_report();

-- Test event (simulate daily run)
-- CALL handle_failed_payment(1);
