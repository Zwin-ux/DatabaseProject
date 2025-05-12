-- Functions.sql
-- Contains all functions for MultimediaContentDB

-- 1. Function: Rank Genres by Popularity
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

-- 2. Function: Validate Active Subscription
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
