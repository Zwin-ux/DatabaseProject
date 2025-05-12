-- Procedures.sql
-- Contains all procedures for MultimediaContentDB

-- Auxiliary Table for Payment Errors
CREATE TABLE IF NOT EXISTS Payment_Errors (
    error_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    payment_method_id INT,
    error_message VARCHAR(255),
    error_time DATETIME DEFAULT NOW()
);

-- 1. Procedure: Generate Monthly User Activity Report
DELIMITER $$
CREATE PROCEDURE generate_monthly_user_activity_report(uid INT)
BEGIN
    SELECT u.user_id, u.name,
        COUNT(DISTINCT w.content_id) AS content_watched,
        AVG(r.score) AS avg_rating,
        SUM(TIMESTAMPDIFF(HOUR, w.watch_date, w.watch_date)) AS hours_spent
    FROM User u
    LEFT JOIN Content_WatchHistory w ON u.user_id = w.user_id AND w.watch_date >= DATE_SUB(NOW(), INTERVAL 1 MONTH)
    LEFT JOIN Rating r ON w.content_id = r.content_id
    WHERE u.user_id = uid
    GROUP BY u.user_id;
END$$
DELIMITER ;

-- 2. Procedure: Process Batch Content Updates (by criteria)
DELIMITER $$
CREATE PROCEDURE update_content_availability_by_criteria(min_release_year INT, min_views INT)
BEGIN
    UPDATE Content_Availability ca
    JOIN Content c ON ca.content_id = c.content_id
    LEFT JOIN (
        SELECT content_id, COUNT(*) AS view_count
        FROM Content_WatchHistory
        GROUP BY content_id
    ) vw ON c.content_id = vw.content_id
    SET ca.available_to = NOW()
    WHERE c.release_year < min_release_year OR vw.view_count < min_views;
END$$
DELIMITER ;

-- 3. Procedure: Handle Failed Payments
DELIMITER $$
CREATE PROCEDURE handle_failed_payment(uid INT, pmid INT, errmsg VARCHAR(255))
BEGIN
    INSERT INTO Payment_Errors (user_id, payment_method_id, error_message) VALUES (uid, pmid, errmsg);
    -- Simulate notification (in real system, would send email/notification)
    UPDATE User_Subscription SET end_date = NOW() WHERE user_id = uid AND end_date > NOW();
END$$
DELIMITER ;

-- 4. Procedure: Refresh Popular Content Rankings (top 10 per genre)
CREATE TABLE IF NOT EXISTS Popular_Content (
    genre_id INT,
    content_id INT,
    view_count INT,
    rank INT,
    PRIMARY KEY (genre_id, rank)
);
DELIMITER $$
CREATE PROCEDURE refresh_popular_content_rankings()
BEGIN
    DELETE FROM Popular_Content;
    INSERT INTO Popular_Content (genre_id, content_id, view_count, rank)
    SELECT cg.genre_id, cg.content_id, IFNULL(vw.view_count, 0) AS view_count, rnk
    FROM (
        SELECT cg.genre_id, cg.content_id,
            ROW_NUMBER() OVER (PARTITION BY cg.genre_id ORDER BY IFNULL(vw.view_count, 0) DESC) AS rnk
        FROM Content_Genre cg
        LEFT JOIN (
            SELECT content_id, COUNT(*) AS view_count
            FROM Content_WatchHistory
            WHERE watch_date >= DATE_SUB(NOW(), INTERVAL 1 DAY)
            GROUP BY content_id
        ) vw ON cg.content_id = vw.content_id
    ) ranked
    JOIN Content_Genre cg ON ranked.content_id = cg.content_id AND ranked.genre_id = cg.genre_id
    LEFT JOIN (
        SELECT content_id, COUNT(*) AS view_count
        FROM Content_WatchHistory
        WHERE watch_date >= DATE_SUB(NOW(), INTERVAL 1 DAY)
        GROUP BY content_id
    ) vw ON cg.content_id = vw.content_id
    WHERE ranked.rnk <= 10;
END$$
DELIMITER ;

-- 5. Procedure: Generate Content Usage Report
DELIMITER $$
CREATE PROCEDURE generate_content_report()
BEGIN
    SELECT c.title, COUNT(w.history_id) AS views
    FROM Content c
    LEFT JOIN Content_WatchHistory w ON c.content_id = w.content_id
    GROUP BY c.content_id;
END$$
DELIMITER ;

-- 6. Procedure: Handle Failed Payment
DELIMITER $$
CREATE PROCEDURE handle_failed_payment(uid INT)
BEGIN
    UPDATE User_Subscription
    SET end_date = NOW()
    WHERE user_id = uid AND end_date > NOW();
END$$
DELIMITER ;
