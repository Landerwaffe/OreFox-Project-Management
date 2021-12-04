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
	Cards:		    Stores each individual "trello card" which exists on some board
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

DROP TABLE IF EXISTS `Users` ;
DROP TABLE IF EXISTS `UserRoles` ;
DROP TABLE IF EXISTS `Boards` ;
DROP TABLE IF EXISTS `BoardMembers` ;
DROP TABLE IF EXISTS `Cards` ;
DROP TABLE IF EXISTS `CardContent` ;
DROP TABLE IF EXISTS `BoardTags` ;
DROP TABLE IF EXISTS `CardTags` ;
DROP TABLE IF EXISTS `Reactions` ;

-- -----------------------------------------------------
-- Table `Users`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Users` (
    `ID` INT NOT NULL AUTO_INCREMENT,
    `Email` VARCHAR(255) NOT NULL,
    `Password` VARCHAR(255) NOT NULL,
    `FirstName` VARCHAR(255) NOT NULL,
    `LastName` VARCHAR(255) NOT NULL,
    `DateCreated` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `DateModified` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`ID`),
    UNIQUE INDEX `uq_Email` (`Email`)
)  ENGINE=INNODB;


-- -----------------------------------------------------
-- Table `UserRoles`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `UserRoles` (
    `ID` INT NOT NULL AUTO_INCREMENT,
    `User` INT NOT NULL,
    `Role` ENUM('User', 'Project Manager') NOT NULL,
    PRIMARY KEY (`ID`),
    UNIQUE INDEX `uq_User` (`User` ASC, `Role` ASC),
    FOREIGN KEY (`User`) REFERENCES `Users` (`ID`)
)  ENGINE=INNODB;


-- -----------------------------------------------------
-- Table `Boards`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Boards` (
    `ID` INT NOT NULL AUTO_INCREMENT,
    `Author` INT NOT NULL,
    `Title` VARCHAR(45) NOT NULL,
    `Description` VARCHAR(45),
    `DateCreated` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `DateModified` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`ID`),
    UNIQUE INDEX `uq_Board` (`Author` ASC, `Title` ASC),
    FOREIGN KEY (`Author`) REFERENCES `Users` (`ID`)
)  ENGINE=INNODB;


-- -----------------------------------------------------
-- Table `BoardMembers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `BoardMembers` (
    `ID` INT NOT NULL AUTO_INCREMENT,
    `Board` INT NOT NULL,
    `Member` INT NOT NULL,
    `Access` ENUM('Owner', 'Admin', 'Read', 'Write') NOT NULL DEFAULT 'Read',
    PRIMARY KEY (`ID`),
    UNIQUE INDEX `uq_Members` (`Board` ASC, `Member` ASC),
    FOREIGN KEY (`Board`) REFERENCES `Boards` (`ID`),
    FOREIGN KEY (`Member`) REFERENCES `Users` (`ID`)
)  ENGINE=INNODB;

-- -----------------------------------------------------
-- Table `Lists`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Lists` (
	`ID` INT NOT NULL AUTO_INCREMENT,
    `Board` INT NOT NULL,
    `Title` VARCHAR(45) NOT NULL,
	`Location` INT NOT NULL UNIQUE DEFAULT 0,
    PRIMARY KEY (`ID`),
    INDEX `idx_Board` (`Board` ASC),
    FOREIGN KEY (`Board`) REFERENCES `Boards` (`ID`)    
) ENGINE=INNODB;


-- -----------------------------------------------------
-- Table `Cards`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Cards` (
    `ID` INT NOT NULL AUTO_INCREMENT,
    `Board` INT NOT NULL,
    `List` INT NOT NULL,
    `Location` INT NOT NULL UNIQUE DEFAULT 0,
    `Author` INT NOT NULL,
    `Title` VARCHAR(45) NOT NULL,
    `Description` VARCHAR(45),
    `DateCreated` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `DateModified` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`ID`),
    INDEX `idx_Board` (`Board` ASC),
    INDEX `idx_List` (`List` ASC),
    INDEX `idx_Author` (`Author` ASC),
    FOREIGN KEY (`Board`) REFERENCES `Boards` (`ID`),
    FOREIGN KEY (`List`) REFERENCES `Lists` (`ID`),
    FOREIGN KEY (`Author`) REFERENCES `Users` (`ID`)
)  ENGINE=INNODB;


-- -----------------------------------------------------
-- Table `CardContent`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `CardContent` (
    `ID` INT NOT NULL AUTO_INCREMENT,
    `Card` INT NOT NULL,
    `Author` INT NOT NULL,
    `Type` ENUM('Comment', 'List') NOT NULL,
    `Contents` VARCHAR(2048) NULL,
    `DateCreated` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `DateModified` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`ID`),
    INDEX `idx_Card` (`Card` ASC),
    INDEX `idx_Author` (`Author` ASC),
    FOREIGN KEY (`Card`) REFERENCES `Cards` (`ID`),
    FOREIGN KEY (`Author`) REFERENCES `Users` (`ID`)
)  ENGINE=INNODB;


-- -----------------------------------------------------
-- Table `BoardTags`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `BoardTags` (
    `ID` INT NOT NULL AUTO_INCREMENT,
    `Board` INT NOT NULL,
    `Name` VARCHAR(45) NOT NULL,
    `Colour` CHAR(6) NOT NULL,
    PRIMARY KEY (`ID`),
    INDEX `idx_Board` (`Board` ASC),
    UNIQUE INDEX `uq_Board` (`Board` ASC, `Name` ASC),
    FOREIGN KEY (`Board`) REFERENCES `Boards` (`ID`)
)  ENGINE=INNODB;


-- -----------------------------------------------------
-- Table `CardTags`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `CardTags` (
    `ID` INT NOT NULL AUTO_INCREMENT,
    `Board` INT NOT NULL,
    `Card` INT NOT NULL,
    `Tag` INT NOT NULL,
    PRIMARY KEY (`ID`),
    INDEX `idx_Board` (`Board` ASC),
    INDEX `idx_Card` (`Card` ASC),
    UNIQUE INDEX `uq_Cards` (`Board` ASC, `Card` ASC, `Tag` ASC),
    FOREIGN KEY (`Board`) REFERENCES `Boards` (`ID`),
    FOREIGN KEY (`Card`) REFERENCES `Cards` (`ID`)
)  ENGINE=INNODB;

-- -----------------------------------------------------
-- Table `Reactions`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Reactions` (
	`ID` int NOT NULL AUTO_INCREMENT,
	`Card` int NOT NULL,
	`Author` int NOT NULL,
	`Reaction` ENUM('Like','Dislike','Check Mark','Cross') NOT NULL,
	`DateCreated` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`ID`),
    INDEX `idx_Card` (`Card` ASC),
    INDEX `idx_Author` (`Author` ASC),
	UNIQUE INDEX `uq_Reaction` (`Card` ASC, `Author` ASC, `Reaction` ASC),
	FOREIGN KEY(`Card`) REFERENCES `Cards` (`ID`),
	FOREIGN KEY(`Author`) REFERENCES `Users` (`ID`)
) ENGINE=INNODB;