CREATE TABLE `content_html` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_box_elements` int(11) DEFAULT NULL,
  `id_router` int(11) DEFAULT NULL,
  `content` mediumtext COLLATE utf8_czech_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_box_elements` (`id_box_elements`,`id_router`)
);