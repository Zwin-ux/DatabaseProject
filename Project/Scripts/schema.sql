-- MultimediaContentDB Schema
-- This schema defines all tables, keys, and relationships for the project on the doc (wanted to throw so i can refrence it)

CREATE DATABASE IF NOT EXISTS MultimediaContentDB;
USE MultimediaContentDB;

-- User and Subtypes
CREATE TABLE User (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL
    -- Add more attributes as needed
);

CREATE TABLE Actor (
    actor_id INT PRIMARY KEY,
    FOREIGN KEY (actor_id) REFERENCES User(user_id)
);

CREATE TABLE Director (
    director_id INT PRIMARY KEY,
    FOREIGN KEY (director_id) REFERENCES User(user_id)
);

-- Content (Show)
CREATE TABLE Content (
    content_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    release_year INT
    -- Add more attributes as needed
);

-- Genre
CREATE TABLE Genre (
    genre_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Country
CREATE TABLE Country (
    country_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Rating
CREATE TABLE Rating (
    rating_id INT PRIMARY KEY AUTO_INCREMENT,
    score DECIMAL(2,1) NOT NULL,
    content_id INT,
    FOREIGN KEY (content_id) REFERENCES Content(content_id)
);

-- Content Format
CREATE TABLE Content_Format (
    format_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Tag
CREATE TABLE Tag (
    tag_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Content Accessibility
CREATE TABLE Content_Accessibility (
    accessibility_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Subscription Plan
CREATE TABLE Subscription_Plan (
    plan_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(6,2) NOT NULL
);

-- Payment Method
CREATE TABLE Payment_Method (
    payment_method_id INT PRIMARY KEY AUTO_INCREMENT,
    method VARCHAR(100) NOT NULL
);

-- Transaction
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
CREATE TABLE Playlist (
    playlist_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    name VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES User(user_id)
);

-- Watchlist
CREATE TABLE Watchlist (
    watchlist_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    content_id INT,
    FOREIGN KEY (user_id) REFERENCES User(user_id),
    FOREIGN KEY (content_id) REFERENCES Content(content_id)
);

-- Content Watch History
CREATE TABLE Content_WatchHistory (
    history_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    content_id INT,
    watch_date DATETIME,
    FOREIGN KEY (user_id) REFERENCES User(user_id),
    FOREIGN KEY (content_id) REFERENCES Content(content_id)
);

-- Content Release
CREATE TABLE Content_Release (
    release_id INT PRIMARY KEY AUTO_INCREMENT,
    content_id INT,
    country_id INT,
    release_date DATE,
    FOREIGN KEY (content_id) REFERENCES Content(content_id),
    FOREIGN KEY (country_id) REFERENCES Country(country_id)
);

-- Content Availability
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
CREATE TABLE Content_Director (
    content_id INT,
    director_id INT,
    PRIMARY KEY (content_id, director_id),
    FOREIGN KEY (content_id) REFERENCES Content(content_id),
    FOREIGN KEY (director_id) REFERENCES Director(director_id)
);

CREATE TABLE Content_Actor (
    content_id INT,
    actor_id INT,
    PRIMARY KEY (content_id, actor_id),
    FOREIGN KEY (content_id) REFERENCES Content(content_id),
    FOREIGN KEY (actor_id) REFERENCES Actor(actor_id)
);

CREATE TABLE Content_Genre (
    content_id INT,
    genre_id INT,
    PRIMARY KEY (content_id, genre_id),
    FOREIGN KEY (content_id) REFERENCES Content(content_id),
    FOREIGN KEY (genre_id) REFERENCES Genre(genre_id)
);

CREATE TABLE Content_Country (
    content_id INT,
    country_id INT,
    PRIMARY KEY (content_id, country_id),
    FOREIGN KEY (content_id) REFERENCES Content(content_id),
    FOREIGN KEY (country_id) REFERENCES Country(country_id)
);

CREATE TABLE Content_Format_Map (
    content_id INT,
    format_id INT,
    PRIMARY KEY (content_id, format_id),
    FOREIGN KEY (content_id) REFERENCES Content(content_id),
    FOREIGN KEY (format_id) REFERENCES Content_Format(format_id)
);

CREATE TABLE Playlist_Content (
    playlist_id INT,
    content_id INT,
    PRIMARY KEY (playlist_id, content_id),
    FOREIGN KEY (playlist_id) REFERENCES Playlist(playlist_id),
    FOREIGN KEY (content_id) REFERENCES Content(content_id)
);

CREATE TABLE Content_Tag (
    content_id INT,
    tag_id INT,
    PRIMARY KEY (content_id, tag_id),
    FOREIGN KEY (content_id) REFERENCES Content(content_id),
    FOREIGN KEY (tag_id) REFERENCES Tag(tag_id)
);

CREATE TABLE Content_Accessibility_Map (
    content_id INT,
    accessibility_id INT,
    PRIMARY KEY (content_id, accessibility_id),
    FOREIGN KEY (content_id) REFERENCES Content(content_id),
    FOREIGN KEY (accessibility_id) REFERENCES Content_Accessibility(accessibility_id)
);
