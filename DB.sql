CREATE DATABASE IF NOT EXISTS ycywa
  DEFAULT CHARACTER SET utf8mb4;

USE ycywa;

CREATE TABLE user_account (
  uuid        BINARY(16)   NOT NULL,
  email       VARCHAR(255) NOT NULL,
  login       VARCHAR(100) NOT NULL,
  type        VARCHAR(50)  NOT NULL,
  password    VARCHAR(255) NOT NULL,
  created_at  DATETIME     NOT NULL,
  updated_at  DATETIME     NOT NULL,
  PRIMARY KEY (uuid),
  UNIQUE KEY uk_user_account_email (email),
  UNIQUE KEY uk_user_account_login (login)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE user_profile (
  uuid          BINARY(16)   NOT NULL,
  first_name    VARCHAR(100) NULL,
  last_name     VARCHAR(100) NULL,
  birth_date    DATE         NULL,
  address_line1 VARCHAR(255) NULL,
  address_line2 VARCHAR(255) NULL,
  postal_code   VARCHAR(20)  NULL,
  city          VARCHAR(120) NULL,
  country_code  VARCHAR(2)   NULL,
  updated_at    DATETIME     NOT NULL,
  PRIMARY KEY (uuid),
  CONSTRAINT fk_user_profile_user_account
    FOREIGN KEY (uuid) REFERENCES user_account(uuid)
    ON DELETE CASCADE
    ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE oauth_account (
  id        CHAR(36)      NOT NULL,
  uuid      BINARY(16)    NOT NULL,
  provider  VARCHAR(50)   NOT NULL,
  email     VARCHAR(255)  NOT NULL,
  linked_at DATETIME      NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_oauth_account_email (email),
  KEY idx_oauth_account_uuid (uuid),
  CONSTRAINT fk_oauth_account_user_account
    FOREIGN KEY (uuid) REFERENCES user_account(uuid)
    ON DELETE CASCADE
    ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE agency (
  id           BIGINT NOT NULL AUTO_INCREMENT,
  name         VARCHAR(150) NOT NULL,
  address      VARCHAR(255) NULL,
  city         VARCHAR(120) NULL,
  country_code VARCHAR(2)   NULL,
  phone        VARCHAR(50)  NULL,
  status       VARCHAR(50)  NOT NULL,
  created_at   DATETIME     NOT NULL,
  updated_at   DATETIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_agency_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE vehicle (
  id           BIGINT NOT NULL AUTO_INCREMENT,
  agency_id    BIGINT NOT NULL,
  brand        VARCHAR(100) NOT NULL,
  model        VARCHAR(100) NOT NULL,
  plate_number VARCHAR(30)  NOT NULL,
  status       VARCHAR(50)  NOT NULL,
  category     VARCHAR(50)  NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_vehicle_plate_number (plate_number),
  KEY idx_vehicle_agency_id (agency_id),
  CONSTRAINT fk_vehicle_agency
    FOREIGN KEY (agency_id) REFERENCES agency(id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE offer (
  id         BIGINT NOT NULL AUTO_INCREMENT,
  agency_id  BIGINT NOT NULL,
  city_start VARCHAR(120) NOT NULL,
  city_end   VARCHAR(120) NOT NULL,
  date_start DATETIME     NOT NULL,
  date_end   DATETIME     NOT NULL,
  price      DECIMAL(10,2) NOT NULL,
  currency   CHAR(3)      NOT NULL,
  status     VARCHAR(50)  NOT NULL,
  created_at DATETIME     NOT NULL,
  PRIMARY KEY (id),
  KEY idx_offer_agency_id (agency_id),
  KEY idx_offer_dates (date_start, date_end),
  KEY idx_offer_city (city_start, city_end),
  CONSTRAINT fk_offer_agency
    FOREIGN KEY (agency_id) REFERENCES agency(id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE offer_vehicle (
  offer_id   BIGINT NOT NULL,
  vehicle_id BIGINT NOT NULL,
  PRIMARY KEY (offer_id, vehicle_id),
  KEY idx_offer_vehicle_vehicle_id (vehicle_id),
  CONSTRAINT fk_offer_vehicle_offer
    FOREIGN KEY (offer_id) REFERENCES offer(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  CONSTRAINT fk_offer_vehicle_vehicle
    FOREIGN KEY (vehicle_id) REFERENCES vehicle(id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE reservation (
  id            BIGINT NOT NULL AUTO_INCREMENT,
  offer_id      BIGINT    NOT NULL,
  uuid          BINARY(16) NOT NULL, -- user uuid
  first_name    VARCHAR(100) NOT NULL,
  last_name     VARCHAR(100) NOT NULL,
  birth_date    DATE         NOT NULL,
  address_line1 VARCHAR(255) NOT NULL,
  address_line2 VARCHAR(255) NOT NULL,
  postal_code   VARCHAR(20)  NOT NULL,
  city          VARCHAR(120) NOT NULL,
  country_code  VARCHAR(2)   NOT NULL,
  status        VARCHAR(50)  NOT NULL,
  amount_total  DECIMAL(10,2) NOT NULL,
  currency      CHAR(3)      NOT NULL,
  reserved_at   DATETIME     NOT NULL,
  PRIMARY KEY (id),
  KEY idx_reservation_offer_id (offer_id),
  KEY idx_reservation_uuid (uuid),
  KEY idx_reservation_reserved_at (reserved_at),
  CONSTRAINT fk_reservation_offer
    FOREIGN KEY (offer_id) REFERENCES offer(id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT fk_reservation_user_account
    FOREIGN KEY (uuid) REFERENCES user_account(uuid)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE payment (
  id                  BIGINT NOT NULL AUTO_INCREMENT,
  reservation_id      BIGINT NOT NULL,
  provider            VARCHAR(50)  NOT NULL,
  provider_payment_id VARCHAR(255) NOT NULL,
  amount              DECIMAL(10,2) NOT NULL,
  currency            CHAR(3)      NOT NULL,
  status              VARCHAR(50)  NOT NULL,
  created_at          DATETIME     NOT NULL,
  paid_at             DATETIME     NULL,
  PRIMARY KEY (id),
  KEY idx_payment_reservation_id (reservation_id),
  UNIQUE KEY uk_payment_provider_payment_id (provider, provider_payment_id),
  CONSTRAINT fk_payment_reservation
    FOREIGN KEY (reservation_id) REFERENCES reservation(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE support_category (
  id   BIGINT NOT NULL AUTO_INCREMENT,
  name VARCHAR(120) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_support_category_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE faq_item (
  id             BIGINT NOT NULL AUTO_INCREMENT,
  support_cat_id BIGINT NOT NULL,
  question       VARCHAR(255) NOT NULL,
  answer         TEXT         NOT NULL,
  created_at     DATETIME     NOT NULL,
  updated_at     DATETIME     NOT NULL,
  PRIMARY KEY (id),
  KEY idx_faq_item_support_cat_id (support_cat_id),
  CONSTRAINT fk_faq_item_support_category
    FOREIGN KEY (support_cat_id) REFERENCES support_category(id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE support_ticket (
  id             BIGINT NOT NULL AUTO_INCREMENT,
  uuid           BINARY(16) NOT NULL, -- user uuid
  support_cat_id BIGINT NOT NULL,
  status         VARCHAR(50) NOT NULL,
  created_at     DATETIME    NOT NULL,
  updated_at     DATETIME    NOT NULL,
  closed_at      DATETIME    NULL,
  PRIMARY KEY (id),
  KEY idx_support_ticket_uuid (uuid),
  KEY idx_support_ticket_support_cat_id (support_cat_id),
  KEY idx_support_ticket_status (status),
  CONSTRAINT fk_support_ticket_user_account
    FOREIGN KEY (uuid) REFERENCES user_account(uuid)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT fk_support_ticket_support_category
    FOREIGN KEY (support_cat_id) REFERENCES support_category(id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE support_ticket_message (
  id               BIGINT NOT NULL AUTO_INCREMENT,
  support_ticket_id BIGINT NOT NULL,
  sender_uuid      BINARY(16) NOT NULL,
  sender_type      VARCHAR(50) NOT NULL,
  content          TEXT        NOT NULL,
  is_email         BOOLEAN     NOT NULL DEFAULT FALSE,
  created_at       DATETIME    NOT NULL,
  PRIMARY KEY (id),
  KEY idx_stm_ticket_id (support_ticket_id),
  KEY idx_stm_sender_uuid (sender_uuid),
  CONSTRAINT fk_stm_support_ticket
    FOREIGN KEY (support_ticket_id) REFERENCES support_ticket(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  CONSTRAINT fk_stm_sender_user_account
    FOREIGN KEY (sender_uuid) REFERENCES user_account(uuid)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE support_ticket_message_attachment (
  id          BIGINT NOT NULL AUTO_INCREMENT,
  message_id  BIGINT NOT NULL,
  filename    VARCHAR(255) NOT NULL,
  mime_type   VARCHAR(100) NOT NULL,
  size_bytes  BIGINT       NOT NULL,
  storage_key VARCHAR(255) NOT NULL,
  created_at  DATETIME     NOT NULL,
  PRIMARY KEY (id),
  KEY idx_stma_message_id (message_id),
  CONSTRAINT fk_stma_message
    FOREIGN KEY (message_id) REFERENCES support_ticket_message(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE support_ticket_channel (
  support_ticket_id BIGINT NOT NULL,
  name              VARCHAR(80) NOT NULL,
  status            VARCHAR(50) NOT NULL,
  created_at        DATETIME    NOT NULL,
  closed_at         DATETIME    NULL,
  PRIMARY KEY (support_ticket_id, name),
  CONSTRAINT fk_support_ticket_channel_ticket
    FOREIGN KEY (support_ticket_id) REFERENCES support_ticket(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE support_ticket_chat_session (
  id              BIGINT NOT NULL AUTO_INCREMENT,
  support_ticket_id BIGINT NOT NULL,
  created_at      DATETIME NOT NULL,
  PRIMARY KEY (id),
  KEY idx_stcs_ticket_id (support_ticket_id),
  CONSTRAINT fk_stcs_support_ticket
    FOREIGN KEY (support_ticket_id) REFERENCES support_ticket(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE support_ticket_chat_message (
  id              BIGINT NOT NULL AUTO_INCREMENT,
  chat_session_id BIGINT NOT NULL,
  sender_uuid     BINARY(16) NOT NULL,
  sender_type     VARCHAR(50) NOT NULL,
  content         TEXT        NOT NULL,
  created_at      DATETIME    NOT NULL,
  PRIMARY KEY (id),
  KEY idx_stcm_session_id (chat_session_id),
  KEY idx_stcm_sender_uuid (sender_uuid),
  CONSTRAINT fk_stcm_chat_session
    FOREIGN KEY (chat_session_id) REFERENCES support_ticket_chat_session(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  CONSTRAINT fk_stcm_sender_user_account
    FOREIGN KEY (sender_uuid) REFERENCES user_account(uuid)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE support_rating (
  id               BIGINT NOT NULL AUTO_INCREMENT,
  support_ticket_id BIGINT NOT NULL,
  score            TINYINT NOT NULL,
  comment          TEXT    NULL,
  created_at       DATETIME NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_support_rating_ticket (support_ticket_id),
  CONSTRAINT fk_support_rating_ticket
    FOREIGN KEY (support_ticket_id) REFERENCES support_ticket(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
