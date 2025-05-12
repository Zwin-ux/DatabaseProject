-- Events.sql
-- Contains all scheduled events for MultimediaContentDB

-- 1. Scheduled Event: Expire Subscriptions Daily
CREATE EVENT IF NOT EXISTS expire_subscriptions
ON SCHEDULE EVERY 1 DAY
DO
    UPDATE User_Subscription
    SET end_date = NOW()
    WHERE end_date < NOW() AND end_date IS NOT NULL;
