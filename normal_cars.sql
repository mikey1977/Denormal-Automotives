\c mikey;
-- Create a new postgres user named normal_user
CREATE USER "normal_user";

-- Create a new database named normal_cars owned by normal_user
DROP DATABASE IF EXISTS normal_cars;

CREATE DATABASE normal_cars OWNER normal_user;

\c normal_cars;

\i ./scripts/denormal_data.sql;
-- \i ./scripts/denormal_data.sql;
-- Whiteboard your solution to normalizing the denormal_cars schema.
-- [bonus] Generate a diagram (somehow) in .png (or other) format,
--  that of your normalized cars schema. (save and commit to this repo)


-- In normalized.sql Create a query to generate the tables needed to
--  accomplish your normalized schema, including any primary and
--   foreign key constraints. Logical renaming of columns is allowed.


CREATE TABLE make (
  id serial PRIMARY KEY,
  company_code varchar(100),
  company_title varchar(100)
  );

CREATE TABLE model (
  id serial PRIMARY KEY,
  name_code varchar(100),
  name_title varchar(100)
  );

CREATE TABLE year (
  id serial PRIMARY KEY,
  year int
  );

CREATE TABLE normalized_cars (
  id serial PRIMARY KEY,
  make_id int REFERENCES make (id),
  model_id int REFERENCES model (id),
  year_id int REFERENCES year (id)
  );
-- Using the resources that you now possess, In normal.sql Create
--  queries to insert all of the data that was in the denormal_cars.car_models
--   table, into the new normalized tables of the normal_cars database.
INSERT INTO make (company_code, company_title)
SELECT make_code, make_title
FROM car_models;

INSERT INTO model (name_code, name_title)
SELECT model_code, model_title
FROM car_models;

INSERT INTO year
SELECT DISTINCT year
FROM car_models;

INSERT INTO normalized_cars (make_id, model_id, year_id)
SELECT make.id, model.id, year.id
FROM make, model, year, car_models
WHERE make.company_code = car_models.make_code
AND make.company_title = car_models.make_title
AND model.name_code = car_models.model_code
AND model.name_title = car_models.model_title
AND year.year = car_models.year;
-- In normal.sql Create a query to get a list of all make_title values
--  in the car_models table. (should have 71 results)
SELECT DISTINCT ON (company_title) company_title FROM make;


SELECT DISTINCT company_title FROM make INNER JOIN normalized_cars ON make.id = normalized_cars.year_id;
-- In normal.sql Create a query to list all model_title values where
--  the make_code is 'VOLKS' (should have 27 results)
SELECT DISTINCT ON (name_title) name_title FROM model WHERE name_code = 'VOLKS';

SELECT model.name_title
FROM normalized_cars
INNER JOIN make
ON normalized_cars.make_id = make.id
INNER JOIN model
ON normalized_cars.make_id = model.id
WHERE make.company_code = 'VOLKS';
-- In normal.sql Create a query to list all make_code, model_code,
--  model_title, and year from car_models where the make_code is 'LAM'
--   (should have 136 rows)
SELECT DISTINCT ON (make.company_code) make.company_code, (model.name_code) model.name_code, (model.name_title) model.name_title, (year.year) year.year
FROM normalized_cars
INNER JOIN make
ON normalized_cars.make_id = make.id
INNER JOIN model
ON normalized_cars.model_id = model.id
INNER JOIN year
ON normalized_cars.year_id = year.id
WHERE make.company_code = 'LAM';

-- In normal.sql Create a query to list all fields from all car_models
--  in years between 2010 and 2015 (should have 7884 rows)

SELECT DISTINCT cm.make_code as make, cd.model_code as model, cd.model_title as title, cy.year_id as year
FROM car_normal cn
INNER JOIN car_makes cm
ON cn.make_id = cm.id
INNER JOIN car_models cd
ON cn.model_id = cd.id
INNER JOIN car_years cy
ON cn.years_id = cy.id
WHERE cn.make_code = 'LAM'


SELECT car_models.model_code
FROM car_normal
INNER JOIN car_models
ON car_normal.model_id = car_models.id
INNER JOIN car_years
ON cn.year_id = car_years.id
WHERE year BETWEEN 2010 and 2015;