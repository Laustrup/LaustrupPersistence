-- ------------------------------------------------------
-- Will set the tables with the default values assigned.
-- Deletes former tables.
-- Is used for testing repository, but copied from Bandwich project.
-- ------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS bandwich_db;
USE bandwich_db;

-- ------------------------------------------------------
-- Deleting tables, if they exists.
-- ------------------------------------------------------

DROP TABLE IF EXISTS contact_informations;
DROP TABLE IF EXISTS subscriptions;
DROP TABLE IF EXISTS tags;
DROP TABLE IF EXISTS album_items;
DROP TABLE IF EXISTS albums;
DROP TABLE IF EXISTS ratings;
DROP TABLE IF EXISTS requests;
DROP TABLE IF EXISTS bulletins;
DROP TABLE IF EXISTS mails;
DROP TABLE IF EXISTS chatters;
DROP TABLE IF EXISTS chat_rooms;
DROP TABLE IF EXISTS followings;
DROP TABLE IF EXISTS participations;
DROP TABLE IF EXISTS acts;
DROP TABLE IF EXISTS gigs;
DROP TABLE IF EXISTS `events`;
DROP TABLE IF EXISTS venues;
DROP TABLE IF EXISTS gear;
DROP TABLE IF EXISTS band_members;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS cards;

-- ------------------------------------------------------
-- Creating tables.
-- ------------------------------------------------------
CREATE TABLE cards(
    id BIGINT(20) NOT NULL AUTO_INCREMENT,
    `type` ENUM('VISA',
        'AMERICAN_EXPRESS',
        'DANCARD') NOT NULL,
    `owner` VARCHAR(60) NOT NULL,
    numbers BIGINT(16) NOT NULL,
    expiration_month INT(2) NOT NULL,
    expiration_year INT(2) NOT NULL,
    cvv INT(3) NOT NULL,

    PRIMARY KEY(id)
);

CREATE TABLE users(
    id BIGINT(20) NOT NULL AUTO_INCREMENT,
    username VARCHAR(30) NOT NULL,
    `password` VARCHAR(30) NOT NULL,
    email VARCHAR(30),
    first_name VARCHAR(20),
    last_name VARCHAR(40),
    `description` VARCHAR(500),
    `timestamp` DATETIME NOT NULL,
    kind ENUM('BAND',
        'ARTIST',
        'VENUE',
        'PARTICIPANT') NOT NULL,

    PRIMARY KEY(id)
);

CREATE UNIQUE INDEX username_password ON users(username,`password`);
CREATE UNIQUE INDEX email_password ON users(email,`password`);

-- Previous Unique indexes
-- ALTER TABLE users ADD UNIQUE username_password(username,`password`);
-- ALTER TABLE users ADD UNIQUE email_password(email,`password`);

CREATE TABLE band_members(
    artist_id BIGINT(20) NOT NULL,
    band_id BIGINT(20) NOT NULL,

    PRIMARY KEY(artist_id, band_id),
    FOREIGN KEY(artist_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY(band_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE gear(
    user_id BIGINT(20) NOT NULL AUTO_INCREMENT,
    `description` VARCHAR(500) NOT NULL,

    PRIMARY KEY(user_id),
    FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE venues(
    user_id BIGINT(20) NOT NULL,
    `size` INT(6),
    location VARCHAR(50) NOT NULL,

    PRIMARY KEY(user_id),
    FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE `events`(
    id BIGINT(20) NOT NULL AUTO_INCREMENT,
    title VARCHAR(60) NOT NULL,

    open_doors DATETIME,
    `description` VARCHAR(1000),

    is_voluntary ENUM(
        'FALSE',
        'TRUE',
        'UNDEFINED'
        ),
    is_public ENUM(
        'FALSE',
        'TRUE',
        'UNDEFINED'
        ),
    is_cancelled ENUM(
        'FALSE',
        'TRUE',
        'UNDEFINED'
        ),
    is_sold_out ENUM(
        'FALSE',
        'TRUE',
        'UNDEFINED',
        'ABOVE_HALF'
        ),

    location VARCHAR(50) NOT NULL,
    price DOUBLE,
    tickets_url VARCHAR(100),

    venue_id BIGINT(20) NOT NULL,

    `timestamp` DATETIME NOT NULL,

    PRIMARY KEY(id),
    FOREIGN KEY(venue_id) REFERENCES venues(user_id)
);

CREATE TABLE gigs(
    id BIGINT(20) NOT NULL AUTO_INCREMENT,
    event_id BIGINT(20) NOT NULL,
    `start` DATETIME,
    `end` DATETIME,
    `timestamp` DATETIME,

    PRIMARY KEY(id),
    FOREIGN KEY(event_id) REFERENCES `events`(id) ON DELETE CASCADE
);

CREATE TABLE acts(
    user_id BIGINT(20) NOT NULL,
    gig_id BIGINT(20) NOT NULL,

    PRIMARY KEY(user_id, gig_id),
    FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY(gig_id) REFERENCES gigs(id) ON DELETE CASCADE
);

CREATE TABLE participations(
    event_id BIGINT(20) NOT NULL,
    participant_id BIGINT(20) NOT NULL,
    `type` ENUM('ACCEPTED',
        'IN_DOUBT',
        'CANCEL',
        'INVITED'),

    `timestamp` DATETIME NOT NULL,

    PRIMARY KEY(event_id, participant_id),
    FOREIGN KEY(event_id) REFERENCES `events`(id) ON DELETE CASCADE,
    FOREIGN KEY(participant_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE followings(
    /* FAN */
    fan_id BIGINT(20) NOT NULL,
    fan_kind ENUM('BAND',
        'ARTIST',
        'VENUE',
        'PARTICIPANT') NOT NULL,

    /* IDOL */
    idol_id BIGINT(20) NOT NULL,
    idol_kind ENUM('BAND',
        'ARTIST',
        'VENUE',
        'PARTICIPANT') NOT NULL,

    PRIMARY KEY(fan_id,idol_id),
    FOREIGN KEY(fan_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY(idol_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Must be changed to fit new values that doesn't calculate answering time
CREATE TABLE chat_rooms(
    id BIGINT(20) NOT NULL AUTO_INCREMENT,
    is_local BOOL NOT NULL,
    title VARCHAR(50),
    responsible_id BIGINT(20),
    `timestamp` DATETIME NOT NULL,

    PRIMARY KEY(id),
    FOREIGN KEY(responsible_id) REFERENCES users(id)
);

CREATE TABLE chatters(
    chat_room_id BIGINT(20) NOT NULL,
    user_id BIGINT(20) NOT NULL,

    PRIMARY KEY(chat_room_id, user_id),
    FOREIGN KEY(chat_room_id) REFERENCES chat_rooms(id) ON DELETE CASCADE,
    FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE mails(
    id BIGINT(20) NOT NULL AUTO_INCREMENT,
    author_id BIGINT(20) NOT NULL,
    content VARCHAR(1000),
    is_sent BOOL NOT NULL,
    is_edited ENUM(
        'FALSE',
        'TRUE',
        'UNDEFINED'
        ),
    is_public BOOL NOT NULL,
    chat_room_id BIGINT(20) NOT NULL,
    `timestamp` DATETIME NOT NULL,

    PRIMARY KEY(id),
    FOREIGN KEY(author_id) REFERENCES users(id),
    FOREIGN KEY(chat_room_id) REFERENCES chat_rooms(id) ON DELETE CASCADE
);

CREATE TABLE bulletins(
    id BIGINT(20) NOT NULL AUTO_INCREMENT,
    author_id BIGINT(20) NOT NULL,
    content VARCHAR(1000),
    is_sent BOOL NOT NULL,
    is_edited ENUM(
        'FALSE',
        'TRUE',
        'UNDEFINED'
        ),
    is_public BOOL NOT NULL,
    user_id BIGINT(20),
    event_id BIGINT(20),
    `timestamp` DATETIME NOT NULL,

    PRIMARY KEY(id),
    FOREIGN KEY(author_id) REFERENCES users(id),
    FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY(event_id) REFERENCES `events`(id) ON DELETE CASCADE
);

CREATE TABLE requests(
    user_id BIGINT(20) NOT NULL,
    event_id BIGINT(20) NOT NULL,
    is_approved ENUM(
        'FALSE',
        'TRUE',
        'UNDEFINED'
        ),
    message VARCHAR(250),
    `timestamp` DATETIME NOT NULL,

    PRIMARY KEY(user_id,event_id),
    FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY(event_id) REFERENCES `events`(id) ON DELETE CASCADE
);

CREATE TABLE ratings(
    appointed_id BIGINT(20) NOT NULL,
    judge_id BIGINT(20) NOT NULL,
    `value` INT(1) NOT NULL,
    `comment` VARCHAR(500) NOT NULL,
    `timestamp` DATETIME NOT NULL,

    PRIMARY KEY(appointed_id, judge_id),
    FOREIGN KEY(appointed_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY(judge_id) REFERENCES users(id)
);

CREATE TABLE albums(
    id BIGINT(20) NOT NULL AUTO_INCREMENT,
    title VARCHAR(100),

    author_id BIGINT(20) NOT NULL,
    event_id BIGINT(20),

    `timestamp` DATETIME NOT NULL,

    PRIMARY KEY(id),
    FOREIGN KEY(author_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY(author_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE album_items(
    title VARCHAR(100),
    endpoint VARCHAR(100) NOT NULL,
    kind ENUM('IMAGE', 'MUSIC') NOT NULL,

    album_id BIGINT(20) NOT NULL,
    event_id BIGINT(20),

    `timestamp` DATETIME NOT NULL,

    PRIMARY KEY(endpoint),
    FOREIGN KEY(album_id) REFERENCES albums(id) ON DELETE CASCADE,
    FOREIGN KEY(event_id) REFERENCES `events`(id)
);

CREATE TABLE tags(
    user_id BIGINT(20) NOT NULL,
    item_endpoint VARCHAR(100) NOT NULL,

    PRIMARY KEY(user_id, item_endpoint),
    FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY(item_endpoint) REFERENCES album_items(endpoint) ON DELETE CASCADE
);

CREATE TABLE subscriptions(
    user_id BIGINT(20) NOT NULL,
    `status` ENUM('ACCEPTED',
        'BLOCKED',
        'DISACTIVATED',
        'CLOSED') NOT NULL,
    subscription_type ENUM('FREEMIUM',
        'PREMIUM_BAND',
        'PREMIUM_ARTIST') NOT NULL,
    /* Offer */
    offer_type ENUM('FREE_TRIAL',
        'SALE'),
    offer_expires DATETIME,
    offer_effect DOUBLE,

    card_id BIGINT(20),
    PRIMARY KEY (user_id),
    FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY(card_id) REFERENCES cards(id)
);

CREATE TABLE contact_informations(
    user_id BIGINT(20) NOT NULL,
    /* Phone */
    first_digits INT(3),
    phone_number INT(10),
    phone_is_mobile BOOL,
    /* Address */
    street VARCHAR(50),
    floor VARCHAR(10),
    postal VARCHAR(10),
    city VARCHAR(20),
    /* Country */
    country_title VARCHAR(50),
    country_indexes ENUM('DK',
     'SE',
     'DE'),

    PRIMARY KEY(user_id),
    FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
);