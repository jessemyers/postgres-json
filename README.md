# Using JSON Columns in PostgreSQL

PostgreSQL supports JSON columns in text (`json`) and binary (`jsonb`) formats, meaning that when
deciding between schema-based and schema-less database designs, you can have both at the same time,
even in the same table:

    CREATE TABLE example (
        id int not null,
        value jsonb not null
    );

That said, schema-less database designs have their drawbacks. You lose out on having SQL -- the
*lingua franca* of data -- act on the interface definition for your data structure. You aren't
able to take advantage of the database's native ability to enforce and validate your structure. You
are more likely to encounter bugs caused by production data having a structure you did not anticipate.


## When Should You Use JSON Columns?

In my experience, the drawbacks of JSNOn colums are only justified when both of the following are true:

 1. The level of effort to map your data structure into SQL is high.
 2. Your data structure is isolated to a small area and a small number of people.

Application prototypes can fit these criteria. So can storage of deeply nested structures used in
isolated areas of your code base.

On the other hand, an application's core entities very rarely are a good choice for JSON columns;
large parts of your application (and, probably, data warehouse) depend on understanding and interpreting
these structures.


## Why Do People Use JSON Columns When They Know They Shouldn't?

What follows are a few arguments (and rebuttals) to some of the common arguments **in favor of**
JSON columns to represent core entities **even knowing** that the loss of explicitness has a tangible
cost.

 1. It's less work if I don't have to change my schema to add a new field.
 2. [I can't afford to run a migration to add a new field.][./migration]
 3. I'm worried about the performance of using joins.
 4. I don't want to have to worry about updating multiple tables.
