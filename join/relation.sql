DROP TABLE IF EXISTS numbers;
DROP TABLE IF EXISTS values;

CREATE TABLE numbers (
  id INT NOT NULL,
  number int
);

CREATE INDEX numbers_id_key ON numbers (id);

CREATE TABLE values (
  id INT NOT NULL,
  value varchar,
  PRIMARY KEY (id)
);

INSERT INTO numbers SELECT id, json_array_elements(numbers::json)::text::int FROM example;
INSERT INTO values SELECT id, value->>'name' FROM example;
