USE `PMDB` ;

-- -----------------------------------------------------
-- Test Insertions
-- -----------------------------------------------------

-- Create some test users
INSERT INTO `Users` (`Email`,`Password`,`Firstname`,`Lastname`) VALUES ('test@email.com','qwerty1','Joe','Blogs');
INSERT INTO `Users` (`Email`,`Password`,`Firstname`,`Lastname`) VALUES ('foopy@email.com','qwerty1','Lorem','Ipsum');

-- Create some boards and tags, nested queries are hard to read yikes
INSERT INTO `Boards` (`Author`,`Title`,`Description`) VALUES ((SELECT `UserID` FROM `Users` WHERE `Email` = 'test@email.com'), 'New Board', 'Some Description.');
INSERT INTO `Boards` (`Author`,`Title`,`Description`) VALUES ((SELECT `UserID` FROM `Users` WHERE `Email` = 'foopy@email.com'), 'Foopy Board', 'Full of Foop.');
INSERT INTO `BoardTags` (`Board`,`Name`,`Colour`) VALUES ((SELECT `b`.`BoardID` FROM `Boards` `b` INNER JOIN `Users` `u` ON `b`.`Author` = `u`.`UserID` AND `b`.`Title` = 'New Board'), 'In Development', 'FF0000');
INSERT INTO `BoardTags` (`Board`,`Name`,`Colour`) VALUES ((SELECT `b`.`BoardID` FROM `Boards` `b` INNER JOIN `Users` `u` ON `b`.`Author` = `u`.`UserID` AND `b`.`Title` = 'New Board'), 'Pending', '00FF00');

-- Add some members to the first board, obviously test@email should be the owner of his own board
INSERT INTO `BoardMembers` (`Board`,`Member`,`Access`) VALUES (
  (SELECT `b`.`BoardID` FROM `Boards` `b` 
     INNER JOIN `Users` `u` ON `b`.`Author` = `u`.`UserID` AND `b`.`Title` = 'New Board'),
  (SELECT `UserID` FROM `Users` WHERE `Email` = 'test@email.com'),
  'Owner'
);

INSERT INTO `BoardMembers` (`Board`,`Member`,`Access`) VALUES (
  (SELECT `b`.`BoardID` FROM `Boards` `b` 
     INNER JOIN `Users` `u` ON `b`.`Author` = `u`.`UserID` AND `b`.`Title` = 'New Board'),
  (SELECT `UserID` FROM `Users` WHERE `Email` = 'foopy@email.com'),
  'Write'
);

-- This is disgusting lmao, but making a new list and assigning it a location (from left to right on the board)
INSERT INTO `Lists` (`Board`,`Location`,`Title`) VALUES (
  (SELECT `b`.`BoardID` FROM `Boards` `b` 
	INNER JOIN `Users` `u` ON `b`.`Author` = `u`.`UserID` AND `b`.`Title` = 'New Board'),
  (SELECT (COUNT(*) + 1) FROM `Lists` `l` 
	WHERE `l`.`Board` = (
		SELECT `b`.`BoardID` FROM `Boards` `b` 
        INNER JOIN `Users` `u` ON `b`.`Author` = `u`.`UserID` AND `b`.`Title` = 'New Board')),
  'This is a List'
);

-- Let's have foopy make a card on test's board
INSERT INTO `Cards` (`Board`,`List`,`Author`,`Title`,`Description`) VALUES (
  (SELECT `b`.`BoardID` FROM `Boards` `b` 
     INNER JOIN `Users` `u` ON `b`.`Author` = `u`.`UserID` AND `b`.`Title` = 'New Board'),
  1,
  (SELECT `UserID` 
     FROM `Users` 
     WHERE `Email` = 'foopy@email.com'),
  'Some Card',
  'This card is fancy!'
);

-- Let's attach a tag to this new card, by this point we should probably have the board, card and tag id's cached in memory, 
INSERT INTO `CardTags` (`Board`,`Card`,`Tag`) VALUES (1, 1, 1);
INSERT INTO `CardTags` (`Board`,`Card`,`Tag`) VALUES (1, 1, 2);

-- -----------------------------------------------------
-- Test Selections, just for fun!
-- -----------------------------------------------------

SELECT * FROM `Users`;
SELECT * FROM `Boards`;
SELECT * FROM `Lists`;
SELECT * FROM `BoardTags`;
SELECT * FROM `Cards`;

-- Show all the Board Members
SELECT CONCAT(`b`.`BoardID`,'@',`b`.`Title`) AS `Board`, `u`.`Email` AS `Member`, `bm`.`Access` 
  FROM `BoardMembers` `bm`
  INNER JOIN `Boards` `b` ON `bm`.`Board` = `b`.`BoardID`
  INNER JOIN `Users` `u` ON `bm`.`Member` = `u`.`UserID`;

-- Show all the cards
SELECT CONCAT(`b`.`BoardID`,'@',`b`.`Title`) AS `Board`, `l`.`Title` AS `List`, `u`.`Email` AS `Author`, `c`.`Title`, `c`.`Description`, `c`.`DateModified` 
  FROM `Cards` `c`
  INNER JOIN `Users` `u` ON `c`.`Author` = `u`.`UserID`
  INNER JOIN `Boards` `b` ON `c`.`Board` = `b`.`BoardID`
  INNER JOIN `Lists` `l` ON `c`.`Board` = `l`.`Board` AND `c`.`List` = `l`.`ListID`;

-- Show all the card tags
SELECT CONCAT(`b`.`BoardID`,'@',`b`.`Title`) AS `Board`, `c`.`Title` AS `Card`, `bt`.`Name` AS `Tag`, `bt`.`Colour`
  FROM `CardTags` `ct`
  INNER JOIN `Cards` `c` ON `ct`.`Card` = `c`.`CardID`
  INNER JOIN `Boards` `b` ON `ct`.`Board` = `b`.`BoardID`
  INNER JOIN `BoardTags` `bt` ON `ct`.`Tag` = `bt`.`BTagID`;

