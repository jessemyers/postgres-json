#!/usr/bin/env python
from csv import writer
from json import dumps
from random import randint, sample
from sys import stdout


ONE_MILLION = 1000000
NUMBERS = list(range(100))


if __name__ == "__main__":
    writer_ = writer(stdout)
    for row in range(ONE_MILLION):
        writer_.writerow(
            (
                row,
                dumps(
                    sample(NUMBERS, randint(0, 20)),
                ),
                dumps(dict(
                    name=f"row{row}",
                )),
            ),
        )
