USE `PMDB` ;

-- -----------------------------------------------------
-- Test Insertions
-- -----------------------------------------------------

-- Create some test users
INSERT INTO `pm_user` (`email`,`password`,`first_name`,`last_name`) VALUES ('test@email.com','qwerty1','Joe','Blogs');
INSERT INTO `pm_user` (`email`,`Password`,`first_name`,`last_name`) VALUES ('foopy@email.com','qwerty1','Lorem','Ipsum');

-- Create some boards and tags, nested queries are hard to read yikes
INSERT INTO `pm_board` (`author`,`title`,`description`) VALUES ((SELECT `id` FROM `pm_user` WHERE `email` = 'test@email.com'), 'New Board', 'Some Description.');
INSERT INTO `pm_board` (`author`,`title`,`description`) VALUES ((SELECT `id` FROM `pm_user` WHERE `email` = 'foopy@email.com'), 'Foopy Board', 'Full of Foop.');
INSERT INTO `pm_board_tag` (`board`,`name`,`colour`) VALUES ((SELECT `b`.`id` FROM `pm_board` `b` INNER JOIN `pm_user` `u` ON `b`.`author` = `u`.`id` AND `b`.`title` = 'New Board'), 'In Development', 'FF0000');
INSERT INTO `pm_board_tag` (`board`,`name`,`colour`) VALUES ((SELECT `b`.`id` FROM `pm_board` `b` INNER JOIN `pm_user` `u` ON `b`.`author` = `u`.`id` AND `b`.`title` = 'New Board'), 'Pending', '00FF00');

-- Add some members to the first board, obviously test@email should be the owner of his own board
INSERT INTO `pm_board_member` (`board`,`member`,`access`) VALUES (
  (SELECT `b`.`id` FROM `pm_board` `b` 
     INNER JOIN `pm_user` `u` ON `b`.`author` = `u`.`id` AND `b`.`title` = 'New Board'),
  (SELECT `id` FROM `pm_user` WHERE `email` = 'test@email.com'),
  'Owner'
);

INSERT INTO `pm_board_member` (`board`,`member`,`access`) VALUES (
  (SELECT `b`.`id` FROM `pm_board` `b` 
     INNER JOIN `pm_user` `u` ON `b`.`author` = `u`.`id` AND `b`.`title` = 'New Board'),
  (SELECT `id` FROM `pm_user` WHERE `email` = 'foopy@email.com'),
  'Write'
);

-- This is disgusting lmao, but making a new list and assigning it a location (from left to right on the board)
INSERT INTO `pm_list` (`board`,`Location`,`title`) VALUES (
  (SELECT `b`.`id` FROM `pm_board` `b` 
	INNER JOIN `pm_user` `u` ON `b`.`author` = `u`.`id` AND `b`.`title` = 'New Board'),
  (SELECT (COUNT(*) + 1) FROM `pm_list` `l` 
	WHERE `l`.`board` = (
		SELECT `b`.`id` FROM `pm_board` `b` 
        INNER JOIN `pm_user` `u` ON `b`.`author` = `u`.`id` AND `b`.`title` = 'New Board')),
  'This is a List'
);

-- Let's have foopy make a card on test's board
INSERT INTO `pm_card` (`board`,`List`,`author`,`title`,`Description`) VALUES (
  (SELECT `b`.`id` FROM `pm_board` `b` 
     INNER JOIN `pm_user` `u` ON `b`.`author` = `u`.`id` AND `b`.`title` = 'New Board'),
  1,
  (SELECT `id` 
     FROM `pm_user` 
     WHERE `email` = 'foopy@email.com'),
  'Some Card',
  'This card is fancy!'
);

-- Let's attach a tag to this new card, by this point we should probably have the board, card and tag id's cached in memory, 
INSERT INTO `pm_card_tag` (`board`,`card`,`tag`) VALUES (1, 1, 1);
INSERT INTO `pm_card_tag` (`board`,`card`,`tag`) VALUES (1, 1, 2);

-- -----------------------------------------------------
-- Test Selections, just for fun!
-- -----------------------------------------------------

SELECT * FROM `pm_user`;
SELECT * FROM `pm_board`;
SELECT * FROM `pm_list`;
SELECT * FROM `pm_board_tag`;
SELECT * FROM `pm_card`;

-- Show all the Board Members
SELECT CONCAT(`b`.`id`,'@',`b`.`title`) AS `board`, `u`.`email` AS `member`, `bm`.`Access` 
  FROM `pm_board_member` `bm`
  INNER JOIN `pm_board` `b` ON `bm`.`board` = `b`.`id`
  INNER JOIN `pm_user` `u` ON `bm`.`Member` = `u`.`id`;

-- Show all the cards
SELECT CONCAT(`b`.`id`,'@',`b`.`title`) AS `board`, `l`.`title` AS `list`, `u`.`email` AS `author`, `c`.`title`, `c`.`Description`, `c`.`DateModified` 
  FROM `pm_card` `c`
  INNER JOIN `pm_user` `u` ON `c`.`author` = `u`.`id`
  INNER JOIN `pm_board` `b` ON `c`.`board` = `b`.`id`
  INNER JOIN `pm_list` `l` ON `c`.`board` = `l`.`board` AND `c`.`List` = `l`.`ListID`;

-- Show all the card tags
SELECT CONCAT(`b`.`id`,'@',`b`.`title`) AS `board`, `c`.`title` AS `card`, `bt`.`Name` AS `tag`, `bt`.`Colour`
  FROM `pm_card_tag` `ct`
  INNER JOIN `pm_card` `c` ON `ct`.`Card` = `c`.`id`
  INNER JOIN `pm_board` `b` ON `ct`.`board` = `b`.`id`
  INNER JOIN `pm_board_tag` `bt` ON `ct`.`Tag` = `bt`.`id`;

