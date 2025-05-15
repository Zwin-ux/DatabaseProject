-- Functions.sql
-- Author: Mazen Zwin
-- 90%+ implemented by Mazen Zwin | Database Analyst/Developer
-- Contains advanced SQL functions for MultimediaContentDB
-- Features: analytics, performance optimization, collaborator discovery

-- 1. Function: Rank Top 3 Genres by Watch Hours (last month)
DROP FUNCTION IF EXISTS get_top_genres_by_watch_hours;
DELIMITER $$
CREATE FUNCTION get_top_genres_by_watch_hours()
RETURNS TEXT
DETERMINISTIC
BEGIN
    DECLARE result TEXT DEFAULT '';
    
    -- Optimized query using indexed columns and explicit duration calculation
    -- This will perform better with larger datasets by leveraging the index on watch_date
    SELECT GROUP_CONCAT(g.name ORDER BY total_hours DESC SEPARATOR ', ') INTO result
    FROM (
        -- Use a subquery with proper time calculation
        SELECT 
            cg.genre_id, 
            SUM(TIMESTAMPDIFF(HOUR, w.watch_date, 
                IFNULL(w.end_time, w.watch_date + INTERVAL 2 HOUR))) AS total_hours
        FROM 
            Content_WatchHistory w
            -- Use indexed join
            JOIN Content_Genre cg ON w.content_id = cg.content_id
        -- Use indexed filter on watch_date
        WHERE 
            w.watch_date >= DATE_SUB(NOW(), INTERVAL 1 MONTH)
        GROUP BY 
            cg.genre_id
        ORDER BY 
            total_hours DESC
        LIMIT 3
    ) t
    JOIN Genre g ON t.genre_id = g.genre_id;
    
    RETURN result;
END$$
DELIMITER ;$$
DELIMITER ;

-- 2. Function: Find Most Frequent Collaborators (Actor-Director pairs)
DROP FUNCTION IF EXISTS get_most_frequent_collaborators;
DELIMITER $$
CREATE FUNCTION get_most_frequent_collaborators()
RETURNS TEXT
DETERMINISTIC
BEGIN
    DECLARE result TEXT DEFAULT '';
    SELECT GROUP_CONCAT(CONCAT(a.actor_id, '-', d.director_id) ORDER BY cnt DESC SEPARATOR ', ') INTO result
    FROM (
        SELECT ca.actor_id, cd.director_id, COUNT(*) AS cnt
        FROM Content_Actor ca
        JOIN Content_Director cd ON ca.content_id = cd.content_id
        GROUP BY ca.actor_id, cd.director_id
        ORDER BY cnt DESC
        LIMIT 1
    ) t
    JOIN Actor a ON t.actor_id = a.actor_id
    JOIN Director d ON t.director_id = d.director_id;
    RETURN result;
END$$
DELIMITER ;

-- 3. Function: Validate Subscription Status (active/expired)
DROP FUNCTION IF EXISTS get_subscription_status;
DELIMITER $$
CREATE FUNCTION get_subscription_status(uid INT)
RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN
    DECLARE is_active INT DEFAULT 0;
    SELECT COUNT(*) INTO is_active
    FROM User_Subscription us
    JOIN Transaction t ON us.user_id = t.user_id
    WHERE us.user_id = uid AND us.end_date > NOW() AND t.amount > 0;
    IF is_active > 0 THEN
        RETURN 'active';
    ELSE
        RETURN 'expired';
    END IF;
END$$
DELIMITER ;

-- 4. Function: Rank Genres by Popularity
DROP FUNCTION IF EXISTS get_genre_rank;
DELIMITER $$
CREATE FUNCTION get_genre_rank(gid INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE `rank` INT;
    SELECT COUNT(*) INTO `rank` FROM Content_Genre WHERE genre_id = gid;
    RETURN `rank`;
END$$
DELIMITER ;

-- 5. Function: Validate Active Subscription
DROP FUNCTION IF EXISTS is_subscription_active;
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
