#!/usr/bin/env python
from csv import writer
from sys import stdout


ONE_MILLION = 1000000


if __name__ == "__main__":
    writer_ = writer(stdout)
    for row in range(ONE_MILLION):
        writer_.writerow((row, row % 2, row % 17))
