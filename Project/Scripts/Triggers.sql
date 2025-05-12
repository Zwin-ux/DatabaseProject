-- Triggers.sql
-- Contains all triggers for MultimediaContentDB

-- 1. Trigger: Enforce Watchlist Size Limit (max 50 items per user)
-- If user has 50, remove oldest, then insert
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
-- Block duplicate director assignments, log errors
CREATE TRIGGER trg_unique_director
BEFORE INSERT ON Content_Director
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 FROM Content_Director
        WHERE content_id = NEW.content_id AND director_id = NEW.director_id
    ) THEN
        INSERT INTO Error_Log (error_message) VALUES ('Duplicate director assignment');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Duplicate director for content';
    END IF;
END;

-- 3. Trigger: Log Negative Transaction Amounts
CREATE TRIGGER trg_log_transaction_error
AFTER INSERT ON Transaction
FOR EACH ROW
BEGIN
    IF NEW.amount < 0 THEN
        INSERT INTO Error_Log (error_message) VALUES ('Negative transaction amount');
    END IF;
END;
