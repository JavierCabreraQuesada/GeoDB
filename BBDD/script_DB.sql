CREATE TABLE `tickets`.`ticket` (
  `id_ticket` VARCHAR(20) NOT NULL,
  `id_evento` VARCHAR(10) NOT NULL,
  `num_entrada` INT NOT NULL,
  `estado` CHAR(1) NOT NULL,
  PRIMARY KEY (`id_ticket`))
  
  
CREATE TABLE `evento` (
  `id_evento` varchar(10) NOT NULL,
  `id_recinto` varchar(5) NOT NULL,
  `descripcion` varchar(1000) NOT NULL,
  `fecha` datetime NOT NULL,
  PRIMARY KEY (`id_evento`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


ALTER TABLE `tickets`.`ticket` 
ADD CONSTRAINT `id_evento`
  FOREIGN KEY (`id_evento`)
  REFERENCES `tickets`.`evento` (`id_evento`)
  ON DELETE CASCADE
  ON UPDATE CASCADE;
  
  
CREATE TABLE `tickets`.`recinto` (
  `id_recinto` VARCHAR(5) NOT NULL,
  `latitud` DECIMAL(10,7) NOT NULL,
  `longitud` DECIMAL(10,7) NOT NULL,
  PRIMARY KEY (`id_recinto`));
  
  ALTER TABLE `tickets`.`evento` 
ADD INDEX `id_recinto_idx` (`id_recinto` ASC);
ALTER TABLE `tickets`.`evento` 
ADD CONSTRAINT `id_recinto`
  FOREIGN KEY (`id_recinto`)
  REFERENCES `tickets`.`recinto` (`id_recinto`)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;
  
  
  
  
  
  
  
