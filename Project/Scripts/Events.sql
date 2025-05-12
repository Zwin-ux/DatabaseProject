-- Events.sql
-- Contains all scheduled events for MultimediaContentDB

-- 1. Scheduled Event: Expire Subscriptions Daily
DROP EVENT IF EXISTS expire_subscriptions;
DELIMITER $$
CREATE EVENT expire_subscriptions
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
    -- Track when this event runs for audit purposes
    INSERT INTO Error_Log (error_message) 
    VALUES (CONCAT('Expire subscriptions event ran at ', NOW()));
    
    -- Expire subscriptions
    UPDATE User_Subscription
    SET end_date = NOW()
    WHERE end_date < NOW() AND end_date IS NOT NULL;
    
    -- Log how many subscriptions were expired
    INSERT INTO Error_Log (error_message) 
    VALUES (CONCAT(
        'Expired ', 
        ROW_COUNT(), 
        ' subscriptions at ', 
        NOW()
    ));
END$$
DELIMITER ;

-- 2. Event: Expire Content Availability
DROP EVENT IF EXISTS expire_content_availability;
DELIMITER $$
CREATE EVENT expire_content_availability
ON SCHEDULE EVERY 1 DAY
DO
    UPDATE Content_Availability
    SET available_to = NOW()
    WHERE available_to < NOW() AND available_to IS NOT NULL;


DROP EVENT IF EXISTS refresh_popular_content_rankings_event;
DELIMITER $$
CREATE EVENT refresh_popular_content_rankings_event
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
    -- Log the start of the event
    INSERT INTO Error_Log (error_message) 
    VALUES (CONCAT('Content rankings refresh started at ', NOW()));
    
    -- Call the procedure to refresh rankings
    CALL refresh_popular_content_rankings();
    
    -- Log the completion
    INSERT INTO Error_Log (error_message) 
    VALUES (CONCAT('Content rankings refresh completed at ', NOW()));
END$$
DELIMITER ;


DROP EVENT IF EXISTS notify_expired_subscriptions;
DELIMITER $$
CREATE EVENT notify_expired_subscriptions
ON SCHEDULE EVERY 1 DAY
DO
    INSERT INTO Error_Log (error_message)
    SELECT CONCAT('Subscription expired for user ', user_id)
    FROM User_Subscription
    WHERE end_date < NOW();
