-- MySQL dump 10.11
--
-- Host: localhost    Database: downes
-- ------------------------------------------------------
-- Server version	5.0.77


--
-- Table structure for table `author`
--

DROP TABLE IF EXISTS `author`;


CREATE TABLE `author` (
  `author_id` int(11) NOT NULL auto_increment,
  `author_link` varchar(255) default NULL,
  `author_name` varchar(123) default NULL,
  `author_description` text,
  `author_crdate` int(15) default NULL,
  `box_test` varchar(250) default NULL,
  `author_nickname` varchar(250) default NULL,
  `author_twitter` varchar(250) default NULL,
  `author_linkedin` varchar(250) default NULL,
  `author_delicious` varchar(250) default NULL,
  `author_flickr` varchar(250) default NULL,
  `author_email` varchar(250) default NULL,
  `author_creator` varchar(250) default NULL,
  `author_opensocialuserid` varchar(250) default NULL,
  `author_person` varchar(250) default NULL,
  `author_facebook` varchar(250) default NULL,
  `author_socialnet` varchar(250) default NULL,
  PRIMARY KEY  (`author_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;


--
-- Table structure for table `author_list`
--

DROP TABLE IF EXISTS `author_list`;


CREATE TABLE `author_list` (
  `author_list_id` int(15) NOT NULL auto_increment,
  `author_list_item` int(15) default NULL,
  `author_list_table` varchar(15) default NULL,
  `author_list_author` int(15) default NULL,
  PRIMARY KEY  (`author_list_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;


--
-- Table structure for table `banned_sites`
--

DROP TABLE IF EXISTS `banned_sites`;


CREATE TABLE `banned_sites` (
  `banned_sites_id` int(15) NOT NULL auto_increment,
  `banned_sites_ip` varchar(30) default NULL,
  PRIMARY KEY  (`banned_sites_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;


--
-- Table structure for table `box`
--

DROP TABLE IF EXISTS `box`;


CREATE TABLE `box` (
  `box_id` int(15) NOT NULL auto_increment,
  `box_title` varchar(255) default NULL,
  `box_description` varchar(255) default NULL,
  `box_content` text,
  `box_sub` varchar(5) default NULL,
  `box_format` varchar(10) default NULL,
  `box_day` varchar(12) default NULL,
  `box_creator` varchar(255) default NULL,
  `box_crdate` varchar(255) default NULL,
  `box_txt_version` int(5) default NULL,
  `box_rss_version` int(15) default NULL,
  `box_order` int(3) default NULL,
  PRIMARY KEY  (`box_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;


--
-- Table structure for table `cache`
--

DROP TABLE IF EXISTS `cache`;


CREATE TABLE `cache` (
  `cache_id` int(15) NOT NULL auto_increment,
  `cache_title` varchar(127) default NULL,
  `cache_update` int(15) default '0',
  `cache_text` longtext character set utf8 collate utf8_unicode_ci,
  PRIMARY KEY  (`cache_id`),
  KEY `cache_title` (`cache_title`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;


--
-- Table structure for table `chat`
--

DROP TABLE IF EXISTS `chat`;


CREATE TABLE `chat` (
  `chat_id` int(11) NOT NULL auto_increment,
  `chat_description` text,
  `chat_signature` varchar(255) default NULL,
  `chat_shown` int(2) default '0',
  `chat_creator` varchar(255) default NULL,
  `chat_crip` varchar(24) default NULL,
  `chat_crdate` int(15) default NULL,
  `chat_thread` varchar(250) default NULL,
  PRIMARY KEY  (`chat_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;


--
-- Table structure for table `cite`
--

DROP TABLE IF EXISTS `cite`;


CREATE TABLE `cite` (
  `cite_id` int(15) NOT NULL auto_increment,
  `cite_cited` varchar(255) default NULL,
  `cite_citer` varchar(255) default NULL,
  `cite_title` varchar(255) default '0',
  `cite_crdate` int(15) default NULL,
  `cite_creator` int(15) default NULL,
  PRIMARY KEY  (`cite_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;




--
-- Table structure for table `custom`
--

DROP TABLE IF EXISTS `custom`;


CREATE TABLE `custom` (
  `custom_id` int(15) NOT NULL auto_increment,
  `custom_person` varchar(36) default NULL,
  `custom_format` varchar(16) default NULL,
  `custom_crdate` int(15) default NULL,
  `custom_creator` int(15) default NULL,
  `custom_content` text,
  PRIMARY KEY  (`custom_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


--
-- Table structure for table `event`
--

DROP TABLE IF EXISTS `event`;


CREATE TABLE `event` (
  `event_id` int(15) NOT NULL auto_increment,
  `event_type` varchar(32) default NULL,
  `event_title` varchar(255) default NULL,
  `event_group` varchar(15) default NULL,
  `event_description` text,
  `event_location` varchar(255) default NULL,
  `event_start` varchar(255) default NULL,
  `event_end` varchar(124) default NULL,
  `event_link` varchar(255) default NULL,
  `event_crdate` int(15) default NULL,
  `event_creator` smallint(15) default NULL,
  `test_date` datetime default NULL,
  `environment` varchar(250) default NULL,
  `event_environment` varchar(250) default NULL,
  `event_finish` varchar(255) default NULL,
  `event_star` varchar(250) default NULL,
  `event_host` varchar(250) default NULL,
  `owner_url` varchar(250) default NULL,
  `event_sponsor` varchar(250) default NULL,
  `event_sponsor_url` varchar(250) default NULL,
  `event_access` varchar(250) default NULL,
  `event_owner_url` varchar(250) default NULL,
  `event_identifier` varchar(250) default NULL,
  `event_localtz` varchar(250) default NULL,
  `event_icalstart` varchar(250) default NULL,
  `event_icalend` varchar(250) default NULL,
  `event_feedid` varchar(250) default NULL,
  `event_feedname` varchar(250) default NULL,
  `event_category` varchar(250) default NULL,
  PRIMARY KEY  (`event_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;


--
-- Table structure for table `event_post`
--

DROP TABLE IF EXISTS `event_post`;


CREATE TABLE `event_post` (
  `event_post_id` int(15) NOT NULL auto_increment,
  `event_post_event` int(15) NOT NULL default '0',
  `event_post_post` int(15) NOT NULL default '0',
  PRIMARY KEY  (`event_post_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;


--
-- Table structure for table `feed`
--

DROP TABLE IF EXISTS `feed`;


CREATE TABLE `feed` (
  `feed_id` int(15) NOT NULL auto_increment,
  `feed_identifier` text,
  `feed_type` varchar(8) default NULL,
  `feed_title` varchar(255) NOT NULL default '',
  `feed_description` text,
  `feed_html` varchar(255) default NULL,
  `feed_link` varchar(255) default NULL,
  `feed_journal` int(15) default NULL,
  `feed_author` int(15) default NULL,
  `feed_post` varchar(255) default NULL,
  `feed_guid` varchar(255) default NULL,
  `feed_lastBuildDate` varchar(25) default NULL,
  `feed_pubDate` varchar(25) default NULL,
  `feed_genname` varchar(24) default NULL,
  `feed_genver` varchar(10) default NULL,
  `feed_genurl` varchar(255) default NULL,
  `feed_creatorname` text,
  `feed_creatorurl` text,
  `feed_creatoremail` text,
  `feed_managingEditor` varchar(255) default NULL,
  `feed_webMaster` varchar(255) default NULL,
  `feed_publisher` text,
  `feed_category` varchar(127) character set utf8 collate utf8_unicode_ci default 'category',
  `feed_docs` varchar(255) default NULL,
  `feed_version` varchar(10) default NULL,
  `feed_rights` varchar(255) default NULL,
  `feed_language` varchar(10) default NULL,
  `feed_updatePeriod` varchar(20) default NULL,
  `feed_updateFrequency` varchar(20) default NULL,
  `feed_updateBase` varchar(20) default NULL,
  `feed_granularity` varchar(20) default NULL,
  `feed_compression` varchar(10) default NULL,
  `feed_imgTitle` varchar(255) default NULL,
  `feed_imgLink` varchar(255) default NULL,
  `feed_imgURL` varchar(255) default NULL,
  `feed_imgCreator` varchar(255) default NULL,
  `feed_imgheight` int(4) default NULL,
  `feed_imgwidth` int(4) default NULL,
  `feed_lastharvest` varchar(15) default NULL,
  `feed_status` varchar(15) default 'O',
  `feed_crdate` int(15) default NULL,
  `feed_tagline` varchar(255) default NULL,
  `feed_modified` varchar(255) default NULL,
  `feed_etag` varchar(255) default NULL,
  `feed_updated` varchar(15) default NULL,
  `feed_cache` longtext,
  `feed_links` int(15) default NULL,
  `feed_country` varchar(5) default NULL,
  `feed_add_entry` varchar(255) default NULL,
  `feed_as_xml` text,
  `feed_timezone` varchar(250) default NULL,
  `feed_feedburnerid` varchar(250) default NULL,
  `feed_feedburnerurl` varchar(250) default NULL,
  `feed_feedburnerhost` varchar(250) default NULL,
  `feed_hub` varchar(250) default NULL,
  `feed_OSstartIndex` varchar(250) default NULL,
  `feed_OStotalResults` varchar(250) default NULL,
  `feed_OSitemsPerPage` varchar(250) default NULL,
  `feed_authorname` varchar(250) default NULL,
  `feed_explicit` varchar(250) default NULL,
  `feed_topic` varchar(250) default NULL,
  `feed_rating` varchar(250) default NULL,
  `feed_authorurl` varchar(250) default NULL,
  `feed_authoremail` varchar(250) default NULL,
  `geo_lat` varchar(250) default NULL,
  `geo_long` varchar(250) default NULL,
  `feed_copyright` varchar(250) default NULL,
  `feed_baseurl` varchar(250) default NULL,
  `feed_autocats` varchar(250) default NULL,
  `feed_blogroll` varchar(250) default NULL,
  `feed_keywords` varchar(250) default NULL,
  `feed_creator` varchar(250) default NULL,
  PRIMARY KEY  (`feed_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;


--
-- Table structure for table `field`
--

DROP TABLE IF EXISTS `field`;


CREATE TABLE `field` (
  `field_id` int(15) NOT NULL auto_increment,
  `field_title` varchar(128) collate utf8_unicode_ci NOT NULL default '',
  `field_type` varchar(32) collate utf8_unicode_ci default NULL,
  `field_size` int(5) default NULL,
  `field_other` varchar(32) collate utf8_unicode_ci default NULL,
  `field_crdate` int(15) default NULL,
  `field_creator` int(15) default NULL,
  PRIMARY KEY  (`field_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


--
-- Table structure for table `file`
--

DROP TABLE IF EXISTS `file`;


CREATE TABLE `file` (
  `file_id` int(15) NOT NULL auto_increment,
  `file_title` varchar(255) default NULL,
  `file_file` varchar(255) default NULL,
  `file_type` varchar(32) default NULL,
  `file_size` int(15) default NULL,
  `file_description` text,
  `file_post` int(15) default NULL,
  `file_gallery` varchar(32) default NULL,
  `file_crdate` int(15) default NULL,
  `file_creator` int(15) default NULL,
  `file_align` varchar(250) default NULL,
  `file_width` varchar(250) default NULL,
  `file_dirname` varchar(250) default NULL,
  `file_mime` varchar(250) default NULL,
  `file_url` varchar(250) default NULL,
  `file_link` varchar(250) default NULL,
  PRIMARY KEY  (`file_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;


--
-- Table structure for table `graph`
--

DROP TABLE IF EXISTS `graph`;


CREATE TABLE `graph` (
  `graph_id` int(15) NOT NULL auto_increment,
  `graph_type` varchar(64) default NULL,
  `graph_typeval` varchar(40) default NULL,
  `graph_tableone` varchar(40) default NULL,
  `graph_urlone` varchar(256) default NULL,
  `graph_idone` varchar(40) default NULL,
  `graph_tabletwo` varchar(40) default NULL,
  `graph_urltwo` varchar(256) default NULL,
  `graph_idtwo` varchar(40) default NULL,
  `graph_crdate` varchar(15) default NULL,
  `graph_creator` varchar(15) default NULL,
  KEY `graph_id` (`graph_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;


--
-- Table structure for table `identifier`
--

DROP TABLE IF EXISTS `identifier`;


CREATE TABLE `identifier` (
  `identifier_id` int(11) NOT NULL auto_increment,
  `identifier_catalog` varchar(255) default NULL,
  `identifier_entry` varchar(255) default NULL,
  `identifier_linkid` int(15) default NULL,
  PRIMARY KEY  (`identifier_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


--
-- Table structure for table `journal`
--

DROP TABLE IF EXISTS `journal`;


CREATE TABLE `journal` (
  `journal_id` int(15) NOT NULL auto_increment,
  `journal_title` varchar(255) default NULL,
  `journal_link` varchar(155) default NULL,
  `journal_description` text,
  `journal_crdate` int(15) default NULL,
  `journal_creator` int(15) default NULL,
  PRIMARY KEY  (`journal_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;


--
-- Table structure for table `journal_list`
--

DROP TABLE IF EXISTS `journal_list`;


CREATE TABLE `journal_list` (
  `journal_list_id` int(15) NOT NULL auto_increment,
  `journal_list_item` int(15) default NULL,
  `journal_list_table` varchar(15) default NULL,
  `journal_list_author` int(15) default NULL,
  PRIMARY KEY  (`journal_list_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;


--
-- Table structure for table `learning`
--

DROP TABLE IF EXISTS `learning`;


CREATE TABLE `learning` (
  `learning_id` int(15) NOT NULL auto_increment,
  `learning_item` varchar(255) default NULL,
  `learning_feedid` varchar(255) default NULL,
  `learning_inttype` varchar(255) default NULL,
  `learning_lrtype` varchar(255) default NULL,
  `learning_intlevel` varchar(255) default NULL,
  `learning_semdens` varchar(255) default NULL,
  `learning_eurole` varchar(255) default NULL,
  `learning_context` varchar(255) default NULL,
  `learning_age` varchar(255) default NULL,
  `learning_difficulty` varchar(255) default NULL,
  `learning_ltime` varchar(255) default NULL,
  `learning_description` text,
  `learning_language` varchar(64) default NULL,
  `learning_langs` varchar(255) default NULL,
  `learning_extra` varchar(255) default NULL,
  `learning_crdate` int(15) default NULL,
  PRIMARY KEY  (`learning_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;


--
-- Table structure for table `link`
--

DROP TABLE IF EXISTS `link`;


CREATE TABLE `link` (
  `link_id` int(15) NOT NULL auto_increment,
  `link_hits` int(15) default '0',
  `link_cites` int(8) default '0',
  `link_title` varchar(255) collate utf8_unicode_ci NOT NULL default '',
  `link_type` varchar(32) collate utf8_unicode_ci default NULL,
  `link_link` varchar(255) collate utf8_unicode_ci NOT NULL default '',
  `link_category` varchar(255) collate utf8_unicode_ci default NULL,
  `link_topics` varchar(255) collate utf8_unicode_ci default NULL,
  `link_localcat` varchar(32) collate utf8_unicode_ci default NULL,
  `link_author` int(15) default NULL,
  `link_guid` varchar(255) collate utf8_unicode_ci default NULL,
  `link_created` datetime default NULL,
  `link_modified` datetime default NULL,
  `link_feedid` int(15) default NULL,
  `link_description` text collate utf8_unicode_ci,
  `link_crdate` int(15) default NULL,
  `link_orig` varchar(5) collate utf8_unicode_ci default NULL,
  `link_journal` varchar(250) collate utf8_unicode_ci default NULL,
  `link_authorname` varchar(250) collate utf8_unicode_ci default NULL,
  `link_authorurl` varchar(250) collate utf8_unicode_ci default NULL,
  `link_issued` varchar(250) collate utf8_unicode_ci default NULL,
  `feedname` varchar(250) collate utf8_unicode_ci default NULL,
  `link_feedname` varchar(250) collate utf8_unicode_ci default NULL,
  `link_total` varchar(250) collate utf8_unicode_ci default NULL,
  `link_content` text collate utf8_unicode_ci,
  `subtitle` varchar(250) collate utf8_unicode_ci default NULL,
  `link_explicit` varchar(250) collate utf8_unicode_ci default NULL,
  `item_keywords` varchar(250) collate utf8_unicode_ci default NULL,
  `link_autocats` varchar(250) collate utf8_unicode_ci default NULL,
  `link_geo` varchar(250) collate utf8_unicode_ci default NULL,
  `link_copyright` varchar(250) collate utf8_unicode_ci default NULL,
  `link_comment` varchar(250) collate utf8_unicode_ci default NULL,
  `link_commentsRSS` varchar(250) collate utf8_unicode_ci default NULL,
  `link_keywords` varchar(250) collate utf8_unicode_ci default NULL,
  `link_comments` varchar(250) collate utf8_unicode_ci default NULL,
  `link_publisher` varchar(250) collate utf8_unicode_ci default NULL,
  `link_pingserver` varchar(250) collate utf8_unicode_ci default NULL,
  `link_pingtarget` varchar(250) collate utf8_unicode_ci default NULL,
  `link_pingtrackback` varchar(250) collate utf8_unicode_ci default NULL,
  `link_gdetag` varchar(250) collate utf8_unicode_ci default NULL,
  `link_status` varchar(250) collate utf8_unicode_ci default NULL,
  PRIMARY KEY  (`link_id`),
  UNIQUE KEY `link_link` (`link_link`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


--
-- Table structure for table `link_author`
--

DROP TABLE IF EXISTS `link_author`;


CREATE TABLE `link_author` (
  `link_author_id` int(15) NOT NULL auto_increment,
  `link_author_link` int(15) default NULL,
  `link_author_author` int(15) default NULL,
  `link_author_role` varchar(123) default NULL,
  `link_author_journal` int(15) default NULL,
  PRIMARY KEY  (`link_author_id`),
  KEY `link_author_link` (`link_author_link`,`link_author_author`),
  KEY `link_author_journal` (`link_author_journal`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


--
-- Table structure for table `linktoread`
--

DROP TABLE IF EXISTS `linktoread`;


CREATE TABLE `linktoread` (
  `lr_id` int(15) NOT NULL auto_increment,
  `lr_date` int(15) default NULL,
  `lr_link` int(15) default NULL,
  `lr_person` int(15) default NULL,
  `lr_localcat` varchar(15) default NULL,
  `lr_feed` int(15) default NULL,
  PRIMARY KEY  (`lr_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;


--
-- Table structure for table `list`
--

DROP TABLE IF EXISTS `list`;


CREATE TABLE `list` (
  `list_id` int(15) NOT NULL auto_increment,
  `list_title` varchar(64) default NULL,
  `list_subject` varchar(64) default NULL,
  `list_replyto` varchar(128) default NULL,
  `list_description` text,
  `list_page` varchar(24) default NULL,
  `list_project` int(15) default NULL,
  `list_crdate` varchar(15) default NULL,
  PRIMARY KEY  (`list_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;


--
-- Table structure for table `log`
--

DROP TABLE IF EXISTS `log`;


CREATE TABLE `log` (
  `log_id` int(11) NOT NULL auto_increment,
  `log_title` varchar(255) default NULL,
  `log_entry` text,
  `log_creator` int(15) default NULL,
  `log_crdate` int(15) default NULL,
  PRIMARY KEY  (`log_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;


--
-- Table structure for table `mapping`
--

DROP TABLE IF EXISTS `mapping`;


CREATE TABLE `mapping` (
  `mapping_id` int(15) NOT NULL auto_increment,
  `mapping_title` varchar(255) default NULL,
  `mapping_stype` varchar(64) default NULL,
  `mapping_specific_feed` int(15) default NULL,
  `mapping_feed_type` varchar(32) default NULL,
  `mapping_feed_fields` varchar(127) default NULL,
  `mapping_field_value_pair` varchar(255) default NULL,
  `mapping_dtable` varchar(32) default NULL,
  `mapping_crdate` int(15) default NULL,
  `mapping_creator` int(15) default NULL,
  `mapping_update` int(15) default NULL,
  `mappung_upby` int(15) default NULL,
  `mapping_mappings` text,
  `mapping_values` text,
  `mapping_prefix` varchar(32) default NULL,
  `mapping_priority` varchar(250) default NULL,
  PRIMARY KEY  (`mapping_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;


--
-- Table structure for table `media`
--

DROP TABLE IF EXISTS `media`;


CREATE TABLE `media` (
  `media_id` int(10) NOT NULL auto_increment,
  `media_type` varchar(40) default NULL,
  `media_mimetype` varchar(40) default NULL,
  `media_title` varchar(256) default NULL,
  `media_url` varchar(256) default NULL,
  `media_description` text,
  `media_size` varchar(32) default NULL,
  `media_link` varchar(256) default NULL,
  `media_post` varchar(256) default NULL,
  `media_feed` varchar(256) default NULL,
  `media_crdate` int(15) default NULL,
  `media_creator` int(15) default NULL,
  `media_thurl` varchar(250) default NULL,
  `media_thwidth` varchar(250) default NULL,
  `media_thheight` varchar(250) default NULL,
  `media_duration` varchar(250) default NULL,
  `media_block` varchar(250) default NULL,
  `media_explicit` varchar(250) default NULL,
  `media_keywords` varchar(250) default NULL,
  `media_subtitle` varchar(250) default NULL,
  `media_height` varchar(250) default NULL,
  `media_width` varchar(250) default NULL,
  `media_language` varchar(250) default NULL,
  `media_identifier` varchar(250) default NULL,
  KEY `media_id` (`media_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;


--
-- Table structure for table `old_link_archives`
--

DROP TABLE IF EXISTS `old_link_archives`;


CREATE TABLE `old_link_archives` (
  `link_id` int(15) NOT NULL auto_increment,
  `link_identifier` varchar(255) default NULL,
  `link_crdate` int(15) NOT NULL default '0',
  `link_pubdate` varchar(64) NOT NULL default '',
  `link_feedid` int(15) NOT NULL default '0',
  `link_title` varchar(255) NOT NULL default '',
  `link_language` varchar(10) default NULL,
  `link_description` text,
  `link_link` varchar(255) default NULL,
  `link_edit` varchar(255) default NULL,
  `link_guid` varchar(255) default NULL,
  `link_category` varchar(128) default NULL,
  `link_created` varchar(25) default NULL,
  `link_modified` varchar(25) default NULL,
  `link_issued` varchar(25) default NULL,
  `link_creatorname` text,
  `link_creatorurl` text,
  `link_creatoremail` varchar(255) default NULL,
  `link_contributor` text,
  `link_subject` varchar(255) default NULL,
  `link_coverage` text,
  `link_aggregationLevel` varchar(5) default NULL,
  `link_journal` varchar(255) default NULL,
  `link_format` varchar(255) default NULL,
  `link_version` varchar(255) default NULL,
  `link_size` int(15) default NULL,
  `link_status` varchar(255) default NULL,
  `link_type` varchar(255) default NULL,
  `link_platform` text,
  `link_duration` varchar(64) default NULL,
  `link_source` varchar(255) default NULL,
  `link_cost` varchar(8) default NULL,
  `link_restrictions` varchar(8) default NULL,
  `link_rights` varchar(255) default NULL,
  `link_lcflag` char(1) NOT NULL default 'C',
  `link_rating_v` float default '0',
  `link_rating_n` int(15) default '0',
  `link_hits` int(15) default '0',
  `link_cites` int(15) default '0',
  `pub` int(15) default '0',
  PRIMARY KEY  (`link_id`),
  KEY `link_link` (`link_link`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


--
-- Table structure for table `option`
--

DROP TABLE IF EXISTS `option`;


CREATE TABLE `option` (
  `option_id` int(15) NOT NULL auto_increment,
  `option_title` varchar(250) default NULL,
  `option_list` text,
  `option_default` varchar(59) default NULL,
  PRIMARY KEY  (`option_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;


--
-- Table structure for table `optlist`
--

DROP TABLE IF EXISTS `optlist`;


CREATE TABLE `optlist` (
  `optlist_id` int(15) NOT NULL auto_increment,
  `optlist_title` varchar(255) collate utf8_unicode_ci default NULL,
  `optlist_list` text collate utf8_unicode_ci,
  `optlist_default` varchar(255) collate utf8_unicode_ci default NULL,
  `optlist_type` varchar(24) collate utf8_unicode_ci default NULL,
  `optlist_crdate` int(11) default NULL,
  `optlist_creator` int(11) default NULL,
  PRIMARY KEY  (`optlist_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


--
-- Table structure for table `page`
--

DROP TABLE IF EXISTS `page`;


CREATE TABLE `page` (
  `page_id` int(15) NOT NULL auto_increment,
  `page_title` varchar(255) character set latin1 default NULL,
  `page_html` varchar(255) character set latin1 default NULL,
  `page_feed` varchar(255) collate utf8_unicode_ci default NULL,
  `page_format` varchar(15) character set latin1 default 'htm',
  `page_description` text character set latin1,
  `page_file` varchar(123) character set latin1 default NULL,
  `page_code` longtext character set latin1,
  `page_days` varchar(255) character set latin1 default 'Friday',
  `page_content` longtext character set latin1,
  `page_topics` varchar(255) collate utf8_unicode_ci default NULL,
  `page_type` varchar(15) character set latin1 default NULL,
  `page_header` varchar(36) character set latin1 default NULL,
  `page_footer` varchar(36) character set latin1 default NULL,
  `page_autopub` varchar(5) character set latin1 default 'no',
  `page_sub` varchar(5) collate utf8_unicode_ci default 'no',
  `page_archive` varchar(5) character set latin1 default 'no',
  `page_creator` varchar(255) character set latin1 default NULL,
  `page_crdate` int(15) default NULL,
  `page_update` int(15) default '0',
  `page_year` int(4) default NULL,
  `page_yday` int(3) default NULL,
  `page_parent` int(15) default NULL,
  `page_offset` int(4) default NULL,
  `page_cohort` int(2) default '7',
  `page_outline` text collate utf8_unicode_ci,
  `page_sent` varchar(250) collate utf8_unicode_ci default NULL,
  `page_location` varchar(250) collate utf8_unicode_ci default NULL,
  `page_latest` varchar(250) collate utf8_unicode_ci default NULL,
  `page_autosub` varchar(250) collate utf8_unicode_ci default NULL,
  PRIMARY KEY  (`page_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


--
-- Table structure for table `person`
--

DROP TABLE IF EXISTS `person`;


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
  UNIQUE (`person_id`,`person_title`,`person_email`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;


--
-- Table structure for table `post`
--

DROP TABLE IF EXISTS `post`;


CREATE TABLE `post` (
  `post_id` int(15) NOT NULL auto_increment,
  `post_type` varchar(32) character set latin1 default 'link',
  `post_pretext` text character set latin1,
  `post_title` varchar(255) default NULL,
  `post_link` varchar(255) character set latin1 default NULL,
  `post_linkid` int(15) default NULL,
  `post_author` varchar(255) character set latin1 default NULL,
  `post_authorids` varchar(255) default NULL,
  `post_authorstr` text,
  `post_journal` varchar(255) character set latin1 default NULL,
  `post_journalids` varchar(255) default NULL,
  `post_journalstr` text,
  `post_authorid` int(15) default NULL,
  `post_journalid` int(15) default NULL,
  `post_description` text,
  `post_quote` text character set latin1,
  `post_content` longtext,
  `post_topics` varchar(255) character set utf8 collate utf8_unicode_ci default NULL,
  `post_replies` int(15) default '0',
  `post_key` int(15) default NULL,
  `post_hits` int(12) default NULL,
  `post_thread` int(15) default NULL,
  `post_dir` varchar(32) character set latin1 default NULL,
  `post_crdate` varchar(36) character set latin1 default NULL,
  `post_creator` varchar(36) character set latin1 default NULL,
  `post_crip` varchar(24) character set latin1 default NULL,
  `post_pub` varchar(10) character set latin1 default NULL,
  `post_updated` int(15) default NULL,
  `post_email_checked` varchar(10) default NULL,
  `post_emails` text,
  `post_cache` longtext,
  `post_offset` int(6) default NULL,
  `post_pub_date` varchar(250) default NULL,
  `image_file` varchar(250) default NULL,
  `post_image_url` varchar(250) default NULL,
  `post_image_file` varchar(250) default NULL,
  `post_total` int(11) default NULL,
  `post_source` varchar(250) default NULL,
  `post_autocats` varchar(250) default NULL,
  PRIMARY KEY  (`post_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;


--
-- Table structure for table `post_file`
--

DROP TABLE IF EXISTS `post_file`;


CREATE TABLE `post_file` (
  `post_file_id` int(11) NOT NULL auto_increment,
  `post_file_post` int(11) NOT NULL default '0',
  `post_file_file` int(11) NOT NULL default '0',
  PRIMARY KEY  (`post_file_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;


--
-- Table structure for table `post_link`
--

DROP TABLE IF EXISTS `post_link`;


CREATE TABLE `post_link` (
  `post_link_id` int(15) NOT NULL auto_increment,
  `post_link_post` int(15) default NULL,
  `post_link_link` int(15) default NULL,
  PRIMARY KEY  (`post_link_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


--
-- Table structure for table `post_presentation`
--

DROP TABLE IF EXISTS `post_presentation`;


CREATE TABLE `post_presentation` (
  `post_presentation_id` int(15) NOT NULL auto_increment,
  `post_presentation_post` int(15) default NULL,
  `post_presentation_presentation` int(15) default NULL,
  PRIMARY KEY  (`post_presentation_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;


--
-- Table structure for table `post_topic`
--

DROP TABLE IF EXISTS `post_topic`;


CREATE TABLE `post_topic` (
  `post_topic_id` int(15) NOT NULL auto_increment,
  `post_topic_post` int(15) default NULL,
  `post_topic_topic` int(15) default NULL,
  PRIMARY KEY  (`post_topic_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;


--
-- Table structure for table `posttoread`
--

DROP TABLE IF EXISTS `posttoread`;


CREATE TABLE `posttoread` (
  `pr_id` int(15) NOT NULL auto_increment,
  `pr_date` int(15) default NULL,
  `pr_post` int(15) default NULL,
  `pr_thread` int(15) default NULL,
  `pr_person` int(15) default NULL,
  PRIMARY KEY  (`pr_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


--
-- Table structure for table `presentation`
--

DROP TABLE IF EXISTS `presentation`;


CREATE TABLE `presentation` (
  `presentation_id` int(15) NOT NULL auto_increment,
  `presentation_category` varchar(59) default 'J - Presented Papers and Talks',
  `presentation_title` varchar(255) default NULL,
  `presentation_link` varchar(255) default NULL,
  `presentation_author` varchar(255) default 'Stephen Downes',
  `presentation_conference` varchar(255) default NULL,
  `presentation_location` varchar(255) default NULL,
  `presentation_crdate` int(15) default NULL,
  `presentation_attendees` int(6) default NULL,
  `presentation_cattendees` int(6) default NULL,
  `presentation_catdetails` varchar(24) default NULL,
  `presentation_slides` varchar(255) default NULL,
  `presentation_slideshare` varchar(255) default NULL,
  `presentation_audio` varchar(255) default NULL,
  `presentation_org` varchar(255) default NULL,
  `presentation_description` text,
  `presentation_video` varchar(255) default NULL,
  `presentation_audio_player` text,
  `presentation_slide_player` text,
  `presentation_video_player` text,
  `presentation_topics` varchar(255) default NULL,
  PRIMARY KEY  (`presentation_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;


--
-- Table structure for table `project`
--

DROP TABLE IF EXISTS `project`;


CREATE TABLE `project` (
  `project_key` int(15) NOT NULL auto_increment,
  `project_title` varchar(255) collate utf8_unicode_ci NOT NULL default '',
  `project_crdate` int(15) default NULL,
  `project_submitted` int(15) default NULL,
  `project_person` int(15) default NULL COMMENT 'Project lead, foreign key',
  `project_description` text collate utf8_unicode_ci,
  `project_rationale` text collate utf8_unicode_ci,
  `project_contribution` text collate utf8_unicode_ci,
  `project_previous` text collate utf8_unicode_ci,
  `project_workplan` text collate utf8_unicode_ci,
  `project_alignment` text collate utf8_unicode_ci,
  `project_research` text collate utf8_unicode_ci,
  `project_budget` text collate utf8_unicode_ci,
  `project_partners` text collate utf8_unicode_ci,
  `project_outputs` text collate utf8_unicode_ci,
  `project_measure` text collate utf8_unicode_ci,
  `project_risks` text collate utf8_unicode_ci,
  `project_approved` int(15) default NULL,
  `project_completion` int(15) default NULL,
  `project_creator` int(15) default NULL,
  PRIMARY KEY  (`project_key`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


--
-- Table structure for table `publication`
--

DROP TABLE IF EXISTS `publication`;


CREATE TABLE `publication` (
  `publication_id` int(15) NOT NULL auto_increment,
  `publication_nrc_number` int(8) default NULL,
  `publication_category` varchar(59) character set utf8 collate utf8_unicode_ci default NULL,
  `publication_catdetails` varchar(24) default NULL,
  `publication_title` varchar(255) default NULL,
  `publication_link` varchar(255) character set utf8 collate utf8_unicode_ci default NULL,
  `publication_author_name` varchar(255) character set utf8 collate utf8_unicode_ci default 'Stephen Downes',
  `publication_author_id` int(15) default NULL,
  `publication_journal_name` varchar(255) default NULL,
  `publication_journal_id` int(15) default NULL,
  `publication_volume` varchar(32) default NULL,
  `publication_crdate` int(15) default NULL,
  `publication_pages` varchar(12) default NULL,
  `publication_type` varchar(32) default NULL,
  `publication_post` int(15) default NULL,
  `publication_publisher_name` varchar(59) default NULL,
  `publication_publisher_id` int(15) default NULL,
  `publication_place` varchar(255) default NULL,
  PRIMARY KEY  (`publication_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;


--
-- Table structure for table `publisher`
--

DROP TABLE IF EXISTS `publisher`;


CREATE TABLE `publisher` (
  `publisher_id` int(15) NOT NULL auto_increment,
  `publisher_title` varchar(64) default NULL,
  `publisher_link` varchar(64) default NULL,
  `publisher_x` varchar(64) default NULL,
  PRIMARY KEY  (`publisher_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


--
-- Table structure for table `queue`
--

DROP TABLE IF EXISTS `queue`;


CREATE TABLE `queue` (
  `queue_id` int(15) NOT NULL auto_increment,
  `queue_feed` int(15) NOT NULL default '0',
  `queue_crdate` int(15) default NULL,
  PRIMARY KEY  (`queue_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;


--
-- Table structure for table `rating`
--

DROP TABLE IF EXISTS `rating`;


CREATE TABLE `rating` (
  `rating_id` int(15) NOT NULL auto_increment,
  `rating_link` int(15) default NULL,
  `rating_person` int(15) default NULL,
  `rating_value` int(7) default NULL,
  `rating_scheme` varchar(255) default NULL,
  `rating_crdate` int(15) default NULL,
  PRIMARY KEY  (`rating_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


--
-- Table structure for table `reference`
--

DROP TABLE IF EXISTS `reference`;


CREATE TABLE `reference` (
  `reference_id` int(15) NOT NULL auto_increment,
  `reference_post` int(15) default NULL,
  `reference_link` int(15) default NULL,
  `reference_type` varchar(15) default NULL,
  PRIMARY KEY  (`reference_id`),
  KEY `reference_post` (`reference_post`,`reference_link`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


--
-- Table structure for table `referral`
--

DROP TABLE IF EXISTS `referral`;


CREATE TABLE `referral` (
  `referral_id` int(15) NOT NULL auto_increment,
  `referral_link` varchar(255) default NULL,
  `referral_feed` varchar(255) default NULL,
  `referral_item` varchar(255) default NULL,
  `referral_cflag` char(2) default NULL,
  `referral_title` varchar(255) default NULL,
  `referral_type` varchar(16) default NULL,
  `referral_description` text,
  `referral_crdate` int(15) default '0',
  PRIMARY KEY  (`referral_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


--
-- Table structure for table `relation`
--

DROP TABLE IF EXISTS `relation`;


CREATE TABLE `relation` (
  `relation_id` int(15) NOT NULL auto_increment,
  `relation_linkid` int(15) default NULL,
  `relation_kind` varchar(24) default NULL,
  `relation_item` varchar(255) default NULL,
  `relation_description` text,
  `relation_identity` varchar(255) default NULL,
  PRIMARY KEY  (`relation_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


--
-- Table structure for table `replyto`
--

DROP TABLE IF EXISTS `replyto`;


CREATE TABLE `replyto` (
  `replyto_id` int(15) NOT NULL auto_increment,
  `replyto_post` int(15) default NULL,
  `replyto_reply` int(15) default NULL,
  PRIMARY KEY  (`replyto_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;


--
-- Table structure for table `subscription`
--

DROP TABLE IF EXISTS `subscription`;


CREATE TABLE `subscription` (
  `subscription_id` int(15) NOT NULL auto_increment,
  `subscription_title` varchar(128) default NULL,
  `subscription_box` int(15) default NULL,
  `subscription_person` int(15) default NULL,
  `subscription_format` varchar(16) default NULL,
  `subscription_order` int(3) default NULL,
  `subscription_misc` varchar(16) default NULL,
  `subscription_crdate` varchar(24) default NULL,
  PRIMARY KEY  (`subscription_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;


--
-- Table structure for table `task`
--

DROP TABLE IF EXISTS `task`;


CREATE TABLE `task` (
  `task_id` int(15) NOT NULL auto_increment,
  `task_title` varchar(255) collate utf8_unicode_ci NOT NULL default '',
  `task_due` int(15) default '0',
  `task_priority` varchar(32) collate utf8_unicode_ci default NULL,
  `task_description` text collate utf8_unicode_ci,
  `task_length` int(32) default '0',
  `task_project` int(15) default '0',
  `task_status` varchar(32) collate utf8_unicode_ci default NULL,
  `task_completed` int(15) default NULL,
  `task_crdate` int(15) default NULL,
  PRIMARY KEY  (`task_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


--
-- Table structure for table `taxon`
--

DROP TABLE IF EXISTS `taxon`;


CREATE TABLE `taxon` (
  `taxon_id` int(15) NOT NULL auto_increment,
  `taxon_item` varchar(255) default NULL,
  `taxon_feedid` int(15) default NULL,
  `taxon_purpose` text,
  `taxon_source` varchar(255) default NULL,
  `taxon_path` text,
  `taxon_keyword` varchar(255) default NULL,
  `taxon_description` text,
  `taxon_crdate` int(15) default NULL,
  PRIMARY KEY  (`taxon_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;


--
-- Table structure for table `template`
--

DROP TABLE IF EXISTS `template`;


CREATE TABLE `template` (
  `template_id` int(15) NOT NULL auto_increment,
  `template_title` varchar(255) default NULL,
  `template_description` text,
  `template_creator` varchar(64) default NULL,
  `template_crdate` int(15) default NULL,
  PRIMARY KEY  (`template_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;


--
-- Table structure for table `theme`
--

DROP TABLE IF EXISTS `theme`;


CREATE TABLE `theme` (
  `theme_id` int(15) NOT NULL auto_increment,
  `theme_title` varchar(56) default NULL,
  `theme_background` varchar(15) default NULL,
  `theme_sitename` varchar(15) default NULL,
  `theme_banner_img` varchar(255) default NULL,
  `theme_main_img` varchar(255) default NULL,
  `theme_main_url` varchar(255) default NULL,
  `theme_main_cap` text,
  `theme_portrait` varchar(255) default NULL,
  `theme_port_cap` text,
  `theme_text` varchar(15) default NULL,
  `theme_link` varchar(15) default NULL,
  `theme_section` varchar(15) default NULL,
  `theme_crdate` int(15) default NULL,
  `theme_creator` varchar(255) default NULL,
  `theme_hits` int(15) default '0',
  PRIMARY KEY  (`theme_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;


--
-- Table structure for table `thread`
--

DROP TABLE IF EXISTS `thread`;


CREATE TABLE `thread` (
  `thread_id` int(15) NOT NULL auto_increment,
  `thread_title` varchar(255) default NULL,
  `thread_description` text,
  `thread_creator` varchar(36) default NULL,
  `thread_crdate` varchar(15) default NULL,
  `thread_numposts` int(6) default '0',
  `thread_extype` varchar(16) default NULL,
  `thread_exid` int(15) default NULL,
  `thread_active` varchar(250) default NULL,
  `thread_status` varchar(250) default NULL,
  `thread_current` varchar(250) default NULL,
  `thread_updated` varchar(250) default NULL,
  `thread_refresh` varchar(250) default NULL,
  `thread_textsize` varchar(250) default NULL,
  `thread_supdated` varchar(250) default NULL,
  `thread_srefresh` varchar(250) default NULL,
  `thread_tag` varchar(250) default NULL,
  PRIMARY KEY  (`thread_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;


--
-- Table structure for table `topic`
--

DROP TABLE IF EXISTS `topic`;


CREATE TABLE `topic` (
  `topic_id` int(15) NOT NULL auto_increment,
  `topic_status` char(3) default NULL,
  `topic_title` varchar(255) default NULL,
  `topic_where` varchar(255) default NULL,
  `topic_description` text,
  `topic_type` varchar(32) default 'Select a Type',
  `topic_creator` varchar(255) default NULL,
  `topic_crdate` int(15) NOT NULL default '0',
  `topic_updated` int(15) default '0',
  `topic_cache` longtext character set utf8 collate utf8_unicode_ci,
  PRIMARY KEY  (`topic_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;


--
-- Table structure for table `topic_list`
--

DROP TABLE IF EXISTS `topic_list`;


CREATE TABLE `topic_list` (
  `topic_list_id` int(15) NOT NULL auto_increment,
  `topic_list_item` int(15) default NULL,
  `topic_list_table` varchar(15) default NULL,
  `topic_list_topic` int(15) default NULL,
  PRIMARY KEY  (`topic_list_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;


--
-- Table structure for table `url`
--

DROP TABLE IF EXISTS `url`;


CREATE TABLE `url` (
  `url_id` int(15) NOT NULL auto_increment,
  `url_title` varchar(256) default NULL,
  `url_href` varchar(256) default NULL,
  KEY `url_id` (`url_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


--
-- Table structure for table `view`
--

DROP TABLE IF EXISTS `view`;


CREATE TABLE `view` (
  `view_id` int(15) NOT NULL auto_increment,
  `view_title` varchar(36) default 'untitled',
  `view_text` text,
  `view_creator` int(15) default NULL,
  `view_crdate` int(15) default NULL,
  PRIMARY KEY  (`view_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

