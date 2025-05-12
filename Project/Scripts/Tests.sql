-- Tests.sql
-- Test cases for triggers, functions, and procedures in MultimediaContentDB

-- Test 1: Watchlist Trigger (max 50)
-- Add 51 items for a user, check that only 50 remain and the oldest is removed

-- Test 2: Director Uniqueness Trigger
-- Tries to assign the same director twice to the same content, expect error and error log

-- Test 3: Negative Transaction Amount Trigger
-- Inserts a transaction with negative amount, expect error log entry

-- Add more tests as needed for your business logic pzl

INSERT INTO Watchlist (user_id, content_id) VALUES (1, 1001);
SELECT COUNT(*) FROM Watchlist WHERE user_id = 1; -- Should be 50
INSERT INTO Content_Director (content_id, director_id) VALUES (2001, 3001);
INSERT INTO Content_Director (content_id, director_id) VALUES (2001, 3001); -- Should fail and log error
INSERT INTO Transaction (user_id, amount) VALUES (1, -10.00);
SELECT * FROM Error_Log WHERE error_message LIKE '%Negative transaction amount%';
