# Defining New Fields

A common approach with JSON columns is to have them represent dictionaries, which in turn
represent multiple values based on keys:

    CREATE TABLE example (
        id int not null,
        value jsonb not null
    );

    INSERT INTO example VALUES(0, '{"foo": "bar", "this": "that"}');

    SELECT value->>'foo' as foo, value->>'this' as this FROM example WHERE id = 0;
     foo | this
    -----+------
     bar | that
    (1 row)

Since the values stored in this dictionary under `foo` and `this` are not part of the database
schema, we do not have to do **any work** to add a new field `baz`:

    UPDATE example
       SET value = jsonb_set(value, '{baz}', '"buzz"')
     WHERE id = 0;

    SELECT value->>'baz' as baz FROM example WHERE id = 0;
     baz
    ------
     buzz
    (1 row)

It's hard to compete with **zero work**, but since having no schema comes with some other costs
(e.g. code complexity, lack of explicitness), it's worth quantifying how much work it takes to
add a new field.

My assumption here is that we're using an ORM of some sort and have something like the following
(based on Python's SQLAlchemy):

    class Example(Base):
        id = Column(Integer, nullable=False, primary_key=True)

What does it take to add a new `baz` field? We have to do three things:

 1. Modify the ORM's definition of the table.
 2. Modify the database's definition of the table.
 3. Modify whatever uses the ORM's definition.

The first of these is trivial; we just add a new `Column` (one line of code):

    class Example(Base):
        id = Column(Integer, nullable=False, primary_key=True)
        baz = Column(String, nullable=True)

The second is also trivial; we just add the column to the database at some point before
we upgrade the application code to reference it:

    ALTER TABLE example ADD COLUMN baz varchar;

The final part has variable complexity. If upstream application code continues to treat
data as an opaque dictionary, we can do something like:

    class Example:
         ...

         @property
         def value(self):
             return {
                 key: value
                 for key, value in self.__dict__
                 if key not in ("id", )
             }

That is, we can define a layer of indirection that *automatically* incorporates all
declared fields into a dictionary for use upstream (and we only need to make this change
once).

If, on the other hand, the upstream application software wished to refer direction to
the field `baz`, we have to write that code. Ultimately such costs are likely to be small
because the upstream application layers (e.g. API resources and controllers) are likely
to have the same sort of "add one declartion" extensibility. And if they don't, the likely
reason is that we require some non-trivial business logic that references the field `baz`
and would have to write that logic no matter what pattern we used at our database layer.

In other words, while non-zero, the costs of adding a new field as a database column are
small and bounded in most cases.
