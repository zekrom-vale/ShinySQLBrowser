-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               11.3.2-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win64
-- HeidiSQL Version:             12.6.0.6765
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for CookLog
CREATE DATABASE IF NOT EXISTS `cooklog` /*!40100 DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci */;
USE `CookLog`;

-- Dumping structure for table CookLog.cook
CREATE TABLE IF NOT EXISTS `cook` (
  `ID` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `Date` date NOT NULL DEFAULT curdate(),
  `Time` time NOT NULL DEFAULT curtime(),
  `ItemID` mediumint(8) unsigned NOT NULL,
  `Temp` tinyint(3) unsigned NOT NULL,
  `Person` smallint(5) unsigned NOT NULL,
  `Comment` varchar(75) DEFAULT NULL,
  PRIMARY KEY (`ID`) USING BTREE,
  KEY `FK__items)_i` (`ItemID`) USING BTREE,
  KEY `FK_cook_work.people_i` (`Person`) USING BTREE,
  CONSTRAINT `FK__items` FOREIGN KEY (`ItemID`) REFERENCES `items` (`ID`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `FK_cook_work.people` FOREIGN KEY (`Person`) REFERENCES `work`.`people` (`ID`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=188 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table CookLog.cook: ~90 rows (approximately)
INSERT INTO `cook` (`ID`, `Date`, `Time`, `ItemID`, `Temp`, `Person`, `Comment`) VALUES
	(34, '2024-02-10', '15:07:24', 10, 211, 1, 'haa'),
	(36, '2024-02-10', '15:39:43', 5, 183, 1, NULL),
	(40, '2024-02-10', '18:17:23', 20, 172, 1, NULL),
	(42, '2024-02-10', '18:37:20', 10, 210, 1, NULL),
	(45, '2024-02-13', '14:10:25', 20, 204, 1, '21h'),
	(46, '2024-02-13', '14:10:44', 10, 200, 1, NULL),
	(49, '2024-02-13', '16:11:30', 2, 207, 2, NULL),
	(50, '2024-02-14', '13:38:26', 20, 213, 1, NULL),
	(53, '2024-02-14', '16:42:40', 10, 196, 2, NULL),
	(54, '2024-02-14', '16:51:15', 10, 207, 2, NULL),
	(57, '2024-02-15', '09:17:44', 10, 205, 1, NULL),
	(58, '2024-02-15', '09:25:05', 20, 215, 1, NULL),
	(59, '2024-02-15', '09:33:19', 13, 200, 1, NULL),
	(60, '2024-02-15', '09:33:27', 7, 200, 1, NULL),
	(62, '2024-02-15', '09:49:02', 4, 170, 1, NULL),
	(63, '2024-02-15', '09:50:45', 12, 200, 1, NULL),
	(64, '2024-02-15', '09:51:46', 2, 199, 1, NULL),
	(66, '2024-02-15', '10:26:07', 16, 197, 1, NULL),
	(67, '2024-02-15', '10:59:21', 15, 204, 1, NULL),
	(69, '2024-02-15', '12:23:49', 20, 178, 6, NULL),
	(70, '2024-02-15', '12:58:27', 15, 195, 6, NULL),
	(71, '2024-02-15', '14:12:47', 10, 213, 1, NULL),
	(74, '2024-02-15', '15:10:14', 2, 208, 1, NULL),
	(75, '2024-02-15', '15:19:26', 16, 184, 1, NULL),
	(78, '2024-02-16', '16:44:56', 6, 205, 2, NULL),
	(79, '2024-02-17', '13:02:43', 6, 203, 1, NULL),
	(81, '2024-02-17', '14:21:43', 10, 214, 1, NULL),
	(83, '2024-02-17', '17:13:01', 20, 200, 1, NULL),
	(84, '2024-02-17', '17:21:51', 10, 217, 1, NULL),
	(85, '2024-02-17', '17:25:32', 6, 208, 1, NULL),
	(87, '2024-02-18', '09:58:52', 20, 212, 4, NULL),
	(92, '2024-02-18', '16:49:38', 20, 200, 1, NULL),
	(94, '2024-02-19', '09:09:01', 10, 200, 1, NULL),
	(95, '2024-02-19', '09:34:12', 20, 200, 1, NULL),
	(96, '2024-02-19', '09:40:48', 19, 202, 1, NULL),
	(97, '2024-02-19', '09:45:48', 12, 200, 1, NULL),
	(98, '2024-02-19', '09:46:49', 2, 196, 1, NULL),
	(100, '2024-02-19', '11:08:54', 20, 196, 1, NULL),
	(101, '2024-02-19', '11:50:05', 18, 180, 1, NULL),
	(103, '2024-02-19', '12:47:14', 2, 190, 1, NULL),
	(104, '2024-02-19', '13:00:31', 8, 170, 1, NULL),
	(107, '2024-02-19', '15:11:49', 16, 193, 1, NULL),
	(109, '2024-02-19', '16:10:06', 10, 208, 1, NULL),
	(114, '2024-02-21', '08:56:57', 20, 200, 1, NULL),
	(115, '2024-02-21', '09:02:27', 12, 170, 1, NULL),
	(116, '2024-02-21', '09:05:31', 10, 203, 1, NULL),
	(117, '2024-02-21', '09:29:40', 4, 183, 1, NULL),
	(118, '2024-02-21', '09:42:02', 8, 190, 1, NULL),
	(119, '2024-02-21', '09:42:40', 2, 200, 1, NULL),
	(122, '2024-02-21', '09:56:01', 2, 190, 1, NULL),
	(125, '2024-02-21', '12:31:22', 4, 165, 1, NULL),
	(127, '2024-02-21', '16:43:52', 10, 206, 2, NULL),
	(130, '2024-02-21', '17:37:26', 20, 204, 2, NULL),
	(132, '2024-02-24', '15:24:33', 2, 200, 1, NULL),
	(133, '2024-02-22', '17:28:00', 20, 209, 2, NULL),
	(134, '2024-02-22', '17:59:00', 20, 205, 2, NULL),
	(136, '2024-02-23', '17:30:00', 6, 200, 2, NULL),
	(139, '2024-02-24', '15:50:39', 16, 200, 1, NULL),
	(140, '2024-02-25', '15:07:10', 2, 193, 1, NULL),
	(141, '2024-02-25', '15:24:36', 20, 193, 2, NULL),
	(145, '2024-02-25', '17:48:29', 16, 200, 1, NULL),
	(146, '2024-02-25', '17:48:42', 10, 212, 1, NULL),
	(147, '2024-02-25', '18:35:42', 20, 212, 1, NULL),
	(150, '2024-02-26', '10:42:26', 9, 180, 1, NULL),
	(151, '2024-03-01', '23:44:29', 20, 200, 9, 'sad'),
	(152, '2024-03-01', '23:47:58', 19, 210, 7, NULL),
	(154, '2024-03-02', '02:34:03', 13, 211, 7, 'sd'),
	(155, '2024-03-02', '02:36:09', 20, 212, 9, NULL),
	(156, '2024-03-02', '02:38:37', 19, 212, 8, NULL),
	(157, '2024-03-02', '02:43:23', 19, 212, 8, NULL),
	(158, '2024-03-02', '02:44:16', 19, 212, 7, NULL),
	(159, '2024-03-02', '02:48:34', 17, 212, 9, NULL),
	(161, '2024-03-02', '02:54:32', 16, 211, 9, NULL),
	(162, '2024-03-02', '03:01:28', 20, 212, 8, NULL),
	(163, '2024-03-02', '03:43:32', 20, 212, 3, NULL),
	(164, '2024-03-02', '03:44:42', 14, 180, 6, NULL),
	(165, '2024-03-02', '03:47:32', 20, 178, 4, NULL),
	(166, '2024-03-02', '03:49:57', 13, 180, 6, NULL),
	(167, '2024-03-02', '03:52:26', 5, 199, 1, NULL),
	(168, '2024-03-02', '03:58:59', 16, 188, 2, NULL),
	(169, '2024-03-06', '02:01:30', 18, 178, 7, NULL),
	(170, '2024-03-06', '02:10:51', 18, 200, 6, NULL),
	(171, '2024-03-06', '02:14:37', 17, 200, 7, 'asdasd'),
	(187, '2024-04-05', '01:37:21', 15, 211, 8, '123adasdasd');

-- Dumping structure for table CookLog.items
CREATE TABLE IF NOT EXISTS `items` (
  `ID` mediumint(8) unsigned NOT NULL AUTO_INCREMENT,
  `Item` varchar(40) NOT NULL DEFAULT '0',
  `MinTemp` tinyint(3) unsigned NOT NULL,
  `Minutes` tinyint(3) unsigned DEFAULT NULL,
  `Method` tinyint(3) unsigned NOT NULL,
  `Comment` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `FK_items_methods` (`Method`),
  CONSTRAINT `FK_items_methods` FOREIGN KEY (`Method`) REFERENCES `methods` (`ID`) ON DELETE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table CookLog.items: ~21 rows (approximately)
INSERT INTO `items` (`ID`, `Item`, `MinTemp`, `Minutes`, `Method`, `Comment`) VALUES
	(1, '8 Piece Fried Chicken', 165, 15, 2, NULL),
	(2, '8 Piece Chicken Baked', 165, 30, 1, NULL),
	(4, 'CornDogs', 165, 8, 2, NULL),
	(5, 'Egg Roll', 165, 6, 2, NULL),
	(6, 'Fish', 165, 8, 1, 'Connected!'),
	(7, 'Gravy', 165, NULL, 1, NULL),
	(8, 'Hot Sandwich', 165, 20, 1, NULL),
	(9, 'Hot Veggie', 165, NULL, 1, NULL),
	(10, 'JoJo\'s', 165, 7, 2, NULL),
	(11, 'Lasagna', 165, 50, 1, NULL),
	(12, 'Mac and Cheese', 165, NULL, 1, NULL),
	(13, 'Mashed Potatoes', 165, NULL, 1, NULL),
	(14, 'Nuggets', 165, 8, 2, NULL),
	(15, 'Pork Chops', 165, NULL, 1, NULL),
	(16, 'Rotisserie Chicken', 181, 60, 1, NULL),
	(17, 'Shrimp', 165, 2, 2, NULL),
	(18, 'Stuffed Beef Cabage', 165, 40, 1, NULL),
	(19, 'Swedish Meetballs', 165, 50, 1, NULL),
	(20, 'Tenders', 170, 8, 2, NULL),
	(21, 'Wing Dings', 165, 8, 2, NULL);

-- Dumping structure for table CookLog.methods
CREATE TABLE IF NOT EXISTS `methods` (
  `ID` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `Method` varchar(20) NOT NULL,
  `Comment` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table CookLog.methods: ~2 rows (approximately)
INSERT INTO `methods` (`ID`, `Method`, `Comment`) VALUES
	(1, 'Oven', NULL),
	(2, 'Fryer', NULL);

-- Dumping structure for trigger CookLog.cook_validate_temp
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `cook_validate_temp` BEFORE INSERT ON `cook` FOR EACH ROW BEGIN
	IF(
		(SELECT `MinTemp` FROM `items` WHERE `ID` = new.`ItemID`)
		> new.`Temp`
	) THEN
		SIGNAL SQLSTATE '45000'
		SET MYSQL_ERRNO=30001,
		MESSAGE_TEXT= 'This item is still raw!';
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;


-- Dumping database structure for SaladLog
CREATE DATABASE IF NOT EXISTS `saladlog` /*!40100 DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci */;
USE `SaladLog`;

-- Dumping structure for table SaladLog.items
CREATE TABLE IF NOT EXISTS `items` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Salad` varchar(40) NOT NULL,
  `Life` tinyint(3) unsigned NOT NULL,
  `Comment` varchar(100) DEFAULT '',
  PRIMARY KEY (`ID`),
  CONSTRAINT `ZeroLife` CHECK (`Life` > 0)
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table SaladLog.items: ~38 rows (approximately)
INSERT INTO `items` (`ID`, `Salad`, `Life`, `Comment`) VALUES
	(2, 'Beets and Onion', 7, NULL),
	(3, 'Blueberry Cheese Cake', 7, NULL),
	(4, 'Brocoli Bacon', 5, ''),
	(5, 'Brocoli Chedder', 5, ''),
	(6, 'Cherry Cheese Cake', 7, ''),
	(7, 'Cherry Cheesecake', 7, ''),
	(8, 'Coleslaw', 7, ''),
	(9, 'Cowboy Cavar', 7, ''),
	(10, 'Cranberry Orange Relish', 7, ''),
	(11, 'Cranberry Walnut', 5, ''),
	(12, 'Cucumber and Onion', 7, ''),
	(13, 'Develed Egg Potato Salad', 7, ''),
	(14, 'Dill Potato Salad', 5, ''),
	(15, 'Egg Salad', 7, ''),
	(16, 'Fruit Salad', 7, ''),
	(17, 'Ham Salad', 7, ''),
	(18, 'Ham and Cheese', 5, ''),
	(19, 'Honey Chicken Salad', 7, ''),
	(20, 'Italian Pasta', 7, ''),
	(21, 'Jalapeno Popper', 7, ''),
	(22, 'Lemon Garlic Shrimp Salad', 5, ''),
	(23, 'Macaroni Salad', 7, ''),
	(24, 'Mushroom Salad', 7, ''),
	(25, 'Oriental Crunch', 5, ''),
	(26, 'Parmasan Bowtie', 5, ''),
	(27, 'Parmesan Peppercorn', 7, ''),
	(28, 'Pepper Slaw', 7, ''),
	(29, 'Pistachio Pineapple', 7, ''),
	(30, 'Potato Salad', 7, ''),
	(31, 'Rice Pudding', 7, ''),
	(32, 'Seafood Macaroni', 7, ''),
	(33, 'Seafood Supream', 7, ''),
	(34, 'Spring Pasta Salad', 7, ''),
	(35, 'Steak House Potato Salad', 7, ''),
	(36, 'Strawberry Supprise', 7, ''),
	(37, 'Summer Fresh', 7, ''),
	(38, 'Three Bean Salad', 7, ''),
	(39, 'Tuna Macaroni', 5, '');

-- Dumping structure for table SaladLog.salad
CREATE TABLE IF NOT EXISTS `salad` (
  `ID` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `Date` date NOT NULL DEFAULT curdate(),
  `Time` time NOT NULL DEFAULT curtime(),
  `SaladID` int(10) unsigned NOT NULL,
  `MeatAge` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `Expires` date NOT NULL,
  `Ack` tinyint(1) DEFAULT 0,
  `Person` smallint(5) unsigned DEFAULT NULL,
  `Comment` varchar(75) DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `FK_salad_Work.people` (`Person`),
  KEY `FK_salad_items` (`SaladID`) USING BTREE,
  CONSTRAINT `FK_salad_Work.people` FOREIGN KEY (`Person`) REFERENCES `work`.`people` (`ID`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `FK_salad_items` FOREIGN KEY (`SaladID`) REFERENCES `items` (`ID`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `ValidExpires` CHECK (`Date` < `Expires`)
) ENGINE=InnoDB AUTO_INCREMENT=80 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table SaladLog.salad: ~41 rows (approximately)
INSERT INTO `salad` (`ID`, `Date`, `Time`, `SaladID`, `MeatAge`, `Expires`, `Ack`, `Person`, `Comment`) VALUES
	(37, '2024-02-06', '16:49:33', 29, 0, '2024-02-14', 1, 4, NULL),
	(38, '2024-02-06', '16:53:33', 34, 0, '2024-02-14', 1, NULL, NULL),
	(39, '2024-02-06', '16:53:53', 27, 0, '2024-02-14', 1, NULL, NULL),
	(40, '2024-02-06', '16:54:06', 9, 0, '2024-02-14', 1, NULL, NULL),
	(41, '2024-02-07', '16:54:28', 28, 0, '2024-02-15', 1, NULL, NULL),
	(42, '2024-02-07', '16:54:36', 20, 0, '2024-02-15', 1, NULL, NULL),
	(43, '2024-02-07', '16:56:46', 29, 0, '2024-02-15', 1, NULL, NULL),
	(44, '2024-02-10', '17:08:28', 19, 0, '2024-02-18', 1, NULL, NULL),
	(45, '2024-02-13', '07:00:00', 29, 0, '2024-02-20', 1, NULL, NULL),
	(46, '2024-02-13', '07:00:00', 8, 0, '2024-02-20', 1, NULL, NULL),
	(47, '2024-02-13', '07:00:00', 20, 0, '2024-02-20', 1, NULL, NULL),
	(48, '2024-02-14', '06:00:00', 38, 0, '2024-02-21', 1, NULL, NULL),
	(49, '2024-02-14', '06:00:00', 26, 0, '2024-02-19', 1, NULL, NULL),
	(50, '2024-02-14', '06:00:00', 12, 0, '2024-02-21', NULL, NULL, NULL),
	(51, '2024-02-14', '14:30:06', 4, 0, '2024-02-20', 1, NULL, NULL),
	(53, '2024-02-15', '07:33:30', 30, 0, '2024-02-22', 1, NULL, NULL),
	(54, '2024-02-15', '07:33:36', 8, 0, '2024-02-22', 1, NULL, NULL),
	(55, '2024-02-15', '07:40:05', 37, 0, '2024-02-22', 1, NULL, NULL),
	(56, '2024-02-15', '07:43:46', 9, 0, '2024-02-22', 1, NULL, NULL),
	(57, '2024-02-13', '07:53:05', 33, 2, '2024-02-18', 1, NULL, NULL),
	(58, '2024-02-15', '09:13:31', 29, 0, '2024-02-22', 0, NULL, NULL),
	(59, '2024-02-15', '14:02:00', 14, 0, '2024-02-21', 1, NULL, NULL),
	(60, '2024-02-17', '12:41:42', 4, 0, '2024-02-23', 1, NULL, NULL),
	(61, '2024-02-17', '14:54:04', 9, 0, '2024-02-25', 1, NULL, NULL),
	(62, '2024-02-17', '16:24:41', 9, 0, '2024-02-25', 0, NULL, NULL),
	(63, '2024-02-17', '17:36:52', 8, 5, '2024-02-20', 1, NULL, NULL),
	(64, '2024-02-17', '12:00:00', 33, 2, '2024-02-23', 0, NULL, NULL),
	(65, '2024-02-19', '09:04:34', 30, 0, '2024-02-26', 0, NULL, NULL),
	(66, '2024-02-19', '07:30:00', 8, 0, '2024-02-26', 0, NULL, NULL),
	(67, '2024-02-17', '08:00:00', 38, 0, '2024-02-24', 0, NULL, NULL),
	(68, '2024-02-19', '10:50:18', 22, 0, '2024-02-24', 0, NULL, NULL),
	(69, '2024-02-19', '07:30:00', 26, 0, '2024-02-24', 0, NULL, NULL),
	(70, '2024-02-20', '16:00:00', 14, 0, '2024-02-26', 1, NULL, NULL),
	(72, '2024-02-21', '07:41:07', 7, 0, '2024-02-28', 0, NULL, NULL),
	(73, '2024-02-21', '14:53:51', 25, 0, '2024-02-27', 0, NULL, NULL),
	(74, '2024-02-24', '15:21:36', 4, 0, '2024-03-01', 0, NULL, NULL),
	(75, '2024-02-24', '15:40:15', 14, 0, '2024-03-01', 0, NULL, NULL),
	(76, '2024-02-26', '08:33:08', 2, 0, '2024-03-04', 0, NULL, NULL),
	(77, '2024-02-26', '08:34:17', 39, 0, '2024-03-02', 0, NULL, NULL),
	(78, '2024-02-26', '08:36:21', 21, 0, '2024-03-04', 0, NULL, NULL),
	(79, '2024-02-26', '12:35:00', 37, 0, '2024-03-05', 0, NULL, NULL);

-- Dumping structure for table SaladLog.vars
CREATE TABLE IF NOT EXISTS `vars` (
  `Key` varchar(20) DEFAULT NULL,
  `Value` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table SaladLog.vars: ~0 rows (approximately)
INSERT INTO `vars` (`Key`, `Value`) VALUES
	('RollOverTime', '12:00');

-- Dumping structure for trigger SaladLog.salad_auto_ack
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `salad_auto_ack` BEFORE INSERT ON `salad` FOR EACH ROW BEGIN
	UPDATE `salad`
		SET `Ack` = 1
	 	WHERE 
			`Ack` = 0
			AND `SaladID` = (NEW.`SaladID`)
			AND `ID` <> (NEW.`ID`);
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger SaladLog.salad_calculate_expires
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `salad_calculate_expires` BEFORE INSERT ON `salad` FOR EACH ROW BEGIN
	SET NEW.`Expires` = 
		NEW.`Date` +
		INTERVAL (
			SELECT `Life`
				FROM `items`
				WHERE `ID` = NEW.`SaladID`
		) - NEW.`MeatAge` DAY;
	
	IF(
		(
			SELECT CAST(`Value` AS TIME)
				FROM `vars`
				WHERE `Key` = 'RollOverTime'
		) <= NEW.`Time`
	) THEN
		SET NEW.`Expires` = NEW.`Expires` + INTERVAL 1 DAY;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;


-- Dumping database structure for Work
CREATE DATABASE IF NOT EXISTS `work` /*!40100 DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci */;
USE `Work`;

-- Dumping structure for table Work.people
CREATE TABLE IF NOT EXISTS `people` (
  `ID` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `Name` varchar(20) NOT NULL,
  `Active` tinyint(1) NOT NULL DEFAULT 0,
  `Comment` varchar(300) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table Work.people: ~10 rows (approximately)
INSERT INTO `people` (`ID`, `Name`, `Active`, `Comment`) VALUES
	(1, 'Zekrom', 1, 'Super user 2.0'),
	(2, 'Reshiram', 1, NULL),
	(3, 'Rayquaza', 1, 'Imported'),
	(4, 'Garchomp', 1, 'Imported'),
	(5, 'Palkia', 1, 'Imported'),
	(6, 'Dragapult', 1, 'Imported'),
	(7, 'Flapple', 1, 'Imported'),
	(8, 'Tyrantrum ', 1, 'Imported'),
	(9, 'Appletun', 1, 'Imported'),
	(10, 'Kommo-o ', 1, 'Imported');

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
