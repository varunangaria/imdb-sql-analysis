-- IMDB Database Schema
-- Tool - MySQL Workbench

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema imdb
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `imdb` ;

-- -----------------------------------------------------
-- Schema imdb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `imdb` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci ;
USE `imdb` ;

-- -----------------------------------------------------
-- Table `imdb`.`actors`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `imdb`.`actors` (
  `id` INT NOT NULL DEFAULT '0',
  `first_name` VARCHAR(100) NULL DEFAULT NULL,
  `last_name` VARCHAR(100) NULL DEFAULT NULL,
  `gender` CHAR(1) NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX `actors_first_name` (`first_name` ASC) VISIBLE,
  INDEX `actors_last_name` (`last_name` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `imdb`.`directors`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `imdb`.`directors` (
  `id` INT NOT NULL DEFAULT '0',
  `first_name` VARCHAR(100) NULL DEFAULT NULL,
  `last_name` VARCHAR(100) NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX `directors_first_name` (`first_name` ASC) VISIBLE,
  INDEX `directors_last_name` (`last_name` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `imdb`.`directors_genres`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `imdb`.`directors_genres` (
  `director_id` INT NOT NULL,
  `genre` VARCHAR(100) NOT NULL,
  `prob` FLOAT NULL DEFAULT NULL,
  PRIMARY KEY (`director_id`, `genre`),
  INDEX `directors_genres_director_id` (`director_id` ASC) VISIBLE,
  CONSTRAINT `directors_genres_ibfk_1`
    FOREIGN KEY (`director_id`)
    REFERENCES `imdb`.`directors` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `imdb`.`movies`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `imdb`.`movies` (
  `id` INT NOT NULL DEFAULT '0',
  `name` VARCHAR(100) NULL DEFAULT NULL,
  `year` INT NULL DEFAULT NULL,
  `rankscore` FLOAT NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX `movies_name` (`name` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `imdb`.`movies_directors`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `imdb`.`movies_directors` (
  `director_id` INT NOT NULL,
  `movie_id` INT NOT NULL,
  PRIMARY KEY (`director_id`, `movie_id`),
  INDEX `movies_directors_director_id` (`director_id` ASC) VISIBLE,
  INDEX `movies_directors_movie_id` (`movie_id` ASC) VISIBLE,
  CONSTRAINT `movies_directors_ibfk_1`
    FOREIGN KEY (`director_id`)
    REFERENCES `imdb`.`directors` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `movies_directors_ibfk_2`
    FOREIGN KEY (`movie_id`)
    REFERENCES `imdb`.`movies` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `imdb`.`movies_genres`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `imdb`.`movies_genres` (
  `movie_id` INT NOT NULL,
  `genre` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`movie_id`, `genre`),
  INDEX `movies_genres_movie_id` (`movie_id` ASC) VISIBLE,
  CONSTRAINT `movies_genres_ibfk_1`
    FOREIGN KEY (`movie_id`)
    REFERENCES `imdb`.`movies` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `imdb`.`roles`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `imdb`.`roles` (
  `actor_id` INT NOT NULL,
  `movie_id` INT NOT NULL,
  `role` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`actor_id`, `movie_id`, `role`),
  INDEX `actor_id` (`actor_id` ASC) VISIBLE,
  INDEX `movie_id` (`movie_id` ASC) VISIBLE,
  CONSTRAINT `roles_ibfk_1`
    FOREIGN KEY (`actor_id`)
    REFERENCES `imdb`.`actors` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `roles_ibfk_2`
    FOREIGN KEY (`movie_id`)
    REFERENCES `imdb`.`movies` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
