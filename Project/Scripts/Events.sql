-- Events.sql
-- Contains all scheduled events for MultimediaContentDB

-- 1. Scheduled Event: Expire Subscriptions Daily
CREATE EVENT IF NOT EXISTS expire_subscriptions
ON SCHEDULE EVERY 1 DAY
DO
    UPDATE User_Subscription
    SET end_date = NOW()
    WHERE end_date < NOW() AND end_date IS NOT NULL;

-- 2. Event: Expire Content Availability
CREATE EVENT IF NOT EXISTS expire_content_availability
ON SCHEDULE EVERY 1 DAY
DO
    UPDATE Content_Availability
    SET available_to = NOW()
    WHERE available_to < NOW() AND available_to IS NOT NULL;


CREATE EVENT IF NOT EXISTS refresh_popular_content_rankings_event
ON SCHEDULE EVERY 1 DAY
DO
    CALL refresh_popular_content_rankings();


CREATE EVENT IF NOT EXISTS notify_expired_subscriptions
ON SCHEDULE EVERY 1 DAY
DO
    INSERT INTO Error_Log (error_message)
    SELECT CONCAT('Subscription expired for user ', user_id)
    FROM User_Subscription
    WHERE end_date < NOW();
