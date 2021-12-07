/* 
Project Management Database Creator
=========================================================

This will create the PMDB locally for you, you'll need to host a MySQL server on your own network if you want to use it (probably),
unless someone else wants to host one for us to all use. Feel free to remove the 'DROP SCHEMA/TABLE' stuff locally if you want, i just left it there
for debug purposes.

Tables:
	Users:		    Table for storing user accounts (this is for testing purposes only, OreFox will have their own on their servers)
	UserRoles:	    Not really sure what this is for, they mentioned it in the meeting on the 1st December
	Boards:		    Stores each individual "trello board"
	BoardMembers:   Stores the members of each board
    Lists: 			The lists in which cards are stored
	Cards:		    Stores each individual "trello card" which exists on some board in some list
	CardContent:    Stores the content for each card, its setup this way incase each card can have more than one item in it
	BoardTags:	    These are the tags that a board has currently, useful so each board doesn't have to have the same tags
	CardTags:	    The tags on each card are stored here, its setup so that a card can only have one of each tag
	Reactions:	    Simple like/dislike for cards

The Database Schema diagram/spreadsheet are on the onedrive if you want a little bit of an easier visual representation of the stuff below.

Author: Thomas Fabian
*/

-- -----------------------------------------------------
-- Schema PMDB
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `PMDB` ;

-- -----------------------------------------------------
-- Schema PMDB
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `PMDB` DEFAULT CHARACTER SET utf8 ;
USE `PMDB` ;

DROP TABLE IF EXISTS `pm_user` ;
DROP TABLE IF EXISTS `pm_user_role` ;
DROP TABLE IF EXISTS `pm_board` ;
DROP TABLE IF EXISTS `pm_board_member` ;
DROP TABLE IF EXISTS `pm_list` ;
DROP TABLE IF EXISTS `pm_card` ;
DROP TABLE IF EXISTS `pm_card_content` ;
DROP TABLE IF EXISTS `pm_board_tag` ;
DROP TABLE IF EXISTS `pm_card_tag` ;
DROP TABLE IF EXISTS `pm_reaction` ;

-- -----------------------------------------------------
-- Table `pm_user`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `pm_user` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `email` VARCHAR(255) NOT NULL,
    `password` VARCHAR(255) NOT NULL,
    `first_name` VARCHAR(255) NOT NULL,
    `last_name` VARCHAR(255) NOT NULL,
    `date_created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `date_modified` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE INDEX `uq_email` (`email`)
)  ENGINE=INNODB;


-- -----------------------------------------------------
-- Table `pm_user_role`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `pm_user_role` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `user` INT NOT NULL,
    `role` ENUM('User', 'Project Manager') NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE INDEX `uq_User` (`user` ASC, `role` ASC),
    FOREIGN KEY (`user`) REFERENCES `pm_user` (`id`)
)  ENGINE=INNODB;


-- -----------------------------------------------------
-- Table `pm_board`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `pm_board` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `author` INT NOT NULL,
    `title` VARCHAR(45) NOT NULL,
    `description` VARCHAR(45),
    `date_created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `date_modified` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE INDEX `uq_board` (`author` ASC, `title` ASC),
    FOREIGN KEY (`author`) REFERENCES `pm_user` (`id`)
)  ENGINE=INNODB;


-- -----------------------------------------------------
-- Table `pm_board_member`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `pm_board_member` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `board` INT NOT NULL,
    `member` INT NOT NULL,
    `access` ENUM('Owner', 'Admin', 'Read', 'Write') NOT NULL DEFAULT 'Read',
    PRIMARY KEY (`id`),
    UNIQUE INDEX `uq_member` (`board` ASC, `member` ASC),
    FOREIGN KEY (`board`) REFERENCES `pm_board` (`id`),
    FOREIGN KEY (`member`) REFERENCES `pm_user` (`id`)
)  ENGINE=INNODB;


-- -----------------------------------------------------
-- Table `pm_list`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `pm_list` (
	`id` INT NOT NULL AUTO_INCREMENT,
    `board` INT NOT NULL,
    `title` VARCHAR(45) NOT NULL,
	`location` INT NOT NULL UNIQUE DEFAULT 0,
    PRIMARY KEY (`id`),
    INDEX `idx_Board` (`board` ASC),
    FOREIGN KEY (`board`) REFERENCES `pm_board` (`id`)    
)  ENGINE=INNODB;


-- -----------------------------------------------------
-- Table `pm_card`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `pm_card` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `board` INT NOT NULL,
    `list` INT NOT NULL,
    `location` INT NOT NULL UNIQUE DEFAULT 0,
    `author` INT NOT NULL,
    `title` VARCHAR(45) NOT NULL,
    `description` VARCHAR(45),
    `date_created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `date_modified` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_Board` (`board` ASC),
    INDEX `idx_List` (`list` ASC),
    INDEX `idx_Author` (`author` ASC),
    FOREIGN KEY (`board`) REFERENCES `pm_board` (`id`),
    FOREIGN KEY (`list`) REFERENCES `pm_list` (`id`),
    FOREIGN KEY (`author`) REFERENCES `pm_user` (`id`)
)  ENGINE=INNODB;


-- -----------------------------------------------------
-- Table `pm_card_content`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `pm_card_content` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `card` INT NOT NULL,
    `author` INT NOT NULL,
    `type` ENUM('Comment', 'List') NOT NULL,
    `contents` VARCHAR(2048) NULL,
    `date_created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `date_modified` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_card` (`card` ASC),
    INDEX `idx_author` (`author` ASC),
    FOREIGN KEY (`card`) REFERENCES `pm_card` (`id`),
    FOREIGN KEY (`author`) REFERENCES `pm_user` (`id`)
)  ENGINE=INNODB;


-- -----------------------------------------------------
-- Table `pm_board_tag`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `pm_board_tag` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `board` INT NOT NULL,
    `name` VARCHAR(45) NOT NULL,
    `colour` CHAR(6) NOT NULL,
    PRIMARY KEY (`id`),
    INDEX `idx_board` (`board` ASC),
    UNIQUE INDEX `uq_board` (`board` ASC, `name` ASC),
    FOREIGN KEY (`board`) REFERENCES `pm_board` (`id`)
)  ENGINE=INNODB;


-- -----------------------------------------------------
-- Table `pm_card_tag`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `pm_card_tag` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `board` INT NOT NULL,
    `card` INT NOT NULL,
    `tag` INT NOT NULL,
    PRIMARY KEY (`id`),
    INDEX `idx_board` (`board` ASC),
    INDEX `idx_card` (`card` ASC),
    UNIQUE INDEX `uq_cards` (`board` ASC, `card` ASC, `tag` ASC),
    FOREIGN KEY (`board`) REFERENCES `pm_board` (`id`),
    FOREIGN KEY (`card`) REFERENCES `pm_card` (`id`)
)  ENGINE=INNODB;


-- -----------------------------------------------------
-- Table `Reactions`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `pm_reaction` (
	`id` int NOT NULL AUTO_INCREMENT,
	`card` int NOT NULL,
	`author` int NOT NULL,
	`reaction` ENUM('Like','Dislike','Check Mark','Cross') NOT NULL,
	`date_created` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_card` (`card` ASC),
    INDEX `idx_author` (`author` ASC),
	UNIQUE INDEX `uq_reaction` (`card` ASC, `author` ASC, `reaction` ASC),
	FOREIGN KEY(`card`) REFERENCES `pm_card` (`id`),
	FOREIGN KEY(`author`) REFERENCES `pm_user` (`id`)
)  ENGINE=INNODB;