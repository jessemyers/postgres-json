# Using JSON Columns in PostgreSQL

PostgreSQL supports JSON columns in text (`json`) and binary (`jsonb`) formats, meaning that when
deciding between schema-based and schema-less database designs, you can have both at the same time,
even in the same table:

    CREATE TABLE example (
        id int not null,
        value jsonb not null
    );

That said, schema-less database designs have their drawbacks:
  -  You lose out on having SQL -- the *lingua franca* of data -- act as the interface definition
     for your data structure.
  -  You aren't able to take advantage of the database's native ability to enforce and validate
     your data structure.
  -  You are more likely to encounter bugs caused by production data having a structure you did
     not anticipate because it was represented by an implicit, historic schema.


## When Should You Use JSON Columns?

In my experience, the drawbacks of JSON colums are only justified when both of the following are true:

 1. The level of effort to map your data structure into SQL is high.
 2. Your data structure is isolated to a small area and a small number of people.

Application prototypes can fit these criteria. So too can storage of deeply nested structures used in
isolated areas of your code base.

On the other hand, an application's **core entities** very rarely are a good choice for JSON columns;
most such objects are easily representable with a relational model and must be understand by large parts
of your application (and, probably, data warehouse).


## Why Do People Use JSON Columns For Core Entities Anyway?

What follows are a few arguments (and rebuttals) to some of the common arguments **in favor of**
JSON columns to represent core entities **even knowing** that the loss of explicitness has a tangible
cost.

 1. [I have to write too much code to add a new field.](./new_field)
 2. [I can't afford to migrate the database to add a new field.](./migration)
 3. [I need to avoid joins to get good query performance.](./join)
 4. [I don't want to have to worry about updating multiple tables.](./update)
