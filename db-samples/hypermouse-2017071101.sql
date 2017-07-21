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
) ENGINE=InnoDB AUTO_INCREMENT=530 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contractor`
--

LOCK TABLES `contractor` WRITE;
/*!40000 ALTER TABLE `contractor` DISABLE KEYS */;
INSERT INTO `contractor` VALUES (1,'2017-01-24 07:08:12',NULL,NULL,'ХМАРА',3,1),(2,'2017-01-24 07:08:12',NULL,NULL,'АПТАЙМ',3,1),(3,'2017-01-24 07:08:12',NULL,NULL,'Сухобок Катерина Володимирівна',2,1),(101,'2017-01-24 06:27:19',NULL,NULL,'ЖУЙСТРОЙІНВЄСТЖЛОБ',3,0),(102,'2017-01-24 06:27:47',NULL,NULL,'Іванов Іван Іванович',1,0),(103,'2017-01-24 06:27:47',NULL,NULL,'АЙНЕНЕ-ТЕЛЕКОМ',3,0),(306,'2017-07-06 10:39:33',NULL,NULL,'Default Contractor (201304)',1,0),(307,'2017-07-06 10:39:33',NULL,NULL,'Default Contractor (201213)',1,0),(308,'2017-07-06 10:39:33',NULL,NULL,'Default Contractor (201310)',1,0),(309,'2017-07-06 10:39:33',NULL,NULL,'Default Contractor (201312)',1,0),(310,'2017-07-06 10:39:33',NULL,NULL,'Default Contractor (201324)',1,0),(311,'2017-07-06 10:39:33',NULL,NULL,'Default Contractor (201333)',1,0),(312,'2017-07-06 10:39:34',NULL,NULL,'Default Contractor (201313)',1,0),(313,'2017-07-06 10:39:34',NULL,NULL,'Default Contractor (201223)',1,0),(314,'2017-07-06 10:39:34',NULL,NULL,'Default Contractor (201227)',1,0),(315,'2017-07-06 10:39:34',NULL,NULL,'Default Contractor (201322)',1,0),(316,'2017-07-06 10:39:34',NULL,NULL,'Default Contractor (201222)',1,0),(317,'2017-07-06 10:39:35',NULL,NULL,'Default Contractor (201305)',1,0),(318,'2017-07-06 10:39:35',NULL,NULL,'Default Contractor (201325)',1,0),(319,'2017-07-06 10:39:35',NULL,NULL,'Default Contractor (201409)',1,0),(320,'2017-07-06 10:39:35',NULL,NULL,'Default Contractor (201408)',1,0),(321,'2017-07-06 10:39:35',NULL,NULL,'Default Contractor (201432)',1,0),(322,'2017-07-06 10:39:35',NULL,NULL,'Default Contractor (201441)',1,0),(323,'2017-07-06 10:39:35',NULL,NULL,'Default Contractor (201457)',1,0),(324,'2017-07-06 10:39:35',NULL,NULL,'Default Contractor (201459)',1,0),(325,'2017-07-06 10:39:35',NULL,NULL,'Default Contractor (201461)',1,0),(326,'2017-07-06 10:39:36',NULL,NULL,'Default Contractor (201460)',1,0),(327,'2017-07-06 10:39:36',NULL,NULL,'Default Contractor (201467)',1,0),(328,'2017-07-06 10:39:36',NULL,NULL,'Default Contractor (201475)',1,0),(329,'2017-07-06 10:39:36',NULL,NULL,'Default Contractor (201484)',1,0),(330,'2017-07-06 10:39:36',NULL,NULL,'Default Contractor (201482)',1,0),(331,'2017-07-06 10:39:36',NULL,NULL,'Default Contractor (20150003)',1,0),(332,'2017-07-06 10:39:36',NULL,NULL,'Default Contractor (20150027)',1,0),(333,'2017-07-06 10:39:37',NULL,NULL,'Default Contractor (20150020)',1,0),(334,'2017-07-06 10:39:37',NULL,NULL,'Default Contractor (20150026)',1,0),(335,'2017-07-06 10:39:37',NULL,NULL,'Default Contractor (20150025)',1,0),(336,'2017-07-06 10:39:37',NULL,NULL,'Default Contractor (20150037)',1,0),(337,'2017-07-06 10:39:37',NULL,NULL,'Default Contractor (20150029)',1,0),(338,'2017-07-06 10:39:37',NULL,NULL,'Default Contractor (20150041)',1,0),(339,'2017-07-06 10:39:37',NULL,NULL,'Default Contractor (20150042)',1,0),(340,'2017-07-06 10:39:37',NULL,NULL,'Default Contractor (20150048)',1,0),(341,'2017-07-06 10:39:38',NULL,NULL,'Default Contractor (20150046)',1,0),(342,'2017-07-06 10:39:38',NULL,NULL,'Default Contractor (20150050)',1,0),(343,'2017-07-06 10:39:38',NULL,NULL,'Default Contractor (20150052)',1,0),(344,'2017-07-06 10:39:38',NULL,NULL,'Default Contractor (20150053)',1,0),(345,'2017-07-06 10:39:38',NULL,NULL,'Default Contractor (20150057)',1,0),(346,'2017-07-06 10:39:38',NULL,NULL,'Default Contractor (20150067)',1,0),(347,'2017-07-06 10:39:38',NULL,NULL,'Default Contractor (20150058)',1,0),(348,'2017-07-06 10:39:38',NULL,NULL,'Default Contractor (20150065)',1,0),(349,'2017-07-06 10:39:38',NULL,NULL,'Default Contractor (20150073)',1,0),(350,'2017-07-06 10:39:38',NULL,NULL,'Default Contractor (20150075)',1,0),(351,'2017-07-06 10:39:39',NULL,NULL,'Default Contractor (20150076)',1,0),(352,'2017-07-06 10:39:39',NULL,NULL,'Default Contractor (20150086)',1,0),(353,'2017-07-06 10:39:39',NULL,NULL,'Default Contractor (20150088)',1,0),(354,'2017-07-06 10:39:39',NULL,NULL,'Default Contractor (20150091)',1,0),(355,'2017-07-06 10:39:39',NULL,NULL,'Default Contractor (20150093)',1,0),(356,'2017-07-06 10:39:39',NULL,NULL,'Default Contractor (20150095)',1,0),(357,'2017-07-06 10:39:39',NULL,NULL,'Default Contractor (20160003)',1,0),(358,'2017-07-06 10:39:40',NULL,NULL,'Default Contractor (20160016)',1,0),(359,'2017-07-06 10:39:40',NULL,NULL,'Default Contractor (20160022)',1,0),(360,'2017-07-06 10:39:40',NULL,NULL,'Default Contractor (20160023)',1,0),(361,'2017-07-06 10:39:40',NULL,NULL,'Default Contractor (20160026)',1,0),(362,'2017-07-06 10:39:40',NULL,NULL,'Default Contractor (20160036)',1,0),(363,'2017-07-06 10:39:40',NULL,NULL,'Default Contractor (20160029)',1,0),(364,'2017-07-06 10:39:40',NULL,NULL,'Default Contractor (20150079)',1,0),(365,'2017-07-06 10:39:40',NULL,NULL,'Default Contractor (20160031)',1,0),(366,'2017-07-06 10:39:40',NULL,NULL,'Default Contractor (20160044)',1,0),(367,'2017-07-06 10:39:41',NULL,NULL,'Default Contractor (20160047)',1,0),(368,'2017-07-06 10:39:41',NULL,NULL,'Default Contractor (20160040)',1,0),(369,'2017-07-06 10:39:41',NULL,NULL,'Default Contractor (20160046)',1,0),(370,'2017-07-06 10:39:41',NULL,NULL,'Default Contractor (20160048)',1,0),(371,'2017-07-06 10:39:41',NULL,NULL,'Default Contractor (20160087)',1,0),(372,'2017-07-06 10:39:41',NULL,NULL,'Default Contractor (20160067)',1,0),(373,'2017-07-06 10:39:41',NULL,NULL,'Default Contractor (20160075)',1,0),(374,'2017-07-06 10:39:41',NULL,NULL,'Default Contractor (20160074)',1,0),(375,'2017-07-06 10:39:41',NULL,NULL,'Default Contractor (20160079)',1,0),(376,'2017-07-06 10:39:42',NULL,NULL,'Default Contractor (20160093)',1,0),(377,'2017-07-06 10:39:42',NULL,NULL,'Default Contractor (20150104)',1,0),(378,'2017-07-06 10:39:42',NULL,NULL,'Default Contractor (20160090)',1,0),(379,'2017-07-06 10:39:42',NULL,NULL,'Default Contractor (20160089)',1,0),(380,'2017-07-06 10:39:42',NULL,NULL,'Default Contractor (20160104)',1,0),(381,'2017-07-06 10:39:42',NULL,NULL,'Default Contractor (20160112)',1,0),(382,'2017-07-06 10:39:42',NULL,NULL,'Default Contractor (20160134)',1,0),(383,'2017-07-06 10:39:42',NULL,NULL,'Default Contractor (20160154)',1,0),(384,'2017-07-06 10:39:42',NULL,NULL,'Default Contractor (20160160)',1,0),(385,'2017-07-06 10:39:43',NULL,NULL,'Default Contractor (20160169)',1,0),(386,'2017-07-06 10:39:43',NULL,NULL,'Default Contractor (20160192)',1,0),(387,'2017-07-06 10:39:43',NULL,NULL,'Default Contractor (20170005)',1,0),(388,'2017-07-06 10:39:43',NULL,NULL,'Default Contractor (20170015)',1,0),(389,'2017-07-06 10:39:43',NULL,NULL,'Default Contractor (20170028)',1,0),(390,'2017-07-06 10:39:43',NULL,NULL,'Default Contractor (20170021)',1,0),(391,'2017-07-06 10:39:43',NULL,NULL,'Default Contractor (20170038)',1,0),(392,'2017-07-06 10:39:43',NULL,NULL,'Default Contractor (20170037)',1,0),(393,'2017-07-06 10:39:44',NULL,NULL,'Default Contractor (20170036)',1,0),(394,'2017-07-06 10:39:44',NULL,NULL,'Default Contractor (20170045)',1,0),(395,'2017-07-06 10:39:44',NULL,NULL,'Default Contractor (20170053)',1,0),(396,'2017-07-06 10:39:44',NULL,NULL,'Default Contractor (20170055)',1,0),(397,'2017-07-06 10:39:44',NULL,NULL,'Default Contractor (20160049)',1,0),(398,'2017-07-06 10:39:44',NULL,NULL,'Default Contractor (20170060)',1,0),(399,'2017-07-06 10:39:44',NULL,NULL,'Default Contractor (20170070)',1,0),(400,'2017-07-06 10:39:44',NULL,NULL,'Default Contractor (20170073)',1,0),(401,'2017-07-06 10:39:45',NULL,NULL,'Default Contractor (20170075)',1,0),(402,'2017-07-06 10:39:45',NULL,NULL,'Default Contractor (20170079)',1,0),(403,'2017-07-06 10:39:45',NULL,NULL,'Default Contractor (20170080)',1,0),(404,'2017-07-06 10:39:45',NULL,NULL,'Default Contractor (20170093)',1,0),(405,'2017-07-06 20:50:41',NULL,NULL,'Default Contractor (20160035)',1,0),(406,'2017-07-06 20:50:46',NULL,NULL,'Default Contractor (20150101)',1,0),(407,'2017-07-06 20:50:54',NULL,NULL,'Default Contractor (20160068)',1,0),(408,'2017-07-06 20:50:55',NULL,NULL,'Default Contractor (201403)',1,0),(409,'2017-07-06 20:50:57',NULL,NULL,'Default Contractor (20160145)',1,0),(410,'2017-07-06 20:50:58',NULL,NULL,'Default Contractor (20160146)',1,0),(411,'2017-07-06 20:51:00',NULL,NULL,'Default Contractor (20160149)',1,0),(412,'2017-07-06 20:51:01',NULL,NULL,'Default Contractor (20160141)',1,0),(413,'2017-07-06 20:51:02',NULL,NULL,'Default Contractor (20160193)',1,0),(414,'2017-07-06 20:51:04',NULL,NULL,'Default Contractor (20160173)',1,0),(415,'2017-07-06 20:51:05',NULL,NULL,'Default Contractor (20160184)',1,0),(416,'2017-07-06 20:51:06',NULL,NULL,'Default Contractor (20160116)',1,0),(417,'2017-07-06 20:51:08',NULL,NULL,'Default Contractor (20160110)',1,0),(418,'2017-07-06 20:51:09',NULL,NULL,'Default Contractor (20160034)',1,0),(419,'2017-07-06 20:51:11',NULL,NULL,'Default Contractor (20160082)',1,0),(420,'2017-07-06 20:51:12',NULL,NULL,'Default Contractor (20160097)',1,0),(421,'2017-07-06 20:51:14',NULL,NULL,'Default Contractor (20160073)',1,0),(422,'2017-07-06 20:51:15',NULL,NULL,'Default Contractor (20160102)',1,0),(423,'2017-07-06 20:51:16',NULL,NULL,'Default Contractor (201446)',1,0),(424,'2017-07-06 20:51:18',NULL,NULL,'Default Contractor (20160148)',1,0),(425,'2017-07-06 20:51:19',NULL,NULL,'Default Contractor (20160151)',1,0),(426,'2017-07-06 20:51:22',NULL,NULL,'Default Contractor (20160152)',1,0),(427,'2017-07-06 20:51:23',NULL,NULL,'Default Contractor (20160118)',1,0),(428,'2017-07-06 20:51:24',NULL,NULL,'Default Contractor (20160080)',1,0),(429,'2017-07-06 20:51:26',NULL,NULL,'Default Contractor (20150051)',1,0),(430,'2017-07-06 20:51:28',NULL,NULL,'Default Contractor (20160099)',1,0),(431,'2017-07-06 20:51:30',NULL,NULL,'Default Contractor (20150038)',1,0),(432,'2017-07-06 20:51:32',NULL,NULL,'Default Contractor (20170001)',1,0),(433,'2017-07-06 20:51:33',NULL,NULL,'Default Contractor (20160195)',1,0),(434,'2017-07-06 20:51:35',NULL,NULL,'Default Contractor (20170004)',1,0),(435,'2017-07-06 20:51:36',NULL,NULL,'Default Contractor (20170002)',1,0),(436,'2017-07-06 20:51:38',NULL,NULL,'Default Contractor (20170003)',1,0),(437,'2017-07-06 20:51:41',NULL,NULL,'Default Contractor (20160178)',1,0),(438,'2017-07-06 20:51:44',NULL,NULL,'Default Contractor (20160139)',1,0),(439,'2017-07-06 20:51:46',NULL,NULL,'Default Contractor (20170007)',1,0),(440,'2017-07-06 20:51:48',NULL,NULL,'Default Contractor (20170008)',1,0),(441,'2017-07-06 20:51:50',NULL,NULL,'Default Contractor (201224)',1,0),(442,'2017-07-06 20:51:51',NULL,NULL,'Default Contractor (20160028)',1,0),(443,'2017-07-06 20:51:53',NULL,NULL,'Default Contractor (20160108)',1,0),(444,'2017-07-06 20:51:54',NULL,NULL,'Default Contractor (20160128)',1,0),(445,'2017-07-06 20:51:56',NULL,NULL,'Default Contractor (20160130)',1,0),(446,'2017-07-06 20:51:58',NULL,NULL,'Default Contractor (20160135)',1,0),(447,'2017-07-06 20:52:01',NULL,NULL,'Default Contractor (20160137)',1,0),(448,'2017-07-06 20:52:04',NULL,NULL,'Default Contractor (20160142)',1,0),(449,'2017-07-06 20:52:05',NULL,NULL,'Default Contractor (20160174)',1,0),(450,'2017-07-06 20:52:09',NULL,NULL,'Default Contractor (20170020)',1,0),(451,'2017-07-06 20:52:11',NULL,NULL,'Default Contractor (20170014)',1,0),(452,'2017-07-06 20:52:13',NULL,NULL,'Default Contractor (20160157)',1,0),(453,'2017-07-06 20:52:16',NULL,NULL,'Default Contractor (20170025)',1,0),(454,'2017-07-06 20:52:18',NULL,NULL,'Default Contractor (20160119)',1,0),(455,'2017-07-06 20:52:20',NULL,NULL,'Default Contractor (20170016)',1,0),(456,'2017-07-06 20:52:22',NULL,NULL,'Default Contractor (20170017)',1,0),(457,'2017-07-06 20:52:24',NULL,NULL,'Default Contractor (20170009)',1,0),(458,'2017-07-06 20:52:26',NULL,NULL,'Default Contractor (20160175)',1,0),(459,'2017-07-06 20:52:27',NULL,NULL,'Default Contractor (201483)',1,0),(460,'2017-07-06 20:52:29',NULL,NULL,'Default Contractor (201435)',1,0),(461,'2017-07-06 20:52:30',NULL,NULL,'Default Contractor (20160053)',1,0),(462,'2017-07-06 20:52:32',NULL,NULL,'Default Contractor (20160072)',1,0),(463,'2017-07-06 20:52:34',NULL,NULL,'Default Contractor (20160041)',1,0),(464,'2017-07-06 20:52:35',NULL,NULL,'Default Contractor (20170029)',1,0),(465,'2017-07-06 20:52:37',NULL,NULL,'Default Contractor (20170031)',1,0),(466,'2017-07-06 20:52:37',NULL,NULL,'Default Contractor (20160155)',1,0),(467,'2017-07-06 20:52:38',NULL,NULL,'Default Contractor (20160159)',1,0),(468,'2017-07-06 20:52:40',NULL,NULL,'Default Contractor (20160136)',1,0),(469,'2017-07-06 20:52:41',NULL,NULL,'Default Contractor (20160156)',1,0),(470,'2017-07-06 20:52:43',NULL,NULL,'Default Contractor (20160165)',1,0),(471,'2017-07-06 20:52:44',NULL,NULL,'Default Contractor (20160172)',1,0),(472,'2017-07-06 20:52:45',NULL,NULL,'Default Contractor (20160177)',1,0),(473,'2017-07-06 20:52:47',NULL,NULL,'Default Contractor (20160179)',1,0),(474,'2017-07-06 20:52:48',NULL,NULL,'Default Contractor (20160170)',1,0),(475,'2017-07-06 20:52:49',NULL,NULL,'Default Contractor (20160176)',1,0),(476,'2017-07-06 20:52:51',NULL,NULL,'Default Contractor (201315)',1,0),(477,'2017-07-06 20:52:52',NULL,NULL,'Default Contractor (20160183)',1,0),(478,'2017-07-06 20:52:53',NULL,NULL,'Default Contractor (201330)',1,0),(479,'2017-07-06 20:52:54',NULL,NULL,'Default Contractor (20160171)',1,0),(480,'2017-07-06 20:52:56',NULL,NULL,'Default Contractor (20160013)',1,0),(481,'2017-07-06 20:52:57',NULL,NULL,'Default Contractor (20160164)',1,0),(482,'2017-07-06 20:52:59',NULL,NULL,'Default Contractor (20150089)',1,0),(483,'2017-07-06 20:53:01',NULL,NULL,'Default Contractor (201466)',1,0),(484,'2017-07-06 20:53:02',NULL,NULL,'Default Contractor (201404)',1,0),(485,'2017-07-06 20:53:08',NULL,NULL,'Default Contractor (20170039)',1,0),(486,'2017-07-06 20:53:10',NULL,NULL,'Default Contractor (20150085)',1,0),(487,'2017-07-06 20:53:13',NULL,NULL,'Default Contractor (20170034)',1,0),(488,'2017-07-06 20:53:15',NULL,NULL,'Default Contractor (20170035)',1,0),(489,'2017-07-06 20:53:16',NULL,NULL,'Default Contractor (20170032)',1,0),(490,'2017-07-06 20:53:17',NULL,NULL,'Default Contractor (20170041)',1,0),(491,'2017-07-06 20:53:18',NULL,NULL,'Default Contractor (20170048)',1,0),(492,'2017-07-06 20:53:23',NULL,NULL,'Default Contractor (20170061)',1,0),(493,'2017-07-06 20:53:25',NULL,NULL,'Default Contractor (20160015)',1,0),(494,'2017-07-06 20:53:26',NULL,NULL,'Default Contractor (20170049)',1,0),(495,'2017-07-06 20:53:27',NULL,NULL,'Default Contractor (20170046)',1,0),(496,'2017-07-06 20:53:28',NULL,NULL,'Default Contractor (20170050)',1,0),(497,'2017-07-06 20:53:30',NULL,NULL,'Default Contractor (20170058)',1,0),(498,'2017-07-06 20:53:32',NULL,NULL,'Default Contractor (20150055)',1,0),(499,'2017-07-06 20:53:33',NULL,NULL,'Default Contractor (20170068)',1,0),(500,'2017-07-06 20:53:34',NULL,NULL,'Default Contractor (20170064)',1,0),(501,'2017-07-06 20:53:36',NULL,NULL,'Default Contractor (20170062)',1,0),(502,'2017-07-06 20:53:41',NULL,NULL,'Default Contractor (20170063)',1,0),(503,'2017-07-06 20:53:42',NULL,NULL,'Default Contractor (20170067)',1,0),(504,'2017-07-06 20:53:46',NULL,NULL,'Default Contractor (20170069)',1,0),(505,'2017-07-06 20:53:48',NULL,NULL,'Default Contractor (20170059)',1,0),(506,'2017-07-06 20:53:49',NULL,NULL,'Default Contractor (20170071)',1,0),(507,'2017-07-06 20:53:50',NULL,NULL,'Default Contractor (20170065)',1,0),(508,'2017-07-06 20:54:32',NULL,NULL,'Default Contractor (20170085)',1,0),(509,'2017-07-06 20:54:34',NULL,NULL,'Default Contractor (20170088)',1,0),(510,'2017-07-06 20:54:36',NULL,NULL,'Default Contractor (20170091)',1,0),(511,'2017-07-06 20:55:13',NULL,NULL,'Default Contractor (20170087)',1,0),(512,'2017-07-06 20:55:14',NULL,NULL,'Default Contractor (20170094)',1,0),(513,'2017-07-06 20:55:38',NULL,NULL,'Default Contractor (20170090)',1,0),(514,'2017-07-06 20:55:41',NULL,NULL,'Default Contractor (20170092)',1,0),(515,'2017-07-06 20:55:44',NULL,NULL,'Default Contractor (20170084)',1,0),(516,'2017-07-06 20:55:49',NULL,NULL,'Default Contractor (20170097)',1,0),(517,'2017-07-06 20:55:54',NULL,NULL,'Default Contractor (20170101)',1,0),(518,'2017-07-06 20:56:14',NULL,NULL,'Default Contractor (20170107)',1,0),(519,'2017-07-06 20:56:16',NULL,NULL,'Default Contractor (20170110)',1,0),(520,'2017-07-06 20:56:18',NULL,NULL,'Default Contractor (20170098)',1,0),(521,'2017-07-06 20:56:22',NULL,NULL,'Default Contractor (20170102)',1,0),(522,'2017-07-06 20:56:24',NULL,NULL,'Default Contractor (20170108)',1,0),(523,'2017-07-06 20:56:49',NULL,NULL,'Default Contractor (20170112)',1,0),(524,'2017-07-06 20:56:53',NULL,NULL,'Default Contractor (20170113)',1,0),(525,'2017-07-06 20:56:56',NULL,NULL,'Default Contractor (20170114)',1,0),(526,'2017-07-06 20:56:58',NULL,NULL,'Default Contractor (20170115)',1,0),(527,'2017-07-06 20:57:00',NULL,NULL,'Default Contractor (20170117)',1,0),(528,'2017-07-06 20:57:02',NULL,NULL,'Default Contractor (20170109)',1,0),(529,'2017-07-08 07:56:29',NULL,NULL,'Default Contractor (20170119)',1,0);
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
) ENGINE=InnoDB AUTO_INCREMENT=430 DEFAULT CHARSET=utf8;
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
  `quantity` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `provisioning_agreement_id` (`provisioning_agreement_id`),
  KEY `service_type_id` (`service_type_id`),
  KEY `service_level_id` (`service_level_id`),
  CONSTRAINT `provisioning_obligation_ibfk_1` FOREIGN KEY (`provisioning_agreement_id`) REFERENCES `provisioning_agreement` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `provisioning_obligation_ibfk_2` FOREIGN KEY (`service_type_id`) REFERENCES `service_type` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `provisioning_obligation_ibfk_3` FOREIGN KEY (`service_level_id`) REFERENCES `service_level` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1889 DEFAULT CHARSET=utf8;
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
) ENGINE=InnoDB AUTO_INCREMENT=1885 DEFAULT CHARSET=utf8;
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
-- Table structure for table `resource_group`
--

DROP TABLE IF EXISTS `resource_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `resource_group` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_since` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `resource_group`
--

LOCK TABLES `resource_group` WRITE;
/*!40000 ALTER TABLE `resource_group` DISABLE KEYS */;
INSERT INTO `resource_group` VALUES (1,'2017-01-24 08:52:28',NULL,NULL,'CloudStack Tucha.Z1'),(2,'2017-01-24 08:52:28',NULL,NULL,''),(4,'2017-07-07 16:06:51',NULL,NULL,'CloudStack Tucha.Z2');
/*!40000 ALTER TABLE `resource_group` ENABLE KEYS */;
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
  `parent_resource_piece_id` int(10) unsigned DEFAULT NULL,
  `resource_type_id` int(10) unsigned NOT NULL,
  `resource_group_id` int(10) unsigned NOT NULL,
  `resource_handle` varchar(127) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `resource_type_id` (`resource_type_id`),
  KEY `resource_host_id` (`resource_group_id`) USING BTREE,
  KEY `parent_resource_piece_id` (`parent_resource_piece_id`),
  CONSTRAINT `resource_piece_ibfk_3` FOREIGN KEY (`parent_resource_piece_id`) REFERENCES `resource_piece` (`id`),
  CONSTRAINT `resource_piece_ibfk_1` FOREIGN KEY (`resource_type_id`) REFERENCES `resource_type` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `resource_piece_ibfk_2` FOREIGN KEY (`resource_group_id`) REFERENCES `resource_group` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=331 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `resource_piece`
--

LOCK TABLES `resource_piece` WRITE;
/*!40000 ALTER TABLE `resource_piece` DISABLE KEYS */;
INSERT INTO `resource_piece` VALUES (1,'2017-01-24 08:55:46',NULL,NULL,NULL,1,1,'dddd8e83-ecdd-4834-9e6b-ad912bf48ef3'),(2,'2017-01-24 08:55:46',NULL,NULL,NULL,1,1,'44fd75f6-8a36-4b76-84f6-7eee403ad39e'),(3,'2017-01-24 08:57:19',NULL,NULL,NULL,2,2,'zaloopa'),(4,'2017-01-24 08:57:19',NULL,NULL,NULL,2,2,'poeben'),(5,'2017-01-24 08:57:19',NULL,NULL,NULL,2,2,'pizdotnya'),(6,'2017-01-24 08:57:19',NULL,NULL,NULL,2,2,'huerga');
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
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `resource_type`
--

LOCK TABLES `resource_type` WRITE;
/*!40000 ALTER TABLE `resource_type` DISABLE KEYS */;
INSERT INTO `resource_type` VALUES (1,'2017-01-24 08:52:48',NULL,NULL),(2,'2017-01-24 08:52:48',NULL,NULL),(3,'2017-07-11 12:58:12',NULL,NULL),(4,'2017-07-11 13:11:26',NULL,NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `resource_type_i18n`
--

LOCK TABLES `resource_type_i18n` WRITE;
/*!40000 ALTER TABLE `resource_type_i18n` DISABLE KEYS */;
INSERT INTO `resource_type_i18n` VALUES (1,'2017-01-24 08:54:22',NULL,NULL,1,1,'Virtual Server'),(2,'2017-01-24 08:54:22',NULL,NULL,1,2,'Віртуальний сервер'),(3,'2017-01-24 08:54:22',NULL,NULL,2,1,'Shared Hosting Account'),(4,'2017-01-24 08:54:22',NULL,NULL,2,2,'Обликовий запис на хостинговому сервері загального користування'),(5,'2017-07-11 12:59:13',NULL,NULL,3,1,'Virtual Data Center Domain'),(6,'2017-07-11 12:59:13',NULL,NULL,3,2,'Домен віртуального центру обробки даних'),(7,'2017-07-11 13:12:20',NULL,NULL,4,1,'Virtual Data Center Account'),(8,'2017-07-11 13:12:20',NULL,NULL,4,2,'Обліковий запис у віртуальному центрі обробки даних');
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
  `short_name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_family`
--

LOCK TABLES `service_family` WRITE;
/*!40000 ALTER TABLE `service_family` DISABLE KEYS */;
INSERT INTO `service_family` VALUES (1,'2017-01-24 08:05:37',NULL,NULL,'vdc'),(2,'2017-01-24 08:05:37',NULL,NULL,'hosting'),(3,'2017-07-07 16:32:19',NULL,NULL,'ip');
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
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_family_i18n`
--

LOCK TABLES `service_family_i18n` WRITE;
/*!40000 ALTER TABLE `service_family_i18n` DISABLE KEYS */;
INSERT INTO `service_family_i18n` VALUES (1,'2017-01-24 08:20:56',NULL,NULL,1,1,'TuchaFlex','Cloud Data Center'),(2,'2017-01-24 08:25:24',NULL,NULL,1,2,'TuchaFlex','Віртуальній центр обробки даних'),(3,'2017-01-24 08:27:35',NULL,NULL,2,1,'TuchaHosting','Shared Hosting'),(4,'2017-01-24 08:27:35',NULL,NULL,2,2,'TuchaHosting','Хостинг на сервері спільного користування'),(5,'2017-07-07 16:32:50',NULL,NULL,3,1,'IP','IP-addresses'),(6,'2017-07-07 16:33:00',NULL,NULL,3,2,'IP','IP-адреси');
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
  `short_name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `service_family_id` (`service_family_id`),
  CONSTRAINT `service_group_ibfk_1` FOREIGN KEY (`service_family_id`) REFERENCES `service_family` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_group`
--

LOCK TABLES `service_group` WRITE;
/*!40000 ALTER TABLE `service_group` DISABLE KEYS */;
INSERT INTO `service_group` VALUES (1,'2017-01-24 08:28:18',NULL,NULL,1,'element'),(2,'2017-01-24 08:28:18',NULL,NULL,2,'plan'),(3,'2017-07-07 16:34:01',NULL,NULL,3,'ip');
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
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_group_i18n`
--

LOCK TABLES `service_group_i18n` WRITE;
/*!40000 ALTER TABLE `service_group_i18n` DISABLE KEYS */;
INSERT INTO `service_group_i18n` VALUES (1,'2017-01-24 08:31:16',NULL,NULL,1,1,'Virtual Machine Element'),(2,'2017-01-24 08:31:16',NULL,NULL,1,2,'Елемент віртуального серверу'),(3,'2017-01-24 08:32:19',NULL,NULL,2,1,'Hosting Plan'),(4,'2017-01-24 08:32:19',NULL,NULL,2,2,'Хостинговий план'),(5,'2017-07-07 16:34:25',NULL,NULL,3,1,'IP-addresses'),(6,'2017-07-07 16:34:32',NULL,NULL,3,2,'IP-адреси');
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
  `short_name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `service_group_id` (`service_group_id`) USING BTREE,
  CONSTRAINT `service_type_ibfk_1` FOREIGN KEY (`service_group_id`) REFERENCES `service_group` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_type`
--

LOCK TABLES `service_type` WRITE;
/*!40000 ALTER TABLE `service_type` DISABLE KEYS */;
INSERT INTO `service_type` VALUES (1,'2017-01-24 08:37:03',NULL,NULL,1,'cpu'),(2,'2017-01-24 08:37:03',NULL,NULL,1,'ram'),(3,'2017-01-24 08:37:03',NULL,NULL,1,'ssd'),(4,'2017-01-24 08:37:03',NULL,NULL,2,'tuchahosting-2'),(5,'2017-01-24 08:37:03',NULL,NULL,2,'tuchahosting-10'),(6,'2017-01-24 08:37:03',NULL,NULL,2,'tuchahosting-25'),(7,'2017-07-07 16:35:14',NULL,NULL,3,'ipv4');
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
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_type_i18n`
--

LOCK TABLES `service_type_i18n` WRITE;
/*!40000 ALTER TABLE `service_type_i18n` DISABLE KEYS */;
INSERT INTO `service_type_i18n` VALUES (1,'2017-01-24 08:40:32',NULL,NULL,1,1,'CPU Cores'),(2,'2017-01-24 08:40:32',NULL,NULL,1,2,'Ядра центрального процессору'),(3,'2017-01-24 08:40:32',NULL,NULL,2,1,'RAM Size'),(4,'2017-01-24 08:40:32',NULL,NULL,2,2,'Обсяг оперативного запам\'ятовуючого пристрою'),(5,'2017-01-24 08:41:45',NULL,NULL,3,1,'SSD Size'),(6,'2017-01-24 08:41:45',NULL,NULL,3,2,'Обсяг постійного запам\'ятовуючого пристрою'),(7,'2017-01-24 08:43:56',NULL,NULL,4,1,'TuchaHosting-2'),(8,'2017-01-24 08:43:56',NULL,NULL,4,2,'TuchaHosting-2'),(9,'2017-01-24 08:43:56',NULL,NULL,5,1,'TuchaHosting-10'),(10,'2017-01-24 08:43:56',NULL,NULL,5,2,'TuchaHosting-10'),(11,'2017-01-24 08:43:56',NULL,NULL,6,1,'TuchaHosting-25'),(12,'2017-01-24 08:43:56',NULL,NULL,6,2,'TuchaHosting-25'),(13,'2017-07-07 16:35:32',NULL,NULL,7,1,'IPv4-addresses (regular)'),(14,'2017-07-07 16:36:09',NULL,NULL,7,2,'IPv4-адреси (звичайні)');
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

-- Dump completed on 2017-07-11 13:17:39
