--
-- Table structure for table `config`
--

DROP TABLE IF EXISTS `config`;


CREATE TABLE `config` (
  `config_id` int(5) NOT NULL auto_increment,
  `config_type` varchar(255) default NULL,
  `config_noun` varchar(255) default NULL,
  `config_verb` varchar(255) default NULL,
  `config_value` varchar(255) default NULL,
  KEY `config_id` (`config_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;


--
-- Table structure for table `custom`
--
