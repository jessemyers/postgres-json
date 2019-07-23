WITH sample AS (
   SELECT floor(random() * (1000000 + 1)) as id
   FROM generate_series(1, 100)
)
SELECT example.id, array_agg(numbers.number), min(values.value)
  FROM example
  JOIN numbers
    ON example.id = numbers.id
  JOIN values
    ON example.id = values.id
  JOIN sample
    ON example.id = sample.id
GROUP BY example.id;
