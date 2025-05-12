-- Tests.sql
-- Test cases for triggers, functions, and procedures in MultimediaContentDB (updated for new ERD)

-- Test 1: Watchlist Trigger (max 50)
-- Add 51 items for a user, check that only 50 remain and the oldest is removed
INSERT INTO Watchlist (user_id, content_id) VALUES (1, 1001);
SELECT COUNT(*) FROM Watchlist WHERE user_id = 1; -- Should be 50

-- Test 2: Director Uniqueness Trigger
-- Create test content and director first to satisfy foreign keys
INSERT IGNORE INTO Content (content_id, title, description, release_year) VALUES (2001, 'Test Content 2001', 'For testing director uniqueness', 2025);
INSERT IGNORE INTO User (user_id, name, email) VALUES (3001, 'Test Director 3001', 'director3001@example.com');
INSERT IGNORE INTO Director (director_id) VALUES (3001);

-- Tries to assign the same director twice to the same content, expect error and error log
INSERT INTO Content_Director (content_id, director_id) VALUES (2001, 3001);
INSERT INTO Content_Director (content_id, director_id) VALUES (2001, 3001); -- Should fail and log error

-- Test 3: Negative Transaction Amount Trigger
-- Inserts a transaction with negative amount, expect error log entry
INSERT INTO Transaction (user_id, payment_method_id, amount, transaction_date) VALUES (1, 1, -10.00, NOW());
SELECT * FROM Error_Log WHERE error_message LIKE '%Negative transaction amount%';

-- Test 4: Content Accessibility Mapping
-- Add and check accessibility mapping
INSERT INTO Content_Accessibility (name) VALUES ('Subtitles');
INSERT INTO Content (title) VALUES ('Test Movie');
INSERT INTO Content_Accessibility_Map (content_id, accessibility_id) VALUES (1, 1);
SELECT * FROM Content_Accessibility_Map WHERE content_id = 1 AND accessibility_id = 1;

-- Test 5: Content Availability
-- Add and check content availability for a country
INSERT INTO Country (name) VALUES ('USA');
INSERT INTO Content_Availability (content_id, country_id, available_from, available_to) VALUES (1, 1, NOW(), DATE_ADD(NOW(), INTERVAL 1 YEAR));
SELECT * FROM Content_Availability WHERE content_id = 1 AND country_id = 1;

-- Test 6: Subscription Unlocks Content

-- Test 7: ETL Metrics Logging
CALL log_etl_metric('test_job', NOW(), NOW(), 123, 'success', NULL);
SELECT * FROM etl_metrics WHERE job_name = 'test_job';

-- Add and check access map
INSERT INTO Subscription_Plan (name, price) VALUES ('Premium', 9.99);
INSERT INTO Content_Access_Map (plan_id, content_id) VALUES (1, 1);
SELECT * FROM Content_Access_Map WHERE plan_id = 1 AND content_id = 1;


