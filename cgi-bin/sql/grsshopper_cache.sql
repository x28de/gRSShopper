--
-- Table structure for table `config`
--

DROP TABLE IF EXISTS `cache`;



-- --------------------------------------------------------

-- 
-- Table structure for table `cache`
-- 

CREATE TABLE `cache` (
  `cache_id` int(15) NOT NULL auto_increment,
  `cache_title` varchar(127) default NULL,
  `cache_update` int(15) default '0',
  `cache_text` longtext character set utf8 collate utf8_unicode_ci,
  PRIMARY KEY  (`cache_id`),
  KEY `cache_title` (`cache_title`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;


