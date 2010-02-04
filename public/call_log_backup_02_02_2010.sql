-- MySQL dump 10.11
--
-- Host: localhost    Database: call_log_development
-- ------------------------------------------------------
-- Server version	5.0.67

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
-- Table structure for table `houses`
--

DROP TABLE IF EXISTS `houses`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `houses` (
  `id` int(11) NOT NULL auto_increment,
  `bu_code` int(11) default NULL,
  `name` varchar(255) collate utf8_unicode_ci default NULL,
  `address` varchar(255) collate utf8_unicode_ci default NULL,
  `city` varchar(255) collate utf8_unicode_ci default NULL,
  `state` varchar(255) collate utf8_unicode_ci default NULL,
  `zip` varchar(255) collate utf8_unicode_ci default NULL,
  `phone1` varchar(255) collate utf8_unicode_ci default NULL,
  `phone2` varchar(255) collate utf8_unicode_ci default NULL,
  `fax` varchar(255) collate utf8_unicode_ci default NULL,
  `overview` text collate utf8_unicode_ci,
  `ratio` varchar(255) collate utf8_unicode_ci default NULL,
  `trainings_needed` text collate utf8_unicode_ci,
  `medication_times` text collate utf8_unicode_ci,
  `relief_pay` varchar(255) collate utf8_unicode_ci default NULL,
  `waivers` text collate utf8_unicode_ci,
  `keys` varchar(255) collate utf8_unicode_ci default NULL,
  `schedule_info` text collate utf8_unicode_ci,
  `behavior_plans` text collate utf8_unicode_ci,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `houses`
--

LOCK TABLES `houses` WRITE;
/*!40000 ALTER TABLE `houses` DISABLE KEYS */;
/*!40000 ALTER TABLE `houses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `imports`
--

DROP TABLE IF EXISTS `imports`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `imports` (
  `id` int(11) NOT NULL auto_increment,
  `processed` int(11) default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `csv_file_name` varchar(255) collate utf8_unicode_ci default NULL,
  `csv_content_type` varchar(255) collate utf8_unicode_ci default NULL,
  `csv_file_size` int(11) default NULL,
  `csv_updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `imports`
--

LOCK TABLES `imports` WRITE;
/*!40000 ALTER TABLE `imports` DISABLE KEYS */;
/*!40000 ALTER TABLE `imports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) collate utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `schema_migrations`
--

LOCK TABLES `schema_migrations` WRITE;
/*!40000 ALTER TABLE `schema_migrations` DISABLE KEYS */;
INSERT INTO `schema_migrations` VALUES ('20100123184610'),('20100123185244'),('20100123193718'),('20100123193738'),('20100123205525'),('20100126210427');
/*!40000 ALTER TABLE `schema_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `staffs`
--

DROP TABLE IF EXISTS `staffs`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `staffs` (
  `id` int(11) NOT NULL auto_increment,
  `staff_id` int(11) default NULL,
  `first_name` varchar(255) collate utf8_unicode_ci default NULL,
  `last_name` varchar(255) collate utf8_unicode_ci default NULL,
  `nickname` varchar(255) collate utf8_unicode_ci default NULL,
  `address` varchar(255) collate utf8_unicode_ci default NULL,
  `city` varchar(255) collate utf8_unicode_ci default NULL,
  `state` varchar(255) collate utf8_unicode_ci default NULL,
  `zip` varchar(255) collate utf8_unicode_ci default NULL,
  `gender` varchar(255) collate utf8_unicode_ci default NULL,
  `doh` date default NULL,
  `cell_number` varchar(255) collate utf8_unicode_ci default NULL,
  `home_number` varchar(255) collate utf8_unicode_ci default NULL,
  `agency_staff` tinyint(1) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `staffs`
--

LOCK TABLES `staffs` WRITE;
/*!40000 ALTER TABLE `staffs` DISABLE KEYS */;
/*!40000 ALTER TABLE `staffs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `users` (
  `id` int(11) NOT NULL auto_increment,
  `username` varchar(255) collate utf8_unicode_ci default NULL,
  `email` varchar(255) collate utf8_unicode_ci default NULL,
  `password_hash` varchar(255) collate utf8_unicode_ci default NULL,
  `password_salt` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `role` varchar(255) collate utf8_unicode_ci default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin','benjamin.vogelzang@gordon.edu','c140bb3cfcdb2e4b2d334e3fef67a4db31f27a12','a6040be13c24a0680dd694ee031b32028faa30de',NULL,NULL,'Admin'),(2,'bennne111','bennne111@gmail.com','56679e8ded6e6c013d50cb6ee44f1b0b31c09d08','09a314a9196924b00582890dd628204ea7b60155','2010-02-01 19:05:52','2010-02-01 19:50:50','Admin');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2010-02-02 21:01:02
