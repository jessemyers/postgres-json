# Using Joins For Decomposition

One of the benefits of using JSON columns is that related data can be retrieved in a query
for a single row (instead of using joins).

For example, this table essentially embeds a one-to-many relationship (`numbers`) as well
as a one-to-one relationship (`value`):

    CREATE TABLE example (
      id INT NOT NULL,
      numbers jsonb not null,
      value jsonb,
      PRIMARY KEY (id)
    );

    INSERT INTO example VALUES (0, '[1, 3, 5, 7, 9]', '{"label": "odds"}');

Querying this table for a row by id *automatically* returns all related data.


## How Fast Is Using A Single Row?

 1. Create a PostgreSQL database for experimentation:

        > createdb example

 2. Generate a million rows of data in CSV format:

        > ./generate.py > /tmp/data.csv

 3. Create the schema and load the data

        > cat load.sql | psql example
        DROP TABLE
        CREATE TABLE
        COPY 1000000

 4. Query 100 rows:

        > time cat query.sql | psql example > /dev/null

        real    0m0.161s
        user    0m0.009s
        sys     0m0.007s


## What Happens If We Use Joins?

 1. Create and populate tables for our relationships.

        > cat relation.sql | psql example

 2. Query 100 rows using joins:

        > time cat query_join.sql | psql example > /dev/null

        real    0m2.683s
        user    0m0.009s
        sys     0m0.009s


## What Does This Mean?

Querying one row is an order of magnitude faster than querying tens of rows joined by an
indexed identifier. But, even in the worst case, the average time per query is measured
in *tens of milliseconds*. In almost every case, this latency will be dwarfed by the
computation time and network I/O of sending data from a server to an end-user.

In other words: putting all data in one row with JSON columns is *faster* but this speed
up is unlikely to make any difference in most applications. Optimizing for query speed
is probably a false economy.
