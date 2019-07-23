DROP TABLE IF EXISTS example;
CREATE TABLE example (
  id INT NOT NULL,
  foo INT,
  bar INT,
  PRIMARY KEY (id)
);
\COPY example FROM '/tmp/data.csv' CSV;
