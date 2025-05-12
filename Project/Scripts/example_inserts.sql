
INSERT INTO User (name, email) VALUES ('Alice Smith', 'alice.smith@example.com');
INSERT INTO User (name, email) VALUES ('Bob Jones', 'bob.jones@example.com');
INSERT INTO User (name, email) VALUES ('Carol Lee', 'carol.lee@example.com');

INSERT INTO Actor (actor_id) SELECT user_id FROM User WHERE name = 'Bob Jones';
INSERT INTO Director (director_id) SELECT user_id FROM User WHERE name = 'Carol Lee';

INSERT INTO Content (title, description, release_year) VALUES ('Sample Movie', 'A test movie.', 2024);
INSERT INTO Content (title, description, release_year) VALUES ('Another Show', 'Second test show.', 2023);

INSERT INTO Genre (name) VALUES ('Comedy');
INSERT INTO Genre (name) VALUES ('Drama');
INSERT INTO Country (name) VALUES ('USA');
INSERT INTO Country (name) VALUES ('Canada');

INSERT INTO Content_Genre (content_id, genre_id) VALUES (1, 1);
INSERT INTO Content_Genre (content_id, genre_id) VALUES (2, 2);
INSERT INTO Content_Director (content_id, director_id) VALUES (1, 3);
INSERT INTO Content_Actor (content_id, actor_id) VALUES (1, 2);
INSERT INTO Content_Country (content_id, country_id) VALUES (1, 1);
INSERT INTO Content_Country (content_id, country_id) VALUES (2, 2);

INSERT INTO Playlist (user_id, name) VALUES (1, 'Alice Playlist');
INSERT INTO Playlist_Content (playlist_id, content_id) VALUES (1, 1);
INSERT INTO Playlist_Content (playlist_id, content_id) VALUES (1, 2);

INSERT INTO Watchlist (user_id, content_id) VALUES (1, 2);
INSERT INTO Content_WatchHistory (user_id, content_id, watch_date) VALUES (1, 1, '2025-04-10 20:00:00');

INSERT INTO Review (user_id, content_id, review_text, review_date) VALUES (1, 1, 'Solid movie.', '2025-04-16');
INSERT INTO Review (user_id, content_id, review_text, review_date) VALUES (2, 2, 'Not bad.', '2025-04-17');

INSERT INTO Subscription_Plan (name, price) VALUES ('Premium', 9.99);
INSERT INTO User_Subscription (user_id, plan_id, start_date, end_date) VALUES (1, 1, '2025-04-01', '2026-04-01');

INSERT INTO Payment_Method (method) VALUES ('Credit Card');
INSERT INTO Transaction (user_id, payment_method_id, amount, transaction_date) VALUES (1, 1, 9.99, '2025-04-01 10:00:00');

-- Edge case: Try inserting duplicate email (should fail)
INSERT INTO User (name, email) VALUES ('Duplicate', 'alice.smith@example.com');

-- Edge case: Try inserting watch history for non-existent user (should fail)
INSERT INTO Content_WatchHistory (user_id, content_id, watch_date) VALUES (999, 1, '2025-04-16 12:00:00');

-- Edge case: Try linking a content to a non-existent genre (should fail)
INSERT INTO Content_Genre (content_id, genre_id) VALUES (1, 999);
