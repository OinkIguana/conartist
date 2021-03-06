DO
$do$
BEGIN
   IF NOT EXISTS (
      SELECT                       -- SELECT list can stay empty for this
      FROM   pg_catalog.pg_roles
      WHERE  rolname = 'conartist_app') THEN

      CREATE ROLE conartist_app WITH LOGIN PASSWORD 'temporary-password';
   END IF;
END
$do$;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO conartist_app;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO conartist_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT USAGE ON SEQUENCES TO conartist_app;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO conartist_app;

CREATE TABLE Users (
  user_id     SERIAL PRIMARY KEY,
  email       VARCHAR(512) UNIQUE NOT NULL,
  name        VARCHAR(512) NOT NULL,
  password    VARCHAR(512) NOT NULL,
  keys        INT NOT NULL DEFAULT 1,
  join_date   TIMESTAMP NOT NULL DEFAULT (NOW()::TIMESTAMP),
  CONSTRAINT user_nonempty_email CHECK (char_length(email) > 0),
  CONSTRAINT user_nonempty_name CHECK (char_length(name) > 0)
);
CREATE INDEX index_Users ON Users (email);
COMMENT ON TABLE Users IS 'A user of the ConArtist app';
-- TODO: add column comments

CREATE TABLE UserSettings (
  user_id   INT PRIMARY KEY REFERENCES Users (user_id) ON DELETE CASCADE,
  currency  CHAR(3) NOT NULL DEFAULT 'CAD' -- Must be a valid currency code
);
CREATE INDEX index_UserSettings ON UserSettings (user_id);
COMMENT ON TABLE UserSettings IS 'Configuration for each user''s specific environment';

CREATE TABLE Conventions (
  con_id      SERIAL PRIMARY KEY,
  title       VARCHAR(512) NOT NULL,
  start_date  DATE NOT NULL,
  end_date    DATE NOT NULL,
  extra_info  JSON NOT NULL DEFAULT ('[]'), -- { name: "Title", info: "Info", action: "Action", actionText: "ActionText" }[]
  predecessor INT REFERENCES Conventions (con_id)
);
CREATE INDEX index_Conventions ON Conventions (con_id);
COMMENT ON TABLE Conventions IS 'The many conventions that are taking place around the world';

CREATE TABLE ConventionImages (
  image_id    SERIAL PRIMARY KEY,
  con_id      INT NOT NULL REFERENCES Conventions (con_id) ON DELETE CASCADE,
  image_uuid  CHAR(36) NOT NULL,
  create_date TIMESTAMP NOT NULL DEFAULT (NOW()::TIMESTAMP)
);
CREATE INDEX index_ConventionImages ON ConventionImages (con_id);
COMMENT ON TABLE ConventionImages IS 'Images associated with conventions';

CREATE TABLE ConventionInfo (
  con_info_id SERIAL PRIMARY KEY,
  con_id      INT NOT NULL REFERENCES Conventions (con_id) ON DELETE CASCADE,
  user_id     INT NOT NULL REFERENCES Users       (user_id) ON DELETE SET NULL,
  information TEXT NOT NULL,
  CONSTRAINT no_duplicate_info UNIQUE (con_id, information)
);
CREATE INDEX index_ConventionInfo ON ConventionInfo (con_id);
COMMENT ON TABLE ConventionInfo IS 'User contributed information about a convention';

CREATE TABLE ConventionRatings (
  con_id      INT NOT NULL REFERENCES Conventions (con_id)  ON DELETE CASCADE,
  user_id     INT NOT NULL REFERENCES Users       (user_id) ON DELETE CASCADE,
  rating      INT NOT NULL,
  review      TEXT NOT NULL,
  PRIMARY KEY (con_id, user_id)
);
CREATE INDEX index_ConventionRatings ON ConventionRatings (con_id);

CREATE TABLE ConventionInfoRatings (
  con_info_id INT NOT NULL REFERENCES ConventionInfo (con_info_id) ON DELETE CASCADE,
  user_id     INT NOT NULL REFERENCES Users          (user_id)     ON DELETE CASCADE,
  rating      BOOLEAN NOT NULL,
  PRIMARY KEY (con_info_id, user_id)
);
CREATE INDEX index_ConventionInfoRatings ON ConventionInfoRatings (con_info_id);
COMMENT ON TABLE ConventionInfoRatings IS 'Tracks the quality of provided info';

CREATE TABLE User_Conventions (
  user_con_id SERIAL PRIMARY KEY,
  user_id     INT NOT NULL REFERENCES Users       (user_id) ON DELETE CASCADE,
  con_id      INT NOT NULL REFERENCES Conventions (con_id)  ON DELETE CASCADE,
  CONSTRAINT unique_user_convention UNIQUE (user_id, con_id)
);
CREATE INDEX index_User_Conventions ON User_Conventions (user_id);
COMMENT ON TABLE User_Conventions IS 'Links users to conventions, indicating that they plan to be selling there';

CREATE TABLE ProductTypes (
  type_id       SERIAL PRIMARY KEY,
  user_id       INT NOT NULL REFERENCES Users (user_id) ON DELETE CASCADE,
  name          VARCHAR(512) NOT NULL,
  color         INT,
  discontinued  BOOLEAN NOT NULL DEFAULT (FALSE),
  CONSTRAINT unique_type_per_person UNIQUE (user_id, name)
);
CREATE INDEX index_ProductTypes ON ProductTypes (user_id);
COMMENT ON TABLE ProductTypes IS 'The types of products that a user produces';

CREATE TABLE Products (
  product_id    SERIAL PRIMARY KEY,
  type_id       INT NOT NULL REFERENCES ProductTypes  (type_id)   ON DELETE CASCADE,
  user_id       INT NOT NULL REFERENCES Users         (user_id)   ON DELETE CASCADE,
  name          VARCHAR(512) NOT NULL,
  discontinued  BOOLEAN NOT NULL DEFAULT (FALSE),
  CONSTRAINT unique_product_per_person UNIQUE (user_id, type_id, name),
  CONSTRAINT product_nonempty_name CHECK (char_length(name) > 0)
);
CREATE INDEX index_Products ON Products (user_id, type_id);
COMMENT ON TABLE Products IS 'The specific products that a user produces';

CREATE TABLE Inventory (
  inventory_id SERIAL PRIMARY KEY,
  product_id   INT NOT NULL REFERENCES Products          (product_id)  ON DELETE CASCADE,
  quantity     INT NOT NULL,
  mod_date     TIMESTAMP NOT NULL DEFAULT (NOW()::TIMESTAMP)
);
COMMENT ON TABLE Inventory IS 'Keeps track of how many of each item a user has by recording modifications over time';

-- TODO: would this be better as user-prices and con-prices?
-- TODO: history of price changes? or something at least to allow changing prices
--       during a convention instead?
-- TODO: THE NOMS DATABASE?!?!
CREATE TABLE Prices (
  price_id    SERIAL PRIMARY KEY,
  user_id     INT          REFERENCES Users             (user_id)     ON DELETE CASCADE,
  user_con_id INT          REFERENCES User_Conventions  (user_con_id) ON DELETE CASCADE,
  type_id     INT NOT NULL REFERENCES ProductTypes      (type_id)     ON DELETE CASCADE,
  product_id  INT          REFERENCES Products          (product_id)  ON DELETE CASCADE,
  prices      JSON NOT NULL, -- [#Quantity#, "Money"][]
  CONSTRAINT user_or_con CHECK (
    (user_id IS NOT NULL AND user_con_id IS NULL) OR
    (user_id IS NULL AND user_con_id IS NOT NULL)
  )
  -- TODO: would be nice to check that all quantities and prices >= 0
);
CREATE INDEX index_Prices_con ON Prices (user_con_id);
CREATE INDEX index_Prices_user ON Prices (user_id);
COMMENT ON TABLE Prices IS 'Records how much each product or product type should cost, for a user or for a specific convention';

-- CHAR(23) is used to represent money, 23 being the longest possible length
-- e.g. CAD-9223372036854775808 to CAD9223372036854775807
CREATE TABLE Records (
  record_id   SERIAL PRIMARY KEY,
  user_id     INT NOT NULL,
  con_id      INT NOT NULL,
  price       CHAR(23) NOT NULL,
  products    INT[] NOT NULL,
  info        TEXT NOT NULL DEFAULT '',
  sale_time   TIMESTAMP NOT NULL DEFAULT (NOW()::TIMESTAMP),
  FOREIGN KEY (user_id, con_id) REFERENCES User_Conventions (user_id, con_id)
);
CREATE INDEX index_Records ON Records (user_id, con_id);
COMMENT ON TABLE Records IS 'Represents a sale of one or more products to one customer';

CREATE TABLE Expenses (
  expense_id  SERIAL PRIMARY KEY,
  user_id     INT NOT NULL,
  con_id      INT NOT NULL,
  price       CHAR(23) NOT NULL,
  category    VARCHAR(32) NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  spend_time  TIMESTAMP NOT NULL DEFAULT (NOW()::TIMESTAMP),
  FOREIGN KEY (user_id, con_id) REFERENCES User_Conventions (user_id, con_id)
);
CREATE INDEX index_Expenses ON Expenses (user_id, con_id);
COMMENT ON TABLE Expenses IS 'Represents something that was purchased by a user to facilitate their attendence at a convention';
