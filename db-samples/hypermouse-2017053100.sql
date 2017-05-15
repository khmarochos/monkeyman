-- MySQL dump 10.13  Distrib 5.5.54, for Linux (x86_64)
--
-- Host: localhost    Database: hypermouse
-- ------------------------------------------------------
-- Server version	5.5.54

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `hypermouse`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `hypermouse` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */;

USE `hypermouse`;

--
-- Table structure for table `_template_`
--

DROP TABLE IF EXISTS `_template_`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `_template_` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `_template_`
--

LOCK TABLES `_template_` WRITE;
/*!40000 ALTER TABLE `_template_` DISABLE KEYS */;
/*!40000 ALTER TABLE `_template_` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contractor`
--

DROP TABLE IF EXISTS `contractor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contractor` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `contractor_type_id` int(10) unsigned NOT NULL,
  `provider` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `name` (`name`) USING BTREE,
  KEY `contractor_type_id` (`contractor_type_id`),
  CONSTRAINT `contractor_ibfk_1` FOREIGN KEY (`contractor_type_id`) REFERENCES `contractor_type` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=104 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contractor`
--

LOCK TABLES `contractor` WRITE;
/*!40000 ALTER TABLE `contractor` DISABLE KEYS */;
INSERT INTO `contractor` VALUES (1,'2017-01-24 07:08:12',NULL,NULL,'ХМАРА',3,1),(2,'2017-01-24 07:08:12',NULL,NULL,'АПТАЙМ',3,1),(3,'2017-01-24 07:08:12',NULL,NULL,'Сухобок Катерина Володимирівна',2,1),(101,'2017-01-24 06:27:19',NULL,NULL,'ЖУЙСТРОЙІНВЄСТЖЛОБ',3,0),(102,'2017-01-24 06:27:47',NULL,NULL,'Іванов Іван Іванович',1,0),(103,'2017-01-24 06:27:47',NULL,NULL,'АЙНЕНЕ-ТЕЛЕКОМ',3,0);
/*!40000 ALTER TABLE `contractor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contractor_type`
--

DROP TABLE IF EXISTS `contractor_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contractor_type` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contractor_type`
--

LOCK TABLES `contractor_type` WRITE;
/*!40000 ALTER TABLE `contractor_type` DISABLE KEYS */;
INSERT INTO `contractor_type` VALUES (1,'2017-01-24 06:01:56',NULL,NULL),(2,'2017-01-24 06:01:56',NULL,NULL),(3,'2017-01-24 07:42:26',NULL,NULL);
/*!40000 ALTER TABLE `contractor_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contractor_type_i18n`
--

DROP TABLE IF EXISTS `contractor_type_i18n`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contractor_type_i18n` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `contrator_type_id` int(10) unsigned NOT NULL,
  `language_id` int(10) unsigned NOT NULL,
  `name` varchar(127) NOT NULL,
  `name_short` varchar(63) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `contractor_type_name_ibfk_1` (`contrator_type_id`),
  KEY `contractor_type_name_ibfk_2` (`language_id`),
  CONSTRAINT `contractor_type_i18n_ibfk_1` FOREIGN KEY (`contrator_type_id`) REFERENCES `contractor_type` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `contractor_type_i18n_ibfk_2` FOREIGN KEY (`language_id`) REFERENCES `language` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contractor_type_i18n`
--

LOCK TABLES `contractor_type_i18n` WRITE;
/*!40000 ALTER TABLE `contractor_type_i18n` DISABLE KEYS */;
INSERT INTO `contractor_type_i18n` VALUES (1,'2017-01-24 06:04:04',NULL,NULL,1,1,'private person','PP'),(2,'2017-01-24 06:04:04',NULL,NULL,1,2,'приватна особа','ПО'),(3,'2017-01-24 06:04:04',NULL,NULL,2,1,'private enterpreneur','PE'),(4,'2017-01-24 06:04:04',NULL,NULL,2,2,'фізична особа підприємець','ФЛП'),(5,'2017-01-24 06:09:48',NULL,NULL,3,1,'limited liability company','LLC'),(6,'2017-01-24 06:11:12',NULL,NULL,3,2,'товариство з обмеженною відповідальністю','ТОВ');
/*!40000 ALTER TABLE `contractor_type_i18n` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `corporation`
--

DROP TABLE IF EXISTS `corporation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `corporation` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `provider` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `name` (`name`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `corporation`
--

LOCK TABLES `corporation` WRITE;
/*!40000 ALTER TABLE `corporation` DISABLE KEYS */;
INSERT INTO `corporation` VALUES (1,'2017-04-18 17:38:07',NULL,NULL,'UKRSALO Inc.',0);
/*!40000 ALTER TABLE `corporation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `corporation_x_contractor`
--

DROP TABLE IF EXISTS `corporation_x_contractor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `corporation_x_contractor` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `corporation_id` int(10) unsigned NOT NULL,
  `contractor_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `corporation_id` (`corporation_id`),
  KEY `contractor_id` (`contractor_id`),
  CONSTRAINT `corporation_x_contractor_ibfk_1` FOREIGN KEY (`corporation_id`) REFERENCES `corporation` (`id`),
  CONSTRAINT `corporation_x_contractor_ibfk_2` FOREIGN KEY (`contractor_id`) REFERENCES `contractor` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `corporation_x_contractor`
--

LOCK TABLES `corporation_x_contractor` WRITE;
/*!40000 ALTER TABLE `corporation_x_contractor` DISABLE KEYS */;
INSERT INTO `corporation_x_contractor` VALUES (1,'2017-04-18 17:38:51',NULL,NULL,1,101),(2,'2017-04-18 17:38:51',NULL,NULL,1,103);
/*!40000 ALTER TABLE `corporation_x_contractor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `country`
--

DROP TABLE IF EXISTS `country`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `country` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `code` varchar(2) NOT NULL,
  `default_language_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `default_language_id` (`default_language_id`),
  CONSTRAINT `country_ibfk_1` FOREIGN KEY (`default_language_id`) REFERENCES `language` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `country`
--

LOCK TABLES `country` WRITE;
/*!40000 ALTER TABLE `country` DISABLE KEYS */;
INSERT INTO `country` VALUES (1,'2017-01-24 06:22:57',NULL,NULL,'UA',2);
/*!40000 ALTER TABLE `country` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `country_i18n`
--

DROP TABLE IF EXISTS `country_i18n`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `country_i18n` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `country_id` int(10) unsigned NOT NULL,
  `language_id` int(10) unsigned NOT NULL,
  `name` varchar(127) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `country_i18n`
--

LOCK TABLES `country_i18n` WRITE;
/*!40000 ALTER TABLE `country_i18n` DISABLE KEYS */;
INSERT INTO `country_i18n` VALUES (1,'2017-01-24 06:23:42',NULL,NULL,1,1,'Ukraine'),(2,'2017-01-24 06:23:42',NULL,NULL,1,2,'Україна');
/*!40000 ALTER TABLE `country_i18n` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `country_x_contractor_type`
--

DROP TABLE IF EXISTS `country_x_contractor_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `country_x_contractor_type` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `country_id` int(10) unsigned NOT NULL,
  `contractor_type` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `country_id` (`country_id`),
  KEY `contractor_type` (`contractor_type`),
  CONSTRAINT `country_x_contractor_type_ibfk_1` FOREIGN KEY (`country_id`) REFERENCES `country` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `country_x_contractor_type_ibfk_2` FOREIGN KEY (`contractor_type`) REFERENCES `contractor_type` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `country_x_contractor_type`
--

LOCK TABLES `country_x_contractor_type` WRITE;
/*!40000 ALTER TABLE `country_x_contractor_type` DISABLE KEYS */;
INSERT INTO `country_x_contractor_type` VALUES (1,'2017-01-24 06:26:19',NULL,NULL,1,1),(2,'2017-01-24 06:26:19',NULL,NULL,1,2),(3,'2017-01-24 06:26:19',NULL,NULL,1,3);
/*!40000 ALTER TABLE `country_x_contractor_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `currency`
--

DROP TABLE IF EXISTS `currency`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `currency` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `code` varchar(3) NOT NULL,
  `sign` char(1) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `currency`
--

LOCK TABLES `currency` WRITE;
/*!40000 ALTER TABLE `currency` DISABLE KEYS */;
INSERT INTO `currency` VALUES (1,'2017-01-24 07:09:24',NULL,NULL,'EUR','€'),(2,'2017-01-24 07:09:24',NULL,NULL,'UAH','₴');
/*!40000 ALTER TABLE `currency` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `currency_i18n`
--

DROP TABLE IF EXISTS `currency_i18n`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `currency_i18n` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `currency_id` int(10) unsigned NOT NULL,
  `language_id` int(10) unsigned NOT NULL,
  `name` varchar(127) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `currency_id` (`currency_id`),
  KEY `language_id` (`language_id`),
  CONSTRAINT `currency_i18n_ibfk_1` FOREIGN KEY (`currency_id`) REFERENCES `currency` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `currency_i18n_ibfk_2` FOREIGN KEY (`language_id`) REFERENCES `language` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `currency_i18n`
--

LOCK TABLES `currency_i18n` WRITE;
/*!40000 ALTER TABLE `currency_i18n` DISABLE KEYS */;
INSERT INTO `currency_i18n` VALUES (1,'2017-01-24 07:13:20',NULL,NULL,1,1,'Euro'),(2,'2017-01-24 07:13:20',NULL,NULL,1,2,'Євро'),(3,'2017-01-24 07:15:18',NULL,NULL,2,1,'Ukrainian hryvnia'),(4,'2017-01-24 07:15:18',NULL,NULL,2,2,'Гривня');
/*!40000 ALTER TABLE `currency_i18n` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `currency_rate`
--

DROP TABLE IF EXISTS `currency_rate`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `currency_rate` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `currency_id` int(10) unsigned NOT NULL,
  `rate` double NOT NULL,
  PRIMARY KEY (`id`),
  KEY `currency_id` (`currency_id`),
  CONSTRAINT `currency_rate_ibfk_1` FOREIGN KEY (`currency_id`) REFERENCES `currency` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `currency_rate`
--

LOCK TABLES `currency_rate` WRITE;
/*!40000 ALTER TABLE `currency_rate` DISABLE KEYS */;
INSERT INTO `currency_rate` VALUES (1,'2017-01-01 00:00:00',NULL,NULL,1,1),(2,'2017-01-01 00:00:00',NULL,NULL,2,28.422604);
/*!40000 ALTER TABLE `currency_rate` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `datetime_format`
--

DROP TABLE IF EXISTS `datetime_format`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `datetime_format` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `format_date` varchar(127) NOT NULL,
  `format_time` varchar(127) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `datetime_format`
--

LOCK TABLES `datetime_format` WRITE;
/*!40000 ALTER TABLE `datetime_format` DISABLE KEYS */;
INSERT INTO `datetime_format` VALUES (1,'2017-02-11 09:26:58',NULL,NULL,'dd-MM-YYYY','HH:mm:ss'),(2,'2017-02-11 09:26:58',NULL,NULL,'MM-dd-YYYY','HH:mm:ss');
/*!40000 ALTER TABLE `datetime_format` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `language`
--

DROP TABLE IF EXISTS `language`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `language` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `name` varchar(64) NOT NULL,
  `name_native` varchar(64) NOT NULL,
  `code` varchar(5) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `language`
--

LOCK TABLES `language` WRITE;
/*!40000 ALTER TABLE `language` DISABLE KEYS */;
INSERT INTO `language` VALUES (1,'2017-01-24 03:37:47',NULL,NULL,'English (United States)','English (United States)','en_US'),(2,'2017-01-24 03:37:57',NULL,NULL,'Ukrainian (Ukraine)','українська (Україна)','uk_UA');
/*!40000 ALTER TABLE `language` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `partnership_agreement`
--

DROP TABLE IF EXISTS `partnership_agreement`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `partnership_agreement` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `name` varchar(32) NOT NULL,
  `provider_contractor_id` int(10) unsigned NOT NULL,
  `client_contractor_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `name` (`name`) USING BTREE,
  KEY `client_contractor_id` (`client_contractor_id`),
  KEY `provider_contractor_id` (`provider_contractor_id`) USING BTREE,
  CONSTRAINT `partnership_agreement_ibfk_1` FOREIGN KEY (`client_contractor_id`) REFERENCES `contractor` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `partnership_agreement_ibfk_2` FOREIGN KEY (`provider_contractor_id`) REFERENCES `contractor` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `partnership_agreement`
--

LOCK TABLES `partnership_agreement` WRITE;
/*!40000 ALTER TABLE `partnership_agreement` DISABLE KEYS */;
/*!40000 ALTER TABLE `partnership_agreement` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `partnership_level`
--

DROP TABLE IF EXISTS `partnership_level`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `partnership_level` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `partnership_level`
--

LOCK TABLES `partnership_level` WRITE;
/*!40000 ALTER TABLE `partnership_level` DISABLE KEYS */;
/*!40000 ALTER TABLE `partnership_level` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `partnership_level_i18n`
--

DROP TABLE IF EXISTS `partnership_level_i18n`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `partnership_level_i18n` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `partnership_level_id` int(10) unsigned NOT NULL,
  `language_id` int(10) unsigned NOT NULL,
  `name` varchar(127) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `lanuage_id` (`language_id`),
  KEY `partnership_level_id` (`partnership_level_id`) USING BTREE,
  CONSTRAINT `partnership_level_i18n_ibfk_1` FOREIGN KEY (`partnership_level_id`) REFERENCES `partnership_level` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `partnership_level_i18n_ibfk_2` FOREIGN KEY (`language_id`) REFERENCES `language` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `partnership_level_i18n`
--

LOCK TABLES `partnership_level_i18n` WRITE;
/*!40000 ALTER TABLE `partnership_level_i18n` DISABLE KEYS */;
/*!40000 ALTER TABLE `partnership_level_i18n` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `partnership_obligation`
--

DROP TABLE IF EXISTS `partnership_obligation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `partnership_obligation` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `partnership_agreement_id` int(10) unsigned NOT NULL,
  `provisioning_obligation_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `partnership_agreement_id` (`partnership_agreement_id`) USING BTREE,
  KEY `provisioning_obligation_id` (`provisioning_obligation_id`) USING BTREE,
  CONSTRAINT `partnership_obligation_ibfk_1` FOREIGN KEY (`partnership_agreement_id`) REFERENCES `partnership_agreement` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `partnership_obligation_ibfk_2` FOREIGN KEY (`provisioning_obligation_id`) REFERENCES `provisioning_obligation` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `partnership_obligation`
--

LOCK TABLES `partnership_obligation` WRITE;
/*!40000 ALTER TABLE `partnership_obligation` DISABLE KEYS */;
/*!40000 ALTER TABLE `partnership_obligation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment`
--

DROP TABLE IF EXISTS `payment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payment` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `provider_contractor_id` int(10) unsigned NOT NULL,
  `client_contractor_id` int(10) unsigned NOT NULL,
  `currency_id` int(10) unsigned NOT NULL,
  `sum` double NOT NULL,
  `transaction_handle` varchar(127) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `provider_contractor_id` (`provider_contractor_id`),
  KEY `client_contractor_id` (`client_contractor_id`),
  KEY `currency_id` (`currency_id`),
  CONSTRAINT `payment_ibfk_1` FOREIGN KEY (`provider_contractor_id`) REFERENCES `contractor` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `payment_ibfk_2` FOREIGN KEY (`client_contractor_id`) REFERENCES `contractor` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `payment_ibfk_3` FOREIGN KEY (`currency_id`) REFERENCES `currency` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment`
--

LOCK TABLES `payment` WRITE;
/*!40000 ALTER TABLE `payment` DISABLE KEYS */;
/*!40000 ALTER TABLE `payment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `period`
--

DROP TABLE IF EXISTS `period`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `period` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `type` enum('hourly','daily','monthly','quarterly','biannually','annually','bienally','trienally') NOT NULL,
  `service_family_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `service_family_id` (`service_family_id`),
  CONSTRAINT `period_ibfk_1` FOREIGN KEY (`service_family_id`) REFERENCES `service_family` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `period`
--

LOCK TABLES `period` WRITE;
/*!40000 ALTER TABLE `period` DISABLE KEYS */;
INSERT INTO `period` VALUES (1,'2017-01-24 09:11:37',NULL,NULL,'monthly',1),(2,'2017-01-24 09:11:37',NULL,NULL,'monthly',2),(3,'2017-01-24 09:11:37',NULL,NULL,'quarterly',2),(4,'2017-01-24 09:11:37',NULL,NULL,'biannually',2),(5,'2017-01-24 09:11:37',NULL,NULL,'annually',2);
/*!40000 ALTER TABLE `period` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `person`
--

DROP TABLE IF EXISTS `person`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `person` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `first_name` varchar(64) NOT NULL,
  `middle_name` varchar(64) DEFAULT NULL,
  `last_name` varchar(64) NOT NULL,
  `language_id` int(10) unsigned NOT NULL,
  `timezone` varchar(32) NOT NULL,
  `datetime_format_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `language_id` (`language_id`),
  KEY `datetime_format_id` (`datetime_format_id`),
  CONSTRAINT `person_ibfk_1` FOREIGN KEY (`language_id`) REFERENCES `language` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `person_ibfk_2` FOREIGN KEY (`datetime_format_id`) REFERENCES `datetime_format` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=128 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `person`
--

LOCK TABLES `person` WRITE;
/*!40000 ALTER TABLE `person` DISABLE KEYS */;
INSERT INTO `person` VALUES (1,'2017-01-25 08:50:50',NULL,NULL,'Катерина','','Сухобок',2,'Europe/Kiev',1),(2,'2017-01-25 08:50:50',NULL,NULL,'Volodymyr','','Melnyk',2,'Europe/Kiev',1),(100,'2017-02-08 20:56:22',NULL,NULL,'Иван','','Царевич',1,'Europe/Kiev',1),(125,'2017-04-18 17:42:19',NULL,NULL,'Степан',NULL,'Срака',2,'Europe/Kiev',1),(127,'2017-04-21 13:08:54',NULL,NULL,'Гаврюша',NULL,'Обезьянов',1,'Europe/Kiev',1);
/*!40000 ALTER TABLE `person` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `person_email`
--

DROP TABLE IF EXISTS `person_email`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `person_email` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `email` varchar(64) NOT NULL,
  `person_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `email` (`email`),
  KEY `person_id` (`person_id`),
  CONSTRAINT `person_email_ibfk_1` FOREIGN KEY (`person_id`) REFERENCES `person` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `person_email`
--

LOCK TABLES `person_email` WRITE;
/*!40000 ALTER TABLE `person_email` DISABLE KEYS */;
INSERT INTO `person_email` VALUES (1,'2017-01-31 11:28:20',NULL,NULL,'e.sukhobok@tucha.ua',1),(2,'2017-01-31 11:28:20',NULL,NULL,'v.melnik@tucha.ua',2),(3,'2017-02-08 20:58:57',NULL,NULL,'ivan.tsarevych@example.org',100),(4,'2017-04-21 12:47:35',NULL,NULL,'vladimir+2017042400@melnik.net.ua',127);
/*!40000 ALTER TABLE `person_email` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `person_email_confirmation`
--

DROP TABLE IF EXISTS `person_email_confirmation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `person_email_confirmation` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `token` varchar(36) NOT NULL,
  `person_email_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `person_email_id` (`person_email_id`),
  CONSTRAINT `person_email_confirmation_ibfk_1` FOREIGN KEY (`person_email_id`) REFERENCES `person_email` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `person_email_confirmation`
--

LOCK TABLES `person_email_confirmation` WRITE;
/*!40000 ALTER TABLE `person_email_confirmation` DISABLE KEYS */;
INSERT INTO `person_email_confirmation` VALUES (1,'2017-04-22 00:33:28',NULL,NULL,'b908b5ea-268e-11e7-b0c5-d3f177be5bce',4);
/*!40000 ALTER TABLE `person_email_confirmation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `person_password`
--

DROP TABLE IF EXISTS `person_password`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `person_password` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `person_id` int(10) unsigned NOT NULL,
  `password` char(40) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `person_id` (`person_id`),
  CONSTRAINT `person_password_ibfk_1` FOREIGN KEY (`person_id`) REFERENCES `person` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `person_password`
--

LOCK TABLES `person_password` WRITE;
/*!40000 ALTER TABLE `person_password` DISABLE KEYS */;
INSERT INTO `person_password` VALUES (1,'2017-01-25 08:58:42',NULL,NULL,1,'7c222fb2927d828af22f592134e8932480637c0d'),(2,'2017-01-25 08:58:49',NULL,NULL,2,'7c222fb2927d828af22f592134e8932480637c0d'),(3,'2017-02-08 20:56:57',NULL,NULL,100,'7c222fb2927d828af22f592134e8932480637c0d'),(4,'2017-04-21 13:08:54',NULL,NULL,127,'6216f8a75fd5bb3d5f22b6f9958cdede3fc086c2');
/*!40000 ALTER TABLE `person_password` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `person_phone`
--

DROP TABLE IF EXISTS `person_phone`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `person_phone` (
  `id` int(10) unsigned NOT NULL,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `phone` varchar(64) NOT NULL,
  `validated` datetime DEFAULT NULL,
  `person_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `person_id` (`person_id`),
  KEY `phone` (`phone`) USING BTREE,
  CONSTRAINT `person_phone_ibfk_1` FOREIGN KEY (`person_id`) REFERENCES `person` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `person_phone`
--

LOCK TABLES `person_phone` WRITE;
/*!40000 ALTER TABLE `person_phone` DISABLE KEYS */;
/*!40000 ALTER TABLE `person_phone` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `person_x_contractor`
--

DROP TABLE IF EXISTS `person_x_contractor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `person_x_contractor` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `person_id` int(10) unsigned NOT NULL,
  `contractor_id` int(10) unsigned NOT NULL,
  `admin` tinyint(1) NOT NULL,
  `billing` tinyint(1) NOT NULL,
  `tech` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `person_x_contractor_ibfk_1` (`person_id`),
  KEY `contractor_id` (`contractor_id`),
  CONSTRAINT `person_x_contractor_ibfk_1` FOREIGN KEY (`person_id`) REFERENCES `person` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `person_x_contractor_ibfk_2` FOREIGN KEY (`contractor_id`) REFERENCES `contractor` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `person_x_contractor`
--

LOCK TABLES `person_x_contractor` WRITE;
/*!40000 ALTER TABLE `person_x_contractor` DISABLE KEYS */;
INSERT INTO `person_x_contractor` VALUES (1,'2017-02-08 13:07:05',NULL,NULL,1,1,1,1,1),(2,'2017-02-08 13:07:53',NULL,NULL,1,2,1,1,1),(3,'2017-02-08 13:08:03',NULL,NULL,1,3,1,1,1),(4,'2017-02-08 13:08:28',NULL,NULL,2,1,1,1,1),(5,'2017-02-08 13:08:28',NULL,NULL,2,2,1,1,1),(6,'2017-02-08 13:08:28',NULL,NULL,2,3,1,1,1),(7,'2017-02-26 19:47:29',NULL,NULL,100,102,0,1,0),(8,'2017-04-19 09:44:28',NULL,NULL,125,103,1,1,1);
/*!40000 ALTER TABLE `person_x_contractor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `person_x_corporation`
--

DROP TABLE IF EXISTS `person_x_corporation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `person_x_corporation` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `person_id` int(10) unsigned NOT NULL,
  `corporation_id` int(10) unsigned NOT NULL,
  `admin` tinyint(1) NOT NULL,
  `billing` tinyint(1) NOT NULL,
  `tech` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `person_x_contractor_ibfk_1` (`person_id`),
  KEY `contractor_id` (`corporation_id`),
  CONSTRAINT `person_x_corporation_ibfk_1` FOREIGN KEY (`person_id`) REFERENCES `person` (`id`),
  CONSTRAINT `person_x_corporation_ibfk_2` FOREIGN KEY (`corporation_id`) REFERENCES `corporation` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `person_x_corporation`
--

LOCK TABLES `person_x_corporation` WRITE;
/*!40000 ALTER TABLE `person_x_corporation` DISABLE KEYS */;
INSERT INTO `person_x_corporation` VALUES (1,'2017-04-18 17:42:58',NULL,NULL,125,1,1,1,1);
/*!40000 ALTER TABLE `person_x_corporation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `person_x_partnership_agreement`
--

DROP TABLE IF EXISTS `person_x_partnership_agreement`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `person_x_partnership_agreement` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `person_id` int(10) unsigned NOT NULL,
  `partnership_agreement_id` int(10) unsigned NOT NULL,
  `admin` tinyint(1) NOT NULL,
  `billing` tinyint(1) NOT NULL,
  `tech` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `person_id` (`person_id`),
  KEY `partnership_agreement_id` (`partnership_agreement_id`) USING BTREE,
  CONSTRAINT `person_x_partnership_agreement_ibfk_1` FOREIGN KEY (`partnership_agreement_id`) REFERENCES `partnership_agreement` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `person_x_partnership_agreement`
--

LOCK TABLES `person_x_partnership_agreement` WRITE;
/*!40000 ALTER TABLE `person_x_partnership_agreement` DISABLE KEYS */;
/*!40000 ALTER TABLE `person_x_partnership_agreement` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `person_x_provisioning_agreement`
--

DROP TABLE IF EXISTS `person_x_provisioning_agreement`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `person_x_provisioning_agreement` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `person_id` int(10) unsigned NOT NULL,
  `provisioning_agreement_id` int(10) unsigned NOT NULL,
  `admin` tinyint(1) NOT NULL,
  `billing` tinyint(1) NOT NULL,
  `tech` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `person_id` (`person_id`),
  KEY `provisioning_agreement_id` (`provisioning_agreement_id`),
  CONSTRAINT `person_x_provisioning_agreement_ibfk_1` FOREIGN KEY (`person_id`) REFERENCES `person` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `person_x_provisioning_agreement_ibfk_2` FOREIGN KEY (`provisioning_agreement_id`) REFERENCES `provisioning_agreement` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `person_x_provisioning_agreement`
--

LOCK TABLES `person_x_provisioning_agreement` WRITE;
/*!40000 ALTER TABLE `person_x_provisioning_agreement` DISABLE KEYS */;
INSERT INTO `person_x_provisioning_agreement` VALUES (1,'2017-02-10 12:23:07',NULL,NULL,100,3,0,1,0),(2,'2017-04-20 12:35:10',NULL,NULL,127,2,1,1,1),(3,'2017-04-20 12:35:39',NULL,NULL,127,1,0,0,1),(4,'2017-04-21 17:05:29',NULL,NULL,127,3,1,1,1);
/*!40000 ALTER TABLE `person_x_provisioning_agreement` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `provisioning_agreement`
--

DROP TABLE IF EXISTS `provisioning_agreement`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `provisioning_agreement` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `name` varchar(32) NOT NULL,
  `provider_contractor_id` int(10) unsigned NOT NULL,
  `client_contractor_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `name` (`name`) USING BTREE,
  KEY `client_contractor_id` (`client_contractor_id`),
  KEY `provider_contractor_id` (`provider_contractor_id`) USING BTREE,
  CONSTRAINT `provisioning_agreement_ibfk_1` FOREIGN KEY (`provider_contractor_id`) REFERENCES `contractor` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `provisioning_agreement_ibfk_2` FOREIGN KEY (`client_contractor_id`) REFERENCES `contractor` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `provisioning_agreement`
--

LOCK TABLES `provisioning_agreement` WRITE;
/*!40000 ALTER TABLE `provisioning_agreement` DISABLE KEYS */;
INSERT INTO `provisioning_agreement` VALUES (1,'2017-01-24 08:45:53',NULL,NULL,'20171001',1,101),(2,'2017-01-24 08:45:53',NULL,NULL,'20171002',2,102),(3,'2017-01-24 08:45:53',NULL,NULL,'20171003',3,103);
/*!40000 ALTER TABLE `provisioning_agreement` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `provisioning_obligation`
--

DROP TABLE IF EXISTS `provisioning_obligation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `provisioning_obligation` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `provisioning_agreement_id` int(10) unsigned NOT NULL,
  `service_type_id` int(10) unsigned NOT NULL,
  `service_level_id` int(10) unsigned NOT NULL,
  `quantity` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `provisioning_agreement_id` (`provisioning_agreement_id`),
  KEY `service_type_id` (`service_type_id`),
  KEY `service_level_id` (`service_level_id`),
  CONSTRAINT `provisioning_obligation_ibfk_1` FOREIGN KEY (`provisioning_agreement_id`) REFERENCES `provisioning_agreement` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `provisioning_obligation_ibfk_2` FOREIGN KEY (`service_type_id`) REFERENCES `service_type` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `provisioning_obligation_ibfk_3` FOREIGN KEY (`service_level_id`) REFERENCES `service_level` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `provisioning_obligation`
--

LOCK TABLES `provisioning_obligation` WRITE;
/*!40000 ALTER TABLE `provisioning_obligation` DISABLE KEYS */;
INSERT INTO `provisioning_obligation` VALUES (1,'2017-01-24 08:46:41',NULL,NULL,1,1,1,2),(2,'2017-01-24 08:46:41',NULL,NULL,1,2,1,4),(3,'2017-01-24 08:46:41',NULL,NULL,1,3,1,100),(4,'2017-01-24 08:46:41',NULL,NULL,2,1,1,8),(5,'2017-01-24 08:46:41',NULL,NULL,2,2,1,32),(6,'2017-01-24 08:46:41',NULL,NULL,2,3,1,500),(7,'2017-01-24 08:46:41',NULL,NULL,2,4,1,1),(8,'2017-01-24 08:50:01',NULL,NULL,3,6,1,1),(9,'2017-01-24 08:50:01',NULL,NULL,3,5,1,1),(10,'2017-01-24 08:50:01',NULL,NULL,3,4,1,1);
/*!40000 ALTER TABLE `provisioning_obligation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `provisioning_obligation_x_resource_piece`
--

DROP TABLE IF EXISTS `provisioning_obligation_x_resource_piece`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `provisioning_obligation_x_resource_piece` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `provisioning_obligation_id` int(10) unsigned NOT NULL,
  `resource_piece_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `provisioning_obligation_id` (`provisioning_obligation_id`),
  KEY `resource_piece_id` (`resource_piece_id`),
  CONSTRAINT `provisioning_obligation_x_resource_piece_ibfk_1` FOREIGN KEY (`provisioning_obligation_id`) REFERENCES `provisioning_obligation` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `provisioning_obligation_x_resource_piece_ibfk_2` FOREIGN KEY (`resource_piece_id`) REFERENCES `resource_piece` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `provisioning_obligation_x_resource_piece`
--

LOCK TABLES `provisioning_obligation_x_resource_piece` WRITE;
/*!40000 ALTER TABLE `provisioning_obligation_x_resource_piece` DISABLE KEYS */;
INSERT INTO `provisioning_obligation_x_resource_piece` VALUES (1,'2017-01-24 09:03:09',NULL,NULL,1,1),(2,'2017-01-24 09:03:09',NULL,NULL,2,1),(3,'2017-01-24 09:03:09',NULL,NULL,3,1),(4,'2017-01-24 09:03:09',NULL,NULL,4,2),(5,'2017-01-24 09:03:09',NULL,NULL,5,2),(6,'2017-01-24 09:03:09',NULL,NULL,6,2),(7,'2017-01-24 09:06:29',NULL,NULL,7,3),(8,'2017-01-24 09:06:29',NULL,NULL,8,4),(9,'2017-01-24 09:06:50',NULL,NULL,9,5),(10,'2017-01-24 09:07:06',NULL,NULL,10,6);
/*!40000 ALTER TABLE `provisioning_obligation_x_resource_piece` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `resource_host`
--

DROP TABLE IF EXISTS `resource_host`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `resource_host` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `resource_type_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `resource_host`
--

LOCK TABLES `resource_host` WRITE;
/*!40000 ALTER TABLE `resource_host` DISABLE KEYS */;
INSERT INTO `resource_host` VALUES (1,'2017-01-24 08:52:28',NULL,NULL,1),(2,'2017-01-24 08:52:28',NULL,NULL,2);
/*!40000 ALTER TABLE `resource_host` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `resource_piece`
--

DROP TABLE IF EXISTS `resource_piece`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `resource_piece` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `resource_type_id` int(10) unsigned NOT NULL,
  `resource_host_id` int(10) unsigned NOT NULL,
  `resource_handle` varchar(127) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `resource_type_id` (`resource_type_id`),
  KEY `resource_host_id` (`resource_host_id`) USING BTREE,
  CONSTRAINT `resource_piece_ibfk_1` FOREIGN KEY (`resource_type_id`) REFERENCES `resource_type` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `resource_piece_ibfk_2` FOREIGN KEY (`resource_host_id`) REFERENCES `resource_host` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `resource_piece`
--

LOCK TABLES `resource_piece` WRITE;
/*!40000 ALTER TABLE `resource_piece` DISABLE KEYS */;
INSERT INTO `resource_piece` VALUES (1,'2017-01-24 08:55:46',NULL,NULL,1,1,'dddd8e83-ecdd-4834-9e6b-ad912bf48ef3'),(2,'2017-01-24 08:55:46',NULL,NULL,1,1,'44fd75f6-8a36-4b76-84f6-7eee403ad39e'),(3,'2017-01-24 08:57:19',NULL,NULL,2,2,'zaloopa'),(4,'2017-01-24 08:57:19',NULL,NULL,2,2,'poeben'),(5,'2017-01-24 08:57:19',NULL,NULL,2,2,'pizdotnya'),(6,'2017-01-24 08:57:19',NULL,NULL,2,2,'huerga');
/*!40000 ALTER TABLE `resource_piece` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `resource_type`
--

DROP TABLE IF EXISTS `resource_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `resource_type` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `resource_type`
--

LOCK TABLES `resource_type` WRITE;
/*!40000 ALTER TABLE `resource_type` DISABLE KEYS */;
INSERT INTO `resource_type` VALUES (1,'2017-01-24 08:52:48',NULL,NULL),(2,'2017-01-24 08:52:48',NULL,NULL);
/*!40000 ALTER TABLE `resource_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `resource_type_i18n`
--

DROP TABLE IF EXISTS `resource_type_i18n`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `resource_type_i18n` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `resource_type_id` int(10) unsigned NOT NULL,
  `language_id` int(10) unsigned NOT NULL,
  `name` varchar(127) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `resource_type_id` (`resource_type_id`),
  KEY `language_id` (`language_id`),
  CONSTRAINT `resource_type_i18n_ibfk_2` FOREIGN KEY (`language_id`) REFERENCES `language` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `resource_type_i18n_ibfk_3` FOREIGN KEY (`resource_type_id`) REFERENCES `resource_type` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `resource_type_i18n`
--

LOCK TABLES `resource_type_i18n` WRITE;
/*!40000 ALTER TABLE `resource_type_i18n` DISABLE KEYS */;
INSERT INTO `resource_type_i18n` VALUES (1,'2017-01-24 08:54:22',NULL,NULL,1,1,'Virtual Server'),(2,'2017-01-24 08:54:22',NULL,NULL,1,2,'Віртуальний сервер'),(3,'2017-01-24 08:54:22',NULL,NULL,2,1,'Shared Hosting Account'),(4,'2017-01-24 08:54:22',NULL,NULL,2,2,'Обликовий запис на хостинговому сервері загального користування');
/*!40000 ALTER TABLE `resource_type_i18n` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `service_family`
--

DROP TABLE IF EXISTS `service_family`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `service_family` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_family`
--

LOCK TABLES `service_family` WRITE;
/*!40000 ALTER TABLE `service_family` DISABLE KEYS */;
INSERT INTO `service_family` VALUES (1,'2017-01-24 08:05:37',NULL,NULL),(2,'2017-01-24 08:05:37',NULL,NULL);
/*!40000 ALTER TABLE `service_family` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `service_family_i18n`
--

DROP TABLE IF EXISTS `service_family_i18n`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `service_family_i18n` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `service_family_id` int(10) unsigned NOT NULL,
  `language_id` int(10) unsigned NOT NULL,
  `name` varchar(127) NOT NULL,
  `description` varchar(127) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `service_family_id` (`service_family_id`),
  KEY `language_id` (`language_id`),
  CONSTRAINT `service_family_i18n_ibfk_1` FOREIGN KEY (`service_family_id`) REFERENCES `service_family` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `service_family_i18n_ibfk_2` FOREIGN KEY (`language_id`) REFERENCES `language` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_family_i18n`
--

LOCK TABLES `service_family_i18n` WRITE;
/*!40000 ALTER TABLE `service_family_i18n` DISABLE KEYS */;
INSERT INTO `service_family_i18n` VALUES (1,'2017-01-24 08:20:56',NULL,NULL,1,1,'TuchaFlex','Cloud Data Center'),(2,'2017-01-24 08:25:24',NULL,NULL,1,2,'TuchaFlex','Віртуальній центр обробки даних'),(3,'2017-01-24 08:27:35',NULL,NULL,2,1,'TuchaHosting','Shared Hosting'),(4,'2017-01-24 08:27:35',NULL,NULL,2,2,'TuchaHosting','Хостинг на сервері спільного користування');
/*!40000 ALTER TABLE `service_family_i18n` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `service_group`
--

DROP TABLE IF EXISTS `service_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `service_group` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `service_family_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `service_family_id` (`service_family_id`),
  CONSTRAINT `service_group_ibfk_1` FOREIGN KEY (`service_family_id`) REFERENCES `service_family` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_group`
--

LOCK TABLES `service_group` WRITE;
/*!40000 ALTER TABLE `service_group` DISABLE KEYS */;
INSERT INTO `service_group` VALUES (1,'2017-01-24 08:28:18',NULL,NULL,1),(2,'2017-01-24 08:28:18',NULL,NULL,2);
/*!40000 ALTER TABLE `service_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `service_group_i18n`
--

DROP TABLE IF EXISTS `service_group_i18n`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `service_group_i18n` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `service_group_id` int(10) unsigned NOT NULL,
  `language_id` int(10) unsigned NOT NULL,
  `name` varchar(127) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `language_id` (`language_id`),
  KEY `service_group_id` (`service_group_id`) USING BTREE,
  CONSTRAINT `service_group_i18n_ibfk_1` FOREIGN KEY (`service_group_id`) REFERENCES `service_group` (`id`),
  CONSTRAINT `service_group_i18n_ibfk_2` FOREIGN KEY (`language_id`) REFERENCES `language` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_group_i18n`
--

LOCK TABLES `service_group_i18n` WRITE;
/*!40000 ALTER TABLE `service_group_i18n` DISABLE KEYS */;
INSERT INTO `service_group_i18n` VALUES (1,'2017-01-24 08:31:16',NULL,NULL,1,1,'Virtual Machine Element'),(2,'2017-01-24 08:31:16',NULL,NULL,1,2,'Елемент віртуального серверу'),(3,'2017-01-24 08:32:19',NULL,NULL,2,1,'Hosting Plan'),(4,'2017-01-24 08:32:19',NULL,NULL,2,2,'Хостинговий план');
/*!40000 ALTER TABLE `service_group_i18n` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `service_level`
--

DROP TABLE IF EXISTS `service_level`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `service_level` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_level`
--

LOCK TABLES `service_level` WRITE;
/*!40000 ALTER TABLE `service_level` DISABLE KEYS */;
INSERT INTO `service_level` VALUES (1,'2017-01-24 08:35:21',NULL,NULL);
/*!40000 ALTER TABLE `service_level` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `service_level_i18n`
--

DROP TABLE IF EXISTS `service_level_i18n`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `service_level_i18n` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `service_level_id` int(10) unsigned NOT NULL,
  `language_id` int(10) unsigned NOT NULL,
  `name` varchar(127) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `service_level_id` (`service_level_id`),
  KEY `lanuage_id` (`language_id`),
  CONSTRAINT `service_level_i18n_ibfk_1` FOREIGN KEY (`service_level_id`) REFERENCES `service_level` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `service_level_i18n_ibfk_2` FOREIGN KEY (`language_id`) REFERENCES `language` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_level_i18n`
--

LOCK TABLES `service_level_i18n` WRITE;
/*!40000 ALTER TABLE `service_level_i18n` DISABLE KEYS */;
INSERT INTO `service_level_i18n` VALUES (1,'2017-01-24 08:35:36',NULL,NULL,1,1,'Basic SLA'),(2,'2017-01-24 08:36:30',NULL,NULL,1,2,'Базовий рівень сервісу');
/*!40000 ALTER TABLE `service_level_i18n` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `service_price`
--

DROP TABLE IF EXISTS `service_price`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `service_price` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `service_type_id` int(10) unsigned NOT NULL,
  `service_level_id` int(10) unsigned NOT NULL,
  `period_id` int(10) unsigned NOT NULL,
  `price` decimal(10,4) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `service_type_id` (`service_type_id`),
  KEY `service_level_id` (`service_level_id`),
  KEY `period_id` (`period_id`),
  CONSTRAINT `service_price_ibfk_1` FOREIGN KEY (`service_type_id`) REFERENCES `service_type` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `service_price_ibfk_2` FOREIGN KEY (`service_level_id`) REFERENCES `service_level` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `service_price_ibfk_3` FOREIGN KEY (`period_id`) REFERENCES `period` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_price`
--

LOCK TABLES `service_price` WRITE;
/*!40000 ALTER TABLE `service_price` DISABLE KEYS */;
INSERT INTO `service_price` VALUES (1,'2017-01-24 09:10:05',NULL,NULL,1,1,1,2.0000),(2,'2017-01-24 09:10:05',NULL,NULL,2,1,1,10.0000),(3,'2017-01-24 09:10:05',NULL,NULL,3,1,1,0.1000),(4,'2017-01-24 09:10:05',NULL,NULL,4,1,5,24.0000),(5,'2017-01-24 09:10:05',NULL,NULL,5,1,5,48.0000),(6,'2017-01-24 09:10:05',NULL,NULL,6,1,5,96.0000);
/*!40000 ALTER TABLE `service_price` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `service_type`
--

DROP TABLE IF EXISTS `service_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `service_type` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `service_group_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `service_group_id` (`service_group_id`) USING BTREE,
  CONSTRAINT `service_type_ibfk_1` FOREIGN KEY (`service_group_id`) REFERENCES `service_group` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_type`
--

LOCK TABLES `service_type` WRITE;
/*!40000 ALTER TABLE `service_type` DISABLE KEYS */;
INSERT INTO `service_type` VALUES (1,'2017-01-24 08:37:03',NULL,NULL,1),(2,'2017-01-24 08:37:03',NULL,NULL,1),(3,'2017-01-24 08:37:03',NULL,NULL,1),(4,'2017-01-24 08:37:03',NULL,NULL,2),(5,'2017-01-24 08:37:03',NULL,NULL,2),(6,'2017-01-24 08:37:03',NULL,NULL,2);
/*!40000 ALTER TABLE `service_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `service_type_i18n`
--

DROP TABLE IF EXISTS `service_type_i18n`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `service_type_i18n` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `service_type_id` int(10) unsigned NOT NULL,
  `language_id` int(10) unsigned NOT NULL,
  `name` varchar(127) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `service_type_id` (`service_type_id`),
  KEY `language_id` (`language_id`),
  CONSTRAINT `service_type_i18n_ibfk_1` FOREIGN KEY (`service_type_id`) REFERENCES `service_type` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `service_type_i18n_ibfk_2` FOREIGN KEY (`language_id`) REFERENCES `language` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_type_i18n`
--

LOCK TABLES `service_type_i18n` WRITE;
/*!40000 ALTER TABLE `service_type_i18n` DISABLE KEYS */;
INSERT INTO `service_type_i18n` VALUES (1,'2017-01-24 08:40:32',NULL,NULL,1,1,'CPU Cores'),(2,'2017-01-24 08:40:32',NULL,NULL,1,2,'Ядра центрального процессору'),(3,'2017-01-24 08:40:32',NULL,NULL,2,1,'RAM Size'),(4,'2017-01-24 08:40:32',NULL,NULL,2,2,'Обсяг оперативного запам\'ятовуючого пристрою'),(5,'2017-01-24 08:41:45',NULL,NULL,3,1,'SSD Size'),(6,'2017-01-24 08:41:45',NULL,NULL,3,2,'Обсяг постійного запам\'ятовуючого пристрою'),(7,'2017-01-24 08:43:56',NULL,NULL,4,1,'TuchaHosting-2'),(8,'2017-01-24 08:43:56',NULL,NULL,4,2,'TuchaHosting-2'),(9,'2017-01-24 08:43:56',NULL,NULL,5,1,'TuchaHosting-10'),(10,'2017-01-24 08:43:56',NULL,NULL,5,2,'TuchaHosting-10'),(11,'2017-01-24 08:43:56',NULL,NULL,6,1,'TuchaHosting-25'),(12,'2017-01-24 08:43:56',NULL,NULL,6,2,'TuchaHosting-25');
/*!40000 ALTER TABLE `service_type_i18n` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `writeoff`
--

DROP TABLE IF EXISTS `writeoff`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `writeoff` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `provider_contractor_id` int(10) unsigned NOT NULL,
  `client_contractor_id` int(10) unsigned NOT NULL,
  `currency_id` int(10) unsigned NOT NULL,
  `sum` double NOT NULL,
  `provisioning_obligation_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `provider_contractor_id` (`provider_contractor_id`),
  KEY `client_contractor_id` (`client_contractor_id`),
  KEY `currency_id` (`currency_id`),
  KEY `provisioning_obligation_id` (`provisioning_obligation_id`),
  CONSTRAINT `writeoff_ibfk_1` FOREIGN KEY (`provider_contractor_id`) REFERENCES `contractor` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `writeoff_ibfk_2` FOREIGN KEY (`client_contractor_id`) REFERENCES `contractor` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `writeoff_ibfk_3` FOREIGN KEY (`currency_id`) REFERENCES `country` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `writeoff_ibfk_4` FOREIGN KEY (`provisioning_obligation_id`) REFERENCES `provisioning_obligation` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `writeoff`
--

LOCK TABLES `writeoff` WRITE;
/*!40000 ALTER TABLE `writeoff` DISABLE KEYS */;
/*!40000 ALTER TABLE `writeoff` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2017-05-15  6:42:51
