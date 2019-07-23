# Migrating The Schema To Add New Fields

Database migrations can be tricky, but out of all the common migrations, adding a new column
to an existing table is one of the safeest. Adding new null columns to tables in PostgreSQL
has always been fast. Since PostgreSQL 11, adding new columns with non-null default values
has also been fast.

Here's a simple example:

 0. Make sure you're running a new enough PostgreSQL (>= 11):

        > psql --version
        psql (PostgreSQL) 11.4

 1. Create a PostgreSQL database for experimentation:

        > createdb example

 2. Generate a million rows of data in CSV format:

        > ./generate.py > /tmp/data.csv

 3. Create the schema and load the data

        > cat load.sql | psql example
        DROP TABLE
        CREATE TABLE
        COPY 1000000

 4. Add a column (and measure the running time):

        > time cat migrate.sql | psql example
        ALTER TABLE

        real    0m0.023s
        user    0m0.008s
        sys     0m0.010s

Your measurements will vary, but clearly, this is not enough latency to matter much.

Let's do the same thing, but with some simulated load happening while we apply the change:

 A. Install the `parallel` tool:

        brew install parallel

 B. Reset the schema and data

        > cat load.sql | psql example
        DROP TABLE
        CREATE TABLE
        COPY 1000000

 C. Generate some concurrent queries in the background.

    This command will run for several (e.g. 5-10) seconds. We want to run the
    next command while it is still executing:

        > seq 1000 | parallel --jobs 4 "./query.py | psql example | true" &

 D. Add a column again (and measure the running time):

        > time cat migrate.sql | psql example
        ALTER TABLE

        real    0m0.033s
        user    0m0.009s
        sys     0m0.009s

Contention with ongoing queries introduces a small amount of additional latency, but nothing
that should matter much nor that indicates that a full table lock is taking place.
