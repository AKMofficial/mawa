CREATE DATABASE IF NOT EXISTS mawa
  DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- Core Tables
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS agency (
  id             BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name           VARCHAR(200) NOT NULL,
  country_code   VARCHAR(3)   NOT NULL,  -- ISO-3166 alpha-3 preferred
  contact_phone  VARCHAR(30),
  UNIQUE KEY uq_agency_name_country (name, country_code)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS hj_group (
  id             BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  agency_id      BIGINT NOT NULL,
  name           VARCHAR(200) NOT NULL,
  country_code   VARCHAR(3)   NOT NULL,
  leader_name    VARCHAR(150),
  contact_phone  VARCHAR(30),
  CONSTRAINT fk_group_agency
    FOREIGN KEY (agency_id) REFERENCES agency(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  UNIQUE KEY uq_group_agency_name (agency_id, name),
  KEY idx_group_agency (agency_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS building (
  id          BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  code        VARCHAR(50)  NOT NULL,
  name        VARCHAR(200),
  address     VARCHAR(300),
  city        VARCHAR(100),
  zone        VARCHAR(100),
  latitude    DOUBLE,
  longitude   DOUBLE,
  UNIQUE KEY uq_building_code (code),
  CONSTRAINT chk_building_lat CHECK (latitude  IS NULL OR (latitude  BETWEEN -90  AND 90)),
  CONSTRAINT chk_building_lon CHECK (longitude IS NULL OR (longitude BETWEEN -180 AND 180))
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS room (
  id           BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  building_id  BIGINT NOT NULL,
  room_number  VARCHAR(50) NOT NULL,
  floor        INT,
  capacity     INT NOT NULL,
  gender       ENUM('M','F') NOT NULL,
  room_type    VARCHAR(50),
  CONSTRAINT fk_room_building
    FOREIGN KEY (building_id) REFERENCES building(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT chk_room_capacity CHECK (capacity > 0),
  UNIQUE KEY uq_room_per_building (building_id, room_number),
  KEY idx_room_building (building_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS bed (
  id        BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  room_id   BIGINT NOT NULL,
  label     VARCHAR(50) NOT NULL,
  CONSTRAINT fk_bed_room
    FOREIGN KEY (room_id) REFERENCES room(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  UNIQUE KEY uq_bed_per_room (room_id, label),
  KEY idx_bed_room (room_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS pilgrim (
  id              BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  passport_no     VARCHAR(40)  NOT NULL,
  national_id     VARCHAR(40),
  first_name_en   VARCHAR(100) NOT NULL,
  last_name_en    VARCHAR(100) NOT NULL,
  full_name_ar    VARCHAR(200),
  gender          ENUM('M','F') NOT NULL,
  date_of_birth   DATE NOT NULL,
  nationality     VARCHAR(3),
  group_id        BIGINT NOT NULL,
  arrival_date    DATE NOT NULL,
  departure_date  DATE NOT NULL,
  special_needs   BOOLEAN NOT NULL DEFAULT FALSE,
  CONSTRAINT fk_pilgrim_group
    FOREIGN KEY (group_id) REFERENCES hj_group(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  UNIQUE KEY uq_pilgrim_passport (passport_no),
  UNIQUE KEY uq_pilgrim_national_id (national_id),
  CONSTRAINT chk_pilgrim_dates CHECK (arrival_date <= departure_date),
  KEY idx_pilgrim_group (group_id),
  KEY idx_pilgrim_dates (arrival_date, departure_date)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS assignment (
  id           BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  pilgrim_id   BIGINT NOT NULL,
  bed_id       BIGINT NOT NULL,
  start_date   DATE   NOT NULL,
  end_date     DATE   NOT NULL,
  status       ENUM('active','completed','cancelled') NOT NULL DEFAULT 'active',
  CONSTRAINT fk_assignment_pilgrim
    FOREIGN KEY (pilgrim_id) REFERENCES pilgrim(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_assignment_bed
    FOREIGN KEY (bed_id)     REFERENCES bed(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT chk_assignment_dates CHECK (start_date <= end_date),
  KEY idx_assignment_pilgrim (pilgrim_id),
  KEY idx_assignment_bed (bed_id),
  KEY idx_assignment_dates (start_date, end_date, status)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS transfer (
  id            BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  pilgrim_id    BIGINT NOT NULL,
  from_bed_id   BIGINT NOT NULL,
  to_bed_id     BIGINT NOT NULL,
  reason        VARCHAR(500),
  transfer_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status        ENUM('approved','pending','rejected') NOT NULL DEFAULT 'pending',
  CONSTRAINT fk_transfer_pilgrim
    FOREIGN KEY (pilgrim_id) REFERENCES pilgrim(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_transfer_from_bed
    FOREIGN KEY (from_bed_id) REFERENCES bed(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_transfer_to_bed
    FOREIGN KEY (to_bed_id) REFERENCES bed(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  KEY idx_transfer_pilgrim (pilgrim_id)
) ENGINE=InnoDB;