-- Events.sql
-- Contains all scheduled events for MultimediaContentDB

-- 1. Scheduled Event: Expire Subscriptions Daily
DROP EVENT IF EXISTS expire_subscriptions;
DELIMITER $$
CREATE EVENT expire_subscriptions
ON SCHEDULE EVERY 1 DAY
DO
    UPDATE User_Subscription
    SET end_date = NOW()
    WHERE end_date < NOW() AND end_date IS NOT NULL;

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
    CALL refresh_popular_content_rankings();


DROP EVENT IF EXISTS notify_expired_subscriptions;
DELIMITER $$
CREATE EVENT notify_expired_subscriptions
ON SCHEDULE EVERY 1 DAY
DO
    INSERT INTO Error_Log (error_message)
    SELECT CONCAT('Subscription expired for user ', user_id)
    FROM User_Subscription
    WHERE end_date < NOW();
