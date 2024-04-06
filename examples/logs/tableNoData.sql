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

-- Data exporting was unselected.

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

-- Data exporting was unselected.

-- Dumping structure for table CookLog.methods
CREATE TABLE IF NOT EXISTS `methods` (
  `ID` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `Method` varchar(20) NOT NULL,
  `Comment` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Data exporting was unselected.

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

-- Data exporting was unselected.

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

-- Data exporting was unselected.

-- Dumping structure for table SaladLog.vars
CREATE TABLE IF NOT EXISTS `vars` (
  `Key` varchar(20) DEFAULT NULL,
  `Value` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Data exporting was unselected.

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

-- Data exporting was unselected.

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
