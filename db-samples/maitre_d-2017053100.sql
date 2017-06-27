-- MySQL dump 10.13  Distrib 5.5.54, for Linux (x86_64)
--
-- Host: localhost    Database: maitre_d
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
-- Current Database: `maitre_d`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `maitre_d` /*!40100 DEFAULT CHARACTER SET latin1 */;

USE `maitre_d`;

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
-- Table structure for table `message`
--

DROP TABLE IF EXISTS `message`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `message` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `type` enum('INFO','WARNING','ERROR') NOT NULL,
  `subject` varchar(128) DEFAULT NULL,
  `text` varchar(1024) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=128 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `message`
--

LOCK TABLES `message` WRITE;
/*!40000 ALTER TABLE `message` DISABLE KEYS */;
INSERT INTO `message` VALUES (1,'2017-04-01 23:35:41',NULL,NULL,'ERROR','Залупа','А ебись то-ты конём!'),(2,'2017-04-01 23:42:35',NULL,NULL,'WARNING','Ебашит нормально','Внимание!'),(3,'2017-04-01 23:42:35',NULL,NULL,'INFO','Кстати...','До чего же пиздатый денёк!'),(17,'2017-04-02 01:02:30',NULL,NULL,'ERROR','Authentication Error','The email isn\'t registered'),(18,'2017-04-02 01:02:34',NULL,NULL,'ERROR','Authentication Error','The email isn\'t registered'),(19,'2017-04-02 01:02:56',NULL,NULL,'ERROR','Authentication Error','The email isn\'t registered'),(20,'2017-04-02 01:04:17',NULL,NULL,'ERROR','Authentication Error','The email isn\'t registered'),(21,'2017-04-02 01:04:34',NULL,NULL,'ERROR','Authentication Error','The email isn\'t registered'),(22,'2017-04-02 01:08:58',NULL,NULL,'ERROR','Authentication Error','The email isn\'t registered'),(23,'2017-04-02 01:14:27',NULL,NULL,'ERROR','Authentication Error','The email isn\'t registered'),(24,'2017-04-02 01:14:30',NULL,NULL,'ERROR','Authentication Error','The email isn\'t registered'),(25,'2017-04-02 01:20:46',NULL,NULL,'ERROR','Authentication Error','The email isn\'t registered'),(26,'2017-04-02 01:21:49',NULL,NULL,'ERROR','Authentication Error','The email isn\'t registered'),(27,'2017-04-02 01:21:49',NULL,NULL,'ERROR','Authentication Error','The email isn\'t registered'),(28,'2017-04-02 01:22:03',NULL,NULL,'ERROR','Authentication Error','The email isn\'t registered'),(29,'2017-04-02 01:22:03',NULL,NULL,'INFO','Authentication Error','The email isn\'t registered'),(30,'2017-04-02 01:22:42',NULL,NULL,'ERROR','Authentication Error','The email isn\'t registered'),(31,'2017-04-02 01:22:42',NULL,NULL,'INFO','Authentication Error','The email isn\'t registered'),(32,'2017-04-02 01:23:24',NULL,NULL,'ERROR','Authentication Error','The email isn\'t registered'),(33,'2017-04-02 01:23:24',NULL,NULL,'INFO','Authentication Error','The email isn\'t registered'),(34,'2017-04-02 01:24:08',NULL,NULL,'ERROR','Authentication Error','The email isn\'t registered'),(35,'2017-04-02 01:24:08',NULL,NULL,'INFO','Authentication Error','The email isn\'t registered'),(36,'2017-04-02 01:24:36',NULL,NULL,'ERROR','Authentication Error','The email isn\'t registered'),(37,'2017-04-02 01:24:36',NULL,NULL,'INFO','Authentication Error','The email isn\'t registered'),(38,'2017-04-02 01:24:41',NULL,NULL,'ERROR','Authentication Error','The email isn\'t registered'),(39,'2017-04-02 01:24:41',NULL,NULL,'INFO','Authentication Error','The email isn\'t registered'),(40,'2017-04-02 01:25:12',NULL,NULL,'ERROR','Authentication Error','The email isn\'t registered'),(41,'2017-04-02 01:25:12',NULL,NULL,'INFO','Authentication Error 2','The email isn\'t registered ?'),(42,'2017-04-02 01:31:43',NULL,NULL,'ERROR','Authentication Error','The email isn\'t registered'),(43,'2017-04-02 01:41:01',NULL,NULL,'ERROR','Registration Error','The v.melnik@tucha.ua email is already registered'),(44,'2017-04-02 01:41:16',NULL,NULL,'ERROR','Registration Error','The v.melnik@uplink.ua email is already registered'),(45,'2017-04-02 01:42:09',NULL,NULL,'ERROR','Confirmation Succeess','The person\'s data has been confirmed'),(46,'2017-04-02 01:42:23',NULL,NULL,'ERROR','Confirmation Error','The confirmation token is expired'),(47,'2017-04-02 01:42:26',NULL,NULL,'ERROR','Confirmation Error','The confirmation token is expired'),(48,'2017-04-02 01:43:08',NULL,NULL,'ERROR','Confirmation Error','The confirmation token is expired'),(49,'2017-04-02 01:43:17',NULL,NULL,'ERROR','Confirmation Error','The confirmation token is expired'),(50,'2017-04-02 01:44:01',NULL,NULL,'ERROR','Confirmation Error','The confirmation token is expired'),(51,'2017-04-02 01:44:46',NULL,NULL,'ERROR','Confirmation Error','The confirmation token is expired'),(52,'2017-04-02 02:12:04',NULL,NULL,'ERROR','Confirmation Error','The confirmation token isn\'t found'),(53,'2017-04-02 02:12:31',NULL,NULL,'WARNING','Confirmation Needed','The vladimir+666@melnik.net.ua email needs to be confirmed, the message is sent'),(54,'2017-04-02 02:13:41',NULL,NULL,'WARNING','Confirmation Needed','The vladimir+13@melnik.net.ua email needs to be confirmed, the message is sent'),(55,'2017-04-02 02:13:41',NULL,NULL,'INFO','Confirmation Succeess','The account is activated'),(56,'2017-04-02 02:14:29',NULL,NULL,'ERROR','Confirmation Error','The confirmation token is expired'),(57,'2017-04-02 02:14:32',NULL,NULL,'ERROR','Confirmation Error','The person isn\'t found'),(58,'2017-04-02 02:14:41',NULL,NULL,'ERROR','Confirmation Error','The person isn\'t found'),(59,'2017-04-02 02:15:55',NULL,NULL,'ERROR','Confirmation Error','The person isn\'t found'),(60,'2017-04-02 02:16:43',NULL,NULL,'ERROR','Confirmation Error','The person isn\'t found'),(61,'2017-04-02 02:16:51',NULL,NULL,'ERROR','Confirmation Error','The person isn\'t found 13'),(62,'2017-04-02 02:17:15',NULL,NULL,'ERROR','Confirmation Error','The person is already confirmed'),(63,'2017-04-02 02:23:01',NULL,NULL,'ERROR','Confirmation Error','The confirmation token is expired'),(64,'2017-04-02 02:23:08',NULL,NULL,'ERROR','Confirmation Error','The confirmation token is expired'),(65,'2017-04-02 02:23:25',NULL,NULL,'ERROR','Confirmation Error','The confirmation token is expired'),(66,'2017-04-02 02:23:53',NULL,NULL,'ERROR','Confirmation Error','The confirmation token is expired'),(67,'2017-04-02 02:24:11',NULL,NULL,'ERROR','Confirmation Error','The email is already confirmed'),(68,'2017-04-02 02:24:40',NULL,NULL,'ERROR','Confirmation Error','The confirmation token is expired'),(69,'2017-04-02 02:24:42',NULL,NULL,'ERROR','Confirmation Error','The confirmation token is expired'),(70,'2017-04-02 02:24:43',NULL,NULL,'ERROR','Confirmation Error','The confirmation token is expired'),(71,'2017-04-02 02:29:10',NULL,NULL,'INFO','Confirmation Success','The vladimir+13@melnik.net.ua email is activated'),(72,'2017-04-02 02:30:25',NULL,NULL,'ERROR','Confirmation Error','The confirmation token is expired'),(73,'2017-04-02 02:30:54',NULL,NULL,'WARNING','Confirmation Needed','The vladimir+13666@melnik.net.ua email needs to be confirmed, the message is sent'),(74,'2017-04-02 02:31:12',NULL,NULL,'INFO','Confirmation Success','The vladimir+13666@melnik.net.ua email is activated'),(75,'2017-04-02 02:31:12',NULL,NULL,'WARNING','Confirmation Needed','Some personal data is required'),(76,'2017-04-02 02:31:59',NULL,NULL,'WARNING','Confirmation Needed','The zaloopa@example.org email needs to be confirmed, the message is sent'),(77,'2017-04-02 02:32:00',NULL,NULL,'INFO','Confirmation Success','The account is activated'),(78,'2017-04-02 02:32:24',NULL,NULL,'ERROR','Confirmation Error','The confirmation token is expired'),(79,'2017-04-02 02:33:29',NULL,NULL,'WARNING','Confirmation Needed','The vladimir+66613@melnik.net.ua email needs to be confirmed, the message is sent'),(80,'2017-04-02 02:33:45',NULL,NULL,'INFO','Confirmation Success','The vladimir+66613@melnik.net.ua email is activated'),(81,'2017-04-02 02:33:45',NULL,NULL,'WARNING','Confirmation Needed','Some personal data is required'),(82,'2017-04-02 02:34:22',NULL,NULL,'INFO','Confirmation Success','The account is activated'),(83,'2017-04-02 05:53:23',NULL,NULL,'INFO','Logged Out','We\'ll be happy to see you soon'),(84,'2017-04-02 05:53:35',NULL,NULL,'ERROR','Authentication Error','The password isn\'t correct'),(85,'2017-04-02 05:54:03',NULL,NULL,'INFO','Logged Out','We\'ll be happy to see you soon!'),(86,'2017-04-20 21:55:58',NULL,NULL,'ERROR','Confirmation Error','The confirmation token isn\'t found'),(87,'2017-04-21 11:19:09',NULL,NULL,'ERROR','Confirmation Error','The confirmation token isn\'t found'),(88,'2017-04-21 12:32:54',NULL,NULL,'ERROR','Confirmation Error','The confirmation token isn\'t found'),(89,'2017-04-21 12:33:29',NULL,NULL,'WARNING','Confirmation Needed','The vladimir+2017042400@melnik.net.ua email needs to be confirmed, the message is sent'),(90,'2017-04-21 12:33:54',NULL,NULL,'INFO','Confirmation Success','The vladimir+2017042400@melnik.net.ua email is activated'),(91,'2017-04-21 12:33:54',NULL,NULL,'WARNING','Confirmation Needed','Some personal data is required'),(92,'2017-04-21 12:35:59',NULL,NULL,'ERROR','Confirmation Error','The confirmation token is expired'),(93,'2017-04-21 12:44:14',NULL,NULL,'ERROR','Confirmation Error','The confirmation token is expired'),(94,'2017-04-21 12:44:38',NULL,NULL,'ERROR','Confirmation Error','The email is already confirmed'),(95,'2017-04-21 12:47:06',NULL,NULL,'INFO','Confirmation Success','The vladimir+2017042400@melnik.net.ua email is activated'),(96,'2017-04-21 12:47:06',NULL,NULL,'WARNING','Confirmation Needed','Some personal data needs to be submitted and confirmed'),(97,'2017-04-21 12:47:11',NULL,NULL,'INFO','Confirmation Success','The vladimir+2017042400@melnik.net.ua email is activated'),(98,'2017-04-21 12:47:11',NULL,NULL,'WARNING','Confirmation Needed','Some personal data needs to be submitted and confirmed'),(99,'2017-04-21 12:47:20',NULL,NULL,'INFO','Confirmation Success','The vladimir+2017042400@melnik.net.ua email is activated'),(100,'2017-04-21 12:47:20',NULL,NULL,'WARNING','Confirmation Needed','Some personal data needs to be submitted and confirmed'),(101,'2017-04-21 12:47:25',NULL,NULL,'ERROR','Confirmation Error','The confirmation token isn\'t found'),(102,'2017-04-21 12:47:30',NULL,NULL,'INFO','Confirmation Success','The vladimir+2017042400@melnik.net.ua email is activated'),(103,'2017-04-21 12:47:30',NULL,NULL,'WARNING','Confirmation Needed','Some personal data needs to be submitted and confirmed'),(104,'2017-04-21 12:47:36',NULL,NULL,'INFO','Confirmation Success','The vladimir+2017042400@melnik.net.ua email is activated'),(105,'2017-04-21 12:47:36',NULL,NULL,'WARNING','Confirmation Needed','Some personal data needs to be submitted and confirmed'),(106,'2017-04-21 12:50:08',NULL,NULL,'WARNING','Confirmation Needed','Some personal data needs to be submitted and confirmed'),(107,'2017-04-21 12:50:12',NULL,NULL,'WARNING','Confirmation Needed','Some personal data needs to be submitted and confirmed'),(108,'2017-04-21 12:50:25',NULL,NULL,'WARNING','Confirmation Needed','Some personal data needs to be submitted and confirmed'),(109,'2017-04-21 12:50:44',NULL,NULL,'WARNING','Confirmation Needed','Some personal data needs to be submitted and confirmed'),(110,'2017-04-21 12:51:21',NULL,NULL,'WARNING','Confirmation Needed','Some personal data needs to be submitted and confirmed'),(111,'2017-04-21 12:51:23',NULL,NULL,'WARNING','Confirmation Needed','Some personal data needs to be submitted and confirmed'),(112,'2017-04-21 12:52:44',NULL,NULL,'WARNING','Confirmation Needed','Some personal data needs to be submitted and confirmed'),(113,'2017-04-21 12:52:59',NULL,NULL,'WARNING','Confirmation Needed','Some personal data needs to be submitted and confirmed'),(114,'2017-04-21 12:55:54',NULL,NULL,'WARNING','Confirmation Needed','Some personal data needs to be submitted and confirmed'),(115,'2017-04-21 12:56:08',NULL,NULL,'WARNING','Confirmation Needed','Some personal data needs to be submitted and confirmed'),(116,'2017-04-21 12:56:20',NULL,NULL,'WARNING','Confirmation Needed','Some personal data needs to be submitted and confirmed'),(117,'2017-04-21 13:01:59',NULL,NULL,'WARNING','Confirmation Needed','Some personal data needs to be submitted and confirmed'),(118,'2017-04-21 13:02:12',NULL,NULL,'WARNING','Confirmation Needed','Some personal data needs to be submitted and confirmed'),(119,'2017-04-21 13:02:32',NULL,NULL,'WARNING','Confirmation Needed','Some personal data needs to be submitted and confirmed'),(120,'2017-04-21 13:03:18',NULL,NULL,'WARNING','Confirmation Needed','Some personal data needs to be submitted and confirmed'),(121,'2017-04-21 13:07:29',NULL,NULL,'WARNING','Confirmation Needed','Some personal data needs to be submitted and confirmed'),(122,'2017-04-21 13:08:00',NULL,NULL,'WARNING','Confirmation Needed','Some personal data needs to be submitted and confirmed'),(123,'2017-04-21 13:08:17',NULL,NULL,'WARNING','Confirmation Needed','Some personal data needs to be submitted and confirmed'),(124,'2017-04-21 13:08:19',NULL,NULL,'WARNING','Confirmation Needed','Some personal data needs to be submitted and confirmed'),(125,'2017-04-21 13:08:54',NULL,NULL,'INFO','Confirmation Success','The account is activated'),(126,'2017-04-21 13:09:00',NULL,NULL,'INFO','Confirmation Success','The person is activated already'),(127,'2017-05-08 13:57:09',NULL,NULL,'ERROR','Authentication Error','The password isn\'t correct');
/*!40000 ALTER TABLE `message` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `message_x_session`
--

DROP TABLE IF EXISTS `message_x_session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `message_x_session` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `received` datetime DEFAULT NULL,
  `message_id` int(10) unsigned NOT NULL,
  `session_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `message_id` (`message_id`),
  KEY `session_id` (`session_id`),
  CONSTRAINT `message_x_session_ibfk_1` FOREIGN KEY (`message_id`) REFERENCES `message` (`id`),
  CONSTRAINT `message_x_session_ibfk_2` FOREIGN KEY (`session_id`) REFERENCES `session` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=115 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `message_x_session`
--

LOCK TABLES `message_x_session` WRITE;
/*!40000 ALTER TABLE `message_x_session` DISABLE KEYS */;
INSERT INTO `message_x_session` VALUES (1,'2017-04-01 23:36:41',NULL,NULL,NULL,1,2),(2,'2017-04-01 23:42:51',NULL,NULL,NULL,2,2),(3,'2017-04-01 23:43:04',NULL,NULL,NULL,3,2),(4,'2017-04-02 01:02:30',NULL,NULL,'2017-04-02 01:14:30',17,5),(5,'2017-04-02 01:02:34',NULL,NULL,'2017-04-02 01:14:31',18,5),(6,'2017-04-02 01:02:56',NULL,NULL,'2017-04-02 01:14:31',19,5),(7,'2017-04-02 01:04:17',NULL,NULL,'2017-04-02 01:16:23',20,5),(8,'2017-04-02 01:04:34',NULL,NULL,'2017-04-02 01:14:31',21,5),(9,'2017-04-02 01:08:58',NULL,NULL,'2017-04-02 01:14:30',22,5),(10,'2017-04-02 01:14:27',NULL,NULL,'2017-04-02 01:14:31',23,5),(11,'2017-04-02 01:14:30',NULL,NULL,'2017-04-02 01:14:31',24,5),(12,'2017-04-02 01:20:46',NULL,NULL,'2017-04-02 01:20:47',25,5),(13,'2017-04-02 01:21:49',NULL,NULL,'2017-04-02 01:21:50',26,5),(14,'2017-04-02 01:21:49',NULL,NULL,'2017-04-02 01:21:50',27,5),(15,'2017-04-02 01:22:03',NULL,NULL,'2017-04-02 01:22:04',28,5),(16,'2017-04-02 01:22:03',NULL,NULL,'2017-04-02 01:22:04',29,5),(17,'2017-04-02 01:22:42',NULL,NULL,'2017-04-02 01:22:43',30,5),(18,'2017-04-02 01:22:42',NULL,NULL,'2017-04-02 01:22:43',31,5),(19,'2017-04-02 01:23:24',NULL,NULL,'2017-04-02 01:23:25',32,5),(20,'2017-04-02 01:23:24',NULL,NULL,'2017-04-02 01:23:25',33,5),(21,'2017-04-02 01:24:08',NULL,NULL,'2017-04-02 01:24:09',34,5),(22,'2017-04-02 01:24:08',NULL,NULL,'2017-04-02 01:24:09',35,5),(23,'2017-04-02 01:24:36',NULL,NULL,'2017-04-02 01:24:37',36,5),(24,'2017-04-02 01:24:36',NULL,NULL,'2017-04-02 01:24:37',37,5),(25,'2017-04-02 01:24:41',NULL,NULL,'2017-04-02 01:24:42',38,5),(26,'2017-04-02 01:24:41',NULL,NULL,'2017-04-02 01:24:42',39,5),(27,'2017-04-02 01:25:12',NULL,NULL,'2017-04-02 01:25:13',40,5),(28,'2017-04-02 01:25:12',NULL,NULL,'2017-04-02 01:25:13',41,5),(29,'2017-04-02 01:31:43',NULL,NULL,'2017-04-02 01:31:44',42,5),(30,'2017-04-02 01:41:01',NULL,NULL,'2017-04-02 01:41:02',43,5),(31,'2017-04-02 01:41:16',NULL,NULL,'2017-04-02 01:41:16',44,5),(32,'2017-04-02 01:42:09',NULL,NULL,'2017-04-02 01:42:11',45,5),(33,'2017-04-02 01:42:23',NULL,NULL,'2017-04-02 01:42:24',46,5),(34,'2017-04-02 01:42:26',NULL,NULL,'2017-04-02 01:42:27',47,5),(35,'2017-04-02 01:43:08',NULL,NULL,'2017-04-02 01:43:09',48,5),(36,'2017-04-02 01:43:17',NULL,NULL,'2017-04-02 01:43:18',49,5),(37,'2017-04-02 01:44:01',NULL,NULL,'2017-04-02 01:44:02',50,5),(38,'2017-04-02 01:44:46',NULL,NULL,'2017-04-02 01:44:47',51,5),(39,'2017-04-02 02:12:04',NULL,NULL,'2017-04-02 02:12:05',52,5),(40,'2017-04-02 02:12:31',NULL,NULL,'2017-04-02 02:12:32',53,5),(41,'2017-04-02 02:13:41',NULL,NULL,'2017-04-02 02:13:43',54,5),(42,'2017-04-02 02:13:41',NULL,NULL,'2017-04-02 02:13:43',55,5),(43,'2017-04-02 02:14:29',NULL,NULL,'2017-04-02 02:14:30',56,5),(44,'2017-04-02 02:14:32',NULL,NULL,'2017-04-02 02:14:33',57,5),(45,'2017-04-02 02:14:41',NULL,NULL,'2017-04-02 02:14:42',58,5),(46,'2017-04-02 02:15:55',NULL,NULL,'2017-04-02 02:15:56',59,5),(47,'2017-04-02 02:16:43',NULL,NULL,'2017-04-02 02:16:44',60,5),(48,'2017-04-02 02:16:51',NULL,NULL,'2017-04-02 02:16:52',61,5),(49,'2017-04-02 02:17:15',NULL,NULL,'2017-04-02 02:17:16',62,5),(50,'2017-04-02 02:23:01',NULL,NULL,'2017-04-02 02:23:02',63,5),(51,'2017-04-02 02:23:08',NULL,NULL,'2017-04-02 02:23:09',64,5),(52,'2017-04-02 02:23:25',NULL,NULL,'2017-04-02 02:23:26',65,5),(53,'2017-04-02 02:23:53',NULL,NULL,'2017-04-02 02:23:53',66,5),(54,'2017-04-02 02:24:11',NULL,NULL,'2017-04-02 02:24:12',67,5),(55,'2017-04-02 02:24:40',NULL,NULL,'2017-04-02 02:24:41',68,5),(56,'2017-04-02 02:24:42',NULL,NULL,'2017-04-02 02:24:42',69,5),(57,'2017-04-02 02:24:43',NULL,NULL,'2017-04-02 02:24:44',70,5),(58,'2017-04-02 02:29:10',NULL,NULL,'2017-04-02 02:29:10',71,5),(59,'2017-04-02 02:30:25',NULL,NULL,'2017-04-02 02:30:26',72,5),(60,'2017-04-02 02:30:54',NULL,NULL,'2017-04-02 02:30:55',73,5),(61,'2017-04-02 02:31:12',NULL,NULL,'2017-04-02 02:31:14',74,5),(62,'2017-04-02 02:31:12',NULL,NULL,'2017-04-02 02:31:14',75,5),(63,'2017-04-02 02:31:59',NULL,NULL,'2017-04-02 02:32:00',76,5),(64,'2017-04-02 02:32:00',NULL,NULL,'2017-04-02 02:32:00',77,5),(65,'2017-04-02 02:32:24',NULL,NULL,'2017-04-02 02:32:25',78,5),(66,'2017-04-02 02:33:29',NULL,NULL,'2017-04-02 02:33:30',79,5),(67,'2017-04-02 02:33:45',NULL,NULL,'2017-04-02 02:33:47',80,5),(68,'2017-04-02 02:33:45',NULL,NULL,'2017-04-02 02:33:47',81,5),(69,'2017-04-02 02:34:22',NULL,NULL,'2017-04-02 02:34:24',82,5),(70,'2017-04-02 05:53:23',NULL,NULL,'2017-04-02 05:53:24',83,6),(71,'2017-04-02 05:53:35',NULL,NULL,'2017-04-02 05:53:35',84,6),(72,'2017-04-02 05:54:03',NULL,NULL,'2017-04-02 05:54:11',85,6),(73,'2017-04-20 21:55:58',NULL,NULL,'2017-04-20 21:55:58',86,19),(74,'2017-04-21 11:19:09',NULL,NULL,'2017-04-21 11:19:10',87,20),(75,'2017-04-21 12:32:54',NULL,NULL,'2017-04-21 12:32:55',88,21),(76,'2017-04-21 12:33:29',NULL,NULL,'2017-04-21 12:33:30',89,21),(77,'2017-04-21 12:33:54',NULL,NULL,'2017-04-21 12:33:55',90,21),(78,'2017-04-21 12:33:54',NULL,NULL,'2017-04-21 12:35:59',91,21),(79,'2017-04-21 12:35:59',NULL,NULL,'2017-04-21 12:36:00',92,21),(80,'2017-04-21 12:44:14',NULL,NULL,'2017-04-21 12:44:15',93,21),(81,'2017-04-21 12:44:38',NULL,NULL,'2017-04-21 12:44:38',94,21),(82,'2017-04-21 12:47:06',NULL,NULL,'2017-04-21 12:47:07',95,21),(83,'2017-04-21 12:47:06',NULL,NULL,'2017-04-21 12:47:07',96,21),(84,'2017-04-21 12:47:11',NULL,NULL,'2017-04-21 12:47:11',97,21),(85,'2017-04-21 12:47:11',NULL,NULL,'2017-04-21 12:47:11',98,21),(86,'2017-04-21 12:47:20',NULL,NULL,'2017-04-21 12:47:21',99,21),(87,'2017-04-21 12:47:20',NULL,NULL,'2017-04-21 12:47:21',100,21),(88,'2017-04-21 12:47:25',NULL,NULL,'2017-04-21 12:47:27',101,21),(89,'2017-04-21 12:47:30',NULL,NULL,'2017-04-21 12:47:31',102,21),(90,'2017-04-21 12:47:30',NULL,NULL,'2017-04-21 12:47:31',103,21),(91,'2017-04-21 12:47:36',NULL,NULL,'2017-04-21 12:47:36',104,21),(92,'2017-04-21 12:47:36',NULL,NULL,'2017-04-21 12:47:36',105,21),(93,'2017-04-21 12:50:08',NULL,NULL,'2017-04-21 12:50:09',106,21),(94,'2017-04-21 12:50:12',NULL,NULL,'2017-04-21 12:50:12',107,21),(95,'2017-04-21 12:50:25',NULL,NULL,'2017-04-21 12:50:25',108,21),(96,'2017-04-21 12:50:44',NULL,NULL,'2017-04-21 12:50:45',109,21),(97,'2017-04-21 12:51:21',NULL,NULL,'2017-04-21 12:51:22',110,21),(98,'2017-04-21 12:51:23',NULL,NULL,'2017-04-21 12:56:21',111,21),(99,'2017-04-21 12:52:44',NULL,NULL,'2017-04-21 12:56:21',112,21),(100,'2017-04-21 12:52:59',NULL,NULL,'2017-04-21 12:56:21',113,21),(101,'2017-04-21 12:55:54',NULL,NULL,'2017-04-21 12:56:21',114,21),(102,'2017-04-21 12:56:08',NULL,NULL,'2017-04-21 12:56:21',115,21),(103,'2017-04-21 12:56:20',NULL,NULL,'2017-04-21 12:56:21',116,21),(104,'2017-04-21 13:01:59',NULL,NULL,'2017-04-21 13:02:13',117,21),(105,'2017-04-21 13:02:12',NULL,NULL,'2017-04-21 13:02:13',118,21),(106,'2017-04-21 13:02:32',NULL,NULL,'2017-04-21 13:08:18',119,21),(107,'2017-04-21 13:03:18',NULL,NULL,'2017-04-21 13:08:18',120,21),(108,'2017-04-21 13:07:29',NULL,NULL,'2017-04-21 13:08:18',121,21),(109,'2017-04-21 13:08:00',NULL,NULL,'2017-04-21 13:08:18',122,21),(110,'2017-04-21 13:08:17',NULL,NULL,'2017-04-21 13:08:18',123,21),(111,'2017-04-21 13:08:19',NULL,NULL,'2017-04-21 13:08:19',124,21),(112,'2017-04-21 13:08:54',NULL,NULL,'2017-04-21 13:08:55',125,21),(113,'2017-04-21 13:09:00',NULL,NULL,'2017-04-21 13:09:00',126,21),(114,'2017-05-08 13:57:09',NULL,NULL,'2017-05-08 13:57:10',127,65);
/*!40000 ALTER TABLE `message_x_session` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `session`
--

DROP TABLE IF EXISTS `session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `session` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `uuid` varchar(36) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=81 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `session`
--

LOCK TABLES `session` WRITE;
/*!40000 ALTER TABLE `session` DISABLE KEYS */;
INSERT INTO `session` VALUES (1,'2017-04-02 03:30:53','2017-04-02 03:30:53',NULL,'3190a666-16f0-11e7-98df-93d5fdce445a'),(2,'2017-04-02 06:56:00','2017-04-02 06:56:00',NULL,'d8d65580-170c-11e7-bc8b-c9726a2ca02e'),(3,'2017-04-02 12:13:43','2017-04-02 12:13:43',NULL,'3b95006e-1739-11e7-8b00-e222e0ed53fc'),(4,'2017-04-02 12:13:43','2017-04-02 12:13:43',NULL,'3bb9b922-1739-11e7-ab07-da29d586ba70'),(5,'2017-04-02 12:13:44','2017-04-02 12:13:44',NULL,'3bcf4dc8-1739-11e7-af5d-f62d540ca454'),(6,'2017-04-02 16:31:30','2017-04-02 16:31:30',NULL,'3e6ef8e8-175d-11e7-898c-f42b9262776e'),(7,'2017-04-03 00:09:12','2017-04-03 00:09:12',NULL,'4737715e-179d-11e7-988f-ff37270e13b2'),(8,'2017-04-03 00:10:00','2017-04-03 00:10:00',NULL,'635c4dfa-179d-11e7-8d06-8bf79b7215ea'),(9,'2017-04-18 22:57:53','2017-04-18 22:57:53',NULL,'df6e1088-2425-11e7-9b28-89937210058b'),(10,'2017-04-19 02:32:26','2017-04-19 02:32:26',NULL,'d81000d0-2443-11e7-9588-a7c75a19024b'),(11,'2017-04-19 04:38:29','2017-04-19 04:38:29',NULL,'7435c0f6-2455-11e7-9fe8-b5f8025b68f7'),(12,'2017-04-19 18:40:01','2017-04-19 18:40:01',NULL,'03e0e558-24cb-11e7-8bdf-e1f760b7e287'),(13,'2017-04-20 00:42:56','2017-04-20 00:42:56',NULL,'b6487cec-24fd-11e7-b52b-e896579437ee'),(14,'2017-04-20 07:48:18','2017-04-20 07:48:18',NULL,'2309870a-2539-11e7-8b5e-abbcf12f9c44'),(15,'2017-04-20 08:03:01','2017-04-20 08:03:01',NULL,'30f0014e-253b-11e7-83ee-d4a47bf9cd55'),(16,'2017-04-20 09:49:50','2017-04-20 09:49:50',NULL,'1d33f00c-254a-11e7-832b-98655285eb89'),(17,'2017-04-20 21:34:25','2017-04-20 21:34:25',NULL,'8af18b4c-25ac-11e7-9f50-d0e947a856a6'),(18,'2017-04-21 07:28:08','2017-04-21 07:28:08',NULL,'7be4f1ae-25ff-11e7-b779-b9b00f932229'),(19,'2017-04-21 09:44:05','2017-04-21 09:44:05',NULL,'79d34e3e-2612-11e7-8196-b2ba66a52337'),(20,'2017-04-21 23:19:09','2017-04-21 23:19:09',NULL,'56e0f602-2684-11e7-bc9a-b2058f784fe4'),(21,'2017-04-22 00:32:26','2017-04-22 00:32:26',NULL,'9422cae0-268e-11e7-93fb-d0ee5252ceae'),(22,'2017-04-22 00:32:27','2017-04-22 00:32:27',NULL,'94553d22-268e-11e7-b056-a838d3fb7c10'),(23,'2017-04-22 05:39:22','2017-04-22 05:39:22',NULL,'74b47930-26b9-11e7-b79e-cfde02df18da'),(24,'2017-04-25 06:19:01','2017-04-25 06:19:01',NULL,'7d9e1516-291a-11e7-9964-b820227bbfcd'),(25,'2017-04-26 06:29:10','2017-04-26 06:29:10',NULL,'136d6644-29e5-11e7-be3a-a630d9d6b056'),(26,'2017-04-26 08:41:25','2017-04-26 08:41:25',NULL,'9032eed0-29f7-11e7-a500-ec96dcf8e98b'),(27,'2017-04-26 08:41:31','2017-04-26 08:41:31',NULL,'903aa954-29f7-11e7-ad36-ba81d5fbf82b'),(28,'2017-04-26 09:47:49','2017-04-26 09:47:49',NULL,'d34902c8-2a00-11e7-92e5-d5f61201e4d2'),(29,'2017-04-26 14:46:10','2017-04-26 14:46:10',NULL,'8173a208-2a2a-11e7-9ea6-c95d8cdb3164'),(30,'2017-04-26 17:32:08','2017-04-26 17:32:08',NULL,'b0954264-2a41-11e7-9581-bee14e7b84cb'),(31,'2017-04-26 20:27:55','2017-04-26 20:27:55',NULL,'3f6173ba-2a5a-11e7-862f-a3b3d256faba'),(32,'2017-04-26 21:45:02','2017-04-26 21:45:02',NULL,'055b8dd0-2a65-11e7-bcde-ea721beb8958'),(33,'2017-04-26 23:31:30','2017-04-26 23:31:30',NULL,'e807094e-2a73-11e7-ba4b-b482938c5788'),(34,'2017-04-26 23:31:36','2017-04-26 23:31:36',NULL,'e8263cec-2a73-11e7-a262-a56873a26f4d'),(35,'2017-04-27 01:53:09','2017-04-27 01:53:09',NULL,'ae6faa7e-2a87-11e7-a2bf-f3bb39a7a2e5'),(36,'2017-04-27 01:53:09','2017-04-27 01:53:09',NULL,'ae8b4662-2a87-11e7-b1bc-c0e269511f0f'),(37,'2017-04-27 01:53:09','2017-04-27 01:53:09',NULL,'aea2224c-2a87-11e7-b13b-e190c453ae4e'),(38,'2017-04-27 04:20:21','2017-04-27 04:20:21',NULL,'3eeecdb4-2a9c-11e7-9ee4-939c7d5ac54f'),(39,'2017-04-27 06:47:17','2017-04-27 06:47:17',NULL,'c5b38b14-2ab0-11e7-a952-fb5d9e30e87d'),(40,'2017-04-27 17:27:08','2017-04-27 17:27:08',NULL,'407a40c8-2b0a-11e7-926e-ceea950a8f53'),(41,'2017-04-27 17:28:37','2017-04-27 17:28:37',NULL,'75193e88-2b0a-11e7-86f1-b3198eed37ff'),(42,'2017-04-27 17:29:17','2017-04-27 17:29:17',NULL,'8d0a0b62-2b0a-11e7-9e71-fb0a6c1a29d0'),(43,'2017-04-27 18:34:48','2017-04-27 18:34:48',NULL,'9ca0d138-2b13-11e7-a613-a8c70a6f2259'),(44,'2017-04-28 00:10:57','2017-04-28 00:10:57',NULL,'9215ebb6-2b42-11e7-a802-e0760c70156f'),(45,'2017-04-28 02:18:12','2017-04-28 02:18:12',NULL,'591cd858-2b54-11e7-aef2-d431d041aeae'),(46,'2017-04-28 04:13:22','2017-04-28 04:13:22',NULL,'6f51a04e-2b64-11e7-81db-fd9ba2f52ff5'),(47,'2017-04-28 12:02:11','2017-04-28 12:02:11',NULL,'ed7a4e9e-2ba5-11e7-99fd-c116d3ad1853'),(48,'2017-04-29 05:02:20','2017-04-29 05:02:20',NULL,'71089746-2c34-11e7-9432-b9b7682efc20'),(49,'2017-04-29 07:38:27','2017-04-29 07:38:27',NULL,'403d0564-2c4a-11e7-ac13-c6a6a8d1ac9d'),(50,'2017-04-29 09:40:57','2017-04-29 09:40:57',NULL,'5d40092a-2c5b-11e7-8b0f-fe6e41db46c0'),(51,'2017-04-29 12:25:18','2017-04-29 12:25:18',NULL,'52e2160a-2c72-11e7-9a1c-a372529dc595'),(52,'2017-04-29 18:42:32','2017-04-29 18:42:32',NULL,'05eaeedc-2ca7-11e7-9120-b294d3e55b0d'),(53,'2017-04-29 20:55:01','2017-04-29 20:55:01',NULL,'87eaa51e-2cb9-11e7-84b0-f4d36b02c3fb'),(54,'2017-04-29 22:08:16','2017-04-29 22:08:16',NULL,'c60f5916-2cc3-11e7-bacc-a123971db1fe'),(55,'2017-04-29 22:08:21','2017-04-29 22:08:21',NULL,'c635b9da-2cc3-11e7-a3a4-99820f35d0c4'),(56,'2017-04-30 04:51:15','2017-04-30 04:51:15',NULL,'0eee31d8-2cfc-11e7-a81f-b5f06440f501'),(57,'2017-04-30 05:05:07','2017-04-30 05:05:07',NULL,'ff08c31c-2cfd-11e7-8aaa-d85c35ecf2b4'),(58,'2017-04-30 09:34:29','2017-04-30 09:34:29',NULL,'a097e99a-2d23-11e7-b565-b9af745da6b0'),(59,'2017-04-30 12:07:57','2017-04-30 12:07:57',NULL,'11113176-2d39-11e7-af0e-f424af4d4d92'),(60,'2017-04-30 13:57:45','2017-04-30 13:57:45',NULL,'67919f7c-2d48-11e7-9f98-a385a83b428c'),(61,'2017-04-30 14:28:44','2017-04-30 14:28:44',NULL,'bbafdd86-2d4c-11e7-99b0-f6c8202efd8e'),(62,'2017-04-30 16:58:17','2017-04-30 16:58:17',NULL,'a01a650e-2d61-11e7-8dd0-dfb0d8a1a9ef'),(63,'2017-05-08 20:45:46','2017-05-08 20:45:46',NULL,'ba5d6c94-33ca-11e7-9e4b-845db10aa9a3'),(64,'2017-05-08 22:17:30','2017-05-08 22:17:30',NULL,'8b10958a-33d7-11e7-9dcf-aec0cdbd4ca8'),(65,'2017-05-09 01:57:02','2017-05-09 01:57:02',NULL,'369e1526-33f6-11e7-ac15-e2b86ab491ff'),(66,'2017-05-09 04:57:56','2017-05-09 04:57:56',NULL,'7c0e07b0-340f-11e7-b83d-ea3d2f637b2b'),(67,'2017-05-09 12:58:11','2017-05-09 12:58:11',NULL,'aad5392c-3452-11e7-8947-db9abddaf47e'),(68,'2017-05-09 12:58:53','2017-05-09 12:58:53',NULL,'c3ff7bba-3452-11e7-8f23-f3415a8383b2'),(69,'2017-05-10 22:18:02','2017-05-10 22:18:02',NULL,'f3505340-3569-11e7-8b90-9746fac8a9c6'),(70,'2017-05-12 08:53:57','2017-05-12 08:53:57',NULL,'f3c1a6a8-368b-11e7-8e6f-ca4d174cc3d6'),(71,'2017-05-12 17:50:21','2017-05-12 17:50:21',NULL,'e2b86e0a-36d6-11e7-8cf8-e1263a06272a'),(72,'2017-05-13 04:11:40','2017-05-13 04:11:40',NULL,'af38ebca-372d-11e7-8567-f9b99bb4b125'),(73,'2017-05-13 16:17:03','2017-05-13 16:17:03',NULL,'0488c7ac-3793-11e7-aea4-c32520c5bd97'),(74,'2017-05-14 23:25:54','2017-05-14 23:25:54',NULL,'1836d888-3898-11e7-ba4e-ef7c6c3bade4'),(75,'2017-05-14 23:25:55','2017-05-14 23:25:55',NULL,'18616008-3898-11e7-bc41-d521c08d49d0'),(76,'2017-05-14 23:25:55','2017-05-14 23:25:55',NULL,'1869be56-3898-11e7-a881-dd2c666c265b'),(77,'2017-05-14 23:25:55','2017-05-14 23:25:55',NULL,'18732702-3898-11e7-a323-af71afc7e0dc'),(78,'2017-05-15 01:09:25','2017-05-15 01:09:25',NULL,'8e484f30-38a6-11e7-a7b3-99b3fb3332a2'),(79,'2017-05-15 13:26:48','2017-05-15 13:26:48',NULL,'911578a2-390d-11e7-bae0-c0e06124d9b1'),(80,'2017-05-15 15:39:32','2017-05-15 15:39:32',NULL,'1bd0e4c4-3920-11e7-b5be-8b9934e01623');
/*!40000 ALTER TABLE `session` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2017-05-15  6:43:44