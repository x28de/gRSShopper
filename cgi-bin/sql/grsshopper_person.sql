
--
-- Table structure for table `person`
--
-- Creates admin user (pwd admin) and anonymous user

DROP TABLE IF EXISTS `person`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `person` (
  `person_id` int(15) NOT NULL auto_increment,
  `person_openid` varchar(255) character set utf8 collate utf8_unicode_ci default NULL,
  `person_title` varchar(255) default NULL,
  `person_pref` varchar(14) default NULL,
  `person_name` varchar(255) default NULL,
  `person_status` varchar(5) default NULL,
  `person_mode` varchar(15) default NULL,
  `person_password` varchar(255) NOT NULL default '',
  `person_midm` varchar(255) default NULL,
  `person_description` text,
  `person_email` varchar(255) default NULL,
  `person_eformat` varchar(10) default 'htm',
  `person_html` varchar(255) default NULL,
  `person_weblog` varchar(255) default NULL,
  `person_photo` varchar(255) default NULL,
  `person_xml` varchar(255) default NULL,
  `person_foaf` varchar(255) default NULL,
  `person_street` varchar(255) default NULL,
  `person_city` varchar(40) default NULL,
  `person_province` varchar(40) default NULL,
  `person_country` varchar(20) default NULL,
  `person_home_phone` varchar(15) default NULL,
  `person_work_phone` varchar(20) default NULL,
  `person_fax_phone` varchar(15) default NULL,
  `person_organization` varchar(255) default NULL,
  `person_remember` varchar(5) default 'yes',
  `person_showreal` varchar(5) default 'yes',
  `person_showemail` varchar(5) default 'yes',
  `person_showuser` varchar(5) default 'yes',
  `person_showpage` varchar(5) default 'yes',
  `person_crdate` int(15) default NULL,
  `show_pref` varchar(4) default 'show',
  `show_name` varchar(4) default 'show',
  `show_html` varchar(4) default 'show',
  `show_weblog` varchar(4) default 'show',
  `show_photo` varchar(4) default 'show',
  `show_email` varchar(4) default 'hide',
  `person_lastread` int(15) default '0',
  PRIMARY KEY  (`person_id`),
  UNIQUE KEY `person_id` (`person_id`,`person_title`,`person_email`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `person`
--
-- WHERE:  TRUE ORDER BY person_id

LOCK TABLES `person` WRITE;
/*!40000 ALTER TABLE `person` DISABLE KEYS */;
INSERT INTO `person` VALUES (1,NULL,'admin',NULL,NULL,'admin','1341531238','SpgG/w3N00gQA',NULL,NULL,'admin@http://course.downes.ca/','htm',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'yes','yes','yes','yes','yes',NULL,'show','show','show','show','show','hide',0),(2,NULL,'anymouse',NULL,NULL,NULL,NULL,'anon',NULL,NULL,'anymouse@http://course.downes.ca/','htm',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'yes','yes','yes','yes','yes',NULL,'show','show','show','show','show','hide',0);
/*!40000 ALTER TABLE `person` ENABLE KEYS */;
UNLOCK TABLES;


