-- MySQL dump 10.13  Distrib 5.1.73, for redhat-linux-gnu (x86_64)
--
-- Host: localhost    Database: downes
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
-- Table structure for table `author`
--

DROP TABLE IF EXISTS `author`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `author` (
  `author_id` int(11) NOT NULL AUTO_INCREMENT,
  `author_link` varchar(255) DEFAULT NULL,
  `author_name` varchar(256) DEFAULT NULL,
  `author_description` text,
  `author_crdate` int(15) DEFAULT NULL,
  `box_test` varchar(250) DEFAULT NULL,
  `author_nickname` varchar(256) DEFAULT NULL,
  `author_twitter` varchar(250) DEFAULT NULL,
  `author_linkedin` varchar(250) DEFAULT NULL,
  `author_delicious` varchar(250) DEFAULT NULL,
  `author_flickr` varchar(250) DEFAULT NULL,
  `author_email` varchar(250) DEFAULT NULL,
  `author_creator` varchar(250) DEFAULT NULL,
  `author_opensocialuserid` varchar(250) DEFAULT NULL,
  `author_person` varchar(250) DEFAULT NULL,
  `author_facebook` varchar(250) DEFAULT NULL,
  `author_socialnet` varchar(250) DEFAULT NULL,
  `event_timezone` varchar(250) DEFAULT NULL,
  `event_duration` varchar(250) DEFAULT NULL,
  `author_url` varchar(250) DEFAULT NULL,
  `author_type` varchar(250) DEFAULT NULL,
  `author_hometown` varchar(256) DEFAULT NULL,
  PRIMARY KEY (`author_id`)
) ENGINE=MyISAM AUTO_INCREMENT=20598 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `banned_sites`
--

DROP TABLE IF EXISTS `banned_sites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `banned_sites` (
  `banned_sites_id` int(15) NOT NULL AUTO_INCREMENT,
  `banned_sites_ip` varchar(30) DEFAULT NULL,
  `banned_sites_crdate` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`banned_sites_id`)
) ENGINE=MyISAM AUTO_INCREMENT=3029 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `box`
--

DROP TABLE IF EXISTS `box`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `box` (
  `box_id` int(15) NOT NULL AUTO_INCREMENT,
  `box_title` varchar(255) DEFAULT NULL,
  `box_description` varchar(255) DEFAULT NULL,
  `box_content` text,
  `box_sub` varchar(5) DEFAULT NULL,
  `box_format` varchar(10) DEFAULT NULL,
  `box_day` varchar(12) DEFAULT NULL,
  `box_creator` varchar(255) DEFAULT NULL,
  `box_crdate` varchar(255) DEFAULT NULL,
  `box_txt_version` int(5) DEFAULT NULL,
  `box_rss_version` int(15) DEFAULT NULL,
  `box_order` int(3) DEFAULT NULL,
  PRIMARY KEY (`box_id`)
) ENGINE=MyISAM AUTO_INCREMENT=47 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `chat`
--

DROP TABLE IF EXISTS `chat`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `chat` (
  `chat_id` int(11) NOT NULL AUTO_INCREMENT,
  `chat_description` text,
  `chat_signature` varchar(255) DEFAULT NULL,
  `chat_shown` int(2) DEFAULT '0',
  `chat_creator` varchar(255) DEFAULT NULL,
  `chat_crip` varchar(24) DEFAULT NULL,
  `chat_crdate` int(15) DEFAULT NULL,
  `chat_thread` varchar(250) DEFAULT NULL,
  `chat_link` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`chat_id`)
) ENGINE=MyISAM AUTO_INCREMENT=4239 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cite`
--

DROP TABLE IF EXISTS `cite`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cite` (
  `cite_id` int(15) NOT NULL AUTO_INCREMENT,
  `cite_cited` varchar(255) DEFAULT NULL,
  `cite_citer` varchar(255) DEFAULT NULL,
  `cite_title` varchar(255) DEFAULT '0',
  `cite_crdate` int(15) DEFAULT NULL,
  `cite_creator` int(15) DEFAULT NULL,
  PRIMARY KEY (`cite_id`)
) ENGINE=MyISAM AUTO_INCREMENT=10389 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `company`
--

DROP TABLE IF EXISTS `company`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `company` (
  `company_id` int(11) NOT NULL AUTO_INCREMENT,
  `company_crdate` int(15) DEFAULT NULL,
  `company_tst` int(2) DEFAULT NULL,
  `company_creator` int(15) DEFAULT NULL,
  `company_title` varchar(256) DEFAULT NULL,
  `company_url` varchar(256) DEFAULT NULL,
  `company_logo` varchar(256) DEFAULT NULL,
  `company_description` text,
  `company_category` varchar(32) DEFAULT NULL,
  `company_acronym` varchar(16) DEFAULT NULL,
  `company_genre` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`company_id`)
) ENGINE=MyISAM AUTO_INCREMENT=104 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `concept`
--

DROP TABLE IF EXISTS `concept`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `concept` (
  `concept_id` int(11) NOT NULL AUTO_INCREMENT,
  `concept_crdate` int(15) DEFAULT NULL,
  `concept_tst` int(2) DEFAULT NULL,
  `concept_creator` int(15) DEFAULT NULL,
  `concept_title` varchar(256) DEFAULT NULL,
  `concept_url` varchar(256) DEFAULT NULL,
  `concept_logo` varchar(256) DEFAULT NULL,
  `concept_description` text,
  `concept_acronym` varchar(16) DEFAULT NULL,
  `concept_genre` varchar(32) DEFAULT NULL,
  `concept_category` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`concept_id`)
) ENGINE=MyISAM AUTO_INCREMENT=175 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `config`
--

DROP TABLE IF EXISTS `config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `config` (
  `config_id` int(5) NOT NULL AUTO_INCREMENT,
  `config_type` varchar(255) DEFAULT NULL,
  `config_noun` varchar(255) DEFAULT NULL,
  `config_verb` varchar(255) DEFAULT NULL,
  `config_value` varchar(511) DEFAULT NULL,
  `config_crdate` varchar(250) DEFAULT NULL,
  KEY `config_id` (`config_id`)
) ENGINE=MyISAM AUTO_INCREMENT=614 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `course`
--

DROP TABLE IF EXISTS `course`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `course` (
  `course_id` int(11) NOT NULL AUTO_INCREMENT,
  `course_crdate` int(15) DEFAULT NULL,
  `course_creator` int(15) DEFAULT NULL,
  `course_title` varchar(256) DEFAULT NULL,
  `course_description` text,
  `course_url` varchar(256) DEFAULT NULL,
  PRIMARY KEY (`course_id`)
) ENGINE=MyISAM AUTO_INCREMENT=117 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `event`
--

DROP TABLE IF EXISTS `event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `event` (
  `event_id` int(15) NOT NULL AUTO_INCREMENT,
  `event_type` varchar(32) DEFAULT NULL,
  `event_title` varchar(255) DEFAULT NULL,
  `event_group` varchar(15) DEFAULT NULL,
  `event_description` text,
  `event_location` varchar(255) DEFAULT NULL,
  `event_start` varchar(255) DEFAULT NULL,
  `event_end` varchar(124) DEFAULT NULL,
  `event_link` varchar(255) DEFAULT NULL,
  `event_crdate` int(15) DEFAULT NULL,
  `event_creator` smallint(15) DEFAULT NULL,
  `test_date` datetime DEFAULT NULL,
  `environment` varchar(250) DEFAULT NULL,
  `event_environment` varchar(250) DEFAULT NULL,
  `event_finish` varchar(255) DEFAULT NULL,
  `event_star` varchar(250) DEFAULT NULL,
  `event_host` varchar(250) DEFAULT NULL,
  `owner_url` varchar(250) DEFAULT NULL,
  `event_sponsor` varchar(250) DEFAULT NULL,
  `event_sponsor_url` varchar(250) DEFAULT NULL,
  `event_access` varchar(250) DEFAULT NULL,
  `event_owner_url` varchar(250) DEFAULT NULL,
  `event_identifier` varchar(250) DEFAULT NULL,
  `event_localtz` varchar(250) DEFAULT NULL,
  `event_icalstart` varchar(250) DEFAULT NULL,
  `event_icalend` varchar(250) DEFAULT NULL,
  `event_feedid` varchar(250) DEFAULT NULL,
  `event_feedname` varchar(250) DEFAULT NULL,
  `event_category` varchar(250) DEFAULT NULL,
  `event_status` varchar(250) DEFAULT NULL,
  `event_duration` varchar(250) DEFAULT NULL,
  `event_timezone` varchar(250) DEFAULT NULL,
  `event_hits` varchar(250) DEFAULT NULL,
  `event_section` varchar(250) DEFAULT NULL,
  `event_total` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`event_id`)
) ENGINE=MyISAM AUTO_INCREMENT=75 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `feed`
--

DROP TABLE IF EXISTS `feed`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `feed` (
  `feed_id` int(15) NOT NULL AUTO_INCREMENT,
  `feed_identifier` text,
  `feed_type` varchar(8) DEFAULT NULL,
  `feed_title` varchar(255) NOT NULL DEFAULT '',
  `feed_description` text,
  `feed_html` varchar(255) DEFAULT NULL,
  `feed_link` varchar(255) DEFAULT NULL,
  `feed_journal` int(15) DEFAULT NULL,
  `feed_author` int(15) DEFAULT NULL,
  `feed_post` varchar(255) DEFAULT NULL,
  `feed_guid` varchar(255) DEFAULT NULL,
  `feed_lastBuildDate` varchar(64) DEFAULT NULL,
  `feed_pubDate` varchar(25) DEFAULT NULL,
  `feed_genname` varchar(24) DEFAULT NULL,
  `feed_genver` varchar(10) DEFAULT NULL,
  `feed_genurl` varchar(255) DEFAULT NULL,
  `feed_creatorname` text,
  `feed_creatorurl` text,
  `feed_creatoremail` text,
  `feed_managingEditor` varchar(255) DEFAULT NULL,
  `feed_webMaster` varchar(255) DEFAULT NULL,
  `feed_publisher` text,
  `feed_category` varchar(127) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT 'category',
  `feed_docs` varchar(255) DEFAULT NULL,
  `feed_version` varchar(10) DEFAULT NULL,
  `feed_rights` varchar(255) DEFAULT NULL,
  `feed_language` varchar(10) DEFAULT NULL,
  `feed_updatePeriod` varchar(20) DEFAULT NULL,
  `feed_updateFrequency` varchar(20) DEFAULT NULL,
  `feed_updateBase` varchar(20) DEFAULT NULL,
  `feed_granularity` varchar(20) DEFAULT NULL,
  `feed_compression` varchar(10) DEFAULT NULL,
  `feed_imgTitle` varchar(255) DEFAULT NULL,
  `feed_imgLink` varchar(255) DEFAULT NULL,
  `feed_imgURL` varchar(255) DEFAULT NULL,
  `feed_imgCreator` varchar(255) DEFAULT NULL,
  `feed_imgheight` int(4) DEFAULT NULL,
  `feed_imgwidth` int(4) DEFAULT NULL,
  `feed_lastharvest` varchar(15) DEFAULT NULL,
  `feed_status` varchar(15) DEFAULT 'O',
  `feed_crdate` int(15) DEFAULT NULL,
  `feed_tagline` varchar(255) DEFAULT NULL,
  `feed_modified` varchar(255) DEFAULT NULL,
  `feed_etag` varchar(255) DEFAULT NULL,
  `feed_updated` varchar(64) DEFAULT NULL,
  `feed_cache` longtext,
  `feed_links` int(15) DEFAULT NULL,
  `feed_country` varchar(5) DEFAULT NULL,
  `feed_add_entry` varchar(255) DEFAULT NULL,
  `feed_as_xml` text,
  `feed_timezone` varchar(250) DEFAULT NULL,
  `feed_feedburnerid` varchar(250) DEFAULT NULL,
  `feed_feedburnerurl` varchar(250) DEFAULT NULL,
  `feed_feedburnerhost` varchar(250) DEFAULT NULL,
  `feed_hub` varchar(250) DEFAULT NULL,
  `feed_OSstartIndex` varchar(250) DEFAULT NULL,
  `feed_OStotalResults` varchar(250) DEFAULT NULL,
  `feed_OSitemsPerPage` varchar(250) DEFAULT NULL,
  `feed_authorname` varchar(250) DEFAULT NULL,
  `feed_explicit` varchar(250) DEFAULT NULL,
  `feed_topic` varchar(250) DEFAULT NULL,
  `feed_rating` varchar(250) DEFAULT NULL,
  `feed_authorurl` varchar(250) DEFAULT NULL,
  `feed_authoremail` varchar(250) DEFAULT NULL,
  `geo_lat` varchar(250) DEFAULT NULL,
  `geo_long` varchar(250) DEFAULT NULL,
  `feed_copyright` varchar(250) DEFAULT NULL,
  `feed_baseurl` varchar(250) DEFAULT NULL,
  `feed_autocats` varchar(250) DEFAULT NULL,
  `feed_blogroll` varchar(250) DEFAULT NULL,
  `feed_keywords` varchar(250) DEFAULT NULL,
  `feed_creator` varchar(250) DEFAULT NULL,
  `feed_genre` varchar(250) DEFAULT NULL,
  `feed_rules` text,
  `feed_section` varchar(250) DEFAULT NULL,
  `feed_issued` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`feed_id`)
) ENGINE=MyISAM AUTO_INCREMENT=7589 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `field`
--

DROP TABLE IF EXISTS `field`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `field` (
  `field_id` int(15) NOT NULL AUTO_INCREMENT,
  `field_title` varchar(128) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `field_type` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `field_size` int(5) DEFAULT NULL,
  `field_other` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `field_crdate` int(15) DEFAULT NULL,
  `field_creator` int(15) DEFAULT NULL,
  PRIMARY KEY (`field_id`)
) ENGINE=MyISAM AUTO_INCREMENT=39 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `file`
--

DROP TABLE IF EXISTS `file`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `file` (
  `file_id` int(15) NOT NULL AUTO_INCREMENT,
  `file_title` varchar(255) DEFAULT NULL,
  `file_file` varchar(255) DEFAULT NULL,
  `file_type` varchar(32) DEFAULT NULL,
  `file_size` int(15) DEFAULT NULL,
  `file_description` text,
  `file_post` int(15) DEFAULT NULL,
  `file_gallery` varchar(32) DEFAULT NULL,
  `file_crdate` int(15) DEFAULT NULL,
  `file_creator` int(15) DEFAULT NULL,
  `file_align` varchar(250) DEFAULT NULL,
  `file_width` varchar(250) DEFAULT NULL,
  `file_dirname` varchar(250) DEFAULT NULL,
  `file_mime` varchar(250) DEFAULT NULL,
  `file_url` varchar(250) DEFAULT NULL,
  `file_link` varchar(250) DEFAULT NULL,
  `file_dir` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`file_id`)
) ENGINE=MyISAM AUTO_INCREMENT=10246 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `form`
--

DROP TABLE IF EXISTS `form`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `form` (
  `form_id` int(11) NOT NULL AUTO_INCREMENT,
  `form_crdate` int(15) DEFAULT NULL,
  `form_creator` varchar(250) DEFAULT NULL,
  `form_data` text,
  `form_edit` tinyint(1) DEFAULT NULL,
  `form_fields` text,
  `form_show` varchar(250) DEFAULT NULL,
  `form_title` varchar(250) DEFAULT NULL,
  `form_view` tinyint(1) DEFAULT NULL,
  `form_commit` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`form_id`)
) ENGINE=MyISAM AUTO_INCREMENT=18 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `graph`
--

DROP TABLE IF EXISTS `graph`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `graph` (
  `graph_id` int(15) NOT NULL AUTO_INCREMENT,
  `graph_type` varchar(64) DEFAULT NULL,
  `graph_typeval` varchar(40) DEFAULT NULL,
  `graph_tableone` varchar(40) DEFAULT NULL,
  `graph_urlone` varchar(256) DEFAULT NULL,
  `graph_idone` varchar(40) DEFAULT NULL,
  `graph_tabletwo` varchar(40) DEFAULT NULL,
  `graph_urltwo` varchar(256) DEFAULT NULL,
  `graph_idtwo` varchar(40) DEFAULT NULL,
  `graph_crdate` varchar(15) DEFAULT NULL,
  `graph_creator` varchar(15) DEFAULT NULL,
  KEY `graph_id` (`graph_id`)
) ENGINE=MyISAM AUTO_INCREMENT=104226 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `institution`
--

DROP TABLE IF EXISTS `institution`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `institution` (
  `institution_id` int(11) NOT NULL AUTO_INCREMENT,
  `institution_crdate` int(15) DEFAULT NULL,
  `institution_tst` int(2) DEFAULT NULL,
  `institution_creator` int(15) DEFAULT NULL,
  `institution_title` varchar(256) DEFAULT NULL,
  `institution_url` varchar(256) DEFAULT NULL,
  `institution_logo` varchar(256) DEFAULT NULL,
  `institution_category` varchar(32) DEFAULT NULL,
  `institution_description` text,
  `institution_acronym` varchar(16) DEFAULT NULL,
  PRIMARY KEY (`institution_id`)
) ENGINE=MyISAM AUTO_INCREMENT=39 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `journal`
--

DROP TABLE IF EXISTS `journal`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `journal` (
  `journal_id` int(11) NOT NULL AUTO_INCREMENT,
  `journal_crdate` int(15) DEFAULT NULL,
  `journal_tst` int(2) DEFAULT NULL,
  `journal_creator` int(15) DEFAULT NULL,
  `journal_title` varchar(256) DEFAULT NULL,
  `journal_url` varchar(256) DEFAULT NULL,
  `journal_logo` varchar(256) DEFAULT NULL,
  `journal_description` text,
  `journal_acronym` varchar(16) DEFAULT NULL,
  `journal_genre` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`journal_id`)
) ENGINE=MyISAM AUTO_INCREMENT=2436 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `link`
--

DROP TABLE IF EXISTS `link`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `link` (
  `link_id` int(15) NOT NULL AUTO_INCREMENT,
  `link_hits` int(15) DEFAULT '0',
  `link_cites` int(8) DEFAULT '0',
  `link_title` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `link_type` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `link_link` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `link_category` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `link_topics` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `link_localcat` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `link_author` int(15) DEFAULT NULL,
  `link_guid` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `link_created` datetime DEFAULT NULL,
  `link_modified` datetime DEFAULT NULL,
  `link_feedid` int(15) DEFAULT NULL,
  `link_description` text COLLATE utf8_unicode_ci,
  `link_crdate` int(15) DEFAULT NULL,
  `link_orig` varchar(5) COLLATE utf8_unicode_ci DEFAULT NULL,
  `link_journal` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  `link_authorname` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  `link_authorurl` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  `link_issued` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  `feedname` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  `link_feedname` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  `link_total` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  `link_content` text COLLATE utf8_unicode_ci,
  `subtitle` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  `link_explicit` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  `item_keywords` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  `link_autocats` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  `link_geo` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  `link_copyright` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  `link_comment` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  `link_commentsRSS` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  `link_keywords` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  `link_comments` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  `link_publisher` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  `link_pingserver` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  `link_pingtarget` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  `link_pingtrackback` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  `link_gdetag` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  `link_status` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  `link_post` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  `link_genre` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`link_id`),
  UNIQUE KEY `link_link` (`link_link`)
) ENGINE=MyISAM AUTO_INCREMENT=12239 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `media`
--

DROP TABLE IF EXISTS `media`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `media` (
  `media_id` int(10) NOT NULL AUTO_INCREMENT,
  `media_type` varchar(40) DEFAULT NULL,
  `media_mimetype` varchar(40) DEFAULT NULL,
  `media_title` varchar(256) DEFAULT NULL,
  `media_url` varchar(256) DEFAULT NULL,
  `media_description` text,
  `media_size` varchar(32) DEFAULT NULL,
  `media_link` varchar(256) DEFAULT NULL,
  `media_post` varchar(256) DEFAULT NULL,
  `media_feed` varchar(256) DEFAULT NULL,
  `media_crdate` int(15) DEFAULT NULL,
  `media_creator` int(15) DEFAULT NULL,
  `media_thurl` varchar(250) DEFAULT NULL,
  `media_thwidth` varchar(250) DEFAULT NULL,
  `media_thheight` varchar(250) DEFAULT NULL,
  `media_duration` varchar(250) DEFAULT NULL,
  `media_block` varchar(250) DEFAULT NULL,
  `media_explicit` varchar(250) DEFAULT NULL,
  `media_keywords` varchar(250) DEFAULT NULL,
  `media_subtitle` varchar(250) DEFAULT NULL,
  `media_height` varchar(250) DEFAULT NULL,
  `media_width` varchar(250) DEFAULT NULL,
  `media_language` varchar(250) DEFAULT NULL,
  `media_identifier` varchar(250) DEFAULT NULL,
  `media_medialink` varchar(250) DEFAULT NULL,
  `media_feedname` varchar(250) DEFAULT NULL,
  `media_feedid` varchar(250) DEFAULT NULL,
  KEY `media_id` (`media_id`)
) ENGINE=MyISAM AUTO_INCREMENT=9010 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `new form`
--

DROP TABLE IF EXISTS `new form`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `new form` (
  `new form_id` int(11) NOT NULL AUTO_INCREMENT,
  `new form_crdate` int(15) DEFAULT NULL,
  `new form_tst` int(2) DEFAULT NULL,
  `new form_creator` int(15) DEFAULT NULL,
  PRIMARY KEY (`new form_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `optlist`
--

DROP TABLE IF EXISTS `optlist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `optlist` (
  `optlist_id` int(15) NOT NULL AUTO_INCREMENT,
  `optlist_title` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `optlist_list` text COLLATE utf8_unicode_ci,
  `optlist_default` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `optlist_type` varchar(24) COLLATE utf8_unicode_ci DEFAULT NULL,
  `optlist_crdate` int(11) DEFAULT NULL,
  `optlist_creator` int(11) DEFAULT NULL,
  `optlist_data` text COLLATE utf8_unicode_ci,
  `optlist_table` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  `optlist_field` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`optlist_id`)
) ENGINE=MyISAM AUTO_INCREMENT=48 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `organization`
--

DROP TABLE IF EXISTS `organization`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `organization` (
  `organization_id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_crdate` int(15) DEFAULT NULL,
  `organization_tst` int(2) DEFAULT NULL,
  `organization_creator` int(15) DEFAULT NULL,
  `organization_title` varchar(256) DEFAULT NULL,
  `organization_url` varchar(256) DEFAULT NULL,
  `organization_logo` varchar(256) DEFAULT NULL,
  `organization_category` varchar(32) DEFAULT NULL,
  `organization_type` varchar(32) DEFAULT NULL,
  `organization_description` text,
  `organization_acronym` varchar(16) DEFAULT NULL,
  `organization_genre` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`organization_id`)
) ENGINE=MyISAM AUTO_INCREMENT=70 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `page`
--

DROP TABLE IF EXISTS `page`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `page` (
  `page_id` int(15) NOT NULL AUTO_INCREMENT,
  `page_title` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `page_html` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `page_feed` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `page_format` varchar(15) CHARACTER SET latin1 DEFAULT 'htm',
  `page_description` text CHARACTER SET latin1,
  `page_file` varchar(123) CHARACTER SET latin1 DEFAULT NULL,
  `page_code` longtext COLLATE utf8_unicode_ci,
  `page_days` varchar(255) CHARACTER SET latin1 DEFAULT 'Friday',
  `page_content` longtext COLLATE utf8_unicode_ci,
  `page_topics` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `page_type` varchar(15) CHARACTER SET latin1 DEFAULT NULL,
  `page_header` varchar(36) CHARACTER SET latin1 DEFAULT NULL,
  `page_footer` varchar(36) CHARACTER SET latin1 DEFAULT NULL,
  `page_autopub` varchar(5) CHARACTER SET latin1 DEFAULT 'no',
  `page_sub` varchar(5) COLLATE utf8_unicode_ci DEFAULT 'no',
  `page_archive` varchar(5) CHARACTER SET latin1 DEFAULT 'no',
  `page_creator` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `page_crdate` int(15) DEFAULT NULL,
  `page_update` int(15) DEFAULT '0',
  `page_year` int(4) DEFAULT NULL,
  `page_yday` int(3) DEFAULT NULL,
  `page_parent` int(15) DEFAULT NULL,
  `page_offset` int(4) DEFAULT NULL,
  `page_cohort` int(2) DEFAULT '7',
  `page_outline` text COLLATE utf8_unicode_ci,
  `page_sent` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  `page_location` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  `page_latest` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  `page_autosub` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  `page_subhour` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  `page_submin` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  `page_subwday` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  `page_submday` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  `page_subsend` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  `page_autowhen` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  `page_hits` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  `page_total` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`page_id`)
) ENGINE=MyISAM AUTO_INCREMENT=187 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `person`
--

DROP TABLE IF EXISTS `person`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `person` (
  `person_id` int(15) NOT NULL AUTO_INCREMENT,
  `person_openid` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  `person_title` varchar(255) DEFAULT NULL,
  `person_pref` varchar(14) DEFAULT NULL,
  `person_name` varchar(255) DEFAULT NULL,
  `person_status` varchar(5) DEFAULT NULL,
  `person_mode` varchar(15) DEFAULT NULL,
  `person_password` varchar(255) NOT NULL DEFAULT '',
  `person_midm` varchar(255) DEFAULT NULL,
  `person_description` text,
  `person_email` varchar(255) DEFAULT NULL,
  `person_eformat` varchar(10) DEFAULT 'htm',
  `person_html` varchar(255) DEFAULT NULL,
  `person_weblog` varchar(255) DEFAULT NULL,
  `person_photo` varchar(255) DEFAULT NULL,
  `person_xml` varchar(255) DEFAULT NULL,
  `person_foaf` varchar(255) DEFAULT NULL,
  `person_street` varchar(255) DEFAULT NULL,
  `person_city` varchar(40) DEFAULT NULL,
  `person_province` varchar(40) DEFAULT NULL,
  `person_country` varchar(20) DEFAULT NULL,
  `person_home_phone` varchar(15) DEFAULT NULL,
  `person_work_phone` varchar(20) DEFAULT NULL,
  `person_fax_phone` varchar(15) DEFAULT NULL,
  `person_organization` varchar(255) DEFAULT NULL,
  `person_remember` varchar(5) DEFAULT 'yes',
  `person_showreal` varchar(5) DEFAULT 'yes',
  `person_showemail` varchar(5) DEFAULT 'yes',
  `person_showuser` varchar(5) DEFAULT 'yes',
  `person_showpage` varchar(5) DEFAULT 'yes',
  `person_crdate` int(15) DEFAULT NULL,
  `show_pref` varchar(4) DEFAULT 'show',
  `show_name` varchar(4) DEFAULT 'show',
  `show_html` varchar(4) DEFAULT 'show',
  `show_weblog` varchar(4) DEFAULT 'show',
  `show_photo` varchar(4) DEFAULT 'show',
  `show_email` varchar(4) DEFAULT 'hide',
  `person_lastread` int(15) DEFAULT '0',
  `person_firstname` varchar(250) DEFAULT NULL,
  `person_lastname` varchar(250) DEFAULT NULL,
  `person_socialnet` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`person_id`)
) ENGINE=MyISAM AUTO_INCREMENT=59244 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `place`
--

DROP TABLE IF EXISTS `place`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `place` (
  `place_id` int(11) NOT NULL AUTO_INCREMENT,
  `place_crdate` int(15) DEFAULT NULL,
  `place_tst` int(2) DEFAULT NULL,
  `place_creator` int(15) DEFAULT NULL,
  `place_title` varchar(256) DEFAULT NULL,
  `place_category` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`place_id`)
) ENGINE=MyISAM AUTO_INCREMENT=46 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `post`
--

DROP TABLE IF EXISTS `post`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `post` (
  `post_id` int(15) NOT NULL AUTO_INCREMENT,
  `post_type` varchar(32) CHARACTER SET latin1 DEFAULT 'link',
  `post_pretext` text CHARACTER SET latin1,
  `post_title` varchar(256) DEFAULT NULL,
  `post_link` varchar(256) DEFAULT NULL,
  `post_author` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `post_journal` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `post_description` text,
  `post_quote` text CHARACTER SET latin1,
  `post_content` longtext,
  `post_topics` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  `post_replies` int(15) DEFAULT '0',
  `post_hits` int(12) DEFAULT NULL,
  `post_thread` int(15) DEFAULT NULL,
  `post_dir` varchar(32) CHARACTER SET latin1 DEFAULT NULL,
  `post_crdate` varchar(36) CHARACTER SET latin1 DEFAULT NULL,
  `post_creator` varchar(36) CHARACTER SET latin1 DEFAULT NULL,
  `post_crip` varchar(24) CHARACTER SET latin1 DEFAULT NULL,
  `post_pub` varchar(10) CHARACTER SET latin1 DEFAULT NULL,
  `post_updated` int(15) DEFAULT NULL,
  `post_email_checked` varchar(10) DEFAULT NULL,
  `post_emails` text,
  `post_offset` int(6) DEFAULT NULL,
  `post_pub_date` varchar(250) DEFAULT NULL,
  `post_image_url` varchar(250) DEFAULT NULL,
  `post_image_file` varchar(250) DEFAULT NULL,
  `post_total` int(11) DEFAULT NULL,
  `post_source` varchar(250) DEFAULT NULL,
  `post_autocats` varchar(250) DEFAULT NULL,
  `post_createcode` varchar(250) DEFAULT NULL,
  `post_creatorname` varchar(250) DEFAULT NULL,
  `post_journalname` varchar(250) DEFAULT NULL,
  `post_genre` varchar(250) DEFAULT NULL,
  `post_category` varchar(250) DEFAULT NULL,
  `post_votescore` varchar(250) DEFAULT NULL,
  `post_feedid` varchar(250) DEFAULT NULL,
  `post_identifier` varchar(250) DEFAULT NULL,
  `post_class` varchar(250) DEFAULT NULL,
  `post_feed` varchar(250) DEFAULT NULL,
  `post_icon` varchar(250) DEFAULT NULL,
  `post_language` varchar(250) DEFAULT NULL,
  `post_social_media` varchar(250) DEFAULT NULL,
  `post_publication` varchar(250) DEFAULT NULL,
  `post_web` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`post_id`)
) ENGINE=MyISAM AUTO_INCREMENT=67518 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `presentation`
--

DROP TABLE IF EXISTS `presentation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `presentation` (
  `presentation_id` int(15) NOT NULL AUTO_INCREMENT,
  `presentation_category` varchar(59) DEFAULT 'J - Presented Papers and Talks',
  `presentation_title` varchar(255) DEFAULT NULL,
  `presentation_link` varchar(255) DEFAULT NULL,
  `presentation_author` varchar(255) DEFAULT 'Stephen Downes',
  `presentation_conference` varchar(255) DEFAULT NULL,
  `presentation_location` varchar(255) DEFAULT NULL,
  `presentation_crdate` int(15) DEFAULT NULL,
  `presentation_attendees` int(6) DEFAULT NULL,
  `presentation_cattendees` int(6) DEFAULT NULL,
  `presentation_catdetails` varchar(24) DEFAULT NULL,
  `presentation_slides` varchar(255) DEFAULT NULL,
  `presentation_slideshare` varchar(255) DEFAULT NULL,
  `presentation_audio` varchar(255) DEFAULT NULL,
  `presentation_org` varchar(255) DEFAULT NULL,
  `presentation_description` text,
  `presentation_video` varchar(255) DEFAULT NULL,
  `presentation_audio_player` text,
  `presentation_slide_player` text,
  `presentation_video_player` text,
  `presentation_topics` varchar(255) DEFAULT NULL,
  `presentation_hits` varchar(250) DEFAULT NULL,
  `presentation_total` varchar(250) DEFAULT NULL,
  `presentation_youtube` varchar(250) DEFAULT NULL,
  `presentation_post` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`presentation_id`)
) ENGINE=MyISAM AUTO_INCREMENT=482 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `product`
--

DROP TABLE IF EXISTS `product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product` (
  `product_id` int(11) NOT NULL AUTO_INCREMENT,
  `product_crdate` int(15) DEFAULT NULL,
  `product_tst` int(2) DEFAULT NULL,
  `product_creator` int(15) DEFAULT NULL,
  `product_title` varchar(256) DEFAULT NULL,
  `product_url` varchar(256) DEFAULT NULL,
  `product_logo` varchar(256) DEFAULT NULL,
  `product_category` varchar(32) DEFAULT NULL,
  `product_description` text,
  `product_genre` varchar(32) DEFAULT NULL,
  `product_acronym` varchar(16) DEFAULT NULL,
  `product_type` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`product_id`)
) ENGINE=MyISAM AUTO_INCREMENT=317 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `project`
--

DROP TABLE IF EXISTS `project`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `project` (
  `project_id` int(11) NOT NULL AUTO_INCREMENT,
  `project_crdate` int(15) DEFAULT NULL,
  `project_tst` int(2) DEFAULT NULL,
  `project_creator` int(15) DEFAULT NULL,
  `project_title` varchar(256) DEFAULT NULL,
  `project_url` varchar(256) DEFAULT NULL,
  `project_logo` varchar(256) DEFAULT NULL,
  `project_category` varchar(32) DEFAULT NULL,
  `project_acronym` varchar(16) DEFAULT NULL,
  PRIMARY KEY (`project_id`)
) ENGINE=MyISAM AUTO_INCREMENT=44 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `provider`
--

DROP TABLE IF EXISTS `provider`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `provider` (
  `provider_id` int(11) NOT NULL AUTO_INCREMENT,
  `provider_crdate` int(15) DEFAULT NULL,
  `provider_tst` int(2) DEFAULT NULL,
  `provider_creator` int(15) DEFAULT NULL,
  `provider_title` varchar(124) DEFAULT NULL,
  PRIMARY KEY (`provider_id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `publication`
--

DROP TABLE IF EXISTS `publication`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `publication` (
  `publication_id` int(15) NOT NULL AUTO_INCREMENT,
  `publication_nrc_number` int(8) DEFAULT NULL,
  `publication_category` varchar(59) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  `publication_catdetails` varchar(24) DEFAULT NULL,
  `publication_title` varchar(255) DEFAULT NULL,
  `publication_link` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  `publication_author_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT 'Stephen Downes',
  `publication_author_id` int(15) DEFAULT NULL,
  `publication_journal_name` varchar(255) DEFAULT NULL,
  `publication_journal_id` int(15) DEFAULT NULL,
  `publication_volume` varchar(32) DEFAULT NULL,
  `publication_crdate` int(15) DEFAULT NULL,
  `publication_pages` varchar(12) DEFAULT NULL,
  `publication_type` varchar(32) DEFAULT NULL,
  `publication_post` int(15) DEFAULT NULL,
  `publication_publisher_name` varchar(59) DEFAULT NULL,
  `publication_publisher_id` int(15) DEFAULT NULL,
  `publication_place` varchar(255) DEFAULT NULL,
  `publication_description` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`publication_id`)
) ENGINE=MyISAM AUTO_INCREMENT=198 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `queue`
--

DROP TABLE IF EXISTS `queue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `queue` (
  `queue_id` int(15) NOT NULL AUTO_INCREMENT,
  `queue_feed` int(15) NOT NULL DEFAULT '0',
  `queue_crdate` int(15) DEFAULT NULL,
  PRIMARY KEY (`queue_id`)
) ENGINE=MyISAM AUTO_INCREMENT=10630 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `rating`
--

DROP TABLE IF EXISTS `rating`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rating` (
  `rating_id` int(15) NOT NULL AUTO_INCREMENT,
  `rating_link` int(15) DEFAULT NULL,
  `rating_person` int(15) DEFAULT NULL,
  `rating_value` varchar(24) DEFAULT NULL,
  `rating_scheme` varchar(255) DEFAULT NULL,
  `rating_crdate` int(15) DEFAULT NULL,
  `rating_test` varchar(256) DEFAULT NULL,
  PRIMARY KEY (`rating_id`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `referral`
--

DROP TABLE IF EXISTS `referral`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `referral` (
  `referral_id` int(15) NOT NULL AUTO_INCREMENT,
  `referral_link` varchar(255) DEFAULT NULL,
  `referral_feed` varchar(255) DEFAULT NULL,
  `referral_item` varchar(255) DEFAULT NULL,
  `referral_cflag` char(2) DEFAULT NULL,
  `referral_title` varchar(255) DEFAULT NULL,
  `referral_type` varchar(16) DEFAULT NULL,
  `referral_description` text,
  `referral_crdate` int(15) DEFAULT '0',
  PRIMARY KEY (`referral_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `subscription`
--

DROP TABLE IF EXISTS `subscription`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subscription` (
  `subscription_id` int(15) NOT NULL AUTO_INCREMENT,
  `subscription_title` varchar(128) DEFAULT NULL,
  `subscription_box` int(15) DEFAULT NULL,
  `subscription_person` int(15) DEFAULT NULL,
  `subscription_format` varchar(16) DEFAULT NULL,
  `subscription_order` int(3) DEFAULT NULL,
  `subscription_misc` varchar(16) DEFAULT NULL,
  `subscription_crdate` varchar(24) DEFAULT NULL,
  PRIMARY KEY (`subscription_id`)
) ENGINE=MyISAM AUTO_INCREMENT=20892 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `task`
--

DROP TABLE IF EXISTS `task`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `task` (
  `task_id` int(15) NOT NULL AUTO_INCREMENT,
  `task_title` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `task_due` int(15) DEFAULT '0',
  `task_priority` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `task_description` text COLLATE utf8_unicode_ci,
  `task_length` int(32) DEFAULT '0',
  `task_project` int(15) DEFAULT '0',
  `task_status` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `task_completed` int(15) DEFAULT NULL,
  `task_crdate` int(15) DEFAULT NULL,
  PRIMARY KEY (`task_id`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `template`
--

DROP TABLE IF EXISTS `template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `template` (
  `template_id` int(15) NOT NULL AUTO_INCREMENT,
  `template_title` varchar(255) DEFAULT NULL,
  `template_description` text,
  `template_creator` varchar(64) DEFAULT NULL,
  `template_crdate` int(15) DEFAULT NULL,
  PRIMARY KEY (`template_id`)
) ENGINE=MyISAM AUTO_INCREMENT=41 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `theme`
--

DROP TABLE IF EXISTS `theme`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `theme` (
  `theme_id` int(15) NOT NULL AUTO_INCREMENT,
  `theme_title` varchar(56) DEFAULT NULL,
  `theme_background` varchar(15) DEFAULT NULL,
  `theme_sitename` varchar(15) DEFAULT NULL,
  `theme_banner_img` varchar(255) DEFAULT NULL,
  `theme_main_img` varchar(255) DEFAULT NULL,
  `theme_main_url` varchar(255) DEFAULT NULL,
  `theme_main_cap` text,
  `theme_portrait` varchar(255) DEFAULT NULL,
  `theme_port_cap` text,
  `theme_text` varchar(15) DEFAULT NULL,
  `theme_link` varchar(15) DEFAULT NULL,
  `theme_section` varchar(15) DEFAULT NULL,
  `theme_crdate` int(15) DEFAULT NULL,
  `theme_creator` varchar(255) DEFAULT NULL,
  `theme_hits` int(15) DEFAULT '0',
  PRIMARY KEY (`theme_id`)
) ENGINE=MyISAM AUTO_INCREMENT=84 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `thread`
--

DROP TABLE IF EXISTS `thread`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `thread` (
  `thread_id` int(15) NOT NULL AUTO_INCREMENT,
  `thread_title` varchar(255) DEFAULT NULL,
  `thread_description` text,
  `thread_creator` varchar(36) DEFAULT NULL,
  `thread_crdate` varchar(15) DEFAULT NULL,
  `thread_numposts` int(6) DEFAULT '0',
  `thread_extype` varchar(16) DEFAULT NULL,
  `thread_exid` int(15) DEFAULT NULL,
  `thread_active` varchar(250) DEFAULT NULL,
  `thread_status` varchar(250) DEFAULT NULL,
  `thread_current` varchar(250) DEFAULT NULL,
  `thread_updated` varchar(250) DEFAULT NULL,
  `thread_refresh` varchar(250) DEFAULT NULL,
  `thread_textsize` varchar(250) DEFAULT NULL,
  `thread_supdated` varchar(250) DEFAULT NULL,
  `thread_srefresh` varchar(250) DEFAULT NULL,
  `thread_tag` varchar(250) DEFAULT NULL,
  `thread_twitterstatus` varchar(250) DEFAULT NULL,
  `thread_identifier` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`thread_id`)
) ENGINE=MyISAM AUTO_INCREMENT=756 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `topic`
--

DROP TABLE IF EXISTS `topic`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `topic` (
  `topic_id` int(15) NOT NULL AUTO_INCREMENT,
  `topic_status` char(3) DEFAULT NULL,
  `topic_title` varchar(255) DEFAULT NULL,
  `topic_where` varchar(255) DEFAULT NULL,
  `topic_description` text,
  `topic_type` varchar(32) DEFAULT 'Select a Type',
  `topic_creator` varchar(255) DEFAULT NULL,
  `topic_crdate` int(15) NOT NULL DEFAULT '0',
  `topic_updated` int(15) DEFAULT '0',
  PRIMARY KEY (`topic_id`)
) ENGINE=MyISAM AUTO_INCREMENT=2542 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `view`
--

DROP TABLE IF EXISTS `view`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `view` (
  `view_id` int(15) NOT NULL AUTO_INCREMENT,
  `view_title` varchar(36) DEFAULT 'untitled',
  `view_text` text,
  `view_creator` int(15) DEFAULT NULL,
  `view_crdate` int(15) DEFAULT NULL,
  PRIMARY KEY (`view_id`)
) ENGINE=MyISAM AUTO_INCREMENT=276 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vote`
--

DROP TABLE IF EXISTS `vote`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vote` (
  `vote_id` int(15) NOT NULL AUTO_INCREMENT,
  `vote_post` int(15) DEFAULT NULL,
  `vote_person` int(15) DEFAULT NULL,
  `vote_value` int(15) DEFAULT NULL,
  `vote_creator` int(15) DEFAULT NULL,
  `vote_crdate` varchar(250) DEFAULT NULL,
  `vote_table` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`vote_id`)
) ENGINE=MyISAM AUTO_INCREMENT=699 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `work`
--

DROP TABLE IF EXISTS `work`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `work` (
  `work_id` int(11) NOT NULL AUTO_INCREMENT,
  `work_crdate` int(15) DEFAULT NULL,
  `work_tst` int(2) DEFAULT NULL,
  `work_creator` int(15) DEFAULT NULL,
  `work_title` varchar(256) DEFAULT NULL,
  `work_url` varchar(256) DEFAULT NULL,
  `work_logo` varchar(256) DEFAULT NULL,
  `work_description` text,
  `work_category` varchar(32) DEFAULT NULL,
  `work_type` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`work_id`)
) ENGINE=MyISAM AUTO_INCREMENT=41 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2017-12-05  4:27:59
