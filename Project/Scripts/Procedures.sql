-- Procedures.sql
-- Contains all procedures for MultimediaContentDB

-- 1. Procedure: Generate Content Usage Report
DELIMITER $$
CREATE PROCEDURE generate_content_report()
BEGIN
    SELECT c.title, COUNT(w.history_id) AS views
    FROM Content c
    LEFT JOIN Content_WatchHistory w ON c.content_id = w.content_id
    GROUP BY c.content_id;
END$$
DELIMITER ;

-- 2. Procedure: Handle Failed Payment
DELIMITER $$
CREATE PROCEDURE handle_failed_payment(uid INT)
BEGIN
    UPDATE User_Subscription
    SET end_date = NOW()
    WHERE user_id = uid AND end_date > NOW();
END$$
DELIMITER ;
