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
  `valid_from` datetime DEFAULT NULL,
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
  `valid_from` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `contractor_type_id` int(10) unsigned NOT NULL,
  `provider` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `name` (`name`) USING BTREE,
  KEY `contractor_type_id` (`contractor_type_id`),
  CONSTRAINT `contractor_ibfk_1` FOREIGN KEY (`contractor_type_id`) REFERENCES `contractor_type` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=773 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contractor`
--

LOCK TABLES `contractor` WRITE;
/*!40000 ALTER TABLE `contractor` DISABLE KEYS */;
INSERT INTO `contractor` VALUES (1,'2017-01-24 07:08:00',NULL,NULL,'ХМАРА',3,1),(2,'2017-01-24 07:08:00',NULL,NULL,'АПТАЙМ',3,1),(3,'2017-01-24 07:08:12',NULL,NULL,'Сухобок Катерина Володимирівна',2,1),(101,'2017-01-24 06:27:19',NULL,NULL,'ЖУЙСТРОЙІНВЄСТЖЛОБ',3,0),(102,'2017-01-24 06:27:47',NULL,NULL,'Іванов Іван Іванович',1,0),(103,'2017-01-24 06:27:47',NULL,NULL,'АЙНЕНЕ-ТЕЛЕКОМ',3,0),(530,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (201304)',1,0),(531,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (201213)',1,0),(532,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (201310)',1,0),(533,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (201312)',1,0),(534,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (201324)',1,0),(535,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (201333)',1,0),(536,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (201313)',1,0),(537,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (201223)',1,0),(538,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (201227)',1,0),(539,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (201322)',1,0),(540,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (201222)',1,0),(541,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (201305)',1,0),(542,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (201325)',1,0),(543,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (201409)',1,0),(544,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (201408)',1,0),(545,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (201432)',1,0),(546,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (201441)',1,0),(547,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (201457)',1,0),(548,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (201459)',1,0),(549,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (201461)',1,0),(550,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (201460)',1,0),(551,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (201467)',1,0),(552,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (201475)',1,0),(553,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (201484)',1,0),(554,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (201482)',1,0),(555,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20150003)',1,0),(556,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20150027)',1,0),(557,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20150020)',1,0),(558,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20150026)',1,0),(559,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20150025)',1,0),(560,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20150037)',1,0),(561,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20150029)',1,0),(562,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20150041)',1,0),(563,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20150042)',1,0),(564,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20150048)',1,0),(565,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20150046)',1,0),(566,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20150050)',1,0),(567,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20150052)',1,0),(568,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20150053)',1,0),(569,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20150057)',1,0),(570,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20150067)',1,0),(571,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20150058)',1,0),(572,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20150065)',1,0),(573,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20150073)',1,0),(574,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20150075)',1,0),(575,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20150076)',1,0),(576,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20150086)',1,0),(577,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20150088)',1,0),(578,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20150091)',1,0),(579,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20150093)',1,0),(580,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20150095)',1,0),(581,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160003)',1,0),(582,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160016)',1,0),(583,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160022)',1,0),(584,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160023)',1,0),(585,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160026)',1,0),(586,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160036)',1,0),(587,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160029)',1,0),(588,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20150079)',1,0),(589,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160031)',1,0),(590,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160044)',1,0),(591,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160047)',1,0),(592,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160040)',1,0),(593,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160046)',1,0),(594,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160048)',1,0),(595,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160087)',1,0),(596,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160067)',1,0),(597,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160075)',1,0),(598,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160074)',1,0),(599,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160079)',1,0),(600,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160093)',1,0),(601,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20150104)',1,0),(602,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160090)',1,0),(603,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160089)',1,0),(604,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160104)',1,0),(605,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160112)',1,0),(606,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160134)',1,0),(607,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160154)',1,0),(608,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160160)',1,0),(609,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160169)',1,0),(610,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160192)',1,0),(611,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170005)',1,0),(612,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170015)',1,0),(613,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170028)',1,0),(614,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170021)',1,0),(615,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170038)',1,0),(616,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170037)',1,0),(617,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170036)',1,0),(618,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170045)',1,0),(619,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170053)',1,0),(620,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170055)',1,0),(621,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160049)',1,0),(622,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170060)',1,0),(623,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170070)',1,0),(624,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170073)',1,0),(625,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170075)',1,0),(626,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170079)',1,0),(627,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170080)',1,0),(628,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170093)',1,0),(629,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160035)',1,0),(630,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20150101)',1,0),(631,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160068)',1,0),(632,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (201403)',1,0),(633,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160145)',1,0),(634,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160146)',1,0),(635,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160149)',1,0),(636,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160141)',1,0),(637,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160193)',1,0),(638,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160173)',1,0),(639,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160184)',1,0),(640,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160116)',1,0),(641,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160110)',1,0),(642,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160034)',1,0),(643,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160082)',1,0),(644,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160097)',1,0),(645,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160073)',1,0),(646,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160102)',1,0),(647,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (201446)',1,0),(648,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160148)',1,0),(649,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160151)',1,0),(650,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160152)',1,0),(651,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160118)',1,0),(652,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160080)',1,0),(653,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20150051)',1,0),(654,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160099)',1,0),(655,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20150038)',1,0),(656,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170001)',1,0),(657,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160195)',1,0),(658,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170004)',1,0),(659,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170002)',1,0),(660,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170003)',1,0),(661,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160178)',1,0),(662,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160139)',1,0),(663,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170007)',1,0),(664,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170008)',1,0),(665,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (201224)',1,0),(666,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160028)',1,0),(667,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160108)',1,0),(668,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160128)',1,0),(669,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160130)',1,0),(670,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160135)',1,0),(671,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160137)',1,0),(672,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160142)',1,0),(673,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160174)',1,0),(674,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170020)',1,0),(675,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170014)',1,0),(676,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160157)',1,0),(677,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170025)',1,0),(678,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160119)',1,0),(679,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170016)',1,0),(680,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170017)',1,0),(681,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170009)',1,0),(682,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160175)',1,0),(683,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (201483)',1,0),(684,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (201435)',1,0),(685,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160053)',1,0),(686,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160072)',1,0),(687,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160041)',1,0),(688,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170029)',1,0),(689,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170031)',1,0),(690,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160155)',1,0),(691,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160159)',1,0),(692,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160136)',1,0),(693,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160156)',1,0),(694,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160165)',1,0),(695,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160172)',1,0),(696,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160177)',1,0),(697,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160179)',1,0),(698,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160170)',1,0),(699,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160176)',1,0),(700,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (201315)',1,0),(701,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160183)',1,0),(702,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (201330)',1,0),(703,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160171)',1,0),(704,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160013)',1,0),(705,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20150089)',1,0),(706,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (201404)',1,0),(707,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170039)',1,0),(708,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20150085)',1,0),(709,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170034)',1,0),(710,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170032)',1,0),(711,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170041)',1,0),(712,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170048)',1,0),(713,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170061)',1,0),(714,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20160015)',1,0),(715,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170049)',1,0),(716,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170046)',1,0),(717,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170050)',1,0),(718,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170058)',1,0),(719,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20150055)',1,0),(720,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170068)',1,0),(721,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170064)',1,0),(722,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170062)',1,0),(723,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170063)',1,0),(724,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170067)',1,0),(725,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170059)',1,0),(726,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170071)',1,0),(727,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170065)',1,0),(728,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170085)',1,0),(729,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170088)',1,0),(730,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170091)',1,0),(731,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170087)',1,0),(732,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170094)',1,0),(733,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170090)',1,0),(734,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170092)',1,0),(735,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170084)',1,0),(736,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170097)',1,0),(737,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170101)',1,0),(738,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170107)',1,0),(739,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170110)',1,0),(740,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170098)',1,0),(741,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170102)',1,0),(742,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170108)',1,0),(743,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170112)',1,0),(744,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170113)',1,0),(745,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170114)',1,0),(746,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170115)',1,0),(747,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170117)',1,0),(748,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170109)',1,0),(749,'2017-07-12 12:33:00',NULL,NULL,'Default Contractor (20170119)',1,0),(750,'2017-07-24 10:08:29',NULL,NULL,'Default Contractor (20170124)',1,0),(751,'2017-07-24 10:08:29',NULL,NULL,'Default Contractor (20170122)',1,0),(752,'2017-07-24 10:08:29',NULL,NULL,'Default Contractor (20170131)',1,0),(753,'2017-07-24 10:08:29',NULL,NULL,'Default Contractor (20170121)',1,0),(754,'2017-07-24 10:08:29',NULL,NULL,'Default Contractor (20170129)',1,0),(755,'2017-07-25 08:36:33',NULL,NULL,'Default Contractor (20170133)',1,0),(756,'2017-07-25 08:36:33',NULL,NULL,'Default Contractor (20170134)',1,0),(757,'2017-08-09 23:49:42',NULL,NULL,'Default Contractor (20170111)',1,0),(758,'2017-08-09 23:49:42',NULL,NULL,'Default Contractor (20170141)',1,0),(759,'2017-08-09 23:49:42',NULL,NULL,'Default Contractor (20170142)',1,0),(760,'2017-08-09 23:49:42',NULL,NULL,'Default Contractor (20170144)',1,0),(761,'2017-08-09 23:49:42',NULL,NULL,'Default Contractor (20170140)',1,0),(762,'2017-08-09 23:49:42',NULL,NULL,'Default Contractor (20170136)',1,0),(763,'2017-08-09 23:49:42',NULL,NULL,'Default Contractor (20170135)',1,0),(764,'2017-08-09 23:49:42',NULL,NULL,'Default Contractor (20170150)',1,0),(765,'2017-08-09 23:49:42',NULL,NULL,'Default Contractor (20170138)',1,0),(766,'2017-08-09 23:49:42',NULL,NULL,'Default Contractor (20170139)',1,0),(767,'2017-08-09 23:49:42',NULL,NULL,'Default Contractor (20170147)',1,0),(768,'2017-08-09 23:49:42',NULL,NULL,'Default Contractor (20170146)',1,0),(769,'2017-08-09 23:49:42',NULL,NULL,'Default Contractor (20170145)',1,0),(770,'2017-08-09 23:49:42',NULL,NULL,'Default Contractor (20170148)',1,0),(771,'2017-08-09 23:49:42',NULL,NULL,'Default Contractor (20170103)',1,0),(772,'2017-08-09 23:49:42',NULL,NULL,'Default Contractor (20170157)',1,0);
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
  `valid_from` datetime DEFAULT NULL,
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
  `valid_from` datetime DEFAULT NULL,
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
  `valid_from` datetime DEFAULT NULL,
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
  `valid_from` datetime DEFAULT NULL,
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
  `valid_from` datetime DEFAULT NULL,
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
  `valid_from` datetime DEFAULT NULL,
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
  `valid_from` datetime DEFAULT NULL,
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
  `valid_from` datetime DEFAULT NULL,
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
  `valid_from` datetime DEFAULT NULL,
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
  `valid_from` datetime DEFAULT NULL,
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
  `valid_from` datetime DEFAULT NULL,
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
  `valid_from` datetime DEFAULT NULL,
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
  `valid_from` datetime DEFAULT NULL,
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
  `valid_from` datetime DEFAULT NULL,
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
  `valid_from` datetime DEFAULT NULL,
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
  `valid_from` datetime DEFAULT NULL,
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
  `valid_from` datetime DEFAULT NULL,
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
  `valid_from` datetime DEFAULT NULL,
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
  `valid_from` datetime DEFAULT NULL,
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
) ENGINE=InnoDB AUTO_INCREMENT=130 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `person`
--

LOCK TABLES `person` WRITE;
/*!40000 ALTER TABLE `person` DISABLE KEYS */;
INSERT INTO `person` VALUES (1,'2017-01-25 08:50:00',NULL,NULL,'Катерина','','Сухобок',2,'Europe/Kiev',1),(2,'2017-01-25 08:50:00',NULL,NULL,'Volodymyr','','Melnyk',2,'Europe/Kiev',1),(100,'2017-02-08 20:56:22',NULL,NULL,'Иван','','Царевич',1,'Europe/Kiev',1),(125,'2017-04-18 17:42:19',NULL,NULL,'Степан',NULL,'Срака',2,'Europe/Kiev',1),(127,'2017-04-21 13:08:00',NULL,NULL,'Гаврюша',NULL,'Обезьянов',1,'Europe/Kiev',1),(129,'2017-08-14 00:00:00',NULL,NULL,'Андрей',NULL,'Штогаренко',1,'Africa/Abidjan',1);
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
  `valid_from` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `email` varchar(64) NOT NULL,
  `person_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email_uq_key` (`email`),
  KEY `person_id` (`person_id`),
  CONSTRAINT `person_email_ibfk_1` FOREIGN KEY (`person_id`) REFERENCES `person` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `person_email`
--

LOCK TABLES `person_email` WRITE;
/*!40000 ALTER TABLE `person_email` DISABLE KEYS */;
INSERT INTO `person_email` VALUES (2,'2017-01-31 11:28:20',NULL,NULL,'v.melnik@tucha.ua',2),(3,'2017-02-08 20:58:57',NULL,NULL,'ivan.tsarevych@example.org',100),(4,'2017-04-21 12:47:35',NULL,NULL,'vladimir+2017042400@melnik.net.ua',127),(8,'2017-08-14 15:49:04',NULL,NULL,'hotjobs@yandex.ru',129),(9,'2017-08-15 11:20:11',NULL,NULL,'e.sukhobok@uplink.ua',1);
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
  `valid_from` datetime DEFAULT NULL,
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
  `valid_from` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `person_id` int(10) unsigned NOT NULL,
  `password` char(40) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `person_id` (`person_id`),
  CONSTRAINT `person_password_ibfk_1` FOREIGN KEY (`person_id`) REFERENCES `person` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `person_password`
--

LOCK TABLES `person_password` WRITE;
/*!40000 ALTER TABLE `person_password` DISABLE KEYS */;
INSERT INTO `person_password` VALUES (1,'2017-01-25 08:58:42',NULL,NULL,1,'7c222fb2927d828af22f592134e8932480637c0d'),(2,'2017-01-25 08:58:49',NULL,NULL,2,'7c222fb2927d828af22f592134e8932480637c0d'),(3,'2017-02-08 20:56:57',NULL,NULL,100,'7c222fb2927d828af22f592134e8932480637c0d'),(4,'2017-04-21 13:08:54',NULL,NULL,127,'6216f8a75fd5bb3d5f22b6f9958cdede3fc086c2'),(6,'2017-08-14 15:49:05',NULL,NULL,129,'6216f8a75fd5bb3d5f22b6f9958cdede3fc086c2');
/*!40000 ALTER TABLE `person_password` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `person_phone`
--

DROP TABLE IF EXISTS `person_phone`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `person_phone` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `valid_from` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `phone` varchar(64) NOT NULL,
  `validated` datetime DEFAULT NULL,
  `person_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `person_id` (`person_id`),
  KEY `phone` (`phone`) USING BTREE,
  CONSTRAINT `person_phone_ibfk_1` FOREIGN KEY (`person_id`) REFERENCES `person` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `person_phone`
--

LOCK TABLES `person_phone` WRITE;
/*!40000 ALTER TABLE `person_phone` DISABLE KEYS */;
INSERT INTO `person_phone` VALUES (2,NULL,NULL,NULL,'1312421432546',NULL,127),(4,'2017-08-14 15:49:04',NULL,NULL,'1132435464576',NULL,129);
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
  `valid_from` datetime DEFAULT NULL,
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
  CONSTRAINT `person_x_contractor_ibfk_1` FOREIGN KEY (`person_id`) REFERENCES `person` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `person_x_contractor_ibfk_2` FOREIGN KEY (`contractor_id`) REFERENCES `contractor` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `person_x_contractor`
--

LOCK TABLES `person_x_contractor` WRITE;
/*!40000 ALTER TABLE `person_x_contractor` DISABLE KEYS */;
INSERT INTO `person_x_contractor` VALUES (3,'2017-02-08 13:08:03',NULL,NULL,1,3,1,1,1),(6,'2017-02-08 13:08:28',NULL,NULL,2,3,1,1,1),(7,'2017-02-26 19:47:29',NULL,NULL,100,102,0,1,0),(8,'2017-04-19 09:44:28',NULL,NULL,125,103,1,1,1),(15,'2017-02-08 13:07:53',NULL,NULL,1,2,1,1,1),(16,'2017-02-08 13:08:28',NULL,NULL,2,2,1,1,1),(21,'2017-02-08 13:07:05',NULL,NULL,1,1,1,1,1),(22,'2017-02-08 13:08:28',NULL,NULL,2,1,1,1,1),(23,'2017-08-15 18:11:35',NULL,NULL,129,1,0,1,1);
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
  `valid_from` datetime DEFAULT NULL,
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
  CONSTRAINT `person_x_corporation_ibfk_1` FOREIGN KEY (`person_id`) REFERENCES `person` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
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
  `valid_from` datetime DEFAULT NULL,
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
  CONSTRAINT `fk_person_x_partnership_agreement_1` FOREIGN KEY (`person_id`) REFERENCES `person` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
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
-- Table structure for table `person_x_person`
--

DROP TABLE IF EXISTS `person_x_person`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `person_x_person` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_from` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `parent_person_id` int(10) unsigned NOT NULL,
  `child_person_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `parent_person_id` (`parent_person_id`),
  KEY `child_person_id` (`child_person_id`),
  CONSTRAINT `person_x_person_ibfk_1` FOREIGN KEY (`parent_person_id`) REFERENCES `person` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `person_x_person_ibfk_2` FOREIGN KEY (`child_person_id`) REFERENCES `person` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `person_x_person`
--

LOCK TABLES `person_x_person` WRITE;
/*!40000 ALTER TABLE `person_x_person` DISABLE KEYS */;
INSERT INTO `person_x_person` VALUES (3,'2017-08-14 15:49:05',NULL,NULL,2,129);
/*!40000 ALTER TABLE `person_x_person` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `person_x_provisioning_agreement`
--

DROP TABLE IF EXISTS `person_x_provisioning_agreement`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `person_x_provisioning_agreement` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_from` datetime DEFAULT NULL,
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
  CONSTRAINT `person_x_provisioning_agreement_ibfk_1` FOREIGN KEY (`person_id`) REFERENCES `person` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
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
  `valid_from` datetime DEFAULT NULL,
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
  `valid_from` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `provisioning_agreement_id` int(10) unsigned NOT NULL,
  `resource_piece_id` int(10) unsigned DEFAULT NULL,
  `service_type_id` int(10) unsigned NOT NULL,
  `service_level_id` int(10) unsigned NOT NULL,
  `quantity` bigint(20) unsigned NOT NULL,
  `applied_from` datetime DEFAULT NULL,
  `applied_till` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `provisioning_agreement_id` (`provisioning_agreement_id`),
  KEY `service_type_id` (`service_type_id`),
  KEY `service_level_id` (`service_level_id`),
  KEY `resource_piece_id` (`resource_piece_id`),
  CONSTRAINT `provisioning_obligation_ibfk_1` FOREIGN KEY (`provisioning_agreement_id`) REFERENCES `provisioning_agreement` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `provisioning_obligation_ibfk_2` FOREIGN KEY (`service_type_id`) REFERENCES `service_type` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `provisioning_obligation_ibfk_3` FOREIGN KEY (`service_level_id`) REFERENCES `service_level` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `provisioning_obligation_ibfk_4` FOREIGN KEY (`resource_piece_id`) REFERENCES `resource_piece` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `provisioning_obligation`
--

LOCK TABLES `provisioning_obligation` WRITE;
/*!40000 ALTER TABLE `provisioning_obligation` DISABLE KEYS */;
/*!40000 ALTER TABLE `provisioning_obligation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `resource_piece`
--

DROP TABLE IF EXISTS `resource_piece`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `resource_piece` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_from` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `parent_resource_piece_id` int(10) unsigned DEFAULT NULL,
  `resource_type_id` int(10) unsigned NOT NULL,
  `resource_set_id` int(10) unsigned NOT NULL,
  `resource_handle` varchar(127) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `resource_type_id` (`resource_type_id`),
  KEY `resource_host_id` (`resource_set_id`) USING BTREE,
  KEY `parent_resource_piece_id` (`parent_resource_piece_id`),
  CONSTRAINT `resource_piece_ibfk_1` FOREIGN KEY (`resource_type_id`) REFERENCES `resource_type` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `resource_piece_ibfk_2` FOREIGN KEY (`resource_set_id`) REFERENCES `resource_set` (`id`),
  CONSTRAINT `resource_piece_ibfk_3` FOREIGN KEY (`parent_resource_piece_id`) REFERENCES `resource_piece` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `resource_piece`
--

LOCK TABLES `resource_piece` WRITE;
/*!40000 ALTER TABLE `resource_piece` DISABLE KEYS */;
/*!40000 ALTER TABLE `resource_piece` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `resource_set`
--

DROP TABLE IF EXISTS `resource_set`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `resource_set` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_from` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `resource_set`
--

LOCK TABLES `resource_set` WRITE;
/*!40000 ALTER TABLE `resource_set` DISABLE KEYS */;
INSERT INTO `resource_set` VALUES (1,'2017-01-24 08:52:28',NULL,NULL,'CloudStack Tucha.Z1'),(2,'2017-01-24 08:52:28',NULL,NULL,''),(4,'2017-07-07 16:06:51',NULL,NULL,'CloudStack Tucha.Z2');
/*!40000 ALTER TABLE `resource_set` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `resource_type`
--

DROP TABLE IF EXISTS `resource_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `resource_type` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_from` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `parent_resource_type_id` int(10) unsigned DEFAULT NULL,
  `short_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `parent_resource_type_id` (`parent_resource_type_id`),
  CONSTRAINT `resource_type_ibfk_1` FOREIGN KEY (`parent_resource_type_id`) REFERENCES `resource_type` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `resource_type`
--

LOCK TABLES `resource_type` WRITE;
/*!40000 ALTER TABLE `resource_type` DISABLE KEYS */;
INSERT INTO `resource_type` VALUES (1,'2017-01-24 08:52:48',NULL,NULL,NULL,NULL),(2,'2017-01-24 08:52:48',NULL,NULL,NULL,NULL),(3,'2017-07-11 12:58:12',NULL,NULL,NULL,'domain'),(4,'2017-07-11 13:11:26',NULL,NULL,NULL,'account'),(5,'2017-07-15 14:50:00',NULL,NULL,NULL,'vm'),(6,'2017-07-15 17:02:24',NULL,NULL,5,'cpu'),(7,'2017-07-15 17:02:31',NULL,NULL,5,'ram'),(8,'2017-07-26 14:03:38',NULL,NULL,NULL,'volume-a'),(9,'2017-07-26 14:04:12',NULL,NULL,NULL,'ipv4-a');
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
  `valid_from` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `resource_type_id` int(10) unsigned NOT NULL,
  `language_id` int(10) unsigned NOT NULL,
  `name` varchar(127) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `resource_type_id` (`resource_type_id`),
  KEY `language_id` (`language_id`),
  CONSTRAINT `resource_type_i18n_ibfk_2` FOREIGN KEY (`language_id`) REFERENCES `language` (`id`),
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
-- Table structure for table `service_level`
--

DROP TABLE IF EXISTS `service_level`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `service_level` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_from` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `short_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_level`
--

LOCK TABLES `service_level` WRITE;
/*!40000 ALTER TABLE `service_level` DISABLE KEYS */;
INSERT INTO `service_level` VALUES (1,'2017-01-24 08:35:21',NULL,NULL,'basic');
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
  `valid_from` datetime DEFAULT NULL,
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
-- Table structure for table `service_package`
--

DROP TABLE IF EXISTS `service_package`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `service_package` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_from` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `short_name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_package`
--

LOCK TABLES `service_package` WRITE;
/*!40000 ALTER TABLE `service_package` DISABLE KEYS */;
INSERT INTO `service_package` VALUES (1,'2017-07-26 13:03:20',NULL,NULL,'tuchaoffice-5'),(2,'2017-08-01 16:19:19',NULL,NULL,'tuchahost-4');
/*!40000 ALTER TABLE `service_package` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `service_package_set`
--

DROP TABLE IF EXISTS `service_package_set`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `service_package_set` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_from` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `service_package_id` int(10) unsigned NOT NULL,
  `resource_type_id` int(10) unsigned NOT NULL,
  `quantity` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `service_package_id` (`service_package_id`),
  KEY `resource_type_id` (`resource_type_id`),
  CONSTRAINT `service_package_set_ibfk_1` FOREIGN KEY (`service_package_id`) REFERENCES `service_package` (`id`),
  CONSTRAINT `service_package_set_ibfk_2` FOREIGN KEY (`resource_type_id`) REFERENCES `resource_type` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_package_set`
--

LOCK TABLES `service_package_set` WRITE;
/*!40000 ALTER TABLE `service_package_set` DISABLE KEYS */;
INSERT INTO `service_package_set` VALUES (1,'2017-07-26 13:38:06',NULL,NULL,1,7,8192),(2,'2017-07-26 14:01:15',NULL,NULL,1,6,2),(3,'2017-07-26 14:06:42',NULL,NULL,1,8,107374182400),(4,'2017-07-26 14:07:42',NULL,NULL,1,9,1),(6,'2017-08-01 16:19:22',NULL,NULL,2,7,8192),(7,'2017-08-01 16:19:30',NULL,NULL,2,6,4),(8,'2017-08-01 16:20:28',NULL,NULL,2,8,536870912000),(9,'2017-08-01 16:20:34',NULL,NULL,2,9,1);
/*!40000 ALTER TABLE `service_package_set` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `service_price`
--

DROP TABLE IF EXISTS `service_price`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `service_price` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `valid_from` datetime DEFAULT NULL,
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
  `valid_from` datetime DEFAULT NULL,
  `valid_till` datetime DEFAULT NULL,
  `removed` datetime DEFAULT NULL,
  `parent_service_type_id` int(10) unsigned DEFAULT NULL,
  `short_name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `service_group_id` (`parent_service_type_id`) USING BTREE,
  CONSTRAINT `service_type_ibfk_1` FOREIGN KEY (`parent_service_type_id`) REFERENCES `service_type` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_type`
--

LOCK TABLES `service_type` WRITE;
/*!40000 ALTER TABLE `service_type` DISABLE KEYS */;
INSERT INTO `service_type` VALUES (1,'2017-01-01 00:00:00',NULL,NULL,14,'cpu'),(2,'2017-01-01 00:00:00',NULL,NULL,14,'ram'),(3,'2017-01-01 00:00:00',NULL,NULL,14,'vol-a'),(4,'2017-01-01 00:00:00',NULL,NULL,NULL,'tuchahosting-2'),(5,'2017-01-01 00:00:00',NULL,NULL,NULL,'tuchahosting-10'),(6,'2017-01-01 00:00:00',NULL,NULL,NULL,'tuchahosting-25'),(7,'2017-01-01 00:00:00',NULL,NULL,12,'ipv4-a'),(8,'2017-01-01 00:00:00',NULL,NULL,11,'domain'),(9,'2017-01-01 00:00:00',NULL,NULL,11,'account'),(10,'2017-01-01 00:00:00',NULL,NULL,NULL,'vdc'),(11,'2017-01-01 00:00:00',NULL,NULL,10,'group'),(12,'2017-01-01 00:00:00',NULL,NULL,10,'ip'),(13,'2017-01-01 00:00:00',NULL,NULL,10,'element'),(14,'2017-07-15 14:54:25',NULL,NULL,13,'vm');
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
  `valid_from` datetime DEFAULT NULL,
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
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_type_i18n`
--

LOCK TABLES `service_type_i18n` WRITE;
/*!40000 ALTER TABLE `service_type_i18n` DISABLE KEYS */;
INSERT INTO `service_type_i18n` VALUES (1,'2017-01-24 08:40:32',NULL,NULL,1,1,'CPU Cores'),(2,'2017-01-24 08:40:32',NULL,NULL,1,2,'Ядра центрального процессору'),(3,'2017-01-24 08:40:32',NULL,NULL,2,1,'RAM Size'),(4,'2017-01-24 08:40:32',NULL,NULL,2,2,'Обсяг оперативного запам\'ятовуючого пристрою'),(5,'2017-01-24 08:41:45',NULL,NULL,3,1,'SSD Size'),(6,'2017-01-24 08:41:45',NULL,NULL,3,2,'Обсяг постійного запам\'ятовуючого пристрою'),(7,'2017-01-24 08:43:56',NULL,NULL,4,1,'TuchaHosting-2'),(8,'2017-01-24 08:43:56',NULL,NULL,4,2,'TuchaHosting-2'),(9,'2017-01-24 08:43:56',NULL,NULL,5,1,'TuchaHosting-10'),(10,'2017-01-24 08:43:56',NULL,NULL,5,2,'TuchaHosting-10'),(11,'2017-01-24 08:43:56',NULL,NULL,6,1,'TuchaHosting-25'),(12,'2017-01-24 08:43:56',NULL,NULL,6,2,'TuchaHosting-25'),(13,'2017-07-07 16:35:32',NULL,NULL,7,1,'IPv4-addresses (regular)'),(14,'2017-07-07 16:36:09',NULL,NULL,7,2,'IPv4-адреси (звичайні)'),(15,'2017-07-12 13:27:13',NULL,NULL,8,1,'VDC Domain'),(16,'2017-07-12 13:27:13',NULL,NULL,8,2,'Домен у віртуальному центрі обробки даних'),(17,'2017-07-12 13:27:13',NULL,NULL,9,1,'VDC Account'),(18,'2017-07-12 13:27:13',NULL,NULL,9,2,'Обліковий запис у віртуальному центрі обробки даних');
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
  `valid_from` datetime DEFAULT NULL,
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

-- Dump completed on 2017-08-18 13:22:24
