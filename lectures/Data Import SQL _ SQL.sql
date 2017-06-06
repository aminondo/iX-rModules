-- To source this file in a SQLite session run
--
-- sqlite> .read <filename>

-- ==========================================================================================================
-- SETUP
-- ==========================================================================================================

-- Most databases will have FOREIGN KEY support enabled by default. Not so with SQLite.
--
PRAGMA foreign_keys;
PRAGMA foreign_keys = ON;
--
-- Find out more about PRAGMA at https://www.sqlite.org/pragma.html.

-- Make that output more user friendly.
--
.mode column
.headers on

-- Let's find out about all of the special dot commands.
--
.help

-- ==========================================================================================================
-- CREATE TABLE
-- ==========================================================================================================

-- Data Types in SQLite: https://www.sqlite.org/datatype3.html

CREATE TABLE tb_Profession
(
    JobId       INTEGER PRIMARY KEY AUTOINCREMENT,
    Description VARCHAR(128)
);

CREATE TABLE tb_Person
(
    PersonId    INTEGER PRIMARY KEY AUTOINCREMENT,
    Name        VARCHAR(128),
    Gender      CHAR(1) NOT NULL,
    Height      REAL,
    Birth       DATE,
    JobId       INTEGER DEFAULT 0 NOT NULL,
    FOREIGN KEY (JobId) REFERENCES tb_Profession(JobId)
);

-- Get a list of tables.
--
.tables
--
-- Checking the structure of the table. Normally you would do this with
--
-- > DESCRIBE tb_Person
--
-- but SQLite is a little different. There are two options.
--
PRAGMA table_info(tb_Person);
.schema tb_Person
.schema
--
-- Note that these need to be run in the terminal client since they are not actually SQL.

-- ==========================================================================================================
-- INSERT DATA
-- ==========================================================================================================

INSERT INTO tb_Profession (JobId) VALUES (0);
INSERT INTO tb_Profession (Description) VALUES ('Data Scientist');
INSERT INTO tb_Profession (Description) VALUES ('Data Analyst');
INSERT INTO tb_Profession (Description) VALUES ('Database Administrator');
INSERT INTO tb_Profession (Description) VALUES ('Statistician');
INSERT INTO tb_Profession (Description) VALUES ('Developer');
INSERT INTO tb_Profession (Description) VALUES ('Team Lead');

INSERT INTO tb_Person (Name, Gender, Birth) VALUES ('Thomas',  'M',  '2003-03-19');
INSERT INTO tb_Person (Name, Gender, Birth) VALUES ('Andrea',  'F',  '2001-06-13');
INSERT INTO tb_Person (Name, Gender, Birth) VALUES ('Roberta', 'F',  '2002-06-25');
INSERT INTO tb_Person (Name, Gender, Height, Birth) VALUES ('Rudy',    'M',  182.5, '2001-11-24');
INSERT INTO tb_Person (Name, Gender, Height, Birth) VALUES ('Maria',   'F',  175.3, '2002-06-28');
INSERT INTO tb_Person (Name, Gender, Height, Birth) VALUES ('Anthony', 'M',  184.7, '2001-12-23');
INSERT INTO tb_Person (Name, Gender) VALUES ('Carl',   'M');
INSERT INTO tb_Person (Name, Gender) VALUES ('Arthur', 'M');
INSERT INTO tb_Person (Name, Gender, Height) VALUES ('Frankie', 'F', 173.8);
INSERT INTO tb_Person (Name) VALUES ('Chris');                  -- This won't work! Why?

-- ==========================================================================================================
-- SIMPLE QUERIES
-- ==========================================================================================================

SELECT * FROM tb_Person;

SELECT * FROM tb_Person WHERE Gender = 'F' AND Birth IS NULL;   -- All Female with missing Birth
SELECT * FROM tb_Person WHERE Birth >= '2002-06-01';            -- All with Birth after 1 June 2002

-- Q. Select all males whose Height is not NULL.
-- Q. Select all people whose names begin with 'A'.

-- Ordering.
--
SELECT Name, Birth FROM tb_Person ORDER BY Birth DESC;

-- Aggregation (https://www.sqlite.org/lang_aggfunc.html)
--
SELECT Gender, AVG(Height) AS AvgHeight, MIN(Height) AS MinHeight, MAX(Height) AS MaxHeight
    FROM tb_Person
    GROUP BY Gender;
--
-- A WHERE clause cannot be applied to the results of aggregation.
--
SELECT Gender, COUNT(*) AS Population
    FROM tb_Person
    GROUP BY Gender
    HAVING Population > 4;

-- ==========================================================================================================
-- ALTER TABLE
-- ==========================================================================================================

-- Add a column to a table.
--
ALTER TABLE tb_Person ADD TaxReference CHAR(12);

-- ==========================================================================================================
-- UPDATING DATA
-- ==========================================================================================================

-- Update existing records.
--
UPDATE tb_Person SET TaxReference = '250602X783U2' WHERE PersonId = 3;
UPDATE tb_Person SET TaxReference = '241101Y129U0' WHERE PersonId = 4;

UPDATE tb_Person SET Birth = '2001-12-21' WHERE PersonId = 7;
UPDATE tb_Person SET Birth = '2001-06-16' WHERE Name = 'Thomas';

UPDATE tb_Person SET JobId = 4 WHERE Name IN ('Andrea', 'Maria');
UPDATE tb_Person SET JobId = 2 WHERE PersonId = 4;

-- Q. Update the table so that the rest of the people are Data Scientists.

-- ==========================================================================================================
-- DELETING DATA
-- ==========================================================================================================

-- Deleting data should be approached with great care. There is no "Are you sure?" prompt.
--
DELETE FROM tb_Person WHERE Name = 'Frankie';

DELETE FROM tb_Profession WHERE JobId = 1;                      -- This won't work! Why?

-- ==========================================================================================================
-- SUB-QUERIES AND COMPOUND QUERIES
-- ==========================================================================================================

-- A Sub-Query is a nested query (one query within another).
--
SELECT * FROM tb_Person WHERE JobId IN (SELECT JobId FROM tb_Profession WHERE Description LIKE 'Data%');

-- ==========================================================================================================
-- TABLE JOINS
-- ==========================================================================================================

-- Information on FOREIGN KEY support in SQLite: https://www.sqlite.org/foreignkeys.html

-- INNER JOIN
--
SELECT    Name, Gender, Description AS Job
FROM      tb_Person P
JOIN      tb_Profession Q
ON
          P.JobId = Q.JobId;

-- OUTER JOIN
--
SELECT Description, Name FROM tb_Profession P LEFT OUTER JOIN tb_Person Q ON P.JobId = Q.JobId;

-- JOIN and Sub-Query
--
SELECT    Description, Workers
FROM
          (SELECT JobId, COUNT(*) AS Workers FROM tb_Person GROUP BY JobId) A
INNER JOIN
          tb_Profession B
ON
          A.JobId = B.JobId;

-- ==========================================================================================================
-- CLEANING UP
-- ==========================================================================================================

-- After numerous transactions the database file can get a little messy. This will sort that out.
--
VACUUM;

-- ==========================================================================================================
-- DELETE TABLE
-- ==========================================================================================================

-- DROP TABLE tb_Person;
-- DROP TABLE tb_Profession;
