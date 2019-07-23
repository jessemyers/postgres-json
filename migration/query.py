#!/usr/bin/env python
from random import choice, randint


ONE_MILLION = 1000000


def query_one():
    row = randint(0, ONE_MILLION)
    return f"SELECT * FROM example WHERE id = {row};"


def add_one():
    row = randint(ONE_MILLION, 2 * ONE_MILLION)
    return f"INSERT INTO example VALUES ({row}, {row % 2}, {row % 17});"


def remove_one():
    row = randint(0, ONE_MILLION)
    return f"DELETE FROM example WHERE id = {row};"


if __name__ == "__main__":
    func = choice([query_one, add_one, remove_one])
    print(func())
