-- MySQL dump 10.13  Distrib 5.1.73, for redhat-linux-gnu (x86_64)
--
-- Host: localhost    Database: course
-- ------------------------------------------------------
-- Server version	5.1.73

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
-- Table structure for table `optlist`
--

DROP TABLE IF EXISTS `optlist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `optlist` (
  `optlist_id` int(15) NOT NULL AUTO_INCREMENT,
  `optlist_title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `optlist_list` text COLLATE utf8_unicode_ci,
  `optlist_default` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `optlist_type` varchar(24) COLLATE utf8_unicode_ci DEFAULT NULL,
  `optlist_crdate` int(11) DEFAULT NULL,
  `optlist_creator` int(11) DEFAULT NULL,
  `optlist_table` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  `optlist_field` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  `optlist_data` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`optlist_id`)
) ENGINE=MyISAM AUTO_INCREMENT=34 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `optlist`
--
-- WHERE:  TRUE ORDER BY optlist_id

LOCK TABLES `optlist` WRITE;
/*!40000 ALTER TABLE `optlist` DISABLE KEYS */;
INSERT INTO `optlist` VALUES (1,'post_type','Link,link;Article,article;Comment,comment;Musing,musing;Preview,preview;Announcement,announcement;Course,course;shownotes,shownotes','link','select',NULL,NULL,NULL,NULL,'Link,link;Article,article;Comment,comment;Cartoon,Cartoon;Musing,musing;Preview,preview;Announcement,announcement;Course,course;shownotes,shownotes'),(2,'optlist_type','Select,select;Checkbox,checkbox;Radio,radio','select',NULL,1186765283,1,NULL,NULL,'Select,select;Checkbox,checkbox;Radio,radio'),(3,'publication_category','A - Publications in Refereed Journals,A - Publications in Refereed Journals;\r\nB - Publications in Refereed Conference Proceedings,B - Publications in Refereed Conference Proceedings;\r\nC - Publications in Trade Journals,C - Publications in Trade Journals;\r\nD - Publications in Non-refereed Journals or Conferences,D - Publications in Non-refereed Journals or Conferences;\r\nE - Unclassified Reports,E - Unclassified Reports;\r\nF - Classified Reports,F - Classified Reports;\r\nG - Miscellaneous Publications,G - Miscellaneous Publications;\r\nH - Books and Chapters,H - Books and Chapters;\r\nI - Patents,I - Patents;\r\nJ - Presented Papers and Talks,J - Presented Papers and Talks;\r\nK - Industrial Reports,K - Industrial Reports;','A Publications in Refereed Journals','select',1186765622,1,NULL,NULL,NULL),(4,'presentation_type','A Publications in Refereed Journals,A Publications in Refereed Journals;\r\nB Publications in Refereed Conference Proceedings,B Publications in Refereed Conference Proceedings;\r\nC Publications in Trade Journals,C Publications in Trade Journals;\r\nD Publications in Non-refereed Journals or Conferences,D Publications in Non-refereed Journals or Conferences;\r\nE Unclassified Reports,E Unclassified Reports;\r\nF Classified Reports,F Classified Reports;\r\nG Miscellaneous Publications,G Miscellaneous Publications;\r\nH Books and Chapters,H Books and Chapters;\r\nI Patents,I Patents;\r\nJ Presented Papers and Talks,J Presented Papers and Talks;\r\nK Industrial Reports,K Industrial Reports;','J Presented Papers and Talks','select',1186765651,1,NULL,NULL,NULL),(5,'publication_type','Article,article;Column,column;Editorial,editorial;Paper,paper;Review,review;White Paper,white paper;Other,other','article','select',1186766052,1,NULL,NULL,NULL),(6,'presentation_catdetails','Keynote,Keynote;\r\nLecture,Lecture;\r\nSeminar,Seminar;\r\nPanel,Panel;\r\nPoster,Poster;\r\nInterview,Interview;\r\nDebate,Debate\r\n\r\n',NULL,'select',1190396330,1,NULL,NULL,NULL),(7,'presentation_category','J - Presented Papers and Talks,J - Presented Papers and Talks\r\n','J - Presented Papers and Talks','select',1190396479,1,NULL,NULL,NULL),(8,'publication_catdetails','invited,invited;\r\ncontinuing,continuing;\r\nrefereed,refereed;\r\nunrefereed,unrefereed','invited','select',1191769255,1,NULL,NULL,NULL),(9,'feed_type','RSS 0.91,RSS 0.91;RSS 1.0,RSS 1.0;RSS 2.0,RSS 2.0;Atom,Atom;OAI,OAI','RSS 2.0','select',1192551911,1,'feed','type','RSS 0.91,RSS 0.91;RSS 1.0,RSS 1.0;RSS 2.0,RSS 2.0;Atom,Atom;OAI,OAI;JSON,JSON;Twitter,Twitter;Facebook,Facebook;Not Harvesting,Not Harvesting'),(10,'feed_section','Education Blogs,edubloggers;Education News,news---ed;Cyberculture,cyberculture;Media,media;Ideas,ideas;Design,design',NULL,'select',1192552080,1,'feed','section','City,City;Province,Province;Canada,Canada;World,World;Economy,Economy;Entertainment,Entertainment;Sports,Sports;Opinion,Opinion;Videos,Videos'),(11,'page_type','HTML,HTML;RSS,RSS;JS,JS;JSON,JSON;email,email;TEXT,TEXT;CSS,CSS;XML,XML;XSL,XSL','HTML','select',1204027424,1,NULL,NULL,'HTML,HTML;RSS,RSS;JS,JS;JSON,JSON;email,email;TEXT,TEXT;CSS,CSS;XML,XML;XSL,XSL'),(12,'link_type','HTML,HTML;RSS,RSS;argument_analysis,argument_analysis;Twitter,Twitter;link,link;text/html,text/html ','HTML','select',1204032470,1,NULL,NULL,'HTML,HTML;RSS,RSS;argument_analysis,argument_analysis;Twitter,Twitter;link,link;text/html,text/html '),(13,'field_type','text,text;varchar,varchar;int,int;longtext,longtext;file,file;yes-no,yes-no','varchar','select',1228672655,1,NULL,NULL,NULL),(14,'thread_active','On,On;Off,Off','Off','select',1280605467,1,NULL,NULL,NULL),(15,'thread_status','Hidden,Hidden;Active,Active','Hidden','select',1280605504,1,NULL,NULL,NULL),(16,'file_type','Illustration,Illustration;Enclosure,Enclosure',NULL,'select',1281382486,1,NULL,NULL,NULL),(17,'event_type','Keynote,Keynote;\r\nLecture,Lecture;\r\nSeminar,Seminar;\r\nPanel,Panel;\r\nPoster,Poster;\r\nInterview,Interview',NULL,'select',1293384686,1,NULL,NULL,NULL),(18,'media_type','audio,audio;video,video;document,document',NULL,'select',1305297356,1,NULL,NULL,'audio,audio;video,video;image,image;document,document'),(19,'lookup_type','Media;Media',NULL,'select',1305305075,1,NULL,NULL,NULL),(20,'feed_status','Approved,A;On Hold,O;Retired,R',NULL,'select',1309112992,1,NULL,NULL,'Approved,A;On Hold,O;Retired,R'),(21,'feed_class',NULL,NULL,'select',1347647998,1,'feed','class','News,News;Opinion,Opinion;Photo,Photo;Video,Video'),(22,'link_section',NULL,NULL,'select',1348443164,1,'link','section','City,City;Province,Province;Canada,Canada;World,World;Economy,Economy;Entertainment,Entertainment;Sports,Sports;Opinion,Opinion;Videos,Videos'),(23,'link_status',NULL,NULL,'select',1348443379,1,'link','status','Stale,Stale;Fresh,Fresh;Posted,Posted'),(24,'feed_genre',NULL,NULL,'select',1348443951,1,'feed','genre','Blog,Blog;Column,Column;News Media,News Media;Report,Report;Press Release,Press Release;Search,Search;Microcontent,Microcontent;Audio,Audio;Video,Video;Police,Police'),(25,'link_genre',NULL,NULL,'select',1348443970,1,'link','genre','Blog,Blog;Column,Column;News Media,News Media;Report,Report;Press Release,Press Release;Search,Search;Microcontent,Microcontent;Audio,Audio;Video,Video;Police,Police'),(26,'post_genre',NULL,NULL,'select',1348443982,1,'post','genre','Blog,Blog;Column,Column;News Media,News Media;Report,Report;Press Release,Press Release;Search,Search;Microcontent,Microcontent;Audio,Audio;Video,Video;Police,Police'),(27,'post_section',NULL,NULL,'select',1348664661,1,'post','section','City,City;Province,Province;Canada,Canada;World,World;Economy,Economy;Entertainment,Entertainment;Sports,Sports;Opinion,Opinion;Videos,Videos'),(28,'post_class',NULL,NULL,'select',1348664680,1,'post','class','News,News;Opinion,Opinion;Photo,Photo;Video,Video'),(29,'link_class',NULL,NULL,'select',1350515437,1,'link','class','News,News;Opinion,Opinion;Photo,Photo;Video,Video'),(30,'event_section',NULL,NULL,'select',1358275634,1,'event','section','City,City;Province,Province;Canada,Canada;World,World;Economy,Economy;Entertainment,Entertainment;Sports,Sports;Opinion,Opinion;Videos,Videos'),(31,'feed_language',NULL,NULL,'select',1358608595,1,'feed',NULL,'English,English;franÃ§ais,franÃ§ais;Bilingual,Bilingual'),(32,'link_language',NULL,NULL,'select',1358608609,1,'link',NULL,'English,English;franÃ§ais,franÃ§ais;Bilingual,Bilingual'),(33,'post_language',NULL,NULL,'select',1358608623,1,'post',NULL,'English,English;franÃ§ais,franÃ§ais;Bilingual,Bilingual');
/*!40000 ALTER TABLE `optlist` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2017-02-12 14:24:57
