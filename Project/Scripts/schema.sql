SET FOREIGN_KEY_CHECKS = 0;

-- Database Initialization
CREATE DATABASE IF NOT EXISTS MultimediaContentDB;
USE MultimediaContentDB;

-- Error Logging Table (must exist before any triggers/procedures/events that use it)
DROP TABLE IF EXISTS Error_Log;
CREATE TABLE Error_Log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    error_message VARCHAR(512) NOT NULL,
    log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Users & Roles
DROP TABLE IF EXISTS User;
CREATE TABLE User (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255),
    email VARCHAR(255) UNIQUE NOT NULL
);

DROP TABLE IF EXISTS Actor;
CREATE TABLE Actor (
    actor_id INT PRIMARY KEY,
    FOREIGN KEY (actor_id) REFERENCES User(user_id)
);

DROP TABLE IF EXISTS Director;
CREATE TABLE Director (
    director_id INT PRIMARY KEY,
    FOREIGN KEY (director_id) REFERENCES User(user_id)
);

-- Content
DROP TABLE IF EXISTS Content;
CREATE TABLE Content (
    content_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255),
    description TEXT,
    release_year INT
);

-- Genre & Tags
DROP TABLE IF EXISTS Genre;
CREATE TABLE Genre (
    genre_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100)
);

DROP TABLE IF EXISTS Tag;
CREATE TABLE Tag (
    tag_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Ratings & Reviews
DROP TABLE IF EXISTS Rating;
CREATE TABLE Rating (
    rating_id INT PRIMARY KEY AUTO_INCREMENT,
    score DECIMAL(2,1),
    content_id INT,
    FOREIGN KEY (content_id) REFERENCES Content(content_id)
);

DROP TABLE IF EXISTS Review;
CREATE TABLE Review (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    content_id INT,
    review_text TEXT,
    review_date DATE,
    FOREIGN KEY (user_id) REFERENCES User(user_id),
    FOREIGN KEY (content_id) REFERENCES Content(content_id)
);

-- Subscription and Transactions
DROP TABLE IF EXISTS Subscription_Plan;
CREATE TABLE Subscription_Plan (
    plan_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(6,2) NOT NULL
);

DROP TABLE IF EXISTS User_Subscription;
CREATE TABLE User_Subscription (
    user_subscription_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    plan_id INT,
    start_date DATE NOT NULL,
    end_date DATE,
    FOREIGN KEY (user_id) REFERENCES User(user_id),
    FOREIGN KEY (plan_id) REFERENCES Subscription_Plan(plan_id)
);

DROP TABLE IF EXISTS Payment_Method;
CREATE TABLE Payment_Method (
    payment_method_id INT PRIMARY KEY AUTO_INCREMENT,
    method VARCHAR(100) NOT NULL
);

DROP TABLE IF EXISTS Transaction;
CREATE TABLE Transaction (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    payment_method_id INT,
    amount DECIMAL(8,2) NOT NULL,
    transaction_date DATETIME NOT NULL,
    FOREIGN KEY (user_id) REFERENCES User(user_id),
    FOREIGN KEY (payment_method_id) REFERENCES Payment_Method(payment_method_id)
);

-- Lists & Watch History (ISA: ContentList)
DROP TABLE IF EXISTS Watchlist;
CREATE TABLE Watchlist (
    watchlist_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    content_id INT,
    FOREIGN KEY (user_id) REFERENCES User(user_id),
    FOREIGN KEY (content_id) REFERENCES Content(content_id)
);

DROP TABLE IF EXISTS Playlist;
CREATE TABLE Playlist (
    playlist_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    name VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES User(user_id)
);

DROP TABLE IF EXISTS Playlist_Content;
CREATE TABLE Playlist_Content (
    playlist_id INT,
    content_id INT,
    PRIMARY KEY (playlist_id, content_id),
    FOREIGN KEY (playlist_id) REFERENCES Playlist(playlist_id),
    FOREIGN KEY (content_id) REFERENCES Content(content_id)
);

DROP TABLE IF EXISTS Content_WatchHistory;
CREATE TABLE Content_WatchHistory (
    history_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    content_id INT,
    watch_date DATETIME,
    FOREIGN KEY (user_id) REFERENCES User(user_id),
    FOREIGN KEY (content_id) REFERENCES Content(content_id)
);

-- Content Relationships
DROP TABLE IF EXISTS Content_Actor;
CREATE TABLE Content_Actor (
    content_id INT,
    actor_id INT,
    PRIMARY KEY (content_id, actor_id),
    FOREIGN KEY (content_id) REFERENCES Content(content_id),
    FOREIGN KEY (actor_id) REFERENCES Actor(actor_id)
);

DROP TABLE IF EXISTS Content_Director;
CREATE TABLE Content_Director (
    content_id INT,
    director_id INT,
    PRIMARY KEY (content_id, director_id),
    FOREIGN KEY (content_id) REFERENCES Content(content_id),
    FOREIGN KEY (director_id) REFERENCES Director(director_id)
);

DROP TABLE IF EXISTS Content_Genre;
CREATE TABLE Content_Genre (
    content_id INT,
    genre_id INT,
    PRIMARY KEY (content_id, genre_id),
    FOREIGN KEY (content_id) REFERENCES Content(content_id),
    FOREIGN KEY (genre_id) REFERENCES Genre(genre_id)
);

DROP TABLE IF EXISTS Content_Tag;
CREATE TABLE Content_Tag (
    content_id INT,
    tag_id INT,
    PRIMARY KEY (content_id, tag_id),
    FOREIGN KEY (content_id) REFERENCES Content(content_id),
    FOREIGN KEY (tag_id) REFERENCES Tag(tag_id)
);

-- Countries & Permissions
DROP TABLE IF EXISTS Country;
CREATE TABLE Country (
    country_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100)
);

DROP TABLE IF EXISTS Content_Release;
CREATE TABLE Content_Release (
    release_id INT PRIMARY KEY AUTO_INCREMENT,
    content_id INT,
    country_id INT,
    release_date DATE,
    FOREIGN KEY (content_id) REFERENCES Content(content_id),
    FOREIGN KEY (country_id) REFERENCES Country(country_id)
);

DROP TABLE IF EXISTS Content_Availability;
CREATE TABLE Content_Availability (
    availability_id INT PRIMARY KEY AUTO_INCREMENT,
    content_id INT,
    country_id INT,
    available_from DATE,
    available_to DATE,
    FOREIGN KEY (content_id) REFERENCES Content(content_id),
    FOREIGN KEY (country_id) REFERENCES Country(country_id)
);

DROP TABLE IF EXISTS Content_Accessibility;
CREATE TABLE Content_Accessibility (
    accessibility_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

DROP TABLE IF EXISTS Content_Accessibility_Map;
CREATE TABLE Content_Accessibility_Map (
    content_id INT,
    accessibility_id INT,
    PRIMARY KEY (content_id, accessibility_id),
    FOREIGN KEY (content_id) REFERENCES Content(content_id),
    FOREIGN KEY (accessibility_id) REFERENCES Content_Accessibility(accessibility_id)
);

-- Subscription Unlocks Content
DROP TABLE IF EXISTS Content_Access_Map;
CREATE TABLE Content_Access_Map (
    plan_id INT,
    content_id INT,
    PRIMARY KEY (plan_id, content_id),
    FOREIGN KEY (plan_id) REFERENCES Subscription_Plan(plan_id),
    FOREIGN KEY (content_id) REFERENCES Content(content_id)
);


-- Tag
DROP TABLE IF EXISTS Tag;
CREATE TABLE Tag (
    tag_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Content Accessibility
DROP TABLE IF EXISTS Content_Accessibility;
CREATE TABLE Content_Accessibility (
    accessibility_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Subscription Plan
DROP TABLE IF EXISTS Subscription_Plan;
CREATE TABLE Subscription_Plan (
    plan_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(6,2) NOT NULL
);

-- Payment Method
DROP TABLE IF EXISTS Payment_Method;
CREATE TABLE Payment_Method (
    payment_method_id INT PRIMARY KEY AUTO_INCREMENT,
    method VARCHAR(100) NOT NULL
);

-- Transaction
DROP TABLE IF EXISTS Transaction;
CREATE TABLE Transaction (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    payment_method_id INT,
    amount DECIMAL(8,2) NOT NULL,
    transaction_date DATETIME NOT NULL,
    FOREIGN KEY (user_id) REFERENCES User(user_id),
    FOREIGN KEY (payment_method_id) REFERENCES Payment_Method(payment_method_id)
);

-- User Subscription
DROP TABLE IF EXISTS User_Subscription;
CREATE TABLE User_Subscription (
    user_subscription_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    plan_id INT,
    start_date DATE NOT NULL,
    end_date DATE,
    FOREIGN KEY (user_id) REFERENCES User(user_id),
    FOREIGN KEY (plan_id) REFERENCES Subscription_Plan(plan_id)
);

-- Review
DROP TABLE IF EXISTS Review;
CREATE TABLE Review (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    content_id INT,
    review_text TEXT,
    review_date DATE,
    FOREIGN KEY (user_id) REFERENCES User(user_id),
    FOREIGN KEY (content_id) REFERENCES Content(content_id)
);

-- Playlist
DROP TABLE IF EXISTS Playlist;
CREATE TABLE Playlist (
    playlist_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    name VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES User(user_id)
);

-- Watchlist
DROP TABLE IF EXISTS Watchlist;
CREATE TABLE Watchlist (
    watchlist_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    content_id INT,
    FOREIGN KEY (user_id) REFERENCES User(user_id),
    FOREIGN KEY (content_id) REFERENCES Content(content_id)
);

-- Content Watch History
DROP TABLE IF EXISTS Content_WatchHistory;
CREATE TABLE Content_WatchHistory (
    history_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    content_id INT,
    watch_date DATETIME,
    FOREIGN KEY (user_id) REFERENCES User(user_id),
    FOREIGN KEY (content_id) REFERENCES Content(content_id)
);

-- Content Release
DROP TABLE IF EXISTS Content_Release;
CREATE TABLE Content_Release (
    release_id INT PRIMARY KEY AUTO_INCREMENT,
    content_id INT,
    country_id INT,
    release_date DATE,
    FOREIGN KEY (content_id) REFERENCES Content(content_id),
    FOREIGN KEY (country_id) REFERENCES Country(country_id)
);

-- Content Availability
DROP TABLE IF EXISTS Content_Availability;
CREATE TABLE Content_Availability (
    availability_id INT PRIMARY KEY AUTO_INCREMENT,
    content_id INT,
    country_id INT,
    available_from DATE,
    available_to DATE,
    FOREIGN KEY (content_id) REFERENCES Content(content_id),
    FOREIGN KEY (country_id) REFERENCES Country(country_id)
);

-- Many-to-Many Junction Tables
DROP TABLE IF EXISTS Content_Director;
CREATE TABLE Content_Director (
    content_id INT,
    director_id INT,
    PRIMARY KEY (content_id, director_id),
    FOREIGN KEY (content_id) REFERENCES Content(content_id),
    FOREIGN KEY (director_id) REFERENCES Director(director_id)
);

DROP TABLE IF EXISTS Content_Actor;
CREATE TABLE Content_Actor (
    content_id INT,
    actor_id INT,
    PRIMARY KEY (content_id, actor_id),
    FOREIGN KEY (content_id) REFERENCES Content(content_id),
    FOREIGN KEY (actor_id) REFERENCES Actor(actor_id)
);

DROP TABLE IF EXISTS Content_Genre;
CREATE TABLE Content_Genre (
    content_id INT,
    genre_id INT,
    PRIMARY KEY (content_id, genre_id),
    FOREIGN KEY (content_id) REFERENCES Content(content_id),
    FOREIGN KEY (genre_id) REFERENCES Genre(genre_id)
);

DROP TABLE IF EXISTS Error_Log;
DROP TABLE IF EXISTS Content_Country;
CREATE TABLE Content_Country (
    content_id INT,
    country_id INT,
    PRIMARY KEY (content_id, country_id),
    FOREIGN KEY (content_id) REFERENCES Content(content_id),
    FOREIGN KEY (country_id) REFERENCES Country(country_id)
);

DROP TABLE IF EXISTS Error_Log;
DROP TABLE IF EXISTS Content_Format_Map;
CREATE TABLE Content_Format_Map (
    content_id INT,
    format_id INT,
    PRIMARY KEY (content_id, format_id),
    FOREIGN KEY (content_id) REFERENCES Content(content_id),
    FOREIGN KEY (format_id) REFERENCES Content_Format(format_id)
);

SET FOREIGN_KEY_CHECKS = 1;

DROP TABLE IF EXISTS Playlist_Content;
CREATE TABLE Playlist_Content (
    playlist_id INT,
    content_id INT,
    PRIMARY KEY (playlist_id, content_id),
    FOREIGN KEY (playlist_id) REFERENCES Playlist(playlist_id),
    FOREIGN KEY (content_id) REFERENCES Content(content_id)
);

DROP TABLE IF EXISTS Content_Tag;
CREATE TABLE Content_Tag (
    content_id INT,
    tag_id INT,
    PRIMARY KEY (content_id, tag_id),
    FOREIGN KEY (content_id) REFERENCES Content(content_id),
    FOREIGN KEY (tag_id) REFERENCES Tag(tag_id)
);

DROP TABLE IF EXISTS Content_Accessibility_Map;
CREATE TABLE Content_Accessibility_Map (
    content_id INT,
    accessibility_id INT,
    PRIMARY KEY (content_id, accessibility_id),
    FOREIGN KEY (content_id) REFERENCES Content(content_id),
    FOREIGN KEY (accessibility_id) REFERENCES Content_Accessibility(accessibility_id)
);
