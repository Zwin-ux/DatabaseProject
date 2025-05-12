-- Procedures.sql

-- Procedure: Log ETL Metrics for the PDF
DROP PROCEDURE IF EXISTS log_etl_metric;
DELIMITER $$
CREATE PROCEDURE log_etl_metric(
    IN job_name VARCHAR(255),
    IN start_time DATETIME,
    IN end_time DATETIME,
    IN rows_processed INT,
    IN status VARCHAR(50),
    IN error_message VARCHAR(1024)
)
BEGIN
    INSERT INTO etl_metrics (job_name, start_time, end_time, rows_processed, status, error_message)
    VALUES (job_name, start_time, end_time, rows_processed, status, error_message);
END$$
DELIMITER ;

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
DROP PROCEDURE IF EXISTS generate_monthly_user_activity_report;
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
DROP PROCEDURE IF EXISTS update_content_availability_by_criteria;
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
DROP PROCEDURE IF EXISTS handle_failed_payment;
DELIMITER $$
CREATE PROCEDURE handle_failed_payment(uid INT, pmid INT, errmsg VARCHAR(255))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Rollback if there's any error
        ROLLBACK;
        -- Log the error
        INSERT INTO Error_Log (error_message) 
        VALUES (CONCAT('Failed to handle payment error for user ', uid, ': ', errmsg));
    END;
    
    -- Start transaction to ensure all operations succeed or fail together
    START TRANSACTION;
    
    -- Log the payment error
    INSERT INTO Payment_Errors (user_id, payment_method_id, error_message) 
    VALUES (uid, pmid, errmsg);
    
    -- Update subscription status
    UPDATE User_Subscription 
    SET end_date = NOW() 
    WHERE user_id = uid AND end_date > NOW();
    
    -- Simulate notification (in real system, would send email/notification)
    INSERT INTO Error_Log (error_message) 
    VALUES (CONCAT('Payment failed notification for user ', uid));
    
    -- If all operations succeed, commit the transaction
    COMMIT;
END$$
DELIMITER ;$$
DELIMITER ;

-- 4. Procedure: Refresh Popular Content Rankings (top 10 per genre)
CREATE TABLE IF NOT EXISTS Popular_Content (
    genre_id INT,
    content_id INT,
    view_count INT,
    `rank` INT,
    PRIMARY KEY (genre_id, `rank`)
);
DROP PROCEDURE IF EXISTS refresh_popular_content_rankings;
DELIMITER $$
CREATE PROCEDURE refresh_popular_content_rankings()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Rollback if there's any error
        ROLLBACK;
        -- Log the error
        INSERT INTO Error_Log (error_message) 
        VALUES ('Failed to refresh popular content rankings');
    END;
    
    -- Start transaction
    START TRANSACTION;
    
    -- Use temporary table for better performance with large datasets
    DROP TEMPORARY TABLE IF EXISTS temp_view_counts;
    
    -- Create temp table with indexes for faster joins
    CREATE TEMPORARY TABLE temp_view_counts (
        content_id INT,
        view_count INT,
        PRIMARY KEY (content_id)
    ) AS (
        SELECT 
            content_id, 
            COUNT(*) AS view_count
        FROM 
            Content_WatchHistory
        WHERE 
            watch_date >= DATE_SUB(NOW(), INTERVAL 1 DAY)
        GROUP BY 
            content_id
    );
    
    -- Clear existing rankings
    DELETE FROM Popular_Content;
    
    -- Insert new rankings using the temp table
    INSERT INTO Popular_Content (genre_id, content_id, view_count, `rank`)
    SELECT 
        cg.genre_id, 
        cg.content_id, 
        IFNULL(vc.view_count, 0) AS view_count, 
        rnk AS `rank`
    FROM (
        SELECT 
            cg.genre_id, 
            cg.content_id,
            ROW_NUMBER() OVER (
                PARTITION BY cg.genre_id 
                ORDER BY IFNULL(vc.view_count, 0) DESC
            ) AS rnk
        FROM 
            Content_Genre cg
            LEFT JOIN temp_view_counts vc ON cg.content_id = vc.content_id
    ) ranked
    JOIN Content_Genre cg ON ranked.content_id = cg.content_id AND ranked.genre_id = cg.genre_id
    LEFT JOIN temp_view_counts vc ON cg.content_id = vc.content_id
    WHERE ranked.rnk <= 10;
    
    -- Log the refresh operation
    INSERT INTO Error_Log (error_message) 
    VALUES (CONCAT('Popular content rankings refreshed successfully at ', NOW()));
    
    -- Drop the temporary table
    DROP TEMPORARY TABLE IF EXISTS temp_view_counts;
    
    -- Commit transaction
    COMMIT;
END$$
DELIMITER ;$$
DELIMITER ;

-- 5. Procedure: Generate Content Usage Report
DROP PROCEDURE IF EXISTS generate_content_report;
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
DROP PROCEDURE IF EXISTS handle_failed_payment;
DELIMITER $$
CREATE PROCEDURE handle_failed_payment(uid INT)
BEGIN
    UPDATE User_Subscription
    SET end_date = NOW()
    WHERE user_id = uid AND end_date > NOW();
END$$
DELIMITER ;
