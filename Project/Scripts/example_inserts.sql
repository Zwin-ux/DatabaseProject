
INSERT IGNORE INTO User (name, email) VALUES ('Alice Smith', 'alice.smith@example.com');
-- Ensure user_id 1 exists for Watchlist tests
INSERT IGNORE INTO User (user_id, name, email) VALUES (1, 'Test User', 'testuser@example.com');
INSERT IGNORE INTO User (name, email) VALUES ('Bob Jones', 'bob.jones@example.com');
INSERT IGNORE INTO User (name, email) VALUES ('Carol Lee', 'carol.lee@example.com');

INSERT IGNORE INTO Actor (actor_id) SELECT user_id FROM User WHERE name = 'Bob Jones';
INSERT IGNORE INTO Director (director_id) SELECT user_id FROM User WHERE name = 'Carol Lee';

INSERT IGNORE INTO Content (title, description, release_year) VALUES ('Sample Movie', 'A test movie.', 2024);
-- Ensure content_id 1 exists for Content_Genre tests
INSERT IGNORE INTO Content (content_id, title, description, release_year) VALUES (1, 'Content 1', 'Content for Content_Genre', 2024);
-- Ensure content_id 1001 exists for Watchlist tests
INSERT IGNORE INTO Content (content_id, title, description, release_year) VALUES (1001, 'Test Content', 'Test Content for Watchlist', 2024);
INSERT IGNORE INTO Content (title, description, release_year) VALUES ('Another Show', 'Second test show.', 2023);
-- Ensure content_id 2 exists for Content_Genre tests
INSERT IGNORE INTO Content (content_id, title, description, release_year) VALUES (2, 'Content 2', 'Test Content for Content_Genre', 2023);

INSERT IGNORE INTO Genre (name) VALUES ('Comedy');
-- Ensure genre_id 1 exists for Content_Genre tests
INSERT IGNORE INTO Genre (genre_id, name) VALUES (1, 'Genre 1');
INSERT IGNORE INTO Genre (name) VALUES ('Drama');
INSERT IGNORE INTO Country (name) VALUES ('USA');
INSERT IGNORE INTO Country (name) VALUES ('Canada');

INSERT IGNORE INTO Content_Genre (content_id, genre_id) VALUES (1, 1);
INSERT IGNORE INTO Content_Genre (content_id, genre_id) VALUES (2, 2);
INSERT IGNORE INTO Content_Director (content_id, director_id) VALUES (1, 3);
INSERT IGNORE INTO Content_Actor (content_id, actor_id) VALUES (1, 2);
INSERT IGNORE INTO Content_Country (content_id, country_id) VALUES (1, 1);
INSERT IGNORE INTO Content_Country (content_id, country_id) VALUES (2, 2);

INSERT IGNORE INTO Playlist (user_id, name) VALUES (1, 'Alice Playlist');
INSERT IGNORE INTO Playlist_Content (playlist_id, content_id) VALUES (1, 1);
INSERT IGNORE INTO Playlist_Content (playlist_id, content_id) VALUES (1, 2);

INSERT IGNORE INTO Watchlist (user_id, content_id) VALUES (1, 2);
INSERT IGNORE INTO Content_WatchHistory (user_id, content_id, watch_date) VALUES (1, 1, '2025-04-10 20:00:00');

INSERT IGNORE INTO Review (user_id, content_id, review_text, review_date) VALUES (1, 1, 'Solid movie.', '2025-04-16');
INSERT IGNORE INTO Review (user_id, content_id, review_text, review_date) VALUES (2, 2, 'Not bad.', '2025-04-17');

INSERT IGNORE INTO Subscription_Plan (name, price) VALUES ('Premium', 9.99);
INSERT IGNORE INTO User_Subscription (user_id, plan_id, start_date, end_date) VALUES (1, 1, '2025-04-01', '2026-04-01');

INSERT IGNORE INTO Payment_Method (method) VALUES ('Credit Card');
INSERT IGNORE INTO Transaction (user_id, payment_method_id, amount, transaction_date) VALUES (1, 1, 9.99, '2025-04-01 10:00:00');

-- Edge case examples (with INSERT IGNORE to prevent errors)
-- Note: These would normally fail due to constraints

-- Edge case: Duplicate email - would normally fail with "Duplicate entry for key 'user.email'"
INSERT IGNORE INTO User (name, email) VALUES ('Duplicate', 'alice.smith@example.com');

-- Edge case: Non-existent user - would normally fail with foreign key constraint
INSERT IGNORE INTO Content_WatchHistory (user_id, content_id, watch_date) VALUES (999, 1, '2025-04-16 12:00:00');

-- Edge case: Non-existent genre - would normally fail with foreign key constraint
INSERT IGNORE INTO Content_Genre (content_id, genre_id) VALUES (1, 999);
