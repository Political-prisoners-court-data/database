CREATE USER airtable;
CREATE SCHEMA AUTHORIZATION airtable;

CREATE USER db;
CREATE SCHEMA db;
GRANT USAGE ON SCHEMA db TO db;
GRANT TRUNCATE, SELECT, INSERT ON ALL TABLES IN SCHEMA db to db;

GRANT USAGE ON SCHEMA scraper TO db;
GRANT TRUNCATE, SELECT ON ALL TABLES IN SCHEMA scraper TO db;


CREATE TABLE db.rfm_person
(
    full_name  TEXT,
    aliases    text[],
    is_terr    boolean NOT NULL,
    birth_date date,
    address    text,
    PRIMARY KEY (full_name, birth_date)
);

CREATE OR REPLACE VIEW db.rfm_added AS
SELECT new.full_name, new.birth_date, new.is_terr
FROM db.rfm_person AS old
         RIGHT OUTER JOIN scraper.rfm_person AS new
                          USING (full_name, birth_date)
WHERE old.full_name IS NULL;

CREATE OR REPLACE VIEW db.rfm_removed AS
SELECT old.full_name, old.birth_date, old.is_terr
FROM db.rfm_person AS old
         LEFT OUTER JOIN scraper.rfm_person AS new
                         USING (full_name, birth_date)
WHERE new.full_name IS NULL;

CREATE OR REPLACE VIEW db.rfm_changed AS
SELECT old.full_name,
       old.birth_date,
       old.is_terr as old_is_terr,
       new.is_terr as new_is_terr,
       old.aliases as old_aliases,
       new.aliases as new_aliases,
       old.address as old_address,
       new.address as new_address
FROM db.rfm_person AS old
         INNER JOIN scraper.rfm_person AS new
                    USING (full_name, birth_date)
WHERE old.is_terr <> new.is_terr
   OR old.address <> new.address
   OR old.aliases <> new.aliases;
