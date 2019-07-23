DROP TABLE IF EXISTS example;
CREATE TABLE example (
  id INT NOT NULL,
  numbers jsonb not null,
  value jsonb,
  PRIMARY KEY (id)
);
\COPY example FROM '/tmp/data.csv' CSV;
