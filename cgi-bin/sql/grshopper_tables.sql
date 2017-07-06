-- gRSShopper - Version 0.8
--
-- Does not over-write existing tables
-- ------------------------------------------------------
-- Database Schema
-- 29 June 2017



--
-- Table structure for table `author`
--

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
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci; DEFAULT;


--
-- Table structure for table `banned_sites`
--

CREATE TABLE `banned_sites` (
  `banned_sites_id` int(15) NOT NULL AUTO_INCREMENT,
  `banned_sites_ip` varchar(30) DEFAULT NULL,
  `banned_sites_crdate` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`banned_sites_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci; DEFAULT;


--
-- Table structure for table `box`
--


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
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci; DEFAULT;


--
-- Table structure for table `chat`
--


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
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci; DEFAULT;


--
-- Table structure for table `cite`
--



CREATE TABLE `cite` (
  `cite_id` int(15) NOT NULL AUTO_INCREMENT,
  `cite_cited` varchar(255) DEFAULT NULL,
  `cite_citer` varchar(255) DEFAULT NULL,
  `cite_title` varchar(255) DEFAULT '0',
  `cite_crdate` int(15) DEFAULT NULL,
  `cite_creator` int(15) DEFAULT NULL,
  PRIMARY KEY (`cite_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci; DEFAULT;


--
-- Table structure for table `config`
--


CREATE TABLE `config` (
  `config_id` int(5) NOT NULL AUTO_INCREMENT,
  `config_type` varchar(255) DEFAULT NULL,
  `config_noun` varchar(255) DEFAULT NULL,
  `config_verb` varchar(255) DEFAULT NULL,
  `config_value` varchar(511) DEFAULT NULL,
  `config_crdate` varchar(250) DEFAULT NULL,
  KEY `config_id` (`config_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci; DEFAULT;


--
-- Table structure for table `course`
--


CREATE TABLE `course` (
  `course_id` int(11) NOT NULL AUTO_INCREMENT,
  `course_crdate` int(15) DEFAULT NULL,
  `course_creator` int(15) DEFAULT NULL,
  `course_title` varchar(256) DEFAULT NULL,
  `course_description` text,
  `course_url` varchar(256) DEFAULT NULL,
  PRIMARY KEY (`course_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci; DEFAULT;


--
-- Table structure for table `event`
--


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
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci; DEFAULT;


--
-- Table structure for table `feed`
--


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
  `feed_category` varchar(127) DEFAULT 'category',
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
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci; DEFAULT;

--
-- Table structure for table `field`
--


CREATE TABLE `field` (
  `field_id` int(15) NOT NULL AUTO_INCREMENT,
  `field_title` varchar(128) NOT NULL DEFAULT 'title',
  `field_type` varchar(32) DFAULT NULL,
  `field_size` int(5) DEFAULT NULL,
  `field_other` varchar(32) DEFAULT NULL,
  `field_crdate` int(15) DEFAULT NULL,
  `field_creator` int(15) DEFAULT NULL,
  PRIMARY KEY (`field_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;;


--
-- Table structure for table `file`
--


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
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci; DEFAULT;


--
-- Table structure for table `form`
--


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
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci; DEFAULT;


--
-- Table structure for table `graph`
--

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
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci; DEFAULT;


--
-- Table structure for table `journal`
--


CREATE TABLE `journal` (
  `journal_id` int(15) NOT NULL AUTO_INCREMENT,
  `journal_title` varchar(255) DEFAULT NULL,
  `journal_link` varchar(155) DEFAULT NULL,
  `journal_description` text,
  `journal_crdate` int(15) DEFAULT NULL,
  `journal_creator` int(15) DEFAULT NULL,
  PRIMARY KEY (`journal_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci; DEFAULT;

--
-- Table structure for table `link`
--


CREATE TABLE `link` (
  `link_id` int(15) NOT NULL AUTO_INCREMENT,
  `link_hits` int(15) DEFAULT '0',
  `link_cites` int(8) DEFAULT '0',
  `link_title` varchar(255) NOT NULL DEFAULT 'title',
  `link_type` varchar(32) DEFAULT NULL,
  `link_link` varchar(255) NOT NULL DEFAULT '',
  `link_category` varchar(255) DEFAULT NULL,
  `link_topics` varchar(255) DEFAULT NULL,
  `link_localcat` varchar(32) DEFAULT NULL,
  `link_author` int(15) DEFAULT NULL,
  `link_guid` varchar(255) DEFAULT NULL,
  `link_created` datetime DEFAULT NULL,
  `link_modified` datetime DEFAULT NULL,
  `link_feedid` int(15) DEFAULT NULL,
  `link_description` text,
  `link_crdate` int(15) DEFAULT NULL,
  `link_orig` varchar(5) DEFAULT NULL,
  `link_journal` varchar(250) DEFAULT NULL,
  `link_authorname` varchar(250) DEFAULT NULL,
  `link_authorurl` varchar(250) DEFAULT NULL,
  `link_issued` varchar(250) DEFAULT NULL,
  `feedname` varchar(250) DEFAULT NULL,
  `link_feedname` varchar(250) DEFAULT NULL,
  `link_total` varchar(250) DEFAULT NULL,
  `link_content` text,
  `subtitle` varchar(250) DEFAULT NULL,
  `link_explicit` varchar(250) DEFAULT NULL,
  `item_keywords` varchar(250) DEFAULT NULL,
  `link_autocats` varchar(250) DEFAULT NULL,
  `link_geo` varchar(250) DEFAULT NULL,
  `link_copyright` varchar(250) DEFAULT NULL,
  `link_comment` varchar(250) DEFAULT NULL,
  `link_commentsRSS` varchar(250) DEFAULT NULL,
  `link_keywords` varchar(250) DEFAULT NULL,
  `link_comments` varchar(250) DEFAULT NULL,
  `link_publisher` varchar(250) DEFAULT NULL,
  `link_pingserver` varchar(250) DEFAULT NULL,
  `link_pingtarget` varchar(250) DEFAULT NULL,
  `link_pingtrackback` varchar(250) DEFAULT NULL,
  `link_gdetag` varchar(250) DEFAULT NULL,
  `link_status` varchar(250) DEFAULT NULL,
  `link_post` varchar(250) DEFAULT NULL,
  `link_genre` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`link_id`),
  UNIQUE KEY `link_link` (`link_link`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;;


--
-- Table structure for table `media`
--


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
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci; DEFAULT;


--
-- Table structure for table `optlist`
--


CREATE TABLE `optlist` (
  `optlist_id` int(15) NOT NULL AUTO_INCREMENT,
  `optlist_title` varchar(255) DEFAULT NULL,
  `optlist_list` text,
  `optlist_default` varchar(255) DEFAULT NULL,
  `optlist_type` varchar(24) DEFAULT NULL,
  `optlist_crdate` int(11) DEFAULT NULL,
  `optlist_creator` int(11) DEFAULT NULL,
  `optlist_data` varchar(250) DEFAULT NULL,
  `optlist_table` varchar(250) DEFAULT NULL,
  `optlist_field` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`optlist_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;;


--
-- Table structure for table `page`
--


CREATE TABLE `page` (
  `page_id` int(15) NOT NULL AUTO_INCREMENT,
  `page_title` varchar(255) DEFAULT NULL,
  `page_html` varchar(255) DEFAULT NULL,
  `page_feed` varchar(255) DEFAULT NULL,
  `page_format` varchar(15) DEFAULT 'htm',
  `page_description` text,
  `page_file` varchar(123) DEFAULT NULL,
  `page_code` longtext,
  `page_days` varchar(255) DEFAULT 'Friday',
  `page_content` longtext,
  `page_topics` varchar(255) DEFAULT NULL,
  `page_type` varchar(15) DEFAULT NULL,
  `page_header` varchar(36) DEFAULT NULL,
  `page_footer` varchar(36) DEFAULT NULL,
  `page_autopub` varchar(5) DEFAULT 'no',
  `page_sub` varchar(5) DEFAULT 'no',
  `page_archive` varchar(5) DEFAULT 'no',
  `page_creator` varchar(255) DEFAULT NULL,
  `page_crdate` int(15) DEFAULT NULL,
  `page_update` int(15) DEFAULT '0',
  `page_year` int(4) DEFAULT NULL,
  `page_yday` int(3) DEFAULT NULL,
  `page_parent` int(15) DEFAULT NULL,
  `page_offset` int(4) DEFAULT NULL,
  `page_cohort` int(2) DEFAULT '7',
  `page_outline` text,
  `page_sent` varchar(250) DEFAULT NULL,
  `page_location` varchar(250) DEFAULT NULL,
  `page_latest` varchar(250) DEFAULT NULL,
  `page_autosub` varchar(250) DEFAULT NULL,
  `page_subhour` varchar(250) DEFAULT NULL,
  `page_submin` varchar(250) DEFAULT NULL,
  `page_subwday` varchar(250) DEFAULT NULL,
  `page_submday` varchar(250) DEFAULT NULL,
  `page_subsend` varchar(250) DEFAULT NULL,
  `page_autowhen` varchar(250) DEFAULT NULL,
  `page_hits` varchar(250) DEFAULT NULL,
  `page_total` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`page_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;;


--
-- Table structure for table `person`
--


CREATE TABLE `person` (
  `person_id` int(15) NOT NULL AUTO_INCREMENT,
  `person_openid` varchar(255) DEFAULT NULL,
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
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci; DEFAULT;


--
-- Table structure for table `post`
--


CREATE TABLE `post` (
  `post_id` int(15) NOT NULL AUTO_INCREMENT,
  `post_type` varchar(32) DEFAULT 'link',
  `post_pretext` text,
  `post_title` varchar(256) DEFAULT NULL,
  `post_link` varchar(256) DEFAULT NULL,
  `post_author` varchar(255) DEFAULT NULL,
  `post_journal` varchar(255) DEFAULT NULL,
  `post_description` text,
  `post_quote` text,
  `post_content` longtext,
  `post_topics` varchar(255) DEFAULT NULL,
  `post_replies` int(15) DEFAULT '0',
  `post_hits` int(12) DEFAULT NULL,
  `post_thread` int(15) DEFAULT NULL,
  `post_dir` varchar(32) DEFAULT NULL,
  `post_crdate` varchar(36) DEFAULT NULL,
  `post_creator` varchar(36) DEFAULT NULL,
  `post_crip` varchar(24) DEFAULT NULL,
  `post_pub` varchar(10) DEFAULT NULL,
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
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci; DEFAULT;


--
-- Table structure for table `presentation`
--

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
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci; DEFAULT;


--
-- Table structure for table `project`
--

CREATE TABLE `project` (
  `project_key` int(15) NOT NULL AUTO_INCREMENT,
  `project_title` varchar(255) NOT NULL DEFAULT 'title',
  `project_crdate` int(15) DEFAULT NULL,
  `project_submitted` int(15) DEFAULT NULL,
  `project_person` int(15) DEFAULT NULL COMMENT,
  `project_description` text,
  `project_rationale` text,
  `project_contribution` text,
  `project_previous` text,
  `project_workplan` text,
  `project_alignment` text,
  `project_research` text,
  `project_budget` text,
  `project_partners` text,
  `project_outputs` text,
  `project_measure` text,
  `project_risks` text,
  `project_approved` int(15) DEFAULT NULL,
  `project_completion` int(15) DEFAULT NULL,
  `project_creator` int(15) DEFAULT NULL,
  PRIMARY KEY (`project_key`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;;


--
-- Table structure for table `provider`
--

CREATE TABLE `provider` (
  `provider_id` int(11) NOT NULL AUTO_INCREMENT,
  `provider_crdate` int(15) DEFAULT NULL,
  `provider_tst` int(2) DEFAULT NULL,
  `provider_creator` int(15) DEFAULT NULL,
  `provider_title` varchar(124) DEFAULT NULL,
  PRIMARY KEY (`provider_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci; DEFAULT;


--
-- Table structure for table `publication`
--


CREATE TABLE `publication` (
  `publication_id` int(15) NOT NULL AUTO_INCREMENT,
  `publication_nrc_number` int(8) DEFAULT NULL,
  `publication_category` varchar(59) DEFAULT NULL,
  `publication_catdetails` varchar(24) DEFAULT NULL,
  `publication_title` varchar(255) DEFAULT NULL,
  `publication_link` varchar(255) DEFAULT NULL,
  `publication_author_name` varchar(255) DEFAULT 'Stephen Downes',
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
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci; DEFAULT;

--
-- Table structure for table `queue`
--


CREATE TABLE `queue` (
  `queue_id` int(15) NOT NULL AUTO_INCREMENT,
  `queue_feed` int(15) NOT NULL DEFAULT '0',
  `queue_crdate` int(15) DEFAULT NULL,
  PRIMARY KEY (`queue_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci; DEFAULT;


--
-- Table structure for table `rating`
--


CREATE TABLE `rating` (
  `rating_id` int(15) NOT NULL AUTO_INCREMENT,
  `rating_link` int(15) DEFAULT NULL,
  `rating_person` int(15) DEFAULT NULL,
  `rating_value` varchar(24) DEFAULT NULL,
  `rating_scheme` varchar(255) DEFAULT NULL,
  `rating_crdate` int(15) DEFAULT NULL,
  `rating_test` varchar(256) DEFAULT NULL,
  PRIMARY KEY (`rating_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci; DEFAULT;


--
-- Table structure for table `referral`
--

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
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci; DEFAULT;


--
-- Table structure for table `subscription`
--

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
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci; DEFAULT;


--
-- Table structure for table `task`
--


CREATE TABLE `task` (
  `task_id` int(15) NOT NULL AUTO_INCREMENT,
  `task_title` varchar(255) NOT NULL DEFAULT '',
  `task_due` int(15) DEFAULT '0',
  `task_priority` varchar(32) DEFAULT NULL,
  `task_description` text,
  `task_length` int(32) DEFAULT '0',
  `task_project` int(15) DEFAULT '0',
  `task_status` varchar(32) DEFAULT NULL,
  `task_completed` int(15) DEFAULT NULL,
  `task_crdate` int(15) DEFAULT NULL,
  PRIMARY KEY (`task_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;;


--
-- Table structure for table `template`
--


CREATE TABLE `template` (
  `template_id` int(15) NOT NULL AUTO_INCREMENT,
  `template_title` varchar(255) DEFAULT NULL,
  `template_description` text,
  `template_creator` varchar(64) DEFAULT NULL,
  `template_crdate` int(15) DEFAULT NULL,
  PRIMARY KEY (`template_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci; DEFAULT;


--
-- Table structure for table `theme`
--


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
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci; DEFAULT;

--
-- Table structure for table `thread`
--


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
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci; DEFAULT;


--
-- Table structure for table `topic`
--


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
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci; DEFAULT;


--
-- Table structure for table `view`
--


CREATE TABLE `view` (
  `view_id` int(15) NOT NULL AUTO_INCREMENT,
  `view_title` varchar(36) DEFAULT 'untitled',
  `view_text` text,
  `view_creator` int(15) DEFAULT NULL,
  `view_crdate` int(15) DEFAULT NULL,
  PRIMARY KEY (`view_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci; DEFAULT;


--
-- Table structure for table `vote`
--


CREATE TABLE `vote` (
  `vote_id` int(15) NOT NULL AUTO_INCREMENT,
  `vote_post` int(15) DEFAULT NULL,
  `vote_person` int(15) DEFAULT NULL,
  `vote_value` int(15) DEFAULT NULL,
  `vote_creator` int(15) DEFAULT NULL,
  `vote_crdate` varchar(250) DEFAULT NULL,
  `vote_table` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`vote_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci; DEFAULT;
