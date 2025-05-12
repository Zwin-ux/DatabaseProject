-- Triggers.sql
-- Contains all triggers for MultimediaContentDB

-- Auxiliary Error Tables (if not exists)
CREATE TABLE IF NOT EXISTS Director_Assignment_Errors (
    error_id INT PRIMARY KEY AUTO_INCREMENT,
    content_id INT,
    director_id INT,
    error_message VARCHAR(255),
    error_time DATETIME DEFAULT NOW()
);
DROP TABLE IF EXISTS Error_Log;
CREATE TABLE Error_Log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    error_message TEXT,
    error_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Drop all triggers first to avoid 'already exists' errors I got like 6 errors for this  i love SQL
DROP TRIGGER IF EXISTS trg_watchlist_limit;
DROP TRIGGER IF EXISTS trg_unique_director;
DROP TRIGGER IF EXISTS trg_log_transaction_error;
DROP TRIGGER IF EXISTS trg_archive_content_on_low_rating;

-- 1. Trigger: Enforce Watchlist Size Limit (max 50 items per user)
-- If user has 50, remove oldest, then insert
DELIMITER $$
CREATE TRIGGER trg_watchlist_limit
BEFORE INSERT ON Watchlist
FOR EACH ROW
BEGIN
    DECLARE watchlist_count INT;
    SELECT COUNT(*) INTO watchlist_count 
    FROM Watchlist 
    WHERE user_id = NEW.user_id;
    IF watchlist_count >= 50 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Watchlist limit reached';
    END IF;
END$$
DELIMITER ;;

-- 2. Trigger: Ensure Unique Director for Content
-- Block duplicate director assignments, log errors to Director_Assignment_Errors
DROP TRIGGER IF EXISTS trg_unique_director;
DELIMITER $$
CREATE TRIGGER trg_unique_director
BEFORE INSERT ON Content_Director
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 FROM Content_Director
        WHERE content_id = NEW.content_id AND director_id = NEW.director_id
    ) THEN
        INSERT INTO Director_Assignment_Errors (content_id, director_id, error_message)
        VALUES (NEW.content_id, NEW.director_id, 'Duplicate director assignment');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Duplicate director for content';
    END IF;
END;

-- 3. Trigger: Log Negative Transaction Amounts
DROP TRIGGER IF EXISTS trg_log_transaction_error;
DELIMITER $$
CREATE TRIGGER trg_log_transaction_error
AFTER INSERT ON Transaction
FOR EACH ROW
BEGIN
    IF NEW.amount < 0 THEN
        INSERT INTO Error_Log (error_message) VALUES ('Negative transaction amount');
    END IF;
END;

-- 4. Trigger: Archive Content if Average Rating Drops Below 2.0
DROP TRIGGER IF EXISTS trg_archive_content_on_low_rating;
DELIMITER $$
CREATE TRIGGER trg_archive_content_on_low_rating
AFTER INSERT ON Review
FOR EACH ROW
BEGIN
    DECLARE avg_rating DECIMAL(3,2);
    
    -- Get latest average rating
    SELECT AVG(score) INTO avg_rating 
    FROM Rating 
    WHERE content_id = NEW.content_id;
    
    -- Archive content if rating is too low
    IF avg_rating < 2.0 THEN
        UPDATE Content_Availability
        SET available_to = NOW(), available_from = NULL
        WHERE content_id = NEW.content_id;
        
        -- Log the archiving action for audit purposes
        INSERT INTO Error_Log (error_message) 
        VALUES (CONCAT('Content ID ', NEW.content_id, ' archived due to low rating of ', avg_rating));
    END IF;
END$$
DELIMITER ;
