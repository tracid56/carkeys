CREATE TABLE IF NOT EXISTS `vehicle_keys` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(22) NOT NULL,
  `plate` varchar(12) NOT NULL,
  PRIMARY KEY (`id`)
)
