WITH sample AS (
   SELECT floor(random() * (1000000 + 1)) as id
   FROM generate_series(1, 100)
)
SELECT example.id, example.numbers, value
  FROM example
  JOIN sample
    ON example.id = sample.id;
