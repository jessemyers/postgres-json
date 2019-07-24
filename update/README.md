# Using Transactions For Updates

As with queries, having all data in a single row with JSON columns means that complex
updates need only change a single row. And since the update touches only a single row,
the application does not need to manage its transactions.

Putting aside whether a distributed web application should be ignorant of its transactions,
let's compare the complexity of this kind of update with and without JSON columns.


## Scenario

We use the following scenario:

 -  A record accumulates potential bids over time.
 -  At some point of in time, we want to update the record with the winning bid
    and simultaneously remove all other bids.


## JSON Column Implementation

We use the following table:

    CREATE TABLE example (
      id INT NOT NULL,
      bids jsonb not null,
      value int,
      PRIMARY KEY (id)
    );

And add a record:

    INSERT INTO example VALUES (0, '[]', null);

Over time, we add bids one by one:

    UPDATE example SET bids = bids || '[3]' WHERE id = 0;
    UPDATE example SET bids = bids || '[7]' WHERE id = 0;
    UPDATE example SET bids = bids || '[2]' WHERE id = 0;
    UPDATE example SET bids = bids || '[5]' WHERE id = 0;

Then we finish bidding:

    WITH bids AS (
       SELECT id, jsonb_array_elements_text(bids)::int AS bid
         FROM example
    ), ranked_bids AS (
       SELECT id, bid, rank() OVER (ORDER BY bid DESC) as rank
         FROM bids
    )
    UPDATE example
       SET value = bid, bids = '[]'
      FROM ranked_bids
     WHERE ranked_bids.id = example.id
       AND ranked_bids.rank = 1
       AND example.id = 0;

Note that most of the complexity here involves switching between JSON and non-JSON representations. It's awkward
but it's not quite fair to blame JSON columns for this problem of syntax.


## Multi Table Implementation

The more classic alternative is:

    CREATE TABLE example (
      id INT NOT NULL,
      value int,
      PRIMARY KEY (id)
    );

    CREATE TABLE bids (
      id INT NOT NULL,
      bid int
    );

    CREATE INDEX bids_id_key ON bids(id);

Then:

    INSERT INTO example VALUES (0, null);

And:

    INSERT INTO bids VALUES (0, 3);
    INSERT INTO bids VALUES (0, 7);
    INSERT INTO bids VALUES (0, 2);
    INSERT INTO bids VALUES (0, 5);

And our update logic becomes:

    BEGIN;

    WITH ranked_bids AS (
       SELECT id, bid, rank() OVER (ORDER BY bid DESC) as rank
         FROM bids
    )
    UPDATE example
       SET value = bid
      FROM ranked_bids
     WHERE ranked_bids.id = example.id
       AND ranked_bids.rank = 1
       AND example.id = 0;

    DELETE FROM bids WHERE id = 0;

    COMMIT;

Note that we need to have an explicit `BEGIN` and `COMMIT` to enforce that our `UPDATE` and `DELETE` happen
in the same transaction. Otherwise, the logic is very similar, just broken into two different statements.


## What Does This Mean?

There isn't much difference here except for the need to wrap this update in a transaction. Given that the
update logic has some complexity in it, we'd expect a reasonable code base to encapsulate this operation
into a function, which means that the transaction logic can be added by wrapping this function in a small
bit of boilerplate transaction logic. (Alternatively: by making every HTTP request define a transaction
boundary).

That is: the cost of adding transactions should not be large enough to influence the choice here.
