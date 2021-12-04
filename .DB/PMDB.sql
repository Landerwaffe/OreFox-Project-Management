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

-- -----------------------------------------------------
-- Table `Users`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Users` (
    `ID` INT NOT NULL AUTO_INCREMENT,
    `Email` VARCHAR(255) NOT NULL UNIQUE,
    `Password` VARCHAR(255) NOT NULL,
    `FirstName` VARCHAR(255) NOT NULL,
    `LastName` VARCHAR(255) NOT NULL,
    `DateCreated` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `DateModified` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`ID`)
)  ENGINE=INNODB;


-- -----------------------------------------------------
-- Table `UserRoles`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `UserRoles` (
    `ID` INT NOT NULL AUTO_INCREMENT,
    `User` INT NOT NULL,
    `Role` ENUM('User', 'Project Manager') NOT NULL,
    PRIMARY KEY (`ID`),
    CONSTRAINT `UR_User` UNIQUE (`User` , `Role`),
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
    CONSTRAINT `Board` UNIQUE (`Author` , `Title`),
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
    CONSTRAINT `Members` UNIQUE (`Board` , `Member`),
    FOREIGN KEY (`Board`) REFERENCES `Boards` (`ID`),
    FOREIGN KEY (`Member`) REFERENCES `Users` (`ID`)
)  ENGINE=INNODB;


-- -----------------------------------------------------
-- Table `Cards`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Cards` (
    `ID` INT NOT NULL AUTO_INCREMENT,
    `Board` INT NOT NULL,
    `Author` INT NOT NULL,
    `Title` VARCHAR(45) NOT NULL,
    `Description` VARCHAR(45),
    `DateCreated` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `DateModified` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`ID`),
    FOREIGN KEY (`Board`) REFERENCES `Boards` (`ID`),
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
    CONSTRAINT `Board` UNIQUE (`Board` , `Name`),
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
    CONSTRAINT `Cards` UNIQUE (`Board` , `Card` , `Tag`),
    FOREIGN KEY (`Board`) REFERENCES `Boards` (`ID`),
    FOREIGN KEY (`Card`) REFERENCES `Cards` (`ID`)
)  ENGINE=INNODB;