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
CREATE TABLE IF NOT EXISTS Error_Log (
    error_id INT PRIMARY KEY AUTO_INCREMENT,
    error_message VARCHAR(255),
    error_time DATETIME DEFAULT NOW()
);

-- 1. Trigger: Enforce Watchlist Size Limit (max 50 items per user)
-- If user has 50, remove oldest, then insert
DROP TRIGGER IF EXISTS trg_watchlist_limit;
DELIMITER $$
CREATE TRIGGER trg_watchlist_limit
BEFORE INSERT ON Watchlist
FOR EACH ROW
BEGIN
    IF (SELECT COUNT(*) FROM Watchlist WHERE user_id = NEW.user_id) >= 50 THEN
        DELETE FROM Watchlist
        WHERE user_id = NEW.user_id
        ORDER BY watchlist_id ASC
        LIMIT 1;
    END IF;
END;

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
    SELECT AVG(score) INTO avg_rating FROM Rating WHERE content_id = NEW.content_id;
    IF avg_rating < 2.0 THEN
        UPDATE Content_Availability
        SET available_to = NOW(), available_from = NULL
        WHERE content_id = NEW.content_id;
    END IF;
END;
